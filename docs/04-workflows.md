# 04 — The 14 Workflows

Each spec is tool-agnostic: it works in n8n, Power Automate, or plain cron + scripts.
Format: **Trigger → Steps → Writes → Gate**.

Legend: 🟢 fully automatic · 🟡 ends at an approval gate · 🔴 human-initiated

---

## Layer 1 — Intake

### W01 — Niche Scout 🟡
Runs once at setup, then quarterly to spot new opportunities.

| | |
|---|---|
| **Trigger** | Manual / quarterly cron |
| **Input** | 10–20 candidate niches (you seed these, or AI generates from structural patterns) |
| **Steps** | 1. For each candidate, query keyword API for `best/vs/alternatives/pricing/review` patterns → volume + CPC<br>2. Pull top-10 SERP for the 5 biggest queries → capture domain authority spread<br>3. Search affiliate networks for programs in the vertical → commission %, cookie, EPC<br>4. Check short-form video demand (hashtag view counts)<br>5. Apply the scoring model from [doc 02](02-niche-and-offer-selection.md)<br>6. Apply hard disqualifiers<br>7. Rank, write top 3 with evidence |
| **Writes** | `niches` (status=`candidate`) |
| **Gate** | **Gate A** — you approve one. It flips to `status=active`; everything downstream keys off it. |

---

### W02 — Offer Harvester 🟡
| | |
|---|---|
| **Trigger** | On niche approval, then weekly |
| **Steps** | 1. Search networks (Impact, PartnerStack, ShareASale, CJ, direct programs) for the niche<br>2. For each: extract commission structure, cookie window, EPC, payout threshold<br>3. **Fetch and parse the program TOS** into structured booleans (`allows_email`, `allows_paid_search`, `allows_brand_bidding`, `required_disclosure`)<br>4. Score with the OfferScore model<br>5. Flag anything where an existing offer's terms *changed* since last run |
| **Writes** | `programs`, `offers` |
| **Gate** | **Gate A** — approve new offers / acknowledge terms changes. Term *downgrades* raise a priority alert. |

---

### W03 — Keyword & Topic Miner 🟢
| | |
|---|---|
| **Trigger** | Daily 02:00 |
| **Steps** | 1. Seed expansion from the niche + each offer's brand name<br>2. Pull: volume, CPC, difficulty, SERP features, "People Also Ask"<br>3. Mine Reddit/forums/YouTube comments in the niche for real buyer language (this is where the non-generic angles come from)<br>4. Classify intent: `transactional` / `comparison` / `informational` / `problem-aware`<br>5. Dedupe against existing `keywords` and published content |
| **Writes** | `keywords` |
| **Gate** | none |

---

### W04 — Opportunity Scorer 🟡 ← *the brain*
| | |
|---|---|
| **Trigger** | Daily 03:00 |
| **Steps** | 1. For each unprocessed keyword compute:<br>`ExpectedValue = Volume × CTR_est(position_est) × AffClickRate(intent) × CVR(offer) × Commission × (1 − refund_rate)`<br>2. Divide by estimated difficulty → **EV per unit of effort**<br>3. Boost topics whose *sibling* topics already convert (learned from W14 feedback)<br>4. Suppress topics in clusters that have underperformed<br>5. Select top 10 for the day |
| **Writes** | `keywords.score`, creates `content_items` (status=`proposed`) |
| **Gate** | **Gate B** — a single digest card with 10 topics. Approve all / deselect some. ~60 seconds. |

> This is the workflow that separates a business from a content mill. It uses **expected
> revenue**, not search volume, and it **learns from actual conversions**.

---

## Layer 2 — Production

### W05 — Brief Builder 🟢
| | |
|---|---|
| **Trigger** | On `content_items.status = approved_topic` |
| **Steps** | 1. Scrape top 10 ranking pages → structure, headings, word count, what they cover<br>2. Identify **coverage gaps** — what nobody answers<br>3. Pull the relevant offer(s) + their allowed disclosure text<br>4. Select internal link targets from existing published content<br>5. Define the **original-value requirement** for this piece: what data/test/screenshot must be included (see [Compliance](07-compliance-and-risk.md)) |
| **Writes** | `content_items.brief` |
| **Gate** | none (briefs are cheap; QA happens at draft) |
| **Prompt** | [`prompts/02-brief-builder.md`](../prompts/02-brief-builder.md) |

---

### W06 — Draft Writer 🟢
| | |
|---|---|
| **Trigger** | On brief complete |
| **Steps** | 1. Generate draft from brief + brand voice file + original-value requirement<br>2. Insert internal links, offer links (as `/go/{slug}`), comparison tables<br>3. Inject FTC disclosure above the fold, automatically<br>4. Generate title variants, meta description, FAQ schema, featured image prompt<br>5. Generate the featured image |
| **Writes** | `content_items.draft`, `assets` |
| **Gate** | none — goes straight to QA |
| **Prompt** | [`prompts/03-draft-writer.md`](../prompts/03-draft-writer.md) |

---

### W07 — QA & Compliance Gate 🟡 ← *the safety net*
| | |
|---|---|
| **Trigger** | On draft complete |
| **Steps** | Score 0–100 on six axes, each with a hard floor:<br>• **Factual verification** — every claim, price, and feature checked against a live source; fabricated specifics are the #1 failure mode of AI content<br>• **Original value** — does it contain the required first-hand data/test/screenshot?<br>• **Brand voice** match<br>• **Compliance** — disclosure present? claims within program TOS? no prohibited language?<br>• **Link integrity** — every `/go/` slug resolves to an active offer<br>• **Differentiation** — semantic similarity vs the top-10 pages; too similar = reject |
| **Writes** | `qa_scores` |
| **Gate** | **Gate C** — score ≥ threshold *and* no hard-floor breach → queued for auto-publish. Otherwise it lands in your review queue with the specific failures listed. |
| **Prompt** | [`prompts/04-qa-reviewer.md`](../prompts/04-qa-reviewer.md) |

> The QA agent must be a **different model call with no memory of writing the draft**, and
> it must be told to look for reasons to reject. A writer grading its own homework is theatre.

---

## Layer 3 — Distribution

### W08 — Publisher 🟢
| | |
|---|---|
| **Trigger** | On approved draft |
| **Steps** | 1. Commit content to the site repo / push via API → Vercel builds<br>2. Ping sitemap, request indexing<br>3. Add to internal link graph — and **update 3 older related posts** to link to it (compounding internal links is free ranking)<br>4. Schedule the distribution chain below, staggered over 5 days |
| **Writes** | `publications` |

---

### W09 — Repurpose Engine 🟢
One piece of content becomes ~10 assets. Zero extra research.

| | |
|---|---|
| **Trigger** | On publish |
| **Steps** | 1. Extract 5 distinct hooks/angles from the article<br>2. For each: 30–45s vertical video script → voiceover → footage/B-roll → captions → export<br>3. Generate 3 text posts (LinkedIn/X) with different angles<br>4. Generate 1 carousel/infographic<br>5. Schedule across TikTok, Reels, Shorts, LinkedIn, X over 5 days at channel-optimal times<br>6. Every CTA points to the **lead magnet**, with `?c={channel}` tracking |
| **Writes** | `assets`, `publications` |
| **Gate** | none after week 4 (see [graduated autonomy](05-approval-and-autonomy.md)); Gate C during weeks 1–4 |
| **Prompt** | [`prompts/05-video-script.md`](../prompts/05-video-script.md) |

---

### W10 — Newsletter Assembler 🟡
| | |
|---|---|
| **Trigger** | Weekly, Thursday 06:00 |
| **Steps** | 1. Pull the week's published content + top-performing older content<br>2. Pull niche news from monitored feeds<br>3. Assemble: 1 short original insight + 3 curated links + 1 "tool of the week" (the anchor offer) + 1 deep link to a money page<br>4. **Enforce TOS**: exclude any offer where `allows_email = false`<br>5. Subject line A/B variants<br>6. Load into email platform as a draft |
| **Writes** | `publications` |
| **Gate** | **Gate C-lite** — one glance, one click. This is the highest-revenue asset; keep a human on it longer than anything else. |

---

## Layer 4 — Monetization & measurement

### W11 — Link Health & Offer Swap 🟢
| | |
|---|---|
| **Trigger** | Every 6 hours |
| **Steps** | 1. HTTP-check every active offer destination<br>2. Compare current commission terms vs stored terms<br>3. On 404 / redirect-to-homepage / program paused / rate cut > 20%:<br>  → swap `offers.destination_url` to the pre-approved backup<br>  → **every link across the whole internet updates instantly** (that's the redirector paying for itself)<br>  → alert you<br>4. Track EPC drift per offer |
| **Writes** | `offers`, alerts |

> Broken and expired affiliate links are the most common silent revenue leak in this
> business. Most operators discover them months late. This workflow is pure found money.

---

### W12 — Conversion Ingestion 🟢
| | |
|---|---|
| **Trigger** | Daily 05:00 + on webhook where available |
| **Steps** | 1. Pull conversion reports from each network's API (or parse the CSV email)<br>2. Match on the `subid` your redirector passed → resolves to exact content item + channel<br>3. Record status: `pending` / `approved` / `reversed` — **track reversals separately**, a 25% reversal rate changes every decision<br>4. Backfill attribution to `content_items` |
| **Writes** | `conversions` |

---

### W13 — Metrics Rollup 🟢
| | |
|---|---|
| **Trigger** | Daily 06:00 |
| **Steps** | 1. **Pull yesterday's visits from the site analytics API** (GA4 / Plausible / Vercel Analytics) → upsert `page_view_daily`, keyed on (date, content_item, channel). Clicks are yours; visits are not, and without this step Affiliate CTR and RPM cannot be computed at all<br>2. Pull the ESP's list stats → upsert `email_list_daily`<br>3. Refresh the `daily_metrics` rollup: one row per (date, content_item, channel, offer) with visits, aff_clicks, conversions, gross_revenue, reversals, net_revenue, pending_revenue, cost, profit |
| **Writes** | `page_view_daily`, `email_list_daily`, `daily_metrics` |

---

### W14 — Kill / Scale Advisor 🟡 ← *the loop closes here*
| | |
|---|---|
| **Trigger** | Weekly, Monday 07:00 |
| **Steps** | 1. Rank content by profit, and by profit *trend*<br>2. **KILL:** published >60 days, <10 visits/mo, 0 conversions → propose deletion/consolidation<br>3. **FIX:** high traffic, low affiliate CTR → propose link placement rewrite<br>4. **FIX:** high affiliate CTR, low conversion → propose a different offer<br>5. **SCALE:** profitable cluster → propose 5 sibling topics + more video volume + a paid test<br>6. **Rewrite W04's scoring weights** based on which intent types/clusters actually converted |
| **Writes** | `recommendations`, updates `scoring_weights` |
| **Gate** | **Gate E** — the Monday scorecard. 15–30 minutes, the most valuable half hour of your week. |

---

## Cross-cutting: W00 — Watchdog 🟢

Runs every 15 minutes. Not glamorous, absolutely necessary.

- Any workflow failed or hasn't run on schedule → alert
- Any content stuck in a status > 48h → alert
- Click volume drops > 50% day-over-day → alert (usually a broken redirect or a deindex)
- Conversion rate drops > 40% week-over-week → alert (usually a merchant-side change)
- API spend exceeds daily budget → **pause the content pipeline**, alert

Without this, an automated business fails silently for three weeks and you find out from
your bank balance.

---

## Workflow dependency map

```
W01 ─▶ W02 ─▶ W03 ─▶ W04 ─▶ W05 ─▶ W06 ─▶ W07 ─▶ W08 ─┬─▶ W09 (video/social)
 ▲              ▲                                      ├─▶ W10 (newsletter)
 │              │                                      └─▶ redirector
 │              │                                              │
 │              │                                        W11 ──┤
 │              │                                              ▼
 │              └────────────────── W14 ◀── W13 ◀── W12 ◀── clicks/sales
 └──────────────────────────────────┘
        (quarterly re-scout)          (weekly weight rewrite)
```
