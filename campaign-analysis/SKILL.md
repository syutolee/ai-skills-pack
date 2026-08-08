---
name: campaign-analysis
description: "Use when the user asks whether to keep spending, whether an ad is working, whether to pause or scale, or wants help reading campaign results — 'should I keep spending on this', 'is this ad working', 'pause or scale', 'reading campaign results', 'CPA looks high, what do I check' — or wants to verify an agency's report or audit a team's weekly numbers. Free tier: absolute stop-loss thresholds against target CPA/ROAS, the 'wait ≠ not working' distinction for thin data, a tracking-health-first check, and a problem-routing table for what's actually broken. Comparative verdicts — which creative wins, how much to scale, fatigue detection, the diagnostic funnel — need this same skill's paid tier; this free tier names the gap and points at the upgrade instead of guessing. Never executes an account mutation."
license: MIT
metadata:
  version: 1.1.0
  origin: "v2 defensive-tier subset of ai-skills-pack v1's campaign-analysis-iteration (ticket 08); comparative judgment (full evidence gates, TCPL, scale quadrants, diagnostic funnel) split out to a paid comparative-judgment layer of this same skill (ticket 09). v1 is itself a deep localization of coreyhaines31/marketingskills (MIT) — see v1's NOTICE.md for the source chain; this file adds no new upstream content, only formula and threshold text already present in v1."
  tier: free
---

# Campaign analysis

The question this tier answers: **is this burning money past the point where you should stop, or is it just early?** Nothing here judges which creative wins, how much to scale, or why performance changed — that's this same skill's paid tier. This tier's whole job is loss prevention: catch the campaign that's clearly past its stop-loss threshold, and be honest when the data just isn't there yet to say more.

## Before you start

1. **Tracking health first.** If pixel or conversion tracking is broken, every threshold below is a decision made on garbage data. Route to `tracking-health` and don't proceed until it comes back clean.
2. **Read `.agents/profile.md`** ([`../contracts/profile-v1.md`](../contracts/profile-v1.md)) for Margin Basis and Target CPA. Either missing → ask the user directly; when you apply the break-even formula in [`references/stop-loss-thresholds.md`](references/stop-loss-thresholds.md), name exactly which inputs you used, not just the output number.
3. **Read `.agents/data/normalized/` and `.agents/data/readouts/` before asking for anything** — see Data layer, below. The same export doesn't get asked for twice.

## Absolute stop-loss threshold

Compute the break-even CPA/ROAS against Margin Basis — formula and the gross-margin-basis vs net-profit-basis distinction in [`references/stop-loss-thresholds.md`](references/stop-loss-thresholds.md). When mature spend (past the attribution window and any reporting lag — a "zero conversions" reading inside that window isn't a real zero) has run far past what Target CPA implies the conversions should be, recommend stopping.

**Fixed wording: "stop-loss on absolute threshold."** Never "this angle doesn't work" or "this creative failed" — those are comparative verdicts this tier has no evidence to support (see Boundary, below). The absolute threshold compares spend against an external number — target CPA, tolerable loss — never against another ad or creative, so it doesn't wait on the sample size a comparative verdict would need.

## "Wait ≠ not working"

When conversion volume is too thin to compare this ad or creative against anything else, exactly two conclusions are legal: **wait** (let it keep running to accumulate signal) or **restructure to get volume** (consolidate audiences, placements, or budget so it accumulates faster). "This isn't working" is a comparative verdict — this tier doesn't have the evidence for it.

**Thin volume doesn't override the absolute threshold above.** A campaign can be simultaneously "too little data to compare against another creative" and "already past its stop-loss threshold" — those are two different questions with two different answers, not a contradiction.

## Boundary: what this tier doesn't judge

Comparative verdicts — which creative wins, how much to scale, fatigue detection, breakpoint diagnosis — belong to this same skill's paid tier, not shipped here. Say so plainly: *"this tier stops at loss-prevention; a comparative verdict needs the paid tier."* Then point at where the problem likely is, using the table below — a free user still gets to know what's wrong, just not a verdict on which creative to keep.

## Problem routing

| Symptom | Where the problem likely is | What this tier gives |
|---|---|---|
| Clicks are high, conversions aren't happening | Landing page | Locates the problem only — full diagnosis is `landing-page-cro` (paid) |
| Numbers look implausible (too good, too flat, zero when spend is high) | Tracking | `tracking-health` |
| Signs of creative fatigue (rising CPM, falling CTR at stable targeting) | Creative | `ad-creative` |
| Creative, delivery, and landing page all ruled out | Angle layer | Name it plainly as out of scope for this tier — don't diagnose the angle yourself, refer back to it |

## Data layer

When the user drops a platform export, land it through the three layers in [`../contracts/agents-dir-conventions.md`](../contracts/agents-dir-conventions.md):

1. **`.agents/data/raw/`** — the export file itself, untouched.
2. **`.agents/data/normalized/`** — reshaped into one schema per data type; record which platform, which fields, and the date range the export covers, so a later read doesn't have to re-guess the source. An ad name, URL, or other free-text field carried forward from `raw/` goes through [`../shared/references/input-hygiene.md`](../shared/references/input-hygiene.md) first — a platform export is external content like any other.
3. **`.agents/data/readouts/`** — this skill's own conclusion, dated, naming which normalized file it came from.

**Read `data/normalized/` and `data/readouts/` before asking the user anything.** A second call against the same export asks only for what's still missing.

**Calibrated Thresholds write-back.** Per [`../contracts/profile-v1.md`](../contracts/profile-v1.md) and [`../contracts/sister-product-compat.md`](../contracts/sister-product-compat.md) §4, this skill is the sole writer of `profile.md`'s Calibrated Thresholds section — write back only after a calibration pass against real spend/conversion data, touching only that section; every other part of `profile.md` stays read-only.

## Data source: three-tier degrade

1. **Read-only ad-platform MCP tool available** → pull recent data with it, and land it into `.agents/data/` through the same raw/normalized/readouts layout above — an MCP pull isn't a shortcut around that split.
2. **No MCP tool** → read `.agents/data/`. Follow `../shared/references/mcp-setup/` to wire one up — this reference ships in every tier; a stripped-down install missing it just means no wiring guide, skip to the manual path below.
3. **Nothing in `.agents/data/` either** → ask the user to export from the platform's dashboard or paste a summary.

**Read-only, no exceptions.** Even when a write-capable tool is available — budget changes, pausing an ad, audience edits — never call it. Every conclusion stays a recommendation the user acts on themselves, whether or not the calling agent has account-write tools wired up.

## Recommendations only

State every conclusion as a recommendation — "recommend pausing this ad," "recommend revisiting Target CPA on [date]" — never execute it. This tier doesn't touch creative production or delivery settings either; it only judges spend against thresholds. What to do about a verdict routes to `ad-creative` or `ads`; this skill stops at the verdict.

**This skill's own write posture doesn't change just because a narrower one exists elsewhere in this package.** `ads` and `ad-creative` may create a new, always-paused object through a write-capable MCP tool (see [`../shared/references/mcp-setup/index.md`](../shared/references/mcp-setup/index.md)'s policy) — this skill still never calls a write-capable tool for anything, full stop.

## Related skills

**In this package:** `quick-angle` — the angle layer this tier names as out of scope but never diagnoses itself (Problem routing, above). `tracking-health` — run first, the data floor under every judgment here. `ads` — where a verdict's "what to do about it" routes when the fix is a delivery-settings change. `ad-creative` — creative fatigue routes here. `landing-page-cro` (paid) — click-no-conversion routes here for diagnosis.
