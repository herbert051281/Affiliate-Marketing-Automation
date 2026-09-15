# Workflows — implementation notes

Full specs live in [`docs/04-workflows.md`](../docs/04-workflows.md). This file covers how
to build them in each orchestrator, and the patterns that matter regardless of tool.

Exported workflow JSON goes here as you build (`w03-keyword-miner.json`, etc.).
**Scrub credentials before committing** — n8n exports can embed them.

---

## Patterns that apply to every workflow

### 1. Always log the run

First node: insert into `workflow_runs` with `status='running'`.
Last node (and the error branch): update with `status`, `items_in`, `items_out`, `error`.
W00 Watchdog reads this table. A workflow that doesn't log is a workflow that can fail
silently for three weeks.

### 2. Idempotency

Every workflow must be safe to re-run. Use natural keys and upserts:
`keywords (niche_id, term)`, `conversions (program_id, network_order_id)`. You *will*
re-run these after failures.

### 3. Batch AI calls

Don't call the model once per keyword. Batch 20–50 per call with structured output. It's
5–10× cheaper and faster, and rate limits stop being a problem.

### 4. Budget guard

Before any AI-heavy loop, check today's spend in `costs`. Over budget → abort and alert.
Log actual token cost after. This is how a runaway loop costs $4 instead of $400.

### 5. Status as the state machine

Workflows trigger off `content_items.status`, never off each other. Any workflow can be
re-run, replaced, or rebuilt in a different tool without touching the others.

---

## n8n (recommended)

| Need | Node |
|---|---|
| Trigger | Schedule Trigger (cron) |
| DB read/write | Postgres node against Supabase (use the connection pooler URI) |
| AI | Anthropic Chat Model + Structured Output Parser |
| Loops | Split In Batches (batch size 20) |
| Branching | Switch on `status` |
| Errors | Set an **Error Workflow** on every workflow → writes `workflow_runs` + alerts |

**Setup:** self-host on a $6/mo VPS with Docker. Put it behind Caddy for TLS. Credentials
go in n8n's credential store, never in nodes. Export workflows to this folder weekly —
that's your backup and your version history.

**Gotchas**
- Use the Supabase **pooler** connection string (port 6543), not the direct one — n8n
  opens more connections than you expect.
- Set "Always Output Data" off, so empty branches don't trigger downstream nodes.
- Pin the Anthropic model ID explicitly (`claude-opus-5`, `claude-sonnet-5`) rather than
  relying on a default.

---

## Power Automate

| Need | Action |
|---|---|
| Trigger | Recurrence |
| DB | HTTP action → Supabase REST (`/rest/v1/{table}`) with `apikey` + `Authorization` headers |
| AI | HTTP → Anthropic Messages API |
| Loops | Apply to each (turn on concurrency, cap at 5) |
| Approvals | **Start and wait for an approval** → Teams/Outlook adaptive card |
| Errors | Configure run after → `has failed` branch |

**Where Power Automate genuinely wins:** the approval layer. Native adaptive cards in
Teams/Outlook with real approve/reject buttons, tracked in the approvals history, on
mobile, with zero build. If you use n8n for the pipeline, still consider Power Automate
for Gates B and C.

**Gotchas**
- HTTP is a premium connector — check your licence before designing around it.
- "Apply to each" over 500+ items is slow and hits limits. Page the data.
- Store Supabase keys in **Azure Key Vault** or environment variables, not in the flow.
- Long AI calls can exceed the default HTTP timeout — set it explicitly.

---

## Suggested build sequence

```
W00 Watchdog      ← first, so everything after it is observable
W01, W02          ← niche + offers (blocks everything downstream)
W03, W04          ← keyword engine
W05, W06, W07     ← content pipeline
W08               ← publisher
W12               ← conversion ingestion (as soon as a program approves you)
W13               ← rollup (so the dashboard has data)
W09, W10          ← distribution
W11               ← link health
W14               ← kill/scale, last (needs 4 weeks of data to be useful)
```

---

## Testing each workflow before it goes live

1. Run with `LIMIT 1` on the input query. Inspect every field.
2. Run with `LIMIT 5`. Check cost against expectation.
3. Deliberately break it — bad API key, malformed response — and confirm the error branch
   writes `workflow_runs` and alerts you.
4. Re-run it twice on the same input and confirm no duplicates.
5. Only then enable the schedule.

Step 3 is the one everybody skips and everybody regrets.
