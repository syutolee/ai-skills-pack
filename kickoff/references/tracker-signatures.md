# Tracker signatures

Static-scan patterns for `SKILL.md` step 3. Match against raw homepage HTML text — script `src` attributes, inline script bodies, and `<noscript>` fallbacks. This is a floor, not a ceiling: a tag manager can inject any of these dynamically after the static HTML loads, and a static scan never sees that — say so every time, per `SKILL.md` step 3.

## Google Tag Manager (GTM)

Look for: a `<script>` `src` containing `googletagmanager.com/gtm.js`, or a `<noscript>` `<iframe>` `src` containing `googletagmanager.com/ns.html?id=`. Either carries a container ID shaped `GTM-XXXXXXX`.

A GTM container present tells you a tag manager is installed — it does not tell you what tags fire inside it. Container contents render at runtime and are invisible to a static scan.

```
last_verified: 2026-08-06
Source: https://support.google.com/tagmanager/answer/14847097
```

## Google Analytics 4 (GA4)

Look for: a `<script>` `src` containing `googletagmanager.com/gtag/js?id=G-`, or an inline `gtag('config', 'G-...')` call. Measurement ID is shaped `G-XXXXXXX`.

GA4 is commonly deployed through GTM instead of this direct snippet — a miss here rules out only the direct-snippet path, not GA4 itself.

```
last_verified: 2026-08-06
Source: https://developers.google.com/tag-platform/gtagjs
```

## Meta Pixel

Look for: a `<script>` `src` containing `connect.facebook.net/en_US/fbevents.js`, an inline `fbq('init', '...')` call, or a `<noscript>` `<img>` pointing at `facebook.com/tr?id=`. Pixel ID appears in both the `fbq('init', ...)` call and the `<noscript>` fallback.

```
last_verified: 2026-08-06
Source: https://developers.facebook.com/docs/meta-pixel/get-started
```

## LINE Tag

Look for: a `<script>` `src` containing `d.line-scdn.net`, or an inline call to `_lt('init', {...})`. Live-page insertion order matters (conversion codes sit right after the base code) but doesn't change what a static scan can see — the base code's presence alone is enough to report the tag as installed.

```
last_verified: 2026-08-06
Source: https://help.line.me/official_account/web/categoryId/20008713/3/pc?lang=en
```

## TikTok Pixel

Look for: a `<script>` `src` containing `analytics.tiktok.com/i18n/pixel/events.js`, or an inline `ttq.load('...')` call. Pixel ID is the argument to `ttq.load`.

```
last_verified: 2026-08-06
Source: https://ads.tiktok.com/help/article/get-started-pixel?lang=en
```

## Reading the results

Report each signature by name as found or not found — "found" means the pattern matched; "not found" means it didn't match this one page's static HTML, not that the tag doesn't exist anywhere on the site (other pages, or tags injected after page load, aren't covered). Never report a signature as "confirmed absent."
