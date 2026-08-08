# Meta (Facebook/Instagram) Ads MCP setup

Connects a read-only Meta Marketing API credential to your MCP server so it can pull ad-account performance data. See [`index.md`](index.md) for the read-only redline this whole guide follows — grant only what's listed below, nothing more, even if a screen offers a broader option.

## 1. Before you start

- A Facebook account with **admin access on the Business Manager** that owns the ad account you want reporting on (business.facebook.com — if you don't have one, Business Manager setup itself is out of scope here; this guide starts from an existing one).
- The **ad account ID** you're connecting: Business Settings → Accounts → Ad Accounts → the number under the account name (used in API calls prefixed `act_<id>`, e.g. `act_1234567890`).

## 2. Create an app and enable Marketing API access

1. Go to <https://developers.facebook.com/apps/creation/> and log in with the Business Manager account.
2. Enter the app name and a contact email, click Next.
3. On the use-case screen, pick the one that connects to Marketing API / ad account access (Meta's use-case list and wording changes periodically — look for anything mentioning "Marketing API" or "manage ads"; if none is offered directly, create the app first and add the Marketing API product from the app dashboard's "Add Product" screen instead).
4. Connect the app to your Business Manager when asked (a business portfolio, verified or not).
5. Finish through to the app dashboard.

A new app has **Standard Access** to the Marketing API by default. **Standard Access is sufficient for reading your own ad account** — no Meta App Review is needed for this guide's use case. App Review (upgrading to Advanced Access) is only required if the MCP tool will read ad accounts you don't own or manage yourself; that scenario is out of scope for this guide.

last_verified: 2026-08-06
Source: <https://developers.facebook.com/docs/development/create-an-app/> (app creation flow); <https://developers.facebook.com/docs/marketing-api/access> (Standard vs Advanced Access, Standard sufficient for own ad accounts)

## 3. Create a System User and grant it read-only access

A System User represents the MCP server itself rather than your personal login — its token doesn't expire the way a personal user token does, and revoking it later doesn't touch your own account.

1. In Business Settings → Users → System Users, click Add, name it (e.g. `mcp-reporting`), and set its role to **Employee** (not Admin — Admin can assign itself broader access later, which this guide's scope doesn't need).
2. Still in System Users, select it → Add Assets → Ad Accounts → select the ad account from step 1.
3. **Grant only the "View Performance" task.** In Business Manager's task-based permission list, "View Performance" is the read-only reporting task — it maps to the `ads_read` permission and cannot edit a campaign, budget, or audience. Do not additionally toggle "Manage campaigns" or any task described as editing.
4. Generate a token for the System User (System Users → select it → Generate New Token → choose the app from step 2 → select the `ads_read` permission only) and save it somewhere the MCP server's config can read it — not into this repo (see [`index.md`](index.md)'s credential-handling section).

last_verified: 2026-08-06
Source: <https://developers.facebook.com/docs/marketing-api/system-users> (System User purpose and token generation); <https://www.facebook.com/business/help/442345745885606> (task-based permissions, "View Performance" = view-only)

## 4. Confirm what `ads_read` actually grants

`ads_read` is strictly read access to the Ads Insights Reporting API (spend, impressions, clicks, conversions, and similar metrics) — it does not include creating, editing, or pausing anything. Write operations (budget changes, campaign edits, pausing an ad) live entirely under the separate `ads_management` permission, which this guide never asks for.

last_verified: 2026-08-06
Source: <https://developers.facebook.com/docs/permissions/reference/ads_read>

## 5. Wire the credential into your MCP server

Paste the System User token, the app ID, and the ad account ID (`act_<id>` form) into your MCP server's own config — the exact field names depend on which server you installed; check its README for what it expects (commonly an access-token field plus the ad-account ID). This guide doesn't endorse a specific server; any read-only Meta Ads MCP server needs the same three values you just generated.

## 6. Verify the connection

Before relying on the MCP tool inside a skill run, confirm the token actually works with one read-only call. Using Graph API Explorer (<https://developers.facebook.com/tools/explorer/>) or a direct request:

```
GET /act_<AD_ACCOUNT_ID>/insights?fields=spend,impressions,clicks&access_token=<SYSTEM_USER_TOKEN>
```

Expect a JSON `data` array with one object holding `spend`, `impressions`, and `clicks` for the account's recent activity. If the account has no recent spend, an empty `data: []` array (not an error) is still a pass.

## 7. Write access: uploading assets and creating paused objects (optional)

Everything above wires up a read-only credential. This section is optional and separate — only work through it if a skill run is actually going to upload a creative asset or stand up a new campaign, ad set, or ad through the MCP tool, not by default. See [`index.md`](index.md)'s read/write/activate policy before granting anything here.

**Two different risk levels — don't conflate them:**

- **Asset upload** (an image to the ad account's image library, a video to its video library) puts a file where it can later be attached to an ad. Meta's own reference docs don't state outright whether an uploaded-but-unattached asset can independently trigger spend — that an unattached asset just sits inert is a structural inference (delivery is documented as governed at the Ad level, not the asset library), not a directly confirmed policy statement; treated as lower risk than object creation below on that basis, not as a confirmed fact. Still a write call either way: it needs `ads_management`, not `ads_read`.
- **Object creation** (campaign, ad set, or ad) is the case that needs the PAUSED discipline below — this is what can actually spend once something else flips it live.

**Grant `ads_management`, not `ads_read`, for this workflow.** Reuse the System User from step 3 above rather than creating a second one: in Business Settings → System Users → select it → Assigned Assets, add (or upgrade) the "Manage campaigns" task on the ad account, then generate a new token selecting the `ads_management` permission — a token generated earlier for `ads_read` only doesn't carry this. `ads_management` is the sole write permission Meta exposes for this; there's no narrower "create only" scope, so the PAUSED rule below is what actually keeps the blast radius small, not the permission grant by itself.

last_verified: 2026-08-08
Source: <https://developers.facebook.com/docs/marketing-api/overview/authorization> (`ads_management` = read-and-manage write permission, distinct from `ads_read`)

**Every create call for Campaign, Ad Set, and Ad must pass `status=PAUSED` explicitly — never omit it.** Meta's reference docs for all three object types confirm `ACTIVE` and `PAUSED` are the only legal values *at creation* (`DELETED`/`ARCHIVED` are update-only) — but none of the three reference pages states what happens if `status` is left off a create call. That default is undocumented, not confirmed safe, so treat it the same as an unsafe default and always pass `status=PAUSED` explicitly rather than relying on it:

| Object | Create endpoint | Required field |
|---|---|---|
| Campaign | `POST /act_<id>/campaigns` | `status=PAUSED` |
| Ad Set | `POST /act_<id>/adsets` | `status=PAUSED` |
| Ad | `POST /act_<id>/ads` | `status=PAUSED` |

A newly created Ad also goes through Meta's own ad review and carries `PENDING_REVIEW` before it can move to any other status — a platform mechanic, not something this rule needs to account for separately; it doesn't change "always pass `status=PAUSED` at creation" above.

last_verified: 2026-08-08
Source: <https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/>, <https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/>, <https://developers.facebook.com/docs/marketing-api/reference/adgroup/> (creation-only status values, PAUSED-at-creation, ad review flow; none states the omitted-`status` default)

**Access Level note (unverified boundary).** Meta's Access Levels doc doesn't explicitly state whether a paused-object create call on your own ad account is permitted under the default Standard Access tier, or requires the Advanced Access tier (App Review). The doc's framing — Standard Access scoped to your own account, Advanced Access required for "managing other people's ad accounts" — suggests Standard Access is likely sufficient here, but this isn't a direct confirmation. A create call rejected with a permissions error under Standard Access is this documented gap surfacing, not necessarily a setup mistake.

last_verified: 2026-08-08
Source: <https://developers.facebook.com/docs/marketing-api/access> (Standard vs Advanced Access framing; the precise boundary for a paused-create call on your own account is not explicitly stated)

## 8. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Error code 190 ("invalid/expired token") | Using a personal user token instead of the System User token — personal tokens expire in hours | Regenerate from System Users → Generate New Token, not from Graph API Explorer's default user login |
| Error code 200 / "permission denied" on the insights call | The System User was never assigned the "View Performance" task on this specific ad account | Business Settings → System Users → select it → Assigned Assets → confirm the ad account is listed with Performance access checked |
| API call 404s or "unknown account" | Ad account ID used without the `act_` prefix | The Business Manager UI shows the bare number; every Marketing API call needs `act_<id>` |

last_verified: 2026-08-06
Source: error-code behavior per <https://developers.facebook.com/docs/marketing-api/error-reference>; act_ prefix and asset-assignment UI per <https://developers.facebook.com/docs/marketing-api/system-users> and <https://www.facebook.com/business/help/442345745885606>
