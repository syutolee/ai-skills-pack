# Account structure, naming, and budget

Dollar amounts below use NT$ as an illustrative currency (this pack's launch market); substitute the local currency for other markets.

## Account organization

```
Account
├── Campaign 1: [objective] - [audience/product]
│   ├── Ad set 1: [audience variant]
│   │   ├── Ad 1: [creative variant A]
│   │   ├── Ad 2: [creative variant B]
│   │   └── Ad 3: [creative variant C]
│   └── Ad set 2: [audience variant]
└── Campaign 2...
```

**What each layer owns decides which numbers can be trusted for which judgment later** — this is foundational at performance-review time; getting the layer wrong turns a structural problem into a false creative verdict. Full three-layer definitions and analysis-unit rules belong to whichever skill does that comparative judgment (`campaign-analysis` and its paid comparative module, where installed). When setting up the account, remember one thing now: **budget and audience sit at the ad-set layer (or campaign layer under CBO), creative sits at the ad layer** — that split decides the analysis unit for "who did the platform actually give the budget to" later.

## Naming convention

```
[platform]_[objective]_[audience]_[offer]_[date]

Examples:
META_conversion_lookalike-existing-customers_flash-sale_2026Q1
GOOG_search_brand-terms_book-consult_always-on
LAP_traffic_line-friends_shopee-referral_2026Mar
```

Naming isn't cosmetic — **when a performance export only has the campaign name and a manual naming field with no creative identifier, there's no way to confirm two rows are the same creative** (see `campaign-analysis`'s "analysis unit"). A consistent naming convention keeps the export at least legible, but **it doesn't substitute for an export that carries `creative_id`/`asset_id`**.

## Budget allocation

**Testing phase (first 2-4 weeks):**
- 70% to already-validated campaigns
- 30% to new audience/creative testing

**Scaling phase:**
- Concentrate resources on validated winning combinations
- Wait at least 3-5 days after each budget increase for the algorithm to relearn

**Two-campaign structure (keep scale and test separate so testing never starves):** run two CBO campaigns against the same audience — a scale campaign at ~80% of budget carrying only validated winners, and a test campaign at ~20% with its own protected budget for new concepts and iterations. Reason: inside a single CBO, whichever ad set already has a winner will always absorb the budget, so a new test never accumulates enough spend to be judged. **This split is budget protection, not audience segmentation.**

## Scaling pace (increases and decreases are two different rules — don't mix them)

- **Increase (scale up):** target increment **+20%**, never more than **30%** in a single step, at least 3-5 days between increases. The strongest evidence behind "a single increase over 30% resets the platform's learning" comes from **Meta's CBO/learning-phase mechanism**; Google Ads Smart Bidding, LINE Ads Platform, and TikTok each have a similar "large adjustments retrigger learning" behavior, but the actual sensitivity threshold, day count, and criteria aren't identical across platforms — **don't carry Meta's validated 30% over to another platform as a guarantee**; test with small increments and observe first
- **Decrease (emergency stop-loss):** a different move entirely, **the "never more than 30% in one step" rule above doesn't apply here** — a single 20-30% cut to stop the bleeding is fine; hold 2 weeks after the cut, then resume with a slow +10%/week recovery (recovery reuses the scale-up pacing above). **But don't claim a decrease never retriggers learning** — that overstates it: the platform's learning phase is triggered by "did this ad set have a significant edit," and a large budget change, including a decrease, can count as one; it's just that **in a stop-loss situation, accepting the relearning risk is usually cheaper than continuing to burn spend at the original budget** — a tradeoff, not a free pass. Practical guidance: cut in steps where possible; after a 20-30% cut, treat the following 3-7 days of results as possibly mixed with relearning noise, and don't use those days alone for a stop-loss/keep decision

**When to increase or decrease is a performance judgment, made in `campaign-analysis-pro`.** This file only answers "once you've decided to adjust, by how much and how often."

## Ad count and feeding capacity

More active ads than the budget can feed = every ad starves, none of them can be judged fairly.

**Calculate this when setting up the account — don't default to 6-10 without confirming the campaign can even compute the number.**

The formula's core is "each ad needs to accumulate 2x its target cost-per-conversion within 14 days," so **the precondition is a clearly defined target cost-per-conversion for this campaign.** TCPL (target cost per qualified lead) is the lead-gen version, originally defined in the context of Meta lead-gen campaigns. **Other campaign objectives need to be mapped first:**

| Campaign objective | Cost value substituted into the formula | Applies? |
|---|---|---|
| Lead/form (Meta qualified leads, Google lead gen) | **TCPL** (target cost per qualified lead) | Yes — the formula's original context |
| Sales/purchase | **Target CPA** (target cost per order). ROAS-only targets need converting first — **normalize ROAS to a multiple before dividing**, see below | Yes |
| App install | **Target CPI** | Yes |
| Awareness, reach, video views, or other objectives **with no conversion event** | None | **Doesn't apply — don't force a fake TCPL onto it.** This objective class isn't judged by conversion count; how many creatives can run concurrently is instead bounded by the platform's optimization-event volume needs (e.g. Meta's weekly optimization-event minimum for the learning phase) and available budget. State plainly that any creative conclusion here is observational, with no conversion-level win/lose verdict |

### ROAS unit normalization (do this before dividing, always)

**A target ROAS gets written in three different units, and plugging the wrong one into the formula produces a 100x error.** Treating `400%` as `400` turns the correct "average order value ÷ 4" into "÷ 400" — target CPA drops from NT$500 to NT$5, and the resulting ad-count ceiling comes out **100x too high**, invalidating the whole account structure recommendation.

| What the user wrote | Normalized value to substitute |
|---|---|
| `400%`, `400 %` (with a percent sign) | `4.0` (divide by 100) |
| `4x`, `4X`, `4 times` (with a multiple unit) | `4.0` |
| `4`, `15`, `400` (a bare number, **no unit at all**) | **Can't be inferred — always ask** |

- **A bare number with no unit: fail closed, always ask back, never guess.** An earlier rule said "≥20 treat as a percentage, <20 treat as a multiple" — that threshold was itself a guess: `4` could mean 4x or 4% (a plausible ad-spend-to-revenue ratio at ecommerce scale), same for `15`. Guessing wrong runs in the expensive direction — treating `4%` as `4x` overstates target CPA by 100x with no symptom to flag it. **No exception based on the value's size.**
  - Ask like this: "You wrote a target ROAS of `4` — is that **$1 spent returns $4 in revenue (4x)**, or **ad spend is 4% of revenue**? These produce target CPAs 100x apart, so I won't guess."
  - Until confirmed: **don't output an ad-count ceiling or target CPA for this campaign at all** — not even a number flagged "pending," since a flagged number still gets used downstream
- **Normalized value's reasonable range is `0.5`–`20`.** Outside that range, or a string that doesn't parse as a number (`"four hundred"`, `"a decent ROAS"`, blank) → **don't guess, ask** rather than proceeding on an assumed value
- **The range check doesn't replace the unit confirmation**: `4` sitting inside the reasonable range proves nothing about whether its unit is a multiple — the two checks each test something different, both are required

Once normalized:

```
target CPA = average order value ÷ normalized target ROAS (as a multiple)
```

Example: average order value NT$2,000, target ROAS `400%` → normalized to `4.0` → target CPA = 2000 ÷ 4 = **NT$500** (not NT$5).

### Ad-count ceiling formula

Only compute once the objective maps to a cost value above. **Three steps, each with a single deterministic integer result:**

```
Step 1: feed budget  = (campaign daily budget × 14) ÷ (2 × target cost-per-conversion)   ← may be a fraction
Step 2: max active ad count = floor(feed budget)                                          ← round down to an integer
Step 3: starting ad count   = min(ceiling, 10)
        but if this campaign currently has ≤2 validated winners → min(ceiling, 6)
```

**Why two starting counts (10 vs. 6), and the condition that decides which:** the extra slots beyond validated winners are test slots. ≥3 validated winners (met target in the past 90 days and still running) → open to 10, roughly 7 test slots, budget has a winner to lean on. ≤2 validated winners → almost the whole campaign is test slots, so cap at 6. **"6-10" isn't an actionable answer — always output a single determined integer.**

Branches (based on Step 2's integer ceiling):

- **Ceiling ≥ 10** → start at 10 (≥3 winners) or 6 (≤2 winners). Example: feed budget 10.1 → ceiling 10
- **Ceiling 1-9** → **use the ceiling as-is**, don't apply the 6/10 rule. Example: daily NT$1,500, TCPL NT$3,000 → feed budget 3.5 → ceiling 3 → run at most 3 ads; daily NT$500, TCPL NT$3,000 → feed budget 1.17 → ceiling 1 → **run only 1 ad** (feedable, but this budget isn't ready for creative testing)
- **Ceiling = 0** (feed budget <1) → **report insufficient budget, don't recommend running any test structure.** Example: daily NT$300, TCPL NT$3,000 → feed budget 0.7 → ceiling 0, can't feed even one ad. State plainly that no judgeable creative conclusion is possible at this budget, and name the budget threshold that would change that

To add a new test slot once at the ceiling, an existing ad has to hit its stop-loss threshold first.

last_verified: 2026-08-06
Source: this package's own v1 reference (`ai-skills-pack/ads/references/account-structure.md`), a practitioner starting-value table (budget splits, scaling pace, the ad-count ceiling formula's constants) — not an official platform policy, so there is no external URL to re-check against. Re-verify by re-deriving these against the account's own data, not by looking anything up; the Meta/Google/LAP/TikTok relearning-trigger behavior cited under "Scaling pace" is each platform's own mechanism and moves independently of this file, so confirm current behavior on the account before relying on the 30% figure there.
