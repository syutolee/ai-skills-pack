# `kickoff-readout/v1` — kickoff scan snapshot contract

`.agents/kickoff-readout.md` carries `kickoff`'s website-scan snapshot across sessions: the reply `kickoff` gives the user at the end of a run doesn't survive past that conversation, but this file does. Not part of `data/`'s raw/normalized/readouts triad — it's a one-time scan, not derived from a platform export. See `contracts/agents-dir-conventions.md` for where it sits inside `.agents/`.

## Frontmatter

```yaml
---
schema: kickoff-readout/v1
generated_by: kickoff
generated_at: YYYY-MM-DD
---
```

## Fixed sections

Body sections are fixed in heading text and order:

```markdown
## Tracking Scan

## Angle Candidates (unverified)

## Data Checklist Gaps
```

### What each section holds

| Section | Holds |
|---|---|
| **Tracking Scan** | The scan's signature-by-signature results, or "not scanned — degraded input, no HTML available" |
| **Angle Candidates (unverified)** | 2-3 distinct audience/angle candidates, verbatim, each still marked unverified |
| **Data Checklist Gaps** | The blanks left in `profile.md` after this run — the same list surfaced to the user on close |

## Who writes it, who reads it

`kickoff` is the only writer, and overwrites the whole file on every run — there is exactly one active onboarding snapshot per client, the same singular shape as `profile.md` and `positioning.md` (unlike `campaign-plan-*.md`, which intentionally accumulates dated files).

`quick-angle`'s prefill entry point is the only reader: it loads `## Angle Candidates (unverified)` to offer as a starting draft instead of interrogating from scratch. Nothing else in this package reads this file.
