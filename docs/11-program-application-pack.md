# 11 — Program Application Pack

Everything needed to apply to the shortlisted programs in ~15 minutes instead of two hours.
**You submit these yourself** — applications require your legal identity, tax details, and
acceptance of each program's terms.

---

## ⚠️ Timing: do not apply yet

[Doc 09](09-90-day-plan.md) originally put applications in week 1. That was wrong.

Every B2B program on this shortlist manually reviews your site before approving. A bare
domain with no content gets rejected, and **re-applying after a rejection is much harder
than a clean first application** — you usually need to email a manager and explain
yourself. Don't spend your one clean shot on an empty site.

### Corrected sequence

| When | Action | Risk |
|---|---|---|
| **Now** | Create network accounts (PartnerStack, Impact, ShareASale). Free, no approval needed. | None |
| **Now** | Email affiliate managers to introduce yourself (template below). Not an application — can't be rejected. | None |
| **Week 3** | Apply, once 8–10 pages + about page + privacy/disclosure are live | Low |
| Week 6 | Re-approach anyone who declined, with traffic data | Low |

The introduction email is the highest-value move available today. In B2B software, affiliate
managers are actual people with quotas, and a credible practitioner who emails before
applying gets treated very differently from an anonymous form submission.

---

## What every application asks

Have these ready once. They're the same everywhere.

| Field | Your answer |
|---|---|
| Legal name / business entity | `[TBD — sole proprietor is fine to start]` |
| Tax form | W-9 (US) or W-8BEN (non-US) |
| Website URL | `[TBD — must be live with content]` |
| Monthly traffic | Be honest. "New site, launched [date]" beats an inflated number you can't support. |
| Audience description | See draft below |
| Promotional methods | See draft below |
| How you'll promote *us* specifically | See draft below — **this is the field that decides it** |
| Other programs you promote | Honest list, or "none yet" |
| Payment method | PayPal / bank / Wise |

---

## Draft answers (MSP / IT ops niche)

Edit to fit; don't paste verbatim without reading. **Do not claim traffic, testing, or
experience you don't have** — these managers check, and a caught exaggeration ends the
relationship permanently.

### Audience description

> IT operations and managed service professionals evaluating RMM, PSA and monitoring
> tooling — primarily small MSPs (2–20 technicians) and internal IT teams at mid-sized
> organizations. The site publishes hands-on comparisons, migration notes, and reporting
> guidance for this stack.

### Promotional methods

> Long-form comparison and review content on [domain], a weekly email newsletter, and
> YouTube/LinkedIn video. All content carries clear affiliate disclosure. No paid search,
> no brand bidding, no coupon or incentivized traffic.

*(If you later want paid search, ask first — several programs prohibit brand bidding and
terminate for it. See [doc 07](07-compliance-and-risk.md).)*

### Why I'm a good fit — the field that actually decides it

> I work as an IT program success data analyst, so I evaluate this category the way the
> buyer does — on deployment friction, reporting quality, and total cost per technician
> rather than feature lists. My content includes original material most comparison sites
> can't produce: real dashboard screenshots, documented setup timings, and Power BI
> reporting layers built on top of these tools. My readers are the exact buyers you're
> targeting, and they arrive with active evaluation intent rather than casual interest.

That paragraph is why you get approved. It's specific, it's true, and it tells the manager
something they can't get from a form field.

---

## Introduction email — send this now

> **Subject:** Affiliate partnership — [domain], MSP tooling comparisons
>
> Hi [name],
>
> I'm building a comparison and review site for MSP and IT operations tooling, launching
> [month]. I work as an IT program success data analyst, so the content angle is hands-on
> evaluation — deployment friction, reporting quality, cost per technician — rather than
> feature-list roundups.
>
> I plan to apply to your affiliate program once the site has its first content live in a
> few weeks. Before I do, two questions:
>
> 1. What's the average EPC for your program?
> 2. Is the commission rate negotiable at volume?
>
> Happy to share the content plan if useful.
>
> [name] · [LinkedIn]

Their answer to Q1 tells you whether the program is worth the effort. Q2 is the **+75%
revenue lever** from [doc 08](08-costs-and-unit-economics.md) — undisclosed rates are
usually negotiable ones, and asking before you have leverage costs nothing.

---

## Per-program notes

Terms verified Sept 2026. **Re-confirm on each program's own page before applying** — rates
change without notice.

| Program | Terms | How to apply | Priority |
|---|---|---|---|
| **Atera** | 20% recurring, 60-day cookie. Reported $45–$1,300 per paid subscription (per-technician pricing) | Affiliate page; partnership contact listed on their business-partners page | **1 — anchor offer** |
| **NinjaOne** | Partner program, recurring revenue, **rates undisclosed** | Partner program page → form | **2 — ask the rate** |
| **Syncro** | Comparable RMM/PSA program | Direct | 3 |
| Hudu, Pulseway, ScreenConnect | Documentation / remote access adjacent | Direct | 4 — portfolio fill |
| **Housecall Pro** | $320 one-time reported (up to $1,000 for qualified referrals), 30-day cookie, paid after lead is 30 days on-platform | Paid affiliates page | Runner-up niche |
| **Jobber** | "Industry-leading", no minimums, **rate undisclosed** | Affiliates page | Runner-up niche |

**Apply to at least 5.** The [portfolio rule](02-niche-and-offer-selection.md#the-portfolio-rule)
requires a pre-approved backup for every primary offer, and approval rates are maybe 60%
for a new site.

---

## After you apply — tracking

Log every application in the `programs` table so W02 and the dashboard can see status:

```sql
insert into programs (merchant, network, status, applied_at, commission_type,
                      commission_rate, cookie_days, tos_url)
values
  ('Atera',         'direct',      'applied', now(), 'recurring', 20.0, 60,  '...'),
  ('NinjaOne',      'direct',      'applied', now(), null,        null, null,'...'),
  ('Syncro',        'direct',      'applied', now(), null,        null, null,'...'),
  ('Housecall Pro', 'direct',      'applied', now(), 'one_time',  null, 30,  '...'),
  ('Jobber',        'direct',      'applied', now(), null,        null, null,'...');
```

Set a follow-up for **day 10**. Roughly a third of applications simply never get a reply;
a polite nudge to the affiliate manager converts a meaningful share of those.

### Response triage

| Response | Action |
|---|---|
| **Approved** | Record real terms + parse TOS into the `programs` booleans ([doc 02](02-niche-and-offer-selection.md#store-the-tos-as-structured-data-not-a-pdf-youll-never-read)). Create the offer + backup. |
| **Rejected** | Ask why — usually "not enough content". Re-apply at week 6 with traffic data. Don't argue. |
| **No reply after 10 days** | One nudge. Then treat as declined and move on. |
| **Approved with different terms than published** | Believe the contract, not the marketing page. Update `programs` and re-run the offer score — it may no longer be your anchor. |

---

## Once Gmail read access is granted

I can automate the whole triage above: watch for replies from these merchants, classify
approved/rejected/needs-info, extract the real commission terms from the acceptance email,
and write them straight into the `programs` table — surfacing only exceptions in your daily
digest ([doc 05](05-approval-and-autonomy.md)).

Grant read scope at: **claude.ai → Settings → Connectors → Gmail → reconnect.**
