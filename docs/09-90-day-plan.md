# 09 — The 90-Day Plan

Each week has a **definition of done**. If a week isn't done, don't start the next one —
this system is a chain, and a weak link fails silently later.

---

## Phase 1 — Foundation (Weeks 1–2)

### Week 1 — Infrastructure before content

| Day | Task |
|---|---|
| 1 | Supabase project, run [`db/schema.sql`](../db/schema.sql), verify tables |
| 1 | Domain purchased, Vercel project connected, Next.js shell deployed |
| 2 | **Link redirector live** (`/go/[slug]`) writing `click_events` — test with a fake offer |
| 2 | Power BI connected to Postgres, executive page skeleton showing zeros |
| 3 | n8n (or Power Automate) installed, credentials stored, W00 Watchdog running |
| 3–4 | Run **W01 Niche Scout** → **Gate A: pick the niche** |
| 4–5 | Run **W02 Offer Harvester** → create network accounts + email affiliate managers to introduce yourself. **Do not apply yet** — see [doc 11](11-program-application-pack.md) |
| 5 | Privacy policy, terms, disclosure page, about page live |

**Done when:** a test click on `/go/test` appears in Power BI the next morning, and
program applications are submitted.

### Week 2 — The content pipeline

| Day | Task |
|---|---|
| 6–7 | Brand voice file written (`prompts/00-brand-voice.md`) — this is worth real thought |
| 7 | Lead magnet created (a tool comparison spreadsheet or checklist — 2 hours, high value) |
| 8 | Email platform connected, landing page live, welcome sequence (5 emails) automated |
| 8–9 | W03 Keyword Miner + W04 Opportunity Scorer running → first Gate B batch |
| 9–10 | W05 Brief Builder + W06 Draft Writer → generate 5 drafts, read all 5 carefully |
| 10 | **Tune the prompts based on those 5.** Do not skip this. |
| 11–12 | W07 QA agent, calibrated against your judgments on those drafts |
| 12 | W08 Publisher → first 5 articles live |

**Done when:** you approve a topic in the morning and a published article exists that
evening, with a working tracked link in it.

---

## Phase 2 — Distribution (Weeks 3–4)

### Week 3 — Volume and channels

- W09 Repurpose Engine → first 25 videos, posted across 3 platforms
- Social accounts set up with consistent branding, bio link → lead magnet
- Publishing cadence: 3 articles/day, 5 videos/day
- **Apply to affiliate programs now** — the site has content to review ([doc 11](11-program-application-pack.md))
- W12 Conversion Ingestion built for whichever program approves first
- Daily digest (Gate B + C) running — start living the actual routine

**Done when:** videos are posting without you, and the first affiliate clicks appear in
the dashboard attributed to a channel.

### Week 4 — Closing the loop

- W10 Newsletter Assembler → first issue sent
- W11 Link Health running every 6 hours
- W13 Metrics Rollup → all 4 Power BI pages populated with real data
- W14 Kill/Scale → first Monday scorecard
- All circuit breakers armed and tested (deliberately trip one)

**Done when:** the Monday scorecard tells you something you didn't already know.

**Month 1 targets:** ~60 articles, ~100 videos, 50–200 email subs, first commission
likely (from video or email, not search).

---

## Phase 3 — Optimization (Weeks 5–8)

Now the machine runs and **your job changes from building to deciding.**

| Week | Focus |
|---|---|
| 5 | Affiliate CTR. Test link placement: above-fold comparison table vs inline CTA vs sticky bar. Pick the winner on data. |
| 6 | Offer optimization. Swap underperformers. Ask affiliate managers for a rate bump — at volume they often say yes, and it's a 75% revenue lever ([doc 08](08-costs-and-unit-economics.md)). |
| 7 | Programmatic comparison pages. Build the structured tool database, generate the `X vs Y` and `best X for Y` matrix. This is the SEO/AI-citation moat. |
| 8 | Autonomy step-up. Check QA-vs-human agreement; if ≥90%, move to the week 5–8 autonomy tier. Reduce your daily time to ~10 min. |

**Month 2 targets:** 150+ articles, 300+ videos, 300–800 subs, consistent conversions,
break-even on tooling plausible.

---

## Phase 4 — Scale or pivot (Weeks 9–12)

### Week 9–10 — Double down on what works
- W14 has 8 weeks of data now. Find the profitable cluster and produce 5× more of it.
- Kill the bottom 30% of content — consolidate into the winners.
- Add 2–3 more offers at different price points.

### Week 11 — Paid test (only if unit economics are proven)
- Take a page with a known conversion rate and EPC. Spend $300 over 2 weeks.
- Rule: if EPC > CPC × 1.5 after 100 clicks, scale. Otherwise stop. No hoping.
- Check `allows_paid_search` and `allows_brand_bidding` first.

### Week 12 — Decide
Run the [go/no-go criteria](08-costs-and-unit-economics.md#go--no-go-criteria).

| Outcome | Action |
|---|---|
| Profitable and growing | Scale content + spend; plan niche #2 with the same machine |
| Traffic but no conversion | Offer problem — swap offers, re-target keywords to `best/vs/pricing` |
| Conversions but no traffic | Distribution problem — increase video volume, add a channel |
| Neither | Niche was wrong. Re-run W01, redeploy the machine. One week, not one quarter. |

**Month 3 targets:** 250+ articles, 600+ videos, 1,000+ subs, $300–1,500/mo revenue
depending on niche quality and offer value.

---

## The daily routine (from week 3 onward)

```
08:00  Open digest        · approve topic batch        (1 min)
08:01  Review QA-flagged drafts                        (5-10 min)
08:10  Act on any alert                                (0-5 min)
       ─── done ───

Monday +20 min: kill/scale scorecard
Month-end +45 min: reconcile network payouts vs dashboard
Quarterly +3 hrs: re-run niche scout, review prompts, re-read program TOS
```

---

## Sequencing traps to avoid

| Trap | Why it hurts |
|---|---|
| Building content before tracking | You'll have 100 pages and no idea which earn |
| Applying to programs before the site has content | Near-certain rejection, and re-applying is much harder than a clean first application |
| Publishing 200 pages in week one | Fastest way to get filtered as scaled spam |
| Skipping the 5-draft manual read | Your prompts will be wrong and you'll scale the error |
| Automating approvals from day one | You won't know what "good" looks like yet |
| Widening the niche in month 2 | Halves your topical authority, doubles your work |
| Chasing traffic before fixing the offer | Most work, least leverage — see the sensitivity table |
