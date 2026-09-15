# 03 — Architecture

## Principle: one spine, many arms

Every workflow reads and writes the same Postgres database. No workflow talks directly to
another. This means you can swap any component (change orchestrator, change the AI model,
change the site framework) without rewriting the system.

```
                         ┌───────────────────────────────┐
                         │      SUPABASE (Postgres)      │
                         │  the single source of truth   │
                         │                               │
  ┌───────────┐          │  niches   offers   keywords   │         ┌──────────────┐
  │ Orchestr. │◀────────▶│  content  assets   links      │◀───────▶│  Power BI    │
  │  (n8n)    │          │  clicks   conversions  costs  │         │  dashboard   │
  └─────┬─────┘          │  approvals  qa_scores         │         └──────────────┘
        │                └───────────────────────────────┘
        │
        ├──▶ Claude API ..................... briefs, drafts, QA, scripts, email
        ├──▶ SERP / keyword API ............. DataForSEO or similar
        ├──▶ Affiliate network APIs ......... conversions in
        ├──▶ Higgsfield / video gen ......... shorts
        ├──▶ Canva / image gen .............. featured images, thumbnails
        ├──▶ Email platform ................. Beehiiv / ConvertKit
        ├──▶ Social schedulers .............. TikTok, YouTube, LinkedIn, X
        └──▶ Vercel (Next.js) ............... the money site + /go redirector
```

---

## Component choices

| Layer | Recommended | Why | Alternative |
|---|---|---|---|
| **Database** | Supabase | Postgres + auth + REST/RPC out of the box; free tier is enough to start; Power BI connects to it natively | Airtable (easier, hits limits ~50k rows) |
| **Orchestrator** | n8n (self-hosted, ~$7/mo VPS) | Native AI nodes, loops, error handling, no per-run cost, exportable JSON | **Power Automate** — use if this must live in M365 |
| **Site** | Next.js on Vercel | Free tier, instant deploys, static generation for programmatic pages, edge redirects for link tracking | Astro, WordPress+plugins |
| **AI** | Claude (`claude-opus-5` for briefs/QA, `claude-sonnet-5` for volume drafting) | Long-context briefs, strong instruction-following for structured output | — |
| **Video** | Higgsfield / similar | Script→video→captions in one call | CapCut templates + TTS |
| **Email** | Beehiiv or ConvertKit | Free to ~1–2.5k subs, API for automated issues | — |
| **Reporting** | Power BI | You already own the skill; direct Postgres connector | Metabase (free, self-host) |

### n8n vs Power Automate — pick one

**Choose n8n if:** you want the lowest running cost, AI-native nodes, easy loops over
100s of records, and full portability. This is the recommendation.

**Choose Power Automate if:** approvals must land in Teams/Outlook with native approval
cards, the business must live in M365, or you want to reuse your existing connector
knowledge. Fully viable — the workflow specs in [doc 04](04-workflows.md) are written
tool-agnostic. Watch out for: per-flow run limits, awkward looping over large arrays, and
premium connector costs for HTTP/Postgres actions.

> A pragmatic hybrid: **n8n for the content/data pipeline, Power Automate for the approval
> and reporting layer** (where Teams/Outlook cards genuinely are the best UX).

---

## The link redirector (build this early)

Every affiliate link on every channel points at **your** domain, never the merchant:

```
yoursite.com/go/{slug}  ──▶  edge function  ──▶  302 to merchant URL + subid
                                   │
                                   └──▶ writes click_events row
                                        (slug, ts, referrer, channel, geo, ua_hash)
```

Why this is non-negotiable:

1. **Attribution.** The `subid` you pass to the merchant comes back on the conversion
   report, so you can tie a sale to the exact article, video, or email that caused it.
   Without this, you are flying blind and no amount of AI helps you.
2. **Swap-ability.** Merchant changes URL, or you move to a better offer? Update one DB
   row; every link everywhere updates instantly.
3. **Survivability.** A dead program doesn't leave 400 broken links across the internet.
4. **Channel measurement.** `?c=tiktok` / `?c=email` tells you where the money is.

See [`scripts/redirect-edge-function.ts`](../scripts/redirect-edge-function.ts).

---

## Data flow, end to end

1. **W01/W02** populate `niches`, `programs`, `offers`.
2. **W03** populates `keywords` with volume, CPC, difficulty, intent classification.
3. **W04** scores keywords into a ranked queue → **Gate B** (batch approve topics).
4. **W05/W06** generate `content_items` (brief → draft) with `qa_scores`.
5. **W07** → **Gate C** (approve drafts) → publish → `publications` rows.
6. **W08/W09** repurpose into video + social + email → more `publications`.
7. **W10** ingests `click_events`; **W12** ingests `conversions` from networks.
8. **W13** joins everything into `daily_metrics` → Power BI.
9. **W14** reads `daily_metrics`, produces the weekly kill/scale recommendation → **Gate E**.
10. The kill/scale decision rewrites the scoring weights in W04. **The loop closes.**

---

## Build order (do not deviate)

Most people build the content machine first and the tracking last. That's backwards —
you end up with 200 pages and no idea which one made money.

```
1. Database schema ...................... day 1     (db/schema.sql)
2. Link redirector + click tracking ..... day 1-2   ← before any content exists
3. Power BI dashboard skeleton .......... day 2     ← so you can see day-1 data
4. Niche + offer selection (W01, W02) ... day 3-4
5. Site shell + lead magnet + email ...... day 5-7
6. Keyword engine (W03, W04) ............ week 2
7. Content pipeline (W05-W07) ........... week 2
8. Distribution (W08, W09) .............. week 3
9. Conversion ingestion (W12) ........... week 3   ← as soon as a program approves you
10. Feedback loop (W13, W14) ............ week 4
```

Rule: **measurement infrastructure ships before the thing it measures.**

---

## Security & hygiene

- All API keys in the orchestrator's credential store or env vars — never in workflow JSON
  or prompt text. Nothing secret gets committed to this repo.
- Supabase RLS on: the public site uses the anon key with read-only policies on published
  content only. Writes go through the service role, used only by the orchestrator.
- Separate the tracking domain from the money site if you can — a redirector on the same
  domain is fine, but keep the click-logging endpoint rate-limited.
- Back up the Postgres database nightly to object storage. The database *is* the business;
  the site is a rendering of it.
- Version the prompts in [`prompts/`](../prompts/) in git. When output quality changes,
  you need to know what changed.
