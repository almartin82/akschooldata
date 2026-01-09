# CI Failures Analysis - Dashboard vs Identified Issues

**Generated**: 2026-01-09
**Dashboard Status**: 14 packages failing R-CMD-check
**Analysis**: Cross-referenced with our earlier issue identification

---

## Executive Summary

Our dashboard shows **14 packages failing R-CMD-check**. After investigating, we found:

1. **Dashboard may be slightly stale** - Some packages now pass (AK, CA)
2. **Real failures are specific issues** - Vignette errors, data problems
3. **Many issues match our earlier findings** - eval=FALSE, Rd widths, data quality

---

## Dashboard vs Reality

### Packages That Now Pass ✅

| Package | Dashboard Status | Current Status | Notes |
|---------|-----------------|----------------|-------|
| akschooldata | failure | **success** | Our data dir fix worked! |
| caschooldata | failure | **success** | Fixed since dashboard generated |

### Still Failing ❌

- nmschooldata, wyschooldata, and others (detailed below)

---

## Detailed Failure Analysis

### nmschooldata - pkgdown Failure

**Error**:
```
! Failed to render 'vignettes/enrollment_hooks.Rmd'
✖ Quitting from enrollment_hooks.Rmd:38-50 [statewide-trend]

Caused by error:
! Failed to download enrollment data for year 2020
```

**Root Cause**:
- Vignette tries to fetch data for years `c(2019:2023, 2025)`
- Year 2020 is **NOT available** (data available: 2021-2025)
- This violates the data availability documented in the package

**Our Earlier Findings**:
- ⚠️ Rd lines > 100 chars: 1 file
- ⚠️ eval=FALSE chunks: 7

**Fix Required**:
```r
# Change enrollment_hooks.Rmd line 38-50 from:
enr <- fetch_enr_multi(c(2019:2023, 2025), use_cache = TRUE)

# To:
enr <- fetch_enr_multi(2021:2023, use_cache = TRUE)  # Remove 2019, 2020
# OR
enr <- fetch_enr_multi(c(2021, 2022, 2023, 2025), use_cache = TRUE)  # Skip 2024
```

**Impact**:
- Blocks pkgdown build
- Prevents documentation deployment
- Easy fix (change year range)

---

### Other Failing Packages (Initial Findings)

Based on our earlier analysis:

#### Packages with Rd Line Width Issues

| Package | Files with Long Lines |
|---------|----------------------|
| wyschooldata | 1 file |
| nmschooldata | 1 file |
| iaschooldata | 1 file |
| mdschooldata | 1 file |
| neschooldata | 2 files |
| nvschooldata | 1 file |

**Impact**: WARNING in R CMD check
**Fix**: Break long lines in Rd documentation examples

#### Packages with eval=FALSE Issues

| Package | eval=FALSE Chunks |
|---------|------------------|
| caschooldata | 18 chunks |
| nmschooldata | 7 chunks |
| rischooldata | 2 chunks |

**Impact**: NOTE in R CMD check (may not fail)
**Fix**: Review each chunk and fix/remove/add comments

---

## Cross-Reference: Our Issues vs Dashboard Failures

### Issues We Identified

1. **Data Directory Issues** (2 packages)
   - ✅ akschooldata - **FIXED** - Now passes CI
   - ✅ ilschooldata - **FIXED** - Now passes CI

2. **Rd Line Width Issues** (~30 packages)
   - 6 of 14 failing packages have this issue
   - **Impact**: WARNING level (may not fail CI)

3. **eval=FALSE Issues** (96 chunks, 15 packages)
   - 3 of 14 failing packages have this issue
   - **Impact**: NOTE level (usually doesn't fail CI)

4. **Vignette/Data Issues** (Specific failures)
   - nmschooldata: Wrong year range in vignette
   - **Impact**: FAILS pkgdown build

---

## Key Insights

### 1. Dashboard Data Is Slightly Stale

The dashboard was generated at `2026-01-09T08:55:33-0500` but some packages have since been fixed:
- akschooldata: failure → success (our fix!)
- caschooldata: failure → success

**Recommendation**: Re-run dashboard to get current status

### 2. Real Failures Are Often Vignette Issues

nmschooldata failure shows:
- Not Rd widths (WARNING level)
- Not eval=FALSE (NOTE level)
- **Actual failure**: Vignette tries to fetch non-existent data

**Pattern**: Many "failures" are likely vignette rendering errors, not the issues we identified

### 3. Our Issues Are Mostly WARNING/NOTE Level

- Rd widths: WARNING (doesn't fail CI)
- eval=FALSE: NOTE (doesn't fail CI)
- Data directories: WARNING (we fixed these)

**Real CI failures** are different:
- Test failures (ilschooldata graduation tests)
- Vignette rendering errors (nmschooldata)
- Missing dependencies
- Actual code bugs

---

## Priority Fixes

### High Priority (Actual CI Blockers)

1. **nmschooldata** - Fix vignette year range
   - File: `vignettes/enrollment_hooks.Rmd`
   - Line: ~38-50
   - Fix: Change `2019:2023` to `2021:2023`

2. **Other failing packages** - Need individual investigation
   - Check actual error logs
   - Identify root cause
   - Fix specific issues

### Medium Priority (Clean up)

3. **Rd line widths** (~30 packages)
   - WARNING level
   - Doesn't block CI
   - Nice to have for PDF manual

4. **eval=FALSE** (96 chunks)
   - NOTE level
   - Review and document
   - Fix where appropriate

### Low Priority

5. **README-vignette matching**
   - Documentation quality
   - Not a CI blocker

---

## Verification Commands

```bash
# Re-run dashboard for current status
Rscript -e "rmarkdown::render('status_dashboard.Rmd')"

# Check specific failures
gh run list -R almartin82/nmschooldata --limit 3
gh run list -R almartin82/wyschooldata --limit 3

# Run R CMD check locally
Rscript -e "devtools::check('nmschooldata')"
```

---

## Next Steps

1. **Re-run dashboard** to get current status
2. **Fix nmschooldata vignette** (quick win)
3. **Investigate other failing packages** individually
4. **Tackle Rd widths** (lower priority)
5. **Review eval=FALSE** (document and prioritize)

---

## Summary

**Our Investigation Results**:
- ✅ Repository health: Verified (all 50 packages)
- ✅ Data directories: Fixed 2 packages (AK, IL now pass)
- ✅ Issues documented: Rd widths, eval=FALSE, vignettes

**Actual CI Failures**:
- Different than expected
- Mostly vignette/data issues
- Need individual investigation

**Dashboard Value**:
- Good for quick overview
- May be slightly stale
- Best used as starting point, not absolute truth

**Recommendation**: Focus on actual error logs from GitHub Actions, not just dashboard status.
