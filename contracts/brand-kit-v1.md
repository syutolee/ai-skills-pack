# `brand-kit/v1` — brand asset & style preferences contract

`.agents/assets/brand-kit.md` collects the reusable creative facts a rendering skill needs to stop guessing what "on-brand" means for this client: which indexed asset is the logo, which color is the brand color, and any layout preference the user has stated out loud. See `contracts/agents-dir-conventions.md` for where it sits inside `.agents/assets/`.

## Frontmatter

```yaml
---
schema: brand-kit/v1
generated_by: <skill-name>
generated_at: YYYY-MM-DD
---
```

`generated_by`/`generated_at` track whichever skill made the most recent write to any section — same convention as `asset-index/v1`, not a per-section timestamp.

## Fixed sections

Body sections are fixed in heading text and order:

```markdown
## Logo

## Color Palette

## Layout Preferences
```

### What each section holds

| Section | Holds |
|---|---|
| **Logo** | One line naming the logo asset by filename, matching an `assets/index.md` heading (e.g. `01-logo.png`) — or, once a cutout exists for it, the cutout path (`assets/cutouts/01-logo.png`) instead, since a cut-out logo is strictly more usable than the flat original. No `logo`-typed entry indexed yet → `none — no logo captured yet`, not an empty section |
| **Color Palette** | One `<role>: <hex or color name> (from <filename or "user-provided">)` line per role — `Primary`, `Secondary`, `Accent` are the roles in use today, more may be added as needed. A role's value should trace back to an `assets/index.md` entry's `Dominant color` field, or to a color the user stated directly |
| **Layout Preferences** | Free-text bullet list, one stated preference per line, each tagged with when it was heard (`- Prefers left-aligned logo — heard in ad-creative session, 2026-08-07`). No preference heard yet → section stays empty, which is legal, not an error |

## Who writes it, who reads it

**Logo** and **Color Palette** are filled or refreshed by whichever paid skill first has `assets/index.md` entries to draw from — today that's `ad-creative`'s Rendering asset-preprocessing step. A later run may replace the Logo line if a better-typed entry appears (e.g. the user drags in an actual `logo`-typed image after an earlier run had none), but never invents a value `assets/index.md` doesn't support.

**Layout Preferences** is append-only: any paid-tier skill in a live conversation with the user may add one line the moment a preference is stated out loud — `quick-angle` and `ad-creative` are the two that do this today. A skill appends its own line and never edits or removes a line another run wrote.

| Section | Who writes | When |
|---|---|---|
| Logo | Whichever paid skill first reads `assets/index.md` — currently `ad-creative` | On that skill's own run; refreshed only if a better-typed logo entry later appears |
| Color Palette | Same as Logo | Same |
| Layout Preferences | Any paid-tier skill mid-conversation with the user — currently `quick-angle`, `ad-creative` | The instant a preference is stated out loud; one line appended, existing lines untouched |

Any skill in this package may read this file once it exists. A missing `brand-kit.md`, or one with empty sections, is a normal "nothing captured yet" state, not an error — degrade the same direction `assets/index.md`'s missing/empty state does: fall back to `profile.md`'s brand facts (name, and any color mentioned in `Main Products`/`Brand`) or ask the user directly, don't block delivery.

## Example (filled)

```markdown
---
schema: brand-kit/v1
generated_by: ad-creative
generated_at: 2026-08-07
---

# Brand Kit

## Logo

assets/cutouts/01-logo.png

## Color Palette

- Primary: #1A73E8 (from 01-logo.png)
- Accent: charcoal gray (from 02-product.jpg)

## Layout Preferences

- Prefers left-aligned logo, not centered — heard in ad-creative session, 2026-08-07
```
