# `.agents/` directory conventions

Layout and multi-client rules for everything this package's skills read and write outside a single `SKILL.md` run. Every skill in this package assumes this layout — don't invent a second one in a skill's own file.

## Layout

```
.agents/
├── positioning.md          # strategy — schema positioning/v1, written by quick-angle. See contracts/sister-product-compat.md.
├── profile.md               # assets — schema profile/v1. See contracts/profile-v1.md.
├── kickoff-readout.md       # kickoff's own scan snapshot — schema kickoff-readout/v1. See contracts/kickoff-readout-v1.md.
├── campaign-plan-*.md        # sister-skill strategy records, not written by this package. See contracts/sister-product-compat.md §2.
├── data/
│   ├── raw/                   # platform exports, verbatim as received — never edited after landing
│   ├── normalized/            # raw exports parsed into one schema per data type
│   ├── readouts/               # a judgment skill's own notes and conclusions, derived from normalized/
│   └── experiments/            # test plans written before a test runs. See experiment-design's own SKILL.md.
└── assets/                     # creative library — banner/GIF/copy prototypes and variants
    ├── source/                  # captured/downloaded source images. See contracts/asset-index-v1.md.
    ├── index.md                 # per-image catalog — schema asset-index/v1. See contracts/asset-index-v1.md.
    ├── cutouts/                  # background-removed PNGs, one per source image that succeeded. See ad-creative-pro/scripts/cutout.py.
    └── brand-kit.md              # logo/palette/layout preferences — schema brand-kit/v1. See contracts/brand-kit-v1.md.
```

### `data/`'s three layers

A judgment skill (`campaign-analysis` and the paid diagnostic skills) needs to tell "what the platform said" apart from "what we concluded from it." `raw/` is the platform's own export, untouched — the record you'd hand someone doing their own analysis. `normalized/` is that export reshaped into one schema per data type, so comparing two campaigns' exports doesn't mean reparsing two platforms' quirks every time. `readouts/` is a skill's own output — the conclusion it reached, when, from which normalized data — so the next session doesn't reprocess an export to re-derive an answer it already gave.

A judgment skill reads what's already in `data/` before asking the user for anything. Skills have no scheduling or standing access of their own: data only lands here when a user drops a file in, or an MCP integration pulls it.

### `assets/`

Creative output — banner and GIF prototypes, copy variants — lives here, deliberately outside `profile.md`. A file that's half static identity data and half something that changes every week is a design mistake: `profile.md` is the stable half, `assets/` is the half that churns.

### `assets/index.md`

Not part of the `data/` triad — it's a per-image catalog over `assets/source/`, built up across runs rather than overwritten each time the way `kickoff-readout.md` is. See `contracts/asset-index-v1.md` for its schema, write/read ownership, and append behavior.

### `assets/cutouts/`

Background-removed PNGs produced by `ad-creative-pro/scripts/cutout.py`, one per `assets/source/` image the script processed successfully — not an index-and-catalog file like `assets/index.md`, just an output directory a rendering skill checks before falling back to the flat original. No `rembg` installed, or the script hasn't run yet, means this directory is empty or absent — a normal state, not an error.

### `assets/brand-kit.md`

Not part of the `data/` triad either — reusable creative facts (which asset is the logo, the color palette, layout preferences heard in conversation), distinct from `assets/index.md`'s per-image catalog and closer in shape to `profile.md`'s stable identity data, just scoped to creative production instead of business facts. See `contracts/brand-kit-v1.md` for its schema and write ownership.

### `kickoff-readout.md`

Not part of the `data/` triad — it isn't derived from a `normalized/` export, it's `kickoff`'s own one-time website scan. See `contracts/kickoff-readout-v1.md` for its schema, write/read ownership, and overwrite behavior.

### `data/experiments/`

Also not part of the `data/` triad above — a test plan is written *before* a test runs, so it isn't derived from a `normalized/` export the way `readouts/` is. Written and read by `experiment-design`; see that skill's own `SKILL.md` for the plan's fields and filename convention. Once a test finishes, its results still land through the ordinary `raw/`/`normalized/`/`readouts/` path for `campaign-analysis-pro` to judge — `experiments/` holds the plan, never the outcome.

## Three conventions

**One client, one folder, one session.** An operator running this package across multiple clients gives each client its own project directory with its own `.agents/`. A `.agents/` folder belongs to exactly one client; a session works against exactly one client's folder at a time. This is what keeps "which client is this positioning file for" from ever being a question — the answer is the directory you're in.

**Confidentiality between clients.** A skill operating inside one client's `.agents/` does not read, reference, or aggregate anything from another client's `.agents/` — not for calibration, not for "here's what worked for a similar client," nothing. Cross-client rollups are out of scope for this package (portfolio-level aggregation is a future tier, not built here); the isolation above is what makes that boundary real rather than aspirational.

**Strategy documents get git PR sign-off.** Changes to `positioning.md` and `campaign-plan-*.md` go through a git PR before being treated as approved. This is the package's entire approval mechanism: no separate sign-off tool, no approval-status field to fake or forget to set. "Who approved this angle" is answered by "who approved the PR," which git already records.
