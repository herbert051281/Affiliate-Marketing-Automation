# 06 — Measurement, Attribution & the Dashboard

If you can't attribute a sale to a specific piece of content on a specific channel, you
can't run the kill/scale loop, and the whole system degrades into a content mill.

---

## The attribution chain

```
video/article/email
      │  link: yoursite.com/go/{slug}?c={channel}&s={content_id}
      ▼
 edge redirector ──▶ writes click_events {slug, channel, content_id, ts, ref, geo}
      │
      │  302 to: merchant.com/?ref=you&subid={click_id}
      ▼
 merchant converts ──▶ network report returns subid
      │
      ▼
 W12 ingestion ──▶ conversions row, joined back to the exact click
```

**The `subid` is everything.** Every network supports one (called `subid`, `sub1`, `u1`,
`clickref`, `aff_sub` depending on the network). Pass your internal `click_id`. Without
it you know you made $400 last month and nothing else.

### What to track at each stage

| Stage | Metric | Healthy range (content) |
|---|---|---|
| Reach | impressions, visits | — |
| Engagement | scroll depth, time on page | >60s for money pages |
| **Affiliate CTR** | aff_clicks / visits | **4–12%** — below 3% means bad link placement |
| **Conversion rate** | sales / aff_clicks | **1–4%** for SaaS trials; below 1% = wrong offer or wrong traffic |
| **Reversal rate** | reversed / total sales | <15%; above 25% means the merchant or your traffic is a problem |
| **EPC** | net revenue / 100 aff clicks | Compare against the network's published EPC — if yours is half, your traffic intent is off |
| **RPM** | net revenue / 1000 visits | Your single best cross-content comparator |

> Diagnose with the funnel, not the total. Low revenue has three different causes and
> three different fixes: not enough visits (distribution problem), low affiliate CTR
> (content/placement problem), or low conversion (offer/intent problem). The dashboard's
> job is to tell you which one.

---

## Power BI model

Connect directly to Supabase Postgres (Npgsql connector, or the Supabase REST API).
Refresh daily after W13 completes (~06:30).

### Star schema

```
                     ┌──────────────┐
                     │  dim_date    │
                     └──────┬───────┘
  ┌────────────┐            │            ┌─────────────┐
  │dim_content ├────────────┼────────────┤  dim_offer  │
  └────────────┘            │            └─────────────┘
                     ┌──────┴─────────┐
                     │  fact_metrics  │  (grain: date × content × channel × offer)
                     │  visits        │
                     │  aff_clicks    │   ┌──────────────┐
                     │  conversions   ├───┤ dim_channel  │
                     │  gross_revenue │   └──────────────┘
                     │  reversals     │
                     │  pending_revenue│
                     │  cost          │
                     └────────────────┘
```

Build `dim_date` as a proper marked date table. Everything else follows normal star rules.

**Where `visits` comes from.** Clicks are yours (the redirector writes them); visits
are not — they come from the site analytics provider (GA4, Plausible or Vercel
Analytics) and land in `page_view_daily`, ingested by W13. Without that ingestion
`visits` is zero and **Affiliate CTR and RPM — the two measures this whole document
is built on — are undefined.** Wire it up in week 1, alongside the redirector.

A pageview cannot be attributed to a single offer, so visits attach to the
(date × content × channel) grain with a null offer. Totals are correct when summed;
slicing *by offer* correctly shows no visits. Read Affiliate CTR at content or
channel level, never per offer.

### Core measures (DAX)

> **Revenue column semantics** (see the header comment on `daily_metrics`):
> `gross_revenue` includes commissions that were later reversed, `reversals` is
> that reversed portion, so `net_revenue = gross_revenue - reversals` is what you
> keep. Subtracting reversals from an approved-only figure would deduct them
> twice and understate net revenue by exactly the reversed amount.
> `pending_revenue` is reported separately and never counted as earned — under
> net-30/60 terms a real sale sits pending for weeks, and treating it as revenue
> is how people talk themselves into scaling a losing offer.

```dax
Net Revenue = SUM(fact_metrics[gross_revenue]) - SUM(fact_metrics[reversals])

Profit = [Net Revenue] - SUM(fact_metrics[cost])

Pending Revenue = SUM(fact_metrics[pending_revenue])   -- booked, not yet earned

Affiliate CTR = DIVIDE(SUM(fact_metrics[aff_clicks]), SUM(fact_metrics[visits]))

Conversion Rate = DIVIDE(SUM(fact_metrics[conversions]), SUM(fact_metrics[aff_clicks]))

EPC = DIVIDE([Net Revenue], SUM(fact_metrics[aff_clicks])) * 100

RPM = DIVIDE([Net Revenue], SUM(fact_metrics[visits])) * 1000

Reversal Rate = DIVIDE(SUM(fact_metrics[reversals]), SUM(fact_metrics[gross_revenue]))

-- Content maturity matters: a 2-week-old page hasn't had its chance yet
Days Since Publish =
    DATEDIFF(MAX(dim_content[published_at]), MAX(dim_date[date]), DAY)

-- Kill candidates: mature, no traffic, no money
Kill Candidates =
CALCULATE(
    DISTINCTCOUNT(fact_metrics[content_id]),
    FILTER(
        SUMMARIZE(fact_metrics, fact_metrics[content_id],
                  "v", SUM(fact_metrics[visits]),
                  "r", [Net Revenue],
                  "age", [Days Since Publish]),
        [age] > 60 && [v] < 30 && [r] = 0
    )
)

-- Rolling trend, to separate "dying" from "just launched"
Net Revenue 28D = CALCULATE([Net Revenue], DATESINPERIOD(dim_date[date], MAX(dim_date[date]), -28, DAY))
Net Revenue Prior 28D = CALCULATE([Net Revenue], DATESINPERIOD(dim_date[date], MAX(dim_date[date]) - 28, -28, DAY))
Revenue Trend % = DIVIDE([Net Revenue 28D] - [Net Revenue Prior 28D], [Net Revenue Prior 28D])
```

### Four pages, no more

1. **Executive** — profit, net revenue, trend, runway to break-even, sales this month vs
   last, one big "are we winning" number.
2. **Content performance** — matrix: content × RPM, affiliate CTR, conversion rate, age.
   Conditional formatting. This is where kill/scale decisions get made.
3. **Channel & offer** — which channel produces profitable clicks (not just clicks), which
   offer converts, EPC per offer vs network benchmark.
4. **Pipeline health** — content in each status, workflow failures, QA pass rate, QA-vs-human
   agreement rate (your autonomy unlock metric), API spend vs budget.

### Alerts (Power BI or the Watchdog workflow)

- Profit negative for 7 consecutive days
- Any single offer > 60% of revenue (concentration risk)
- QA-vs-human agreement < 90% (autonomy rollback trigger)
- Reversal rate > 25% for any offer
- Zero conversions in 72h after a period with conversions

---

## Reconciliation: trust but verify

Once a month, compare your dashboard's revenue to the **actual network payout statements**.
They will disagree. Reasons, in order of likelihood:

1. Reversals posted after your last ingest
2. Cross-device conversions the merchant attributed but your click didn't capture
3. Currency conversion and network fees
4. Cookie-window expiry differences

Tolerance: ±10% is normal. Above that, your ingestion has a bug and every downstream
decision is wrong. Make this a calendar item, not a good intention.
