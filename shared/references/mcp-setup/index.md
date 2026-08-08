# MCP setup guide: entry point

A judgment skill in this package (`campaign-analysis`) can pull recent ad-platform data itself when a read-only ad-platform MCP tool is wired into the calling agent — see that skill's "three-tier degrade." This guide walks a zero-MCP-experience user through wiring one up, platform by platform, so the skill stops falling back to manual exports.

**This guide connects a platform account to an MCP server you already chose or are about to install.** It doesn't build, host, or recommend a specific MCP server — every MCP server needs the same three platform-side things (an app/project registration, a permission grant, a token), and this guide produces those three things. Most setups only need the read-only grant each platform guide leads with; the optional write section further down covers the narrower create-paused permission, for the workflows that actually need it. Once you have them, paste them into your MCP server's own config per its README.

Pick a platform:

- [Meta (Facebook/Instagram) Ads](meta.md)
- [Google Ads](google.md)

**Not covered:** LINE and TikTok don't yet have a mature read-only ads MCP ecosystem to set up against (as of this guide's writing) — when one exists, add a module here rather than improvising against this guide's Meta/Google structure.

## Read, write, and activate: the policy every step below follows

This package's skills operate under a strict three-part policy — every step in both platform guides below sits under one of these three, never a fourth:

1. **Read — unrestricted.** Pulling reporting/insights data is always fine; it's what most of both platform guides set up.
2. **Write — create-only, and every created object is forced PAUSED.** A skill in this package may use a write-capable MCP tool for exactly one thing: creating a new campaign, ad set, ad, or creative asset. **Every object it creates carries an explicit paused status — never omitted, never left to a platform default.** (Google's `Campaign` object defaults to live `ENABLED` if `status` is left off a create call — see [`google.md`](google.md)'s write section for the confirmed source.) No skill in this package ever calls a write operation for anything else: no budget change, no audience edit, no status change on an *existing* object, no pause/resume toggle on something already live. Uploading a creative asset to the platform's own asset library is the lower-risk half of this same write path — an unattached asset doesn't itself spend — but it's still a write call, covered by the same permission and the same discipline; see each platform guide's write section for the create-vs-upload split.
3. **Activate — never, by any skill, on any tier.** Flipping a created-paused object to live/enabled is exclusively a human action taken in the platform's own dashboard. **No skill in this package calls an activation/enable/status-update endpoint, ever** — that decision, and the click that executes it, always belongs to the account owner.

**Only grant the permission named for the workflow you're actually setting up** — read-only/reporting-only if this is just for `campaign-analysis` to pull data, the write permission too only if a skill run is actually going to create a paused object or upload an asset. If a setup step ever offers a broader "edit," "manage," or "admin" option than what's named, skip it — the platforms named here have no scope granular enough to express "create-only," so the PAUSED discipline above is what actually keeps the blast radius small, not the permission grant by itself.

**Revoking write access, both platforms** (once a create-paused workflow is no longer needed, or you never want it):

- **Meta**: Business Settings → System Users → select the system user → remove the `ads_management` task/permission from the ad account assignment (or remove the asset assignment entirely) — see [`meta.md`](meta.md)'s write section for where that permission was granted.
- **Google**: there's no separate write *scope* to revoke (Google Ads API has one OAuth scope total) — instead remove the authorizing Google account's access-and-security role on the ad account, or delete the OAuth client in Cloud Console, to cut the credential off entirely — see [`google.md`](google.md)'s write section.

Credential handling, both platforms:

- A token or client secret is a live credential, not a value to record anywhere this pack tracks: never write it into `.agents/`, a chat message, a commit, or this repo. It belongs only in the MCP server's own config/secret store, per that server's README.
- If a token is ever pasted somewhere it shouldn't be (a chat log, a shared doc), revoke and regenerate it from the platform's own dashboard rather than trying to scrub the leak after the fact.

## Third-party MCP servers: not official, not endorsed

Neither Meta nor Google publishes an official MCP server for their ads API — every server you'll find, for either platform, is a third-party/community open-source project. This guide doesn't build, host, recommend, or vouch for any of them; **review a server's own source and README before connecting it to a real account, especially before granting it the write permission above.** Two examples with a create-paused default, for orientation (not a recommendation): `pipeboard-co/meta-ads-mcp` documents a `status` parameter defaulting to `PAUSED` on its campaign/ad-set/ad creation tools; `FGRibreau/mcp-google-ads` documents new campaigns/ad groups/ads created `PAUSED` by default, requiring an explicit override to create live. Several other open-source projects exist for both platforms — check each one's own README for whether it actually defaults to PAUSED, or whether that's a plain create call needing `status`/`PAUSED` supplied by the caller, before wiring it up.

## What "connected" looks like when you're done

Each platform guide ends with a verification call — a single read-only request your MCP server (or a manual test call, if the server isn't wired up yet) can make to confirm the credential actually works before you rely on it inside a skill run.
