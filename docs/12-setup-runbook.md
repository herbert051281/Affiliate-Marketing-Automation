# 12 — Setup Runbook

Everything that needs installing, in order. Assumes a machine where you can install
software. Budget ~2 hours.

Check off as you go — later steps depend on earlier ones.

---

## 0. Prerequisites

```bash
# Verify what you have
node --version      # need 20+
docker --version    # need Docker Desktop or Engine
git --version
```

Install what's missing:
- **Node 20+** — [nodejs.org](https://nodejs.org) or `winget install OpenJS.NodeJS.LTS`
- **Docker Desktop** — [docker.com](https://www.docker.com/products/docker-desktop/) ← *needs admin*
- **Git** — [git-scm.com](https://git-scm.com)

```bash
git clone https://github.com/herbert051281/Affiliate-Marketing-Automation.git
cd Affiliate-Marketing-Automation
cp .env.example .env     # fill in as you complete each step below
```

> `.env` is gitignored. Never commit it. Never paste a key into a doc, prompt, or workflow node.

---

## 1. Supabase — the data spine

Cloud, free tier. No admin rights needed.

1. Create an account at [supabase.com](https://supabase.com) → **New project**
   - Name: `affiliate-automation`
   - Region: closest to you
   - **Save the database password** — it's shown once
2. **SQL Editor** → paste all of [`db/schema.sql`](../db/schema.sql) → **Run**
3. Verify: **Table Editor** should show 24 tables and the `channels` table seeded with 9 rows
4. Sanity-check the lockdown — the schema revokes the default public grants, so this must
   return **zero rows**. If it returns any, the anon key (which ships in your site bundle)
   can read your commission data:

   ```sql
   select tablename from pg_tables
   where schemaname = 'public' and not rowsecurity;
   ```
5. **Settings → API** — copy into `.env`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY` (public — it ships in the site bundle, so treat it as published)
   - `SUPABASE_SERVICE_ROLE_KEY` (**secret** — orchestrator only, never client-side)
6. **Settings → Database → Connection string → Transaction pooler** (port **6543**)
   → `SUPABASE_DB_URL`

> Want to check the schema before touching Supabase? `./db/test-schema.sh` runs it against
> a throwaway local Postgres and asserts the rollup arithmetic and the anon lockdown.
> No network, no Docker.

> ⚠️ Use the **pooler** URI (6543) for n8n, not the direct connection (5432). n8n opens
> more connections than you'd expect and will exhaust the direct pool.

**Verify:**
```bash
psql "$SUPABASE_DB_URL" -c "select count(*) from channels;"   # expect 8
```

---

## 2. n8n — the orchestrator

### Local (start here)

```bash
mkdir -p ~/n8n-data
docker run -d --name n8n --restart unless-stopped \
  -p 5678:5678 \
  -v ~/n8n-data:/home/node/.n8n \
  -e N8N_ENCRYPTION_KEY="$(openssl rand -hex 32)" \
  -e GENERIC_TIMEZONE="America/New_York" \
  -e N8N_DIAGNOSTICS_ENABLED=false \
  docker.io/n8nio/n8n:latest
```

Open http://localhost:5678 and create the owner account.

> **Save the `N8N_ENCRYPTION_KEY` into `.env`.** Without it your stored credentials are
> unrecoverable if the container is rebuilt. This is the single easiest way to lose a
> weekend.

### VPS (do this before going live)

A local machine that sleeps won't run your 02:00 cron jobs. Move to a ~$6/mo VPS once the
workflows work. [`docker-compose.yml`](../docker-compose.yml) in the repo root sets up n8n
behind Caddy with automatic TLS:

```bash
# on the VPS
export N8N_HOST=n8n.yourdomain.com
export N8N_ENCRYPTION_KEY=<the same key, or a new one if starting fresh>
docker compose up -d
```

Point an A record at the VPS first. Caddy provisions the certificate automatically.

### Credentials to add in the n8n UI

**Credentials → Add** — never put these in workflow nodes directly:

| Credential | Type | Value |
|---|---|---|
| Supabase Postgres | Postgres | host/port/db/user/password from the pooler URI |
| Anthropic | Anthropic API | `ANTHROPIC_API_KEY` |
| DataForSEO | Basic Auth | login + password |

### Set an error workflow

Create a workflow named `ERR — alert` that writes to `workflow_runs` and emails you.
Then in **every** workflow: Settings → **Error Workflow** → `ERR — alert`.

Skipping this is how an automated business fails silently for three weeks
([doc 07](07-compliance-and-risk.md)).

---

## 3. API keys

| Service | Where | Env var | Cost |
|---|---|---|---|
| **Anthropic** | [console.anthropic.com](https://console.anthropic.com) | `ANTHROPIC_API_KEY` | ~$40–80/mo |
| **DataForSEO** | [dataforseo.com](https://dataforseo.com) | `DATAFORSEO_LOGIN` / `_PASSWORD` | pay-per-use, ~$20/mo |
| Email platform | Beehiiv or ConvertKit | `EMAIL_API_KEY` | free to ~1–2.5k subs |
| Video generation | your choice | `VIDEO_API_KEY` | ~$25–40/mo |

**Set a spend limit on the Anthropic key on day one.** A runaway loop costs $4 with a cap
and $400 without one.

Model IDs used in the prompts: `claude-opus-5` (judgment — briefs, QA, niche scout),
`claude-sonnet-5` (volume — drafting, video scripts). Pin them explicitly in nodes; don't
rely on a default.

---

## 4. Site + redirector

```bash
npx create-next-app@latest site --ts --app --tailwind --eslint
cd site
npm i @supabase/supabase-js
mkdir -p app/go/\[slug\]
cp ../scripts/redirect-edge-function.ts app/go/\[slug\]/route.ts
```

Deploy:
```bash
npm i -g vercel
vercel login
vercel link
vercel env add SUPABASE_URL production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel --prod
```

**Verify the redirector before writing a single article** — this is the build-order rule
from [doc 03](03-architecture.md):

```sql
-- in Supabase SQL editor: create a test offer + link
insert into programs (merchant, status) values ('TEST', 'approved');
insert into offers (program_id, name, destination_url)
  select id, 'test offer', 'https://example.com/' from programs where merchant='TEST';
insert into links (slug, offer_id)
  select 'test', id from offers where name='test offer';
```

Then hit `https://yourdomain.com/go/test?c=manual`. You should land on example.com with a
`subid` parameter, and:

```sql
select * from click_events order by occurred_at desc limit 1;   -- expect one row
```

**If that row isn't there, stop and fix it.** Every downstream decision depends on this
one query working.

---

## 5. Power BI

*Windows only. The Npgsql install needs admin rights — this is the main reason for the machine move.*

1. Install **Power BI Desktop** (Microsoft Store or MSI)
2. Install the **Npgsql** provider — [github.com/npgsql/npgsql/releases](https://github.com/npgsql/npgsql/releases)
   - Choose the **MSI**, and enable **"Npgsql GAC Installation"** during setup ← the step
     everyone misses; without it Power BI won't see the connector
   - Restart Power BI Desktop
3. **Get Data → PostgreSQL database**
   - Server: `<project>.pooler.supabase.com:6543`
   - Database: `postgres`
   - Credentials: from the pooler URI
   - **Import** mode (not DirectQuery — the daily refresh is plenty and Import is far faster)
4. Load `daily_metrics`, `content_items`, `offers`, `programs`, `channels`, `qa_scores`
5. Create a `dim_date` table and **mark it as a date table**
6. Paste the DAX from [doc 06](06-measurement.md#core-measures-dax)
7. Build the four pages from [doc 06](06-measurement.md#four-pages-no-more)

> Connection fails with "provider not found"? You skipped the GAC checkbox. Re-run the
> Npgsql MSI and tick it.

---

## 6. Verify the whole stack

| Check | Expected |
|---|---|
| `psql "$SUPABASE_DB_URL" -c "\dt"` | 24 tables |
| http://localhost:5678 | n8n loads, credentials saved |
| `https://yourdomain.com/go/test` | redirects, and a `click_events` row appears |
| Power BI refresh | completes without error |
| n8n test workflow with a deliberate bad API key | error workflow fires and alerts you |

That last one is the check everybody skips and everybody regrets.

---

## 7. Then

→ [`docs/13-w01-niche-scout-build.md`](13-w01-niche-scout-build.md) — build W01 and settle
the niche question with real data.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| n8n: "too many connections" | Using the direct DB URI | Switch to the pooler (6543) |
| n8n credentials gone after restart | `N8N_ENCRYPTION_KEY` not persisted | Set it explicitly; re-enter credentials |
| Power BI can't see PostgreSQL | Npgsql GAC option not ticked | Re-run the MSI with it enabled |
| Redirect works, no `click_events` row | Service role key missing/wrong in Vercel | Check `vercel env ls`, redeploy |
| Redirect works, still no `click_events` row | The insert isn't being awaited. supabase-js builders are lazy — `void supabase.from(...).insert(...)` sends no request at all | Await it, or hand it to `waitUntil` as `scripts/redirect-edge-function.ts` does |
| `visits` empty in Power BI, clicks fine | Analytics ingestion (W13 step 1) not built — clicks are yours, visits come from GA4/Plausible | Build the `page_view_daily` upsert; without it Affiliate CTR and RPM can't be computed |
| Cron jobs don't fire overnight | Machine sleeping | Move n8n to the VPS |
| Anthropic 401 in n8n | Key pasted with trailing whitespace | Re-paste into the credential store |
