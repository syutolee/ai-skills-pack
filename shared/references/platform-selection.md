# Platform selection

**Strategy layer — read this before touching account structure or budget.** Which platform(s) to run on is a decision that precedes execution: it sets the constraints everything downstream (account structure, audience setup, creative format) has to work within, not the other way around. Shared across this package because more than one tactical skill needs it before starting: `ads` reads it when the user asks which platform to run; other skills point here rather than restating platform tradeoffs.

Launch coverage is Taiwan (TW) — the table below reflects that market's landscape. A skill using this file for a different GEO should treat it as a template to re-derive, not a global default; see the loaded skill's own GEO module for that market's specifics.

## Taiwan media landscape

LINE is a near-universal communication tool in Taiwan (penetration is commonly cited around 90%; check LINE's own official Taiwan figures for the current number) and belongs in the core platform set, not treated as a fallback option. Twitter/X sees low usage in Taiwan and can sit last in priority.

| Platform | Best for | When it fits |
|---|---|---|
| **Google Ads (Search + PMax)** | High-intent search traffic | The user is actively searching for your solution |
| **Meta (Facebook/Instagram)** | Demand generation, visual products | Need to create demand, have strong creative output |
| **LINE Ads Platform (LAP)** | Broad-reach, retail/food/beauty/local services | Reaching LINE's friend graph and interest audiences, especially where other platforms under-reach older or non-urban audiences |
| **TikTok** | Younger demographics, viral-format creative | Audience concentrated 18-34, video production capacity available; note review is comparatively strict — regulated/aesthetic/supplement categories are often rejected |
| **Yahoo (native + display network)** | Older demographics, brand reach on a network | Audience skews older, B2B, financial — reaches users outside the Google ecosystem |
| **Threads / X** | Tech/current-events audiences | Usage in Taiwan is still low; secondary unless the audience is demonstrably active here |

## LINE Ads Platform's distinct profile

LINE's audience data is built on friend relationships and in-app behavior (open rates, sticker usage, LINE Points) — **not cookie-based** — which makes it one of the few Taiwan channels that can still deliver precise audience profiles after iOS ATT restrictions and third-party cookie deprecation.

Remarketing through a LINE Official Account (OA) is subject to LINE's commercial-messaging terms — **the user must have added the account as a friend first; this can't be run as cold outreach the way email can.** Push frequency and content rules are in the loaded GEO module. LINE ad delivery also needs its own LINE Tag for conversion tracking — GA4/GTM don't cover it; see `tracking-health`.

## Common platform-selection mistakes

- **Splitting budget evenly across every platform.** When creative output is limited, spreading it thin starves every platform's algorithm of enough material to work with. Concentrate on one or two platforms until results are validated, then expand
- **Choosing Meta because "everyone runs Meta."** If the audience is older and local, LINE often reaches them more efficiently; if the audience is already actively searching, Google Search is cheaper than demand generation
- **Ignoring a closed-ecosystem platform's attribution limits.** When most sales happen inside Shopee/momo, off-platform ad performance can't be attributed by the seller — confirm what's actually measurable before choosing a platform, see `tracking-health`'s section on closed-ecommerce-platform attribution limits
