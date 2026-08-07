# Output format: the tracking plan document

## Event property standard table (field reference for designing a tracking plan)

| Category | Properties |
|---|---|
| Page | `page_title`, `page_location`, `page_referrer` |
| User | `user_id`, `user_type`, `account_id`, `plan_type` (**all pseudonymous identifiers — personal data**; check [privacy-compliance.md](privacy-compliance.md)'s four preconditions before using any of them; prefer a coarse field like `user_type` when it already answers the decision instead of sending `user_id`. **`account_id`/member number needs a case-by-case call** — anything equivalent to a login handle, a public seller code, or an enumerable sequential ID is a direct identifier and must not be sent) |
| Ad campaign | `source`, `medium`, `campaign`, `content`, `term` |
| Product | `product_id`, `product_name`, `category`, `price` |

Best practice: keep property naming consistent, attach relevant context, don't duplicate what's auto-collected, **never put a direct identifier in a property** (email/phone/name/national ID/address/reverse-identifiable order number, no exception), and **fill in the data-inventory row below for every pseudonymous identifier** (see [privacy-compliance.md](privacy-compliance.md)'s identifier table and four preconditions, plus [url-pii-protection.md](url-pii-protection.md) — `page_location` is auto-attached by GA4 to every event; no property-design table blocks that on its own).

## Tracking plan template

```markdown
# [Site/product] tracking plan

## Overview
- Tools: GA4, GTM, [any GEO-specific tag]
- Last updated: [date]

## Events

| Event name | Description | Properties | Trigger timing |
|----------|------|------|----------|
| purchase | GA4 official ecommerce event | transaction_id, currency, value, items | Sent once, server-side, when the backend confirms the order as paid (payment webhook); the success page never sends GA4 purchase (a conversion tag on the success page for a different ad platform is that platform's own event, not a second GA4 purchase) |
| signup_completed | User completed registration | method, plan | Success page |
| [GEO-specific intent event, e.g. an add-friend click] | Intent signal, not a count of completions | source | Button click |

## Custom dimensions

| Name | Scope | Parameter |
|------|------|------|
| user_type | User | user_type |

## Conversions

| Conversion | Event | Calculation |
|------|------|----------|
| Purchase | purchase | Deduplicated by transaction_id |
| Signup | signup_completed | Once per session |

## Data inventory results (legal-basis judgment per the GEO module's specific articles)

> Fill every row for real — **don't leave the template's placeholder answer in place**. The same field's answer differs by client and by use purpose.

| Field | Category | Reasoning | Collection legal basis and stated purpose | Use purpose | Beyond original purpose? | Retention | Who can access |
|---|---|---|---|---|---|---|---|
| client_id | Pseudonymous identifier (personal data) | Links back to the same device across sessions | [fill: which basis, what purpose was disclosed] | [fill] | [fill: yes/no + why] | [fill: GA4 retention setting] | [fill] |
| user_id | Pseudonymous identifier (personal data) | Backend holds a mapping table that reverses to the real member | [fill] | [fill] | [fill] | [fill: including the backend mapping table's deletion schedule] | [fill: including who can reach the mapping table] |

## Verification record

| Check | Date | Result | Evidence |
|---|---|---|---|
| No direct identifier in any GA4 payload across the **whole flow** on a sensitive page (not just the first request) | | | Network-tab field list / canary test result |
| URL path/query/fragment all three checked | | | Per-segment check record |
| transaction_id bidirectional test | | | 3 reloads, same ID / two orders, different IDs |
| Backend event passed /debug/mp/collect (validationMessages empty) | | | Debug-endpoint response |
| Payment webhook: forged signature rejected, resend not double-counted, authorized-not-captured doesn't send purchase | | | Test record for all three scenarios |
```

**State clearly at delivery what's measured and what isn't** — especially closed-marketplace attribution limits and any GEO-specific measurement boundary (see the applicable `references/geo/<code>.md`) — don't let the client assume every number in the report carries the same confidence level.
