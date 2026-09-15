# 08 — Costs & Unit Economics

Numbers, not vibes. This is what decides whether the machine is worth running.

---

## Monthly running costs

### Lean start (months 1–3)

| Item | Cost |
|---|---|
| Domain | $1 |
| Vercel (hobby) | $0 |
| Supabase (free tier) | $0 |
| n8n on a small VPS | $6 |
| Claude API (~50 pieces/mo + QA) | $40–80 |
| Keyword/SERP data (pay-per-use) | $15–25 |
| Video generation (~90 shorts/mo) | $25–40 |
| Email platform (free tier to ~1–2.5k subs) | $0 |
| Social scheduling (free tiers / API) | $0 |
| **Total** | **≈ $90–150 / mo** |

### Scaled (month 6+, if profitable)

| Item | Cost |
|---|---|
| Everything above, upgraded tiers | $120 |
| Supabase Pro | $25 |
| Email platform (5–10k subs) | $50–100 |
| Claude API (higher volume) | $150 |
| Paid test budget | $300–500 |
| **Total** | **≈ $650–900 / mo** |

Don't scale costs until the lean version is profitable. The whole point of this
architecture is that the lean version can run for a year on the price of two dinners.

---

## Cost per content unit

| Unit | Cost | Notes |
|---|---|---|
| Keyword research (per 100 keywords) | ~$0.30 | Batched API calls |
| Brief | ~$0.15 | Includes SERP scraping |
| Draft (2,000 words) | ~$0.40 | Sonnet-class for volume |
| QA pass | ~$0.20 | Separate model call, worth every cent |
| Featured image | ~$0.05 | |
| **Article, all-in** | **≈ $0.80–1.20** | vs. $80–300 for a freelance writer |
| Short-form video | ~$0.30–0.50 | |
| Newsletter issue | ~$0.25 | |

At ~$1/article, you can afford to publish 100 pieces and have 90 of them fail. That's the
real unlock: **the cost of being wrong collapses**, so the scoring loop in W04 can
experiment instead of agonize.

---

## Break-even math

Fixed cost to beat: **$150/month.**

```
Required sales = Monthly cost ÷ (Commission per sale × (1 − reversal rate))
```

**Scenario A — recurring SaaS, $20/mo commission, 15% reversal:**
```
Effective per sale (month 1) = $20 × 0.85 = $17
Break-even = $150 ÷ $17 ≈ 9 new sales/month
```
But it's recurring — by month 4 you're also collecting on months 1–3's sales:

| Month | New sales | Accumulated (8% churn) | MRR |
|---|---|---|---|
| 1 | 9 | 9 | $153 |
| 2 | 12 | 20 | $340 |
| 3 | 15 | 33 | $561 |
| 6 | 25 | 79 | $1,343 |
| 12 | 40 | 209 | $3,553 |

**That's the compounding.** The same effort in a one-time-commission niche plateaus at
month 1's number forever.

### What traffic does 9 sales/month require?

```
9 sales ÷ 2.5% conversion rate        = 360 affiliate clicks
360 clicks ÷ 8% affiliate CTR         = 4,500 visits/month  = ~150 visits/day
```

150 visits/day is achievable from:
- 90 short-form videos/month at a modest 2% click-through on 5k avg views, **or**
- 40 published pages averaging 4 visits/day from search (month 4+), **or**
- 1,500 email subscribers at one weekly send, **or**
- realistically: a mix of all three, which is why the system runs all three.

**Sanity check that number before you build.** If your chosen niche can't plausibly
produce 150 targeted visits/day within 6 months, the niche is wrong, not the machine.

---

## Sensitivity — what to fix first

Starting point: 4,500 visits, 8% CTR, 2.5% CVR, $20 commission → $180/mo.

| Change | New monthly revenue | Lift |
|---|---|---|
| Visits 4,500 → 6,000 (+33%) | $240 | +33% |
| Affiliate CTR 8% → 11% | $248 | +38% |
| Conversion 2.5% → 3.5% | $252 | +40% |
| Commission $20 → $35 (better offer) | $315 | **+75%** |
| Reversal 15% → 8% | $195 | +8% |

**Ranked by effort-to-impact:**

1. **Pick a better offer.** Highest lift, lowest effort, one-time decision. This is why
   doc 02 spends so much time on offer scoring.
2. **Fix affiliate CTR.** Link placement, comparison tables above the fold, contextual CTAs.
   Cheap to test, immediate.
3. **Fix conversion.** Usually a traffic-intent mismatch — target `best/vs/pricing`
   keywords instead of informational ones.
4. **More traffic.** The most work for the least leverage. Do it last.

Most people do this list backwards — they grind for traffic on a bad offer. The dashboard
in [doc 06](06-measurement.md) exists to keep you honest about which lever you're pulling.

---

## Time investment

| Phase | Your time |
|---|---|
| Build (weeks 1–4) | 8–15 hrs/week |
| Operate (month 2+) | **15 min/day + 30 min Monday** ≈ 2.5 hrs/week |
| Quarterly review | 3 hrs |

The build is real work. The operation is not. That ratio is the entire proposition.

---

## Go / no-go criteria

Kill or pivot the whole project if, at **month 4**:

- Fewer than 500 visits/month total, **or**
- Affiliate CTR below 3% after two placement iterations, **or**
- Zero conversions despite >500 affiliate clicks, **or**
- Reversal rate above 40%

Any of these means the niche or offer is wrong. Re-run W01 with what you learned and
redeploy the *same machine* at a new niche — that takes a week, not a quarter. The system
is the asset; the niche is a configuration value.
