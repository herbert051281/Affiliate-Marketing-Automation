#!/usr/bin/env bash
# Schema regression tests. Runs db/schema.sql against a throwaway local Postgres
# and asserts the things that are expensive to get wrong:
#
#   1. the schema applies cleanly, with and without Supabase's roles
#   2. net_revenue does not double-subtract reversals
#   3. pending revenue is never counted as earned
#   4. bot clicks are excluded from aff_clicks
#   5. visits do not fan out when a page carries several offers
#   6. the anon role (whose key is PUBLIC) cannot read or write anything
#      except published content
#
# Usage:  ./db/test-schema.sh
# Needs:  postgresql server binaries (initdb, pg_ctl). No network, no Docker.
set -euo pipefail

SCHEMA="$(cd "$(dirname "$0")" && pwd)/schema.sql"
PGBIN="${PGBIN:-$(ls -d /usr/lib/postgresql/*/bin 2>/dev/null | tail -1)}"
[ -x "$PGBIN/initdb" ] || { echo "postgres binaries not found; set PGBIN"; exit 1; }

RUN="$(mktemp -d)"; PORT="${PGPORT:-5433}"
# Postgres refuses to run as root; fall back to the postgres system user.
AS=""; [ "$(id -u)" = "0" ] && AS="postgres" && chown -R postgres:postgres "$RUN"
run() { if [ -n "$AS" ]; then su "$AS" -c "$1"; else bash -c "$1"; fi; }
cleanup() { run "$PGBIN/pg_ctl -D $RUN/data stop -m immediate" >/dev/null 2>&1 || true; rm -rf "$RUN"; }
trap cleanup EXIT

run "$PGBIN/initdb -D $RUN/data -U postgres --auth=trust" >/dev/null
run "$PGBIN/pg_ctl -D $RUN/data -o '-k $RUN -p $PORT -c listen_addresses=\"\"' -l $RUN/pg.log start" >/dev/null
PSQL="psql -h $RUN -p $PORT -U postgres -v ON_ERROR_STOP=1 -q"

fail=0
ok()   { echo "  PASS  $1"; }
bad()  { echo "  FAIL  $1"; fail=1; }
check(){ [ "$2" = "$3" ] && ok "$1 ($2)" || bad "$1 — expected $3, got $2"; }

echo "1. applies without Supabase roles (plain Postgres)"
$PSQL -d postgres -c "create database plain;" >/dev/null
$PSQL -d plain -f "$SCHEMA" >/dev/null && ok "applied" || bad "failed"

echo "2. applies over Supabase's permissive default grants"
$PSQL -d postgres -c "create role anon nologin" -c "create role authenticated nologin" >/dev/null
$PSQL -d postgres -c "create database app" >/dev/null
$PSQL -d app -c "grant usage on schema public to anon, authenticated;
  grant all privileges on all tables in schema public to anon, authenticated;
  grant all privileges on all sequences in schema public to anon, authenticated;
  alter default privileges in schema public grant all on tables to anon, authenticated;" >/dev/null
$PSQL -d app -f "$SCHEMA" >/dev/null && ok "applied" || bad "failed"

echo "3. rollup arithmetic"
$PSQL -d app >/dev/null <<'SQL'
insert into niches (name, slug, status) values ('test','test','active');
insert into programs (niche_id, merchant) select id,'M' from niches;
insert into offers (program_id, name, destination_url) select id,'A','https://a.example' from programs;
insert into offers (program_id, name, destination_url) select id,'B','https://b.example' from programs;
insert into content_items (niche_id, title, slug, status) select id,'pub','pub','published' from niches;
insert into content_items (niche_id, title, slug, status) select id,'hidden','hidden','drafting' from niches;
insert into links (slug, offer_id, content_item_id) select 'a', o.id, c.id from offers o, content_items c where o.name='A' and c.slug='pub';
insert into links (slug, offer_id, content_item_id) select 'b', o.id, c.id from offers o, content_items c where o.name='B' and c.slug='pub';
insert into page_view_daily (date, content_item_id, channel_code, visits) select current_date, id,'site',1000 from content_items where slug='pub';
insert into click_events (link_id, content_item_id, channel_code, is_bot) select l.id,l.content_item_id,'site',false from links l, generate_series(1,50) where l.slug='a';
insert into click_events (link_id, content_item_id, channel_code, is_bot) select l.id,l.content_item_id,'site',false from links l, generate_series(1,30) where l.slug='b';
insert into click_events (link_id, content_item_id, channel_code, is_bot) select l.id,l.content_item_id,'site',true  from links l, generate_series(1,7)  where l.slug='a';
-- $100 kept, $100 reversed, $50 still pending
insert into conversions (program_id,offer_id,content_item_id,channel_code,network_order_id,amount,status,occurred_at)
  select p.id,o.id,c.id,'site','O1',100,'approved',now() from programs p, offers o, content_items c where o.name='A' and c.slug='pub';
insert into conversions (program_id,offer_id,content_item_id,channel_code,network_order_id,amount,status,occurred_at)
  select p.id,o.id,c.id,'site','O2',100,'reversed',now() from programs p, offers o, content_items c where o.name='A' and c.slug='pub';
insert into conversions (program_id,offer_id,content_item_id,channel_code,network_order_id,amount,status,occurred_at)
  select p.id,o.id,c.id,'site','O3',50,'pending',now()  from programs p, offers o, content_items c where o.name='A' and c.slug='pub';
insert into costs (category, amount, content_item_id) select 'ai_api',12,id from content_items where slug='pub';
insert into costs (category, amount) values ('hosting', 6);
SQL
q() { $PSQL -d app -tAc "$1" 2>/dev/null | tr -d ' ' || true; }
check "visits not fanned out across 2 offers" "$(q 'select coalesce(sum(visits),0) from daily_metrics')" "1000"
check "bot clicks excluded"                   "$(q 'select sum(aff_clicks) from daily_metrics')"          "80"
check "net_revenue not double-subtracted"     "$(q 'select sum(net_revenue) from daily_metrics')"         "100.00"
check "pending not counted as earned"         "$(q 'select sum(pending_revenue) from daily_metrics')"     "50.00"
check "costs counted once"                    "$(q 'select sum(cost) from daily_metrics')"                "18.00"
check "profit = net - cost"                   "$(q 'select sum(profit) from daily_metrics')"              "82.00"

echo "4. anon lockdown (the anon key is public — treat it as an attacker)"
for t in conversions costs programs offers click_events approvals qa_scores config \
         alerts tools tool_pricing_history email_list_daily content_items page_view_daily \
         links niches keywords recommendations scoring_weights workflow_runs; do
  out=$($PSQL -d app -tAc "set role anon; select count(*) from $t;" 2>&1 | head -1 || true)
  case "$out" in *"permission denied"*) ;; *) bad "anon can read $t"; esac
done
[ $fail -eq 0 ] && ok "all tables denied to anon"
for stmt in "delete from conversions" "insert into click_events (channel_code) values ('x')" "update offers set destination_url='x'"; do
  out=$($PSQL -d app -tAc "set role anon; $stmt;" 2>&1 | head -1 || true)
  case "$out" in *"permission denied"*) ok "anon blocked: ${stmt:0:34}" ;; *) bad "anon could run: $stmt" ;; esac
done
check "anon reads published content only" "$(q "set role anon; select count(*) from published_content")" "1"

echo
[ $fail -eq 0 ] && echo "ALL TESTS PASSED" || { echo "TESTS FAILED"; exit 1; }
