# Creative strategy loop

Mode 1 (from scratch) and Mode 2 (scaled static batch) answer "make me some ads." This file supports **Mode 3: the creative strategy loop**, the question in front of that: **what's worth making, in what order, at what capacity** — and the monthly feedback loop that turns last month's results into next month's plan. A continuously running strategy loop, executed by the agent, decided by a human.

```
Signals → evidence-graded concepts → capacity roadmap (tiered, checked against capacity) → creative brief → handed to Mode 1/2 → monthly retro → back into the concept bank
```

**Comparative performance judgment (which creative wins, what phase the account is in, funnel diagnosis) is not this file's job.** That's `campaign-analysis-pro`'s comparative-verdict layer (paid; free-tier `campaign-analysis` covers only absolute stop-loss and problem-routing — see its own scope boundary). Every step below that needs a performance verdict names it as an input from that skill; **without it installed, the field stays "pending" and this mode still runs** on the other two signal sources, per the free↔paid downgrade rule in [`../../contracts/sister-product-compat.md`](../../contracts/sister-product-compat.md) §6.

**This file's data-handling rules are the same set as [`grounded-inputs.md`](grounded-inputs.md), not a separate one**: anywhere below mentioning "customer language," "verbatim," or "source" follows that file's rules — only authorized, public/de-identified material; private DMs and customer-service transcripts stay excluded by default; without auditable authorization, only a rewritten insight ships, never a verbatim quote; a brief's "source" field is always the opaque triple `source_id/evidence_class/source_license` (e.g. `review-20260715-014/B/research_only`), never the original text.

---

## Step 1: read three signal sources

Creative direction comes from combining three independent sources — reading only one misleads: account data tells you what worked among what you've tried, customer language tells you why they buy in their own words, native content tells you what this audience watches when nobody's paying for reach.

| Signal | What to gather | Where |
|---|---|---|
| **Account performance conclusions** | Win/loss verdicts by angle/hook/format, funnel diagnosis, fatigue calls, each with a **conclusion tier** (actionable / needs-more-signal) | **`campaign-analysis-pro`'s output** (paid) — it owns the analysis-unit, comparability, and sample-size gates this needs. **Without it, this field is "pending"**; prioritize using the other two signals instead |
| **Customer/brand language** | Recurring pain-point/desire/objection phrasing, unexpected use cases, whether actual buyers match the target audience | The input library (`inputs/reviews/`, `inputs/comments/`) — public reviews and comments; region sources in [`geo/tw.md`](geo/tw.md). **Customer-service transcripts aren't a standing source** — private one-to-one content, include only with explicit consent for marketing use |
| **External native content** | Hooks, formats, and language performing organically for this audience with no ad spend behind it; competitor ads running a long time (a plausible signal of effectiveness) | [`copy-and-visual-production.md`](copy-and-visual-production.md)'s observation accounts (region-specific, [`geo/tw.md`](geo/tw.md)); Meta/Google ad-library lookup tools |

**Cadence**: one deep pass monthly (60-90 min, all three sources, feeds that month's roadmap) + a ~20-minute weekly check-in (what changed: new winners/losers, new themes in reviews, anything suddenly going organically viral). Research beyond what the next decision needs is wasted effort — every pass should produce concepts, not notes.

**Grounding rule**: every insight cites its source as an opaque triple (`review-20260715-014/B/research_only`) — never the original text, handle, or post URL; the concept bank, roadmap, and monthly retro are long-lived, widely-circulated files. Mapping stays in `inputs/` (see [`grounded-inputs.md`](grounded-inputs.md)). An insight with no `source_id` doesn't enter the concept bank.

---

## Step 2: turn signals into evidence-graded concepts

A **concept** is a testable creative hypothesis: *audience segment × motivation × angle × format*, with evidence attached. "UGC for moms" isn't a concept; "new sleep-deprived parents (per 40+ reviews mentioning 3am feedings) × 'quiet enough not to wake the baby' × before/after with real footage × first-person night-shot video" is.

Grade by the strongest evidence behind it:

| Tier | Evidence | Weight |
|---|---|---|
| 1 | Same angle/segment already converting in your own account | Strongest — extend it |
| 2 | Customer-language pattern: recurring phrasing across public reviews/comments (rewritten, not verbatim unless authorized) | Strong — build new creative directly |
| 3 | A competitor ad running 60+ days (**running long is "worth noticing," not "proven effective"** — could equally be a brand-awareness budget, an unmanaged account, or a non-conversion goal; longevity alone doesn't guarantee profitability, only that it outlasted a flash-in-the-pan ad) | Good — borrow the angle, never copy the ad |
| 4 | Organic engagement in the niche audience (unpaid views/saves) | Moderate — validate cheap first |
| 5 | Cross-niche pattern (worked in an adjacent category) | Weak — shelve until better-supported |
| 6 | Team intuition, no external signal | Weakest — cheap test or skip |

Evidence tier decides **priority** (how soon it lands in the roadmap); production spec (Step 4) is a separate call driven by validation strength, existing assets, capacity, and risk — even a tier-2 concept runs on a low-cost spec first, upgrading only after a conclusion comes back (mapping in Spec tiers, below).

**Tier 1 requires `campaign-analysis-pro`'s determination** — "already converting" is a performance verdict, not a good-looking number on a report. Without that determination, don't self-promote a concept to tier 1; grade it 2-4 by whatever external evidence it actually has.

---

## Step 3: account phase (from `campaign-analysis-pro`, not judged here)

The right creative mix depends on whether the account is exploring or scaling — that determination needs the same analysis-unit/comparability/sample-size gates as tier-1 grading, so it's `campaign-analysis-pro`'s call, not this file's.

- **`campaign-analysis-pro` has a phase verdict** → apply its mix: **exploring** (no creative has cleared the winner bar yet) skews broad-and-shallow — mostly new concepts across segments/angles, only iterate on tier-1 or tier-2-with-actionable-conclusion work; **scaling** (one or more concepts have cleared the bar) skews deep-on-winners — visually distinct variations of the winning concept, a tonal remix, sub-segment probes, while still reserving a small explore slice (winners fatigue; the next winner is rarely a rehash of the current one).
- **No verdict, but the user has performance data** → get the verdict from `campaign-analysis-pro` first, don't read the numbers yourself.
- **No verdict and no data (new account)** → default to the **exploring** mix, and disclose "defaulted to exploring — no performance data yet, not a performance determination."

---

## Step 4: capacity roadmap

Maintain a living document (`roadmap.md`, alongside the input library), three time horizons:

```
## Shelf         — every concept, evidence tier + source (opaque triple, no raw text/handle/URL), not yet scheduled
## This quarter  — 2-4 themes pulled from the shelf (what to bet on this quarter), with "why now"
## This month    — the actual production schedule: concept | evidence tier | spec tier | owner | status
```

Every concept on this month's schedule gets a **spec tier**:

| Tier | Cost | What it is | Used for |
|---|---|---|---|
| **T1 — iterate** | Hours | New hook/copy/crop on an existing asset | Extending a validated winner |
| **T2 — remix** | Days | Recombine existing assets or generation tools into something new | Concepts with a "needs-more-signal" conclusion |
| **T3 — full production** | Weeks | New shoot, creator partnership, full production | **Only angles with an "actionable" conclusion** — see Spec tiers, below |

**Promotion to T3 has one legal source, `campaign-analysis-pro`'s conclusion tier — this file offers no shortcut.** "The cheap version already showed a funnel signal" isn't grounds for T3; that's "needs-more-signal," T2 at most. Full mapping in Spec tiers.

**Capacity check — the rule that keeps the roadmap honest**: compute what the team (or the AI pipeline) can actually produce this month **without sacrificing quality**, and schedule to that number. Forcing an 8-concept capacity to cover a 20-concept schedule doesn't produce 20 ads — it produces 20 diluted ones and a burned-out team. Sort by evidence tier, cut to fit.

Turn the roadmap into a **brief per concept** (segment, motivation + source, angle, format, hook-matrix row, spec tier, success metric), handed to Mode 1 (from scratch) or Mode 2 (static batch) for actual production.

---

## Step 5: monthly creative retro

The loop's last step and next cycle's first input. One document per month (`retros/YYYY-MM.md`).

**This retro translates `campaign-analysis-pro`'s verdicts into next cycle's production plan — it doesn't re-run the performance judgment.** The first three sections below come entirely from that skill's conclusions; this file's job is the back half — turning verdicts into concept-level learning and next month's roadmap.

```
## Winners        — concept, and why it won per campaign-analysis-pro (which element drove it)
## Losers         — concept, which funnel stage it died at per that skill, the failed hypothesis
## Metric winners — flagged "needs-more-signal" (didn't clear the winner bar, but one metric showed a signal)
## What we learned — pattern-level notes → written back to the shelf as new/revised concepts
## Retired        — concepts dropped from the shelf, with reason
## Next roadmap   — next month's draft, evidence tiers updated
```

Retro rules:

- **No conclusion yet for the first three sections → leave them blank, tag "pending `campaign-analysis-pro`."** Don't judge from raw numbers yourself — this is the easiest place to break the rule, since a performance report sitting right there invites a quick eyeball sort.
- **Judge concepts, not individual ads — this is this file's job**: that skill verdicts a single ad/asset; rolling several execution variants up into "does this concept work" is strategy work. But check its **comparability call** first — if it flags the variants as untested-under-comparable-conditions (different audience, placement, bid strategy, attribution window), don't roll them up into a concept-level verdict, log it as needs-more-signal instead. One failed execution doesn't mean "the execution was the problem" either.
- **Read the funnel, not just the top-line metric** — this means **asking that skill for a stage-level diagnosis**, not reading funnel numbers yourself.
- **Every learning needs a destination**: back to the shelf (new or revised), a re-graded evidence tier, or retired. A retro that changes nothing on the roadmap was a meeting, not a retro.

---

## Hook system (used by Mode 1/2 for hook production, and for diagnosing which part of a weak ad to fix)

The first 3 seconds of a video ad decide whether the rest gets watched. The hook is the single highest-leverage unit in paid creative.

### A hook is three parts, not one line

| Part | What it is | Job |
|---|---|---|
| **Visual action** | What actually happens on screen in 0-3s | Stops the thumb |
| **Voiceover/line** | The first spoken line | Opens a question |
| **Caption text** | On-screen title/overlay | Anchors the claim for muted viewers |

**No-repeat rule**: the three parts complement, never restate each other. If the voiceover says "I stopped paying $60/month for a gym membership" and the caption also reads "no more $60/month," two of three slots were wasted saying the same thing. A strong hook divides the labor — visual shows the cancellation, voiceover states the line, caption names the alternative. Static ads compress this to two parts (visual + headline) — same rule: the headline can't just restate what's in the image.

### Production flow

```
Audience segment → motivation → format → hook (three parts)
```

1. **Audience segment** — who exactly this hook targets, a small group sharing a specific situation, not the whole ICP (from the input library: public reviews, public comments — not customer-service transcripts unless authorized)
2. **Motivation** — the single pain/desire/objection driving this segment, **rewritten from the input library's phrasing logic**, not copied verbatim — matching how the customer actually talks, without unauthorized verbatim quoting (see the data-handling principles this file opens with)
3. **Format** — street interview, first-person selfie, screen recording, unboxing, side-by-side test, text-overlay static, founder-to-camera, reaction/duet — pick format before writing the line; the same motivation reads completely differently written as a street-interview answer versus a confessional to-camera piece
4. **Hook** — write the three parts for this segment × motivation × format combination

**Present as a hook matrix** to make coverage visible:

```
| # | Segment | Motivation (source triple) | Format | Visual action | Line | Caption |
```

Produce horizontally (covering different segment × motivation combinations), not vertically (rewriting the same row repeatedly) — 10 hooks covering 10 combinations beats 30 versions of one, same "diversity is coverage" principle as the static template library.

### From a funnel diagnosis to what to fix

**Diagnosing which funnel stage failed (thin 3-second view rate vs. weak hold vs. weak CTR vs. weak post-click conversion) is `campaign-analysis-pro`'s call, not a table to self-apply against raw numbers** — same analysis-unit and sample-size gates as everywhere else in this file. `campaign-analysis`'s free tier gives one coarse signal worth routing on without the paid layer: rising CPM with falling CTR at stable targeting names creative fatigue and routes here — useful for "something in creative may be tired," not for which specific element to fix.

Once a stage-level diagnosis is in hand: stopped → test a new visual open (and rule out placement/fatigue/audience mismatch); held → rewrite the 3-15s bridge, not the hook; clicked-but-didn't-convert → tighten the promise/CTA/proof, but also check bid strategy and attribution window before assuming it's the creative; check landing-page message match (`landing-page-cro`) only after ruling out traffic-quality causes.

A strong 3-second open doesn't guarantee a good ad — a misleading visual pulls in the wrong viewer, producing high initial view rate paired with a collapsed hold/conversion rate (part of why winner verdicts live outside this file — a single-stage metric alone can point the wrong way). Change one element per test (visual, bridge, or offer framing) — the same single-variable rule as `SKILL.md`'s hard rules.

### Spec tiers

Production cost should track evidence strength: test intuition cheap (static, text-overlay video, remixed existing assets, 1-2 days) to validate the angle cheaply, not to produce a polished ad; only a validated angle earns full-production investment (creator shoots, street interviews, live demos).

**"Validated" has exactly one source: `campaign-analysis-pro`'s conclusion tier.**

| Conclusion | Spec tier it unlocks |
|---|---|
| **Actionable** (cleared the sample-size and comparability gates) | T3 full production |
| **Needs-more-signal** (a signal, hasn't cleared the gates) | T2 remix at most — **a single good-looking metric isn't grounds for T3** |
| No conclusion yet (new concept, untested) | T1/T2 cheap test |

**Don't self-declare "this angle is validated" from one metric** — the most common way this file gets misused: a strong hold rate on one execution shouldn't fast-track it into full production, that's committing weeks of budget on a number that never cleared the gate. Expensive shoots to test hunches, and throwaway statics to test validated angles, both waste the mismatch.

---

## Common failure modes

- **Building the roadmap without reading the three signals** — a roadmap built on no signal is a wish list; testing without a diagnosis isn't strategy
- **Filling the exploring phase with iterations** — losers get endlessly polished while the real problem (angle, offer, audience) never gets tested
- **Ignoring capacity** — scheduling more than the team can produce guarantees a stack of half-finished work
- **Ungrounded concepts cutting the line** — the loudest stakeholder's hunch jumps straight to a T3 shoot while a tier-2 customer-language concept still waits on the shelf
- **Retros as theater** — celebrate the winners, reorder nothing, shelf never updated
- **Complacency in the scaling phase** — a roadmap that's 100% variations on the current winner leaves nothing ready once it fatigues
