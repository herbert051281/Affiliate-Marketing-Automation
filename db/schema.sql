-- ============================================================================
-- Affiliate Marketing Automation — core schema (PostgreSQL / Supabase)
-- Run once in the Supabase SQL editor.
--
-- Read the security section at the bottom before exposing anything publicly.
-- In Supabase the anon key is PUBLIC (it ships in the browser bundle), and the
-- anon role is granted full CRUD on public-schema tables by default. A table
-- with RLS disabled is therefore world-readable AND world-writable. This file
-- revokes those defaults and enables RLS on every table.
-- ============================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- 0. Helpers
-- ---------------------------------------------------------------------------
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 0b. Config — runtime knobs the workflows read.
-- Budgets, autonomy thresholds and circuit-breaker limits live here, not
-- hard-coded in workflow nodes, so changing one is a DB update and an audit
-- trail rather than an edit in eleven places.
-- ---------------------------------------------------------------------------
create table config (
  key         text primary key,
  value       jsonb not null,
  description text,
  updated_at  timestamptz not null default now()
);
create trigger trg_config_updated before update on config
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- 1. Niches
-- ---------------------------------------------------------------------------
create table niches (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  slug            text unique not null,
  status          text not null default 'candidate'
                    check (status in ('candidate','active','rejected','archived')),
  score           numeric(5,2),
  score_breakdown jsonb,          -- {monetization:82, intent:71, gap:64, durability:80, distribution:75}
  evidence        jsonb,          -- raw data behind the score, for auditability
  created_at      timestamptz not null default now(),
  approved_at     timestamptz
);

-- ---------------------------------------------------------------------------
-- 2. Programs (merchant / network relationships) — TOS stored as ENFORCEABLE data
-- ---------------------------------------------------------------------------
create table programs (
  id                   uuid primary key default gen_random_uuid(),
  niche_id             uuid references niches(id) on delete cascade,
  merchant             text not null,
  network              text,                       -- impact | partnerstack | shareasale | direct | ...
  status               text not null default 'prospect'
                         check (status in ('prospect','applied','approved','rejected','paused','terminated')),
  applied_at           timestamptz,
  approved_at          timestamptz,

  -- commercial terms
  commission_type      text check (commission_type in ('recurring','one_time','tiered','hybrid')),
  commission_rate      numeric(6,3),               -- percent, or fixed amount if commission_fixed set
  commission_fixed     numeric(10,2),
  merchant_arpu        numeric(10,2),              -- for recurring value modelling
  expected_retention_m numeric(5,1),               -- expected months retained
  cookie_days          integer,
  epc_reported         numeric(10,4),              -- network-published EPC
  payout_threshold     numeric(10,2),
  payout_terms         text,                       -- 'net-60' etc.

  -- TOS as booleans the workflows actually check
  allows_email         boolean default false,
  allows_paid_search   boolean default false,
  allows_brand_bidding boolean default false,
  allows_coupon        boolean default false,
  allows_ai_content    boolean,                    -- null = unspecified
  required_disclosure  text,
  tos_url              text,
  tos_hash             text,                       -- detect TOS changes between scans
  tos_last_checked     timestamptz,

  offer_score          numeric(5,2),
  notes                text,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);
create trigger trg_programs_updated before update on programs
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- 3. Offers (a specific product/link within a program)
-- ---------------------------------------------------------------------------
create table offers (
  id               uuid primary key default gen_random_uuid(),
  program_id       uuid not null references programs(id) on delete cascade,
  name             text not null,
  destination_url  text not null,                  -- the merchant URL incl. your affiliate id
  subid_param      text default 'subid',           -- varies: subid | sub1 | u1 | clickref
  is_primary       boolean default false,
  backup_offer_id  uuid references offers(id),     -- auto-swap target for W11
  health_status    text default 'ok'
                     check (health_status in ('ok','degraded','broken','paused')),
  last_checked_at  timestamptz,
  epc_observed     numeric(10,4),                  -- YOUR measured EPC, not the network's claim
  active           boolean default true,
  created_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 3b. Tools + pricing history
-- This is the structured product database the programmatic comparison pages
-- render from (doc 01, "the moat"), and the source of the pricing-history
-- original-value requirement that W05 assigns and W07 enforces (doc 07).
-- ---------------------------------------------------------------------------
create table tools (
  id              uuid primary key default gen_random_uuid(),
  niche_id        uuid references niches(id) on delete cascade,
  name            text not null,
  slug            text not null,
  vendor          text,
  website         text,
  category        text,                            -- rmm | psa | documentation | backup | ...
  program_id      uuid references programs(id),    -- null when we can't monetize it (still list it)
  our_score       numeric(5,2),                    -- score against OUR published rubric
  rubric_scores   jsonb,                           -- {setup:8, reporting:6, integrations:9, support:7}
  features        jsonb,                           -- feature matrix, drives comparison tables
  best_for        text,
  disqualifier    text,                            -- who this tool is WRONG for (brand voice rule 2)
  screenshot_urls text[],                          -- our own captures, not vendor marketing images
  last_reviewed_at timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (niche_id, slug)
);
create trigger trg_tools_updated before update on tools
  for each row execute function set_updated_at();

create table tool_pricing_history (
  id             uuid primary key default gen_random_uuid(),
  tool_id        uuid not null references tools(id) on delete cascade,
  plan_name      text not null,
  price          numeric(10,2),
  currency       text default 'USD',
  unit           text,                             -- per_technician | per_seat | flat | per_endpoint
  billing_period text check (billing_period in ('monthly','annual','one_time')),
  limits         jsonb,                            -- {endpoints:100, users:5}
  captured_on    date not null default current_date,
  source_url     text,
  created_at     timestamptz not null default now(),
  unique (tool_id, plan_name, billing_period, captured_on)
);
create index on tool_pricing_history (tool_id, captured_on desc);

-- ---------------------------------------------------------------------------
-- 4. Keywords / topic opportunities
-- ---------------------------------------------------------------------------
create table keywords (
  id                 uuid primary key default gen_random_uuid(),
  niche_id           uuid references niches(id) on delete cascade,
  term               text not null,
  volume             integer,
  cpc                numeric(8,2),
  difficulty         numeric(5,2),
  intent             text check (intent in ('transactional','comparison','informational','problem_aware')),
  serp_features      jsonb,
  competitor_summary jsonb,                        -- top-10 domains + authority spread
  expected_value     numeric(10,2),                -- output of W04
  ev_per_effort      numeric(10,4),
  status             text not null default 'new'
                       check (status in ('new','scored','queued','used','suppressed')),
  suppressed_reason  text,
  created_at         timestamptz not null default now(),
  unique (niche_id, term)
);
create index on keywords (status);

-- SERP snapshots over time. ContentDurability in the doc 02 scoring model is
-- "inverse of how often the top pages change" — that needs a time series, not
-- a single scrape.
create table serp_snapshots (
  id              uuid primary key default gen_random_uuid(),
  keyword_id      uuid not null references keywords(id) on delete cascade,
  captured_on     date not null default current_date,
  results         jsonb not null,                  -- [{position, domain, url, title, dr}]
  top_domains     text[],
  weak_slots_pct  numeric(5,2),                    -- % of top-10 held by DR<40 / forums / Reddit
  churn_vs_prev   numeric(5,2),                    -- % of top-10 that changed since last snapshot
  created_at      timestamptz not null default now(),
  unique (keyword_id, captured_on)
);

-- ---------------------------------------------------------------------------
-- 5. Content pipeline
-- ---------------------------------------------------------------------------
create table content_items (
  id                   uuid primary key default gen_random_uuid(),
  niche_id             uuid references niches(id) on delete cascade,
  keyword_id           uuid references keywords(id),
  title                text,
  slug                 text unique,
  content_type         text default 'article'
                         check (content_type in ('article','comparison','review','listicle','landing','programmatic')),
  status               text not null default 'proposed'
                         check (status in ('proposed','approved_topic','briefing','briefed',
                                           'drafting','drafted','qa','qa_failed','ready',
                                           'published','updated','killed')),
  brief                jsonb,
  original_value_req   text,                       -- what first-hand data this piece MUST contain
  body_md              text,
  meta                 jsonb,                      -- title variants, meta description, schema
  primary_offer_id     uuid references offers(id),
  cluster              text,                       -- for cluster-level kill/scale decisions
  published_at         timestamptz,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);
create index on content_items (status);
create index on content_items (cluster);
create trigger trg_content_items_updated before update on content_items
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- 6. QA scores — also the dataset that governs graduated autonomy
-- ---------------------------------------------------------------------------
create table qa_scores (
  id                  uuid primary key default gen_random_uuid(),
  content_item_id     uuid not null references content_items(id) on delete cascade,
  factual             numeric(5,2),
  original_value      numeric(5,2),
  brand_voice         numeric(5,2),
  compliance          numeric(5,2),
  link_integrity      numeric(5,2),
  differentiation     numeric(5,2),
  total               numeric(5,2),
  hard_floor_breached boolean default false,
  failures            jsonb,                       -- [{axis, line, detail}]
  predicted_decision  text check (predicted_decision in ('publish','review','reject')),
  human_decision      text check (human_decision in ('publish','review','reject')),
  human_reason        text,                        -- feeds back into the QA rules file
  created_at          timestamptz not null default now()
);
create index on qa_scores (created_at desc);

-- ---------------------------------------------------------------------------
-- 7. Assets (images, videos, carousels)
-- ---------------------------------------------------------------------------
create table assets (
  id              uuid primary key default gen_random_uuid(),
  content_item_id uuid references content_items(id) on delete cascade,
  asset_type      text check (asset_type in ('image','video','carousel','audio')),
  url             text,
  meta            jsonb,                           -- hook, duration, aspect ratio, script
  created_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 8. Channels & publications
-- ---------------------------------------------------------------------------
create table channels (
  id       uuid primary key default gen_random_uuid(),
  code     text unique not null,                   -- site | tiktok | reels | shorts | linkedin | x | email
  name     text not null,
  active   boolean default true
);

create table publications (
  id              uuid primary key default gen_random_uuid(),
  content_item_id uuid references content_items(id) on delete cascade,
  asset_id        uuid references assets(id),
  channel_id      uuid not null references channels(id),
  external_url    text,
  external_id     text,
  scheduled_for   timestamptz,
  published_at    timestamptz,
  status          text default 'scheduled'
                    check (status in ('scheduled','published','failed','removed')),
  created_at      timestamptz not null default now()
);
create index on publications (channel_id, published_at);

-- ---------------------------------------------------------------------------
-- 9. Tracked links + clicks  (the attribution spine)
-- ---------------------------------------------------------------------------
create table links (
  id              uuid primary key default gen_random_uuid(),
  slug            text unique not null,            -- yoursite.com/go/{slug}
  offer_id        uuid not null references offers(id),
  content_item_id uuid references content_items(id),
  placement       text,                            -- hero_table | inline | sticky | email | bio
  active          boolean default true,
  created_at      timestamptz not null default now()
);

create table click_events (
  id              bigserial primary key,
  click_id        uuid not null default gen_random_uuid(),   -- passed to merchant as subid
  link_id         uuid references links(id),
  content_item_id uuid references content_items(id),
  channel_code    text,
  referrer        text,
  country         text,
  device          text,
  ua_hash         text,                            -- hashed, not raw UA — keep it privacy-clean
  is_bot          boolean default false,
  occurred_at     timestamptz not null default now()
);
create index on click_events (occurred_at);
-- Unique, not just indexed: the click_id is the subid a merchant reports back.
-- If two clicks ever shared one, W12 would attribute a sale to the wrong page.
create unique index on click_events (click_id);
create index on click_events (content_item_id, occurred_at);

-- Visits, ingested daily from the site analytics provider (GA4 / Plausible /
-- Vercel Analytics). Affiliate CTR and RPM — the two diagnostics doc 06 and
-- doc 08 are built on — are undefined without this.
-- Aggregated, not raw pageviews: it is what the analytics APIs return, it keeps
-- the rollup cheap, and it stores no visitor-level data.
create table page_view_daily (
  id               uuid primary key default gen_random_uuid(),
  date             date not null,
  content_item_id  uuid references content_items(id) on delete cascade,
  channel_code     text,                           -- referral source bucket
  visits           integer not null default 0,
  unique_visitors  integer,
  avg_seconds      numeric(8,2),
  bounce_rate      numeric(5,2),
  source           text,                           -- ga4 | plausible | vercel
  ingested_at      timestamptz not null default now(),
  unique (date, content_item_id, channel_code)
);
create index on page_view_daily (date);

-- ---------------------------------------------------------------------------
-- 10. Conversions  (reversals tracked separately — net revenue is the only truth)
-- ---------------------------------------------------------------------------
create table conversions (
  id               uuid primary key default gen_random_uuid(),
  program_id       uuid references programs(id),
  offer_id         uuid references offers(id),
  click_id         uuid,                           -- matched back to click_events.click_id
  content_item_id  uuid references content_items(id),
  channel_code     text,
  network_order_id text,
  amount           numeric(10,2),                  -- commission amount
  sale_amount      numeric(10,2),
  currency         text default 'USD',
  status           text not null default 'pending'
                     check (status in ('pending','approved','reversed','paid')),
  is_recurring     boolean default false,
  occurred_at      timestamptz,
  ingested_at      timestamptz not null default now(),
  unique (program_id, network_order_id)
);
create index on conversions (occurred_at);
create index on conversions (content_item_id);
create index on conversions (click_id);

-- ---------------------------------------------------------------------------
-- 11. Costs
-- ---------------------------------------------------------------------------
create table costs (
  id          uuid primary key default gen_random_uuid(),
  category    text not null,                       -- ai_api | data_api | video | hosting | email | ads | tools
  description text,
  amount      numeric(10,2) not null,
  content_item_id uuid references content_items(id),  -- when attributable
  incurred_on date not null default current_date,
  created_at  timestamptz not null default now()
);
create index on costs (incurred_on);

-- ---------------------------------------------------------------------------
-- 12. Approvals (audit trail for every gate)
-- ---------------------------------------------------------------------------
create table approvals (
  id          uuid primary key default gen_random_uuid(),
  gate        text not null check (gate in ('A','B','C','D','E')),
  entity_type text not null,                       -- niche | program | offer | content_item | spend | recommendation
  entity_id   uuid,
  decision    text not null check (decision in ('approved','rejected','deferred','edited')),
  reason      text,
  decided_by  text,
  decided_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 12b. Alerts — what W00 Watchdog, W11 and the circuit breakers write to.
-- The digest reads open rows; nothing else needs to know who raised them.
-- ---------------------------------------------------------------------------
create table alerts (
  id           uuid primary key default gen_random_uuid(),
  severity     text not null default 'warning'
                 check (severity in ('info','warning','critical')),
  source       text not null,                      -- 'W11' | 'W00' | 'breaker:spend'
  kind         text not null,                      -- link_broken | terms_changed | traffic_drop | budget_exceeded
  entity_type  text,
  entity_id    uuid,
  message      text not null,
  detail       jsonb,
  status       text not null default 'open'
                 check (status in ('open','acknowledged','resolved')),
  created_at   timestamptz not null default now(),
  resolved_at  timestamptz
);
create index on alerts (status, created_at desc);

-- ---------------------------------------------------------------------------
-- 12c. Email list health — daily snapshot from the ESP API.
-- Deliberately aggregate: subscriber PII stays in the email platform, which is
-- the system of record for it and the one that has to honour unsubscribes.
-- ---------------------------------------------------------------------------
create table email_list_daily (
  date             date primary key,
  subscribers      integer not null default 0,
  new_subs         integer default 0,
  unsubs           integer default 0,
  sends            integer default 0,
  opens            integer default 0,
  clicks           integer default 0,
  ingested_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 13. Recommendations + learned scoring weights (the feedback loop)
-- ---------------------------------------------------------------------------
create table recommendations (
  id              uuid primary key default gen_random_uuid(),
  kind            text check (kind in ('kill','fix_placement','fix_offer','scale','expand_cluster','paid_test')),
  content_item_id uuid references content_items(id),
  cluster         text,
  rationale       text,
  evidence        jsonb,
  status          text default 'open' check (status in ('open','accepted','rejected','done')),
  created_at      timestamptz not null default now()
);

create table scoring_weights (
  id          uuid primary key default gen_random_uuid(),
  version     integer not null unique,
  weights     jsonb not null,                      -- {intent:{comparison:1.4, informational:0.6}, cluster:{...}}
  reason      text,
  active      boolean default false,
  created_at  timestamptz not null default now()
);
-- Exactly one active weight set, enforced by the database rather than by hoping
-- every workflow remembers to deactivate the previous row.
create unique index one_active_scoring_weight on scoring_weights (active) where active;

-- ---------------------------------------------------------------------------
-- 14. Workflow run log (W00 Watchdog reads this)
-- ---------------------------------------------------------------------------
create table workflow_runs (
  id           uuid primary key default gen_random_uuid(),
  workflow     text not null,                      -- 'W04'
  status       text not null check (status in ('running','success','failed')),
  items_in     integer,
  items_out    integer,
  cost_usd     numeric(10,4),                      -- what this run actually spent
  error        text,
  started_at   timestamptz not null default now(),
  finished_at  timestamptz
);
create index on workflow_runs (workflow, started_at desc);

-- ============================================================================
-- Reporting rollup — Power BI's fact table
-- Grain: date × content_item × channel × offer
-- W13 refreshes this nightly (materialize it once volume grows).
--
-- Revenue semantics, which every downstream decision depends on:
--   gross_revenue  = everything ever booked, INCLUDING what was later reversed
--   reversals      = the reversed portion
--   net_revenue    = gross_revenue - reversals   (what you actually keep)
--   pending_revenue= booked but not yet approved by the network. Reported
--                    separately and never counted in net: with net-30/60 terms
--                    it is weeks before a real sale turns into approved money,
--                    and treating pending as earned is how people scale a
--                    losing offer.
--
-- gross_revenue deliberately includes reversed rows. If it counted only
-- approved+paid, then net = gross - reversals would subtract reversals a second
-- time and understate net revenue by exactly the reversed amount.
--
-- visits attach to the (date, content, channel) grain with offer_id NULL,
-- because a pageview is not attributable to one offer. Summing across offer
-- rows in Power BI gives correct totals; slicing BY offer correctly shows no
-- visits. Affiliate CTR is therefore only meaningful at content/channel level.
-- ============================================================================
create or replace view daily_metrics as
with clicks as (
  select ce.occurred_at::date as d,
         ce.content_item_id,
         ce.channel_code,
         l.offer_id,
         count(*) as aff_clicks
  from click_events ce
  left join links l on l.id = ce.link_id
  where not ce.is_bot
  group by 1,2,3,4
),
views as (
  select pv.date as d,
         pv.content_item_id,
         pv.channel_code,
         null::uuid as offer_id,
         sum(pv.visits) as visits
  from page_view_daily pv
  group by 1,2,3
),
sales as (
  select c.occurred_at::date as d,
         c.content_item_id,
         c.channel_code,
         c.offer_id,
         count(*) filter (where c.status in ('approved','paid'))                      as conversions,
         count(*) filter (where c.status = 'pending')                                 as conversions_pending,
         coalesce(sum(c.amount) filter (where c.status in ('approved','paid','reversed')), 0) as gross_revenue,
         coalesce(sum(c.amount) filter (where c.status = 'reversed'), 0)              as reversals,
         coalesce(sum(c.amount) filter (where c.status = 'pending'), 0)               as pending_revenue
  from conversions c
  where c.occurred_at is not null
  group by 1,2,3,4
),
spend as (
  select incurred_on as d,
         content_item_id,
         null::text as channel_code,
         null::uuid as offer_id,
         sum(amount) as cost
  from costs
  group by 1,2
),
-- One row per distinct grain key present in any source, so each left join below
-- matches at most one row and nothing fans out.
grain as (
  select d, content_item_id, channel_code, offer_id from clicks
  union
  select d, content_item_id, channel_code, offer_id from views
  union
  select d, content_item_id, channel_code, offer_id from sales
  union
  select d, content_item_id, channel_code, offer_id from spend
)
select
  g.d                                                          as date,
  g.content_item_id,
  g.channel_code,
  g.offer_id,
  coalesce(v.visits, 0)                                        as visits,
  coalesce(cl.aff_clicks, 0)                                   as aff_clicks,
  coalesce(s.conversions, 0)                                   as conversions,
  coalesce(s.conversions_pending, 0)                           as conversions_pending,
  coalesce(s.gross_revenue, 0)                                 as gross_revenue,
  coalesce(s.reversals, 0)                                     as reversals,
  coalesce(s.gross_revenue, 0) - coalesce(s.reversals, 0)      as net_revenue,
  coalesce(s.pending_revenue, 0)                               as pending_revenue,
  coalesce(sp.cost, 0)                                         as cost,
  coalesce(s.gross_revenue, 0) - coalesce(s.reversals, 0)
                                - coalesce(sp.cost, 0)         as profit
from grain g
left join clicks cl
  on  cl.d = g.d
  and cl.content_item_id is not distinct from g.content_item_id
  and cl.channel_code    is not distinct from g.channel_code
  and cl.offer_id        is not distinct from g.offer_id
left join views v
  on  v.d = g.d
  and v.content_item_id is not distinct from g.content_item_id
  and v.channel_code    is not distinct from g.channel_code
  and v.offer_id        is not distinct from g.offer_id
left join sales s
  on  s.d = g.d
  and s.content_item_id is not distinct from g.content_item_id
  and s.channel_code    is not distinct from g.channel_code
  and s.offer_id        is not distinct from g.offer_id
left join spend sp
  on  sp.d = g.d
  and sp.content_item_id is not distinct from g.content_item_id
  and sp.channel_code    is not distinct from g.channel_code
  and sp.offer_id        is not distinct from g.offer_id;

-- ============================================================================
-- Seeds
-- ============================================================================
insert into channels (code, name) values
  ('site','Website'), ('tiktok','TikTok'), ('reels','Instagram Reels'),
  ('shorts','YouTube Shorts'), ('youtube','YouTube'), ('linkedin','LinkedIn'),
  ('x','X'), ('email','Newsletter'), ('reddit','Reddit')
on conflict (code) do nothing;

insert into config (key, value, description) values
  ('daily_ai_budget_usd',        '5',      'W-level budget guard. Over this, the pipeline aborts and alerts.'),
  ('autonomy_stage',             '1',      '1=review everything ... 4=auto-publish at threshold. See doc 05.'),
  ('autonomy_threshold',         '95',     'QA total required to auto-publish at the current stage.'),
  ('autonomy_agreement_floor',   '0.90',   'QA-vs-human agreement below this rolls autonomy back a stage.'),
  ('max_offer_revenue_share',    '0.60',   'Concentration breaker: alert when one merchant exceeds this.'),
  ('qa_rejection_rate_breaker',  '0.40',   'Pause publishing above this rejection rate over 20 drafts.'),
  ('traffic_drop_breaker',       '0.50',   'Pause and alert on a drop this large within 48h.'),
  ('conversion_drop_breaker',    '0.40',   'Pause new links to an offer on a w/w drop this large.'),
  ('reversal_rate_alert',        '0.25',   'Alert above this reversal rate for any offer.'),
  ('max_articles_per_day',       '3',      'Publishing pace cap. Doc 07: slow and steady beats 200 pages in week one.')
on conflict (key) do nothing;

insert into scoring_weights (version, weights, reason, active) values
  (1, '{"intent":{"transactional":1.0,"comparison":1.0,"informational":1.0,"problem_aware":1.0}}',
      'Neutral starting weights. W14 rewrites these from actual conversions.', true)
on conflict (version) do nothing;

-- ============================================================================
-- SECURITY
--
-- In Supabase the anon key is public by design — it is embedded in any
-- client-side bundle. The anon and authenticated roles are granted full CRUD on
-- public-schema tables by default, so "RLS disabled" means "world readable and
-- writable", NOT "private". Verified: with stock Supabase grants and RLS off,
-- the anon role can SELECT your commission data and DELETE every row in
-- `conversions`.
--
-- Posture here:
--   - revoke the blanket default grants from anon/authenticated
--   - enable RLS on every table, with no policy = no access
--   - expose exactly one read-only view to anon, with only safe columns
--   - the orchestrator uses the service role, which bypasses RLS
-- ============================================================================

-- 1. Drop the default blanket grants, including for tables created later.
--    Guarded so this file also runs on a plain Postgres (for local testing),
--    where Supabase's anon/authenticated roles do not exist.
do $$
declare r text;
begin
  foreach r in array array['anon','authenticated'] loop
    if exists (select 1 from pg_roles where rolname = r) then
      execute format('revoke all privileges on all tables    in schema public from %I', r);
      execute format('revoke all privileges on all sequences in schema public from %I', r);
      execute format('revoke all privileges on all functions in schema public from %I', r);
      execute format('alter default privileges in schema public revoke all on tables    from %I', r);
      execute format('alter default privileges in schema public revoke all on sequences from %I', r);
      execute format('alter default privileges in schema public revoke all on functions from %I', r);
    end if;
  end loop;
end;
$$;

-- 2. RLS on every table. Belt and braces: a loop, so a table added later and
--    forgotten here is still caught by re-running this block.
do $$
declare t record;
begin
  for t in
    select tablename from pg_tables where schemaname = 'public'
  loop
    execute format('alter table public.%I enable row level security', t.tablename);
    execute format('alter table public.%I force row level security', t.tablename);
  end loop;
end;
$$;

-- 3. The only thing the public site may read: published content, safe columns
--    only. Note what is NOT here — offers.destination_url carries your affiliate
--    ID, offers.epc_observed is your measured earnings, and neither belongs in
--    a public bundle. The /go redirector resolves those server-side with the
--    service role, so anon never needs the offers table at all.
create or replace view published_content
with (security_invoker = false) as
  select id, title, slug, content_type, body_md, meta, cluster, published_at
  from content_items
  where status = 'published';

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    grant usage  on schema public to anon;
    grant select on published_content to anon;
  end if;
end;
$$;

-- NOTE: `force row level security` also applies RLS to the table owner. The
-- Supabase service role has BYPASSRLS, so the orchestrator is unaffected; a
-- direct psql session as the owner will need policies or a superuser.
