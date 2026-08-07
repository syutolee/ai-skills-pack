# `profile/v1` — business profile contract

`.agents/profile.md` holds the static facts about the business every skill in this package needs before doing substantive work: who they are, what they sell, what "working" costs. Every skill reads it before starting. See `contracts/agents-dir-conventions.md` for where it sits inside `.agents/`.

## Frontmatter

```yaml
---
schema: profile/v1
generated_by: <skill-name>
generated_at: YYYY-MM-DD
geo: [TW]           # list, uppercase ISO 3166-1 alpha-2, one or more
locale: [zh-TW]      # list, BCP 47, one or more
---
```

`geo` and `locale` are lists even for a single-market business — a business expanding into a second market adds an entry rather than swapping a scalar field, and every skill that reads `geo` already expects a list. See `AUTHORING.md`'s GEO modules section for how `geo` maps to `references/geo/<code>.md`.

## Fixed sections

Body sections are fixed in heading text and order, the same discipline `positioning/v1` uses (see `contracts/sister-product-compat.md` for why *that* file's four headings stay in Chinese — `profile/v1` is a new schema, so its headings are English from the start):

```markdown
## Brand

## Product URLs

## Main Products

## Competitors

## Margin Basis

## Target CPA

## Calibrated Thresholds
```

### What each section holds

| Section | Holds | Example |
|---|---|---|
| **Brand** | Brand or company name, one line | `Meiling Kitchenware` |
| **Product URLs** | One product/storefront URL per line | `https://example.com/products` |
| **Main Products** | Bullet list, `<name> — <one-line description>` | `Ceramic knife set — flagship SKU, 8 colors` |
| **Competitors** | Bullet list, `<name> — <how they compete>`; an unnamed alternative ("doing it in Excel," "not solving it at all") counts too | `CompetCo — same price tier, ships next-day` |
| **Margin Basis** | How gross margin is calculated and what it currently is — the number every CPA and ad-spend decision gets measured against | `62% gross margin on landed cost, before ad spend` |
| **Target CPA** | Target cost per acquisition, currency + amount, and which product or campaign it applies to | `NT$450 per order, storewide` |
| **Calibrated Thresholds** | Threshold name, current value, and the date it was last calibrated from real data | `Kill threshold: CPA > NT$900 for 3 consecutive days — calibrated 2026-08-01` |

A section missing from the file is a missing data point, not a broken file: a skill that needs it treats the value as absent and degrades (asks the user, or falls back to a default range) rather than erroring or refusing to run — the same failure direction `positioning/v1` uses for a missing field, so a skill reading both contracts doesn't need two different degrade rules.

## Who writes what

Every skill in this package reads `profile.md`; only two write to it, each owning a disjoint set of sections — see `contracts/sister-product-compat.md` for the authoritative ownership table (it governs write ownership across all of `.agents/`, not only `positioning.md`). In short: everything except **Calibrated Thresholds** is written by the onboarding skill (on intake) or the user editing the file directly; **Calibrated Thresholds** is the one section `campaign-analysis` may write back to, after a calibration pass against real spend/conversion data.

## Example (filled)

```markdown
---
schema: profile/v1
generated_by: onboarding
generated_at: 2026-08-06
geo: [TW]
locale: [zh-TW]
---

# Business Profile

## Brand

Meiling Kitchenware

## Product URLs

https://meiling-kitchen.example.com/

## Main Products

- Ceramic knife set — flagship SKU, 8 colors, NT$1,280
- Bamboo cutting board — entry SKU, NT$380

## Competitors

- CompetCo — same price tier, ships next-day
- Generic marketplace listings — 30-40% cheaper, no warranty

## Margin Basis

58% gross margin on landed cost, before ad spend. Free shipping above NT$1,000 comes out of margin, not added to price.

## Target CPA

NT$400 per order, storewide. The flagship SKU alone tolerates up to NT$600.

## Calibrated Thresholds

Kill threshold: CPA > NT$800 for 3 consecutive days — calibrated 2026-08-01.
Scale threshold: CPA < NT$300 with CTR > 2% — calibrated 2026-08-01.
```
