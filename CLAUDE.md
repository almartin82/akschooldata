## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source** - the entire point of these packages is to provide STATE-LEVEL data directly from state DOEs. Federal sources aggregate/transform data differently and lose state-specific details. If a state DOE source is broken, FIX IT or find an alternative STATE source - do not fall back to federal data.

---

# Claude Code Instructions

### GIT COMMIT POLICY
- Commits are allowed
- NO Claude Code attribution, NO Co-Authored-By trailers, NO emojis
- Write normal commit messages as if a human wrote them

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

# Package Documentation

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

## Fidelity Requirement

**tidy=TRUE MUST maintain fidelity to raw, unprocessed data:**
- Enrollment counts in tidy format must exactly match the wide format
- No rounding or transformation of counts during tidying
- Percentages are calculated fresh but counts are preserved
- State aggregates are sums of school-level data

## Known Data Issues

1. **2021 orphan schools:** 3 schools (Hoonah, Yakutat, LEAD) lack district assignments in source data, causing ~300 student difference between state total and district sums
2. **Duplicate campus IDs:** A few schools appear in multiple districts due to shared IDs in source data
3. **Excel warnings:** "end of table" rows generate readxl warnings (filtered out during processing)


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

See `state-schooldata/CLAUDE.md` for complete testing framework documentation.

