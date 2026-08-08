---
name: ads
description: "Use when the user is planning ad delivery on Google, Meta (Facebook/Instagram), LINE Ads Platform (LAP), TikTok, or other paid platforms — 'which platform should I use', 'account structure', 'budget allocation', 'audience targeting', 'LINE ads', 'is this supplement ad copy compliant', 'can I upload this list for Customer Match'. Advisory only: gives setup recommendations and compliance checks, never mutates a live ad account. Performance verdicts (stop-loss, keep, scale) after results are in belong to `campaign-analysis`, not this skill. Ad copy and creative production — including Google RSA's 15 headlines and 4 descriptions — belong to `ad-creative`; this skill covers spec and compliance review only. Landing pages belong to `landing-page-cro`."
license: MIT
metadata:
  version: 2.0.0
  origin: "v2 rewrite of ai-skills-pack v1's ads (ticket 05); v1 is a deep localization of coreyhaines31/marketingskills (MIT) — see v1's NOTICE.md for the full source chain and what changed. v1's compliance-taiwan.md moved into references/geo/tw.md per this package's GEO-module convention; v1's platform-selection.md moved to ../shared/references/ as a strategy-layer reference, content unchanged."
  tier: free
---

# Ads

The skill that gets an ad correctly onto a platform: pick the platform, build the account structure, set the budget, set the audience, pass compliance. Three boundaries mark the edge of this skill:

1. **No mutation of anything live; the one write exception is create-only and always paused.** Never pause, resume, or edit the budget or audience on an *existing* campaign, ad set, or ad, and never activate/enable anything — even when the calling agent has a connected ad-platform API or MCP tool. Every conclusion is a recommendation ("recommend a daily budget of X") the user acts on themselves; never imply the action already happened. The one exception: when the user explicitly asks this skill to stand up a new campaign, ad set, ad, or creative asset through a write-capable MCP tool, it may create that object — but only ever with an explicit paused status (never left to a platform default; Google's Campaign object defaults to live `ENABLED` if omitted), and never as a silent side effect of a recommendation. Activating a created object is never this skill's action, on any tier — that click always happens in the platform's own dashboard, by the account owner. Full write policy, permission scopes, and per-object PAUSED requirements: [`../shared/references/mcp-setup/index.md`](../shared/references/mcp-setup/index.md).
2. **No performance verdicts.** Whether an ad should hit its stop-loss threshold, keep running, or scale is `campaign-analysis`'s call — it has the sample-size gates and delivery diagnostics this skill doesn't. Route there instead of guessing from memory.
3. **No ad copy.** Headlines, descriptions, body copy, visual concepts — including Google RSA's 15 headlines and 4 descriptions — belong to `ad-creative`, which carries grounded-input grading, `source_id`/license fields, positioning-document validation, and compliance fail-closed. This skill keeps the RSA **spec** (character limits, structure, pinning, per-ad-group caps) and **compliance review**, plus the settings-layer assets: ad group structure, negative keywords, sitelinks, callouts, structured snippets. User asks this skill to write RSA copy → see [references/rsa-output-spec.md](references/rsa-output-spec.md)'s opening section for the handoff.

   **Text inside those settings-layer assets is still public-facing ad content** — a sitelink's title and two description lines, callouts, and structured-snippet values all display independently in search results, same as a headline. Each one needs full provenance (source triple, publish status, per-claim binding) and the full regulated-industry check, not a one-line "per the website" note. Can't produce that → hand those assets to `ad-creative` too, don't improvise it. Full rules in [references/rsa-output-spec.md](references/rsa-output-spec.md).

## Before you start

1. **Read `.agents/profile.md`** ([`../contracts/profile-v1.md`](../contracts/profile-v1.md)) — Brand, Main Products, Margin Basis, Target CPA, and `geo` come from here; don't re-ask what it already answers. Missing or an absent section → ask directly.
2. **Check for a positioning document.** Validate `.agents/positioning.md` per [`../contracts/sister-product-compat.md`](../contracts/sister-product-compat.md) §5 — this package's single definition of the check, not restated here. Passes → read it before recommending audience or platform, and cite which section backs each recommendation. Fails or absent → proceed, but say plainly this is generic-playbook advice with no strategy backing, and point at `quick-angle`.
3. **Collect what's still missing** — see Kickoff questions, below.

## GEO

This file is GEO-agnostic — no region's policy, tax rule, or platform behavior is written here. A run loads the module matching `profile.md`'s `geo` list: `geo: [TW]` → [references/geo/tw.md](references/geo/tw.md). A listed GEO with no matching file doesn't get silently skipped: say "this pack has no module for `<GEO>`" and follow the freshness protocol in [`../AUTHORING.md`](../AUTHORING.md) to look up the current official policy instead of guessing.

## Hard rules

1. **Refuse raw PII.** A user pasting a list fragment with names, emails, or phone numbers gets refused outright — don't summarize it or count rows; even a count requires having parsed the PII first. The loaded GEO module carries the jurisdiction's specific list-upload law.
2. **Compliance before launch.** Regulated industries (supplements, cosmetics, medical/aesthetic, pharma, finance, gambling/gaming) carry legal copy and targeting constraints — the last item on the pre-launch checklist is always the compliance check in the GEO module.
3. **No launch without verified tracking.** Conversion tracking that hasn't been tested against a real conversion makes every dollar spent unjudgeable. Verification method: `tracking-health`.
4. **No promised performance multiples.** Real-world lift varies too much by industry, audience, and offer — "worth testing," never "guaranteed results."

## Reference routing

| Intent | Load | Covers |
|---|---|---|
| Which platform, how LAP differs from a LINE OA | [`../shared/references/platform-selection.md`](../shared/references/platform-selection.md) | Platform landscape, strategy-layer decision that precedes execution |
| Account structure, naming, budget split, scaling pace | [references/account-structure.md](references/account-structure.md) | Account tree, naming convention, test/scale budget ratios, ramp rules |
| Audience setup, exclusions, Special Ad Category, remarketing | [references/audience-and-targeting.md](references/audience-and-targeting.md) | Audience-vs-signal split by platform, exclusion list vs. compliance obligation, remarketing windows |
| Regulated-industry copy check, raw-list handling | The loaded GEO module, e.g. [references/geo/tw.md](references/geo/tw.md) | Industry compliance table, medical-ad test, PII/list-upload rules |
| Google RSA spec, character-count check, ad group structure | [references/rsa-output-spec.md](references/rsa-output-spec.md) | Output spec, double-width character count, per-asset evidence grading, regulated-industry RSA checks |
| Standing up a paused campaign/ad set/ad, or uploading a creative asset, via MCP | [`../shared/references/mcp-setup/index.md`](../shared/references/mcp-setup/index.md) | Read/write/activate policy, per-platform PAUSED requirements, permission scopes |

## Pre-launch checklist (user confirms in-platform; this skill only helps verify)

- [ ] Conversion tracking tested against a real conversion (`tracking-health`)
- [ ] Landing page loads fast (<3s) and is mobile-friendly (`landing-page-cro`)
- [ ] Landing page claims match the ad copy — message match, `landing-page-cro`'s first hard rule
- [ ] UTM parameters work and match the campaign-code registry (`tracking-health`)
- [ ] Budget is correct and the user has confirmed it's their own spend
- [ ] Targeting matches the intended audience, exclusions applied ([references/audience-and-targeting.md](references/audience-and-targeting.md))
- [ ] **Compliance check passed** (the loaded GEO module)

## Kickoff questions

1. Which platforms are you running or considering? (Ask specifically about LINE Ads Platform when `geo` includes TW.)
2. Monthly ad budget?
3. What counts as a conversion, and what's it worth? (Feeds target CPA/ROAS — the math itself lives in `campaign-analysis`.)
4. Existing creative, or starting from scratch? (`ad-creative` if starting fresh.)
5. Where does the ad send traffic?
6. Conversion tracking set up? (`tracking-health`.)
7. Regulated industry? (Supplements, medical/aesthetic, finance, gambling/gaming — triggers the compliance check.)

## Related skills

**In this package:** `quick-angle` — produces the positioning document this skill reads. `tracking-health` — verifies conversion tracking before launch. `ad-creative` — writes and iterates creative, including RSA headlines/descriptions. `landing-page-cro` — the page after the click. `campaign-analysis` — stop-loss/keep/scale verdicts after results are in; not this skill's job.

**Not shipped with this package:** `copywriting` — landing pages and other long-form copy.
