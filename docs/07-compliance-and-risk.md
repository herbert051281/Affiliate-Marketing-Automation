# 07 — Compliance & Risk

The things that actually kill automated affiliate businesses, ranked by how often they do it.

---

## Risk 1 — Scaled content without differentiation (most common killer)

Search engines explicitly target mass-produced content that adds no original value,
regardless of how it was produced. AI isn't the problem; **undifferentiated** is the problem.

### The mitigation is structural, not stylistic

Every money page must carry at least one thing that cannot be generated from public text.
The brief builder (W05) assigns it, and QA (W07) enforces it as a hard floor:

| Original-value type | How to produce it at scale |
|---|---|
| **Your own pricing tracker** | Scrape merchant pricing weekly, store history, show the chart. Nobody else has "this tool raised prices twice in 18 months." |
| **Your own scoring rubric** | Publish the methodology, score every tool against it consistently |
| **Real screenshots** | Sign up for trials once, capture the actual UI |
| **Original benchmarks** | Timed tests, feature-matrix checks you actually ran |
| **Aggregated community sentiment** | Mine Reddit/G2/forums, quantify the complaints — "34 of 120 reviews mention X" |
| **Your own experience** | The `× 1.15` niche bonus in doc 02 exists for exactly this reason |

A comparison page built on your own structured tool database *is* original data. That's
why the programmatic approach in doc 01 is the moat and not the risk.

### Also
- Publish **slowly and steadily**, not 200 pages week one. 3–5/day maximum for a new site.
- Real author identity, real about page, real contact. Anonymous thin sites get filtered.
- Don't delete-and-reindex churn. Consolidate losers into winners instead.

---

## Risk 2 — Affiliate program termination

Programs terminate accounts without warning and **claw back unpaid commissions**. Causes:

| Violation | How the system prevents it |
|---|---|
| Brand bidding on paid search | `programs.allows_brand_bidding` flag; the ads workflow checks it |
| Emailing links from a program that forbids it | W10 filters offers by `allows_email` |
| Coupon/deal behavior when prohibited | `allows_coupon` flag |
| Missing required disclosure text | W06 injects `programs.required_disclosure` automatically |
| Self-referral / incentivized clicks | Never do it. One-strike offense. |
| Trademark misuse in domains/handles | Checked at setup |
| Cookie stuffing, forced clicks, popunders | Not in this architecture at all |

**Store the TOS as data, enforce it in code.** Re-parse quarterly (W02 flags changes).

Additional hedges:
- Apply to programs **before** you have traffic, and be honest in the application — most
  rejections come from vague applications, not low traffic.
- Keep a pre-approved backup offer for every primary (doc 02, portfolio rule).
- Never exceed 60% revenue from one merchant.
- Keep your own click data. If a network disputes numbers, your logs are the only evidence.

---

## Risk 3 — Disclosure & advertising law

Not optional, and it's cheap to comply with:

- **FTC (US):** clear, conspicuous affiliate disclosure **before** the first affiliate
  link, in plain language, not buried in a footer or behind a "disclosure" link. Applies
  to social posts and video too (verbal + on-screen for video).
- **EU/UK:** advertising disclosure plus GDPR consent for tracking cookies and email.
- **CAN-SPAM / GDPR email:** working unsubscribe, physical address, no pre-ticked consent.
- **Claims:** no unsubstantiated performance claims, no fake scarcity, no fabricated
  testimonials or invented review counts. AI will happily invent "trusted by 10,000 users" —
  QA's factual-verification floor must catch this.
- **Privacy policy + terms** on the site from day one. Generated once, done.

Automate it: disclosure text is a field on the program record, injected by W06, verified
by W07, and rendered above the fold by the site template. It cannot be forgotten.

---

## Risk 4 — Platform dependency

| Dependency | Exposure | Hedge |
|---|---|---|
| Google organic | Algorithm updates | Email list + video; never >60% of traffic |
| TikTok/Meta | Account bans, algorithm shifts | Post to 3+ platforms; all CTAs drive to email |
| One affiliate network | Termination | Multi-network, direct merchant deals in month 4+ |
| One AI provider | Price/policy change | Prompts are provider-agnostic markdown files |
| Your orchestrator | Vendor lock-in | n8n JSON exports in git; logic lives in the DB |

**The email list is the hedge for all of them.** Which is why every single CTA in the
whole system points at the lead magnet, not directly at an offer. A subscriber survives
every platform change on this list.

---

## Risk 5 — Silent failure

An automated business fails quietly. Covered by [W00 Watchdog](04-workflows.md#cross-cutting-w00--watchdog)
and the circuit breakers in [doc 05](05-approval-and-autonomy.md). The specific horrors:

- Tracking parameter drops after a site deploy → 3 weeks of unattributable sales
- A merchant changes their URL structure → every link 404s → W11 catches it in 6 hours
- Email platform starts landing in spam → open rate collapse, nobody notices for a month
- API key expires → pipeline silently stops → discovered by the traffic decline
- QA model drifts → quality erodes gradually → caught by the rejection-rate breaker

Monitor the *inputs* (did the workflow run?) not just the outputs (is revenue up?).

---

## Risk 6 — Money & tax

- **Cash flow lag:** net-30 to net-60 after month close. A week-3 sale can be week-12 cash.
  Budget 4 months of tooling costs up front.
- **Payout thresholds:** many networks hold until $50–100. Small programs can sit unpaid
  for months. Factor into the concentration rule.
- **Tax:** affiliate income is business income. Register appropriately, keep the cost
  records (the `costs` table exists for this), and expect a 1099/equivalent from networks.
- **Reversals are not revenue.** Report net, always. Optimistic gross numbers lead to
  scaling a losing offer.

---

## What to never automate

1. Anything that spends money without a human click
2. Communication with merchants or affiliate managers
3. Negative claims about a named competitor product
4. Responding to a legal or program-violation notice
5. Health, financial, or legal advice of any kind

---

## Pre-launch checklist

- [ ] Privacy policy, terms, affiliate disclosure page live
- [ ] Disclosure renders above the fold on every money page (template-level, not per-post)
- [ ] Every program's TOS parsed into `programs` flags
- [ ] Cookie consent banner if targeting EU/UK
- [ ] Real about page with real identity and contact
- [ ] Backup offer configured for every primary offer
- [ ] Watchdog + all circuit breakers active
- [ ] Nightly database backup verified by an actual restore test
- [ ] No secrets in git (`.gitignore` covers `.env`, workflow exports scrubbed)
