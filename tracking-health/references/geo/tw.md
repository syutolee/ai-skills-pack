# Taiwan (TW)

Region-specific measurement mechanics and legal basis for `tracking-health`. General, jurisdiction-agnostic material lives in [`../privacy-compliance.md`](../privacy-compliance.md), [`../ga4-implementation.md`](../ga4-implementation.md), and the other `references/` files — this module only carries what's specific to TW.

## LINE Tag and LINE OA add-friend measurement

### LINE Tag

Running ads on LINE Ad Platform (LAP) in Taiwan needs a separately installed **LINE Tag** (LINE's own conversion-tracking tag) — GA4/GTM alone doesn't cover it. The common setup is a GTM container carrying both the GA4 tag and the LINE Tag, both firing off the same conversion event (a self-hosted site's `purchase`, for instance) so LAP spend attributes correctly.

### Add-friend: the site can measure "clicked," never "actually added"

**Don't instrument an on-site event called `line_oa_added`.** Once a user clicks the "add friend" button, the flow leaves your site and enters the LINE app — your site's JavaScript has no way to know whether the user actually completed the add or abandoned partway. Naming the button click `line_oa_added` will systematically inflate the "add-friend count" (actual add rate is typically well below click count), which then distorts any CPA or performance number computed from it. The correct model is two layers:

| Event | Sent by | Represents |
|---|---|---|
| `line_oa_add_clicked` | The site (GA4/GTM click trigger) | User clicked the add-friend button on your page — an **intent** signal |
| `line_oa_add_confirmed` | Your own backend (received and verified LINE's `follow` webhook, written to your database; **only** sent to GA4 via Measurement Protocol when you have that user's legitimate site `client_id`) | LINE reports this user is now a friend — a **result** signal |

**Confirm you have a legitimate `client_id` before sending to GA4.** Measurement Protocol's required fields, `api_secret` handling, and `/debug/mp/collect` validation are in [`../ga4-implementation.md`](../ga4-implementation.md), "Server-side events: Measurement Protocol minimum spec." The `follow` webhook itself carries **no** site-identifying information — unless the user went through the LIFF/LINE Login binding flow below and you stored the site `client_id` alongside their `userId` at that time, you have no legitimate `client_id` to attach. **Don't randomly generate one just to get the number into GA4** — that manufactures a pile of single-event fake users and pollutes user counts and conversion rates. Keep the add-friend total in your own database's reporting; let GA4 honestly lack that number.

### What the `follow` webhook does *not* give you — three common misreadings

Per the LINE Messaging API's official webhook event spec:

1. **Any query parameter on the add-friend link doesn't come back in the `follow` event payload.** "Put a one-time tracking token on the add-friend link, then match it against the webhook to know who clicked" **doesn't work on LINE** — the `follow` event returns only the platform-defined fields (event type, timestamp, `source.userId`, `webhookEventId`, `deliveryContext`, `replyToken`, `follow.isUnblocked`); there is no channel that carries your own URL parameter back. The LINE OA console's "add-friend source" stats are an **account-level aggregate**, not a per-click, per-user record either
2. **A `follow` event ≠ a new friend. Unblocking also fires `follow`.** The `follow.isUnblocked` field is what distinguishes them: `true` means the user **unblocked** (was already a friend before), `false` means **first-time add**. Counting both as "new friend" systematically inflates acquisition numbers, and the inflated portion is exactly the part that shouldn't count toward marketing performance. **Only `isUnblocked === false` counts toward `line_oa_add_confirmed`**; log `true` separately as `line_oa_unblocked` or don't log it at all
3. **The webhook endpoint is a public URL — without signature verification, anyone can forge events to inflate your "add-friend count."** Not a theoretical risk — once the endpoint URL leaks (front-end code, a public repo, an error message), forging a `follow` JSON POST to it is a few lines of code

### `line_oa_add_confirmed` needs all four preconditions (missing any one → fall back to `line_oa_add_clicked` only)

1. **Signature verification (mandatory, not optional)**: LINE puts an HMAC-SHA256 signature — keyed with the channel secret, computed over the raw HTTP request body, then base64-encoded — in each webhook request's `x-line-signature` header. The server must recompute and compare using the **raw, unparsed request body** — **not** `JSON.parse` then `JSON.stringify` back — that changes field order, whitespace, and Unicode-escaping in ways that produce a different hash, and this is the single most common cause of "signature never matches" in practice (in Express, use `express.raw()`, or preserve the raw body ahead of the JSON parser). Compare with a **constant-time comparison** (`crypto.timingSafeEqual`), never `===`. **A failed verification is discarded outright with a 4xx response — never log the event**
2. **Idempotent deduplication (mandatory)**: the same event may be redelivered — `deliveryContext.isRedelivery: true` marks a resend. Store by **`webhookEventId` as the unique key** (unique index or upsert); an existing key is simply skipped. Relying only on `isRedelivery` isn't enough — that's the platform's own flag; `webhookEventId` is what you can actually enforce on your side
3. **First-add vs. unblock routing (mandatory)**: route by `follow.isUnblocked`, per point 2 above
4. **A legitimate, explicit attribution binding (skip attribution entirely without one)**: matching "this LINE user" to "that click on the site" has exactly one defensible method — an explicit **LIFF or LINE Login** binding flow, where the user authorizes through LINE Login on your page and you obtain a `userId` tied to that site session. Without that flow, the `userId` a `follow` event gives you has **no reliable correspondence** to any click on your site — guessing by time proximity ("this follow happened within 30 seconds of that click, must be the same person") is not a valid attribution and produces large-scale mismatches at any real traffic volume

   **"Go through LIFF/LINE Login" isn't a one-line integration — miss any of these four preconditions and the resulting `userId` either doesn't match up or can't be trusted**:

   - **Same-Provider gate (the easiest to miss, and the failure mode is "the data looks fine but is entirely wrong")**: LINE's `userId` is **isolated per Provider** — the same real person gets a **completely different** `userId` under a different Provider. The LINE Login/LIFF channel and the Messaging API channel receiving the `follow` webhook must sit under the **same Provider** for their two `userId` values to actually be the same value and join correctly. Cross-Provider joins don't produce "less accurate" results — they produce **zero matches, or worse, matches to the wrong person**. **Confirm both channels share a Provider in the LINE Developers Console as the first step**, not after data fails to reconcile
   - **Never trust a `userId` sent from the front end**: LIFF's front end can call `liff.getProfile()` to get a `userId`, but that's **a value returned by JavaScript running on the user's own device** — anyone can alter it. Writing a front-end-POSTed `userId` straight to your database means anyone can claim to be any LINE user. **The backend only accepts an access token or ID token, exchanges or verifies it itself, and never accepts a `userId` sent directly from the front end**
   - **Backend token verification (mandatory)**: the LIFF front end sends an ID token (`liff.getIDToken()`) to the backend, which **verifies its signature** (using LINE's public key, or LINE's own verify endpoint) and checks every claim: `iss` is LINE's real issuer, `aud` is **your own channel's ID** (not someone else's — skipping this check means accepting a token issued for any LINE app), `exp` hasn't expired, and `nonce` matches the value generated for this flow. Only after verification does `userId` get read from the token's **`sub` claim** — never from a front-end-supplied field
   - **The OAuth flow needs `state` and `nonce`**: for LINE Login's authorization-code flow, generate a one-time `state` and `nonce` before starting authorization, store them in the user's session, and compare on callback — `state` blocks login CSRF (an attacker tricking a victim into completing a binding under the attacker's own account), `nonce` blocks ID-token replay. Both are single-use, invalidated once consumed

   **Missing any of these four → fall back to the degraded approach below**, rather than shipping an attribution report built on a "probably close enough" binding — a mismatched attribution is worse than no attribution, because it looks like real data.

last_verified: 2026-07-25
Source: LINE Developers, Messaging API webhook event reference — https://developers.line.biz/en/reference/messaging-api/

**Degraded approach when precondition 4 isn't feasible**: `line_oa_add_confirmed` can still be logged, but only as an **account-level add-friend total** (with unblocks already excluded), **not splittable by campaign or source** — the report has to say plainly "this is a total, not attributable to a specific ad or page." Getting source-level attribution requires either the LIFF/LINE Login binding, or falling back to the LINE OA console's own add-source statistics (aggregate level only).

**This whole mechanism links a LINE user identifier to on-site behavior — that's processing that can identify a specific person.** Apply [`../privacy-compliance.md`](../privacy-compliance.md)'s data-inventory and notice-obligation process (the LINE Login consent screen by itself doesn't satisfy PDPA's notice obligation below — the privacy policy still needs to state it) — don't quietly wire the two identifiers together just to get attribution working.

## Personal Data Protection Act (PDPA)

Taiwan's legal basis for tracking-related privacy work is the **Personal Data Protection Act (PDPA)**, not GDPR or CCPA — its logic doesn't map directly onto either.

- **Basic principles for collection/processing/use** (Article 5): must respect the data subject's interests, act in good faith, stay within the necessary scope of the specific purpose, and maintain a legitimate relationship with the purpose of collection
- **Legal basis for a non-government body to collect or process personal data** (Article 19): requires a specific purpose plus one of the statutorily listed conditions (explicit legal authorization, a contractual or contract-like relationship with the data subject, data the subject made public themselves or that's already been lawfully made public, academic research, the subject's consent, or benefiting the subject's own interests, among others)
- **The current text doesn't use the word "cookie"** and has no provision specifically addressing website-analytics tracking — meaning Taiwan currently has no explicit requirement like GDPR's "consent before loading an analytics tool," but that doesn't mean analytics tracking falls entirely outside the Act's scope

last_verified: 2026-07-20
Source: 《個人資料保護法》(Personal Data Protection Act), National Laws & Regulations Database — https://law.moj.gov.tw/LawClass/LawAll.aspx?PCode=I0050021

**Recent legislative development**: per public reporting, the Legislative Yuan has passed a PDPA amendment establishing an independent Personal Data Protection Commission (PDPC); the exact effective date hadn't been announced as of the verification date below. Taiwan's personal-data enforcement is trending stricter — recheck periodically rather than treating this section as settled once and for all.

last_verified: 2026-07-20
Source: public news reporting on the PDPA amendment establishing the PDPC — no consolidated official announcement page existed as of the verification date; re-check the National Laws & Regulations Database URL above and the Ministry of Justice's own announcements for the current status.

### Personal data has no exhaustive field list (Article 2)

PDPA's definition of personal data (Article 2) includes "any other information that may be used to directly or indirectly identify a specific person" — its scope can't be exhausted by a fixed list of field names, which is why [`../privacy-compliance.md`](../privacy-compliance.md)'s data-inventory process (judge every field, don't rely on a checklist) is a PDPA-conformant approach, not just good practice.

### Collection basis and use basis are two separate gates (PDPA specifics)

**Article 19 only answers "was collecting this data lawful in the first place"; it doesn't answer "can this particular use happen now."** Article 20 Paragraph 1 requires that a non-government body's use of personal data stays within the necessary scope of the original specific purpose — going beyond it needs a separate statutory basis. The same tracking data, used for different purposes, clears this gate independently each time:

| Use purpose | Usually within the original "provide the service / analytics" purpose? | What else is needed |
|---|---|---|
| **Internal analytics only** (traffic, funnels, conversion rate — data never leaves) | Usually yes (provided the privacy policy's stated collection purpose covers analytics) | Article 8 notice obligation is sufficient |
| **Ad-platform integration / conversion feedback** (sending conversion events back to an ad platform, including Enhanced Conversions, CAPI) | **Usually not** — this is providing data to a third-party ad platform for performance matching, a different purpose from "analyzing your own site," and it typically involves cross-border transfer | Notice must explicitly cover "provided to third-party ad platforms" and cross-border transfer; if it doesn't, separate consent is needed |
| **Ad personalization / remarketing** (building audiences from on-site behavior, targeting specific behavior segments, Customer Match list matching) | **Usually not** — this profiles an individual and markets based on it, clearly beyond "providing the service" | Needs separate consent or another statutory basis; must also implement Article 20 Paragraphs 2–3: **offer a free opt-out the first time data is used for marketing, and stop that use immediately once the subject refuses** |

**The opt-out has to be a real technical control, not left in a support inbox**: at minimum ① a findable, clickable opt-out entry point ② pressing it **actually stops** — stops sending that user's events to the ad platform, removes them from any existing audience/Customer Match list (a suppression list applied before every upload) ③ this state persists, not undone by clearing cookies. **An opt-out that fails ② is worse than not having one** — it's a false representation to the data subject.

**Practical test**: "does what I'm about to do fall inside the collection purpose stated in the privacy policy? Would an ordinary user reading that text expect me to be doing this?" A "no" answer means it's a new purpose.

### Article 8 notice obligation

The site needs a privacy policy stating the collecting entity's name, the purpose of collection, the categories of personal data, the period/region/recipients/method of use, the data subject's statutory rights and how to exercise them, and the consequence of declining to provide data — and it must disclose the use of analytics tools like GA4/GTM and that data may be transferred to a server abroad (GA4 data is processed on Google's US infrastructure).

**GA4's privacy-policy disclosure obligation isn't determined by the PDPA inventory alone**: even where the PDPA inventory concludes no mandatory notice is triggered, **Google Analytics' own terms of service independently require disclosing GA4/cookie use and obtaining consent where required by law** — a separate contractual obligation to Google, judged independently of the PDPA analysis.

### Special-category data (Article 6)

Medical records, healthcare, genetic data, sexual life, health examination results, and criminal record carry stricter rules than ordinary personal data — "we're only sending a pseudonymous ID" doesn't bypass this. An event name itself (`booked_hiv_test`) can disclose special-category data even with a pseudonymous identifier. A tracking plan for a regulated industry needs a separate pass through this article.
