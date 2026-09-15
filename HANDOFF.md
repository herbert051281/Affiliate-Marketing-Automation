# Handoff — state of play

**Last updated:** 15 Sep 2026 · **Branch:** `claude/affiliate-automation-strategy-ix729u`
(this is the repo's default branch — the repo was empty before this work, so there's no PR)

Read this first on a new machine. Then [`docs/12-setup-runbook.md`](docs/12-setup-runbook.md).

---

## What this is

A blueprint + build kit for an affiliate business designed to run with owner
review/approval only. **Nothing is deployed yet.** The repo currently contains planning
docs, a database schema, prompts, and one script.

---

## Decisions locked

| Decision | Choice | Where |
|---|---|---|
| Business model | Recurring-commission SaaS + newsletter core; video for traffic; programmatic comparison pages as the moat | [doc 01](docs/01-strategy-and-model.md) |
| Orchestrator | **n8n** (self-hosted) | [workflows/README.md](workflows/README.md) |
| Database | Supabase (Postgres) | [doc 03](docs/03-architecture.md) |
| Site | Next.js on Vercel | [doc 03](docs/03-architecture.md) |
| Reporting | Power BI direct to Postgres | [doc 06](docs/06-measurement.md) |
| Niche (provisional) | **MSP / IT operations tooling** — score 78 | [doc 10](docs/10-niche-shortlist.md) |
| Anchor offer (provisional) | Atera — 20% recurring, 60-day cookie | [doc 10](docs/10-niche-shortlist.md) |

## Decisions still open

| Open question | How it gets answered | Blocks |
|---|---|---|
| **Is the MSP niche real?** Monetization is verified; search volume and SERP competition are *estimates* | Run W01 with real DataForSEO data. **Tripwire: under 2,000 monthly buyer-intent searches → switch to field service software** | Everything |
| Domain name + brand | Your call, after the niche is confirmed | Site build |
| Brand voice | Fill in [`prompts/00-brand-voice.md`](prompts/00-brand-voice.md) — budget an hour, it's the highest-leverage hour in the build | All content generation |
| Real commission terms | Ask affiliate managers ([doc 11](docs/11-program-application-pack.md)) | Offer scoring |

---

## Do these in order on the new machine

1. **[`docs/12-setup-runbook.md`](docs/12-setup-runbook.md)** — Supabase project, run
   `db/schema.sql`, n8n via Docker, Vercel CLI, Power BI connector. This is the part that
   needed admin rights.
2. **Send the affiliate manager intro emails** ([doc 11](docs/11-program-application-pack.md)).
   Not an application, can't be rejected, and their EPC answer may change the niche call.
   10 minutes, do it today.
3. **Build W01** — [`docs/13-w01-niche-scout-build.md`](docs/13-w01-niche-scout-build.md)
   has the node-by-node spec. Settles the open niche question.
4. **Fill in the brand voice file.**
5. **Capture your first 3 evidence records** before briefing any money page — a price
   capture, a timed setup, a real screenshot. The content pipeline is gated on these, so
   an empty `evidence_records` table means nothing publishes.
6. Then follow [doc 09](docs/09-90-day-plan.md) week 1.

---

## Two corrections already made — don't re-introduce them

- **Don't apply to affiliate programs before the site has content.** The plan originally
  said week 1; it's now week 3. Every B2B program reviews your site manually, and
  re-applying after a rejection is much harder than a clean first application.
- **Short-form video doesn't fit the MSP niche.** If you go with MSP, W09's distribution
  mix becomes YouTube + LinkedIn + newsletter, not TikTok/Reels. And never post affiliate
  links to r/msp or r/sysadmin — mine them for research language only.
- **Content targets are 40–60 pages in 90 days, not 250.** Verified Sept 2026: Google ran
  three spam updates this year, and the August one named programmatic content, unreviewed
  AI content and thin affiliate pages directly. Publishing 250 pages into a niche with
  ~2,000 monthly searches is structurally scaled-content abuse. Break-even is ~1 sale a
  month, so the volume was never needed. See [doc 07](docs/07-compliance-and-risk.md).
- **Original value is a database row, not a prompt instruction.** A page cannot publish
  without citing a verified `evidence_records` entry — enforced by trigger, because an AI
  reviewer cannot tell a real benchmark from a convincing sentence about one.

---

## Blocked on you

| Item | Why | Fix |
|---|---|---|
| Gmail response monitoring | Connector lacks read scope | claude.ai → Settings → Connectors → Gmail → reconnect with read access |
| Affiliate applications | Require your legal identity, tax forms, and TOS acceptance | You submit; [doc 11](docs/11-program-application-pack.md) has the draft answers |

---

## Repo map

```
README.md          navigation + the one-page picture
HANDOFF.md         you are here
CLAUDE.md          context for a new Claude session
docs/01-13         strategy → setup runbook (see README table)
db/schema.sql      25 tables + daily_metrics view — run this first
db/test-schema.sh  schema regression tests (local Postgres, no network)
prompts/           versioned AI prompts (00-brand-voice.md needs filling in)
scripts/           tracked-redirect edge function
workflows/         n8n notes; exported workflow JSON goes here
.env.example       every credential the system needs
```

---

## Money check

Running cost is **~$90–150/mo**. Break-even at Atera's terms is roughly **one sale a
month**, not nine — that's the whole argument for the recurring-commission niche. Full
math in [doc 08](docs/08-costs-and-unit-economics.md), including the go/no-go criteria to
apply at month 4.
