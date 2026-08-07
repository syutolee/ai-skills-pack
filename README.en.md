# AI Ad Skills Pack v2 (Free Tier) — syutolee.com

*[繁體中文版](README.md)*

An Agent Skills pack for running digital advertising with an AI agent, conforming to the [Agent Skills spec](https://agentskills.io/specification.md). Works with Claude Code and any other host that supports the spec. English content throughout, with per-market GEO reference modules (Taiwan at launch). Part of this content is a deep localization of [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (MIT), carried forward through this package's own v1. Full source chain in `NOTICE.md`, license in `LICENSE`.

## What this pack does

An asset layer for running digital ads. Paste a product or storefront URL, and the agent scans the homepage, writes a starting `profile.md`, and produces a few unverified angle candidates. From there it splits into two lines: a **strategy line** (set the angle, launch, produce creative) and a **data line** (check whether tracking is healthy, judge from the numbers whether spend is still justified).

```
kickoff (scan URL) → quick-angle (positioning)
                        │
          ┌─────────────┴─────────────┐
          ↓                           ↓
    ads + ad-creative           tracking-health
    (platform / budget /        (setup, debug,
     audience / copy /           privacy compliance)
     visual spec)
          │                           │
          └─────────────┬─────────────┘
                        ↓
              campaign-analysis
        (absolute stop-loss judgment)
                        │
                        └──→ verdict feeds back into ads / ad-creative, loop continues
```

## The six free-tier skills

| Skill | Owns |
|---|---|
| `kickoff` | Static scan of a product URL, writes a starting `profile.md` and 2-3 unverified angle candidates |
| `quick-angle` | Three questions (who / why you win / against whom), writes `.agents/positioning.md` |
| `ads` | Platform choice, account structure, budget, audience, compliance review. Advisory only, never touches a live account |
| `ad-creative` | Angle, copy, visual spec: headlines, body copy, static-ad concepts |
| `tracking-health` | Checks whether tracking is broken: verify, debug, fix (GA4/GTM/pixels/UTM) |
| `campaign-analysis` | Absolute stop-loss judgment: is this burning money past the point where you should stop |

These six skills together complete the whole loop, scan, set the angle, launch, produce creative, check tracking, catch a burning campaign. None of them stalls just because a paid module is missing; each one's own `SKILL.md` states its degrade behavior.

## Installation

Clone this repo, or download and unzip it, then drop the skill directories into your agent host's skills directory:

```
git clone https://github.com/syutolee/ai-skills-pack.git
```

- **Claude Code**: `~/.claude/skills/` (user-wide) or the project's `.claude/skills/`
- **Any other Agent Skills spec host**: `.agents/skills/`

Keep `contracts/`, `shared/`, and the six skill directories at the same level, not nested inside one another. Each `SKILL.md`'s frontmatter `name` must match the directory it lives in. Installing the whole set is recommended: the skills check for each other, and fall back to their own degrade branch with reduced functionality when a sibling is missing.

## Paid tier

A separate paid set of modules is available, covering comparative performance verdicts, landing-page diagnosis, tracking architecture design, structured experiment design, and creative rendering. Details and inquiries: [syutolee.com](https://syutolee.com).

## License

MIT. `LICENSE` carries two notices: **Copyright (c) 2025 Corey Haines** (upstream `coreyhaines31/marketingskills`, retained per the MIT terms) and **Copyright (c) 2026 syutolee.com** (this package's original content and its English rewrite/restructuring). Per-file source and adaptation notes: `NOTICE.md`.
