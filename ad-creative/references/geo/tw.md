# Taiwan (TW) module

Region-specific facts for `ad-creative` when `profile.md`'s `geo` list includes `TW`. Loaded by [`../grounded-inputs.md`](../grounded-inputs.md), [`../platform-specs.md`](../platform-specs.md), [`../copy-and-visual-production.md`](../copy-and-visual-production.md), and [`../static-ad-templates.md`](../static-ad-templates.md) wherever they point here. Nothing in this file overrides the GEO-agnostic gates those files define — it only supplies the market facts.

## Review and comment sources

| Input type | Taiwan source |
|---|---|
| Customer reviews | Shopee/MOMO product reviews, Google reviews, App Store/Google Play reviews |
| Forum / word-of-mouth | Dcard (beauty, tech, relationships, career boards especially), PTT boards |
| Ad comments | Public comments under Meta/Instagram ads |
| Unboxing / recommendation content | YouTube, Xiaohongshu (if the audience also spans the PRC market), IG Stories shares |

Private DMs and LINE Official Account private replies are excluded from every input source above by default — this is the package-wide rule in [`grounded-inputs.md`](../grounded-inputs.md)'s data-handling principles, not a TW-specific carve-out; noted here because LINE OA is the channel most likely to tempt an operator into treating a private reply as a public comment.

## LINE Ads Platform (LAP)

| Element | Limit | Note |
|---|---|---|
| Ad headline | ~20 characters recommended | Chinese text is dense; longer titles get truncated |
| Ad body | ~50 characters recommended | Varies slightly by placement (Timeline, LINE TODAY, chat feed) |
| Image placement | Depends on format (square, rectangle) | Preview the actual render in-platform before launch |

No stable, citable official page publishes these limits the way Google does — treat the numbers above as experience-based guidance, not a verified spec. **Always confirm live in LINE Ads Manager before every campaign**; this is a "verify before spend" fact under [`../../../AUTHORING.md`](../../../AUTHORING.md)'s freshness protocol regardless of when this file was last touched.

## Platform coverage

Paid Taiwan media spend concentrates on Google, Meta, LINE, and TikTok — this is why [`../platform-specs.md`](../platform-specs.md) covers exactly those four and skips LinkedIn/X (negligible TW ad spend on either, and neither has a GEO-localization angle to add regardless).

## LINE conversation flip-card ads

Format: a screenshot-style ad mimicking a LINE chat, used where the U.S. pack's source material used iMessage flip-cards (LINE's mobile penetration in Taiwan far exceeds iMessage's).

- LINE's green speech bubbles and "read" timestamp — this is the interface Taiwan audiences recognize instantly, not the blue iMessage bubble
- Script structure: screenshot hook → a friend asking "where did you get this / what app is this" → brand and offer reveal → closing card
- LINE sticker reactions (e.g., a surprise sticker) read as more native than text-only reactions
- **A staged conversation must be disclosed as illustrative, not presented as a real screenshot** — passing off a fabricated chat as genuine falls under Taiwan's Fair Trade Act rules on misleading advertising, the same claim-honesty rule [`../static-ad-templates.md`](../static-ad-templates.md) applies to every template

## Native-content observation accounts

Track Threads, Instagram, and Dcard's curated/featured boards for the same niche — their content rhythm and voice differ substantially from the TikTok/Reels-centric references most generic creative playbooks assume. Use these to answer "what does this audience watch when nobody's paying for reach" (see [`../creative-strategy-loop.md`](../creative-strategy-loop.md) step 1, signal 3).

## Compliance quick-pointer

Regulated-industry compliance (medical, aesthetic medicine, supplements, cosmetics, pharma, finance, gaming) is owned by the `ads` skill's own TW module — see [`../../../ads/references/geo/tw.md`](../../../ads/references/geo/tw.md), mandatory-load per `SKILL.md`. Two reminders specific to creative production, not duplicating that module:

- **Comparative and superlative claims** ("best," "industry-leading," "#1") draw Fair Trade Act scrutiny for unsubstantiated advertising — every comparative claim needs the `E`-class evidence [`grounded-inputs.md`](../grounded-inputs.md) requires regardless of geography; this note just names the TW legal hook.
- **Before/after claims** in health, finance, and beauty categories are separately regulated — route to the `ads` module above before shipping any Before/After template ([`../static-ad-templates.md`](../static-ad-templates.md) template 6).
