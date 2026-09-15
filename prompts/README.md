# Prompt Library

Version-controlled prompts. When output quality shifts, `git log` tells you what changed.

| File | Used by | Model |
|---|---|---|
| `00-brand-voice.md` | W06, W09, W10 | — (injected as context) |
| `01-niche-scout.md` | W01 | `claude-opus-5` |
| `02-brief-builder.md` | W05 | `claude-opus-5` |
| `03-draft-writer.md` | W06 | `claude-sonnet-5` |
| `04-qa-reviewer.md` | W07 | `claude-opus-5` |
| `05-video-script.md` | W09 | `claude-sonnet-5` |

## Rules

1. **Opus for judgment, Sonnet for volume.** Briefs and QA decide what gets made and what
   ships — pay for the better model there. Drafting is high-volume and cheap.
2. **The QA prompt never sees the writer prompt.** Separate call, no shared context, and
   explicitly instructed to look for reasons to reject. Self-grading is theatre.
3. **Force structured output.** Every prompt returns JSON with a fixed schema so workflows
   can branch on it without parsing prose.
4. **Feed rejections back.** Every Gate C rejection reason gets appended to the "known
   failure modes" section of `04-qa-reviewer.md`. The same mistake should not survive twice.
5. **No secrets, no affiliate IDs, no API keys in prompt text.** Ever.
