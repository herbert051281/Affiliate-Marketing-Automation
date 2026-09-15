# 02 — Niche & Offer Selection (automated)

Don't pick a niche by vibes. Score it. This is the single highest-leverage automation in
the whole system, and it runs before you build anything else.

---

## The scoring model

For each candidate niche, the Niche Scout workflow ([W01](04-workflows.md#w01--niche-scout))
collects the data and computes:

```
NicheScore = (0.30 × MonetizationDepth)
           + (0.20 × BuyerIntentVolume)
           + (0.20 × CompetitionGap)
           + (0.15 × ContentDurability)
           + (0.15 × DistributionFit)
```

Each component is normalized 0–100.

| Component | How it's computed | Data source |
|---|---|---|
| **MonetizationDepth** | # of programs with ≥20% recurring or ≥$100 payout, × avg cookie days, × avg EPC | Affiliate networks (Impact, PartnerStack, ShareASale), merchant pages |
| **BuyerIntentVolume** | Monthly searches for `best/vs/alternatives/pricing/review` patterns × avg CPC | DataForSEO / Keywords Everywhere API |
| **CompetitionGap** | % of top-10 SERP slots held by DR<40 sites or forums/Reddit (high = beatable) | SERP API |
| **ContentDurability** | Inverse of how often the top pages change; penalize fast-moving/news niches | SERP snapshots over 2 weeks |
| **DistributionFit** | Does the niche have short-form video demand? (hashtag view counts, existing creators) | TikTok/YouTube search |

### Hard disqualifiers — auto-reject regardless of score

- YMYL categories (health claims, medical, financial advice, legal) — regulatory exposure
  and a much higher content quality bar. Not a first business.
- Niches where the only programs are Amazon or sub-5% one-time commissions.
- Anything with an obvious brand-dominated SERP (top 10 all DR 80+ publishers).
- Gambling, adult, crypto trading, supplements, MLM. Payment processors and ad networks
  will cut you off, and program TOS are minefields.
- Seasonal-only niches (>70% of volume in one quarter).

### Bonus multipliers

- `× 1.15` if you have genuine domain knowledge → your original data is cheap to produce.
- `× 1.15` if merchants offer **lifetime/recurring** rather than 12-month recurring.
- `× 1.10` if the niche has an active Reddit/Discord/forum community (free distribution
  and a free research feed).

---

## Where to look (strong 2026 candidate patterns)

Generic advice says "find your passion." Better: find **professionals who expense
software**. They buy fast, they churn slowly, and their tools carry recurring commissions.

Strong structural patterns to feed the scout as candidates:

- Tools for a *specific job function* in a *specific industry*
  (e.g. "scheduling software for home-service contractors", "compliance tooling for
  small clinics", "inventory tools for Shopify sellers")
- "Solo operator" stacks — tools for freelancers, agencies of one, creators
- B2B verticals with a software boom but no good comparison content
- Adjacent to your own expertise: **IT ops / data / automation tooling** is a real
  candidate here — you'd have first-hand credibility, original benchmarks, and screenshots
  competitors can't fake. That's a `× 1.15` you can't buy.

> Pick **one**. Narrow beats broad every time: "best X for Y" outranks "best X".

---

## Offer selection — scoring individual programs

Once the niche is chosen, [W02](04-workflows.md#w02--offer-harvester) scores each program:

```
OfferScore = (RecurringValue × 0.35)
           + (EPC × 0.25)
           + (CookieDays_norm × 0.15)
           + (MerchantQuality × 0.15)
           + (TOSFreedom × 0.10)
```

- **RecurringValue** = commission% × merchant ARPU × expected retention months
- **EPC** = network-reported earnings per 100 clicks (ask the affiliate manager if not public)
- **MerchantQuality** = review scores, refund rate, trial→paid conversion, support quality.
  A merchant with a 30% refund rate silently halves your income.
- **TOSFreedom** = can you use email? paid ads? your own reviews? comparison tables?

### Store the TOS as structured data, not a PDF you'll never read

Every program's rules go into the `programs` table as booleans
(`allows_email`, `allows_paid_search`, `allows_brand_bidding`, `allows_coupon`,
`requires_disclosure_text`). Workflows then **enforce** them automatically — the email
workflow simply won't insert a link from a program with `allows_email = false`.

This single design choice prevents the #1 way automated affiliate businesses get
terminated: violating a rule nobody re-read after month one.

---

## The portfolio rule

- **1 anchor offer** (recurring, high EPC) — gets 50% of link placements
- **2–3 supporting offers** — different price points, different buyer stages
- **1 backup per offer** — pre-approved, so [W11 Link Health](04-workflows.md#w11--link-health--offer-swap)
  can auto-swap within an hour if a program pauses, cuts rates, or you get dropped

Never let one merchant exceed 60% of revenue. Programs get shut down without warning;
this is your circuit breaker.

---

## Output of this phase

A one-page approval card in your digest:

```
NICHE RECOMMENDATION                                    Score: 78 / 100
─────────────────────────────────────────────────────────────────────
Niche:        [candidate]
Why:          6 programs ≥20% recurring · 14,200 buyer-intent searches/mo
              avg CPC $8.40 · 40% of top-10 slots are DR<40 or Reddit
Anchor offer: [merchant] — 30% recurring, 90-day cookie, EPC $1.40
Risks:        [e.g. one merchant = 45% of available commission volume]
Runner-up:    [candidate 2] — Score 71
─────────────────────────────────────────────────────────────────────
                                    [ Approve ]  [ Use runner-up ]  [ Rescan ]
```

You click once. Everything downstream configures itself from that record.
