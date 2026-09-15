# 14 — Operator's Guide

**Start here if affiliate marketing is new to you.** Every other doc in this repo assumes
you already know the vocabulary. This one doesn't assume anything.

It's long because it's a manual, not an overview. Read Parts 0–3 once to understand what
you're running. Come back to Parts 4–8 while actually running it.

---

# Part 0 — What you're actually building

## The business in four sentences

You publish honest comparisons of software that IT professionals buy. Someone reads one,
clicks through to the vendor, and signs up. The vendor pays you a percentage of what that
customer pays them — **every month, for as long as they stay**. That's it.

You are not selling anything, holding inventory, handling payments, or doing support. You
are the person who did the homework so the buyer didn't have to.

## Why this specific shape

There are five ways to do affiliate marketing ([doc 01](01-strategy-and-model.md)
compares them). This project picked one deliberately:

| Choice | Why |
|---|---|
| **Recurring** commission, not one-time | One sale pays you every month for a year or more. Twenty sales in month 1 are still paying you in month 12, while you make twenty more. |
| **Software**, not physical products | Physical product commissions are 1–4%. Software is 20–40%, and there's no shipping, returns, or stock. |
| **One narrow niche** (MSP / IT ops tooling) | You can genuinely outrank a big publisher on "best RMM for a 5-tech MSP". You cannot outrank them on "best software". |
| **Email list** at the centre | Google traffic is rented — an algorithm change can halve it overnight. A subscriber list is yours. |

## What "automated" actually means here

The machine does the research, writing, publishing, distribution, and measurement. **You
do three things:**

1. **Approve or reject** what the machine proposes (about 15 minutes a day)
2. **Capture the original data** that makes the content worth reading (this is the real job — Part 6)
3. **Decide what to kill and what to scale** on Mondays (about 20 minutes)

Nothing else is yours. If you find yourself writing articles by hand, something is broken.

## The honest version of the timeline

| When | What actually happens |
|---|---|
| Weeks 1–2 | You build. Nothing earns. This is normal. |
| Weeks 2–3 | First clicks on affiliate links. Still $0. Normal. |
| Weeks 3–6 | First commission, probably from email or video — **not** from Google |
| Month 2–3 | Break even on tooling (~$150/mo) |
| Month 4–9 | Google traffic becomes meaningful |
| Month 6–12 | $2–5k/mo **if** you actually run the Monday loop |

**Month 1 earning zero is not failure. It is the plan.** Anyone promising faster is
selling you something.

---

# Part 1 — The words people use

This is the biggest barrier when you're new. Nobody defines these; they just use them.

## Money words

| Term | What it means | Why you care |
|---|---|---|
| **Merchant** / **vendor** | The company whose software you recommend (e.g. Atera) | They pay you |
| **Affiliate program** | The merchant's arrangement for paying people who send them customers | You apply to join; they can reject you |
| **Network** | A middleman platform hosting many programs (Impact, PartnerStack, ShareASale) | One login, many merchants, one payment |
| **Commission** | Your cut of a sale | The whole point |
| **Recurring commission** | You get paid every month the customer stays, not once | This is why the niche was chosen |
| **One-time commission** | You get paid once, however long they stay | Month 12 looks like month 1. Avoid as your anchor. |
| **Cookie window** | How long after clicking your link the buyer can still buy and have it count as yours | 60 days is good. 24 hours (Amazon) is nearly useless for software. |
| **EPC** | Earnings Per Click (usually per 100 clicks). Revenue ÷ clicks | The single best comparison between two offers |
| **Reversal** / **clawback** | A sale that was credited to you, then taken back — refund, chargeback, fraud, or the customer cancelled in trial | **Reversals are not revenue.** Always look at net. |
| **Payout threshold** | The minimum owed before they'll actually pay you | Often $50–100. Small programs can sit unpaid for months. |
| **Net-30 / net-60** | They pay 30 or 60 days *after the month closes* | A sale in week 3 can be cash in week 12. Budget for this. |

## Traffic words

| Term | What it means |
|---|---|
| **SERP** | Search Engine Results Page — the list of ten blue links |
| **Organic traffic** | Visitors from unpaid search results |
| **Impression** | Your page was shown |
| **Visit** / **session** | Someone actually landed on your page |
| **Affiliate click** | Someone clicked your tracked link *out* to the merchant. This is the number that matters, not visits |
| **CTR** (Affiliate CTR) | Affiliate clicks ÷ visits. "Of people who read the page, how many clicked through?" |
| **CVR** (Conversion rate) | Sales ÷ affiliate clicks. "Of people who clicked, how many bought?" |
| **RPM** | Revenue per 1,000 visits. Best single way to compare two articles |
| **DR / DA** | Domain Rating / Authority — a third-party score of how strong a website is. High DR sites are hard to outrank |
| **Lead magnet** | Something useful you give away free in exchange for an email address |
| **Backlink** | Another site linking to yours |

## Rules words

| Term | What it means | Consequence of ignoring |
|---|---|---|
| **TOS** | Terms of Service — the merchant's rules for affiliates | Termination, and they keep your unpaid commissions |
| **FTC disclosure** | A clear statement that you earn a commission, placed **before** the first affiliate link | Legal exposure. Non-negotiable, and it's easy |
| **Brand bidding** | Buying Google ads on the merchant's own name | Banned by most programs. Instant termination |
| **YMYL** | "Your Money or Your Life" — health, medical, finance, legal topics | Held to a much higher standard. This project avoids them entirely |
| **Scaled content abuse** | Publishing lots of pages that add nothing, to game rankings | Google demotes the whole site. See [doc 07](07-compliance-and-risk.md) |
| **Thin affiliate** | A page that just lists products and links with no original information | Same |

## Your niche's words

You'll see these constantly in MSP content. Worth knowing even though you're IT.

| Term | Meaning |
|---|---|
| **MSP** | Managed Service Provider — an outsourced IT department for small businesses |
| **RMM** | Remote Monitoring and Management — the software an MSP uses to watch and fix client machines |
| **PSA** | Professional Services Automation — ticketing, billing, time tracking for an MSP |
| **Endpoint** | A managed device (laptop, server) |
| **Per-technician pricing** | Priced per staff member, not per device. Why one MSP customer is worth a lot |

---

# Part 2 — How a dollar reaches your bank account

This is the part nobody explains, and it's the thing you most need to understand, because
every decision you make depends on knowing where the money is.

## The chain, step by step

```
1.  You publish "Best RMM for small MSPs"
              │
2.  Someone searches, reads it, and clicks your link
              │   the link is yoursite.com/go/atera?c=site&s=<page id>
              │   NOT atera.com — this matters, see below
              ▼
3.  Your redirector does two things in ~50 milliseconds:
       a) writes a row: "click #abc123 happened, from this page, this channel"
       b) sends the visitor to atera.com/?ref=you&subid=abc123
              │
4.  The visitor signs up for a trial. Nothing happens yet — no money.
              │
5.  Trial converts to paid, maybe 14–30 days later.
       Atera records: "subid abc123 produced a customer"
              │
6.  Your W12 workflow pulls their report, sees subid abc123,
       and matches it back to the exact page and channel that caused it.
       Status: PENDING
              │
7.  30–60 days later, Atera confirms the customer stuck.
       Status: APPROVED
              │
8.  After the month closes, net-30 or net-60, they pay.
       Status: PAID → money in your bank
```

**From click to cash: typically 8–14 weeks for the first one.** After that it's a rolling
stream, because month 4 is collecting on months 1, 2 and 3 simultaneously.

## Why the link points at your own site first

This is the single most important piece of infrastructure, and it looks pointless until
you understand it.

If your article linked straight to `atera.com/?ref=you`, you would know you made $400 last
month and **nothing else**. Not which article. Not which channel. Not whether YouTube or
the newsletter drove it.

By passing through your own `/go/` link first, you mint a unique `subid` per click, hand
it to the merchant, and get it back on their report. That's what lets you say *"this
specific article, from LinkedIn, made $52."* Without it, the entire kill/scale loop —
the thing that makes this a business instead of a content mill — cannot run.

Three more things it buys you:

- **Swap-ability.** Merchant changes their URL? Update one database row. Every link you've ever posted, in every video description and old email, updates instantly.
- **Survivability.** A dead program doesn't leave 400 broken links scattered across the internet.
- **Channel measurement.** `?c=linkedin` vs `?c=email` tells you where the money is.

## The four states a sale can be in

You'll see these in the dashboard and they mean very different things.

| Status | Meaning | Count it as income? |
|---|---|---|
| `pending` | Recorded, not yet confirmed by the merchant | **No.** It may vanish. |
| `approved` | Merchant confirmed it's real | Yes |
| `reversed` | Refunded, cancelled, or rejected. Taken back | No — and subtract it |
| `paid` | Money has actually moved | Yes |

**The rule: report net, always.** Gross numbers make you feel good and lead to scaling a
losing offer. The dashboard is built to show net by default for exactly this reason.

---

# Part 3 — The machine: what each part does

Five services. Here's what each is for, in one line, and what breaks if it's down.

| Part | Plain English | If it stops |
|---|---|---|
| **Supabase** (database) | The filing cabinet. Every offer, article, click, and sale lives here | Everything stops. This *is* the business |
| **n8n** (orchestrator) | The robot that runs the 14 workflows on a schedule | Nothing new gets made; existing pages keep earning |
| **Vercel** (website) | Hosts your site and the `/go/` redirector | Site down, clicks lost, money lost |
| **Power BI** (dashboard) | Your read-out. Which pages earn, which don't | You fly blind but keep earning |
| **Email platform** | Holds subscribers, sends the newsletter | Your most valuable channel goes quiet |

> **A note in your language:** think of Supabase as the star-schema source, n8n as
> scheduled Power Automate flows, and Power BI as… Power BI. The architecture is one you
> already know: one warehouse, many jobs writing to it, one semantic layer on top.
> [Doc 06](06-measurement.md) has the actual model.

## The 14 workflows, grouped

You don't need to memorise these. You need to know roughly what's running so an alert
makes sense. Full specs in [doc 04](04-workflows.md).

| Group | Workflows | What they do |
|---|---|---|
| **Find opportunities** | W01 W02 W03 W04 | Pick the niche, find programs, mine keywords, score topics by expected revenue |
| **Make things** | W05 W06 W07 | Brief → draft → quality check |
| **Distribute** | W08 W09 W10 | Publish, turn into videos/posts, assemble the newsletter |
| **Measure** | W11 W12 W13 W14 | Check links, pull in sales, roll up metrics, recommend kill/scale |
| **Watch** | W00 | Every 15 min: is anything broken or stuck? |

**The one to understand is W04.** It ranks topics by *expected commission revenue*, not
search volume — and it rewrites its own scoring weights based on what actually converted.
That feedback loop is what separates this from a content farm.

---

# Part 4 — Your job, concretely

## The daily routine (about 15 minutes)

One message lands at 08:00 — Teams, Outlook, or email, whatever you'll actually open.

```
╔═══════════════════════════════════════════════════════════════════╗
║  DAILY BRIEF · Tue 15 Sep                                         ║
╠═══════════════════════════════════════════════════════════════════╣
║  YESTERDAY        Visits 412 (+8%)  Aff clicks 61  Sales 2        ║
║                   Revenue $84  ·  Cost $6  ·  Profit $78          ║
╠═══════════════════════════════════════════════════════════════════╣
║  ⚠  NEEDS YOU                                                     ║
║  1. Approve 10 topics                       [Approve all] [Review]║
║  2. 2 drafts failed QA                              [Review both] ║
║  3. 1 evidence capture needed: Atera price check     [Open task]  ║
╠═══════════════════════════════════════════════════════════════════╣
║  ✓  DONE WITHOUT YOU                                              ║
║  1 article published · 4 videos posted · 3 dead links swapped     ║
╚═══════════════════════════════════════════════════════════════════╝
```

Work top to bottom and stop when the ⚠ section is empty:

| Time | Action |
|---|---|
| 08:00 | Approve the topic batch — usually one click |
| 08:01 | Review drafts QA flagged — read the specific failure, not the whole article |
| 08:10 | Act on any alert |
| 08:12 | Clear evidence capture tasks (Part 6) |

Then stop. If it's taking an hour, something is wrong with the setup, not with you.

## The weekly routine (Monday, ~20 minutes)

The Monday scorecard is **the actual job**. Everything else is maintenance.

It tells you which pages made money, which didn't, and what to do. You'll see four kinds
of recommendation:

| Recommendation | What it means | Usual answer |
|---|---|---|
| **KILL** | Published 60+ days, no traffic, no sales | Accept. Consolidate it into a page that works |
| **FIX placement** | Lots of readers, few clicking the link | Accept. The link is buried |
| **FIX offer** | Lots of clicks, nobody buys | Accept. Wrong offer, or wrong kind of reader |
| **SCALE** | A cluster is making money | Accept enthusiastically. Make five more like it |

**Do not skip this to publish more content.** Publishing more of the wrong thing is how
people spend a year going nowhere.

## The monthly routine (~45 minutes)

Compare the dashboard's revenue against the **actual payout statements** from each
network. They will disagree. Tolerance is ±10%; above that, your ingestion has a bug and
every decision downstream of it is wrong.

Put it in the calendar. It will not happen as a good intention.

---

# Part 5 — The five decisions, and how to make them

The system has five approval gates ([doc 05](05-approval-and-autonomy.md)). Here's what
each actually asks and how to answer when you don't yet have instincts.

## Gate A — Niche and offers (rare, high stakes)

**Asks:** "Approve this niche?" or "This program changed its terms — acknowledge or swap?"

**How to decide:** Look at *concentration*. If one merchant is more than about 60% of
your available commission, that's a single point of failure. Programs shut down without
warning.

**If terms get worse** (commission cut from 30% to 20%), that isn't automatically a
disaster — but it does mean re-running the numbers. Sometimes your backup is now better.

## Gate B — Topic batch (daily, low stakes)

**Asks:** "Here are 10 topics. Approve?"

**How to decide:** Scan for anything embarrassing or off-niche. Otherwise approve all. The
scoring already ranked these by expected revenue; second-guessing it manually is how you
end up with a hobby instead of a system.

**Deselect a topic if:** it's a near-duplicate of something you have, it's about a tool
you'd never recommend, or it needs first-hand data you don't have and can't get.

## Gate C — Drafts that failed QA (daily, moderate stakes)

**Asks:** "This draft failed on [specific axis]. Publish, fix, or reject?"

The QA reviewer scores six things. You only need to know what each failure *means*:

| Failure | Plain meaning | What to do |
|---|---|---|
| **factual** | It stated a number it can't back up | **Always reject or fix.** A wrong price is worse than no price |
| **original_value** | It doesn't actually contain your evidence, or claims data it wasn't given | Reject. See Part 6 |
| **compliance** | Missing disclosure, or a claim the program forbids | **Always reject.** This is the one that gets you terminated |
| **link_integrity** | A link points somewhere broken | Reject — it's a revenue leak |
| **differentiation** | Too similar to pages already ranking | Reject. Publishing it risks the whole site |
| **brand_voice** | Doesn't sound like you | Judgement call. Often fine to fix and ship |

**Always give a reason when you reject.** The reason gets appended to the QA rules file,
so the same mistake shouldn't survive twice. A rejection with no reason teaches the
system nothing.

## Gate D — Spend (rare)

**Asks:** "Approve this spend increase?"

**How to decide:** Only spend money on something whose numbers you already know. The rule
for a paid test: if EPC > CPC × 1.5 after 100 clicks, scale. Otherwise stop. No hoping.

## Gate E — The Monday scorecard

Covered in Part 4. This is your actual job.

## About "graduated autonomy"

The system starts by showing you everything, and earns the right to skip steps:

| Period | What auto-publishes |
|---|---|
| Weeks 1–2 | Nothing. You read every draft |
| Weeks 3–4 | Videos, if QA scored ≥ 85 |
| Weeks 5–8 | Articles scoring ≥ 90 with no hard failure. You spot-check 2/day |
| Week 9+ | Articles scoring ≥ 85. You spot-check 5 a week |

**The unlock condition:** QA's prediction must have matched your decision at least 90% of
the time over the last 30 drafts. If agreement drops, it rolls back automatically.

Two things never graduate: **the newsletter** (a bad send costs subscribers permanently)
and **evidence capture** (Part 6). Also: no page ever publishes without verified
evidence, at any autonomy level. That gate is in the database.

---

# Part 6 — Evidence capture: the one job only you can do

**This is the most important section in this guide.** If you only internalise one thing,
make it this.

## Why this exists

Google does not penalise content for being AI-written. It penalises content that adds
nothing — and in 2026 it ran three separate updates targeting exactly that, with the
August one naming programmatic pages, unreviewed AI content, and thin affiliate pages
specifically ([doc 07](07-compliance-and-risk.md)).

The thing that makes your page survive is something **only you have**. A price you
tracked. A setup you timed. A limit you hit. A screenshot of a real dashboard.

We used to ask the AI reviewer "does this draft contain original value?" That doesn't
work, for a blunt reason: **a made-up benchmark reads exactly like a real one.** A draft
saying *"in our testing, setup took 47 minutes"* scores brilliantly whether or not anyone
tested anything.

So the claim is now a **database record**, and the database refuses to publish a page
that doesn't cite a verified one. Not a guideline. A hard stop.

## What counts as evidence

| Kind | What it looks like | How you get it |
|---|---|---|
| `pricing_history` | "Atera Professional went from $129 to $149/tech/mo between Mar 2025 and Aug 2026" | Record the price monthly. After 3 months you have something nobody else has |
| `benchmark` | "Full deployment to 25 endpoints took 47 minutes, including agent rollout" | Time yourself doing it once. Write down the number |
| `tested_limitation` | "The reporting module caps custom fields at 20; we hit it at client #4" | Note it when you hit it |
| `rubric_score` | "Scored 6/10 on reporting against our published methodology" | Publish your scoring method once, then apply it consistently |
| `community_sentiment` | "34 of 120 G2 reviews mention slow onboarding" | Count them. Actually count them |
| `screenshot` | A real screenshot of the actual dashboard | Sign up for a trial, take the screenshot |

**Your unfair advantage:** you do this work anyway. You are an IT professional who
evaluates tooling. Writing down what you already observe is nearly free for you and
impossible for a competitor who has never touched the product.

## What does NOT count

- Anything from the vendor's marketing page
- A summary of other people's reviews
- "Experts agree that..."
- A number you're fairly sure is right but didn't check
- Anything you'd be uncomfortable being asked to prove

## How it flows

```
1. You capture something real and record it
       ↓
2. Mark it `verified` (you saw it; it's true; the artifact exists)
       ↓
3. W05 picks it up and briefs an article around it
       ↓
4. W06 writes the page, putting your data high on the page
       ↓
5. W07 checks the draft actually carries YOUR claim, with the real numbers
       ↓
6. Publish gate: no verified record cited → the database refuses. Full stop.
```

## When there's no evidence for a topic

The brief builder will **park the topic** and raise a capture task instead of inventing a
requirement. That's correct behaviour, not a bug.

It also means: **an empty evidence table means nothing publishes.** Capture at least three
records before you brief your first money page.

## The good news about this constraint

It caps your publishing rate at the rate you produce real data — which sounds limiting
until you notice that's the *only* honest ceiling, and it's exactly what separates the
sites that survived 2026 from the ones that didn't.

You need roughly **one sale a month** to break even. You do not need 250 articles. You
need 40–60 genuinely good ones.

---

# Part 7 — Reading the dashboard

Four pages. Here's which number to look at and what it's telling you.

## The one number that matters most

**RPM** — revenue per 1,000 visits. It's the fairest way to compare two articles, because
it accounts for both traffic and monetisation. A page with 200 visits and $40 beats a page
with 2,000 visits and $50.

## Diagnosing low revenue

Low revenue has three completely different causes with three different fixes. **The funnel
tells you which one you have:**

```
Visits ──CTR──▶ Affiliate clicks ──CVR──▶ Sales
```

| Symptom | Healthy range | Diagnosis | Fix |
|---|---|---|---|
| Few visits | — | Distribution problem | More video, more email, more pages |
| Affiliate CTR below 3% | 4–12% | Content/placement problem | Link is buried. Move the comparison table above the fold |
| Conversion below 1% | 1–4% for SaaS trials | Offer or intent problem | Wrong offer, or you're attracting readers who aren't buying |
| Reversal rate above 25% | under 15% | Merchant or traffic-quality problem | Check the offer; may need swapping |

**Diagnose with the funnel, not the total.** "Revenue is low" is not actionable.
"CTR is 2%" is.

## The fix order that actually pays

From [doc 08](08-costs-and-unit-economics.md), ranked by payoff per unit of effort:

1. **Pick a better offer** — biggest lift, one decision, done once
2. **Fix affiliate CTR** — link placement, comparison table position. Cheap to test
3. **Fix conversion** — usually means targeting different keywords
4. **Get more traffic** — the most work for the least return. Do it last

Most people do this list backwards and grind for traffic on a bad offer.

---

# Part 8 — When something breaks

## Alerts you'll see, and what they mean

| Alert | Plain meaning | Urgency |
|---|---|---|
| Workflow failed / didn't run | A robot job broke | Same day |
| Content stuck > 48h | Something's jammed in the pipeline | Same day |
| Clicks dropped > 50% | Usually a broken redirect or the site fell out of Google | **Immediate** |
| Conversion dropped > 40% | Usually the merchant changed something | Same day |
| Link broken / swapped | W11 already fixed it and is telling you | Just acknowledge |
| Terms changed | A merchant cut your rate | Review this week |
| **Program sent a warning email** | You may have violated their TOS | **Stop everything for that program. Read [doc 07](07-compliance-and-risk.md)** |
| Spend over budget | The pipeline paused itself | Check for a runaway loop |

## Circuit breakers — the system stopping itself

These pause things automatically. A pause is the system working, not failing:

| Trigger | What pauses |
|---|---|
| QA rejecting > 40% of drafts | Publishing — the prompts or model drifted |
| Traffic down > 50% in 48h | Publishing — possible penalty or tracking break |
| Spend > 150% of daily budget | The whole pipeline |
| Any program warning | Everything for that program |

## The failures that hide

An automated business fails **quietly**. These are the ones that cost people months:

| Silent failure | How you'd catch it |
|---|---|
| Tracking broke after a site deploy | Clicks go to zero while traffic looks fine. W00 catches it |
| Merchant changed their URL structure | Every link 404s. W11 catches it within 6 hours |
| Newsletter started landing in spam | Open rate collapses. Watch it weekly |
| An API key expired | Pipeline silently stops. W00 catches it |

**The principle: monitor the inputs (did the job run?), not just the outputs (is revenue
up?).** Revenue can look fine for weeks after something broke.

## First things to check when confused

1. Did the workflow actually run? (`workflow_runs` table, or the n8n execution list)
2. Is there an unacknowledged alert?
3. Does a test click on `/go/test` still produce a `click_events` row?
4. Does the dashboard number match the network's own report?

[Doc 12](12-setup-runbook.md) has a troubleshooting table for setup-specific problems.

---

# Part 9 — What normal looks like

So you don't panic, and so you don't fool yourself.

| Month | Realistic | Worrying |
|---|---|---|
| **1** | 12–18 articles, ~100 videos, 50–200 subscribers, $0–50 | Nothing published; no evidence captured |
| **2** | 30–40 articles, 300–800 subs, first consistent sales | Zero affiliate clicks despite traffic |
| **3** | 40–60 articles, 1,000+ subs, $300–1,500/mo | Zero sales despite 500+ affiliate clicks |
| **4** | Apply the go/no-go criteria below | — |

## The month-4 go/no-go

Kill or pivot if **any** of these is true:

- Under 500 visits/month total
- Affiliate CTR below 3% after two placement attempts
- Zero conversions despite 500+ affiliate clicks
- Reversal rate above 40%

Any of these means **the niche or offer is wrong — not the machine.** Re-run the niche
scout and point the same system at a different niche. That takes about a week.

> **The system is the asset. The niche is a configuration value.** This is the single
> most useful mental model in the whole project. You are not building an MSP blog. You are
> building a machine that can be aimed.

---

# Part 10 — Rules you must not break

Short list. Each of these can end the business rather than dent it.

## Never

1. **Never claim you tested something you didn't.** Not in an article, not in an
   application, not to an affiliate manager. It's the fastest way to lose both rankings
   and relationships — and the evidence gate exists so you're never tempted.
2. **Never publish without the FTC disclosure** before the first affiliate link. The
   template handles it; don't work around it.
3. **Never bid on a merchant's brand name** in ads without explicit written permission.
   Instant termination at most programs.
4. **Never post affiliate links to r/msp or r/sysadmin.** Those communities are hostile to
   it and they're right to be. Use them for research only. Getting called out there would
   damage the brand permanently.
5. **Never let one merchant exceed 60% of revenue.** Programs vanish without warning.
6. **Never publish 200 pages in a week.** Fastest possible route to being filtered.
7. **Never report gross revenue to yourself.** Net, always.

## Always

- Date every price and feature claim ("as of 15 Sep 2026...")
- Say who a tool is *wrong* for — it's the strongest trust signal in affiliate content
- Keep your own click logs. If a network disputes numbers, your data is the only evidence
- Re-read program TOS quarterly. They change

## Things a human must do (not automatable)

- Submitting program applications (needs your legal identity and tax forms)
- Talking to affiliate managers
- Anything legal
- Evidence capture

---

# Part 11 — Your first two weeks

Checklist form. Don't start a step until the one before it is genuinely done.

## Week 1 — Build the plumbing

- [ ] Work through [doc 12](12-setup-runbook.md): Supabase, n8n, Vercel, Power BI
- [ ] Verify: 25 tables exist, `channels` has 9 rows
- [ ] Verify: the anon lockdown query returns **zero rows** (doc 12 step 4)
- [ ] Redirector live — a test click on `/go/test` creates a `click_events` row
- [ ] Power BI connected, showing zeros without errors
- [ ] W00 Watchdog running
- [ ] Send the affiliate-manager intro emails ([doc 11](11-program-application-pack.md)) — **not** applications. 10 minutes, do it early
- [ ] Privacy policy, terms, disclosure, about page live

**Done when:** a test click appears in Power BI the next morning.

## Week 2 — Make it produce

- [ ] Fill in `prompts/00-brand-voice.md`. Budget a full hour. It's the highest-leverage hour in the build
- [ ] **Capture your first 3 evidence records** — a price, a timing, a screenshot. Nothing publishes without these
- [ ] Build W01 ([doc 13](13-w01-niche-scout-build.md)) and settle the niche question with real data
- [ ] Lead magnet created (a comparison spreadsheet works well — 2 hours)
- [ ] Email platform connected, landing page live
- [ ] Generate 5 drafts and **read all five carefully**
- [ ] Tune the prompts based on those 5. Do not skip this — otherwise you scale the error
- [ ] Deliberately break something and confirm the alert fires

**Done when:** you approve a topic in the morning and a published article exists that
evening, with a working tracked link in it.

## Then

Follow [doc 09](09-90-day-plan.md) from week 3, and start living the daily routine in
Part 4.

---

# Quick reference

| I want to... | Go to |
|---|---|
| Understand why the business is shaped this way | [doc 01](01-strategy-and-model.md) |
| See the workflow specs | [doc 04](04-workflows.md) |
| Know what I'm approving and when | [doc 05](05-approval-and-autonomy.md) |
| Build the Power BI model | [doc 06](06-measurement.md) |
| Check a compliance rule | [doc 07](07-compliance-and-risk.md) |
| Check the numbers behind a decision | [doc 08](08-costs-and-unit-economics.md) |
| Know what week I should be in | [doc 09](09-90-day-plan.md) |
| Apply to a program | [doc 11](11-program-application-pack.md) |
| Install something | [doc 12](12-setup-runbook.md) |
| See current project state | [HANDOFF.md](../HANDOFF.md) |

**The three sentences to remember:**

1. Your job is approving, capturing evidence, and deciding what to kill or scale.
2. Report net revenue, never gross.
3. The system is the asset; the niche is a configuration value.
