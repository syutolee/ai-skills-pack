---
name: tracking-health
description: "Use when tracking or measurement needs verifying, debugging, or fixing — GA4, GTM, conversion tracking, event tracking, UTM, 'is this actually tracking', 'did this event fire', 'the numbers don't match'. The pack's horizontal foundation: every judgment `ads`, `ad-creative`, `landing-page-cro`, and `campaign-analysis` make assumes these numbers are trustworthy. Health-check tier only — answers 'is it broken,' not 'what's installed' (`kickoff`'s static scan) or 'what should be tracked' (`tracking-architecture`, paid, design). A/B test measurement isn't covered — see `ab-testing` (not shipped with this pack)."
license: MIT
metadata:
  version: 2.0.0
  origin: "v2 English rewrite and slim of ai-skills-pack v1's tracking-health (ticket 07); TW-specific content (LINE OA measurement, PDPA specifics) moved to references/geo/tw.md. v1 is itself a deep localization of coreyhaines31/marketingskills analytics v2.0.0 (MIT, Corey Haines) — see v1's NOTICE.md for the full source chain; this file adds no new upstream content."
  tier: free
---

# Tracking health

You're responsible for making marketing numbers **trustworthy**. This skill is the pack's horizontal foundation — every judgment `ads` (delivery), `ad-creative`, `landing-page-cro`, and `campaign-analysis` make assumes the data under it isn't broken. When tracking is broken, every conclusion built on top of it is wrong — so the first move is always confirming the data holds up, never rushing to instrument more events.

**Three-way split, don't blur these:** `kickoff` answers *what's installed* (static scan, unverified). This skill answers *is it broken* (health check — verify, debug, fix). `tracking-architecture` (paid) answers *what should be tracked* (event design for a given business goal). A user asking "did you check my tracking" wants this skill; a user asking "what events should I even be tracking" wants `tracking-architecture`.

## Before you start

Read `.agents/profile.md` if present — its `geo` field names which `references/geo/<code>.md` module(s) to load (e.g. `references/geo/tw.md` for TW). A listed GEO with no matching file isn't silently skipped — say so, and look up the current official policy instead of guessing.

No positioning document needed here — tracking health doesn't depend on strategy the way `ads`/`ad-creative`/`landing-page-cro` do.

## Hard limits (violating any of these is this skill failing)

1. **No direct identifier reaches an analytics tool** — email, phone, name, national ID, address, credit card, or a reversible order ID — in an event property, event name, or **any part of a URL**. A hash of any of these counts as the identifier itself, not a safe transform (small, fixed-format value spaces make hashes reversible by dictionary attack). This is also Google's platform policy — no consent-based exception. Detail: [references/url-pii-protection.md](references/url-pii-protection.md), [references/privacy-compliance.md](references/privacy-compliance.md).
2. **Opaque pseudonymous IDs are allowed, but they're still personal data** — `client_id`, a random `transaction_id`, a backend-random `user_id` — usable only under the four preconditions in [references/privacy-compliance.md](references/privacy-compliance.md) (legal basis, minimization, retention limit, access control). `account_id`/member number: judge case by case — anything equivalent to a login handle or enumerable is a direct identifier, not opaque.
3. **Never claim measured what wasn't.** Say "can't measure this" plainly (a closed marketplace, an unconfirmed add-friend) rather than reporting an intent signal as a result.
4. **`purchase` fires once, server-side, after payment is confirmed** — never from the success page, never front-end-then-back-end-again. Detail: [references/ga4-implementation.md](references/ga4-implementation.md).
5. **Every webhook is signature-verified and idempotent**, using that source's own official verification method — never generalized from another source's. Detail: [references/ga4-implementation.md](references/ga4-implementation.md) and the applicable GEO module.

## Core principles

- **Track for a decision.** Can't answer "what will I do with this number" → don't instrument it.
- **Name before you build.** lowercase, snake_case, `object_action`; ecommerce events are the exception — use GA4's official reserved names.
- **Clean data beats more data.** One verified event beats ten nobody trusts.

## Health-check order (default sequence on "check my tracking")

1. **Data trustworthiness** — right trigger timing? Revenue inflated or under-counted (`transaction_id` direction)? → [references/ga4-implementation.md](references/ga4-implementation.md), [references/debug-validation.md](references/debug-validation.md)
2. **PII leakage** — is the first GA4 payload off a sensitive page clean? → [references/url-pii-protection.md](references/url-pii-protection.md)
3. **Attribution chain** — UTM / click ID / closed-platform limits / GEO-specific channels intact end to end? → [references/utm-and-attribution.md](references/utm-and-attribution.md), GEO module
4. **Compliance basis** — data inventory done? Privacy policy cover the actual use? → [references/privacy-compliance.md](references/privacy-compliance.md), GEO module
5. **Delivery** — tracking plan, verification record → [references/output-templates.md](references/output-templates.md)

## Reference routing (load on demand, never all at once)

| User intent | Load | Covers |
|---|---|---|
| Set up GA4, name events, ecommerce events, revenue doesn't match | [references/ga4-implementation.md](references/ga4-implementation.md) | Naming rules, core event table, official ecommerce schema, `transaction_id` dedup, `purchase`'s authoritative trigger, Measurement Protocol, payment-webhook verification |
| URL carries PII, GTM allowlist, is `gclid`/`fbclid` trustworthy | [references/url-pii-protection.md](references/url-pii-protection.md) | Four leak channels, protection layers ranked by effectiveness, canary testing |
| GTM structure, UTM naming, closed marketplaces, redirect links | [references/utm-and-attribution.md](references/utm-and-attribution.md) | GTM components and dataLayer, UTM table, closed-platform structural limits, redirect-service safeguards |
| Privacy law, privacy policy, consent, pseudonymous vs. anonymous | [references/privacy-compliance.md](references/privacy-compliance.md) + GEO module | Direct-vs-pseudonymous-identifier line, anonymization technique, data inventory process, region-specific legal basis |
| Event not firing, numbers look wrong, pre-launch checks | [references/debug-validation.md](references/debug-validation.md) | Test tooling, verification checklist, symptom table |
| Deliver a tracking plan | [references/output-templates.md](references/output-templates.md) | Tracking plan template, custom dimensions, event property table |
| A GEO-specific channel or legal basis not covered above | `references/geo/<code>.md` (see `profile.md`'s `geo` field) | Region-specific measurement mechanics and legal citations |

## Kickoff questions

1. What's in place now (GA4, GTM, other)? What's already tracked?
2. Which behaviors matter, and is there an ecommerce transaction involved (needs the official schema)?
3. What decision does this data support?
4. Who implements — dev or marketing?
5. Any compliance constraint, or a sensitive industry (finance, health)?
6. Any GEO-specific ad channel that needs its own tag (check the GEO module)?
7. Selling direct, or through a closed marketplace (decides whether third-party tracking can even be installed)?

## Related skills

**In this package:**
- `kickoff` — static scan of what's installed; the natural first stop for a brand-new project with nothing set up yet.
- `tracking-architecture` (paid) — event-architecture design. Check whether `../tracking-architecture/` exists: present → route comparative "what should we track" questions there; absent → say plainly this tier only checks what exists, no design recommendation.
- `campaign-analysis` — every threshold there assumes this skill's data is clean; route back here first when numbers look implausible.
- `ads`, `ad-creative`, `landing-page-cro` — iterate against the numbers this skill verifies.

**Not shipped with this pack:** `ab-testing` — experiment design and measurement.
