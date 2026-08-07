# Debugging and validation

## Test tooling

| Tool | Purpose |
|---|---|
| GA4 DebugView | Real-time event monitoring (secondary check, not primary evidence for PII validation) |
| GTM preview mode | Test triggers before publishing |
| Browser DevTools Network tab | Inspect the actual payload sent — **primary evidence** for PII validation, see [url-pii-protection.md](url-pii-protection.md) |
| Browser extensions | Tag Assistant, dataLayer inspectors |
| `/debug/mp/collect` endpoint | Validates **server-side** Measurement Protocol events — **primary evidence** for backend-event validation. The standard `/mp/collect` endpoint returns 2xx with no error message for invalid payloads; only the debug endpoint returns `validationMessages`, and only an empty array counts as passing. See [ga4-implementation.md](ga4-implementation.md) |

## Pre-launch checklist

- [ ] Events fire at the correct trigger timing.
- [ ] Property values populate correctly.
- [ ] `transaction_id` correspondence is correct — **this has direction, verify both, don't reduce it to "IDs can't repeat"**:
  - **Same transaction, same ID**: this is **expected behavior**, not a bug. Test by **resending the same payment webhook (or re-running the same outbox event) 2–3 times** and confirming `transaction_id` stays identical each time and GA4's transaction count only increments by 1. **Don't test by reloading the success page** — the success page shouldn't send GA4 `purchase` at all, so a reload sending nothing is the correct outcome
  - **Different transactions, different IDs**: IDs must be globally unique. Test by placing two real test orders back to back and confirming their `transaction_id` values differ (sharing one causes the second to be discarded as a duplicate, undercounting revenue)
- [ ] `purchase` **fires exactly once, from the backend order-confirmation/payment webhook only** (verify recurring renewal charges are captured, especially for subscriptions); confirmed **not** built as "front end sends first, backend sends again."
- [ ] The Network tab on the payment success page shows **no GA4 `purchase` request** — if Google Ads/Meta Pixel/a regional platform's conversion tag fires there, confirm those hit their own endpoints and fire only after the backend's payment-confirmation response returns.
- [ ] Backend events run through the five-state `pending`/`retryable`/`delivered_unverified`/`verified`/`dead_letter` outbox: tested that a timeout, lost response, `429`, or `5xx` moves the event to `retryable` and it retries on exponential backoff (not silently treated as sent and skipped); that `400`/`401`/a failed local schema check go straight to `dead_letter` with no retry; that `dead_letter` alerts rather than accumulating silently.
- [ ] **`delivered_unverified` is never treated as done**: a daily reconciliation job compares GA4 reports/BigQuery export counts and amounts against the outbox, promoting to `verified` on a match; anything stuck past two reconciliation cycles alerts.
- [ ] Every backend event type has been run against `/debug/mp/collect` with an empty `validationMessages`; `api_secret` lives only in backend env vars, never in front-end code or the repo.
- [ ] Backend events' `client_id` comes from the real browser `_ga` cookie (captured and persisted with the order at checkout), **never randomly generated**; a count with no legitimate `client_id` (e.g. a regional messaging platform's add-friend total) stays in your own database, not force-fed into GA4.
- [ ] Webhook endpoints verify signatures and dedup by event ID; **verification method follows that source's own official docs/SDK** (a regional messaging platform's raw-body HMAC-SHA256 scheme is not portable to a payment provider's own scheme, or vice versa).
- [ ] Payment webhooks tested against all three scenarios: a forged signature gets rejected, a resend doesn't double-count, and **an authorized-but-not-yet-captured payment doesn't send `purchase`**.
- [ ] Verified across browsers and mobile devices.
- [ ] Conversions record correctly.
- [ ] No PII leak — tested with a **synthetic canary** marker per [url-pii-protection.md](url-pii-protection.md) across password reset, checkout confirmation, on-site search, and similar sensitive flows; **every** `/g/collect` request across the **whole flow** (not just the first) searched for the marker, not just eyeballed.
- [ ] Canary testing covers **query, path, and fragment**, not query alone.
- [ ] Server access logs, CDN/WAF logs, error tracking, and session-replay services all searched for the canary marker to confirm masking rules actually took effect.

## Symptom table

| Symptom | Check |
|---|---|
| Event doesn't fire | Trigger configuration, whether GTM loaded |
| Wrong value | Variable path, dataLayer structure |
| Revenue inflated (one order counted multiple times) | Multiple GA4 containers installed at once, a trigger firing more than once, **`transaction_id` changing on every send for the same transaction** (e.g. the front end generates a fresh UUID on every page reload), or a missing `transaction_id` (no ID means no way to dedup) |
| Revenue undercounted (multiple real orders, only one counted) | **Different transactions sharing the same `transaction_id`** (e.g. accidentally using a member number, cart ID, or a fixed daily string) — GA4 treats them as duplicates of one transaction and keeps only one |
| Revenue undercounted (especially subscriptions, or doesn't reconcile with the payment back office) | **`purchase` only instrumented on the front-end success page** — recurring renewal charges have no front end and are missed entirely; third-party payment methods or cash/bank-transfer orders that never redirect to the success page are missed too. Switch to the backend payment webhook as the authoritative trigger — see [ga4-implementation.md](ga4-implementation.md) |
| GA4 shows revenue the payment back office has no record of (or it later turns out to be refunded/failed) | `purchase` fired on reaching the success page, earlier than the backend actually confirmed payment; no matching `refund` event sent afterward |
| Add-friend count is much higher than actual follower growth | The site's button click was named as if it were the add itself, conflating intent with result; or the `follow` webhook wasn't filtered by unblock status — see the applicable GEO module |
| A closed marketplace's traffic shows no attribution data at all | Not a missing configuration — closed platforms don't let sellers install third-party tags, so UTM parameters produce no data the seller can query. See [utm-and-attribution.md](utm-and-attribution.md) |
