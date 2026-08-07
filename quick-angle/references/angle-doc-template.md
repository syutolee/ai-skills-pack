# Positioning document template

## Template (schema `positioning/v1`)

What gets written to `.agents/positioning.md`: five frontmatter fields and four section headings, all fixed — downstream skills key off them by exact name, and a renamed field or heading reads as a broken schema and triggers the no-positioning-document fallback. This template covers only the fields `quick-angle` owns; an existing file's other content is field-level-merged around it ([`../SKILL.md`](../SKILL.md), Writing the file), never replaced.

The four section headings stay in Chinese — `positioning/v1` is frozen from v1, see [`AUTHORING.md`](../../AUTHORING.md).

```markdown
---
schema: positioning/v1
status: ready
generated_by: quick-angle
generated_at: YYYY-MM-DD
source: user_self_report
---

# Positioning

## 要打誰

<target audience, with situation or trigger moment; a group description — no individual customer's identity>

## 憑什麼贏

<one differentiation claim>

## 對比誰

<who or what they'd choose instead of you>

## 限制

<which field fell short of the bar and what that costs downstream; any instruction-span removals logged here too (field, count, category — never the original sentence); "none" when every field cleared the bar>
```

`status` and `source`'s legal values and how they're decided — see [`../SKILL.md`](../SKILL.md). `schema` and `generated_by` are always the literal values above. `generated_at` is `YYYY-MM-DD`, the write or last-update date.

## Filled example (`ready`)

```markdown
---
schema: positioning/v1
status: ready
generated_by: quick-angle
generated_at: 2026-08-06
source: user_self_report
---

# Positioning

## 要打誰

Restaurant owners 1-3 years into running their own storefront, doing steady
business but losing 30% of margin to delivery-platform commissions, wanting
their own online ordering but stuck without the staff to run it or set up
payments.

## 憑什麼贏

Live the day it launches — we configure the menu, payments, and pickup
integration before handoff, so the owner only runs the kitchen and never
touches the backend.

## 對比誰

Mainly "keep using the delivery platform instead of building their own,"
secondarily the self-serve storefront platforms — cheaper monthly fee, but
the owner has to configure it themselves, and most give up halfway.

## 限制

None.
```

## Filled example (`draft` — question 2 still weak after a follow-up)

```markdown
---
schema: positioning/v1
status: draft
generated_by: quick-angle
generated_at: 2026-08-06
source: user_self_report
---

# Positioning

## 要打誰

Restaurant owners 1-3 years in, losing margin to delivery-platform
commissions, want their own online ordering.

## 憑什麼贏

Consistent quality, good service.

## 對比誰

Keeping the current delivery-platform setup instead of switching.

## 限制

"憑什麼贏" was asked once more and still reads as something any competitor
could say unchanged — below the bar, so `status` is `draft`. The three
tactical skills will treat this as no positioning document until it's
sharpened.
```
