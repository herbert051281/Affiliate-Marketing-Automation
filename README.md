# Affiliate Marketing Automation — Zero to Hero

A blueprint + build kit for an affiliate business that runs itself, where the owner's
only recurring job is **reviewing and approving** from a daily digest.

> **Design principle:** automate *selection and measurement* first, *production* second.
> Most people automate writing and end up with 500 pages nobody reads. The edge is an
> automated loop that decides **what to make, what to kill, and what to scale.**

---

## The one-page picture

```
                        ┌──────────────────────────────────┐
                        │  DAILY DIGEST (your only job)    │
                        │  Approve / Reject / Edit — 1 click│
                        └───────────────▲──────────────────┘
                                        │
  ┌─────────┐   ┌──────────┐   ┌────────┴────────┐   ┌──────────┐   ┌──────────┐
  │ INTAKE  │──▶│ DECIDE   │──▶│    PRODUCE      │──▶│ DISTRIBUTE│──▶│ MEASURE  │
  │ offers  │   │ score &  │   │ brief→draft→QA  │   │ site, video│   │ clicks,  │
  │ keywords│   │ rank by  │   │ →images→schema  │   │ email,social│  │ sales,   │
  │ trends  │   │ expected │   │                 │   │            │   │ profit   │
  │ competitors│ │ value   │   │                 │   │            │   │          │
  └─────────┘   └──────────┘   └─────────────────┘   └──────────┘   └────┬─────┘
       ▲                                                                  │
       └──────────────── FEEDBACK LOOP: kill / scale / re-target ─────────┘
```

Everything writes to **one database** (Supabase/Postgres). Every layer reads from it.
That single spine is what makes the whole thing measurable and automatable.

---

## Read in this order

| # | Doc | What you get |
|---|-----|--------------|
| 1 | [Strategy & business model](docs/01-strategy-and-model.md) | Which affiliate model to run and why; what "profitable fast" realistically means |
| 2 | [Niche & offer selection](docs/02-niche-and-offer-selection.md) | An automated scoring system that picks the niche for you |
| 3 | [Architecture](docs/03-architecture.md) | The stack, the data spine, build order |
| 4 | [Workflows](docs/04-workflows.md) | All 14 automations, spec'd: trigger → steps → output → gate |
| 5 | [Approval & graduated autonomy](docs/05-approval-and-autonomy.md) | How you get to "review only" without torching the brand |
| 6 | [Measurement](docs/06-measurement.md) | Tracking, attribution, the Power BI model, alerts |
| 7 | [Compliance & risk](docs/07-compliance-and-risk.md) | The things that actually kill affiliate businesses |
| 8 | [Costs & unit economics](docs/08-costs-and-unit-economics.md) | What it costs, what break-even requires, in numbers |
| 9 | [90-day plan](docs/09-90-day-plan.md) | Week by week, with a "done" definition for each |
| 10 | [Niche shortlist](docs/10-niche-shortlist.md) | 10 researched candidates, scored — with verified program terms |
| 11 | [Program application pack](docs/11-program-application-pack.md) | Draft application answers, manager outreach email, response triage |

**Build kit:** [`db/schema.sql`](db/schema.sql) · [`prompts/`](prompts/) · [`workflows/`](workflows/README.md)

---

## The short version

**Model:** One narrow niche. Recurring-commission software/tools offers as the money
engine. A newsletter as the owned asset. Short-form video as the traffic engine.
Programmatic comparison pages as the long-term SEO/AI-citation moat.

**Why that combo:** recurring commissions compound (one sale pays for 12–24 months),
email is the only channel no algorithm can take from you, short video is the cheapest
traffic on earth right now, and comparison pages are what both Google and AI assistants
cite when someone is ready to buy.

**Automation target:** ~85% hands-off. You approve roughly **15 minutes a day** —
a batch of topics, a batch of drafts flagged by QA, and any spend change.

**Honest timeline:**

| Milestone | Realistic timing |
|-----------|------------------|
| Infrastructure live, tracking working | Week 1–2 |
| First affiliate clicks | Week 2–3 |
| First commission | Week 3–6 (from video/email, not SEO) |
| Break-even on tooling (~$150/mo) | Month 2–3 |
| SEO traffic becomes meaningful | Month 4–9 |
| $2–5k/mo | Month 6–12, if the loop is actually run |

Anyone promising faster is selling you something. The automation doesn't make it
faster than the market allows — it makes it **cheap enough to survive until it works**,
and removes the 30 hours/week that normally kills these projects.

---

## Two things to decide before building

1. **Orchestrator:** ✅ **n8n** — decided. See [workflows/README.md](workflows/README.md)
   for setup notes and gotchas.
2. **Niche:** shortlist researched — see [doc 10](docs/10-niche-shortlist.md). Leading
   candidate is **MSP / IT operations tooling**; verify with [W01](docs/04-workflows.md#w01--niche-scout)
   before committing.

---

## Status

This repository currently contains the **plan and build kit**. Nothing is deployed.
See [docs/09-90-day-plan.md](docs/09-90-day-plan.md) for the build order.
