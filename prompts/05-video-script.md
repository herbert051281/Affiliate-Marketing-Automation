# Prompt — Short-Form Video Script (W09)

**Model:** `claude-sonnet-5` · **Output:** JSON array of 5 scripts

---

## System

Turn one published article into **5 structurally different** 30–45 second vertical video
scripts. Different hooks, different angles — not five rewrites of the same idea. They
will be posted across TikTok, Reels and YouTube Shorts over five days, and a viewer may
see more than one.

### The only job of these videos

Drive viewers to the **lead magnet**, not to the affiliate offer. Email is the asset;
the platform is rented. Never put an affiliate link in a video CTA.

### Structure per script

| Beat | Duration | Requirement |
|---|---|---|
| Hook | 0–3s | A specific claim, cost, mistake, or number. No "hey guys". If the first 3 seconds are generic, nothing else matters. |
| Context | 3–10s | Why this matters to the specific viewer you want |
| Payload | 10–35s | 2–3 concrete, useful points. Give away real value — the lead magnet earns the click, the video earns the trust. |
| CTA | 35–45s | One action, driving to the lead magnet. Spoken **and** on-screen. |

### Five required angle types

1. **Contrarian** — the common advice in this niche that's wrong
2. **Cost/number** — a specific price, waste, or measurable gap
3. **Mistake** — what people get wrong, and what it costs them
4. **Comparison** — A vs B, with a clear verdict
5. **Quick win** — something actionable in under 5 minutes

### Rules

- Spoken language. Short sentences. Read it aloud in your head — if it stumbles, rewrite.
- No claim that isn't in the source article. Same factual standard as the article itself.
- Include the FTC-required verbal + on-screen disclosure when an affiliate relationship
  is mentioned at all.
- Captions are mandatory (most views are muted).

---

## Output schema

```json
[{
  "angle": "contrarian|cost|mistake|comparison|quick_win",
  "hook": "first 3 seconds, verbatim",
  "script": "full voiceover, ~90-120 words",
  "on_screen_text": ["beat 1 caption", "beat 2 caption"],
  "b_roll_prompts": ["visual direction per beat"],
  "cta": "spoken CTA",
  "cta_on_screen": "text overlay",
  "caption": "platform caption with 3-5 hashtags",
  "disclosure_required": true,
  "estimated_seconds": 0
}]
```
