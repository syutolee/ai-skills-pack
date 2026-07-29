# AI Marketing Skills Pack (Taiwan Localization)

*[繁體中文版](README.md)*

A marketing skills pack that Claude Code and similar agent tools can load directly. Conforms to the Agent Skills spec. Deeply localized adaptation of [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (MIT) — **not a translation**. Platform choices, case studies, regulatory context, and measurement constraints have all been replaced with what a media buyer actually runs into in Taiwan. See `LICENSE` for licensing, and each skill's `NOTICE.md` for its exact source and adaptation notes.

## How the skills are split

Skill boundaries follow the **top-down dependency chain of marketing knowledge**, not "tool function":

```
        ┌─────────────────────────────────────────────┐
        │  1. tracking-health                          │  ← horizontal foundation
        │     every layer's judgment depends on         │
        │     whether these numbers can be trusted      │
        └─────────────────────────────────────────────┘

  2. usp-discovery (value proposition mining)      〔not included〕
                  ↓
  3. campaign-strategy (angle / strategy design)   〔not included〕
                  ↓
     ── quick-angle (fast positioning) 〔included — the lightweight version of this layer〕
        no research, no validation — just organizes your answers to three
        questions into a positioning doc the downstream skills can read
                  ↓
   ┌──────────────┼──────────────┐
   ↓              ↓              ↓
 4a. ad-creative  4b. landing-   4c. ads
   (ad creative)   page-cro       (campaign setup)
                  (landing page
                   CRO)
   └──────────────┼──────────────┘
                  ↓
  5. campaign-analysis-iteration (performance analysis & iteration calls)
                  ↓
  6. strategy-recalibration (strategy recalibration)   〔not included〕
     judges whether the angle/USP assumption itself still holds,
     decides whether to loop back to layer 2/3 — not "tweak the creative again"
```

## The six skills in this pack

| Skill | Owns | Explicitly does not own |
|---|---|---|
| **tracking-health** | Setting up, auditing, and debugging tracking & measurement; PII-leak protection; attribution limits | — |
| **quick-angle** | Asks three questions (who you're targeting, why you win, who you're compared against), writes a 10-20 line positioning doc for downstream skills | Market research, validating whether the claims hold up, producing multiple candidate angles |
| **ads** | Platform selection, account structure, budget allocation, audience setup, Taiwan ad-compliance checks | Performance judgment (→ 5), creative production (→ 4a), account execution (does not execute) |
| **ad-creative** | Defining angles, copywriting, static concept generation, creative capacity planning | Performance analysis and win/lose judgment (→ 5) |
| **landing-page-cro** | Diagnoses landing pages with the LIFT six-factor model; message-match check | Statistical significance testing (→ ab-testing, not included) |
| **campaign-analysis-iteration** | Deciding whether to continue from data — kill/keep/scale, whether to swap creative | Producing creative, changing settings, operating accounts |

**Every skill follows the "lightweight routing entry point (`SKILL.md`) + topical `references/`" progressive-disclosure structure**: `SKILL.md` only holds the role definition, scope boundaries, hard rules, and a routing table; the actual thresholds, checklists, and templates live in `references/` and load on demand.

## Three modules not included in this pack (planned)

`usp-discovery`, `campaign-strategy`, and `strategy-recalibration` are **not provided this time** — this pack only reserves their place and explains what they'd do. They sit at the strategy layer of the dependency chain; content and pricing plans are in [`ROADMAP.md`](ROADMAP.md).

**The six skills in this pack work fully standalone without them.** The three tactical skills (`ads` / `ad-creative` / `landing-page-cro`) each check, before starting, whether the project has a positioning / value-proposition document:

- **Found** → reads it first and uses it as the baseline
- **Not found** → **still proceeds**, but explicitly discloses "this is a generic execution recommendation with no strategic basis," and explains which layer of judgment is missing

This is a **soft nudge, not a hard gate**. No skill refuses to work just because you don't have a positioning doc, but none of them will pretend you do either.

When you don't have a positioning doc handy, `quick-angle` (included in this pack) asks three questions and writes the answers into `.agents/positioning.md`, which the three tactical skills above can then read. It does no market research and doesn't validate whether the answers hold up; its scope differs from `usp-discovery` / `campaign-strategy` — see [`ROADMAP.md`](ROADMAP.md) for details.

## Installation

Drop the skill directories under `ai-skills-pack/` into your agent environment's skills directory (for Claude Code, that's `~/.claude/skills/` or the project's `.claude/skills/`), one directory per skill. The `name` field in each `SKILL.md`'s frontmatter must match the directory it lives in.

**Installing the whole pack together is recommended.** The skills cross-reference each other (for example, `ad-creative` **force-loads** `ads`'s Taiwan ad-compliance reference file when producing creative for a regulated industry); installing only one skill means the parts it can't read fall back to their own degradation handling, but functionality will be limited — for regulated-industry creative, missing the compliance file means only a skeleton flagged for manual review gets output. That's a deliberate fail-closed behavior, not a bug.

## Principles that run through this pack

1. **Don't fabricate** — if there's no data, say so, and state what data is needed to produce the output; don't guess to make it look complete
2. **"Wait and see" and "it doesn't work" are two different conclusions** — don't call it ineffective just because the sample size is insufficient
3. **If you can't measure it, say you can't measure it** — closed e-commerce platforms' in-platform attribution, actual LINE friend-add counts — if a seller can't get the number, don't pretend the report has it
4. **Regulatory sections cite the actual statute and a verification date, and explicitly say this is not legal advice** — have your client's legal or compliance contact review before actually launching
5. **Never promise clients a specific multiple of performance lift** — say "worth testing," not "guaranteed to work"

## License

MIT. The `LICENSE` file contains two copyright notices: **Copyright (c) 2025 Corey Haines** (the upstream `coreyhaines31/marketingskills` project, retained per the MIT terms as required for adaptations; **this includes the "headline mirroring" section of `landing-page-cro`**, which is adapted from the original `ads/SKILL.md`) and **Copyright (c) 2026 syutolee.com** (the localized-adaptation content of four skills, all of `quick-angle`, the original content of `landing-page-cro` other than "headline mirroring," all newly written or rewritten passages across the reference files, and the README/ROADMAP/each `NOTICE.md`). Both are released under MIT. See each skill's `NOTICE.md` for its exact source, pinned version, and nature of adaptation.
