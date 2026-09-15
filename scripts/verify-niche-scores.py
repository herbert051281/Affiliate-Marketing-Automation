#!/usr/bin/env python3
"""Check that docs/10's niche scores reproduce from doc 02's stated model.

The first version of doc 10 published scores that did not follow its own formula —
every one understated, two of them by more than 20 points — because the author was
applying a competition penalty far heavier than the 20% weight expresses. The
judgement was right and the arithmetic didn't support it, which is the worst
failure mode for a doc whose whole premise is "don't pick a niche by vibes, score it."

Run this after editing either doc:   python3 scripts/verify-niche-scores.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SHORTLIST = ROOT / "docs" / "10-niche-shortlist.md"
MODEL = ROOT / "docs" / "02-niche-and-offer-selection.md"

# doc 02: 0.30 Monetization + 0.20 Intent + 0.20 Gap + 0.15 Durability + 0.15 Distribution
WEIGHTS = (0.30, 0.20, 0.20, 0.15, 0.15)
GATE = 30          # CompetitionGap below this is auto-rejected before scoring
EXPERTISE = 1.15   # doc 02 bonus multiplier for genuine domain knowledge
EXPERTISE_NICHES = ("MSP / IT operations tooling", "Workflow automation / no-code")

failures = []


def cells(row):
    return [c.strip().replace("**", "") for c in row.strip().strip("|").split("|")]


def table_rows(text):
    return [r for r in text.splitlines()
            if r.strip().startswith("|") and "---" not in r][1:]


def check_weights_still_sum_to_one():
    """The formula lives in doc 02; catch a silent re-weighting there."""
    m = re.search(r"NicheScore\s*=\s*\((.*?)\)\s*$", MODEL.read_text(), re.S | re.M)
    found = [float(x) for x in re.findall(r"0\.\d+", MODEL.read_text().split("NicheScore")[1][:400])]
    weights = found[:5]
    if len(weights) != 5:
        failures.append(f"could not read 5 weights out of doc 02 (found {found[:8]})")
        return
    if abs(sum(weights) - 1.0) > 1e-9:
        failures.append(f"doc 02 weights sum to {sum(weights)}, not 1.0")
    if tuple(weights) != WEIGHTS:
        failures.append(f"doc 02 weights {tuple(weights)} no longer match this script's {WEIGHTS} "
                        f"— update both, then re-derive docs/10")


def check_survivors(text):
    section = text.split("### Ranked survivors")[1].split("### Correction")[0]
    seen = 0
    for row in table_rows(section):
        c = cells(row)
        if len(c) < 9:
            continue
        name, stated = c[2], float(c[3])
        comps = [float(x) for x in c[4:9]]
        mult = EXPERTISE if any(n in name for n in EXPERTISE_NICHES) else 1.0
        calc = round(sum(w * x for w, x in zip(WEIGHTS, comps)) * mult, 1)
        gap = comps[2]
        seen += 1
        if abs(calc - stated) > 0.06:
            failures.append(f"{name}: doc says {stated}, formula gives {calc}")
        if gap < GATE:
            failures.append(f"{name}: gap {gap:.0f} is below the {GATE} gate but listed as a survivor")
        print(f"  {'ok ' if abs(calc - stated) <= 0.06 else 'BAD'} {name:<38} "
              f"{stated:>5}  gap {gap:>3.0f}  x{mult}")
    if seen == 0:
        failures.append("no survivor rows parsed — did the table structure change?")


def check_rejected(text):
    section = text.split("### Disqualified before scoring")[1].split("### Ranked survivors")[0]
    gaps = [float(g) for g in re.findall(r"\|\s*\*\*(\d+)\*\*\s*\|", section)]
    if not gaps:
        failures.append("no rejected rows parsed — did the table structure change?")
    for g in gaps:
        if g >= GATE:
            failures.append(f"a row with gap {g:.0f} is listed as disqualified but passes the {GATE} gate")
    print(f"  ok  {len(gaps)} disqualified, gaps {[int(g) for g in gaps]} — all below {GATE}")


def main():
    text = SHORTLIST.read_text()
    print("doc 02 model:")
    check_weights_still_sum_to_one()
    print(f"  ok  weights {WEIGHTS} sum to 1.0, gate at Gap < {GATE}")
    print("\nranked survivors:")
    check_survivors(text)
    print("\ndisqualified:")
    check_rejected(text)
    print()
    if failures:
        for f in failures:
            print(f"FAIL  {f}")
        sys.exit(1)
    print("ALL SCORES REPRODUCE FROM THE STATED MODEL")


if __name__ == "__main__":
    main()
