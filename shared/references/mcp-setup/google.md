# Google Ads MCP setup

Connects a read-only Google Ads API credential to your MCP server so it can pull ad-account performance data. See [`index.md`](index.md) for the read-only redline this whole guide follows — grant only what's listed below, nothing more, even if a screen offers a broader option.

## 1. Before you start

- A **Google Ads Manager account (MCC)** — required even to read a single account, since the developer token in step 2 is issued to a manager account, not an individual ad account. If you only have a standalone Google Ads account, create a free manager account first (steps at <https://support.google.com/google-ads/answer/7459399>) and link your ad account under it.
- The Google Ads account's **customer ID** (the `XXX-XXX-XXXX` number shown top-right in the Google Ads UI) for the account you want reporting on.

## 2. Apply for a developer token

1. Sign in to the manager account and go to <https://ads.google.com/aw/apicenter>.
2. Fill out the API Access form. Use an email you actually monitor — Google may follow up during review.
3. Submitting the form issues a 22-character developer token immediately, but it starts at the lowest access tier (below).

A token starts at **Test account access** (production-account calls fail). For this guide's use case — reading your own real ad account — apply to upgrade to **Basic access** from the same API Center page, and when asked for the token's intended use, select **"Reporting"** as the permissible use. A Basic-access token scoped to Reporting is restricted at the platform level to read-only calls (`GoogleAdsService.Search` / `SearchStream` and similar) — it cannot be used to create or modify anything even if the calling code tried. Basic-access review commonly takes about 5 business days; **Standard access is not needed** for a single-account read-only setup and requires a longer review, so don't apply for it here.

last_verified: 2026-08-06
Source: <https://developers.google.com/google-ads/api/docs/get-started/dev-token> (application steps); <https://developers.google.com/google-ads/api/docs/api-policy/access-levels> (Test/Basic/Standard tiers, Basic + Reporting use = read-only enforced calls)

## 3. Create OAuth credentials (Google Cloud Console)

The developer token identifies your app to Google Ads; a separate OAuth client identifies *you* logging in. These are different systems (Google Cloud Console vs. the Google Ads UI) — both are required.

1. In <https://console.cloud.google.com>, create a project (or pick an existing one) for this integration.
2. Go to APIs & Services → Credentials → Create Credentials → OAuth client ID.
3. Choose **Desktop app** as the application type (a desktop-type client doesn't require configuring a redirect URI, unlike a Web application client).
4. Download the resulting client secret JSON — this holds the client ID and client secret your MCP server (or the token-generation step below) needs.

last_verified: 2026-08-06
Source: <https://developers.google.com/google-ads/api/docs/oauth/cloud-project> (Cloud Console project + OAuth credentials setup)

## 4. Grant your Google account read-only access on the ad account

The single Google Ads API OAuth scope is `https://www.googleapis.com/auth/adwords` — there is no separate read-only *scope*; read-only enforcement instead comes from the Basic+Reporting developer-token restriction above **and** from the account-level access role of the Google account you authorize with in the next step:

1. In Google Ads (not Cloud Console), open Admin → Access and security → Users, for the manager account or the specific ad account.
2. Add the Google account you'll use to generate the OAuth token, set its access level to **Read only**, and send the invitation.
3. Read only permits viewing campaigns, performance data, and reports; it cannot edit a campaign, change budgets, or modify targeting — pick this over Standard or Admin even if those are offered.

last_verified: 2026-08-06
Source: <https://developers.google.com/google-ads/api/docs/oauth/internals> (single `adwords` OAuth scope); <https://support.google.com/google-ads/answer/9978556> (account access levels, Read only permissions)

## 5. Generate a refresh token

1. Install the Google Ads API client library for a language you have available (the official samples use Python) and run its `generate_user_credentials` sample, pointing `--client_secrets_path` at the JSON file from step 3.
2. The script prints a URL — open it, sign in with the **Read-only account from step 4**, and approve the consent screen (it will ask to authorize access to your Google Ads account).
3. The script exchanges that approval for a **refresh token**, which does not expire on its own (it can still be revoked from the account's security settings) — this, not an access token, is what a long-running MCP server should store.

last_verified: 2026-08-06
Source: <https://developers.google.com/google-ads/api/samples/generate-user-credentials>

## 6. Wire the credential into your MCP server

Paste the developer token (step 2), client ID + client secret (step 3), refresh token (step 5), and the target customer ID (step 1) into your MCP server's own config — field names vary by server; check its README. If the account you're reading is a *child* account under a manager, most Google Ads tooling also needs the manager's customer ID separately (commonly a `login-customer-id` field) — see troubleshooting below if calls fail without it. This guide doesn't endorse a specific server; any Google Ads MCP server needs the same four values above.

## 7. Verify the connection

Before relying on the MCP tool inside a skill run, confirm the credentials work with one read-only call — the simplest is a `GoogleAdsService.Search` (or the client library's equivalent) with:

```
SELECT campaign.id, campaign.name FROM campaign LIMIT 1
```

Expect either one campaign row back, or a clean empty result if the account has no campaigns yet — either is a pass. An authentication or permission error at this step means one of steps 2–5 didn't complete; see below.

## 8. Write access: uploading assets and creating paused objects (optional)

**Read this warning before anything else in this section.** Google's own `Campaign` resource definition states outright: *"When a new campaign is added, the status defaults to ENABLED."* A Campaign created through the Google Ads API with no `status` field set goes live immediately — not paused, not a safe default, live and spending from that call onward. **Every campaign-create call in this workflow must pass `status: PAUSED` explicitly; there is no scenario here where omitting it is safe.**

last_verified: 2026-08-08
Source: <https://github.com/googleapis/googleapis/blob/master/google/ads/googleads/v25/resources/campaign.proto> ("the status defaults to ENABLED" on new campaign creation)

Everything in steps 1-7 above wires up a read-only credential. This section is optional and separate — only work through it if a skill run is actually going to upload a creative asset or stand up a new campaign, ad group, or ad through the MCP tool, not by default. See [`index.md`](index.md)'s read/write/activate policy before granting anything here.

**No separate write scope — the same `adwords` OAuth scope from step 4 covers create/update calls too.** The Google Ads API has exactly one OAuth scope; there's no way to grant "create only" or narrower write access at the scope level. What keeps this safe is the PAUSED discipline below, not the scope: the Google account authorizing the OAuth token also needs at least Standard (not Read only) access-and-security role on the ad account for a write call to succeed — deliberately upgrading that role is a separate, explicit step from step 4 above, never a side effect of the read-only setup.

last_verified: 2026-08-08
Source: <https://developers.google.com/google-ads/api/rest/auth> (single `adwords` scope); <https://support.google.com/google-ads/answer/9978556> (account access-and-security roles)

**Every create call for Campaign, Ad Group, and Ad (`AdGroupAd`) must pass `status: PAUSED` explicitly:**

| Object | Resource | Required field |
|---|---|---|
| Campaign | `Campaign` | `status: PAUSED` — **confirmed default is live `ENABLED` if omitted, see the warning above** |
| Ad Group | `AdGroup` | `status: PAUSED` — default if omitted undocumented; treated as equally unsafe, see below |
| Ad | `AdGroupAd` | `status: PAUSED` — default if omitted undocumented; treated as equally unsafe, see below |

**Unverified, treated conservatively.** Google's own resource definitions for `AdGroup` and `AdGroupAd` don't carry the same explicit "defaults to ENABLED" sentence the `Campaign` resource does — no default-value statement was found for either at time of writing. Given the confirmed Campaign behavior, this guide treats AdGroup and AdGroupAd as equally likely to default to ENABLED rather than assuming they're safer — set `status: PAUSED` on both explicitly too, the same rule as Campaign, never a documented-safe omission.

last_verified: 2026-08-08
Source: <https://github.com/googleapis/googleapis/blob/master/google/ads/googleads/v25/resources/ad_group.proto>, <https://github.com/googleapis/googleapis/blob/master/google/ads/googleads/v25/resources/ad_group_ad.proto> (no default-value statement found in either)

**Asset upload is a separate, lower-risk case.** The `Asset` resource carries no `status`/`enabled` field governing spend — only policy-review fields (`review_status`, `approval_status`) unrelated to a live/paused delivery switch. An asset only starts mattering for spend once it's linked into an `AdGroupAd` (governed by the `AdGroupAd.status` rule above); Google's docs don't state this inertness in so many words, but no field exists on `Asset` that could turn delivery on. Treat asset upload itself as not needing the PAUSED discipline, while the ad object it eventually attaches to still does.

last_verified: 2026-08-08
Source: <https://github.com/googleapis/googleapis/blob/master/google/ads/googleads/v25/resources/asset.proto> (no delivery/spend-governing field on Asset)

## 9. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `USER_PERMISSION_DENIED` | The Google account tied to the refresh token doesn't have at least Read-only access on the target ad account | Admin → Access and security → Users on that account; confirm the account and status is "Accepted," not still pending |
| `DEVELOPER_TOKEN_NOT_APPROVED` (or calls only work against a test account) | The developer token is still at Test account access, not Basic | Check status at ads.google.com/aw/apicenter; Basic access takes a manual review, it isn't instant |
| Calls fail with a customer-not-found or authorization error even though credentials look right | Target account is a child account under a manager, and the manager's ID wasn't set | Set the manager account's customer ID in whichever config field maps to the `login-customer-id` request header |

last_verified: 2026-08-06
Source: <https://developers.google.com/google-ads/api/docs/api-policy/access-levels> (access-level errors); <https://support.google.com/google-ads/answer/9978556> (account permission errors); manager/child login-customer-id requirement per <https://developers.google.com/google-ads/api/docs/concepts/call-structure>
