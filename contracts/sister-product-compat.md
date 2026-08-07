# Sister-product compatibility contract (v2)

Two skills outside this package share `.agents/` with it: `usp-discovery` (value-proposition research) and `campaign-strategy` (campaign angle strategy). Neither ships with this package. When installed, they append fields and sections to `.agents/positioning.md` and create their own `.agents/campaign-plan-*.md` records.

**Without those two skills installed, none of what this document describes appears under `.agents/`.** Everything here is "if you encounter this kind of file, here's how to read it" — not "you should have these files." A project without them behaves exactly as if this document didn't exist.

**This is the single authoritative definition of these fields and files within this package.** `ads`, `ad-creative`, `landing-page-cro`, and `quick-angle` all point here; if one of them needs to change how it understands a field, change it here — never write a second definition in a skill's own file. Two skills reading the same field two different ways is the least visible kind of drift there is, and it never shows up in the output.

The full rule for how a value gets computed (`evidence_level`'s derivation, when `source` gets recomputed, what gets validated on write) belongs to those two skills' own output specs — this document records only the slice this package needs to consume them. Where the two disagree, their spec wins only on field semantics and value range: what a value means, what values are legal, which skill writes it. How this package *uses* a field once read — what it permits, what it blocks, what extra guardrail it adds — is this package's own call, made in each skill's own file, not subordinate to the sister skills' spec. Their spec is written for themselves and their own users, not as a governing spec for this package's judgment logic: this package doesn't lose an already-shipped behavior because their spec never mentioned that use, and doesn't gain a new obligation just because their wording changed without this document being updated.

**§1–§5 carry v1's field semantics and validation rules forward with no change in meaning** — the ticket worklog that produced this file has the field-by-field comparison. §6 is new in v2.

## §1. Fields added to `positioning.md`

This package's own `quick-angle` writes five frontmatter fields (`schema` / `status` / `generated_by` / `generated_at` / `source`) and four fixed body sections — that shape is `positioning/v1` itself and is frozen (v1's `quick-angle/references/angle-doc-template.md` is today's live definition; v2 doesn't redefine it). Once a sister skill has run, the **same file** gains the fields below.

**`schema` is still `positioning/v1`; the four fixed sections' headings, order, and position don't change.** The file remains a valid positioning document for this package's three tactical skills — no second parser, and gaining fields doesn't fail the format.

### `evidence_level` — how well-supported the three sections are

| Value | Meaning |
|---|---|
| `sourced` | Every substantive claim across all three sections is backed by the user's own verified fact, or by three or more independent pieces of material |
| `mixed` | At least one section rests on a single lead, an unverified claim from a competitor or third party, or a sentence with no backing |
| `assumed` | None of the three sections has any material backing — inference or the user's gut sense throughout |

**Only these three values are legal.** Judge per-section by its weakest substantive claim, then the whole document by its weakest section — so `sourced` means "even the weakest sentence is backed," not "mostly researched." One unsupported add-on claim in an otherwise well-researched section drops that section, and the document, to `mixed`.

**Not interchangeable with `ad-creative`'s `evidence_class` (A–F)** — different axis entirely: `evidence_level` grades a positioning document's three-section backing strength; `evidence_class` grades a single creative asset's source (see `ad-creative/references/grounded-inputs.md`). No conversion between them. How each skill folds `evidence_level` into its own judgment is that skill's own call, written in its own file — not defined here.

### `source` — how verified this document's content is

| Value | Meaning | Written by |
|---|---|---|
| `user_self_report` | The user's own unverified statement at time of writing | `quick-angle` (this package) |
| `user_confirmed` | Some sections carried over from an existing file, confirmed section-by-section by the user; still unverified against material | `quick-angle` (this package) |
| `material_analysis` | All three sections re-verified against material and named URLs | `usp-discovery` |
| `mixed` | Some sections material-verified, the rest carried over unchanged | `usp-discovery` / `campaign-strategy` |

**Only these four values are legal**; the first two are already what `quick-angle` writes on its own. **`user_confirmed`'s "confirmed" means "this is what I meant," not "this is backed by material"** — it carries the same unverified status as `user_self_report`.

### Other fields that can appear

| Field | Written by | Shape / meaning |
|---|---|---|
| `candidates_considered` | `usp-discovery` | `2` / `3` / `4` — how many value-proposition candidates this document was compared against |
| `research_notes` | `usp-discovery` | Relative path to the currently-active research record (`.agents/usp-research-YYYY-MM-DD[-N].md`) |
| `angles_considered` | `campaign-strategy` | `2` / `3` / `4` — how many angle candidates this round compared; a different count from `candidates_considered` |
| `strategy_notes` | `campaign-strategy` | Relative path to the currently-active campaign strategy record |
| `origin_generated_by` | `campaign-strategy` | Which skill originally produced this document; `unknown` if untraceable. Written once, never updated after |
| `claim_verified_at` | `campaign-strategy` (carried) | `YYYY-MM-DD` — when the claim-level evidence was verified. Distinct from `generated_at` (the document's last-edit date); don't conflate the two |

`generated_by` can also read `usp-discovery` or `campaign-strategy`. **This field only says "who last wrote this file"** — never a proxy for verification level; that's `source` and `evidence_level`'s job.

The body also gains sections when those skills run: `## 研究依據` (`usp-discovery`) and `## 活動策略` (`campaign-strategy`, at most one instance per document). Both sit **after** `## 限制`; nothing gets inserted between the four fixed sections.

## §2. `campaign-plan-*.md` — a strategy record, not a positioning document

All three structural markers must hold together:

- Frontmatter `schema` is exactly `campaign-plan/v1` (not `positioning/v1`)
- Filename is `.agents/campaign-plan-YYYY-MM-DD.md`; a same-day second file increments a suffix (`-2`, `-3`, …) — full pattern `campaign-plan-YYYY-MM-DD[-N].md`
- It does **not** have the four fixed section headings

Other frontmatter: `generated_by: campaign-strategy`, `generated_at`, `angles_considered`, `positioning_doc: .agents/positioning.md`.

This package doesn't treat its content as an angle to use, and doesn't validate it — it's `campaign-strategy`'s own working notes (candidates, tradeoff tables, rejected angles, failure signals), not a substitute or supplement for the positioning document. This package does *recognize* it, because when several `.agents/` documents coexist, this package needs to identify which candidate strategy record is currently active (§3), and cross-check it against `positioning.md`'s `strategy_notes` field when that field is present.

**Structure-only validation, one recognizer:** the three markers above decide legality; body content is never checked. "No four fixed headings" is a structural signal used only to confirm this file isn't a positioning document wearing extra sections — it is not read further once that's confirmed. This is one act (recognize the shape, stop), not two contradictory ones: once the three markers hold, whatever the body says has no bearing on the recognition verdict and is never used for anything beyond that recognition.

- **Don't validate it against positioning-document rules** — it deliberately isn't `positioning/v1` and deliberately skips the four headings; measuring it with that ruler guarantees a fail.
- **Don't treat "wrong format" as an error worth stopping for** — it's a sister skill's normal output, not a broken positioning file.
- **Don't treat it as a second positioning document**, and don't let it stand in for `.agents/positioning.md`.

A fresh file is created on every run; old ones are never overwritten, so `.agents/` accumulates dated files over time. That's by design, not clutter — cleanup is the user's call.

## §3. Read priority across multiple documents

1. **The angle is `.agents/positioning.md`, full stop.** When it exists, nothing else under `.agents/` that resembles a positioning file — a user's own backup, `positioning-old.md`, a strategy record — substitutes for it, merges with it, or gets picked over it.
2. **The active strategy record is whichever file `strategy_notes` names**, when that pointer is usable. `campaign-strategy` writes `strategy_notes` and deliberately does **not** update `positioning.md` every time it creates a new candidate plan — that's its normal workflow, not a stale state, so the newest-dated file under `.agents/` is not necessarily the active one; `strategy_notes` is. Single validator, fixed order:
   - **Step 0 — path safety, checked before existence or legality.** `strategy_notes` is illegal if it's an absolute path, contains `..`, or resolves outside the project's `.agents/` directory once resolved against it. A legal value is a relative path to a file inside `.agents/` itself (`campaign-plan-2026-08-01.md`, or spelled out as `.agents/campaign-plan-2026-08-01.md`) — never a path that escapes that directory.
   - **Passes path safety, has a value, the file exists, and it's a legal strategy record** (§2's three markers) → use it. Don't compare filename dates against it, and don't flag "inconsistent" just because a newer-dated candidate plan sits in the directory — a newer candidate existing alongside the active one is expected, not a conflict.
   - **`strategy_notes` is missing, fails path safety, points to a file that doesn't exist, or points to an illegal record** → fall back to the newest file by filename date, highest suffix breaking same-day ties (`-3` beats `-2` beats no suffix). This fallback only fires when `strategy_notes` can't be used; disclose it on delivery ("this run picked the strategy record by newest-filename fallback because `strategy_notes` was [missing / unsafe / pointing at a missing file / invalid]") — when the reason is a path-safety failure, disclose it as "invalid" without naming which escape technique was attempted, so the disclosure doesn't double as a guide to bypassing the check.
3. **Unrecognized `.agents/` documents: mention, don't validate.** A schema this package doesn't know, field values outside the known range, or a file that's unclear what it even is — mention it on delivery ("`.agents/` also has these files, not used this run") and stop there. No format check, no error, no halt.

None of §3 changes the fail-closed degrade on the positioning document itself: `.agents/positioning.md` with a `schema` that isn't `positioning/v1`, a `status` that isn't `ready`/`draft`, or missing fixed sections still degrades to "no positioning document" exactly as before. The difference is only "is this file `.agents/positioning.md`" — the document of record degrading is the safe direction; flagging some other file this package never owned is a false alarm.

## §4. Write ownership across `.agents/`

**Sister fields on `positioning.md`: read-only.** No skill in this package adds, edits, or removes any field or section listed in §1. Understood → use it as a signal. Not understood → leave it exactly as found. The skill that updates this file (only `quick-angle`, in this package) touches only the five fields its own template defines — every other frontmatter field and body section is untouched, byte for byte.

**Values are never "fixed."** An illegal value is not adopted and not corrected — the field is left as-is. This package doesn't know who reads that field or what they do with it downstream; silently "fixing" it decides a fact on someone else's behalf. `research_notes` and `strategy_notes` are pointer fields naming the currently-active record; `origin_generated_by` / `claim_verified_at` are provenance and verification dates. None of these fail loudly when altered or deleted — the next run of the skill that owns them simply can't find its own prior record, and nothing in the output shows where the chain broke. Losing a field a downstream skill depends on costs more than keeping one nobody reads.

**`profile.md` write ownership.** Every skill in this package reads `profile.md`; two write to it, and each owns a disjoint slice:

| Section | Who writes | When |
|---|---|---|
| Everything except **Calibrated Thresholds** | The onboarding skill (creates the file), or the user editing it directly | On intake, or whenever the user updates their own facts |
| **Calibrated Thresholds** only | `campaign-analysis` | After a calibration pass against real spend/conversion data |

No other skill in this package writes to `profile.md`, and `campaign-analysis` writes to no section of it besides Calibrated Thresholds — the same discipline as `positioning.md`: one section, one writer, everyone else read-only. See `contracts/profile-v1.md` for the section shapes this governs.

## §5. Two mandatory pre-checks before reading `.agents/positioning.md`

Shared by every skill in this package that touches this file (`quick-angle`, `ads`, `ad-creative`, `landing-page-cro`) — whether updating it (`quick-angle`) or only reading it as the angle baseline (the other three). Run both before looking at `schema`, `status`, or content. No skill defines its own version of these checks; change them here and all four pick it up.

**Three-state routing** (not two mutually exclusive states — judged solely by whether the file opens with a `---` frontmatter delimiter, and whether a legal closing delimiter can be found):

- **Opener present, legal closer found (a complete frontmatter block)** → run both checks below. Check 1 (key normalization) runs whenever frontmatter exists, regardless of what `schema` turns out to be — key-level ambiguity has to be resolved before even the `schema` value itself can be trusted. Check 2 (four fixed sections) only runs once `schema` is confirmed to be exactly `positioning/v1` — a sister skill's other output (`schema: campaign-plan/v1`) isn't `.agents/positioning.md` and isn't governed by this section (see §2).
- **No opener at all (not a single `---` line)** → neither check fires. Fall back to each skill's own "handwritten content" branch — checking only whether the three substantive answers are non-vacuous, with no `status` or fixed-heading requirement. No frontmatter mechanism means no key to normalize and no `schema` to confirm; running these checks would be answering a question the file never asked.
- **Opener present, no legal closer (or the closer itself is ambiguous — the block boundary can't be determined, or looks truncated)** → a third state, not either of the above: not a complete frontmatter block (no legal end), and not the handwritten branch either (the `---` opener signals the author meant to write frontmatter). **Fail closed — the file is invalid, unconditionally**: readers (`ads` / `ad-creative` / `landing-page-cro`) treat it as no positioning document and take their degrade branch; the writer (`quick-angle`) doesn't touch the file and asks the user to confirm. Don't fall back to the handwritten branch here — that would treat a file with a broken, ambiguous frontmatter block as an ordinary handwritten document.

Each of the four skills' own "positioning-document validation" section and `quick-angle`'s own "update existing document" pre-write check apply this same three-state split — they don't redefine it.

### 1. Key-normalization check (blocks duplicate/colliding keys from slipping past fail-closed)

**Form check first — illegal form fails immediately, no parsing attempted.** Only a flat block mapping is accepted: one `<key>: <value>` per line, unquoted keys, scalar values (no nested objects or lists). Any of the following fails the whole frontmatter block, no partial parse, no guessing intent:

- **Flow form** (`{` or `[` opening a line) — e.g. `{"schema":"positioning/v1","status":"draft","status":"ready"}`; flow form can carry the same key twice on one line, which a line-by-line key scan can't see.
- **Quoted keys** (`"status":` or `'status':`) — escape sequences can collide with an unquoted `status` only after a YAML parser resolves them; comparing raw text can't catch that.
- **Multiple fields on one line** (comma-separated).
- **Nested or list-valued fields** (multi-line indented structure, `- ` list items).
- Anything else outside flat block mapping (anchors/aliases, multi-document separators, tags).

**Only after the form check passes, extract keys line by line.** Check the raw frontmatter text, not a parser's output — a standard YAML parser resolving the document into a dict is exactly the step that silently keeps only the last value when a key repeats; by the time a parser has run, the duplicate is already gone.

1. Pull every key from the raw text, keeping duplicates.
2. Normalize each: **Unicode NFKC, then trim whitespace, then lowercase** — in that order, and NFKC can't be skipped (trim+lowercase alone misses fullwidth/compatibility variants — fullwidth `ｓｔａｔｕｓ` normalizes to the same key as `status`).
3. **A normalized key must match the ASCII identifier form `[a-z][a-z0-9_]*`** — any key that doesn't fails the whole block, not just that one field. This closes off implicit-typing collisions at the source: keys that look numeric (`1`, `01`), null-like (`null`, `~`, `Null`, `NULL`), or anything a given YAML parser might implicitly retype rather than treat as a plain string, don't survive this filter in the first place — no need to guess whether a particular parser reads `01` as the string `"01"` or the number `1`, or `~`/`null` as YAML null. The raw spelling already fails the form.
4. Among keys that pass, **any two that normalize identically collide** — whether they're literally repeated or only match after normalization (`status` / `Status` / `ｓｔａｔｕｓ`).

**Any failure here — wrong form, non-identifier key, duplicate, post-normalization collision, or a YAML parse failure — invalidates the whole file; don't read `schema`, `status`, or content past this point.** Consequence depends on role:

- **`quick-angle` (writer)**: don't touch the file; tell the user specifically what's broken and let them fix it — no auto-repair.
- **`ads` / `ad-creative` / `landing-page-cro` (readers)**: treat as no positioning document, take the normal degrade branch. Fail-closed direction: a file this ambiguous at the structural level isn't trustworthy no matter how clean most of it looks.

*Why this form restriction instead of full YAML*: same approach as the frontmatter-snapshot anti-collision check elsewhere in this package (`ad-creative/references/grounded-inputs.md`) — rather than fighting YAML's full expressiveness with a parser and a pile of escaping rules, shrink "legal" down to one form that's safe to compare line by line, and reject everything outside it. The `{"status":"draft","status":"ready"}` case is exactly what the block-mapping restriction exists to catch: a line-by-line key scan sees one odd line, not two `status` keys, but a YAML parser resolving it will likely keep `ready` silently — restricting to flat block mapping fails the whole thing at the form-check stage, before "which value did the parser keep" is even a question. The ASCII-identifier restriction is the same idea one layer down: instead of researching how every parser handles implicit-typed keys like `1` / `01` / `null` / `~` (answers vary by parser and config), collapse legal keys to a form that's always read as a plain string with no implicit-typing ambiguity, sidestepping the parsing uncertainty entirely.

### 2. Four fixed sections (`## 要打誰` / `## 憑什麼贏` / `## 對比誰` / `## 限制`)

Once check 1 passes and `schema` is confirmed exactly `positioning/v1`, all of the following must hold:

1. **Exact heading text** — the four headings must match `## 要打誰` / `## 憑什麼贏` / `## 對比誰` / `## 限制` verbatim; no synonyms, no punctuation variants, no case or width variants.
2. **Fixed order** — 要打誰 → 憑什麼贏 → 對比誰 → 限制, never reordered.
3. **Contiguous** — nothing sits between the four. `## 研究依據` / `## 活動策略` (§1) may only follow `## 限制`, never sit between the four; any other section (custom or sister-written) appearing between them also fails this condition.
4. **Each exactly once** — a repeated heading (e.g. `## 憑什麼贏` appearing twice) fails. A repeated heading makes a `@§憑什麼贏` locator and body-hash targeting ambiguous — which occurrence does the locator mean, first or last? Neither is decidable, so failing outright beats guessing.
5. **Markdown-structural match only, no plain-text hits** — only a real H2 heading (`##`-prefixed, in heading position) counts. The following containers never count even when they contain the identical text (this is a prompt-facing skill, not tied to one parser; the list below is the coverage bar, not a mandated implementation):
   - Fenced code block (` ``` ` or `~~~`)
   - Indented code block (4-space or one-tab indent)
   - Blockquote (`>`, including nested `>>`)
   - HTML comment (`<!-- ... -->`)
   - HTML block (raw tags, e.g. `<div>...</div>`)

   A code sample showing `## 憑什麼贏` as literal text, or the same text quoted inside a blockquote or HTML comment, doesn't count toward condition 4's "exactly once," and isn't one of the four real headings for conditions 1–3. Judge by Markdown structure, not a plain-text search over the whole document.

**Any condition failing → treat as no positioning document, take the normal degrade branch; don't error, don't stop.** Same direction as "malformed fails closed" — the difference is this isn't the user's mistake, the file is broken or was tampered with; this package doesn't repair it, just doesn't trust it.

## §6. Free ↔ paid downgrade boundary

Per spec: the existing sister-compat degrade discipline (read-only fields, missing-field-degrades-gracefully) *is* the free↔paid interface — no new schema, no new mechanism. A tactical skill without its paid counterpart installed takes the same "field/file missing → degrade, don't ask, don't error" branch it already takes for a missing sister-skill field.

| File / behavior | Paid skill absent | Free-tier behavior |
|---|---|---|
| `positioning.md` `evidence_level` | `usp-discovery` not installed (a sister product, not tier-gated by this package) | Field absent → treated as unverified, no error — existing rule, unchanged |
| `campaign-analysis` full judgment (evidence gates, TCPL, scale quadrants, diagnostic funnel) | Paid layer absent | Free layer runs only the defensive subset: absolute stop-loss thresholds, "wait ≠ not working," fix-tracking-first, and the problem-routing table pointing at what paid diagnosis would cover |
| `landing-page-cro` | Paid-only skill, not installed | Free layer never diagnoses the landing page; it names the landing page as the likely problem and points at the paid skill as the upgrade path |
| Tracking-architecture-design (new, paid) | Not installed | `tracking-health` (free) still runs its check-only scope (what's installed, what's missing); no event-architecture recommendation is produced |
| Experiment-design (new, paid) | Not installed | No structured experiment design is produced; the user proceeds without hypothesis/sample-size/verdict guidance |
| `profile.md` **Calibrated Thresholds** | `campaign-analysis`'s paid calibration pass never runs | Section stays at whatever the onboarding skill or user set (or empty); every skill treats it the same "missing field → degrade" way it treats any other absent profile section |

A free-tier install completes the whole "build assets → set the angle → launch → produce creative → check tracking" loop without ever hitting a hard stop from a missing paid file — every row above degrades, none of them block.
