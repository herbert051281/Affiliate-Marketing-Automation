-- ============================================================================
-- Affiliate Marketing Automation — core schema (PostgreSQL / Supabase)
-- Run once in the Supabase SQL editor.
-- ============================================================================

create extension if not exists "pgcrypto";

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
create index on click_events (click_id);
create index on click_events (content_item_id, occurred_at);

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
  version     integer not null,
  weights     jsonb not null,                      -- {intent:{comparison:1.4, informational:0.6}, cluster:{...}}
  reason      text,
  active      boolean default false,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 14. Workflow run log (W00 Watchdog reads this)
-- ---------------------------------------------------------------------------
create table workflow_runs (
  id           uuid primary key default gen_random_uuid(),
  workflow     text not null,                      -- 'W04'
  status       text not null check (status in ('running','success','failed')),
  items_in     integer,
  items_out    integer,
  error        text,
  started_at   timestamptz not null default now(),
  finished_at  timestamptz
);
create index on workflow_runs (workflow, started_at desc);

-- ============================================================================
-- Reporting rollup — Power BI's fact table
-- Grain: date × content_item × channel × offer
-- W13 refreshes this nightly (materialize it once volume grows).
-- ============================================================================
create or replace view daily_metrics as
with clicks as (
  select date_trunc('day', ce.occurred_at)::date as d,
         ce.content_item_id,
         ce.channel_code,
         l.offer_id,
         count(*) filter (where not ce.is_bot) as aff_clicks
  from click_events ce
  left join links l on l.id = ce.link_id
  group by 1,2,3,4
),
sales as (
  select date_trunc('day', c.occurred_at)::date as d,
         c.content_item_id,
         c.channel_code,
         c.offer_id,
         count(*) filter (where c.status in ('approved','paid'))            as conversions,
         coalesce(sum(c.amount) filter (where c.status in ('approved','paid')), 0) as revenue,
         coalesce(sum(c.amount) filter (where c.status = 'reversed'), 0)     as reversals
  from conversions c
  group by 1,2,3,4
),
spend as (
  select incurred_on as d, content_item_id, sum(amount) as cost
  from costs group by 1,2
)
select
  coalesce(cl.d, s.d, sp.d)                              as date,
  coalesce(cl.content_item_id, s.content_item_id, sp.content_item_id) as content_item_id,
  coalesce(cl.channel_code, s.channel_code)              as channel_code,
  coalesce(cl.offer_id, s.offer_id)                      as offer_id,
  coalesce(cl.aff_clicks, 0)                             as aff_clicks,
  coalesce(s.conversions, 0)                             as conversions,
  coalesce(s.revenue, 0)                                 as revenue,
  coalesce(s.reversals, 0)                               as reversals,
  coalesce(s.revenue, 0) - coalesce(s.reversals, 0)      as net_revenue,
  coalesce(sp.cost, 0)                                   as cost,
  coalesce(s.revenue, 0) - coalesce(s.reversals, 0) - coalesce(sp.cost, 0) as profit
from clicks cl
full outer join sales s
  on s.d = cl.d and s.content_item_id is not distinct from cl.content_item_id
 and s.channel_code is not distinct from cl.channel_code
 and s.offer_id is not distinct from cl.offer_id
full outer join spend sp
  on sp.d = coalesce(cl.d, s.d)
 and sp.content_item_id is not distinct from coalesce(cl.content_item_id, s.content_item_id);

-- ============================================================================
-- Seed: channels
-- ============================================================================
insert into channels (code, name) values
  ('site','Website'), ('tiktok','TikTok'), ('reels','Instagram Reels'),
  ('shorts','YouTube Shorts'), ('linkedin','LinkedIn'), ('x','X'),
  ('email','Newsletter'), ('reddit','Reddit')
on conflict (code) do nothing;

-- ============================================================================
-- Row Level Security
-- The public site reads published content with the anon key.
-- Everything else is service-role only (the orchestrator).
-- ============================================================================
alter table content_items enable row level security;
alter table links         enable row level security;
alter table offers        enable row level security;

create policy "public reads published content"
  on content_items for select using (status = 'published');

create policy "public reads active links"
  on links for select using (active = true);

create policy "public reads active offers"
  on offers for select using (active = true);

-- NOTE: every other table stays RLS-off but is unreachable with the anon key
-- provided you never expose it. Enable RLS on them too before any client-side
-- access is added.
