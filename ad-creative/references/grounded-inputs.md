# Grounded inputs and data-handling principles

**Shared entry point for every mode.** Most AI-generated ads fail not on output quality but on ungrounded input: a concept with no evidence behind it reads as plausible ad copy, not copy that actually works for this brand.

## Input library structure

```
inputs/
  winning-ads/   10-20 screenshots of the best-performing ads from the last 90 days
  reviews/       50-100 customer reviews, saved as .md/.txt
  comments/      public comments under existing ads — objections, spontaneous praise, angles customers surface themselves
brand/           brand voice doc, color codes, logo, product assets
outputs/         batch output by date (outputs/YYYY-MM-DD/)
```

Region-specific review/comment sources: [`geo/<code>.md`](geo/tw.md) for the markets in `profile.md`'s `geo` list (TW: [`geo/tw.md`](geo/tw.md)).

**Why every input matters**: winning ads carry hooks and structures already proven for this brand; reviews carry the buyer's own language for pain points and payoffs — reference that language's logic and register when rewriting, don't paste it verbatim as copy (verbatim quoting needs authorization, see Data-handling below); comments are the most-overlooked, highest-value input — an objection ("does this work for X?") becomes an FAQ card directly, spontaneous praise surfaces angles you hadn't thought of.

Inputs go stale: refresh winning ads as new ones scale, refresh reviews/comments monthly.

## Two source paths — decided by file state, not by asking

| File state | Path | What it means |
|---|---|---|
| `inputs/SOURCES.md` exists and parses | **Registry path** | Every rule under Source registry below runs, no relaxation |
| `inputs/SOURCES.md` doesn't exist (typical: user just describes the product in conversation, no `inputs/` at all) | **Conversation-fact path** | The only usable source is what the user says about the product this session — class `A`, code `usersaid-*` |
| File exists but won't parse, or has a duplicate `source_id` | **Stop and report, neither path runs** | A broken registry gets fixed, not downgraded — otherwise "break the registry" becomes the easiest way to skip verification |

**`inputs/` has material but no `SOURCES.md`**: take the conversation-fact path; that material isn't usable this run (unregistered material isn't a source) — tell the user "the reviews/winning ads under `inputs/` weren't used; register them first to use them."

Both paths hold the same floor: no fabricated sources, no fabricated numbers, no evidence-class upgrades, full provenance on every asset before it ships. What changes is only how "the user's own product claim" gets a source code and a limit, instead of having nowhere to go.

## Evidence classes and what to do when material is missing

| Class | Source | Missing it means |
|---|---|---|
| **A. Product facts** | Brand's own spec, ingredients, features, price, service — registered product docs (`productfact-*`), `.agents/profile.md`'s own Brand/Main Products/Competitors sections (`productfact-*`, see note below), or the user's own statement this conversation (`usersaid-*`, weakest sub-type of A, see Conversation-fact path) | Nothing can be written — **the only hard stop condition** |
| **B. Customer language** | `inputs/reviews/`, `inputs/comments/` (register for voice, not verbatim) | Copy falls back to generic "sounds like an ad" phrasing, angle sourcing narrows sharply |
| **C. Existing performance signal** | `inputs/winning-ads/` (hooks/structures this brand already proved) | Nothing validated to extend from, every concept is an untested hypothesis |
| **D. Authorized verbatim testimonial** | Real review + auditable subject authorization | Review-card and testimonial-stack templates can't run |
| **E. Substantiable numbers** | Case studies, product analysis, survey results | Stat-callout and competitor-callout templates can't run |
| **F. Real media coverage** | Actually covered you, and logo-usage terms permit it | Press-mention template can't run |

**`.agents/profile.md` as a source**: `profile.md` ([`../../contracts/profile-v1.md`](../../contracts/profile-v1.md)) is a standing, already-confirmed product-fact document — its Brand/Main Products/Competitors sections cite as `productfact-<YYYYMMDD>-<NNN>` (date is this run's date), locator pointing at the section (`@profile.md#Main Products`), on either source path, without a separate `inputs/SOURCES.md` row — the file itself is the confirmed record, the same way the onboarding intake already established it. Sections it doesn't cover (Margin Basis, Target CPA, Calibrated Thresholds) aren't ad-facing product facts and don't route through this note.

**Entry rule**: only text-based product-fact sources (`productfact-*`/`usersaid-*`) count as A — a product photo alone answers nothing about what the product is or does; third-party visual assets (stock photos, third-party logos) never count toward any `evidence_class` at all (see Visual asset provenance, below).

1. **No A → stop**, ask the user for product information. This is the only "produce nothing" case (a missing registry isn't this — that's a path switch, see above).
2. **A present, B and C both empty** (new brand, or the user only described the product in conversation) → **degraded batch, not a stop and not business-as-usual**:
   - Tag the top of `INDEX.md`: `Basis: degraded (product facts only, no customer language or performance signal)` — conversation-fact path: `Basis: degraded (self-reported product facts only, no source registry, no customer language or performance signal)`
   - **Batch cap = (templates passing the eligibility gate) × 3**, not a fixed 50 — the ceiling on concept count is the number of real angles available, not the number of template slots; forcing 50 out of one angle in ten layouts is padding, the same failure as fabrication in a different shape
   - Disclose: "produced without customer-language input, treat as an untested hypothesis; rerun once you have a few performing ads or 50-100 reviews"
3. **A present, and B or C has material → normal batch**, standard count per the user's ask, still gated per template.
4. **D/E/F only gate individual templates**, they never block whether the batch runs at all (gate table lives in [`static-ad-templates.md`](static-ad-templates.md)).

**Per-template cap is 6 variations regardless of batch type.** When skipped-template quota gets redistributed to eligible templates and that hits the cap, cut the total and say so in `INDEX.md` ("actual N, below the requested M, because only X templates passed the gate at 6 each") — never force past the cap to hit a round number; the last few of an over-stuffed template are near-duplicates that test nothing.

## Data-handling principles (data minimization, mandatory)

- **Collect only public, purpose-limited content the user has rights to use.** Public reviews and public ad comments qualify; **private messages and private one-to-one feedback on any channel are excluded by default** (region-specific channels most likely to tempt a misread as "public" are named in `geo/<code>.md`), unless the subject has explicitly consented to marketing use.
- **"Publicly visible" ≠ "usable as paid-ad testimonial"** — two different things:
  - **Internal voice research (lower risk)**: mining reviews for how this audience describes their problem, rewritten in your own words, unquoted, unattributed — this package's default use.
  - **Named external testimonial / verbatim-or-near-verbatim quoting (higher risk, needs separate authorization)**: presenting a review's original or near-original text as a named or identifiable customer's testimonial (named or not — distinctive enough phrasing plus a screenshot or avatar can still be identifiable) needs authorization beyond "they posted it publicly"; most platforms' review/comment ToS don't transfer re-use rights either.
- **De-identification isn't absolute**: stripping name/phone/email/account ID is baseline, but distinctive phrasing can still be searched back to the original post — genuine anonymization means rewriting the content, not just removing the name.
- **Sourcing always uses an opaque `source_id`, everywhere**: every persisted output (concept files, `INDEX.md`, hook matrix, briefs, roadmap, monthly retro, standard output, CSV) records only the four fields defined in Provenance schema below — never the original text, handle, or post URL.
  - Format: `type-date-serial` (`review-20260715-014`, `comment-20260718-003`, `winnerad-20260620-002`, `productfact-20260729-001`, `usersaid-20260730-001`).
  - **The `source_id` ↔ original-content mapping lives only in `inputs/`** (a controlled location) — never in `outputs/`, never in version control, never handed to a client or external reviewer.
  - **This applies to human-readable fields too**: a "based on: …" prose field may only carry the source type + `source_id` ("based on the official ToS, `productfact-20260729-004`"), never the original quote, handle, or URL — the point of the opaque code is exactly to make this field safe to hand over. A user-stated fact has its own code (`usersaid-*`); never write "the user said…" as a substitute — that phrase can't be traced back to a specific statement.
  - **These fields are fail-closed**: any output format missing `source_id` (visual assets: `asset_id`) / `evidence_class` / `source_license` / `publish_status` doesn't get that row — report "this version is missing source attribution, needed before delivery" instead. A `public_cited` source additionally needs `attribution`. Every claim additionally needs `@locator`.
  - **The only URL that belongs in a deliverable is the ad's own destination URL** (RSA final URL, sitelink, landing page) — brand-owned, no PII, no query string or fragment. That's a functional field, not source attribution; don't conflate the two.

## Source registry (`inputs/SOURCES.md`) — `source_id` must resolve, matching format isn't enough

**Format-only checking can't stop fabrication.** Producing a plausible-looking `productfact-20260729-001/A/brand_owned` string costs nothing; if verification stops at "the four fields are present and well-formed," provenance is theater. **`source_id` must point at something that genuinely exists and was registered before this run** — the registry path points into files registered under `inputs/`, the conversation-fact path points into a fact list the user has already reviewed (see below). Both share the property that the source was on the table before output happened, not produced on the spot to justify it.

**Minimum viable approach: one controlled file, `inputs/SOURCES.md`**, one row per source:

| Field | Notes |
|---|---|
| `source_id` | Unique key, format below. No duplicates in the registry. |
| `evidence_class` | `A`-`F`, set at registration. |
| `source_license` | `brand_owned` / `research_only` / `authorized_verbatim` / `public_cited` — no dedicated value for third-party visuals; those are always `blocked_needs_permission` (see Visual asset provenance). |
| Source type | review / comment / winning ad / product doc / case study / media coverage / authorized testimonial / logo / visual asset. |
| File path | Relative path under `inputs/` where this source actually lives. Blank doesn't count as registered. Sole exception: `positioning-*` records `.agents/positioning.md` (see Positioning file as source). |
| Content hash | **Full** SHA-256 of the file's content at registration time (64 lowercase hex chars, never truncated). Detects post-registration tampering (see Claim-level check). Lowercase both sides before comparing the full 64 chars; malformed (wrong length, non-hex), blank, or non-matching after lowercasing → block (`blocked_unsupported_claim`, or a full stop — see "Source file untouched," below). |
| Registration date | `YYYY-MM-DD`. |
| Authorization proof | Required for `authorized_verbatim`: file path or record ID of the authorization. **Testimonial photos additionally need both** a portrait-use consent **and** proof the photo's copyright itself belongs to the brand (not an outside photographer who never transferred it) — missing either counts as blank, see Testimonial photos, below. |
| `attribution` | Required for `public_cited`: the citable, publishable source string (e.g., "National statistics agency, March 2026 wholesale/retail figures") — public information, the only source description allowed to ship with the deliverable. |
| License terms | Required for `public_cited`: an auditable pointer to the terms (archived terms page, license agreement ID, named license plan). "Findable online" isn't terms. |
| Citable scope | Required for `public_cited`, exactly two legal values: `verbatim_ok:<scope>` (terms explicitly permit verbatim reproduction — scope states the word/paragraph limit and any non-commercial restriction) or `rewrite_only` (terms explicitly permit commercial ad use but not verbatim reproduction). Unclear terms, terms that don't mention advertising/commercial use, or terms limited to non-commercial sharing → neither value is legal, leave blank (fails "required proof in place," below). **Don't fill `rewrite_only` as a safe default when terms are unclear** — that disguises "unclear license" as "confirmed rewrite-only." |

**`source_id` format (strict)**: `<type-code>-<YYYYMMDD>-<NNN>`

- Type code is one of: `review` / `comment` / `winnerad` / `productfact` / `casestudy` / `mediareport` / `testimonial` / `logo` / `visual` / `usersaid` / `positioning`. No invented codes. `usersaid` is conversation-fact-path only, never registered in `inputs/SOURCES.md` (a registry-path project uses `productfact` for the same fact). `positioning` is legal on either path, only when `evidence_level` is exactly `sourced` (see Positioning file as source).
- `YYYYMMDD` is the **registration date**, not the production date; `NNN` is that day's three-digit serial for that type.
- Unique across the whole registry — collisions take the next available number, never overwrite.

**Registration is its own step, never a silent side effect of writing copy.** Adding a row: stop production, say "this claim needs a new source"; list the proposed row (with file path) for the user to confirm; only after confirmation and after the file genuinely exists under `inputs/` does it get read, hashed, and registered — then production resumes. This is what makes fabrication expensive: from "type a string" to "claim a file exists in front of the user," and the user can check.

### Output-time resolution (fail-closed, six checks per triple)

Run for every triple on every asset (registry path — the conversation-fact path runs the equivalent four checks, see below):

1. **Resolves**: `source_id` is a row in the registry. Not found → `blocked_unsupported_claim`.
2. **Unique**: only one row uses this `source_id`. Duplicate → stop, don't ship the batch (the registry itself is broken).
3. **Fields match**: the `evidence_class`/`source_license` in the output match the registry row verbatim — output never overwrites or "upgrades" (writing a registered `B` review as `E` is the classic cheat). Mismatch → `blocked_unsupported_claim`.
4. **Required proof in place**: `authorized_verbatim` needs a non-blank authorization field (testimonial photos need both conditions above); `public_cited` needs non-blank `attribution`, license terms, and a citable scope that's one of the two legal values. Any gap → `blocked_needs_permission`. A `source_license` value outside the four legal ones fails this check outright.
5. **Source file untouched**: re-read the file, recompute the full SHA-256, compare lowercase-to-lowercase against the registered hash. Unreadable → `blocked_unsupported_claim`; malformed or blank registered hash → treat as failed, stop the batch; mismatch after lowercasing → **stop the batch**, report "`<source_id>`'s source file was modified after registration, every claim citing it needs re-verification and re-registration." **`positioning-*` is the sole exception** — a mismatch there runs the re-verify/whitelist flow in Positioning file as source, not a full stop.
6. **The claim actually appears in the source** (next section).

### Claim-level check: a resolvable ID isn't the same as a supported claim

The first five checks catch "citing a source that doesn't exist," not "citing a real but unrelated source." Attaching a genuine `productfact-20260729-001` (warranty terms) under "saves an average of 10 hours" passes all five — only the sixth catches it.

**Recorded at registration: a `claim locator`** (kept in the claim's own provenance record, not the registry — one source can support multiple distinct claims):

| Source type | Locator form |
|---|---|
| `.md`/`.txt`/archived webpage | Paragraph number or heading (`§3 Warranty scope`, `para:12`) |
| PDF/deck | Page + paragraph (`p.4 para.2`) |
| Table/CSV/stats | Column + row key (`col:avg_handling_time, row:2026Q1`) |
| Screenshot (winning ad, review) | The labeled field on the screenshot (`primary_text`, `review_body`), with a full verbatim transcript kept as `.md` in `inputs/` |
| Conversation self-report (`usersaid-*`) | The numbered line in the conversation fact list (`@usersaid-20260730-001`) |

**Output-time check (per claim, not per asset)**: open the source at that locator, read that passage, ask — does it support the claim's literal meaning? (numbers must match — the claim says 3 days, the source says 3-5 business days is a mismatch; a comparative needs the comparison target; a ratio needs numerator and denominator). Unresolvable locator, unrelated content, or "same gist, different number/range" → `blocked_unsupported_claim`, don't ship, report "claim '…' isn't supported at `<source_id>`'s `<locator>`." **A blank `locator` fails this check** — "that's the gist of the whole document" doesn't count; either point to a specific location or narrow the claim to one that can be pointed to. This can't be answered from memory — it means re-opening the source at that location, not recalling that the document said something like that; a source that can't be read at all (paper-only, inaccessible location) blocks any claim depending on it.

**No registry, or unreadable**:
- **`inputs/SOURCES.md` doesn't exist** → conversation-fact path (see below). Not "produce as usual," not "build a registry on the user's behalf" — the only available class is what the user says about the product this conversation.
- **File exists but won't parse, or has a duplicate `source_id`** → **stop and report**, "`inputs/SOURCES.md` is unreadable or malformed, can't verify any source," help fix it. Never falls back to the conversation-fact path — that would make "corrupt the registry" the easy way out.

**Never**: "produce first, register later" — by the time it's registered, nobody remembers what actually backed that sentence at the time. Same for the conversation-fact path: the fact list is finalized and confirmed before production starts, not reconstructed mid-batch from a vague memory of what the user said.

**The registry itself is controlled data**: it carries file paths into potentially non-de-identified content, so it stays out of `outputs/`, version control, and client deliverables, same as the rest of `inputs/`. Only `source_id` (and `public_cited`'s `attribution`) shows up in a deliverable.

## Conversation-fact path: using what the user says when there's no registry

No registry doesn't mean no source. "We run an online ordering system, live the day we launch" is a **brand's own statement about its own product** — unverified, but not fabricated either; those are different things. This path treats it as a source with a code, a class, and a limit — not silence, not a verified fact.

**Code**: `usersaid-<YYYYMMDD>-<NNN>`, date is this conversation's date, `NNN` is this conversation's fact serial.

**Fixed binding, no upgrades**: `usersaid-*` only ever pairs with `evidence_class: A` and `source_license: brand_owned`. Writing it as `B`-`F` is fabrication — "the user said our repeat-purchase rate is 80%" doesn't become an `E`-class substantiated number by virtue of being said; that's `blocked_unsupported_claim`.

### Fact list replaces the registry (same rigor, not a lighter version)

A registry blocks fabrication by making the user confirm a file exists. Conversation has no file — the equivalent is reading the user's own statements back to them:

1. **List it**: before production, list a conversation fact list in the reply (in the reply, not written to `outputs/`) — one line each: `usersaid-20260730-001 | stated by the user this conversation | can accept orders same-day as launch`.
2. **Only what they actually said**: nothing inferred, assumed from the product category, or filled in from "products like this usually…" — that's the same fabrication as a fake registry row, no more excusable for happening in conversation.
3. **Confirm**: ask "does this list match what you told me — anything wrong or missing?" and wait before producing. The user can see on the spot whether they said it — the same cost structure that makes the registry path work.
4. **Per-claim check**: each output claim's `@locator` names the fact-list line number (`@usersaid-20260730-001`); checking means returning to that line and asking whether it supports the claim's literal meaning — same standard as Claim-level check above.

| Registry path's six checks | Conversation-fact equivalent |
|---|---|
| 1 Resolves | List has that entry number; not found → `blocked_unsupported_claim` |
| 2 Unique | Serial unique this conversation; collision takes next number |
| 3 Fields match | `usersaid-*` is fixed `A`/`brand_owned`; anything else doesn't match |
| 4 Required proof | A-class needs no authorization proof; `D`/`F` classes needing authorization have no equivalent on this path — the templates that need them get skipped |
| 5 Source untouched | List is final once the user confirms it; no rewrite mid-batch — a real addition means listing again for reconfirmation |
| 6 Claim in source | The per-claim check above |

The fact list is controlled data like the registry — never written to `outputs/`; only `source_id` appears there.

### What this path can and can't write

Class-A limits apply as-is (see Provenance schema's evidence-class table below); the only addition is a "verify before launch" obligation. This table covers `usersaid-*` sources specifically — a batch that also has a qualifying `positioning-*` source (see next section) follows that source's own class instead.

| What the user says in conversation | Usable in creative? |
|---|---|
| Product/service description, features, plans, fit, price | Yes |
| Product's own spec numbers ("orders same-day," "10-year warranty," "30 stores nationwide") | Yes, but **must go on the "verify before launch" list at delivery** — this becomes a consumer-facing promise on the strength of one spoken line |
| Outcome numbers ("saved a customer 10 hours," "revenue up 30%") | **No.** Needs `E`. Rewrite without the number, or drop the field |
| Social proof ("lots of stores use it," "high repeat rate," "thousands of customers") | **No.** Needs `E` |
| Competitive comparison ("cheaper than X," "only one in the industry") | **No.** Needs `E` |
| Named/identifiable testimonial, media logo | **No.** Needs `D`/`F` + matching authorization |
| Efficacy or health claims | **No** — same regulated-industry mandatory load as always, no exemption on this path |

### Required disclosure at delivery

- **Factual basis**: this batch's product facts come from what the user said this conversation, not verified against docs, testing, or a third party. Any claim also resting on `positioning-*` names which section of `.agents/positioning.md` backs it, and that it's an already-verified section.
- **What to verify before launch**: which claims use spec numbers, what evidence each needs (product doc, dashboard screenshot, test record), and which claims were rewritten or dropped for lack of `E`/`D`/`F`.
- **Upgrade path**: register product docs, reviews, and winning ads under `inputs/` to move to the registry path next time — that unlocks outcome numbers and social proof. When a batch already has `positioning-*`-backed `E` claims, another path is registering the underlying verified material (case study, survey, third-party report) directly, so future runs get full hash and claim-level checks instead of relying on the positioning document's say-so.

Batch size follows the degraded-batch rule (Evidence classes, above) — **the conversation-fact path is necessarily B-and-C-empty, there's no other case**: cap = eligible templates × 3. `INDEX.md`'s basis tag reflects whether `positioning-*` backs part of the batch — the two tags aren't interchangeable: `Basis: degraded (self-reported product facts only, no source registry, no customer language or performance signal)` when nothing else backs it, versus `Basis: degraded (self-reported product facts + positioning-verified claims, no source registry, no customer language or independent performance signal)` plus a list of which claims rely on `positioning-*` when at least one does — reusing the "self-reported only" tag when material actually backs some claims misleads the reviewer.

## Positioning file as source: `positioning-*` (only when `evidence_level` is exactly `sourced`)

`.agents/positioning.md` defaults to unverified user self-report, so it can't back a factual ad claim — `SKILL.md`'s "before you start" gate 5. **The sole exception**: frontmatter `evidence_level` exactly `sourced` (legal values and meaning per [`../../contracts/sister-product-compat.md`](../../contracts/sister-product-compat.md) — not redefined here) means every claim across the three sections has material backing. A document at that level can register as a source; without the code, its claims all fail the claim-level check regardless of how well-verified they actually are.

**Code**: `positioning-<YYYYMMDD>-<NNN>` — registration date (registry path) or this conversation's date (conversation-fact path), `NNN` the ordinary three-digit serial. **Different claims from the same document get different `source_id`s** — a registry row (and its `evidence_class`) covers exactly one claim; a spec-fact sentence and an outcome sentence from the same document are two rows (`positioning-20260730-001` for the spec claim, `-002` for the outcome claim), never one ID reused with the output silently switching its class.

**All five conditions required, one missing means unusable** (falls back to gate 5's default: rewrite the claim without numbers/comparatives, or skip the template and log why — never an error, never a stop):

1. The file is `.agents/positioning.md` itself — no other `.agents/` file qualifies.
2. `evidence_level` is exactly `sourced`. `mixed`/`assumed`/missing/unrecognized/contract file unreadable → unusable.
3. The claim sits in one of the four fixed sections or `## Research basis`, and is one `evidence_level` actually marks as verified — content elsewhere in the file doesn't ride along on this code.
4. The document passed `SKILL.md`'s gates 1-3 (schema, status, non-vacuous content). Failing those means "no positioning document" to begin with.
5. **No signal conflict**: `source` is a material-verification value (`material_analysis`/`mixed` only — not `user_self_report`/`user_confirmed`). `evidence_level: sourced` sitting alongside a non-material-verified `source` (typically after `quick-angle` does a field-level merge that resets `source` but leaves the older `evidence_level` untouched) means the fields describe two different points in time → treat as stale, code unusable, same fallback as condition 2.

**`evidence_class` follows what the claim is about**, mirroring gate 5's exception:

| Claim content | Registers as |
|---|---|
| Product spec, service content, feature description, the product's own numbers | `A` |
| Outcome numbers, competitive comparison, market position, a computable social-proof figure | `E` |
| Customer-voice register (`B`), named/identifiable verbatim testimonial (`D`), media coverage/logos (`F`) | **Unusable** — these need raw material and subject authorization a positioning document can't supply; skip the template as usual |

**`source_license` is judged claim-by-claim, never once for the whole document; the finished asset never gets `publishable_verbatim`** (a positioning file paraphrases the underlying material — the right to quote verbatim stays with that original source):

1. **The underlying source can be resolved, verified, and itself passes its own `source_license`'s fail-closed check** (registry path: registered in `inputs/SOURCES.md` with matching class/license, `public_cited` sources have all three required fields; conversation-fact path: the underlying source is separately listed in the fact list with equivalent authorization info confirmed by the user) → **register and cite that underlying source directly** (`casestudy-*`/`mediareport-*`/etc.), not `positioning-*` — a more precise, verifiable source supersedes this code.
2. **Plainly the brand's own product fact** (the fixed sections describing the brand's own spec/service/feature/price, phrased as "our product is…," not relaying an external finding) → `positioning-*`/`brand_owned`, can be `publishable_rewrite`.
3. **Everything else — including "the positioning file names a third-party source in prose, but there's no resolvable underlying source with license fields"** — a line reading "per XX Institute's 2026 statistics" is secondhand relay, not an auditable license chain; no underlying source means no `license terms`/`citable scope` to check. **This case is always `blocked_needs_permission`** — never relabel it `public_cited` off the positioning document's own attribution text; use it only as directional backing (rewrite without numbers/comparatives, or skip the template and log why).

This is a deliberately safety-first, durable design choice: `positioning-*` flows smoothly for brand-owned claims (case 2); third-party-sourced claims block without a verifiable license chain (case 3), regardless of whether the positioning file names an origin — `evidence_level: sourced` guarantees the claim has material backing, not that the underlying material's license chain is auditable; those are different guarantees. In practice, `A`-class claims (spec, own numbers) mostly land in case 2; `E`-class claims (outcome numbers, comparisons, social proof) are usually research findings and mostly land in case 3 — blocked absent the user separately registering the underlying source with its license fields (case 1).

`locator` points into the positioning document, same form as the `.md` row in the locator table above (`@§Why we win`, `@§Research basis para.2`). The check is unchanged — read that passage, ask whether it supports the claim's literal meaning. `evidence_level: sourced` lifts the default distrust; it doesn't waive the read-back.

**Registering the code**:
- **Registry path**: add a row to `inputs/SOURCES.md`, file path field is `.agents/positioning.md` — the sole exception to "file path must be under `inputs/`," because this is the project's own file, not third-party material carrying someone else's PII. Content hash as usual, **plus a `body hash` and a frontmatter snapshot** (see Hash-mismatch handling, next) — a mismatch doesn't trigger the ordinary "stop the batch," it runs the whitelist flow below instead.
- **Conversation-fact path**: list alongside `usersaid-*` entries: `positioning-20260730-001 | .agents/positioning.md (evidence_level: sourced) | §Why we win: [the claim]`, confirmed by the user like any other list entry. This registration form only supports case 2 above (the brand's own product fact) — a case-1 third-party claim needs its own separate fact-list entry for the underlying source, with the user-confirmed equivalent of `attribution`/citable scope; it can't ride on the `positioning-*` entry alone.

### Hash-mismatch handling (positioning-* only)

`.agents/positioning.md` is a file sister skills (`campaign-strategy`) legitimately keep writing to — writing `strategy_notes`, updating `generated_by` changes the whole-file hash without any registered claim's content having changed. Treating every such write as "content tampered with, stop the batch" would punish normal sister-skill operation. Instead:

**Registered alongside the content hash**: a **body hash** — full SHA-256 of everything after the frontmatter's closing delimiter (heading, fixed sections, sister-skill sections, any unrecognized addition — the entire remainder, nothing skipped), after canonicalizing to UTF-8, normalizing all line endings to `LF`, and stripping trailing whitespace from every line (leading/mid-line whitespace and blank lines untouched). Lowercase hex, same as the content hash. And a **frontmatter snapshot**: every current frontmatter field, one `<field>: <value>` per line sorted by field name, scalar values only — **any field whose value contains a newline, or isn't a scalar (nested/list), doesn't get serialized; a mismatch touching that field is automatically treated as non-whitelisted** (a multi-line value could otherwise be crafted to look like two separate fields in the flattened snapshot, defeating the whitelist comparison — rejecting it outright is simpler and safer than adding escaping rules).

On mismatch:

1. Recompute both the whole-file content hash and the body hash.
2. **Body hash differs → block outright, no re-verify, no re-registration.** Any change to the substantive content — a new sentence, an added qualifier, a whole new section — means this file's meaning may have shifted; "the sentence at the registered locator is still there verbatim" is no longer sufficient on its own, since a qualifier added elsewhere can invert meaning without touching that sentence. Report "the body of `.agents/positioning.md` has changed since registration, every claim from this source needs re-verification and re-registration"; this source is `blocked_needs_permission` until the user confirms.
3. **Body hash matches, only the whole-file hash differs** → the difference is confined to frontmatter. Regenerate the frontmatter snapshot and diff it line-by-line against the registered one to find which fields actually changed. (If no field differs but the whole-file hash still doesn't match, the difference is pure formatting noise the canonicalization didn't need to touch — re-register with the new hashes and move on; nothing to whitelist-check.)
4. **Check each changed field against the whitelist.** `evidence_level`, `source`, and `claim_verified_at` are never whitelisted — these three directly gate how much a claim can be trusted, so any change to them (even paired with a legitimate-looking newer date) blocks rather than auto-passes; this is what stops "hand-edit `assumed` to `sourced`" from riding through as a normal sister-skill update. Whitelisted fields are pure pointer/record metadata that don't affect any claim's credibility: `candidates_considered`, `research_notes`, `angles_considered`, `strategy_notes`, `origin_generated_by`, and the value of `generated_by` — the set `sister-product-compat.md` documents as fields sister skills routinely write.
5. **All changed fields whitelisted** → re-register this row with the new content hash, body hash, and frontmatter snapshot; note "`positioning-*` re-registered after a legitimate sister-skill frontmatter update, body unchanged, fields changed: [list]." Batch continues, nothing else affected.
6. **Any changed field isn't whitelisted** (including the three named above, or an unrecognized field) → block, don't auto-reregister, report "`.agents/positioning.md`'s frontmatter has a non-whitelisted change (`<field>`), needs user confirmation before re-registering."

This flow is `positioning-*`-only — every other source type (`productfact-*`/`review-*`/`casestudy-*`/etc.) still gets a full stop on any hash mismatch; those files were never supposed to change post-registration, while `positioning-*` is the one place this package explicitly expects an ongoing legitimate writer.

**State the basis at delivery**: name which section of the positioning document backs each `positioning-*`-sourced claim ("the 'hours saved per week' line is per `.agents/positioning.md`'s `## Research basis` section"), not just "per the positioning file."

**This package reads this field, never writes it.**

## Provenance schema: bound to each asset, not the batch

A batch of 15 headlines and 4 descriptions has 15+4 *different* evidence trails — collapsing them into one `source_id` is the most common failure: one field has a review behind it, so the whole batch reads as grounded, and every other field's numbers and comparisons ride along uninspected.

**Every independently publishable text asset** (one headline, one description, one line of primary text, one extra field) **gets its own provenance record**, in two layers — **except a purely angle-driven line that makes no factual claim at all** (a pure hook, a wordplay line, a CTA carrying no product fact): nothing there needs a source to check, so no provenance record applies. The moment a line states or implies anything checkable about the product, outcome, or comparison, it re-enters this schema at whatever evidence class that claim requires (see "`evidence_class` determines what an asset may say," below).

**Source layer — `source_id` / `evidence_class` / `source_license`, one record, multiple rows when multiple sources**

| Field | Value | Meaning |
|---|---|---|
| `source_id` | `type-date-serial` | Which piece of evidence this is. Required. |
| `evidence_class` | `A`/`B`/`C`/`D`/`E`/`F` | What class **this `source_id`** falls in (see Evidence classes above). Required. |
| `source_license` | see table below | How **this source** may be used. Required. |

**Product layer — `publish_status`, one value for the whole asset**

| Value | Meaning |
|---|---|
| `publishable_rewrite` | Rewritten copy, ships |
| `publishable_verbatim` | Contains verbatim/near-verbatim quoting, and every quoted source passes the compatibility matrix below, ships |
| `blocked_needs_permission` | Content is fine but the citation exceeds the source's license, or attribution can't be shown — don't ship, report what authorization is missing |
| `blocked_unsupported_claim` | A claim has no matching-class evidence behind it — don't ship, report what evidence class is missing |

`source_license` legal values (**describes how the source may be used, not whether the finished asset may ship**):

| Value | Applies to | Permitted use |
|---|---|---|
| `brand_owned` | Brand's own material: spec, site copy, own case data, founder story | Free use and rewrite, verbatim allowed |
| `research_only` | Public reviews, ad comments, competitor ads — voice/angle reference only | **Rewrite only**, never verbatim/near-verbatim, never attributed to a name |
| `authorized_verbatim` | A testimonial with auditable subject authorization (portrait photos need authorization covering the likeness, not just the text) | Verbatim allowed, cite the authorization record ID |
| `public_cited` | **Text/data** third-party sources that are publicly citable: official stats, public research reports, media coverage body text — **not for visual assets**, see Third-party visuals below | Citable, must attribute per the original terms, can't alter the number's meaning, and `citable scope` must pass the tightened definition in Source registry above |

**No dedicated license value for third-party visuals**: stock photos, third-party logos, any non-brand-owned photo — none of the four values apply; they never enter `source_license` at all, always `blocked_needs_permission` (see Third-party visuals below).

**Compatibility matrix — `publish_status` is derived from `source_license`, never self-assigned:**

| `source_license` | `publishable_rewrite`? | `publishable_verbatim`? | Extra condition |
|---|---|---|---|
| `brand_owned` | Yes | **Yes** — brand's own copy needs no one else's authorization to quote verbatim | None |
| `research_only` | Yes (**must be substantively rewritten**, not near-verbatim, not attributed) | No → `blocked_needs_permission` | Rewrite enough that it can't be searched back to the original post |
| `authorized_verbatim` | Yes | Yes | Registry row's authorization field is non-blank |
| `public_cited` | **Yes, conditionally**: only when `citable scope` is `rewrite_only` or `verbatim_ok:<scope>` — those values themselves mean "terms confirm commercial ad use." Blank or illegal scope → **not even rewrite is allowed**, straight to `blocked_needs_permission` | **Default No** — only when scope is `verbatim_ok:<scope>` and this asset's verbatim content falls inside that scope | All three fields present: `attribution` (ships with the deliverable), license terms, citable scope (one of the two legal values) |

Third-party visuals never enter this matrix — no path to either publish status, always `blocked_needs_permission` (see Third-party visuals).

**`publishable_verbatim` isn't reserved for `authorized_verbatim` alone — but it isn't "public + attributed" either.** The real test: *every verbatim span in this asset has an auditable record permitting verbatim use, source by source*:
- `brand_owned` → no one else's permission needed.
- `authorized_verbatim` → the registry's authorization field names the record.
- `public_cited` → "public and attributed" ≠ "cleared for verbatim reuse in paid advertising"; most official stats/research/media terms permit citation-with-attribution but restrict or ban verbatim reproduction in commercial ads (some explicitly ban wording that reads as endorsement). Only `verbatim_ok:<scope>`, with this asset's verbatim length/scope inside that range and use not excluded by the terms, permits verbatim — everything else is rewrite-only. **When the scope can't be judged, don't default to `publishable_rewrite` either** — an unclear license should have been left blank at registration, triggering `blocked_needs_permission` then, not patched here with an optimistic guess.
- `research_only` → verbatim never permitted.
- Third-party visuals → not applicable, always `blocked_needs_permission`.

**No "the model read the terms and judged it fine" option**: license interpretation happens at registration, written into `citable scope` with `license terms` cited, confirmed by the user. Production reads that field only, never interprets terms live.

**`attribution` is the one source-description field that ships**: `public_cited` sources need attribution shown, and the opaque `source_id` can't show it — so the registry stores a separate, publicly displayable `attribution` string, which travels with the asset at delivery. It's public information without PII, so it doesn't conflict with "never ship raw text or URLs" — because it describes a **public publication**, not an individual's post; private reviews and comments never use `public_cited`, so they never reach this field.

**Multiple sources take the strictest result**: an asset citing both `brand_owned` and `research_only` — if any verbatim span comes from the `research_only` source, the whole asset is `blocked_needs_permission`.

## Visual assets need their own provenance too

**Logos, testimonial photos, product shots, cutouts, fonts, background music are assets, not annotations on a "visual description."** A required-authorization media logo or a customer photo needing portrait consent has to have an auditable record somewhere in the deliverable — otherwise a designer works from the concept file with no way to know whether that logo is actually clear to use.

**Every visual element that ships gets its own record**, same fields as text assets, keyed `asset_id`:

```
Visual  asset_id: visual-20260712-003/A/brand_owned                 publish_status: publishable_rewrite
        asset_id: testimonial-20260710-002/D/authorized_verbatim    publish_status: publishable_verbatim
                  (portrait consent + copyright-transfer proof both on file, see Testimonial photos below)
```

**Each `asset_id` gets its own `publish_status`, never shared** — a concept using multiple visual elements records each independently; one shared status can't show which specific element got blocked.

- `asset_id` must resolve in `inputs/SOURCES.md` and pass the applicable output-time checks — same as text assets, minus check 6 (no textual claim to verify): resolves, unique, fields match, required proof in place, **source file untouched** (re-read, recompute the full SHA-256, lowercase-compare against the registered hash) — all five run, not just a format check; without #5, a swapped-out registered photo or graphic goes undetected.
- **Common mapping**: brand-owned product/lifestyle shots → `visual-*`/`A`/`brand_owned`; testimonial photos → `testimonial-*`/`D`/`authorized_verbatim` (see Testimonial photos below); **third-party stock, third-party logos (media badges, certification marks, partner-brand marks), any non-brand-owned photo → always `blocked_needs_permission`** (see Third-party visuals).
- **AI-generated images aren't "sourceless"**: register as `visual-*`/`A`/`brand_owned`, file path pointing at the generated file, note it's generated in the source type. But **a generated image resembling a real face, a real brand's mark, or real media layout is treated as needing authorization regardless** (`blocked_needs_permission`) — "it's AI-generated" doesn't bypass this.
- Pure layout instructions — color blocks, whitespace, font size — don't need an `asset_id`; the line is "could someone own the rights to this."
- Missing `asset_id`, mismatched fields, a failed hash re-check, or `blocked_*` status → that element doesn't ship; if the template needs it, skip the whole concept.

### Third-party visuals are always blocked

**Stock photography, third-party logos (media badges, certification marks, partner-brand marks), any non-brand-owned photo — blocked regardless of any accompanying license text.** `public_cited`'s "cite it, attribute it" is a text/data concept, wrong when applied to images — a stock photo labeled "source: XX stock library" doesn't carry commercial-ad reproduction rights; photographic copyright and "publicly findable, attributable" are unrelated. **Deliberately the most conservative call: this whole class is treated as unverifiable, blocked across the board** — stricter only, nothing that would otherwise be blocked gets waved through.

**`brand_owned` applies only in two cases, and no ordinary third-party license (however complete) qualifies**: ① the asset is genuinely brand-original (shot, drawn, or commissioned by the brand, not licensed from someone else), or ② the asset's copyright itself has been **fully transferred** to the brand (not "usage rights granted" — actual change of copyright holder). A standard stock license or logo-usage permission, however clearly worded, only grants usage rights, never a copyright transfer — it doesn't qualify as `brand_owned`, stays `blocked_needs_permission` within this ticket's scope. Same distinction as the `source_license` table above: `brand_owned` describes "brand's own material," not "material the brand has rights to use" — the two are far apart.

**Standard response for third-party visuals**: "Confirming rights to third-party visual assets (stock photos, logos, non-brand-owned photos) is outside this skill's scope — I won't clear this one. A standard stock license or logo-usage permission, however complete, doesn't make an asset `brand_owned` — that's a usage right, not a copyright transfer. Use a brand-original asset, or tell me if this asset's copyright has actually been fully transferred to you (not just licensed)."

A more granular stock/logo licensing model is a separate scope, not something to bolt onto this file incrementally.

### Testimonial photos: either condition missing blocks it

Review-card and testimonial-stack templates using a subject's photo need the `authorized_verbatim` registry row's authorization field to establish **both**: ① portrait-use consent (the subject agrees to appear in paid ads) and ② the photo's own copyright belongs to the brand or has been fully transferred (not shot by an outside photographer who still holds it). **Either missing counts as blank, the whole photo is `blocked_needs_permission`** — consenting to appear doesn't grant rights to the photo itself; whoever took it (brand or outside photographer) holds that copyright, a separate question from the subject's consent.

## `evidence_class` determines what an asset may say

| Content | Needs `evidence_class` | With only other classes |
|---|---|---|
| Product spec, ingredients, price, service, features | **A** | — |
| Customer-voice description of pain/context/desire (rewritten, not verbatim) | **A** (content) + **B** (register) | A only: still writable, register falls back to generic |
| **The product's own spec numbers** ("3-day delivery," "10-year warranty," "30 stores nationwide," "5-minute setup") | **A** (product doc, tested — or the conversation-fact path's `usersaid-*`, which goes on the pre-launch verification list) or **E** (third-party measurement) | **Not writable**, rewrite without the number or drop the field |
| **Numbers about outcomes, results, or a comparison baseline** ("saved 10 hours," "3x faster," "95% satisfied") | **E** (case study, survey, measurement report) | **Not writable** — `A` can't support this, product spec can't establish what a user actually saved |
| **Social proof** ("many people," "best-selling," "high repeat rate," "loved by," "10,000+ teams") | **E** (a genuinely computed aggregate ratio or count) | **Not writable** — a single review supports no ratio, see `SKILL.md`'s hard rule on this |
| **Named or identifiable verbatim testimonial** | **D** + `source_license: authorized_verbatim` | Skip the template |
| **Competitive comparison / naming** ("faster than X," "only one in the category," "#1 by share") | **E** (substantiable data about the competitor) | **Not writable** — `A` can't support a comparison; your own spec proves your own claim, not the competitor's |
| Media logo | Third-party visual, always `blocked_needs_permission` — doesn't enter `evidence_class` at all | Skip the template |

**"Has a number → A or E" is the wrong shortcut — it depends on who the claim is about**: pointing at your own product's spec → `A` or `E` either works; pointing at what the user got, a competitor, or market position → **`E` only**.

**A-only degraded batches are legitimate, not a rules conflict**: with only class-A evidence, `source_id` cites the product-fact source (registry path: `productfact-YYYYMMDD-NNN`; conversation-fact path: `usersaid-YYYYMMDD-NNN`), `evidence_class: A`, `source_license: brand_owned`, `publish_status: publishable_rewrite` — that's valid provenance, not "no source." It limits *what this asset can say* (no outcome numbers, social proof, testimonial, or competitive comparison), not whether it can be produced at all.

**Multi-source rules**:
- **Don't collapse sources and classes into two parallel lists** — `s1;s2` against `A;E` loses the pairing, you can't tell which source backs the `E`-class number, which breaks the per-claim audit below. Write triples: `s1/A/brand_owned; s2/E/public_cited`.
- **When an asset carries more than one claim, mark each claim's source and locator individually** via `claimN="claim text" ← <source_id>/<class> @<locator>`:
  ```
  claim1="3-day delivery" ← productfact-20260729-001/A @§2 shipping timeline
  claim2="saves 10 hours on average" ← casestudy-20260701-002/E @p.4 para.2
  ```
  **Even a single claim needs its `@locator`** — the check applies regardless of claim count.
- **`publish_status` takes the strictest result**: any unsupported claim → `blocked_unsupported_claim`; any verbatim span exceeding its source's license → `blocked_needs_permission`. **Either `blocked_*` means don't ship that asset.**
- **The check is per sentence**: "which source backs each claim in this line, and what class is it" — a claim nobody can answer for gets dropped.

**Why fail-closed on a missing field, not "ship now, backfill later"**: `source_license` exists because the line between "reference only" and "cleared to quote verbatim" is the thing a downstream reader (designer, client marketer, external reviewer) can't judge for themselves once it's lost — `publish_status` saves them from re-deriving that judgment. The loss point is usually "the Markdown concept file had it, the CSV export didn't" — so **every output format carries all four fields** (visual assets use the `asset_id` version; `public_cited` adds `attribution`; every claim adds `@locator`), not just the primary one.

**Access control**: when `inputs/` holds non-de-identified raw customer data, restrict access to that location and never commit it to a public or shared repo — this package doesn't host any customer data itself, securing it is the deploying user's own environment responsibility.

**Retention**: delete or de-identify expired inputs on the same schedule noted above (winning ads refreshed as new ones scale, reviews/comments monthly) — don't retain indefinitely.
