# Static ad template library

15 structural templates for static (image) ads. Each is a layout frame with defined fields — the structure is already proven, what you fill in is the brand.

Use this library when producing static concepts at scale (Meta, Instagram, LinkedIn, display network). **Rotate across every template that has assets available — don't cluster on 2-3 easy ones.** Template diversity is angle diversity; the winner usually isn't the one you'd instinctively reach for.

## Eligibility gate (run before producing — decides which templates this batch can use)

**"Cover all 15 templates" is a capacity-allocation target, not an obligation, and it never outranks compliance.** Several templates are gated not by how well the copy is written but by **whether the brand actually holds the asset** — a new brand with no real reviews, no authorized testimonial, no press coverage simply has no legal way to fill those templates. Forcing all 15 only produces fabricated reviews, unauthorized testimonials, or an uncovered media logo — that's misleading advertising and infringement, not a capacity problem.

Before producing a batch, check assets item by item — **an ineligible template is skipped, never patched with fabricated or unauthorized content**:

| Template | Asset required | Registry row needed | If missing |
|---|---|---|---|
| 4. Review card | A real review **+** subject-auditable verbatim-quote authorization | `review-*`/`D`/`authorized_verbatim`, authorization field non-blank | Skip |
| 5. Testimonial stack | Three real testimonials **+** subject authorization (name/photo use) | One row per testimonial (as above) + one `testimonial-*`/`D`/`authorized_verbatim` row per portrait | Skip (can't substitute an "anonymous testimonial card" — see the template's own note for why) |
| 10. Press mention | Real coverage **+** media logo usage rights | Coverage as `mediareport-*`/`F`/`public_cited` (`attribution` non-blank); **the logo element is a third-party visual, always `blocked_needs_permission` in this package — there's no registration path that passes it** | Skip (the logo element failing is this package's own capability boundary, not a batch-specific exception — third-party visual licensing is a separate scope) |
| 3. Stat callout | A real, substantiable number (case study, product analysis, survey) | `casestudy-*`/`E`/matching license, or `positioning-*`/`E` (see [`grounded-inputs.md`](grounded-inputs.md)'s "Positioning file as source") | Skip |
| 14. Competitor callout | A substantiable concrete difference **+** the platform allows naming competitors | `casestudy-*` or `mediareport-*`/**`E`** (`A` can't support a competitive comparison), or `positioning-*`/`E` | Skip |
| 8. Founder message / 15. Origin story | A real founder/founding story | `productfact-*` or `visual-*`/`A`/`brand_owned` (including the founder's portrait) | Skip |
| Everything else (1, 2, 6, 7, 9, 11, 12, 13) | Product facts and internal voice research suffice | `productfact-*`/`A`/`brand_owned` (+ visuals, each their own row) | Usually available |

**"Has the asset" and "resolves in the registry" are the same fact seen two ways**: the right column above isn't extra paperwork, it's how this gate actually gets checked — no matching row in `inputs/SOURCES.md` means no asset, and the template is skipped. See [`grounded-inputs.md`](grounded-inputs.md)'s Source registry section.

**No registry (conversation-fact path) runs this same gate**: it checks "what class of qualifying source does this batch actually have," not which path is in use. The only class with default coverage is what the user said in conversation (`usersaid-*`/`A`/`brand_owned`, see [`grounded-inputs.md`](grounded-inputs.md)'s Conversation-fact path) — resolving against the conversation fact list counts as "has the asset." **When the batch also has a `positioning.md` at `evidence_level: sourced` with a claim registered as `positioning-*`** (see Positioning file as source), that source participates in the gate at its own class (`A` or `E`), not limited to "conversation-fact path only gets class A." Reviews, testimonials, media logos (`B`/`D`/`F`) have no conversation-fact-path equivalent — templates 4, 5, 10 are always skipped there; templates 3 and 14 needing `E` check for a `positioning-*`/`E` source specifically. The gate itself doesn't loosen, only what it checks against changes.

**Log every skip**: the batch's `INDEX.md` lists unused templates, the reason, and what asset would unblock them (e.g., "templates 4, 5 skipped: no reviewer authorization yet; revisit once obtained"). This tells a reviewer why coverage isn't 15/15, and turns "go get authorization" into a tracked item instead of a silent gap.

**Redistributing skipped quota (capped, not unconditional)**: shift a skipped template's quota to the ones that passed (e.g., 3-4 each → 4-5 each after skipping 3), but **the per-template cap is 6 variations regardless**. Hitting the cap means cutting the total honestly, noted in `INDEX.md` ("actual N, below the requested M, because only X templates passed the gate"). **Don't force a single template to 8-10 variations to hit a round number** — the extra ones are the same angle in different words; the ceiling on concept count is angle count, not layout count.

**Whether to produce the batch at all is a separate, higher-level call, not this table's job**: this gate decides which templates are usable; whether to produce at all — and the batch cap — is [`grounded-inputs.md`](grounded-inputs.md)'s "Evidence classes" section, which defines the one hard stop (no product facts at all) and the degraded-batch mode (product facts only, no customer voice or performance signal: cap = eligible templates × 3). The two files never give conflicting instructions for the same case: a new brand with zero reviews, zero authorization, zero coverage runs a degraded batch, skips 4/5/10 and similar, produces under 50 with the reason logged — never "stop" and never "produce 50 anyway."

## How to use this library

1. **Ground it first**: before producing anything, read the input library (winning ads, reviews, comments, brand voice doc) — see [`grounded-inputs.md`](grounded-inputs.md).
2. **Run the eligibility gate, then rotate templates**: spread a batch of N concepts across **templates that passed the gate** (50 concepts, 15/15 passing → 3-4 variations per template).
3. **Fill fields from the library**: every version's copy must trace back to a real evidence class, tagged with the opaque source triple `source_id/evidence_class/source_license` and product-layer `publish_status` (see Production rules, below). **Traceable sources aren't limited to reviews/winning ads/comments — product facts (class A) are equally valid**, which is exactly what makes A-only degraded batches legitimate. **A-only's limit isn't "no numbers," it's who the number is about**: a product doc's own spec numbers ("5-minute setup," "10-year warranty," "30 stores nationwide") hold up on `A` (with no registry, the source is the user's conversational self-report, `usersaid-*`, still class `A`, but goes on the pre-launch "verify before shipping" list — see [`grounded-inputs.md`](grounded-inputs.md)'s Conversation-fact path). **Outcome numbers, social proof, market position, competitive comparisons** ("saves 10 hours a week," "3x faster," "10,000+ sold," "the only one in the industry") **need `E`**, never A-only. Full mapping in [`grounded-inputs.md`](grounded-inputs.md)'s `evidence_class` table.
4. **Write concrete visual descriptions**: specific enough that a designer or an image-generation tool doesn't have to guess.

## Production rules

- Every version includes: **template name, headline copy, body copy, visual description**, plus the fields [`grounded-inputs.md`](grounded-inputs.md)'s Provenance schema defines — source layer `source_id`/`evidence_class`/`source_license` (triple, multiple rows for multiple sources) + product layer `publish_status`.
- **Headline and body are separate assets, each with its own provenance, never shared** — e.g. a headline from product fact, body using review-derived voice:

  ```
  Headline  src: productfact-20260729-001/A/brand_owned      publish_status: publishable_rewrite
  Body      src: review-20260715-014/B/research_only         publish_status: publishable_rewrite
  ```

  Collapsing these into one shared record is the most common failure (one field has a review source, the whole version reads as grounded). **As many records as there are independently-publishable text elements in the template** — a review card's quote, a stat callout's number line, a CTA line all count separately.
- **Sources are always written as opaque `source_id`s — never the original text, handle, or post URL in the output**: the same rule as [`grounded-inputs.md`](grounded-inputs.md)'s data-handling principles and `creative-strategy-loop.md`, shared across every mode, no exceptions. Applies everywhere: each concept file, `INDEX.md`, any list handed to a client or external reviewer.
  - Suggested format: `type-date-serial`, e.g. `review-20260715-014`, `comment-20260718-003`, `winnerad-20260620-002`.
  - **`source_license` describes how that source may be used** (`brand_owned`/`research_only`/`authorized_verbatim`/`public_cited` — no dedicated value for third-party visuals: stock photos, third-party logos, non-brand-owned photos are always `blocked_needs_permission`, see [`grounded-inputs.md`](grounded-inputs.md)'s Third-party visuals); **`publish_status` is whether this finished asset may ship** (`publishable_rewrite`/`publishable_verbatim`/`blocked_*`). Verbatim templates (4, 5) need `authorized_verbatim` on the source side and `publishable_verbatim` on the product side — both have to line up.
  - **The `source_id` ↔ original content mapping stays in a controlled location** (under `inputs/`, access-restricted per [`grounded-inputs.md`](grounded-inputs.md)'s Access control), never in `outputs/`, version control, or a delivered concept. Verbatim source text is itself searchable back to the original poster — writing it into `outputs/` defeats de-identification.
- No `source_id` → don't produce that version. No fabricated claims, numbers, or testimonials.
- **"Close to the customer's real words" and "copy-pasted verbatim" are different things — every mention of "verbatim" or "original wording" in this file means the former, not the latter**: the default is extracting the pain point, the turn of phrase, the logic from a review and rewriting it in your own words, matching how the customer actually talks — not lifting a whole sentence as copy. Genuinely presenting a review's original or near-original text (especially templates 4 and 5, which display a review as a named/identifiable testimonial) needs [`grounded-inputs.md`](grounded-inputs.md)'s "named external testimonial / verbatim quoting" rule: **no auditable subject authorization means no verbatim, near-verbatim, or phrasing specific enough to be traced back to the original poster** — a public review isn't authorization to use it as paid-ad testimonial, and this rule outranks anything in this file suggesting verbatim beats rewritten.
- Match the brand voice document, not a generic direct-response tone.
- Real names, real numbers, real quotes only — fabricated social proof is a compliance and trust problem; named or identifiable quotes still need authorization confirmed, "it's true" isn't enough on its own.

---

## The 15 templates

### 1. Headline statement

A bold single-line claim. A single hero product shot. Minimal background. The headline carries all the communication weight.

- **Structure**: one dominant line of text (60%+ of visual weight), product image, logo small in a corner
- **Copy field**: one claim concrete enough to stop the scroll
- **Retail/DTC example**: "The last probiotic you'll buy."
- **SaaS/service example**: "Close the books in 3 days, not 3 weeks."
- **Asset source**: your strongest winning-ad hook, or the benefit that appears most often in reviews

### 2. Us vs. them

Side-by-side comparison. Competitor or "the old way" on the left (grayscale), your product on the right (full color). 4-6 rows of comparison.

- **Structure**: two columns, checkmark/X per row, your side visually "alive"
- **Copy field**: every row is a real difference, not padding
- **Retail example**: "Their multivitamin: 13 ingredients. Ours: 60."
- **SaaS example**: "Spreadsheets: 6 hours a week. Us: 6 minutes."
- **Asset source**: reviews mentioning "switched from," or comments comparing you to a competitor

### 3. Stat callout

One dominant number filling 60% of the frame. Supporting context below.

- **Structure**: a giant number, one line of context, product or logo anchor
- **Copy field**: one real, defensible number — a substantiated measurement beats a superlative every time
- **Retail example**: "97% of users notice a difference within 14 days."
- **SaaS example**: "Each rep saves 11 hours a week."
- **Asset source**: case study, product analytics, or survey — never a fabricated number

### 4. Review card

A five-star testimonial styled as a review screenshot. Reviewer name, rating, date.

- **Structure**: mirrors a real review interface (your buyers' e-commerce platform's own review layout, Google reviews, App Store — match whichever platform your buyers actually see reviews on; region-specific platform examples in the applicable [`geo/<code>.md`](geo/tw.md) module)
- **Copy field**: a real review, quoted verbatim — this template's credibility comes from being genuinely verbatim
- **Asset source**: verbatim quote from `inputs/reviews/` — this template is by definition "named external testimonial / verbatim quoting," subject to [`grounded-inputs.md`](grounded-inputs.md)'s stricter rule: needs the reviewer's own authorization for ad use, a public review alone doesn't qualify

### 5. Testimonial stack

Three customer quotes stacked vertically, each with photo + name + one-line quote.

- **Structure**: three short rows; each one scannable in 2 seconds
- **Copy field**: the three quotes cover *different* concerns or benefits — not three variations on the same point
- **Compliance note**: like the review card, this template pairs a photo, a real name, and a quote — a "named external testimonial," subject to [`grounded-inputs.md`](grounded-inputs.md)'s stricter rule: no real photo or name without subject authorization, and no verbatim or near-verbatim quoting either. **"Remove the name, remove the photo" isn't a valid workaround** — the core issue is presenting it as something a specific person said, not whether a name is attached; an unnamed but verbatim quote still reads as a real testimonial to the audience and still needs authorization. Without authorization, don't reach for an "anonymous testimonial card" as a substitute
- **Asset source**: reviews — select for coverage, not just enthusiasm; without authorization, **the only substitute is falling back to internal voice research**, rewriting the pain-point/benefit logic into a general insight statement, subject to the N=1 rule below. Don't keep the "three quotes + photos" visual format — switch to a template that doesn't imply named quotes (numbered list, feature spotlight)

  **N=1 rule: one review supports "this happened," never a ratio, count, or consensus.** Take the review "this is my third repurchase":

  | Rewritten as | Allowed? | Why |
  |---|---|---|
  | "Many repeat customers say they're satisfied" / "Lots of customers repurchase" | **No** | Fabricates multi-person social proof from one person |
  | "**High repeat-purchase rate**" | **No** (a mistake a prior version of this file let through) | "Rate" is a statistic — the proportion of all customers who repurchase — one review computes no ratio. Dropping "customers" doesn't stop it being a social-proof claim, it just hides it better |
  | "High customer satisfaction," "great word of mouth," "everyone recommends it" | **No** | Same failure — an implied-consensus claim |
  | "A refill pack for repeat use" / "one-bottle-and-reorder option" | Yes | States a **product fact**, not a statistic about other people's behavior |
  | "Once it clicks, you'll want more" | Yes | A general value statement, no claim about how many people do this |

  Claims quantifying "many," "most," "high repeat rate," "X% of people" require a genuinely computed, auditable aggregate (e.g. "35% of 200 reviews mention repurchasing," with both numbers auditable). The same line applies to the aggregate itself — 3-out-of-200 doesn't get to read as "quite a few."

### 6. Before/After

Split-image with an arrow. A transformation frame — product result, workflow, or visual proof.

- **Structure**: two panels, an arrow or divider, minimal label text per state
- **Copy field**: label both states in the customer's own words ("dreading Sunday-night reports" → "reports generate themselves")
- **Retail example**: skin, energy, or space — the classic visual transformation
- **SaaS example**: a chaotic 6-tab workflow → one clean dashboard
- **Compliance note**: before/after claims are regulated in health, finance, and beauty categories — see [`geo/tw.md`](geo/tw.md) before shipping this template in a regulated category; **regulated-industry loading is fail-closed** — unable to load that module means output only an unaudited skeleton, per `SKILL.md`'s mandatory-load section
- **Asset source**: transformation language in reviews ("I used to X, now Y")

### 7. Problem/Solution

Pain point up top (text or image), product as the answer below.

- **Structure**: two zones — tension above, relief below
- **Copy field**: rewrite the pain point in the customer's own logic and phrasing (not lifted verbatim from a review), followed by the product's answer
- **Retail example**: "Still swallowing 6 supplements every morning?" → a one-scoop visual
- **SaaS example**: "Your CRM has no idea how the product's actually being used." → an integration screenshot
- **Asset source**: the most common pain-point phrasing in `inputs/reviews/` — this template's headline is usually a short rewrite, not a review sentence lifted whole; reusing one review's exact phrasing needs the same verbatim authorization check as the Production rules section above

### 8. Founder message

Handwritten-style or plain-text founder note. Conversational, personal tone.

- **Structure**: note-style layout, founder name/photo, no product glamour shots
- **Copy field**: "I built this because…" — an honest line, no marketing polish
- **Retail example**: "Hey, I built this because most 'healthy' snacks are just candy in disguise."
- **SaaS example**: "6 years running ops, this is the tool I always wished existed."
- **Asset source**: a real founding story — a fabricated one collapses this template entirely

### 9. Feature spotlight

Hero product shot centered, 4-6 callout boxes around it highlighting key components.

- **Structure**: center image, radial callouts, 3-6 words per callout
- **Copy field**: the ingredients/features buyers actually ask about — not your full feature list
- **Retail example**: product bottle with a callout per key ingredient and its effect
- **SaaS example**: dashboard screenshot with callouts on the 4 most-mentioned features in reviews
- **Asset source**: the features/ingredients that come up most often in reviews and comments

### 10. Press mention

"As seen in" with media logos and a one-line pull quote.

- **Structure**: logo row + a strong pull quote + product anchor
- **Copy field**: a real quote from real coverage
- **Retail example**: "The first genuinely new idea in this category in years." — [Publication]
- **Compliance note**: media logos are third-party visuals, always `blocked_needs_permission` in this package (see [`grounded-inputs.md`](grounded-inputs.md)'s Third-party visuals) — this template's logo element has no registration path that currently passes; skip
- **Asset source**: real media coverage, podcast, newsletter, or analyst mention

### 11. Lifestyle hero

Product in a real-use context. Minimal copy. Aspiration over pitch.

- **Structure**: one photo carries the whole message, at most a short line and logo
- **Copy field**: 5-8 words, identity-driven ("Mornings, handled.")
- **Retail example**: product on a kitchen counter, part of a daily routine
- **SaaS example**: the tool visible in a real work moment (standup, closing call, launch day)
- **Asset source**: visual patterns from winning ads; identity language from reviews

### 12. Numbered list

"5 reasons [audience] is switching to [brand]." Each point with an icon.

- **Structure**: numbered rows, icon + short line each, product anchor at bottom
- **Copy field**: each reason is a different angle — pain, outcome, proof, differentiation, price
- **Retail example**: "5 reasons runners are switching to [brand] this year"
- **SaaS example**: "4 reasons finance teams are leaving [old system]"
- **Asset source**: the most common switching reasons across reviews

### 13. FAQ card

A common objection framed as a question, answered directly.

- **Structure**: prominent question, concise answer, product anchor
- **Copy field**: phrase the objection in *the customer's own words* — the "that's exactly my situation" recognition is the hook
- **Retail example**: "Safe for sensitive skin? Yes — here's why…"
- **SaaS example**: "Will this pass our security review? Meets relevant standards, supports SSO."
- **Asset source**: `inputs/comments/` — the objections people leave publicly under your ads

### 14. Competitor callout

Names a specific competitor (or the category default) and states the difference. Bold, but factually grounded.

- **Structure**: them vs. you, one clear axis of difference
- **Copy field**: a difference you can back with fact — comparative claims get scrutinized
- **Retail example**: "Same as [competitor], minus the 14 grams of sugar."
- **SaaS example**: "[Competitor] charges per seat. We don't."
- **Compliance note**: comparative advertising draws regulatory scrutiny in most markets — claims must be true and substantiable, and some platforms restrict naming competitors directly. Check platform policy and claim substantiation before launch; region-specific rules in the applicable [`geo/<code>.md`](geo/tw.md) module
- **Asset source**: competitor mentions in reviews and comments — customers name the alternative for you

### 15. Origin story

Founder photo with a "why we built this" narrative. Longer copy than most templates.

- **Structure**: portrait or team photo, 2-3 short paragraphs, product takes a back seat
- **Copy field**: the specific moment or frustration that led to founding — specificity is what makes it credible
- **Retail example**: "It took us 2 years and 47 formula versions to get this right, because…"
- **SaaS example**: "We were the user. The tool we needed didn't exist, so we built it."
- **Asset source**: a real story — better suited to warm/retargeting audiences than cold prospecting

---

## Per-concept output format

```markdown
## Concept [N]: [template name]

**Headline**: [headline copy]
  src: [source_id/evidence_class/source_license; semicolon-separate multiple sources]
  publish_status: [publishable_rewrite/publishable_verbatim]
  claim1="[the claim, as written, in this headline]" ← [source_id]/[evidence_class] @[locator]
  (list claim2, claim3… for more than one claim; **even a single claim needs `@locator`** — claim count doesn't change the check)
**Body**: [supporting copy, if the template uses it]
  src: [as above, this body's own source, not reused from the headline]
  publish_status: [...]
  claim1="[the claim in this body copy]" ← [source_id]/[evidence_class] @[locator]
**Visual**: [layout description, concrete enough for a designer or generation tool to build without guessing]
  asset_id: [visual element 1's asset_id]/[evidence_class]/[source_license]
  publish_status: [this visual element's own publish_status]
  asset_id: [visual element 2's asset_id]/[evidence_class]/[source_license]
  publish_status: [this visual element's own publish_status]
  (logo, portrait, product shot… **every visual element that ships gets its own complete record** — its own `asset_id/evidence_class/source_license` + its own `publish_status`, never one `publish_status` shared across multiple `asset_id`s; pure layout instructions — color blocks, whitespace, font size, alignment — don't need an asset_id, that's an instruction, not an asset; visual elements have no textual claim, so no `claimN`. **Visual assets only ever have two legal licenses, `brand_owned`/`authorized_verbatim` — no `attribution` needed**; stock photos, third-party logos, any non-brand-owned photo are always `blocked_needs_permission` and don't ship, see [`grounded-inputs.md`](grounded-inputs.md)'s Third-party visuals)
**Image prompt**: [prompt for an image-generation tool, if generating — see [`copy-and-visual-production.md`](copy-and-visual-production.md)'s generation tools section]
```

Filled example:

```markdown
## Concept 7: Stat callout

**Headline**: Reports generate themselves — 5-minute setup
  src: productfact-20260729-001/A/brand_owned
  publish_status: publishable_rewrite
  claim1="5-minute setup" ← productfact-20260729-001/A @§3 setup flow
**Body**: Marketing teams save an average of 10 hours a week after adopting
  src: casestudy-20260701-002/E/public_cited
  publish_status: publishable_rewrite
  attribution: Source: "2026 Marketing Team Hours Survey," OO Research Consulting, July 2026
  claim1="save an average of 10 hours a week" ← casestudy-20260701-002/E @p.4 para.2
**Visual**: dark background, product UI screenshot left, large numerals right, case-study source line along the bottom edge
  asset_id: visual-20260712-003/A/brand_owned
  publish_status: publishable_rewrite
```

(The headline's "5-minute setup" is a product spec number, `A` holds it. The body's "10 hours a week" is an outcome number, needs `E` — different source, different class, so two separate records. The body's source is `public_cited`, so it carries a publishable `attribution` line. The visual has one element: a brand-owned product screenshot, registered `visual-*`/`A`/`brand_owned`, no `attribution` needed. **This concept originally planned a stock background image, but third-party visuals are always `blocked_needs_permission`** (see [`grounded-inputs.md`](grounded-inputs.md)'s Third-party visuals) — that element doesn't ship; delivery notes "this concept's planned background image was from a third-party stock library, which this package can't clear — substitute a brand-original asset, or confirm the asset's copyright has actually been transferred (not just licensed) if that's the case." The visual has no textual claim, so no `claimN`. Every text asset's `claimN` points to its position in the source — `@locator` — for the pre-output claim-level check; it isn't optional.)

- **A concept missing any field (including each claim's `claimN`/`@locator`) doesn't ship** — list it under "these concepts are missing source attribution, needed before delivery."
- **A concept whose `source_id`/`asset_id` doesn't resolve in `inputs/SOURCES.md`, or whose fields don't match the registered row, doesn't ship** — matching format isn't the same as the source existing; see [`grounded-inputs.md`](grounded-inputs.md)'s Source registry section for the full resolution checks (resolves, unique, fields match, required proof in place, full hash re-check — text and visual assets both run these five; text assets additionally run claim-level check, #6). **No registry**: resolve against the conversation fact list instead (`usersaid-*`, see [`grounded-inputs.md`](grounded-inputs.md)'s Conversation-fact path) — same "unresolvable means don't ship" rule.
- **A concept with `publish_status: blocked_*` doesn't ship** — report what authorization or evidence class is missing instead.
- **A `public_cited` source with no `attribution` doesn't ship either** — that license's condition is showing attribution; unable to show it means the usage right was never established.

**Verbatim quotes only appear in output after passing the verbatim-authorization gate**: only the lines where `source_license: authorized_verbatim` *and* the product layer is `publishable_verbatim` (templates 4, 5, see How to use this library and Production rules, above) may show real quoted review text — that's the entire point of those two templates. **A registry entry that hasn't cleared the verbatim gate** (`research_only`, or `authorized_verbatim` still marked `publishable_rewrite` at the product layer, or anything `blocked_*`) **still can't appear in output** — rewrite it or drop it. **Reviewer handles, post URLs, or profile links never appear in output regardless of authorization status** — that's the data-handling rule (see [`grounded-inputs.md`](grounded-inputs.md)); it's a separate question from whether the copy itself may quote verbatim. Anyone tracing the original goes through `source_id` to the controlled mapping, not a leftover handle or link in the output.

For batch production, add an `INDEX.md` listing **per asset, not per concept** — template type, asset type (headline/body/visual), `src` or `asset_id` triple, `publish_status` (same rule: no original text or handles), and each claim's `claim`/`locator`, plus this batch's skipped templates and why (see Eligibility gate) — scannable by a reviewer in two minutes:

```markdown
| Concept | Template | Asset | src / asset_id | publish_status | claim / locator | attribution |
|---|---|---|---|---|---|---|
| 7 | Stat callout | Headline | productfact-20260729-001/A/brand_owned | publishable_rewrite | claim1 "5-minute setup" @§3 setup flow | — |
| 7 | Stat callout | Body | casestudy-20260701-002/E/public_cited | publishable_rewrite | claim1 "save 10 hours a week on average" @p.4 para.2 | "2026 Marketing Team Hours Survey," OO Research Consulting |
| 7 | Stat callout | Visual (product screenshot) | visual-20260712-003/A/brand_owned | publishable_rewrite | — | — |
```

**A concept with two or more visual elements gets one row per element in `INDEX.md`** — don't cram multiple `asset_id`s into one row's "src / asset_id" field, a reviewer can't tell which one was blocked. **Third-party visuals are always `blocked_needs_permission` and don't appear as a formal asset row** — note the omission in the skipped-templates/reasons area instead (e.g. "concept 7's planned background image was a third-party stock photo, omitted") so the reviewer knows what's missing and why, rather than assuming the concept is simply incomplete.

At the top of `INDEX.md`, one line of **source-resolution results**: registry path — "N assets this batch, resolved against `inputs/SOURCES.md`: all matched / M failed to resolve (blocked, not shipped)"; conversation-fact path — "N assets this batch, resolved against this conversation's fact list: all matched / M failed to resolve (blocked, not shipped); no source registry this batch, factual basis is the user's conversational self-report." A reviewer should be able to read this one line and know whether anything was fabricated, and how thick this batch's evidence base is.

## Batch allocation

A standard 50-concept batch: 3-4 variations per **gate-eligible** template. All 15 passing → full coverage. Any skipped → redistribute their quota to the rest (**cap: 6 per template**), and log actual coverage and total honestly in `INDEX.md` ("12/15, skipped 4, 5, 10 — no authorized testimonial or press coverage; actual output 50"). When too few templates pass and the 6-per-template cap gets hit, scale the total down honestly (e.g. only 8 templates available → cap 48) and note why. **Don't pad coverage or total count with fabricated/unauthorized material, or with near-duplicate variations** — coverage and total count are capacity-planning numbers, not something compliance or test value gets traded for.

Degraded batches (no customer voice or performance signal) have a stricter total cap — see [`grounded-inputs.md`](grounded-inputs.md)'s Evidence classes section.

**The 60/40 mix only adjusts on `campaign-analysis`'s structured conclusions, never on a glance at performance numbers the user pasted in** — that's the analysis-unit, comparability-check, sample-size-gate work described in `SKILL.md`'s scope boundary. When that skill delivers an actionable conclusion that certain templates consistently outperform, shift to 60% validated templates / 40% remaining coverage; **without that conclusion, keep the default mix, don't self-adjust.** Whatever the mix, never drop coverage to zero — sustained production is exactly what fights creative fatigue; a template judged "fatigued" this month may be the one that matters when scaling next month.
