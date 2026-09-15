# 05 — Approval Layer & Graduated Autonomy

Your requirement: *"everything automated with me just reviewing and approving."*
Here's how that works without the business going off the rails in month two.

---

## The five gates

| Gate | What you approve | Frequency | Time | Can it ever be automated? |
|---|---|---|---|---|
| **A** | Niche, new offers, TOS changes | Weekly / on event | 2 min | No — money and legal risk |
| **B** | Topic batch (10) | Daily | 1 min | Partially, at week 8 |
| **C** | Drafts flagged by QA | Daily | 5–10 min | Yes, progressively |
| **D** | Spend changes > threshold | On event | 1 min | No |
| **E** | Weekly kill/scale scorecard | Weekly | 20 min | No — this is your actual job |

**Daily load: ~10–15 minutes. Weekly: +20 minutes.** That's the whole operation.

---

## The daily digest

One message at 08:00 (Outlook/Teams/Slack — whatever you'll actually read). Structure:

```
╔═══════════════════════════════════════════════════════════════════╗
║  DAILY BRIEF · Tue 15 Sep                                         ║
╠═══════════════════════════════════════════════════════════════════╣
║  YESTERDAY        Visits 412 (+8%)  Aff clicks 61  Sales 2        ║
║                   Revenue $84  ·  Cost $6  ·  Profit $78          ║
║                   Top earner: "best X for Y" — $52                ║
╠═══════════════════════════════════════════════════════════════════╣
║  ⚠  NEEDS YOU                                                     ║
║  1. Approve 10 topics                       [Approve all] [Review]║
║  2. 2 drafts failed QA                              [Review both] ║
║       • "X vs Y" — unverified pricing claim (line 34)             ║
║       • "best Z"  — 82% similar to competitor page                ║
║  3. Offer terms changed: [merchant] 30% → 20%    [Ack] [Swap]     ║
╠═══════════════════════════════════════════════════════════════════╣
║  ✓  DONE WITHOUT YOU                                              ║
║  4 articles published · 18 videos posted · 1 newsletter sent      ║
║  3 dead links auto-swapped · 142 keywords scored                  ║
╚═══════════════════════════════════════════════════════════════════╝
```

Design rules that make this work:

1. **Exceptions first, achievements second.** You should be able to act on the top third
   and stop reading.
2. **Every item is one click.** Approve, reject, or "edit" (opens the draft). Never
   "log into the dashboard to see more."
3. **Batch approvals default to approve-all.** If the QA layer is doing its job, the
   common case is one click for the whole batch.
4. **Rejections must teach the system.** Every reject asks for a one-line reason, which
   gets appended to the brand voice / QA rules file. Reject the same thing twice and it
   should stop happening.

### Implementation options

| Approach | Best for |
|---|---|
| Power Automate → Teams/Outlook **adaptive cards** with approve buttons | Native, zero build, you already know it. **Recommended start.** |
| Simple web approval page (Next.js + Supabase) with magic-link auth | Better for reviewing drafts side-by-side |
| Email with signed action links (`/approve?token=...`) | Lowest effort, works on phone |

Start with adaptive cards. Build the web page in month 2 when draft review volume grows.

---

## Graduated autonomy — the schedule

Do **not** start fully automated. Earn it.

| Period | Content approval | Video/social | Newsletter |
|---|---|---|---|
| **Weeks 1–2** | You read every draft | You approve every batch | You approve, and edit |
| **Weeks 3–4** | You read every draft; QA scores logged against your decisions | Auto-post if QA ≥ 85 | You approve |
| **Weeks 5–8** | Auto-publish if QA ≥ 90 **and** no hard-floor breach; you spot-check 2/day | Fully auto | You approve |
| **Week 9+** | Auto-publish if QA ≥ 85; weekly spot-check of 5 random pieces | Fully auto | You approve (keep this one) |

**The unlock condition** between each stage: *the QA score must have agreed with your
decision ≥ 90% of the time over the previous 30 drafts.* Measure this — it's a column in
`qa_scores` (`human_decision` vs `predicted_decision`). If agreement drops, you fall back
a stage automatically.

That's the difference between "I automated it" and "I automated it and it still works in
six months."

### Things that never graduate

- Anything touching money out (ad spend, tool purchases)
- Merchant/partner communication
- Legal, claims, testimonials, comparison verdicts that name a competitor negatively
- The newsletter — it's your highest-trust channel; a bad send costs subscribers permanently

---

## Circuit breakers

Automatic pause conditions. The system stops and waits for you:

| Condition | Action |
|---|---|
| QA rejection rate > 40% over 20 drafts | Pause publishing — the prompt or the model drifted |
| Traffic drops > 50% in 48h | Pause publishing, alert — possible penalty or tracking break |
| Conversion rate drops > 40% w/w | Pause new links to that offer, alert |
| API/tool spend > 150% of daily budget | Pause the pipeline |
| Any program sends a warning email | **Pause everything for that program**, alert immediately |
| Same QA failure type 3× in a week | Pause, and surface the pattern |

Build these on day one. They cost an hour and they are the reason you'll still have a
business in month twelve.
