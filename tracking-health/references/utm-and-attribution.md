# GTM structure, UTM strategy, and closed-marketplace attribution limits

## Google Tag Manager container structure

| Component | Purpose |
|---|---|
| Tags | The code that actually runs (GA4, Pixel, a regional platform's tag) |
| Triggers | When a tag fires (page view, click) |
| Variables | Dynamic values (click text, dataLayer, custom JavaScript) |

### dataLayer pattern

```javascript
dataLayer.push({
  'event': 'form_submitted',
  'form_name': 'contact',
  'form_location': 'footer'
});
```

GTM custom-JavaScript variables are commonly used to override `page_location` — **the sequencing trap and the correct approach are in [url-pii-protection.md](url-pii-protection.md), protection layer 4**.

## UTM parameter strategy

| Parameter | Purpose | Example |
|---|---|---|
| `utm_source` | Traffic source | `google`, `newsletter` |
| `utm_medium` | Marketing channel | `cpc`, `email`, `social` |
| `utm_campaign` | Campaign name | `spring_sale` |
| `utm_content` | Version differentiator | `hero_cta` |
| `utm_term` | Paid-search keyword | `running+shoes` |

Naming rule: all lowercase, consistently hyphenated or underscored, specific but concise (`blog_footer_cta`, not `cta1`), every UTM logged in a shared registry. **This shared registry is the same "campaign-code registry" [url-pii-protection.md](url-pii-protection.md) uses for GTM allowlist exact-matching** — the two share one dataset, don't maintain a second copy.

## Closed marketplace platforms: structural limits (a UTM parameter alone produces no data you can query)

Closed marketplace platforms don't let sellers install their own GA4/GTM tags — only the platform's own back-end reports are visible. **"UTM tracks traffic into the marketplace" doesn't hold** — a UTM is just a parameter riding on a URL; **producing any queryable tracking data requires an analytics tool at the destination reading and logging it**. On a closed platform, the seller has no access to what UTM their own storefront URL carried, so **there is no attribution data available to the seller at all** — this isn't "attribution is a bit coarse," it's a structural absence.

**But be precise: the parameter doesn't "vanish."** The query string still travels with the HTTP request all the way to the destination; the servers, CDN, WAF, reverse proxies, and access logs along the way may well log the full URL, and the platform itself can see it. The difference is **access**, not existence. This matters because it cuts the other way too: **don't put sensitive content into an outbound link's URL just because "the UTM disappears anyway"** — it doesn't disappear, it just flows into logs you don't control.

### Three approaches that actually produce queryable data

1. **A mechanism the platform officially supports**: an affiliate/referral link program, a platform-issued campaign code — these are attribution methods the platform itself recognizes and reports numbers back on
2. **A redirect service you control that logs the click**: log the click once, then forward to the marketplace (gives a click count, not whether the visit converted)
3. **Send to your own landing page first** (which can run GA4/Pixel), with a button forwarding to the marketplace listing — at least the landing-page interaction is trackable

**Without any of the three, the only honest numbers to report are the ad platform's own click, impression, and spend figures** — claiming "this drove X visits to the store" has no data behind it. This is a structural gap between marketplace sellers and businesses running their own site, and it needs to be explained plainly at delivery time.

### Approach 2's (self-built redirect) three mandatory safeguards

Not just a tracking configuration — skipping any one of these hands the client an open vulnerability:

- **Destination fixed to a backend-maintained allowlist, to block open redirect**: the redirect target can only come from a backend allowlist (domains, full URLs, or an internal short-code mapping). **Never accept an arbitrary URL from the query string and redirect to it blindly** (`shortdomain/go?url=...`) — that's a ready-made phishing vector where the victim sees a trusted domain, and search engines and ad platforms may flag it as abuse. Compare against the **fully resolved domain**, never `startsWith` or substring containment (`https://marketplace.com.evil.example` would pass a substring check)
- **Log only the minimum fields needed for counting**: a redirect service's logs (IP, User-Agent, Referer) count as potentially-identifying personal data under privacy law. Keep only what's genuinely needed for the click count (timestamp, short code, destination); truncate or drop IP entirely
- **Set an explicit, short retention window**: e.g. auto-delete after 30 days, documented in the privacy policy's retention section

## General attribution notes

- Platform self-attribution tends to run high.
- Use UTM parameters consistently.
- Cross-check platform numbers against GA4.
- Judge by blended CAC across all channels, not a single platform's CPA in isolation.
