# Google RSA output spec

**This is a spec, not a production workflow.** `ads` does **not** write RSA headlines and descriptions itself — text-asset production runs through `ad-creative`, which carries grounded-input grading, `source_id`/license fields, positioning-document schema validation, and injection defense, plus compliance fail-closed. Writing headlines directly in `ads` bypasses that whole chain.

**When the user asks `ads` to "write the RSA"**:

1. State the division of labor — "`ad-creative` produces the headlines and descriptions, with a source requirement on every line; I handle the spec, ad group structure, negative keywords, and compliance review"
2. Hand `ad-creative` this spec plus the known ad group structure, keywords, and regulated-industry flag
3. Once `ad-creative` produces the assets, `ads` does the **spec and compliance review**: character count, pinning, the 3-per-ad-group cap, and the two-check medical/supplement pass — this skill's job
4. `ad-creative` not installed → say so plainly: "the full RSA workflow needs `ad-creative` (shipped in this package) — without it I can give you the spec, ad group structure, negative keywords, and a compliance checklist, but I won't write headline copy myself, because that needs a per-line source chain." **Don't write copy yourself just because it's missing.**

The parts `ads` produces itself (ad group structure, negative keywords, sitelinks, callouts, structured snippets) follow the evidence-grading rules below.

## Hard limits per RSA (check before replying)

**Separate what's a Google platform limit from what's this pack's own house rule** — `ad-creative`'s `references/platform-specs.md` states "up to 15 headlines, up to 4 descriptions," which is Google's platform ceiling (the platform actually only requires 3 headlines/2 descriptions minimum to create an RSA, not a full house every time); the "exactly 15/4" target below is **this pack's house rule** — the reasoning is that 15 headlines and 4 descriptions give Google's auto-combination testing enough angle coverage to be worth it. It's a quality bar this pack sets, not a technical ceiling Google enforces:

- **Headlines:** target **15** when evidence supports it, each **≤30 characters** (including spaces/punctuation — see "Character counting," below). Format as `1. ...(NN chars)` so the user can verify. **"15" is a target, not a hard floor** — reduce per the evidence tiers below when support is thin; never pad to 15 with unsupported variants (a reworded duplicate counts as unsupported)
- **Descriptions:** target **4** when evidence supports it, each **≤90 characters**. Same evidence-tier rule applies

**Floor for reduction: below 3 headlines/2 descriptions, don't output the RSA at all.** This is the platform's own minimum to create an RSA, not a house rule — handing the user a "RSA" with 2 headlines can't even be saved in the account, so it looks like a deliverable but isn't one.

| Supported lines on hand | How to handle |
|---|---|
| Headlines 3-14, descriptions 2-3 | **Output as-is with the gap flagged** — this is a deliverable RSA, buildable and launchable, just with narrower combination coverage than 15/4. Gap note follows the "shared across every asset type" rules below |
| Headlines <3 **or** descriptions <2 (either one triggers this) | **Don't output this RSA.** Output a data request instead: how many supported headlines/descriptions exist now, the gap to the platform minimum, and what evidence category would close it. The lines already written can be included as progress, but **don't format them as if they're ready to paste into the account** |

**This judgment is made per RSA, independently**: RSA1 clears 3/2, RSA2 doesn't → output RSA1, issue a data request for RSA2 — not an all-or-nothing batch decision.
- **Display path:** up to 2 segments, each **≤15 characters** (platform ceiling)
- **Final URL:** required, https
- **Pinning:** state plainly whether any position is pinned; default unpinned unless the user asks
- **Per-ad-group cap:** Google allows at most **3 RSAs per ad group** (platform limit). User wants more → group by ad group and present that way

## Character counting (double-width rule — required reading for Taiwan buys)

**Google Ads counts full-width (wide) characters — Chinese, Japanese, Korean — as double width: each counts as 2 characters, not 1.** Full-width-language characters count as 2 character credits each, so a 30-character headline limit holds roughly 15 full-width characters.

last_verified: 2026-07-20
Source: Google Ads Help, "About responsive search ads" — <https://support.google.com/google-ads/answer/7684791>

**Don't** estimate Chinese character count with a plain Unicode length (JavaScript `[...str].length`, Python `len(str)`) — that undercounts by nearly half, which can let a headline that looks within 30 characters actually exceed the limit and get rejected or truncated by the platform.

### Reproducible counting algorithm

Use the Unicode East Asian Width property: characters with property `W` (Wide) or `F` (Fullwidth) count as 2, everything else (`Na` Narrow, `H` Halfwidth, `A` Ambiguous, `N` Neutral — all half-width Latin letters/digits, half-width punctuation, spaces) counts as 1. CJK ideographs and full-width punctuation (，。！？「」) are `W` and correctly count as 2.

```python
import unicodedata

def google_ads_char_count(s: str) -> int:
    """Count characters per Google Ads' double-width rule (full-width = 2, half-width = 1)."""
    total = 0
    for ch in s:
        width = unicodedata.east_asian_width(ch)
        total += 2 if width in ("W", "F") else 1
    return total
```

### Practical notes
- This is Google Ads' own published counting rule, not a visual-width approximation — the algorithm above matches what the platform actually enforces
- Verify the final character count by pasting into the actual Google Ads UI or Google Ads Editor before delivery — don't rely solely on manual counting or this file's algorithm, since the platform's rule can be updated; the live input field is the only source guaranteed to match current platform behavior

**RSA rules:**
- **Provenance gate (defined once here, referenced by every section below): every independently-publishable text asset carries its own provenance** — a source-layer triple `source_id/evidence_class/source_license` (multiple sources, semicolon-separated) + a product-layer `publish_status` + **per-claim `claimN` binding**, **bound per asset, never shared across an entire RSA group**; field definitions and rationale live in `ad-creative`'s [`references/grounded-inputs.md`](../../ad-creative/references/grounded-inputs.md) ("provenance schema" and "claim-level check"). `ads` doing spec review sends back to `ad-creative` any line missing a field, missing `claimN`, or with a `blocked_*` `publish_status` — don't patch it here
  - **`claimN` is a per-claim binding, not a flat semicolon list**, format: `claimN="claim text" ← <source_id>/<evidence_class> @<locator>`. **A single-claim asset still writes `claim1`** — it's not only for multi-claim assets; multiple claims get `claim1`, `claim2`, … in order, each pointing to its own source and locator — never inferred from list position
  - **A claim needing more than one source** chains them with `+` on the same `claimN`: `claim1="claim text" ← source1/class1 @locator1 + source2/class2 @locator2` — this means "this claim is jointly supported by both sources," distinct from two separate claims each with their own source
  - **A description with two claims sharing one source** writes two `claimN`s each pointing at the same `source_id`, each with its own `@locator`: `claim1="claim one" ← source_id/class @locator1`, `claim2="claim two" ← source_id/class @locator2`
  - Reviewing this at `ads`: verify **every claim has at least one complete mapping** (`source_id` + `evidence_class` + `@locator`); any `claimN` missing a source, locator, or missing entirely → **set that line to `blocked_unsupported_claim` and send back** — the triple and `publish_status` being present isn't enough on its own, without the per-claim mapping there's no way to verify the source actually backs the claim
  - **A conditionally-required field still counts as "missing" if absent**: any line whose triple includes `public_cited` needs `attribution` (the `cite:` field) shipped alongside it; missing → set to `blocked_needs_permission` and send back
- **Evidence class depends on the claim type, not on whether it has a number**: ① **the product's own spec figures** (capacity, duration, price, warranty length, store count) = `A` (first-party fact) or `E` (third-party verified), either is fine ② **outcome figures** (how much a customer saved, how much they grew), **social proof** (user count, review count, sales ranking), and **competitive comparisons** (faster than, cheaper than, industry-first, market-leading) = **`E` only**. Reason: `A` is your own product spec — it proves "we ship in 3 days," it can't prove "faster than the competition," which needs verified data about the competitor, i.e. `E`. Same rule as `ad-creative`'s [`grounded-inputs.md`](../../ad-creative/references/grounded-inputs.md) — that schema is authoritative for review
- **RSA's auto-combination amplifies this**: Google freely combines any headline with any description for display, so "this line is fine in isolation" isn't enough — an `A`-class spec figure paired with another line's comparative headline displays as an unverified competitive comparison once combined. Content carrying a mandatory disclosure or warning can't rely on a single headline to always show — pin it, or place it in a field that can't be split apart
- Headlines need to stand alone individually and combine coherently in any pairing (Google displays random combinations)
- Pin only when necessary (pinning reduces the platform's optimization room)
- At least one keyword-driven headline
- At least one benefit-driven headline
- At least one CTA-driven headline

## Required accompanying assets (attach with every RSA request — conditioned on real supporting data)

**Check for real data backing these before producing them — output "data needed" fields when data is short, don't fabricate to hit a count.** Negative keywords need a real search-terms report or existing account data to be accurate; sitelinks need pages that genuinely exist on the client's site. Given only product information with no search-terms report or page list, generating plausible-looking negative keywords or URLs is fabricating a deliverable — a direct violation of this pack's no-fabrication rule:

1. **Ad group structure**, labeled `Ad group structure:` — list each ad group's theme, target keywords (match type), and which RSAs map to it (usually derivable from the product/audience info the user already provided, no extra data needed)

**General output-quantity rule (read this first, the next two items expand on it): how many lines to output is decided by how much defensible evidence is on hand, not by the target count.** Data availability isn't binary — the common case is a **middle state**: a search-terms report exists, but only 3 terms in it actually earn negative-keyword status; a website exists, but only 2 pages genuinely fit as sitelinks. **Output exactly what's defensible, then state the gap clearly — don't pad to the target, and don't withhold the whole section just because it's short of the target.** Padding produces fabricated content (real harm if copied straight into the account); withholding the whole section throws away real, usable output.

2. **Negative keywords**, labeled `Negative keywords:` — **8 is the target when evidence is sufficient, not a floor to hit regardless**, three tiers by actual evidence:
   - **≥8 defensible terms**: output ≥8, split by ad-group and campaign level, each one mapped to a term that actually appeared in the report
   - **1-7 defensible terms** (a report exists, but fewer than 8 terms in it genuinely warrant blocking; or the user only supplied a partial existing negative list): **output only what's defensible**, with a gap note after the list. E.g. "3 terms listed here, all matched to search terms in the report that are clearly unrelated to the business. No other term in this report's window qualified. A longer window (30-90 days recommended) may surface more." **Don't guess-fill to 8**
   - **0 defensible terms** (no search-terms report, no existing negative list): output **zero**, replace with a data request — what's needed (a Google Ads search-terms report, ~30-90 days recommended; or an existing account negative-keyword list), where to get it (Google Ads → Insights & Reports → Search Terms, or a Google Ads Editor export)
   - **Common to all three tiers**: **never list "plausible-sounding guesses" to pad the count** — a guessed negative keyword gets pasted straight into the account and can block real converting traffic, which is worse than not providing one; labeling it "speculative" doesn't cancel that risk, since a finished-looking list gets used as a finished deliverable
3. **Sitelinks**, labeled `Sitelinks:` — **needs real existing page URLs**, same three-tier handling (4 is the target, not a floor):
   - **≥4 real usable pages**: output ≥4
   - **1-3 real usable pages** (common for a small site or single-page landing page): **output those 1-3**, with a gap note. E.g. "2 listed here, matching pages the site currently has. Google recommends at least 4 for better sitelink exposure; more can be added once FAQ/case-study pages exist." **Don't invent a 3rd or 4th URL, and don't list the same page twice under different titles to pad the count**
   - **0 real usable pages** (user supplied no page list): output **zero**, replace with "Data needed: a list of real page URLs (e.g. full https URLs for pricing, FAQ, case studies, contact)"
   - **Common to all tiers**: don't fabricate URLs, and don't use "a page type we'd suggest" as a placeholder for a delivered sitelink
4. **Callouts** (each ≤25 characters), labeled `Callouts:` — **the easiest asset to fabricate under "it's short, just fill four."** Every callout is a public factual claim ("free shipping," "24-hour dispatch," "10-year warranty," "30 stores nationwide") — getting it wrong is false advertising. Evidence = explicitly stated by the user, or explicitly published on the client's site:
   - **≥4 defensible facts**: output ≥4, each tagged with its source
   - **1-3 defensible facts**: output those + gap note. E.g. "2 listed, based on shipping and return terms explicitly stated in the product info you provided. Google recommends at least 4; to close the gap, provide the site's terms of service or FAQ page."
   - **0 defensible facts**: output **zero** + data request ("needed: service terms explicitly published on the official site, e.g. shipping threshold, dispatch time, warranty length, store count, payment methods")
   - **Prohibited**: padding with marketing adjectives ("guaranteed quality," "customer-first," "professional team") — these aren't factual claims and carry no information, and they trip both this pack's no-fabrication and no-promised-results rules

5. **Structured snippet** (1 set, header chosen from Google's fixed list), labeled `Structured snippet:` — the platform requires **at least 3 values** to build one, so this item is **all-or-nothing**, no partial output:
   - **≥3 defensible same-category items** (e.g. genuinely 3+ service types, models, or courses): output one set, values all matching what's actually offered
   - **<3 defensible same-category items**: **don't output the section**, replace with a data request ("needed: at least 3 real, same-category items — e.g. a service list, model numbers, or course names. Only N on hand now, short of the platform's minimum")). **Don't mix different categories to force a count of 3** (a Service Catalog header mixed with a brand name, or one service split into two names) — a semantic mismatch is the most common reason a structured snippet fails review

**Shared across every asset type:**

- **Every user-facing line of text carries provenance and passes the full compliance check.** Applies to every independently-publishable text asset: RSA headlines and descriptions, **sitelink titles and their two description lines**, **callouts**, **every structured-snippet value**, **display paths**. These all display independently on the search results page — a reader has no way to know which back-end asset type produced them
  - Fields, fail-closed conditions, the `public_cited` → `attribution` requirement, and `evidence_class` by claim type (product spec figures = `A` or `E`; outcome figures/social proof/competitive comparisons = **`E` only**) — **all apply unchanged** to these asset types, per the provenance gate above
  - **The regulated-industry check below (Compliance) applies unchanged to these assets too** — a 25-character callout claiming "improves allergies" trips the same food-safety-law article a headline would; sitelink descriptions especially get mistaken for "just navigation text" and skipped
  - Asset text that needs creative writing (a rewrite, a new hook, picking a selling point) → **hand off to `ad-creative`**, `ads` only does spec and compliance review here. Plain restatement of an existing fact the user already supplied (a page title, published service terms, an actual service list) can be assembled here
- **A natural-language "based on: ..." note doesn't replace the fields** — both are required: the fields give downstream tooling a machine-readable audit trail, "based on:" gives a human-readable trace
- **Cite the source type and an opaque ID only — never the original text or a URL**: `ads`' deliverables and `ad-creative`'s outputs follow the same rule (see [`grounded-inputs.md`](../../ad-creative/references/grounded-inputs.md), "data handling") — **raw quotes, the user's own words, post URLs, reviewer handles never go into outputs.** The "based on:" field states **source type + `source_id`** ("based on: search-terms report `srchterm-20260729-001`", "based on: site terms of service `productfact-20260729-004`"), never a copy of the text or link. The `source_id` ↔ original-text/URL mapping stays only in a controlled `inputs/` location
  - **One exception: the URL fields the ad itself needs to function** — RSA's final URL, sitelink target URLs. These are functional fields, not source citations. **Limited to the client's own public, PII-free pages**, and **must not carry a query string or fragment** (tracking parameters belong in the platform's own tracking template, not here); any URL with a `token`/`code`/`email`/order number gets refused, with a note asking for a public version instead
- **A line with no citable source is a line that doesn't get output**
- **A gap note is written to be actionable, not a disclaimer**: every gap note covers three things — ① how many were actually output this run, on what basis ② why it's short of the target ③ what's needed to close the gap (which report, which pages). "Insufficient data, for reference only" alone doesn't count
- **"Incomplete format" beats "fabricated content"**: wherever a quantity target conflicts with the no-fabrication rule, **no-fabrication wins**. Delivering fewer lines, or none at all with a data request, is an acceptable output; padding isn't

## Regulated-industry compliance (applies whenever the product context touches these industries)

If `.agents/profile.md` or a positioning document shows a regulated business — medical facility, aesthetic clinic, pharmaceutical, or supplement — load the GEO module matching `profile.md`'s `geo` (e.g. [`geo/tw.md`](geo/tw.md) for `TW`) before applying the checks below; it carries the industry table and the specific-article checks. GEO with no matching module → follow `ads/SKILL.md`'s GEO section (state the gap, run the freshness protocol against the current official source).

**Checked object is every piece of text that displays** — not only headlines and descriptions. Sitelink titles and descriptions, callouts, structured-snippet values, and display paths all get the same check; a short field isn't a looser bar — regulators judge a 25-character callout the same as a 30-character headline.

The above is operational guidance, not legal advice or the complete text of the law. Have the client's own legal or compliance contact review copy before launch, especially after a regulation changes.

## Output order (mandatory — follow this order so truncation, if it happens, drops the least-critical part last)

1. **Ad group structure** (brief)
2. **Negative keywords** (≥8 when evidence supports it; 1-7 output as-is + gap note; 0 output zero + data request — placed before the RSAs so truncation doesn't drop it)
3. **Sitelinks** (≥4 real pages → ≥4; 1-3 → output as-is + gap note; 0 → zero + data request)
4. **Callouts** (≥4 defensible facts → ≥4; 1-3 → output as-is + gap note; 0 → zero + data request)
5. **Structured snippet** (≥3 same-category items → 1 set; <3 → don't output + data request)
6. **RSA1, RSA2, RSA3** (largest section, placed last — truncation here doesn't affect what's already confirmed above). **Headlines and descriptions come from `ad-creative`**, per the handoff at the top of this file; `ads` does spec and compliance review here

## Structured snippet spec

- **Header**: pick only from Google's fixed header list, never invent one — common options include Amenities, Brands, Courses, Degree Programs, Destinations, Featured Hotels, Insurance Coverage, Models, Neighbourhoods, Service Catalog, Shows, Styles, Types. Header must semantically match the values below it — a mismatch is the most common review failure
- **Values**: at least 3, at most 10, 4+ recommended; each ≤25 characters (double-width rule applies)

## Output template (mandatory format)

**`source_license` is always required, never blank; the template's `cite:` field is the conditionally-required one** — its value comes from `ad-creative`'s registry (`inputs/SOURCES.md`) `attribution` string for that row; `cite:` stays blank for any `source_license` type other than `public_cited`. When `cite:` is required and what happens if it's missing follows the provenance gate above.

```
Ad group structure:
- Ad group 1 [theme]: keywords (match type) → RSA1, RSA2
- Ad group 2 [theme]: ...

Negative keywords:
  [Tier A: ≥8 defensible terms]
  Campaign level:
    - <term>
    - <term>
    (at least 4)
  Ad group level:
    - Ad group 1: <term>, <term>
    - Ad group 2: <term>, <term>
    (at least 4 more — ≥8 total)
  [Tier B: 1-7 defensible terms, output as-is, no padding]
  Campaign level:
    - <term>
  Gap note: <the three things, per "shared across every asset type" above>
  [Tier C: 0 defensible terms, replace the whole section with]
  (No negative keywords output this run)
  Data needed: <per tier-C guidance above: which report, where to get it>

Sitelinks:
  [Tier A: ≥4 real usable pages]
  - <title (≤25 chars)> | <description line 1 (≤35 chars)> | <description line 2 (≤35 chars)> | URL
    | src: <source_id>/<A-F>/<source_license> | publish_status: <publish_status> | cite: <attribution|public_cited only>
    claim1="<claim text>" ← <source_id>/<A-F> @<locator>
    (more than one claim → list claim2, claim3…; a single-claim line still writes claim1/@locator; a multi-source claim chains with +: claim1="…" ← source1/class1 @locator1 + source2/class2 @locator2)
  (at least 4)
  [Tier B: 1-3 real usable pages, output as-is, no padding]
  - <title> | <description1> | <description2> | URL
    | src: .../.../... | publish_status: ... | cite: ...
    claim1="..." ← .../... @...
  Gap note: <the three things, as above>
  [Tier C: 0 real usable pages, replace the whole section with]
  (No sitelinks output this run)
  Data needed: <per tier-C guidance above>

Callouts (each ≤25 chars):
  [Tier A: ≥4 defensible facts]
  - <callout> (based on: <source type + source_id, e.g. "site terms of service productfact-20260729-004";
                no raw text, no URL, no user's own words>)
    | src: <source_id>/<A-F>/<source_license> | publish_status: <publish_status> | cite: <attribution|public_cited only>
    claim1="<claim text>" ← <source_id>/<A-F> @<locator>
    (more than one claim → list claim2, claim3…; a single-claim line still writes claim1/@locator; a multi-source claim chains with +: claim1="…" ← source1/class1 @locator1 + source2/class2 @locator2)
  (at least 4)
  [Tier B: 1-3 defensible facts, output as-is, no padding]
  - <callout> (based on: <source type + source_id>)
    | src: .../.../... | publish_status: ... | cite: ...
    claim1="..." ← .../... @...
  Gap note: <the three things, as above>
  [Tier C: 0 defensible facts, replace the whole section with]
  (No callouts output this run)
  Data needed: <per tier-C guidance above>

Structured snippet (all-or-nothing, platform minimum is 3 values):
  [Tier A: ≥3 same-category items]
  Header: <Service Catalog / Brands / ... (from the fixed list, semantically matching the values below)>
  Values (≥3, each ≤25 chars, all matching what's actually offered; each tagged individually):
    - <value 1> | src: <source_id>/<A-F>/<source_license> | publish_status: <publish_status> | cite: <attribution|public_cited only>
      claim1="<value 1's claim text>" ← <source_id>/<A-F> @<locator>
    - <value 2> | src: .../.../... | publish_status: ... | cite: ...
      claim1="..." ← .../... @...
    - <value 3> | src: .../.../... | publish_status: ... | cite: ...
      claim1="..." ← .../... @...
  [Tier B: <3 same-category items, don't output the section]
  (No structured snippet output this run)
  Data needed: <per Tier C guidance above: how many short, what list is needed>

RSA1 — [ad group name]  ← headlines and descriptions come from ad-creative, ads does spec and compliance review
  Final URL: https://... (client's own public page, no query string or fragment)
  Display path (each segment ≤15 chars; **both segments are independently-publishable assets, each with its own provenance, never shared**):
    Path 1: <text> | src: <source_id>/<A-F>/<source_license> | publish_status: <publish_status> | cite: <attribution|public_cited only>
      claim1="<the path text itself>" ← <source_id>/<A-F> @<locator>
    Path 2: <text> | src: .../.../... | publish_status: ... | cite: ...
      claim1="..." ← .../... @...
  (either field missing (including claimN), or publish_status is blocked_* → **that path segment isn't output**, leave it blank;
    an unfilled display path is a legal RSA, padding one with an unsupported text isn't)
  Headlines (target 15, reduce per evidence tiers when data is thin, each ≤30 chars):
    1. <headline> (NN chars) | src: <source_id>/<A-F>/<source_license> | publish_status: <publish_status> | cite: <attribution|public_cited only>
       claim1="<this headline's claim text>" ← <source_id>/<A-F> @<locator>
    ...
  Descriptions (target 4, reduce per evidence tiers when data is thin, each ≤90 chars):
    1. <description> (NN chars) | src: <source_id>/<A-F>/<source_license> | publish_status: <publish_status> | cite: <attribution|public_cited only>
       claim1="<this description's claim text>" ← <source_id>/<A-F> @<locator>
       (more than one claim → list claim2…; two claims in one line sharing a source still each write their own claimN and @locator)
    ...
  Pinning: H1=none; H2=none; ... (or state pinned positions explicitly)
  [When headlines are 3-14 or descriptions are 2-3, add, like the other asset types]
  Gap note: <the three things, as above; basis is ad-creative's grounded-input tier result>

[Headlines <3 or descriptions <2: don't output this RSA, see "Floor for reduction" above, replace with]
(This RSA set not output — below the platform's minimum to create an RSA)
  Data needed: currently N headlines, M descriptions supported, short <X> headlines, <Y> descriptions.
           Needed: <which evidence category, mapped to ad-creative's evidence_class>.
           The lines on hand are listed below for reference — not yet enough to build an RSA, don't paste directly into the account:
           - <headline> | src: .../.../... | publish_status: ... | cite: ...
             claim1="..." ← .../... @...

RSA2 — ...
RSA3 — ...
```

## Self-check before replying

Run this checklist mentally before sending:

- [ ] **Headlines and descriptions came from `ad-creative`**, not written directly in `ads` — this skill does spec and compliance review
- [ ] Each RSA's headline/description count is driven by actual evidence (target 15/4, reduced with a gap note when short), **with no unsupported variant or reworded duplicate padded in to hit the target**
- [ ] **Every RSA has at least 3 headlines and 2 descriptions** (Google's minimum to create one); any RSA that can't clear that isn't output — a data request instead, never an unbuildable RSA delivered as one
- [ ] Every headline ≤30 chars, every description ≤90 chars — counted with the double-width rule (full-width = 2), not plain Unicode length, and the computed count is shown
- [ ] Negative keywords: counted "how many terms actually match real search terms" first, then output per the three tiers above with a gap note. **No speculative keyword listed, and the "matches a real term" bar wasn't loosened to pad the count**
- [ ] Ad group structure is labeled
- [ ] Sitelinks: counted "how many real usable pages the site has" first, then output per the three tiers. No fabricated URL, no "page type" placeholder, no page listed twice under different titles
- [ ] Callouts: counted "how many facts match published terms" first, then output per the three tiers. **No marketing adjective ("guaranteed quality," "professional team") padded in as a callout**
- [ ] Structured snippet: only output when ≥3 same-category items exist (header from the fixed list, semantically matching the values); <3 → don't output + data request, **no mixed-category padding to reach 3**
- [ ] Every output line states its source (which report, which page, which user statement); a line with no citable source wasn't output
- [ ] **Sitelink titles/descriptions, callouts, structured-snippet values, and display paths all carry the source triple + product status + per-claim `claimN`** too, not just RSA headlines/descriptions — the same compliance check ran on these, not skipped for being "settings-layer assets"
- [ ] **Both display-path segments are tagged separately** (path 1 one entry, path 2 another), not shared; an unsupported segment is left blank rather than padded with an unsupported text
- [ ] **No user's own words, review text, post URL, or source-page URL anywhere in the deliverable**; "based on:" states source type + `source_id`. The only URLs present are the RSA final URL and sitelink target URLs, both the client's own public pages, no query string or fragment
- [ ] **Every line whose source carries `public_cited` has `cite:` (`attribution`) shipped with it**; none of those were let through without it (all set to `blocked_needs_permission`); non-`public_cited` `cite:` stays blank, never filled with raw text or a URL for appearance
- [ ] **Every line binds each of its claims with `claimN="claim" ← source @locator`** — a single-claim line still writes `claim1`; **a multi-source claim chains with `+` on the same `claimN`, never split into separate `claimN`s**; **any claim missing a complete mapping (source + locator) blocks that line** (`blocked_unsupported_claim`) — the triple and `publish_status` being present doesn't count as passing, and the semicolon-separated flat list isn't a valid substitute
- [ ] Headlines and descriptions carry the triple, `publish_status`, and per-claim `claimN` **per line**, not shared across the group; product spec figures are `A` or `E`, **social proof and competitive comparisons are `E` only**, no comparison or social-proof number hung on a `B`
- [ ] Medical/aesthetic involved: every headline, description, sitelink, callout, and structured-snippet value passed the loaded GEO module's checks — both/all of that module's independent checks, not just one
- [ ] Supplement/cosmetic/pharmaceutical involved: no medical-efficacy term, no exaggerated claim, geographic modifier added where relevant, copy in the target locale
- [ ] User has been reminded to verify character counts in the actual Google Ads UI before delivery — not relying solely on this file's manual calculation

Any item failing → rewrite before replying. Don't ship an incomplete RSA.
