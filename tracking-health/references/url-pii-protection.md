# URL parameters: PII leak risk and protection

Expands `SKILL.md` hard limit 1. **Read before turning on Enhanced Measurement.**

## Why "don't put PII in properties" isn't enough

"Don't put PII in properties" only covers what you **manually** set. But GA4 **automatically attaches `page_location` (the full URL, including path and query string) and `page_referrer` (the referring URL) to every event** — this is the base Google tag's behavior, **independent of whether Enhanced Measurement is on** (Enhanced Measurement separately adds scroll, on-site search `search_term`, and other auto-events — see leak channel 1, below). This is platform-automatic behavior; it doesn't filter sensitive URL content for you. If a site's URL structure puts PII in the URL, it flows into GA4 automatically with zero manually-configured properties involved:

- Password reset flow: `/reset-password?token=abc123&email=user@example.com` → email and reset token go straight into GA4
- Checkout confirmation: `/checkout/confirm?order_id=12345&email=...` → email goes into GA4
- On-site search (Enhanced Measurement's `view_search_results` auto-collects the search term): a user searching their own name, phone number, or member ID gets that string captured as `search_term`

**Hard rule: PII (email, phone, name, any verification token) must not appear in any part of the URL — not query, not path, not fragment (after `#`).** "Move PII from the query string to the URL path" isn't a fix: `page_location` collects the whole URL, so path leaks exactly the same way query does — that just relocates the leak.

**The three URL segments behave differently, and need different protection — don't only think about query:**

| Segment | Reaches the GA4 payload? | Reaches server/CDN/WAF logs? | Common misconception |
|---|---|---|---|
| **query** (`?a=b`) | Yes (the `dl` field carries it whole) | Yes | Assuming a clean GTM allowlist is enough — that only closes this one channel |
| **path** (`/reset/user@example.com`) | Yes (same as above) | Yes | Assuming "it's not a parameter so it doesn't count"; **parameter-level allowlisting doesn't reach path at all** — the most common implementation gap |
| **fragment** (`#token=abc`) | **Yes** — `page_location` reads `location.href`, which includes the fragment | **No** (browsers never send the fragment to the server) | Assuming "fragments aren't uploaded so they're safe" — true for server logs, **completely false for GA4 and any script on the page**; `location.hash` is readable by any script |

So the cleanup logic **must cover all three**: not just a query allowlist — check path segments too, and exclude the fragment from whatever gets sent to GA4.

## Four independent leak channels (don't conflate them — each has a different risk level and fix)

1. **GA4 payload**: `page_location`/`page_referrer` ride on every event GA4 collects. **This channel isn't closed by turning off Enhanced Measurement — that's the most common misunderstanding**: `page_location` is sent by the base Google tag (gtag `config` or GTM's GA4 config tag) on its first automatic `page_view`, **firing whenever the tag loads at all**, independent of Enhanced Measurement. Enhanced Measurement only adds extra auto-events (scroll, outbound clicks, on-site search `view_search_results`, file downloads, video engagement) — turning it off loses those extra events (and fields like `search_term`), **but the base `page_view` and its `page_location` still fire**. So on this channel, only two things actually work: ① a sensitive page's URL contains nothing sensitive **before the tag loads** (protection layer 1) ② `page_location` is overwritten clean **before the first hit fires** (protection layer 4; sequencing is everything). Neither of these reaches the other three channels below
2. **Same-origin Referer**: clicking a link within the same site, or loading a same-domain resource, has the browser send "the current full URL" (path and query included) as Referer by default — **not restricted** by modern browsers' default Referrer-Policy
3. **Cross-origin Referer**: loading a third-party resource (ad pixel, font, external script), or navigating away to another site, is where **modern browsers' current default Referrer-Policy (`strict-origin-when-cross-origin`) sends only the domain**, not the full path and query — different from point 2, don't assume both cases leak the full URL the same way; but a looser policy (`unsafe-url`) or an older browser can still send the full URL cross-origin
4. **A script directly reading `location.href`/`document.referrer`**: this is JavaScript-API-level access, not the browser's Referer header mechanism, so it's **entirely unaffected by Referrer-Policy** — any script running on the page (first- or third-party) can read the current URL directly. This is the one channel Referrer-Policy can't touch at all; the only fix is not loading non-essential scripts on sensitive pages

Turning off Enhanced Measurement doesn't even fully close channel 1, let alone 2–4; URL-borne PII still gets recorded in server access logs regardless.

## Protection layers (ranked by how much they actually close, not a pick-one menu)

### 1. Architecture level (the only layer that actually prevents the leak; everything else is a partial patch)

Never put email, phone, name, or a reverse-identifiable full order number in a URL at all. Password reset uses a **randomly generated, email-unrelated, server-side-mapped, short-lived** opaque token (not a hash of the email — common email formats are dictionary-attackable, so the token must have no reversible relationship to the email at all); when a page needs to show an email or order info, the server looks it up by token and renders it directly into the page content, never into the URL. Form submission prefers POST or a server-side session over GET, which exposes sensitive values in the URL. This has to be done **before the first GA4 hit fires** — the sensitive URL should never come into existence in the first place, not "generate it and then try to clean it up."

### 2. Don't load non-essential third-party scripts on sensitive pages

The only effective countermeasure against "a script reads the URL directly" — **Referrer-Policy has no effect on this channel at all**. Password-reset and checkout-confirmation pages, which may briefly carry a sensitive URL, should load only necessary first-party scripts, not the site-wide third-party script bundle out of convenience.

### 3. Referrer-Policy (narrow scope — only governs the Referer header the browser itself emits)

Set `Referrer-Policy: no-referrer` (strictest) or `strict-origin-when-cross-origin` (HTTP header or `<meta name="referrer">`). **Its real scope is narrow**: `strict-origin-when-cross-origin` still sends the full URL as Referer by default for same-origin requests or navigation — only cross-origin traffic gets reduced to domain-only; and neither setting touches layer 2's direct script access. `no-referrer` gets closest to fully blocking it, and even then it only solves the Referer-header leak.

### 4. GTM-level override of `page_location`/`page_referrer`

**A report-layer defense only, never something to rely on alone.** Build a GTM Custom JavaScript variable that allows only a known-safe marketing-attribution parameter allowlist through (`utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`, `gclid`, `fbclid`).

**Checking only whether the parameter name is on the allowlist isn't enough** — `utm_content=user@example.com` has an allowlisted name but an email value. And a **generic character-set/length/"has an `@`"/"has consecutive digits" rule is unreliable in both directions**:

- **False negatives**: a URL-encoded email (`user%40example.com`) has no literal `@` in the string; a hyphenated phone number (`0912-345-678`) slips past an "8 consecutive digits" rule; an alphanumeric-only name (`JohnSmith`) fully satisfies "legal campaign-code character set"
- **False positives**: legitimate platform-issued click IDs like `gclid`/`fbclid` are naturally long (`gclid` commonly runs 80–100+ characters) and get wrongly flagged by a length rule; `utm_term=running+shoes`'s `+` gets wrongly stripped by an overly strict character-set rule

#### A parameter name is not source authentication

**This has to be stated flatly, because "it's a platform-issued click ID, so it's trustworthy" is an easy wrong inference.** A URL is entirely controlled by whoever sends the request — anyone can visit `https://your-site/?gclid=user%40example.com` or `?fbclid=0912345678`, or post a link carrying that parameter to a forum, a social post, or an email for someone else to click. **There's no way to verify a `gclid` value that actually reaches your site** — it isn't a signature, isn't a token, has no lookup mechanism proving "this value really was issued by Google." So `gclid`/`fbclid` values get checked exactly like every other parameter — an allowlisted name doesn't earn a pass through.

#### The correct approach: decode first, then validate against what that parameter's value should look like

For every allowlisted parameter, first decode it (URL decode, then try common encodings like base64 if needed), then check the **decoded** value. This decode-then-scan judgment is the same one defined once in [`../../shared/references/input-hygiene.md`](../../shared/references/input-hygiene.md) — decode repeatedly until stable, then scan for PII shapes (names, phone numbers, email, national ID patterns). Two validation rules apply depending on the parameter:

- **Marketing tags you define yourself** (`utm_source`/`utm_medium`/`utm_campaign`/`utm_content`/`utm_term`): validate by **exact match against your own maintained campaign-code registry** — a value passes only if it **exactly equals** an entry in that list; anything not on the list is held back for manual review, never auto-passed. This is the only reliable check for these parameters, because their legal value set is one **you** define, finite, and enumerable. Prefix matching or regex approximation doesn't work either (`spring_sale`'s rule would let `spring_sale_user@example.com` through)
- **`gclid`/`fbclid`**: validate shape by **character-set allowlist**, not length — these platform-issued click IDs are URL-safe opaque strings using only `A-Z a-z 0-9 _ -` (`fbclid` may also include `.`). After decoding, any character outside that set (`@`, whitespace, CJK, `%`, `+`) means it can't possibly be a real platform-issued click ID — discard it outright. **Don't apply a length rule to these**

#### A character-set check is a syntax check, not a PII check

This distinction has to be stated flatly, or it creates false confidence:

- **`A-Za-z0-9_-` is exactly base64url's full character set.** Base64url-encode an email and stuff it into `gclid` (`user@example.com` → `dXNlckBleGFtcGxlLmNvbQ`) and it **fully passes this rule**. Same for a plain alphanumeric name (`JohnSmith`, `chenyating`) or a member ID (`A123456789`). The character-set rule only catches "leaked despite naive encoding" — the clumsiest cases
- So **"passed the character-set check" never means "no PII"** — this rule's real job is filtering out the most common low-effort mistakes; it's a **coarse first pass, not a defense line**
- **A `gclid`/`fbclid` that passes the check is still treated as an "untrusted pseudonymous identifier"**: ① its value is fully controlled by whoever sends the request, unverifiable ② it's a cross-site-linkable pseudonymous identifier, so [privacy-compliance.md](privacy-compliance.md)'s full rule set applies — governed by privacy law, belongs in the data inventory, needs a retention limit ③ never use it as a user identifier or to join against another dataset
- **The only approach that genuinely guarantees a sensitive page doesn't leak is stripping the entire query string before any tag loads** (below). A parameter allowlist, however carefully built, only ever manages "ordinary traffic on non-sensitive pages"
- With no campaign-code registry available, fall back to "decoded character-set allowlist" as a **coarse first layer only**, and state explicitly in the delivery doc "this layer necessarily has false negatives, no campaign-code registry built yet" — never claim "this layer means no PII leaked"

Assemble the clean URL after stripping unsafe parameters, then overwrite it into the GA4 config tag's `page_location`/`page_referrer` — **this only stops GA4's own reports from storing the value**; the URL itself in the browser address bar, browsing history, server access logs, and any script that reads it are all unaffected by this setting.

#### For genuinely sensitive pages: don't filter parameter by parameter, send a canonical URL instead

Password reset, checkout confirmation, and on-site search-results pages usually don't need marketing attribution tracking at all — rather than maintaining a parameter allowlist that will inevitably have gaps, **send a single canonical URL with no sensitive data at all** into GA4 for these.

**Canonical URL definition (all three parts, not just query)**: a fixed string decided server-side for this page template — `/reset-password`, `/checkout/confirm`, `/search` — **path is the template path, not the value-bearing actual path** (`/orders/A12345` → `/orders/:id`), **no query at all**, **no fragment at all**. It's a "which kind of page is this" label, not the user's actual current URL. When a report needs to distinguish product or category, send an already-known-safe custom parameter instead (e.g. `page_template: order_detail`) — don't put values back into the URL for report granularity.

Ranked by reliability:

- **Most reliable: the server doesn't emit any third-party tag on these pages at all** (not even GTM/gtag) — no tag, no payload to talk about
- **Next: in the page `<head>`, before the GTM/gtag snippet**, a first-party inline script writes the **server-rendered canonical URL** into the dataLayer or a global variable, which the GA4 config tag then reads. **Render it server-side — don't derive it front-end from `location.href`**; a front-end derivation that misses path or fragment defeats the whole point. **Sequencing is everything** — write it after the tag, or via a GTM custom-HTML tag that fires after page view, and the first `page_view` has already gone out carrying the dirty URL. **This "looks handled" configuration is the most dangerous kind, because DebugView looks clean afterward**
- **`page_referrer` must be overwritten too.** When a user clicks from `/reset-password?token=...` to the next page, that page's `dr` carries the previous page's full dirty URL — overwriting only `page_location` misses this
- Also clear the browser address bar's query **and fragment** with `history.replaceState` (reduces exposure in later events, Referer, and if the user copies the URL); this still doesn't substitute for the two points above, since the first hit may fire before it runs

### 5. Disable risky auto-events

If an on-site search field might receive PII input and can't be simply filtered, consider turning off the "site search" auto-event in Enhanced Measurement settings, replacing it with manual instrumentation that sends only a known-safe search category, not the raw search term — this, too, only closes the GA4 collection channel.

### 6. Edge and log-layer masking (the part nothing on the browser side can undo)

**Even after 1–5 are all done, one slice of leakage is already a done deal**: the moment a browser sends any request to `https://site/reset-password?token=abc&email=user@example.com`, that full URL is already recorded in CDN, WAF, load-balancer, and application-server access logs. GTM's `page_location` override happens in the browser and **can't retract a request already sent**; `history.replaceState` only changes the address bar, it doesn't reach back and edit logs. The fragment is the only part that never reaches the server, but it still reaches GA4 and any script on the page.

So there's a second pass needed at the edge and log layer:

- **Edge masking**: at the CDN/WAF/reverse-proxy layer, mask sensitive query-parameter values before writing to logs (`token=[REDACTED]`), and normalize known sensitive path patterns (`/reset/<value>`, `/orders/<value>`) before logging
- **Application server logs**: the same masking needs to happen in both the access-log format and the application's own logger — a common gap is fixing only one of the two
- **Third-party logs**: error trackers (Sentry-style), session-replay tools, and APM each keep their own copy of the full URL — mask each one individually
- **Historical logs**: logs generated before the masking rule shipped still contain sensitive URLs — include them in the data inventory and schedule deletion
- **This layer is a mitigation, not a substitute.** The real fix is still layer 1 (sensitive values never enter the URL to begin with) — a masking rule that misses a pattern gives no warning that it missed it

## Pre-launch verification: walk the full flow, check every payload, not just the first

Use a **synthetic canary**: plant a unique value that would never occur naturally in a sensitive test-environment URL (`email=canary-7f3a9b@example.invalid`, `token=CANARY7F3A9B`, type `canary7f3a9b` into a search box), run the complete flow (not just the homepage), then **search every collection point for that marker** — a hit anywhere is a fail. A unique marker lets you search once across everything instead of manually inspecting every field.

In order:

1. **Every GA4 request payload across the whole flow (the most important item, never skip it)**: open DevTools' Network tab → check **Preserve log**, clear it → run the complete flow (load the sensitive page → scroll → click → move to the next page) → filter on `collect` (the browser-side GA4 tag's request path contains **`/g/collect`** — a **different endpoint** from the server-side Measurement Protocol's `/mp/collect`; filtering the wrong path finds nothing, since the browser always uses `/g/collect`) → **search the marker across the whole Network log**, checking every request, not just the first and not just `dl`/`dr`. Check at minimum `dl` (document location), `dr` (document referrer), `ep.*` (custom event parameters), and every other custom field beyond `sr`/`ul`. **The first hit matters most** (overwriting too late shows up as "first hit dirty, rest clean") but **later hits can each carry their own leak too**: scroll events, outbound-click events, the next page's `dr` are all independent leak points
2. **GA4 DebugView**'s `page_location`/`page_referrer`/`search_term` — treat as a secondary check, not primary evidence
3. **All third-party requests**: filter Network for third-party domains, confirm none (including their Referer header) carries the canary marker
4. **Server access logs, CDN/WAF logs, error tracking and session-replay services**: search for the canary marker to confirm masking rules actually took effect — **this is the most commonly skipped step**, since the first three are all visible in-browser and this one needs a separate trip to a back-end console
5. **Path and fragment as independent cases**: besides `?email=canary...`, run the flow again with the marker in the path (`/orders/CANARY7F3A9B`) and the fragment (`#token=CANARY7F3A9B`) — parameter-level allowlist logic usually does nothing for these two, and testing query alone gives a false pass

A canary marker (or any other identifiable PII) turning up anywhere fails the check.
