# GA4 implementation: event naming, ecommerce schema, revenue correctness

Expands `SKILL.md` hard limits 4 and 5. Answers: how to name events, what ecommerce events need, and why revenue numbers don't match.

## Tracking-plan framework

```
event name | category | properties | trigger timing | notes
```

| Type | Example |
|---|---|
| Page view | Auto-fires, extra properties can be attached |
| User behavior | Button click, form submit, feature use |
| System event | Signup completed, purchase, subscription change |
| Custom conversion | Goal reached, funnel stage |

## Event naming

### Custom events: `object_action`

```
signup_completed
button_clicked
form_submitted
article_read
```

- All lowercase, underscore-separated.
- Be specific: `cta_hero_clicked` beats `button_clicked`.
- Context goes in properties, not the event name.
- No spaces or special characters.
- Record every naming decision.

**Ecommerce events are the exception — don't invent your own names.** Be precise about what breaks without the official reserved names, don't overstate it: a custom event name (`product_viewed`, `checkout_started`) can still be marked a Key Event in GA4 and imported into Google Ads as a conversion action — that part isn't blocked. What actually breaks: GA4's built-in Monetization/ecommerce reports (item-level revenue, purchase funnel, Shopping-ads product data) only recognize the official reserved names and their `items` structure, so a custom event never appears there; and `transaction_id` deduplication only applies to the official `purchase` event, so a custom event has no dedup mechanism and easily double-counts the same order.

## Core events

### Marketing site

| Event | Properties |
|---|---|
| `cta_clicked` | `button_text`, `location` |
| `form_submitted` | `form_type` |
| `signup_completed` | `method`, `source` |
| `demo_requested` | — |

GEO-specific channel events (e.g. a regional messaging app's add-friend click) live in the matching `references/geo/<code>.md` module, not here.

### Product / app (non-payment behavior)

| Event | Properties |
|---|---|
| `onboarding_step_completed` | `step_number`, `step_name` |
| `feature_used` | `feature_name` |
| `subscription_started` | `plan` (lifecycle state change, not the payment act itself) |
| `subscription_plan_changed` | `old_plan`, `new_plan` |
| `subscription_cancelled` | `reason` |

**A subscription's payment event is always the official `purchase`, never a custom `purchase_completed`.** Whether it's a one-off retail sale or a subscription's first charge or a recurring renewal charge — "money actually changed hands" always uses `purchase`. Inventing a separate naming scheme for subscriptions is what makes revenue reports stop reconciling. `subscription_started`/`subscription_plan_changed`/`subscription_cancelled` record subscription **state** changes — usually fired alongside `purchase` in the same operation (a new subscription: `purchase` records the money, `subscription_started` records the state) but they're different responsibilities, not substitutes for each other. **Recurring renewal charges have no front-end page to instrument from — they must be triggered by a backend payment webhook** (see "`purchase`'s authoritative trigger," below).

## Ecommerce events (GA4's official schema — reserved names are mandatory)

Ecommerce event parameters carry one of three necessity levels: required, conditionally required, optional.

| GA4 event | Fires when | Parameter necessity |
|---|---|---|
| `view_item` | Product detail page viewed | **Required: `items`** (array). Conditionally required: `currency` (only if `value` is also sent — `value` itself isn't mandatory). Optional: `value` |
| `add_to_cart` | Added to cart | **Required: `items`**. Conditionally required: `currency` (same rule). Optional: `value` |
| `begin_checkout` | Checkout started | **Required: `items`**. Conditionally required: `currency` (same rule). Optional: `value` |
| `purchase` | Backend confirms payment succeeded (including a subscription's first charge and every renewal) — **never** "user reached the success page" | **Required: `transaction_id`, `items`**. Conditionally required: `currency` (only if `value` is sent — most stores send `value` for revenue reporting, but don't assume it's always present). Optional: `value`, `shipping`, `tax` |

last_verified: 2026-07-20
Source: Google Analytics Developers, "Recommended events" — https://developers.google.com/analytics/devguides/collection/ga4/reference/events

**Inside the `items` array**: each item object needs only **one of `item_id` or `item_name`** (not both); `price`, `quantity`, `item_category` are all optional. Filling them all in is still worth doing (item-level reports and Google Ads dynamic remarketing need the full data), but the only fields GA4 actually flags as missing are "`item_id` or `item_name`, at least one" plus the event-level `transaction_id`/`items` array itself.

### `transaction_id` must not be reverse-identifiable

`transaction_id` is `purchase`'s required field, and GA4 uses it to prevent double-counting the same transaction — but **don't use the sequential order number the customer sees** (`ORDER_20260720_001`) as `transaction_id`. GA4 data routinely gets exported to smaller audiences than the original order system (BigQuery, Google Ads conversion import, agency access), and a predictable, sequential ID is easy to enumerate or cross-reference against another leaked dataset. Correct approach: `transaction_id` is a **random opaque value unrelated to the customer-facing order number** (a UUID), with the backend maintaining a separate "GA4 `transaction_id` ↔ internal order number" mapping table (kept in your own database, never sent to GA4). Same for subscription renewals — each charge gets a fresh random ID, never a predictable "subscription ID + sequence number" composite.

**This random `transaction_id` is itself a pseudonymous identifier — personal data**, since your own mapping table is the re-identification path. It's allowed in GA4 (direct identifiers aren't, pseudonymous ones are) but subject to the retention-limit and access-control preconditions in [privacy-compliance.md](privacy-compliance.md), "direct identifier vs. pseudonymous identifier." The mapping table's own access list matters most — anyone who can read it sees the equivalent of a direct identifier.

### `transaction_id` deduplication: three cases (don't simplify to "IDs can't repeat")

| Case | GA4's behavior | Is this a problem? |
|---|---|---|
| Same transaction, **same** ID every time | Treated as a duplicate of the same transaction, counted once | **Not a problem — this is the intended design.** A payment webhook resent by the provider, or an unconfirmed outbox retry, should land here |
| Same transaction, a **different** ID each time (or no ID) | Every event treated as an independent transaction | **Problem: revenue inflation.** Typically caused by the front end calling `crypto.randomUUID()` fresh on every load, or the backend never persisting the ID |
| **Different** transactions sharing one ID | The later transaction gets discarded as a duplicate of the earlier one | **Problem: revenue undercount.** Typically caused by using a member number, cart ID, or subscription ID as `transaction_id` — each renewal charge is an independent transaction and needs its own new ID |

One rule: **the ID binds one-to-one to the transaction** — the same transaction always gets the same ID, different transactions always get different IDs.

Retries or page reloads for the same transaction must reuse the same **persisted** ID — read it from that transaction's own server-side record (bound to the order, stored), sent unchanged on every `purchase` trigger. Generating a fresh ID on every front-end page load breaks deduplication entirely.

### `purchase`'s authoritative trigger is a backend order-confirmation or payment webhook

"Fire `purchase` on the payment-success page" is the most common implementation, and the most common cause of revenue not reconciling. It's wrong in both directions:

- **Undercounts**: ① a subscription's **recurring auto-renewal has no front end at all** — users don't revisit a success page monthly, so front-end instrumentation systematically misses subscription revenue ② the user closes the tab right after paying, or a third-party payment method never redirects back to the success page ③ non-instant payment methods (bank transfer, cash voucher) confirm payment days after the order, so the success page isn't the payment-completion moment at all
- **Over- or mis-counts**: reaching the success page doesn't mean money actually landed — authorization succeeded but capture failed, fraud review caught it after the fact, the user cancelled immediately — any of these can leave a `purchase` recorded in GA4 for revenue that doesn't exist

**Correct approach: the backend's "order status became paid" is the single authoritative source, and the whole transaction sends GA4 `purchase` exactly once** — on receiving the payment provider's webhook (or an active reconciliation query) and confirming the status, the **server** sends it via GA4 Measurement Protocol. The success page **doesn't send GA4 `purchase`** — it isn't a secondary source or a fallback, it just doesn't send it.

- **"Front end sends first, backend confirms and sends again" is not a safe design — don't build it this way.** `transaction_id` deduplication only holds within the **same GA4 data stream and the same GA4-resolved user**; front-end `gtag` uses the browser cookie's `client_id`, and if the backend's Measurement Protocol call doesn't reuse that same `client_id`, the two events can land on different users and GA4 won't reliably merge them. More fundamentally, **deduplication isn't correction**: if the front-end event carried the wrong amount, or the payment never actually completed, the backend event can't overwrite it — `transaction_id` has no "retract" semantics, only `refund` can offset it, and that's a separate event, not a fix
- **Triggering other ad platforms' conversion pixels on the success page is a separate matter — don't conflate it with GA4.** Some teams fire a Google Ads conversion tag, Meta Pixel `Purchase`, or a regional tag on the success page — those are **that ad platform's own conversion event**, running through its own channel, and **don't constitute a second GA4 `purchase`**. Fine to do, but two conditions apply: ① **only trigger after the backend payment-confirmation response returns**, not on reaching the success page (otherwise the ad platform over-counts the same way) ② that code path must **not** call `gtag('event', 'purchase', ...)` or anything sending `purchase` to a GA4 stream. Any `purchase` seen on the success page during a health check is a bug regardless of whether the backend also sent one
- **Renewal charges always go through the backend**: each charge is an independent transaction with its own fresh random `transaction_id`, triggered by the payment webhook
- **Payment-webhook verification isn't a single universal method** (see "Payment webhook verification," below), but signature verification plus idempotent deduplication are both mandatory regardless of provider — skip either and a forged payment notification becomes fake revenue
- **Refunds/cancellations** need a matching GA4 `refund` event (same `transaction_id`) — don't just update your own database's status and leave GA4's revenue number untouched

Payload shape (this is the **backend** Measurement Protocol event body — full request format below):

```json
{
  "name": "purchase",
  "params": {
    "transaction_id": "a1e4c9f0-6b2d-4e77-9c3a-8f21d6b7c9e2",
    "currency": "TWD",
    "value": 1280,
    "items": [
      { "item_id": "SKU123", "item_name": "Moisturizing serum", "price": 640, "quantity": 2 }
    ]
  }
}
```

`transaction_id` is a random UUID the backend generates and persists when the order is created; its mapping table lives in your own backend. **This payload has no front-end version** — the rule at the top of this section has no exception.

**Scope**: this ecommerce schema only applies to **self-hosted sites that can install GA4** (your own build, or platforms like 91APP/Shopline). Closed marketplaces that don't allow sellers to install third-party tracking can't use this schema at all — see [utm-and-attribution.md](utm-and-attribution.md).

### Server-side events: Measurement Protocol minimum spec

Any event sent by a server (backend `purchase`, a regional messaging platform's follow-total count) goes through GA4 Measurement Protocol. **Spec mistakes fail silently** — all four points below matter.

**① Minimum request**

```
POST https://www.google-analytics.com/mp/collect?measurement_id=G-XXXXXXX&api_secret=<SECRET>
Content-Type: application/json

{
  "client_id": "1234567890.1234567890",
  "events": [
    { "name": "purchase", "params": { "transaction_id": "...", "currency": "TWD", "value": 1280, "items": [...] } }
  ]
}
```

| Field | Location | Notes |
|---|---|---|
| `measurement_id` | query string | The web data stream's `G-` ID (**not** the property ID, not the app's `firebase_app_id`) |
| `api_secret` | query string | Created under Admin → Data Streams → Measurement Protocol API secrets. **Only ever lives in backend env vars / a secrets manager** — leak it into front-end code or a repo and anyone can forge events to inflate your numbers; rotate immediately if that happens. **The full request URL (including `api_secret`) must never land in access logs, APM traces, exception stack traces, or an outbox's `last_error` field** — these are commonly-overlooked leak surfaces just as real as the codebase; assemble the URL with the secret only right before sending, and log only the path plus masked parameters |
| `client_id` | body, required | Which user this event counts against — see point ③ |
| `events` | body, required | Event array; parameter requirements are identical to front-end `gtag` (see the ecommerce schema above) |

**② A 2xx from the standard endpoint doesn't mean the event is valid**

`/mp/collect` returns 2xx with no error message for malformed payloads, illegal event names, or missing fields. **Validation must go through `https://www.google-analytics.com/debug/mp/collect`** (same query string and body) — it returns a `validationMessages` array; an empty array is the only pass condition. Run every backend event type against the debug endpoint before launch and save the response in your verification record — see [debug-validation.md](debug-validation.md).

**③ `client_id` decides whether the event links to on-site behavior**

- **When there's a site origin**: pull `client_id` from the browser's `_ga` cookie (the last two segments of the `GA1.1.<client_id>` format, i.e. `1234567890.1234567890`), persist it with the order during checkout, and reuse it when the backend sends the event. This is the only way to keep the backend `purchase` in the same GA4 user as the browsing session that led to it
- **Session linkage is a separate concern**: even with the right `client_id`, the backend event won't automatically attach to the user's session at that time. That needs `session_id` (also captured front-end and persisted with the order) plus `timestamp_micros`, and Measurement Protocol has a limit on how far back it'll backfill — an event too late won't attribute to the original session. **Attribution reports may therefore classify a backend `purchase` as direct** — this is a known limitation, document it in the tracking plan rather than treating it as broken tracking later
- **Never fabricate a `client_id` when there's no legitimate one**: a random `client_id` manufactures a pile of single-event fake users and pollutes user-count and conversion-rate numbers. A server-only count with no corresponding browser session (see the GEO module's messaging-platform section) stays in your own database, not force-fit into GA4

**④ Idempotency needs a stateful outbox, not "skip if already exists"**

Measurement Protocol has no built-in retry deduplication — resending means double-counting. But **a naive "create a unique record before sending, skip if it already exists" silently drops events**: between creating the record and getting GA4's response, the request might never have gone out, might have gone out but the response got lost, or the process might have crashed outright. "Record exists" alone can't distinguish these three cases, and skipping on that basis alone permanently discards unsent events with no error surfaced.

The correct pattern is a **transactional outbox**: the event and its state live in the same database transaction.

**Don't call the state `sent`.** The standard endpoint `/mp/collect` returns 2xx for **invalid payloads too** (point ② above), and even for an expired `api_secret` — so "got a 2xx" only proves **transport was accepted**, never that the event is valid or will appear in reports. A state called `sent` will get misread by whoever inherits this system three months from now as "successfully delivered," and they'll use the `sent` count as the actual revenue-recorded count — **that misreading is a design defect, and renaming the state fixes it more reliably than a comment would.** Two names, two separate facts:

- **`delivered_unverified`**: the HTTP transport was accepted (2xx) by the endpoint. **This is a fact about the connection, not about the data**
- **`verified`**: actually matched to this event in GA4 Realtime/reports/BigQuery export (see reconciliation, below). Only this state means "GA4 genuinely received it"

**Any inference of "this event succeeded" from a production 2xx is wrong** — that signal doesn't exist. `delivered_unverified` sitting too long (past two reconciliation cycles, say) is itself something to alert on.

So **validity checks must happen before sending** (at enqueue time), not guessed from the response afterward:

- **Run local schema validation before enqueueing**: legal event name (not reserved, correct length/characters), required parameters present (`purchase` needs `transaction_id`/`currency`/`value`/`items`), correct types, valid `client_id` format. **Fails → write straight to `dead_letter`, don't send at all** (retrying this kind of error a thousand times won't change the outcome)
- **Run every event type against `debug/mp/collect` once before launch**, and save the empty-`validationMessages` response in the verification record (see [debug-validation.md](debug-validation.md)). Re-run after any schema or code change. This is the only channel that confirms payload semantics are valid — and it's a pre-launch action, not a per-event real-time check

| State | Written when | How retry handles it |
|---|---|---|
| `pending` | Written in the **same database transaction** as the business event (order status → paid), with a unique constraint on event ID, full payload, `attempt_count`, `next_attempt_at`, `last_error` | Sent when `next_attempt_at` arrives |
| `retryable` | Sent, then hit a **transient failure**: connection timeout, DNS/TLS failure, lost response, `408`/`429`/`5xx` | **Must retry**, next `next_attempt_at` scheduled per the backoff table below. This means "state unknown or temporarily unable," not failure and not success |
| `delivered_unverified` | Changed after the standard endpoint returns 2xx. **Means "HTTP transport completed," not "event valid" and not "visible in reports"** | No further retry. Waits for reconciliation to promote it to `verified` |
| `verified` | Changed after report reconciliation (Realtime/GA4 reports/BigQuery export) **actually matches** this event | Terminal state, done |
| `dead_letter` | Two paths in: ① **fails local schema validation pre-send** (not retryable — resending a thousand times changes nothing) ② `retryable` exhausts its max attempts or time limit | Stop auto-retrying and **alert**; goes into a manual-review queue |

**Retryable vs. not — fixed by rule, not judgment at the time**:

| Error | Class | Why |
|---|---|---|
| Connection timeout, connection reset, TLS failure, DNS failure, lost response | `retryable` | The event may or may not have been sent; `purchase` dedups on `transaction_id`, so resending is safe |
| `408`/`429`/`500`/`502`/`503`/`504` | `retryable` | Transient state on the other end; especially honor `Retry-After` for `429` |
| `400`/`401`/`403`/`404`/`413` (request itself is malformed) | `dead_letter` | Resending won't fix it — needs a human to check URL, secret, or payload size |
| Fails local schema validation | `dead_letter` (**never sent at all**) | Sending it out only earns a misleading 2xx |

**Backoff and caps (without these numbers, `retryable` means infinite retry)**:

- **Exponential backoff with jitter**: interval on retry n = `min(2^n × base, cap)`, multiplied by a `0.5–1.5` random jitter factor. Suggested `base = 30s`, `cap = 1h`
- **Max 8 attempts**, **or 24 hours since enqueue**, whichever comes first — past either, move to `dead_letter`
- **When `429` carries `Retry-After`, honor it over your own computed interval**
- **The retry worker must be concurrency-safe**: claim rows with `SELECT ... FOR UPDATE SKIP LOCKED` (or equivalent) so two workers never send the same event twice

**`dead_letter` manual-resend process (document it in the tracking plan, not just tribal knowledge)**:

1. `dead_letter` **count and amount** feed a daily alert — silent accumulation is a silent undercount
2. A human reads `last_error` to judge cause: schema issue → fix code, then **re-enqueue with the original `transaction_id`/event ID** (never a new one — that becomes two records); credentials/config issue → fix config, then re-enqueue the whole batch
3. Measurement Protocol has a backfill time limit — even a successful late resend may not attribute to the original session (see point ③ above). **Confirm which report the resent data feeds before resending** — a mis-attributed resend isn't automatically better than a gap
4. Anything decided as not worth resending gets logged as a "known gap" (period, count, reason) in the tracking plan, so the next person asking "why doesn't that week reconcile" has an answer

**Two problems only surface after `delivered_unverified` — each needs its own separate mechanism** (don't expect either to show up in a single response):

- **Secret health check**: when `api_secret` is invalidated or revoked, the standard endpoint **still returns 2xx** and events silently vanish. Run a scheduled job that sends a test event to the **debug** endpoint using the same `measurement_id` + `api_secret`, alerting on an abnormal response. Also re-run after any secret rotation. **Pre-deploy smoke tests take the same path**: after a new environment, secret rotation, or payload-structure change, first hit the debug endpoint to confirm `validationMessages` is empty, then send one real event to production and confirm it shows up in Realtime — both gates have to pass before deployment counts as done
- **Report reconciliation** (the catch-all, and the only source of `verified`): daily, compare "`purchase` count and amount for `delivered_unverified` rows in the outbox" against "`purchase` count and amount for the same period in GA4 reports (or BigQuery export)." Matches promote to `verified`; mismatches **don't sit silently** — alert past a defined tolerance. This is the only method that catches "transport succeeded but the event never reached the report," and it's the last safety net in the whole mechanism
  - Reconciliation lag: Realtime within minutes, standard reports 24–48 hours, BigQuery daily export the next day. **Set the tolerance window to this lag** — don't declare an event missing 10 minutes after sending it
  - `delivered_unverified` sitting past two reconciliation cycles without promoting to `verified` → alert, treat as a suspected undercount

Use the source system's own event ID (the payment provider webhook's event ID, a messaging platform's delivery event ID) as the unique key — its purpose is deduplicating **resends from the source**, not serving as a "was this sent" check; that's the `status` field's job.

- **Retrying `purchase` is safe**: the same transaction always reuses its one persisted `transaction_id`, so GA4 dedups repeated sends into a single counted transaction (see the dedup table above). So `purchase` uses at-least-once delivery — resending is preferable to dropping
- **Non-`purchase` events have no built-in GA4 dedup** — resending means an extra row. Document two things explicitly in the tracking plan for these: ① at-least-once (may duplicate) or at-most-once (may drop) ② if at-least-once, how downstream dedups — usually by event ID at the BigQuery-export layer, since the GA4 UI reports themselves can't dedup, and that margin of error needs to be noted on the report. **Don't put an important decision metric on a non-`purchase` backend event until this is settled**

### Payment webhook verification: follow each provider's own official method

Don't generalize one provider's signing scheme onto another's — different payment providers verify very differently (parameter-concatenation checksums, AES-decrypt-and-compare, asymmetric signatures are all in use depending on the provider). Applying the wrong scheme just fails validation, and the most common failure mode is a developer disabling verification entirely to make it "work" — which is exactly how fake revenue gets in.

Rules:

1. **Implement exactly to that provider's official docs' canonicalization rule, or use their official SDK.** Verify by reading that provider's technical documentation for field names and hash order — never from memory
2. **Compare with a constant-time comparison** (e.g. Node's `crypto.timingSafeEqual`, after first confirming both sides are the same length — mismatched lengths throw)
3. **Only check a time window when that provider's official spec both provides a timestamp and includes it in the signed payload** — use the tolerance the provider's docs specify, don't invent one. Reasoning: ① not every notification carries a timestamp ② a timestamp that isn't covered by the signature can be tampered with, so it doesn't actually block replay ③ delayed notifications, batch settlement, and the provider's own resend mechanism can all deliver a **legitimate** notification tens of minutes or even a day late — a strict "5 minutes" tolerance would reject real payments, and a missed order is worse than a replay attack. **Without a trustworthy timestamp, replay protection comes from**: the provider's own anti-replay mechanism, the event ID's unique constraint (see the outbox section above), and the order state machine — a notification arriving again for an order already marked "paid" is a no-op, not a second sale
4. **Signature verification only proves "this notification really came from the provider," not "the money has landed."** Still check the payment status code inside the notification — authorized ≠ captured, and a cash-voucher/bank-transfer "code issued" ≠ paid. **Only send `purchase` once the state machine reaches "paid"**; every other status just updates your own order state
5. **Secrets live only on the backend** (env vars / secrets manager) — never in a repo, never in front-end code

## GA4 quick setup

1. Create the GA4 property and data stream.
2. Install gtag.js or GTM.
3. Turn on Enhanced Measurement — **read [url-pii-protection.md](url-pii-protection.md) first**; it's an auto-collection feature and won't filter PII out of URLs for you.
4. Configure custom and ecommerce events (per the official schema above).
5. Mark conversions in the Admin UI.
