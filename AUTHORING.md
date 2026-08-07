# AUTHORING — writing skills for ai-skills-pack-v2

Rules for every `SKILL.md` and `references/` file in this package. Read before writing or editing any skill; it answers five questions any new skill has to settle: language, structure, GEO, freshness, tier.

## Language

Every shipped file is English: frontmatter `description`, the `SKILL.md` body, and all `references/` content. The user's conversation language is not affected — the agent replies in whichever language the user uses; only the package's own text stays English, so the same skill runs at the same quality on any model or agent host.

Exception: `.agents/positioning.md`'s four fixed section headings (`## 要打誰` / `## 憑什麼贏` / `## 對比誰` / `## 限制`) are unchanged from v1 — schema `positioning/v1` itself is frozen (see `contracts/sister-product-compat.md`). Quote them verbatim wherever a skill checks or writes that file; do not translate them.

## Structure

Follow the `writing-for-agents` reference for every document in this package. Five levers do most of the work:

- **Information hierarchy** — put material at the rung it's needed: an in-file step for what the agent always does next, in-file reference for rules consulted on demand, a disclosed `references/` file for material only some branches reach. Don't bury steps under reference the agent has to read past to find them.
- **Single source of truth** — a field, a rule, a judgment threshold is defined in exactly one file. Every other file that needs it points there instead of restating it. `contracts/` is where cross-skill definitions live for exactly this reason.
- **Positive instructions** — state the target behavior ("delete the instruction span") rather than the forbidden one ("don't leave instructions in the file") wherever a positive phrasing exists; negation makes the banned behavior more available, not less.
- **Front-loaded triggers** — a `description` or a pointer leads with the word that fires it, one trigger per distinct branch. No synonym stacking.
- **No-op hunting** — before shipping, read every sentence and ask whether it changes the agent's behavior versus what it would already do by default. Delete the ones that don't.

## GEO modules

Skill bodies are GEO-agnostic — no region-specific policy, tax rule, or platform behavior written into `SKILL.md` itself. Region-specific fact goes in `references/geo/<code>.md`, one file per market, `<code>` the lowercased ISO 3166-1 alpha-2 code (`references/geo/tw.md` for Taiwan).

A skill loads the module(s) matching `profile.md`'s `geo` list (uppercase in the frontmatter, e.g. `geo: [TW]`; lowercase the value to find the file). Launch coverage is TW only. When `profile.md` lists a GEO with no matching file, the skill does not silently skip it: it says so explicitly ("this pack has no module for `<GEO>`") and follows the freshness protocol below to look up the current official policy instead of guessing.

## Freshness markers

Any reference entry stating a fact that can go stale (a platform policy, a tax rule, a compliance requirement) carries two things next to the claim:

```
last_verified: YYYY-MM-DD
Source: <official URL>
```

A skill consulting such an entry checks the date. Two conditions force a live re-check against the official source before the skill relies on the entry: the mark is past the staleness window set for that specific reference (the window is a per-reference decision made when that reference is written, not a package-wide constant), or the conclusion touches something that goes live or costs money (an ad launches, a budget changes, a compliance claim gets acted on). Either condition fires on its own — checking the date once at the top of a skill run isn't enough if the one claim actually being used is the stale or high-stakes one.

A skill never rewrites a reference file to update its own `last_verified` date — a mismatch between what's found live and what's on file gets reported to the user with a suggestion to update the package, not silently patched (integrity and injection-persistence risk; see `NOTICE.md` precedent in v1).

**Where the line sits**: a number, a policy, or a link that could be superseded by an external party carries the marker — this pack's own house rules and practitioner starting values carry one too (a single marker for the whole table, pointing at "this pack's own reference" rather than an external URL, is enough — see `campaign-analysis-pro/references/kill-keep-scale-pro.md`'s bottom marker for the pattern). A sentence that only describes how a mechanism behaves (RSA's auto-combination, CBO's budget allocation, Poisson math) doesn't need one on its own — nothing there can be "checked against the current official source," there's no claim to re-verify, only a mechanism to understand.

## Tier marking

`SKILL.md` frontmatter carries `metadata.tier: free` or `metadata.tier: paid`. Free-tier and paid-tier skills both ship in this package; the tier field is what a downstream install process or a user-facing catalog reads to know which skills sit behind a paid gate. It does not, by itself, change how a skill behaves at runtime — that's the free↔paid downgrade behavior each tactical skill defines for itself, per the boundary table in `contracts/sister-product-compat.md`.

## Before shipping a skill

Check it against every rule above — the same way this document was checked against its own rules before shipping (see the ticket that wrote it). A document telling other skills how to write that fails its own rules is the fastest way for it to lose authority.
