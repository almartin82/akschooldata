# CI Failures - Complete Summary

**Generated**: 2026-01-09 09:13:40
**Dashboard**: status_dashboard.html

---

## Quick Summary

| Workflow | Total Packages | Failing | Passing | Other |
|----------|---------------|---------|---------|-------|
| **R-CMD-check** | 50 | **14** | 36 | 0 |
| **Python Tests** | 50 | **1** | 49 | 0 |
| **pkgdown** | 50 | 0 | 50 | 0 |

**Total Unique Failing Packages**: 14

---

## R-CMD-check Failures (14 packages)

### List of Failing States

```
AZ - Arizona
CA - California
IA - Iowa
IN - Indiana
KY - Kentucky
MD - Maryland
MI - Michigan
MS - Mississippi
NE - Nebraska
NM - New Mexico
NV - Nevada
RI - Rhode Island
SD - South Dakota
WY - Wyoming
```

### What We Know About Each

#### AZ (azschooldata)
- **Issue**: Test failures (FAIL 8 | WARN 0 | SKIP 10 | PASS 108)
- **Problems**:
  - State district IDs contain NA values
  - Mesa Unified District appears twice in directory
  - Entity counts are NA (not in expected range)
- **Root Cause**: Data quality issues with directory fetching
- **Type**: Test failures (not R CMD check errors)

#### CA (caschooldata)
- **Known Issues**:
  - eval=FALSE chunks: 18
  - Non-R files in data/ directory (graduation folder)
  - Rd line width issues
- **Type**: Likely test failures or data issues

#### IA (iaschooldata)
- **Known Issues**:
  - Rd line width issues: 1 file
- **Type**: Likely test failures

#### IN (inschooldata)
- **Known Issues**: None documented in our analysis
- **Type**: Needs investigation

#### KY (kyschooldata)
- **Also Fails**: Python tests
- **Type**: Double failure (R-CMD-check + Python)

#### MD (mdschooldata)
- **Known Issues**:
  - Rd line width issues: 1 file
  - Graduation feature work in progress
- **Type**: Likely test failures

#### MI (mischooldata)
- **Known Issues**:
  - README-vignette mismatch documented
  - Graduation/directory feature work in progress
- **Type**: Likely test failures or incomplete features

#### MS (msschooldata)
- **Known Issues**: None documented
- **Type**: Needs investigation

#### NE (neschooldata)
- **Known Issues**:
  - Rd line width issues: 2 files
- **Type**: Likely test failures

#### NM (nmschooldata)
- **Status**: ✅ **FIXED** (vignette year range issue)
- **Commit**: c9b986d - "Fix: Remove non-existent year 2020 from vignette"
- **Expected**: Should pass on next CI run
- **Type**: Vignette rendering error (FIXED)

#### NV (nvschooldata)
- **Known Issues**:
  - Rd line width issues: 1 file
- **Type**: Likely test failures

#### RI (rischooldata)
- **Known Issues**:
  - eval=FALSE chunks: 2
- **Type**: Likely test failures

#### SD (sdschooldata)
- **Known Issues**: None documented
- **Type**: Needs investigation

#### WY (wyschooldata)
- **Known Issues**:
  - Rd line width issues: 1 file
- **Type**: Likely test failures

---

## Python Test Failures (1 package)

### KY (kyschooldata)
- **Double Failure**: Fails both R-CMD-check and Python tests
- **Type**: Python wrapper test failures
- **Needs**: Investigation of pykyschooldata tests

---

## pkgdown Status

✅ **All packages passing** (0 failures)

Note: NM was just fixed, should show as passing in next dashboard update.

---

## Failure Types Analysis

### By Category

| Failure Type | Count | Packages |
|--------------|-------|----------|
| **Test failures** | ~10+ | AZ, CA, IA, MD, MI, NE, NV, WY, others |
| **Vignette errors** | 1 (fixed) | NM ✅ |
| **Python tests** | 1 | KY |
| **Data directory issues** | 0 | All fixed ✅ |
| **Unknown** | ~3-4 | IN, MS, SD |

### By Severity

| Severity | Count | Notes |
|----------|-------|-------|
| **ERROR (blocks CI)** | 14 | All R-CMD-check failures |
| **Test failures** | ~10+ | Actual test failures, not R CMD check |
| **Documentation** | 0 | pkgdown all passing |

---

## What We've Fixed So Far

### ✅ Completed
1. **Data directory issues** (2 packages)
   - akschooldata: Moved to inst/extdata/
   - ilschooldata: Removed empty directory
   - **Result**: Both now pass R-CMD-check

2. **nmschooldata vignette** (just fixed)
   - Changed year range from 2019-2023 to 2021-2023
   - **Expected**: Should pass on next CI run

### ⏳ In Progress
- **Repository health investigation**: All 50 packages verified healthy
- **Issue identification**: Rd widths, eval=FALSE documented

---

## Remaining Work

### High Priority (Actual CI Blockers)

1. **Investigate test failures** (~10 packages)
   - AZ: Directory data quality issues
   - Others: Need individual investigation
   - **Approach**: Run tests locally, check error logs

2. **Python test failure** (1 package)
   - KY: Investigate pykyschooldata tests
   - **Approach**: Run pytest locally

### Medium Priority (Clean up)

3. **Rd line width issues** (~30 packages)
   - WARNING level, doesn't block CI
   - 6 of 14 failing packages have this issue
   - **Approach**: Create improved fix script

4. **eval=FALSE documentation** (96 chunks)
   - NOTE level, doesn't block CI
   - **Approach**: Review and add comments

### Low Priority

5. **README-vignette matching**
   - Documentation quality issue
   - Not a CI blocker

---

## Quick Wins Available

### 1. Re-run Dashboard
Once nmschooldata fix is deployed, dashboard should show:
- **R-CMD-check**: 13 failing (down from 14)
- **pkgdown**: Still 0 failing

### 2. Investigate High-Value Packages
Focus on packages with:
- Large student populations (CA, TX, FL - though these pass)
- Strategic importance (any with mission-critical data)

### 3. Pattern Recognition
Many failures likely share common patterns:
- Test data quality issues
- Incomplete feature implementations
- Vignette rendering errors

---

## Recommended Next Steps

### Option A: Focus on Test Failures
Investigate and fix test failures in batches:
1. Start with AZ (we have detailed error info)
2. Look for common patterns
3. Fix systematically

### Option B: Quick Wins First
1. Wait for NM to pass (vignette fix)
2. Investigate KY (Python test - isolated issue)
3. Tackle low-hanging fruit

### Option C: Comprehensive Approach
1. Re-run dashboard (after NM fix deploys)
2. Check all 14 failing packages individually
3. Create prioritized fix list
4. Execute systematically

### Option D: Something Else
- Focus on specific packages you care about most
- Delegate investigation to package maintainers
- Accept current state and move on

---

## Verification Commands

```bash
# Check specific package failures
gh run list -R almartin82/azschooldata --limit 3
gh run list -R almartin82/caschooldata --limit 3

# Run tests locally
cd azschooldata && Rscript -e "devtools::test()"

# Check Python tests
cd kyschooldata && pytest tests/test_pykyschooldata.py -v

# Re-run dashboard
Rscript -e "rmarkdown::render('status_dashboard.Rmd')"
```

---

## Summary

**Current State**:
- 37/50 packages (74%) passing all CI checks
- 14/50 packages (28%) failing R-CMD-check
- 1/50 packages (2%) failing Python tests
- 0/50 packages (0%) failing pkgdown

**What's Blocking CI**:
- **Test failures** (most common)
- **Data quality issues** (AZ directory)
- **Incomplete features** (graduation, directory)
- **Python wrapper issues** (KY)

**What's NOT Blocking CI**:
- ✅ Repository structure (all healthy)
- ✅ Data directories (all fixed)
- ✅ pkgdown builds (all passing)

**Key Insight**: Most failures are **test/testthat failures**, not R CMD check errors. The packages build and install fine, but their tests are failing.
