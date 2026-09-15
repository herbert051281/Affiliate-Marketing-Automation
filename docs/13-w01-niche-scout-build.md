# 13 — Build W01: Niche Scout

The first workflow to build, because it settles the one question everything else depends
on: **is the MSP niche real?**

[Doc 10](10-niche-shortlist.md) verified the monetization half (commission terms, sourced).
The competition half — search volume, SERP difficulty — is my estimate, not data. This
workflow buys the data.

**Tripwire:** under **2,000 monthly buyer-intent searches** → switch to field service
software (candidate #2). Decide on the number, not on attachment to the plan.

---

## Node-by-node (n8n)

```
[Manual Trigger]
      ↓
[Set: candidates]            4 niches + seed terms
      ↓
[Postgres: log run start]    workflow_runs, status='running'
      ↓
[Split In Batches]           1 niche at a time
      ↓
[HTTP: DataForSEO keywords]  volume + CPC + difficulty
      ↓
[HTTP: DataForSEO SERP]      top 10 for the 5 biggest queries
      ↓
[Code: compute gap]          % of top-10 slots that are weak
      ↓
[Aggregate]                  collect all niches
      ↓
[Anthropic: score & rank]    prompts/01-niche-scout.md, opus
      ↓
[Postgres: insert niches]    status='candidate'
      ↓
[Postgres: log run end]      status='success'
      ↓
[Email/Teams: approval card] Gate A
```

---

## 1. Candidates

`Set` node, JSON mode:

```json
{
  "candidates": [
    { "niche": "MSP / IT operations tooling",
      "seeds": ["rmm software", "psa software msp", "atera vs ninjaone",
                "best rmm for small msp", "msp software pricing"] },
    { "niche": "Field service / contractor software",
      "seeds": ["field service software", "jobber vs housecall pro",
                "best software for hvac contractors", "plumbing business software"] },
    { "niche": "Vet / dental practice management",
      "seeds": ["veterinary practice management software",
                "dental practice software", "best pims for vet clinic"] },
    { "niche": "Restaurant / hospitality software",
      "seeds": ["restaurant pos system", "toast vs square for restaurants",
                "best pos for small restaurant"] }
  ]
}
```

---

## 2. Keyword data

`HTTP Request` → DataForSEO, Basic Auth credential:

```
POST https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live
```
```json
[{ "keywords": {{ $json.seeds }}, "location_code": 2840, "language_code": "en" }]
```

Then expand with related keywords:
```
POST https://api.dataforseo.com/v3/dataforseo_labs/google/related_keywords/live
```

**Filter to buyer intent only.** This is the number the tripwire is about — 50,000
informational searches are worth less than 3,000 `best X for Y` searches at $12 CPC
([doc 02](02-niche-and-offer-selection.md)).

```javascript
// Code node — keep only commercial-intent terms
const BUYER = /\b(best|vs|versus|alternative|alternatives|pricing|price|cost|review|reviews|compare|comparison|top \d+)\b/i;
const kws = $input.first().json.tasks[0].result.filter(k => BUYER.test(k.keyword));
return [{ json: {
  niche: $('Split In Batches').item.json.niche,
  buyer_intent_volume: kws.reduce((s, k) => s + (k.search_volume || 0), 0),
  avg_cpc: kws.reduce((s, k) => s + (k.cpc || 0), 0) / (kws.length || 1),
  keyword_count: kws.length,
  top_terms: kws.sort((a,b) => b.search_volume - a.search_volume).slice(0, 25)
}}];
```

---

## 3. SERP + competition gap

```
POST https://api.dataforseo.com/v3/serp/google/organic/live/advanced
```

Then compute how beatable the SERP is:

```javascript
// Code node — CompetitionGap
// A "weak" slot = a forum, Reddit, YouTube, or a low-authority site.
// 30%+ weak slots means a new site can realistically break in.
const WEAK = /reddit\.com|quora\.com|youtube\.com|spiceworks\.com|stackexchange|\.forum|community\./i;
const BIG  = /g2\.com|capterra\.com|forbes\.com|nerdwallet\.com|techradar\.com|pcmag\.com|gartner\.com|softwareadvice\.com/i;

const items = $json.tasks[0].result[0].items.filter(i => i.type === 'organic').slice(0, 10);
const weak = items.filter(i => WEAK.test(i.domain)).length;
const big  = items.filter(i => BIG.test(i.domain)).length;

return [{ json: {
  weak_slots_pct: Math.round((weak / (items.length || 1)) * 100),
  big_publisher_slots: big,
  // brand-dominated SERP = auto-reject per doc 02
  auto_reject: big >= 7,
  domains: items.map(i => i.domain)
}}];
```

> DataForSEO doesn't return domain authority directly. This pattern-match on known big
> publishers is a rough proxy — good enough for a go/no-go, not for fine ranking. If you
> want real DR, add an Ahrefs or Moz call later.

---

## 4. Scoring

`Anthropic Chat Model` node:
- Model: **`claude-opus-5`** (pin it explicitly)
- System prompt: paste [`prompts/01-niche-scout.md`](../prompts/01-niche-scout.md)
- User message: the aggregated JSON from all four niches
- Attach a **Structured Output Parser** using the schema in that prompt file

The prompt already carries the scoring model, the auto-reject rules, and the instruction
never to fabricate missing data — it marks gaps `"unknown"` and lowers confidence instead.

Feed it the verified program terms from [doc 10](10-niche-shortlist.md) as context so
`MonetizationDepth` uses real numbers rather than the model's guesses.

---

## 5. Write + approve

```sql
-- Postgres node
insert into niches (name, slug, status, score, score_breakdown, evidence)
values ($1, $2, 'candidate', $3, $4::jsonb, $5::jsonb);
```

Approval card (Gate A) — the format from [doc 05](05-approval-and-autonomy.md#the-daily-digest).
On approve:

```sql
update niches set status = 'active', approved_at = now() where id = $1;
insert into approvals (gate, entity_type, entity_id, decision, decided_by)
values ('A', 'niche', $1, 'approved', 'herbert');
```

Everything downstream keys off `niches.status = 'active'`.

---

## Before you enable it

Per [workflows/README.md](../workflows/README.md):

1. Run with **one** niche. Inspect every field.
2. Run with all four. Check the API cost against expectation.
3. **Break it deliberately** — bad DataForSEO password — and confirm the error workflow
   fires and writes `workflow_runs`.
4. Re-run and confirm no duplicate `niches` rows.
5. Export the workflow JSON to `workflows/w01-niche-scout.json` and commit it
   (**scrub credentials first** — n8n exports can embed them).

---

## Reading the result

| Outcome | Do this |
|---|---|
| MSP ≥ 2,000 buyer-intent searches, weak slots ≥ 30% | Approve it. Proceed to doc 09 week 1. |
| MSP volume under 2,000 | Switch to candidate #2, field service. The machine doesn't change — only the niche row. |
| Everything scores under 60 | Widen the candidate list and re-run before building anything |
| Two niches score within 5 points | Take the one where you have domain expertise — that's the original-value advantage you can't buy |

Then: [doc 09 week 1](09-90-day-plan.md#week-1--infrastructure-before-content).
