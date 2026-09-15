# 10 — Niche Shortlist (researched Sept 2026)

Ten candidates scored against the [doc 02](02-niche-and-offer-selection.md) model.

## Read this first — what is and isn't verified

| Component | Status |
|---|---|
| **Program terms** (commission %, recurring vs one-time, cookie) | ✅ **Verified** via web research, Sept 2026. Sources at the bottom. |
| **MonetizationDepth** score | ✅ Computed from verified terms |
| **CompetitionGap**, **BuyerIntentVolume**, **ContentDurability** | ⚠️ **Estimated from experience, not measured.** Real SERP and keyword-volume data needs the DataForSEO call in [W01](04-workflows.md#w01--niche-scout). |
| **DistributionFit** | ⚠️ Estimated |

**So treat this as the candidate list W01 should verify, not the final answer.** The
monetization half is solid; the competition half is a hypothesis. Rates also change without
notice — re-confirm on each program's own page before you apply.

---

## The scored table

Scores are computed from the components by the [doc 02](02-niche-and-offer-selection.md)
formula, then the expertise multiplier, then the `CompetitionGap < 30` disqualifier.

### Disqualified before scoring — SERP not enterable

Three candidates fail the competition gate. They are **not** low-scoring; on the weighted
formula two of them land in the high 60s, ahead of several candidates below. They are
simply unwinnable for a new site, which is why the gate runs first.

| # | Niche | Gap | Would have scored | Why it's out |
|---|---|---|---|---|
| 8 | Small-business payroll / HR | **22** | 60.0 | $200 flat, no recurring, and a SERP owned by incumbents |
| 9 | Course creator / LMS | **12** | 69.8 | Best economics on the list (monetization 92) — and you cannot rank |
| 10 | Email marketing / funnel tools | **8** | 68.9 | Monetization 94. GoHighLevel is the most-promoted offer alive |

> **The pattern in rows 8–10 is the whole lesson: the best-paying programs have the worst
> competition.** That's not coincidence, it's the market pricing itself. A weighted average
> would have ranked the LMS niche 4th — which is exactly why competition is a gate here and
> not a term you can trade away against commission rate.

### Ranked survivors

| Rank | # | Niche | Score | Monetization | Intent | Gap | Durability | Distribution | Notes |
|---|---|---|---|---|---|---|---|---|---|
| **1** | 1 | **MSP / IT operations tooling** | **84.2** | 74 | 62 | **88** | 85 | 55 | 73.2 × 1.15 expertise. Real recurring. Nobody serves this well |
| **2** | 3 | **Workflow automation / no-code** | **80.6** | 70 | 85 | 42 | 68 | **90** | 70.1 × 1.15 expertise. Best video fit; thinnest gap of the three |
| **3** | 2 | **Field service / contractor software** | **79.3** | 78 | 82 | 70 | 82 | **88** | Big payouts, great video fit, mostly one-time |
| 4 | 5 | Restaurant / hospitality software | 71.5 | 66 | 74 | 66 | 78 | 80 | Worth a real W01 pass |
| 5 | 4 | Vet / dental practice management | 69.6 | 72 | 58 | 85 | 84 | 45 | Under-researched, structurally attractive |
| 6 | 6 | Accounting / bookkeeping SaaS | 64.7 | 68 | 88 | **30** | 76 | 62 | Exactly on the gate. Forbes/NerdWallet own the SERP |
| 7 | 7 | Nonprofit software | 60.9 | 48 | 50 | 88 | 86 | 40 | Low competition, low budgets |

### Correction — the scores in the first version of this doc were wrong

The originally published scores did not reproduce from doc 02's own formula. Every one was
understated, rows 9 and 10 by more than 20 points, because the author was applying a
competition penalty far heavier than the stated 20% weight expresses. The judgement was
right; the arithmetic did not support it.

The fix is the gate above rather than new weights — doc 02 and
[the scout prompt](../prompts/01-niche-scout.md) already said "30%+ of weak top-10 slots =
beatable by a new site", so the rule existed and simply wasn't applied. Two consequences:

- **MSP still wins**, and by a wider margin than published (84.2, not 78). The
  recommendation below is unchanged.
- **The runner-up changes.** Workflow automation (80.6) now edges field service (79.3),
  because it carries the same ×1.15 expertise multiplier and this doc grants it. See the
  runner-up section for why that ordering is less settled than the numbers suggest.

---

## Recommendation: #1 — MSP / IT operations tooling · **84.2 / 100**

### Why this one for you specifically

You are an IT Program Success analyst. In this niche you can produce, cheaply and
credibly, exactly the original-value assets that [doc 07](07-compliance-and-risk.md)
says are mandatory:

- Real screenshots of RMM/PSA dashboards
- Genuine "we ran this for 6 months" observations
- Deployment-time benchmarks, integration gotchas, actual migration friction
- Power BI reporting layers on top of these tools — **content nobody else can write**,
  and a natural lead magnet

That's the `×1.15` expertise multiplier, and it's the only component of the score you
can't buy or fake.

### Verified economics

| Program | Terms | Notes |
|---|---|---|
| **Atera** | **20% recurring**, 60-day cookie | Priced per technician (~$149+/tech/mo). A 5-tech shop ≈ $745/mo → **~$149/mo recurring to you** |
| NinjaOne | Partner program, recurring revenue, rates undisclosed | Apply and ask — undisclosed usually means negotiable |
| Syncro, Hudu, Pulseway, ScreenConnect, Backup/EDR vendors | Various | Deep bench — the portfolio rule is satisfiable |

Atera alone at **one sale/month** clears your $150/mo running cost by month two.
That's the compounding argument from [doc 01](01-strategy-and-model.md) at its strongest:
few sales needed, each one large and recurring.

### Why the competition gap is real

MSP content is written *by* MSPs — vendor blogs, forum posts, and Reddit threads. There's
almost no professional comparison publishing. The buyer is highly informed, searches
narrowly, and has nowhere good to go. That's the textbook `CompetitionGap = 88`.

### The honest problems

1. **Low search volume.** You're trading volume for value. At $149/mo recurring per sale
   you need ~1 sale/month to break even, not 9 — but if W01 comes back showing under
   ~2,000 buyer-intent searches/month, reconsider.
2. **⚠️ Short-form video doesn't fit.** This is the real tension: the plan's traffic
   engine is TikTok/Reels, and IT buyers aren't there. **The distribution mix must change:**
   YouTube (long + Shorts), LinkedIn, and technical newsletters replace TikTok. W09 gets
   reconfigured, not deleted.
3. **⚠️ r/msp and r/sysadmin are hostile to affiliate content — and they should be.**
   Do not post promotional links there. Use them as a *research feed* (W03 mines them for
   real buyer language) and nothing else. Getting called out on r/msp would damage the
   brand permanently.
4. **Long sales cycles.** MSPs evaluate for months. The 60-day cookie helps; email
   nurture matters more here than anywhere else. Lean hard on the newsletter.
5. **Concentration risk.** If Atera is the only transparent recurring program, you're
   over-indexed on one merchant. Apply to 5+ and negotiate directly with the rest.

---

## Runner-up: the model and the judgement disagree — W01 settles it

On the corrected scores, **workflow automation (80.6) edges field service (79.3)**. That
ordering rests on a number this doc has flagged as an estimate from the start: workflow
automation's `Gap = 42` was assigned by feel, not measured. If the real figure is under 30
it is disqualified outright, and the two are not close.

So don't pick a runner-up from the table. The two candidates fail in opposite directions,
and W01 measures exactly the thing that separates them:

| | Workflow automation (80.6) | Field service (79.3) |
|---|---|---|
| Your credibility | **High** — it's your day job | None. Original value gets expensive |
| Commission shape | Recurring (Make 35%/12mo, n8n 30%/1yr) | **One-time** — month 12 looks like month 1 |
| Video fit | **Best of the three** | Excellent — contractor content performs |
| The problem | Every AI-content operator alive is producing automation content right now. `Gap = 42` is the most optimistic estimate in this doc | 30-day cookie, payout only after 30 days on-platform, slow cash |
| Kills it if | W01 returns `Gap < 30` | You need compounding revenue, which is the whole thesis of [doc 01](01-strategy-and-model.md) |

**The honest read:** field service is the safer runner-up despite scoring 1.3 points lower,
because its weakness (one-time commissions) is *known* while workflow automation's weakness
(an unmeasured, probably-optimistic competition gap) is exactly the kind of error that costs
six months. Take workflow automation only if W01 measures its gap at 30+ with real SERP data.

**Take either instead of MSP if** W01 shows MSP search volume is too thin, or if you'd
rather have a bigger market than a personal edge.

### Field service / contractor software — the detail

| Program | Terms |
|---|---|
| Housecall Pro | **$320 one-time** (reported up to $1,000 for qualified referrals), 30-day cookie, paid after the lead is on-platform 30 days |
| Jobber | "Industry-leading", no minimums — **rate undisclosed, ask the affiliate manager** |
| ServiceTitan, FieldPulse, Workiz | Comparable programs |

**Pros:** large payouts, huge and growing market, genuinely excellent short-form video fit
(contractor content performs enormously well), buyers with real budgets.

**Why it scores below MSP:** commissions are **one-time, not recurring** — so it never
compounds, and month 12 looks like month 1 ([doc 01](01-strategy-and-model.md)). You'd also
have no domain credibility, making the original-value requirement genuinely expensive to
satisfy. The 30-day cookie is short, and payout only after 30 days on-platform means slow cash.

**Why it scored below workflow automation:** only the ×1.15 expertise multiplier, which
field service doesn't get and can't earn cheaply. On raw components it is the strongest
candidate on the list (79.3 unmultiplied vs MSP's 73.2).

---

## What to do next

1. **Run W01 against candidates 1, 2, 3 and 5** with real keyword and SERP data. The
   monetization half of this doc is done; buy the other half. Candidate 3 is on this list
   now because the corrected scores put it second — it wasn't before.
2. **Apply to programs now, in parallel.** Approval takes 3–14 days
   ([doc 09](09-90-day-plan.md) trap list). Atera, NinjaOne, Syncro, Housecall Pro, Jobber
   — applying costs nothing and doesn't commit you.
3. **Ask every affiliate manager two questions:** "what's your average EPC?" and "is the
   rate negotiable at volume?" Undisclosed rates are usually negotiable ones.
4. **Measure workflow automation's competition gap specifically.** It is the one number
   that decides the runner-up, and the one this doc is least confident about. `Gap < 30`
   disqualifies it outright.
5. **Set the go/no-go tripwire now:** if W01 returns under 2,000 monthly buyer-intent
   searches for MSP tooling, fall back to field service — not to whichever candidate scores
   highest, for the reasons in the runner-up section.

---

## Sources

Program terms verified Sept 2026 — re-confirm before applying:

- [Atera affiliate program — 20% recurring, 60-day cookie](https://openaffiliate.dev/programs/atera)
- [NinjaOne Partner Program](https://www.ninjaone.com/partner-program/)
- [Housecall Pro affiliate program](https://www.housecallpro.com/paid-affiliates/) · [reported $320 one-time / 30-day cookie](https://openaffiliate.dev/programs/housecall-pro)
- [Jobber affiliate program](https://www.getjobber.com/affiliates/) · [directory listing](https://uppromote.com/affiliate-directory/jobber/)
- [n8n cloud affiliate partner program](https://n8n.io/affiliates/)
- [Gusto affiliate program — $200 flat via PartnerStack](https://uppromote.com/affiliate-directory/gusto/) · [HR/payroll program roundup](https://affweekly.com/hr-payroll-software-affiliate-programs/)
- [Accounting affiliate programs — commission rates](https://getlasso.co/niche/accounting/) · [ProfitBooks roundup](https://profitbooks.net/highest-paying-affiliate-marketing-programs/)
- [Course platform affiliate programs — Kajabi/Teachable/Thinkific](https://getlasso.co/niche/course-builder/) · [Kajabi 30% lifetime](https://earnifyhub.com/blog/affiliate/kajabi-affiliate-program-review-2026)
- [Recurring commission program roundup](https://tapfiliate.com/blog/best-recurring-commission-affiliate-programs-gp/) · [SaaS program roundup](https://supademo.com/blog/saas-affiliate-programs)
- [Clio channel partner program](https://www.clio.com/partnerships/channel-partners/)
