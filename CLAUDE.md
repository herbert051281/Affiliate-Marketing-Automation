# Context for Claude

Read [`HANDOFF.md`](HANDOFF.md) first — it carries current state, locked decisions, and
open questions.

## What this repo is

A blueprint + build kit for an affiliate marketing business designed to run with owner
review/approval only. **Nothing is deployed.** The product here is documentation, a
database schema, prompts, and a small amount of code.

The owner is an IT program success data analyst — strong on Power BI, Power Automate, and
data modelling. Write for that: plain language, actionable outputs, bullets over prose,
automation preferred over manual steps.

## Conventions

- **Docs are the deliverable.** `docs/NN-name.md`, numbered in reading order, linked from
  the README table. Keep them scannable: tables, short sections, no filler.
- **Never commit secrets.** Not in docs, not in prompts, not in workflow exports. n8n JSON
  exports can embed credentials — scrub before committing. `.env.example` lists what's
  needed; `.env` is gitignored.
- **Prompts are versioned files** in `prompts/`. When output quality shifts, `git log` on
  the prompt is the first place to look.
- **Model IDs are pinned explicitly** — `claude-opus-5` for judgment (briefs, QA, niche
  scout), `claude-sonnet-5` for volume (drafting, scripts). Don't rely on defaults.
- Branch: `claude/affiliate-automation-strategy-ix729u`. It is the repo's default branch —
  the repo was empty before this work, so there's no PR to open against a base.

## Design principles this repo commits to

Don't quietly reverse these; they're load-bearing.

1. **Automate selection and measurement before production.** W04 ranks topics by expected
   commission revenue, not search volume, and rewrites its own weights from what actually
   converted. That loop is the difference between a business and a content mill.
2. **One database spine.** Workflows read and write Postgres; they never call each other.
   Any component stays swappable.
3. **Measurement infrastructure ships before the thing it measures.** The redirector and
   the dashboard exist before the first article.
4. **TOS is enforceable data, not a PDF.** Program rules live as booleans on `programs` and
   workflows check them. This prevents the most common cause of account termination.
5. **Graduated autonomy.** Auto-publish thresholds relax only as QA-vs-human agreement
   proves out, and roll back automatically if it drops.
6. **Every money page carries original, first-hand value.** Undifferentiated scaled content
   is the failure mode this whole design exists to avoid.

## Honesty rules for this project

The owner is making real decisions with real money on what's written here.

- **Separate verified from estimated.** Doc 10 does this explicitly — program terms are
  sourced and cited; competition scores are flagged as estimates pending W01 data. Keep
  that distinction anywhere new numbers appear.
- **Cite sources for commission terms and date them.** Rates change without notice.
- **Name the problems with a recommendation**, not just its strengths. Every recommendation
  doc here carries an honest-problems section. Keep that.
- **Don't inflate timelines or earnings.** The plan says first commission at week 3–6 and
  meaningful SEO at month 4–9 because that's true.

## What Claude should not do here

- Submit affiliate program applications, or anything else binding under the owner's
  identity. These need legal name, tax forms, and TOS acceptance.
- Spend money, or set up anything that spends money without an explicit approval step.
- Post to Reddit or any community on the owner's behalf — `r/msp` and `r/sysadmin` are
  research feeds only, never promotion channels.
- Invent search volumes, traffic numbers, or commission rates. Mark unknowns as unknown.
