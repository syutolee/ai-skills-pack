# Platform specs and CJK character counting

Platforms reject or truncate assets past their limit — check character counts before delivery, every time.

## CJK character counting (wide-character rule)

**Google Ads officially counts CJK (Chinese/Japanese/Korean) wide characters as 2, not 1.**

```
last_verified: 2026-07-20
Source: https://support.google.com/google-ads/answer/7684791 ("About responsive search ads")
```

A 30-character headline limit holds roughly 15 wide (CJK) characters, not 30 — **don't** estimate with a plain Unicode code-point count (`[...str].length` in JS, `len(str)` in Python); that undercounts by nearly half and can pass a headline that the platform will actually reject or truncate.

Reproducible algorithm and a Python implementation: `ads` skill's [`rsa-output-spec.md`](../../ads/references/rsa-output-spec.md), "Character counting" section. Summary: classify by Unicode East Asian Width — property `W` (Wide) or `F` (Fullwidth) counts as 2, everything else (`Na`, `H`, `A`, `N` — all halfwidth Latin letters/digits, halfwidth punctuation, spaces) counts as 1. CJK characters and fullwidth punctuation (，。！？「」) are `W`.

Example: "別再手動做報表" → 7 wide characters × 2 = **14**. "報表自動化，5分鐘搞定" → 10 wide characters (including the fullwidth comma) × 2 + halfwidth digit "5" × 1 = **21**.

**Always paste the final text into the platform's own input box (or Google Ads Editor) before delivery** — don't trust manual counting or this file's algorithm alone; a platform rule can change, and a live check is the only way to match current enforcement.

## Google Ads (Responsive Search Ads)

| Element | Limit | Count |
|---|---|---|
| Headline | 30 characters | Up to 15 |
| Description | 90 characters | Up to 4 |
| Display path | 15 characters each | 2 segments |

The "up to 15/4" above is Google's **platform ceiling** (the platform itself only requires a minimum of 3 headlines and 2 descriptions to create an RSA). This package additionally has its own house rule of delivering exactly 15/4 per RSA — that's a quality bar this package sets, not a platform requirement. Full output spec and the distinction: `ads` skill's [`rsa-output-spec.md`](../../ads/references/rsa-output-spec.md).

## Meta ads (Facebook/Instagram)

| Element | Limit | Note |
|---|---|---|
| Primary text | 125 visible characters (2,200 max) | Front-load the hook |
| Headline | ~40 characters recommended | Below the image |
| Description | ~30 characters recommended | Below the headline |
| Display link | 40 characters | Optional |

## TikTok ads

| Element | Limit | Note |
|---|---|---|
| Ad copy | ~80 characters recommended (100 max) | Above the video |
| Display name | 40 characters | Brand name |

## LINE Ads Platform (LAP)

TW-specific — see [`geo/tw.md`](geo/tw.md)'s "LINE Ads Platform" section, loaded when `profile.md`'s `geo` list includes `TW`.

## Platforms not covered

LinkedIn and X ad specs aren't provided in this package. This package covers the performance-ad platforms most launches spend on; regional media concentration is a GEO-specific fact — see the applicable [`geo/<code>.md`](geo/tw.md) module for which platforms actually carry spend in that market. LinkedIn and X have no GEO-localization angle to add here regardless (copying their spec pages would just be translation, against this package's "not a plain translation" principle). Check each platform's own official ad-specs page when needed.

**When `profile.md` lists a GEO with no matching module** in this file or [`geo/`](geo/): say so explicitly ("this pack has no platform-spec module for `<GEO>`") rather than guessing, and follow the freshness protocol in [`../../AUTHORING.md`](../../AUTHORING.md) to check the platform's current official spec before relying on a number.
