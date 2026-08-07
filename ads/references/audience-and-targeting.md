# Audience understanding and targeting setup

## Where audience knowledge belongs: creative first, targeting filters second

Deep audience understanding — demographics, job titles, pain points, fears, expectations, the words they use to describe their problem — is still the highest-leverage work in paid advertising. **This means cohort-level understanding** (e.g. "SMB owners, 30-45, who complain reporting takes too long"), **never any specific individual's identifying data** (raw PII is always refused — see the loaded GEO module).

What changed is where that understanding gets used. Ad-platform algorithms have gotten much better at finding the right person on their own; stacking all that audience knowledge into the platform's targeting filters now underperforms feeding the same knowledge into the **creative** (headline, copy, visuals, hook, case study).

| Platform | Weight in creative | Weight in targeting | Note |
|---|---|---|---|
| **Meta** (post-Andromeda) | **80%+** | 20% | The algorithm rewards broad targeting + precise creative; stacking interest tags now costs performance |
| **Google Search** | 40% | **60%** | Keywords still lead — match type, search-intent tiering, and negative keywords still decide outcomes |
| **Google Performance Max** | **70%** | 30% | Audience signals are suggestions; creative and product-feed quality carry the campaign |
| **LINE Ads Platform** | 50% | **50%** | LINE's interest/demographic tags come from in-app behavior and are reasonably precise, but creative fit to local reading habits (tone, informal register) matters just as much |
| **TikTok** | **70%** | 30% | Similar algorithm logic to Meta — broad targeting + native-feeling creative wins |

These ratios are directional, not a rule — test on the actual account; results vary by industry.

**Common failure mode**: over-targeting to compensate for weak creative. Mediocre creative stacked with 12 interest tags, 3 demographic filters, and a custom audience locks the ad in front of a small crowd watching a mediocre ad. Better: write 5 creative variants targeted at different cohorts (route to `ad-creative`), serve them broadly, and let the algorithm sort out the matching.

## Meta's current playbook (the Andromeda era)

Meta shipped the Andromeda ranking algorithm in 2025, changing the targeting playbook. Old tactics (stacking interest tags, polished video creative, scaling a single winner) underperform now:

- **Creative volume is the bottleneck, static images often beat polished video** — Andromeda needs a steady stream of fresh creative to avoid fatigue; static creative costs far less to produce at volume. Spend a fixed hour a week producing new variants for the best-performing offer — volume beats polish
- **Creative is the targeting** — set only geography (country, or specific region) and let the creative do the targeting
- **Identity-trigger keywords** — take a winning ad and insert an identity/niche keyword into the headline or body: "get 462 more leads a week" → "get 462 more **dental clinic** leads a week" / "...**real-estate agent**..." — the keyword is both an identity trigger for the viewer and a targeting signal for the algorithm
- **Don't let the ad look like an ad** — ad-blocker adoption is widespread, and a polished ad-agency look now costs performance. Study what "native content" looks like on the platforms your audience actually uses, and match that aesthetic; keep a clean observation account tracking the creators your audience follows
- **Long-form copy has recently outperformed short copy** — gives the algorithm more context to route on; effect varies by industry and audience, A/B test on the account rather than treating this as a universal conclusion

## "Broad" means dropping interest/demographic filters, not exclusion lists

Before loosening interest targeting, confirm the exclusion list below is already in place.

### Exclusion list (this list only holds "actively excluded from the audience" actions)

- **Existing-customer exclusion** (suppression): existing customers shouldn't keep being paid for as if they were new-customer prospects (unless the campaign is deliberately targeting existing customers)
- **Recent-converter exclusion** (suppression): people who converted in the last window (e.g. 7-14 days) shouldn't be double-counted by repeated exposure
- **Opt-out list removal** (suppression): people who've opted out of marketing, or who shouldn't be reached under the business's own policy. **This one has a legal basis** — see the loaded GEO module for the specific law and, critically, the correct implementation: suppress locally before generating the upload file, never upload the opt-out list itself as an "excluded audience" (that hands their identifier to the platform, the opposite of the intent)
- **Legal age exclusion**: when the product or offer has a legal minimum age (alcohol, gambling categories), exclude the underage segment from targeting. **This is the only exclusion driven purely by law** — entirely separate from Special Ad Category, below
- **Short-visit exclusion** (remarketing audiences only): visitors with very short dwell time (e.g. <10s, usually a mis-click or bounce) shouldn't be pulled into a remarketing audience

### Compliance obligations (not exclusions — putting these in the exclusion list misleads the setup)

#### Meta Special Ad Category (SAC) = a disclosure obligation, and the platform then restricts your own targeting options

**The SAC category list changes by market and over time — don't memorize it as a fixed global list.** The long-standing core three are **Employment, Housing, and Credit**; Meta has since expanded or restructured Credit in some markets into a broader **Financial Products and Services** category, effective 2025-01-21 for US advertisers and advertisers delivering to the US/Canada/parts of Europe, folding investment and insurance marketing that wasn't previously under Credit. **"General financial marketing and insurance don't count as SAC" is no longer a safe one-line conclusion** — it only holds for specific markets and time windows.

last_verified: 2026-07-25
Source: <https://www.facebook.com/business/help/1157846251802527> — re-check this page directly; a category boundary like this one moves independently of this file's own revision history.

**Actual determination (rerun every time you launch — never cite this file or any secondhand summary as the answer):**

1. **Advertiser/payment-entity location** — the Meta announcement is explicit: the new financial category applies to **US advertisers**, and to advertisers delivering to the US/Canada/parts of Europe. **The first half is independent of delivery region**: a US-registered advertiser billing through a US payment method may be in scope even if delivery is Taiwan-only. Check the ad account's business location, billing country, and payment-entity registration (if these disagree, use the strictest)
2. **Actual delivery regions** — SAC also follows delivery region; a primarily-Taiwan campaign that also delivers to the US/Canada/parts of Europe falls into scope
3. **Policy effective date** — a category change has a specific effective date (e.g. 2025-01-21 for financial). "Does this apply now" depends on which side of that date the delivery window falls, not memory of "it wasn't required before"
4. Open the ad account's campaign-creation flow and check **which options the Special Ad Category dropdown actually lists right now**
5. Cross-check against Meta's current official policy and Business Help Center pages

**All five checks run every time, not just whichever one seems to apply.** Check 2 (delivery region) alone is the most common miss — it's the source of the "primary market is Taiwan so this doesn't apply" error.

**When the checks disagree (the dropdown isn't the final word):**

- **Official policy says it applies, but the dropdown has no matching option** → **stop and escalate to Meta support before publishing.** Don't treat a missing option as non-applicability — the account may not be on the updated interface yet, or the option lives at a different level. A missing option is an interface state, not a policy exemption; the advertiser bears the responsibility if this is later judged non-compliant, and a missed disclosure can get the ad taken down or the account restricted
- **The dropdown has the option, official pages don't document it** → follow the dropdown (the conservative side), and log it
- **Both point to applicable** → disclose

**Log the outcome of all five checks in the delivery document**, each with its verification date and basis (which page, which screen): ① advertiser/payment-entity location ② actual delivery regions ③ effective date vs. delivery window ④ what the dropdown currently lists ⑤ what the current official policy page says. Missing any one means the check isn't complete — don't publish.

**What happens after disclosure (this part doesn't change with the category revision)**: **Meta removes targeting options you'd otherwise have** (age, gender, precise ZIP targeting, detailed-interest targeting in that category, lookalikes, some automatic expansion) — the audience gets **broader**, so "disclose SAC" and "exclude some audience" aren't just different, they're **opposite directions**. **Never build an exclusion audience to "handle" a special category**: the mechanism doesn't work that way, and SAC exists specifically to prevent differential treatment of protected groups — self-excluding a group risks violating platform policy on its own.

Medical-facility and supplement advertising is generally governed by content policy (health claims, personal-attribute rules), not SAC — a separate rule set; don't fold it into an SAC determination.

#### No copy implying the viewer's personal status (a copy rule, applies to any industry)

Regardless of SAC disclosure status, Meta's personal-attributes policy prohibits copy that directly asserts or implies a viewer's health, financial, or sexual-orientation status (e.g. second-person copy like "struggling with debt?" or "have this condition too?"). Use general statements instead of direct assertions about the viewer's personal state. **This governs how copy is written, unrelated to how targeting is set.**

## Remarketing strategy

### By funnel stage

| Funnel stage | Audience | Message | Goal |
|---|---|---|---|
| Top | Blog readers, video viewers | Educational content, social proof | Move to consideration |
| Middle | Visited pricing/product pages | Case studies, book a consult | Move to decision |
| Bottom | Cart abandoners, active trial users | Urgency, objection handling | Convert |

### Remarketing time windows

| Stage | Window | Frequency cap |
|---|---|---|
| Hot (cart/trial) | 1-7 days | Can run higher |
| Warm (viewed key pages) | 7-30 days | 3-5x/week |
| Cold (any visit) | 30-90 days | 1-2x/week |

Apply the exclusion list above before building any remarketing audience — remarketing audiences are especially prone to two problems: burning spend on recent converters, and inflating audience size with short-visit noise. **Time-window settings don't substitute for those exclusions.** Special Ad Category isn't on this list — it's a disclosure obligation with platform-side targeting restrictions, not an audience to exclude.

Fatigue-detection frequency thresholds (safe/warning/danger zones) are a performance judgment, made in `campaign-analysis`.

### Remarket with a different offer, not the same one

Traditional remarketing re-serves the same offer to non-converters. More effective: **the most common reason someone didn't buy is that the offer wasn't right for them.** Pushing the same thing harder doesn't fix that. Use a **different** product/service/offer from the catalog instead:

- Browsed supplements, didn't buy → remarket a different category (e.g. beauty)
- Downloaded a lead magnet, didn't book → offer a different, related lead magnet
- Viewed pricing, didn't fill the form → offer a free assessment or consultation instead

This often lifts results meaningfully in practice, but the size of the lift varies too much by industry, audience, and offer to promise — **never commit to a specific ROAS multiple**, use "worth testing," not "guaranteed."

### Follow up with people who didn't convert

For people who downloaded a lead magnet or entered the funnel without buying, schedule a call or message asking what held them back. This first-hand feedback is some of the best raw material for objection-handling creative — feed it into `ad-creative`'s input library (note: interview content is non-public one-to-one communication; confirm consent before adding it to the library — see that skill's data-handling section).
