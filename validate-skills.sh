#!/bin/bash
# validate-skills.sh (v2) — pre-ship lint for ai-skills-pack-v2
#
# Checks (rule <-> AUTHORING.md correspondence, see 02-worklog.md for the full table):
#   1. Frontmatter exists and parses — both opening AND closing `---` required; all other
#      fields are parsed strictly within that span, never from the file at large
#   2. name: matches directory name, lowercase/digits/hyphen, 1-64 chars
#   3. description: non-empty, <= 1024 chars, no CJK characters (AUTHORING "Language")
#   4. metadata.tier is exactly "free" or "paid" (AUTHORING "Tier marking")
#   5. SKILL.md line count <= 500 (inherited from v1; AUTHORING sets no different number)
#   6. Freshness marker format: a `last_verified:` line must hold YYYY-MM-DD and the
#      immediately following line must be a non-empty `Source:` line (AUTHORING
#      "Freshness markers"); EOF with a still-pending marker also flags. Severity split:
#      empty/missing Source = ISSUE; Source present but with no
#      recognizable http(s):// URL in it = WARNING (human review, doesn't block ship);
#      Source containing a URL = silent pass
#   7. Relative markdown links (plain, `<...>`, or with a title) resolve to an existing
#      file or directory
#   8. GEO content lives only under references/geo/<iso-alpha-2>.md, checked recursively
#      (AUTHORING "GEO modules")
#   9. The pack directory must exist and contain at least one skill (a SKILL.md) — an
#      empty or misspelled pack path is a failure, not a silent zero-issue pass
#
# Usage: ./validate-skills.sh [pack_dir]   (default: this script's own directory)
# Exit code: 0 when no ISSUE was found, 1 otherwise.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="${1:-$SCRIPT_DIR}"

MAX_SKILL_LINES=500
MAX_DESC_LEN=1024
CJK_PATTERN='[\x{3040}-\x{30ff}\x{3400}-\x{4dbf}\x{4e00}-\x{9fff}\x{ac00}-\x{d7a3}\x{ff00}-\x{ffef}]'

TOTAL_ISSUES=0
TOTAL_WARNINGS=0
SKILLS_PASSED=0
SKILLS_WARNED=0
SKILLS_FAILED=0

report_issue() {
    echo "  [ISSUE] $1"
    ((TOTAL_ISSUES++))
}

report_warning() {
    echo "  [WARN]  $1"
    ((TOTAL_WARNINGS++))
}

# Freshness-marker format + relative-link existence for one markdown file.
check_freshness_and_links() {
    local file="$1"
    local dir
    dir="$(dirname "$file")"

    # A `last_verified:` line must hold YYYY-MM-DD, and the very next line must be a
    # non-empty `Source:` line. The END block catches a `last_verified:` on the file's
    # last line, which would otherwise never see a "next line" to check (R1 must-fix).
    #
    # Source-value severity: campaign-analysis/references/stop-loss-thresholds.md:55
    # ships a real, intentional `Source:` line with no URL, "not an official platform
    # policy, so there is no external URL to re-check against"; ads/references/geo/tw.md:120
    # similarly points back at an earlier citation instead of a URL. So: empty/missing
    # Source = ISSUE; Source present but no recognizable http(s):// URL substring anywhere
    # in it = WARNING (flag for human review, don't block ship — catches unverifiable
    # provenance without false-positiving genuine non-URL provenance); Source
    # containing a URL = silent pass, no report.
    # Field separator \x1f (unit separator) instead of ":" — a URL value itself contains
    # colons, which would break a naive ":"-delimited split.
    local fresh_hits
    fresh_hits=$(awk -v RS='\n' -v FS='\x1f' '
        { line = $0; sub(/\r$/, "", line) }
        pending == 1 {
            if (line !~ /^Source:/) {
                print (NR - 1) "\x1fMISSING_SOURCE\x1f"
            } else {
                content = line
                sub(/^Source:[ \t]*/, "", content)
                if (content == "") print (NR - 1) "\x1fMISSING_SOURCE\x1f"
                else print (NR - 1) "\x1fSOURCE_LINE\x1f" content
            }
            pending = 0
        }
        line ~ /^last_verified:[ \t]*/ {
            val = line
            sub(/^last_verified:[ \t]*/, "", val)
            if (val !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) print NR "\x1fBAD_DATE\x1f" val
            pending = 1
        }
        END {
            if (pending == 1) print NR "\x1fMISSING_SOURCE\x1f"
        }
    ' "$file")
    if [[ -n "$fresh_hits" ]]; then
        while IFS=$'\x1f' read -r lineno kind rest; do
            [[ -z "$lineno" ]] && continue
            case "$kind" in
                MISSING_SOURCE)
                    report_issue "$file:$lineno: last_verified line not followed by a non-empty Source: line"
                    ;;
                BAD_DATE)
                    report_issue "$file:$lineno: last_verified value '$rest' is not YYYY-MM-DD"
                    ;;
                SOURCE_LINE)
                    if ! [[ "$rest" =~ https?://[^[:space:]\<\>\)]+ ]]; then
                        report_warning "$file:$lineno: Source has no recognizable http(s):// URL (non-URL provenance, human review suggested): ${rest:0:120}"
                    fi
                    ;;
            esac
        done <<< "$fresh_hits"
    fi

    local links
    links=$(grep -oP '(?<=\]\()[^)]+(?=\))' "$file" 2>/dev/null || true)
    if [[ -n "$links" ]]; then
        while IFS= read -r link; do
            [[ -z "$link" ]] && continue
            # strip an optional Markdown link title: (url "title") or (url 'title')
            link="${link%% \"*}"
            link="${link%% \'*}"
            # strip an optional <...> destination wrapper
            if [[ "$link" == "<"*">" ]]; then
                link="${link#<}"
                link="${link%>}"
            fi
            case "$link" in
                http://*|https://*|mailto:*|tel:*|/*) continue ;;
            esac
            local target="${link%%#*}"
            [[ -z "$target" ]] && continue
            # A target may be a file or a directory link (e.g. `geo/`, used deliberately in
            # ad-creative/references/platform-specs.md to reference the whole geo/ folder) —
            # `test -e` treats both as existing; `test -f` alone false-positives on that link.
            if ! (cd "$dir" 2>/dev/null && test -e "$target"); then
                report_issue "$file: broken relative link -> $link"
            fi
        done <<< "$links"
    fi
}

if [[ ! -d "$PACK_DIR" ]]; then
    echo "[ISSUE] pack directory not found: $PACK_DIR"
    exit 1
fi

echo "Validating skill pack: $PACK_DIR"
echo "======================================================"
echo ""
echo "== Skills =="

SKILL_DIRS_FOUND=0

for skill_dir in "$PACK_DIR"/*/; do
    skill_name="$(basename "$skill_dir")"
    skill_file="$skill_dir/SKILL.md"

    [[ "$skill_name" == "contracts" || "$skill_name" == "shared" ]] && continue
    [[ ! -f "$skill_file" ]] && continue
    ((SKILL_DIRS_FOUND++))

    issues_before=$TOTAL_ISSUES
    warnings_before=$TOTAL_WARNINGS
    echo "-- $skill_name --"

    # Locate the first two `---` delimiter lines (CRLF-tolerant); frontmatter is only
    # legal, and only parsed, strictly between them (R1 must-fix: a body section could
    # otherwise impersonate frontmatter when only an opening `---` exists).
    delims=($(tr -d '\r' < "$skill_file" | grep -n -x -- '---' | head -2 | cut -d: -f1))
    if [[ "${#delims[@]}" -lt 2 ]]; then
        report_issue "missing or unparsable YAML frontmatter (need both opening and closing ---)"
    else
        frontmatter=$(sed -n "$((${delims[0]} + 1)),$((${delims[1]} - 1))p" "$skill_file")
        # ---- name ----
        name_in_file=$(echo "$frontmatter" | grep '^name:' | head -1 | sed -E 's/^name:[ \t]*//; s/[ \t\r]+$//')
        if [[ -z "$name_in_file" ]]; then
            report_issue "missing 'name' field in frontmatter"
        elif [[ "$name_in_file" != "$skill_name" ]]; then
            report_issue "name mismatch: directory='$skill_name' frontmatter='$name_in_file'"
        elif ! [[ "$name_in_file" =~ ^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$ ]]; then
            report_issue "invalid name format '$name_in_file' (lowercase alphanumeric + hyphen only)"
        fi

        # ---- description ----
        description=$(echo "$frontmatter" | grep '^description:' | head -1 | sed 's/^description:[ \t]*//')
        description="${description%\"}"
        description="${description#\"}"
        if [[ -z "$description" ]]; then
            report_issue "missing 'description' field in frontmatter"
        else
            desc_len=${#description}
            if (( desc_len < 1 || desc_len > MAX_DESC_LEN )); then
                report_issue "description length $desc_len chars (must be 1-$MAX_DESC_LEN)"
            fi
            if echo "$description" | grep -qP "$CJK_PATTERN"; then
                report_issue "description contains non-English (CJK) characters"
            fi
        fi

        # ---- tier ---- (scoped to the frontmatter block only, not the whole file —
        # R1 must-fix: a body section could otherwise impersonate a metadata: block)
        metadata_block=$(echo "$frontmatter" | awk '/^metadata:[\r]?$/{f=1; next} f && /^[^ \t]/{f=0} f')
        tier_value=$(echo "$metadata_block" | grep '^[ \t]*tier:' | head -1 | sed -E 's/^[ \t]*tier:[ \t]*//' | tr -d "\"' \r")
        if [[ "$tier_value" != "free" && "$tier_value" != "paid" ]]; then
            report_issue "metadata.tier is '$tier_value' (must be 'free' or 'paid')"
        fi
    fi

    # ---- SKILL.md line count ---- (awk NR, not `wc -l`, so a file missing its final
    # newline still counts its last line — R1 should-fix)
    line_count=$(awk 'END{print NR}' "$skill_file")
    if (( line_count > MAX_SKILL_LINES )); then
        report_warning "SKILL.md is $line_count lines (should be <= $MAX_SKILL_LINES)"
    fi

    # ---- GEO module placement ----
    # One recursive pass over references/, classifying every .md by its path relative to
    # references/geo/: (a) sits directly in references/geo/ -> filename must be an ISO
    # alpha-2 code; (b) nested deeper under references/geo/<sub>/... -> ISSUE, AUTHORING
    # requires references/geo/<code>.md with no further nesting (R2 must-fix: the R1 fix
    # excluded all of references/geo/* from the escape scan, but never itself checked
    # what was nested inside it, e.g. references/geo/archive/tw.md went unchecked by
    # either check); (c) outside references/geo/ entirely -> a bare 2-letter filename is
    # GEO content that escaped its module directory.
    if [[ -d "${skill_dir}references" ]]; then
        while IFS= read -r -d '' mdfile; do
            rel="${mdfile#${skill_dir}references/}"
            case "$rel" in
                geo/*)
                    sub="${rel#geo/}"
                    if [[ "$sub" == */* ]]; then
                        report_issue "GEO file nested too deep (must sit directly in references/geo/, not a subdirectory): $mdfile"
                    else
                        code=$(basename "$mdfile" .md)
                        if ! [[ "$code" =~ ^[a-z]{2}$ ]]; then
                            report_issue "GEO file '$mdfile' has a non-ISO-3166-1-alpha-2 filename '$code'"
                        fi
                    fi
                    ;;
                *)
                    base=$(basename "$mdfile" .md)
                    if [[ "$base" =~ ^[a-z]{2}$ ]]; then
                        report_issue "GEO-coded filename outside references/geo/: $mdfile"
                    fi
                    ;;
            esac
        done < <(find "${skill_dir}references" -type f -name '*.md' -print0)
    fi

    # ---- freshness markers + relative links, whole skill dir ----
    while IFS= read -r -d '' mdfile; do
        check_freshness_and_links "$mdfile"
    done < <(find "$skill_dir" -type f -name '*.md' -print0)

    if (( TOTAL_ISSUES > issues_before )); then
        ((SKILLS_FAILED++))
    elif (( TOTAL_WARNINGS > warnings_before )); then
        echo "  [PASS]  (with warnings above)"
        ((SKILLS_WARNED++))
    else
        echo "  [PASS]"
        ((SKILLS_PASSED++))
    fi
done

# A pack directory that exists but is empty, or wrong, would otherwise finish with zero
# issues and report false success (R1 must-fix).
if (( SKILL_DIRS_FOUND == 0 )); then
    report_issue "no skill directory with a SKILL.md was found under $PACK_DIR"
fi

echo ""
echo "== contracts/ and shared/ (subset: links + freshness markers only) =="

for subdir in contracts shared; do
    [[ -d "$PACK_DIR/$subdir" ]] || continue
    while IFS= read -r -d '' mdfile; do
        issues_before=$TOTAL_ISSUES
        warnings_before=$TOTAL_WARNINGS
        echo "-- $mdfile --"
        check_freshness_and_links "$mdfile"
        if (( TOTAL_ISSUES > issues_before )); then
            :
        elif (( TOTAL_WARNINGS > warnings_before )); then
            echo "  [PASS]  (with warnings above)"
        else
            echo "  [PASS]"
        fi
    done < <(find "$PACK_DIR/$subdir" -type f -name '*.md' -print0)
done

echo ""
echo "======================================================"
echo "Summary:"
echo "  Skills passed clean : $SKILLS_PASSED"
echo "  Skills with warnings: $SKILLS_WARNED"
echo "  Skills with issues  : $SKILLS_FAILED"
echo "  Total issues        : $TOTAL_ISSUES"
echo "  Total warnings      : $TOTAL_WARNINGS"
echo ""

if (( TOTAL_ISSUES == 0 )); then
    echo "All checks passed."
    exit 0
else
    echo "Found $TOTAL_ISSUES issue(s) that need fixing."
    exit 1
fi
