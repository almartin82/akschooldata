## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source** — the entire point of these packages is to provide STATE-LEVEL data directly from state DOEs. Federal sources aggregate/transform data differently and lose state-specific details. If a state DOE source is broken, FIX IT or find an alternative STATE source — do not fall back to federal data.

---

### CONCURRENT TASK LIMIT
- **Maximum 5 background tasks running simultaneously**
- When launching multiple agents (e.g., for mass audits), batch them in groups of 5
- Wait for the current batch to complete before launching the next batch

---

# Claude Code Instructions

## Git Commits and PRs
- NEVER reference Claude, Claude Code, or AI assistance in commit messages
- NEVER reference Claude, Claude Code, or AI assistance in PR descriptions
- NEVER add Co-Authored-By lines mentioning Claude or Anthropic
- Keep commit messages focused on what changed, not how it was written

---

## Git Workflow (REQUIRED)

### Feature Branch + PR + Auto-Merge Policy

**NEVER push directly to main.** All changes must go through PRs with auto-merge:

```bash
# 1. Create feature branch
git checkout -b fix/description-of-change

# 2. Make changes, commit
git add -A
git commit -m "Fix: description of change"

# 3. Push and create PR with auto-merge
git push -u origin fix/description-of-change
gh pr create --title "Fix: description" --body "Description of changes"
gh pr merge --auto --squash

# 4. Clean up stale branches after PR merges
git checkout main && git pull && git fetch --prune origin
```

### Branch Cleanup (REQUIRED)

**Clean up stale branches every time you touch this package:**

```bash
# Delete local branches merged to main
git branch --merged main | grep -v main | xargs -r git branch -d

# Prune remote tracking branches
git fetch --prune origin
```

### Auto-Merge Requirements

PRs auto-merge when ALL CI checks pass:
- R-CMD-check (0 errors, 0 warnings)
- Python tests (if py{st}schooldata exists)
- pkgdown build (vignettes must render)

If CI fails, fix the issue and push - auto-merge triggers when checks pass.

---

## Local Testing Before PRs (REQUIRED)

**PRs will not be merged until CI passes.** Run these checks locally BEFORE opening a PR:

### CI Checks That Must Pass

| Check | Local Command | What It Tests |
|-------|---------------|---------------|
| R-CMD-check | `devtools::check()` | Package builds, tests pass, no errors/warnings |
| Python tests | `pytest tests/test_pyakschooldata.py -v` | Python wrapper works correctly |
| pkgdown | `pkgdown::build_site()` | Documentation and vignettes render |

### Quick Commands

```r
# R package check (required)
devtools::check()

# Python tests (required)
system("pip install -e ./pyakschooldata && pytest tests/test_pyakschooldata.py -v")

# pkgdown build (required)
pkgdown::build_site()
```

### Pre-PR Checklist

Before opening a PR, verify:
- [ ] `devtools::check()` — 0 errors, 0 warnings
- [ ] `pytest tests/test_pyakschooldata.py` — all tests pass
- [ ] `pkgdown::build_site()` — builds without errors
- [ ] Vignettes render (no `eval=FALSE` hacks)

---

## LIVE Pipeline Testing

This package includes `tests/testthat/test-pipeline-live.R` with LIVE network tests.

### Test Categories:
1. URL Availability - HTTP 200 checks
2. File Download - Verify actual file (not HTML error)
3. File Parsing - readxl/readr succeeds
4. Column Structure - Expected columns exist
5. get_raw_enr() - Raw data function works
6. Data Quality - No Inf/NaN, non-negative counts
7. Aggregation - State total > 0
8. Output Fidelity - tidy=TRUE matches raw

### Running Tests:
```r
devtools::test(filter = "pipeline-live")
```

---

## Fidelity Requirement

**tidy=TRUE MUST maintain fidelity to raw, unprocessed data:**
- Enrollment counts in tidy format must exactly match the wide format
- No rounding or transformation of counts during tidying
- Percentages are calculated fresh but counts are preserved
- State aggregates are sums of school-level data

---

## README Images from Vignettes (REQUIRED)

**NEVER use `man/figures/` or `generate_readme_figs.R` for README images.**

README images MUST come from pkgdown-generated vignette output so they auto-update on merge:

```markdown
![Chart name](https://almartin82.github.io/{package}/articles/{vignette}_files/figure-html/{chunk-name}-1.png)
```

**Why:** Vignette figures regenerate automatically when pkgdown builds. Manual `man/figures/` requires running a separate script and is easy to forget, causing stale/broken images.

---

## README and Vignette Code Matching (REQUIRED)

**CRITICAL RULE (as of 2026-01-08):** ALL code blocks in the README MUST match code in a vignette EXACTLY (1:1 correspondence).

### Why This Matters

The Idaho fix revealed critical bugs when README code didn't match vignettes:
- Wrong district names (lowercase vs ALL CAPS)
- Text claims that contradicted actual data
- Missing data output in examples

### README Story Structure (REQUIRED)

Every story/section in the README MUST follow this structure:

1. **Claim**: A factual statement about the data
2. **Explication**: Brief explanation of why this matters
3. **Code**: R code that fetches and analyzes the data (MUST exist in a vignette)
4. **Code Output**: Data table/print statement showing actual values (REQUIRED)
5. **Visualization**: Chart from vignette (auto-generated from pkgdown)

### Enforcement

The `state-deploy` skill verifies this before deployment:
- Extracts all README code blocks
- Searches vignettes for EXACT matches
- Fails deployment if code not found in vignettes
- Randomly audits packages for claim accuracy

### What This Prevents

- Wrong district/entity names (case sensitivity, typos)
- Text claims that contradict data
- Broken code that fails silently
- Missing data output
- Verified, accurate, reproducible examples

---

# akschooldata

## Data Availability

**Available Years:** 2021-2025

| Year | Grade Data | Ethnicity Data | Notes |
|------|------------|----------------|-------|
| 2021 | Yes | Yes | Old format (ID/District/School Name) |
| 2022 | Yes | Yes | Old format |
| 2023 | Yes | Yes | Old format |
| 2024 | Yes | Yes | New format (Type/id/District/School) |
| 2025 | Yes | Yes | New format |

**Data Source:** Alaska Department of Education & Early Development (DEED)
- URL: https://education.alaska.gov/Stats/enrollment/
- Files: "Enrollment by School by Grade" and "Enrollment by School by ethnicity"

## Data Format Differences

The DEED changed their file format between 2023 and 2024:
- **2021-2023:** Title row in row 1, headers in row 2, uses ID/District/School Name columns
- **2024-2025:** Headers in row 1, uses Type/id/District/School columns

The package handles both formats automatically.

## Test Coverage

The test suite verifies:
1. **All years fetchable:** 2021-2025 all download and process successfully
2. **All subgroups present:** total_enrollment, white, black, hispanic, asian, native_american, pacific_islander, multiracial
3. **All grade levels present:** TOTAL, PK, K, 01-12
4. **Data quality:**
   - No negative enrollment counts
   - No Inf/NaN percentages
   - State totals match sum of districts (within 1% tolerance)
   - Ethnicity sums approximately equal total (within 5%)
   - Large districts have non-zero values for all ethnicities
5. **Fidelity:** tidy=TRUE preserves exact raw counts from wide format

## Known Data Issues

1. **2021 orphan schools:** 3 schools (Hoonah, Yakutat, LEAD) lack district assignments in source data, causing ~300 student difference between state total and district sums
2. **Duplicate campus IDs:** A few schools appear in multiple districts due to shared IDs in source data
3. **Excel warnings:** "end of table" rows generate readxl warnings (filtered out during processing)
