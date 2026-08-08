# NOTICE — licensing and source attribution

This package (`ai-skills-pack-v2`) is licensed under the MIT License — see `LICENSE`. It's an English-language product with per-market GEO reference modules (Taiwan at launch; see `AUTHORING.md`'s "GEO modules"), not a localized product in its own right — every `SKILL.md` and `references/` file ships in English regardless of which GEO module it loads.

## Three source tiers

Every skill in this package traces to one of three tiers. A skill's own `SKILL.md` frontmatter `metadata.origin` field states which tier(s) apply and cites the exact upstream/predecessor file; this document is the package-wide summary, not a second copy of that detail.

### Tier 1 — deep localization of `coreyhaines31/marketingskills` (MIT, Corey Haines), via this package's own v1

[coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) is the ultimate upstream. This package doesn't adapt it directly — `ai-skills-pack` (v1) did that work first, deeply localizing platform choices, case studies, and compliance content for Taiwan; each v1 skill's own `NOTICE.md` carries the locked upstream commit, pinned version, and file-level SHA-256 table. v2 rewrites v1's content into English, restructures skill boundaries, and splits free/paid tiers — see each skill's `metadata.origin` for exactly what changed — but the underlying authorship chain back to Corey Haines still runs through it for:

- `ads` (v2 rewrite of v1's `ads`, ticket 05)
- `ad-creative` (v2 rewrite of v1's `ad-creative`, ticket 06)
- `tracking-health` (v2 English rewrite and slim of v1's `tracking-health`, ticket 07)
- `campaign-analysis` (v2 split of v1's `campaign-analysis-iteration` into a free defensive subset, ticket 08, and a paid comparative-judgment module, ticket 09 — the two were merged back into one same-named skill in v2.3, see "v2.3: same-name merge," below)
- `landing-page-cro` — **mixed**: v1's `landing-page-cro` was itself a new build (the upstream project's locked commit ships no CRO skill) **except** its "headline mirroring" section, adapted from upstream `ads/SKILL.md` and credited to Corey Haines in v1's own `NOTICE.md`. v2's rewrite (ticket 12) carries that same mixed status forward — see v2's `landing-page-cro/SKILL.md` `metadata.origin`.
- `shared/references/platform-selection.md` (moved from v1's `ads/references/platform-selection.md`, content unchanged — that file was itself split out of upstream `ads/SKILL.md`, per v1's `ads/NOTICE.md`)
- `tracking-architecture/references/event-library.md`'s recovered catalog (traces through v1's since-cut standalone `analytics` skill, itself a deep localization of upstream `marketingskills`' `analytics` v2.0.0)

### Tier 2 — this package's own v1 original content, carried into v2

Content syutolee.com wrote for v1 with no upstream `marketingskills` counterpart, now rewritten into English for v2:

- `quick-angle` (v2 rewrite of v1's `quick-angle`, ticket 04; `positioning/v1` schema unchanged from v1)
- `shared/references/input-hygiene.md` (extracted from v1-era `quick-angle`'s own input-cleaning logic into a shared reference other skills load)
- `contracts/sister-product-compat.md` §1–§5 (carries v1's field semantics and validation rules forward with no change in meaning — v1's `quick-angle/references/angle-doc-template.md` is still the live `positioning/v1` definition; §6 is new in v2)

### Tier 3 — new in v2, no upstream or v1 predecessor

Skills and references built for this package's v2 with no `marketingskills` or v1 lineage:

- `kickoff` (new free-tier entry point, ticket 03)
- `tracking-architecture` (new paid skill, ticket 10) — its design-vs-health framing, not-tracked reasoning, and platform-mapping structure are new; only its event catalog is Tier 1 (above)
- `experiment-design` (new paid skill, ticket 11; no v1 predecessor — v1 pointed at a third-party `ab-testing` skill instead of shipping this)
- `ad-creative`'s Rendering stage (new paid rendering module, ticket 13, originally shipped as the separate `ad-creative-pro` skill and merged into `ad-creative` in v2.3, see "v2.3: same-name merge," below) — productizes this business's own in-house banner-batch production pipeline (Playwright screenshot + Pillow pixel verification) and reuses its overflow-detection technique, adapted from `sns/carousel/render.py`'s clone-and-measure line-clamp check. No third-party upstream content; templates and scripts are original to this ticket.
- `quick-angle`'s deep-grill mode (new paid module, ticket 17, originally shipped as the separate `kickoff-pro` skill and merged into `quick-angle` in v2.3, see "v2.3: same-name merge," below) — the multi-round interrogation method is modeled on the `grilling` skill's frontier approach (mechanism only, no text reused) and applied to `quick-angle`'s three base questions. No third-party upstream content.
- `shared/references/mcp-setup/` (new reference, ticket 14; free-tier since ticket 21) — the Meta/Google MCP setup guide; original content, cites each platform's own current official documentation inline (see each file's `last_verified`/`Source` markers)
- `contracts/profile-v1.md`, `contracts/kickoff-readout-v1.md`, `contracts/agents-dir-conventions.md`, and `contracts/sister-product-compat.md` §6 (new v2 contracts and additions)
- `AUTHORING.md`, this `NOTICE.md`, `README.md`, `PACKAGING.md`, `validate-skills.sh`

## v2.3: same-name merge (ticket 22)

v2 shipped three paid capabilities as separate `-pro`-suffixed skill directories, installed alongside their free-tier counterpart: `kickoff-pro` (beside `quick-angle`), `ad-creative-pro` (beside `ad-creative`), `campaign-analysis-pro` (beside `campaign-analysis`). All three were always the same skill asked for more — never a separate document, schema, or production line — so the two-file split was tier packaging, not a design boundary. v2.3 merges each pair into one same-named skill: the paid capability is now a section inside the free skill's own `SKILL.md`, present in the paid distribution and absent from the free one, rather than a sibling directory a paid install adds on top.

| Retired directory | Content now lives in |
|---|---|
| `kickoff-pro/` | `quick-angle/`'s "Deep-grill mode" section and `quick-angle/references/deep-grill-mechanics.md` |
| `ad-creative-pro/` | `ad-creative/`'s "Rendering: turning a spec into a file" section, `ad-creative/scripts/`, `ad-creative/templates/` |
| `campaign-analysis-pro/` | `campaign-analysis/`'s "Comparative judgment: the four-gate flow" section and `campaign-analysis/references/{evidence-gates,kill-keep-scale,diagnostic-funnel,iteration-report}.md` (`kill-keep-scale-pro.md` renamed `kill-keep-scale.md` in the move) |

No content was dropped in the merge — see each merged `SKILL.md`'s own `metadata.origin` for the ticket-level detail. The free public distribution (`free-dist/`, GitHub) is unaffected: it never carried the `-pro` directories, and its copy of `quick-angle`/`ad-creative`/`campaign-analysis` keeps the same free-tier behavior it always had.

## Copyright

MIT License. `LICENSE` carries two notices: **Copyright (c) 2025 Corey Haines** (Tier 1 content above, retained per the MIT terms) and **Copyright (c) 2026 syutolee.com** (Tier 2 and Tier 3 content, and the English-rewrite/restructuring work applied to Tier 1 content). Both are released under MIT.

## What changed in v2, package-wide

- **English throughout.** Every `SKILL.md` and `references/` file is English — frontmatter, body, and reference content alike (v1 was Traditional Chinese localization; see `AUTHORING.md`'s "Language"). This is a narrative change from v1's "zh-TW localized product" framing to "English product with per-market GEO data modules."
- **GEO modules, not baked-in region content.** Region-specific policy and platform behavior (formerly v1's `compliance-taiwan.md`, in-body Taiwan case studies) now live in `references/geo/<code>.md`, one file per market, loaded off `.agents/profile.md`'s `geo` field. Launch coverage is TW only (`references/geo/tw.md` across `ads`, `ad-creative`, `tracking-health`).
- **Free/paid tier split.** Every skill's frontmatter carries `metadata.tier: free` or `metadata.tier: paid`; the free↔paid boundary reuses the existing sister-compat degrade discipline — see `contracts/sister-product-compat.md` §6 and `PACKAGING.md` for the free-tier install's degrade-clause citations.
