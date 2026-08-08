# Stop-loss thresholds

Absolute-threshold math only: break-even CPA/ROAS, how to read the marginal number's direction, and the absolute threshold that triggers a stop-loss recommendation. Comparative thresholds — the ≥10-conversion maintenance rule, TCPL, the quality×cost matrix, scale quadrants — live in `campaign-analysis`'s paid-tier comparative-judgment layer, not shipped in this free tier; this file doesn't restate them.

## Break-even CPA / ROAS

Two different numbers, two different bases. Don't convert between them — pick the one that matches the business model.

**Contribution-margin break-even CPA** (how much of a customer's lifetime gross-margin contribution the acquisition cost is allowed to eat — fits subscription, high-repeat-purchase businesses):

```
break-even CPA = LTV, gross-margin basis
                 (already net of cost of goods / fulfillment — not revenue)
```

Target CPA — the number that actually goes into the platform as a spend cap — sits below break-even with a safety margin:

```
target CPA = break-even CPA × safety factor
             (commonly 50-70%, tighter with more LTV-forecast uncertainty)
```

**Gross-margin ROAS floor** (single-order basis — fits low-repeat-purchase, single-transaction businesses):

```
ROAS floor = 1 / gross margin rate
```

**Neither number is company-wide net-profit break-even.** Both stop at gross-margin contribution — before payment-processing fees, refunds, and other variable costs. Getting closer to net-profit break-even means substituting the contribution-margin rate (gross margin rate minus payment-processing rate, refund-rate loss, and per-order support cost) for the gross margin rate above. Without that data, treat the gross-margin number as an optimistic ceiling, not a guaranteed break-even.

## Marginal ROAS/CPA: reading the direction right

Judge by the **marginal** number — the number for *this* increment of new spend — not the account's cumulative average:

1. An account-wide average ROAS (or CPA) drifting worse as spend scales up is normal on its own (reach extends into marginal, costlier users) — that alone isn't evidence of a problem.
2. **When judging whether the marginal number has crossed the line, ROAS and CPA point in opposite directions — the two don't share the same "hasn't broken the threshold yet" wording.** The ROAS threshold is a **floor (lower bound)**; the CPA threshold is a **ceiling (upper bound)**:

   | Metric | Threshold type | Still OK to keep scaling | Should stop / slow down |
   |---|---|---|---|
   | Marginal ROAS | Floor (lower bound) | Marginal ROAS **≥** the gross-margin ROAS floor | Marginal ROAS **<** the floor (breaks below it) |
   | Marginal CPA | Ceiling (upper bound) | Marginal CPA **≤** target CPA | Marginal CPA **>** target CPA (breaks above it) |

   Saying CPA "hasn't broken the threshold yet" gets the direction backwards and waves through a scale-up that's clearly over budget: target CPA NT$100, marginal CPA already NT$200 — "hasn't dropped below 100" is technically true and completely misleading, since actual cost is already double target and the increase that should have been stopped gets waved through instead. The right question for CPA is "has it gone over the ceiling," not "has it dropped below a floor."

3. When the marginal number is still in the table's "still OK to keep scaling" column, total profit is usually still growing — this is still a gross-margin-contribution-level judgment, not a guarantee of company-wide net profit.
4. **This isn't an automatic guarantee** — once marginal ROAS drops below the floor or marginal CPA breaks above the ceiling, that increment of spend is acquiring customers at a loss; stop or slow down, don't push mechanically toward the ceiling.
5. **Recompute the marginal number after every increase** (see `ads`' [`account-structure.md`](../../ads/references/account-structure.md), "Scaling pace," for the standard cadence: +20% target, never over 30% in one step, at least 3-5 days apart) — don't judge off the account-wide totals alone.

## Absolute threshold: spend far past what Target CPA implies

Use **mature spend only** — spend that's cleared the attribution window and any CRM/offline-conversion reporting lag. A "zero conversions" or "one conversion" reading inside that window isn't necessarily real; it may just not have synced back yet. `tracking-health` and the Before-you-start check in `SKILL.md` are what confirm this before any number below gets used.

```
actual CPA = mature spend ÷ mature conversions
             (mature spend with zero mature conversions counts as unbounded — always past threshold)

stop-loss on absolute threshold  when  actual CPA ≥ K × target CPA
```

This is a conservative, single-rule simplification — it covers both a genuinely zero-conversion campaign and a low-but-nonzero one (spend NT$100,000 against a NT$1,000 target CPA with 1 conversion gives an actual CPA of NT$100,000, 100× target — well past any reasonable K). It does not distinguish "clearly abnormal" from "plausible bad luck" at low conversion counts the way a statistical treatment would; that finer distinction is the paid module's job. When conversions are already ≥10, this simple ratio is the same math the paid module's maintenance rule refines further — this tier still catches the obvious cases without waiting for the pro install.

**Choosing K** — this is a risk-tolerance input, not a universal constant. State which row applies when giving a recommendation, not just the resulting number:

| Situation (first match wins) | K (spend multiple of target CPA before stop-loss) |
|---|---|
| Cash tight, budget is a hard cap, or the client wants strict waste control | 2.0 |
| Normal operation (default when no preference is stated) | 2.5 |
| Thin creative supply (no replacement ready) or an explicit learning/exploration phase | 3.0 |

**Recalibrate after 30 days live.** These are practitioner starting values, not a guarantee — once the account has its own 30-day history, replace K with a value derived from that account's actual data rather than the table above.

last_verified: 2026-08-06
Source: this package's own v1 reference (`ai-skills-pack/campaign-analysis-iteration/references/kill-keep-scale.md`), a practitioner starting-value table — not an official platform policy, so there is no external URL to re-check against. Re-verify by re-deriving K from the account's own spend/conversion history, not by looking anything up.
