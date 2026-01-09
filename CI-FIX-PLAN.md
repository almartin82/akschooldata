# Comprehensive CI Fix Plan for State Schooldata Packages

## Repository Health Summary
✅ **Repository Structure**: HEALTHY - No git/submodule issues
✅ **Build Artifacts**: CLEANED - No .venv, .tar.gz, or data-cache directories

## CI Issues Identified

### Priority 1: Easy Wins (High Impact, Low Effort)

#### 1. Rd Line Width Warnings (~30 packages)
**Issue**: Documentation examples exceed 100 characters
**Impact**: WARNING in R CMD check
**Fix Strategy**: Break long example lines into multiple lines
**Packages**: arschooldata, caschooldata, coschooldata, flschooldata, gaschooldata, iaschooldata, idschooldata, ilschooldata, ksschooldata, laschooldata, mdschooldata, meschooldata, ncschooldata, neschooldata, nhschooldata, njschooldata, nv, tx, vt, wa, wi, wy, + more

**Implementation**:
- Split into 3 groups of ~10 packages each
- Run in parallel background tasks
- Use sed/awk to reformat Rd examples

#### 2. Data Directory Issues (2 packages)
**Issue A**: Non-R files in data/ directory
- **Package**: akschooldata
- **Problem**: `data/graduation` directory contains non-R data
- **Fix**: Move to `inst/extdata/graduation`

**Issue B**: Empty data/ directory
- **Package**: ilschooldata
- **Problem**: Empty `data/` directory triggers WARNING
- **Fix**: Remove empty directory or add placeholder .rda file

### Priority 2: Medium Impact (Moderate Effort)

#### 3. eval=FALSE in Vignettes (~15 packages)
**Issue**: Code chunks marked with `eval=FALSE` (won't execute during check)
**Impact**: NOTE in R CMD check, may indicate broken code
**Packages**: akschooldata, alschooldata, arschooldata, caschooldata, ctschooldata, hischooldata, ilschooldata, ndschooldata, + more

**Fix Strategy**:
1. Identify why eval=FALSE was used
2. Fix broken code OR remove chunk if not needed
3. Re-enable with `eval=TRUE`

### Priority 3: Investigate Further

#### 4. README-Vignette Code Block Mismatch (~45 packages)
**Issue**: README has more code blocks than vignettes
**Impact**: Unknown - may be false positive or legitimate issue
**Investigation Needed**:
- Check if code is duplicated in vignettes
- Verify README-vignette matching rule compliance

## Execution Plan

### Phase 1: Parallel Background Tasks (Launch Together)

**Task 1**: Fix Rd line widths - Group 1 (10 packages)
- Packages: ar, ca, fl, ia, id, ks, la, me, nc, ne
- Context: Fix man/*.Rd files with lines > 100 chars
- Output: Fixed Rd files, committed changes

**Task 2**: Fix Rd line widths - Group 2 (10 packages)
- Packages: nh, nj, nv, tx, ut, vt, wa, wi, wy, [one more]
- Context: Fix man/*.Rd files with lines > 100 chars
- Output: Fixed Rd files, committed changes

**Task 3**: Fix Rd line widths - Group 3 (10 packages)
- Packages: [remaining 10]
- Context: Fix man/*.Rd files with lines > 100 chars
- Output: Fixed Rd files, committed changes

**Task 4**: Fix data directory issues
- Packages: akschooldata, ilschooldata
- Context: Move non-R data to inst/extdata, remove empty dirs
- Output: Clean data/ directories, updated .Rbuildignore if needed

**Task 5**: Remove eval=FALSE from vignettes
- Packages: All ~15 with eval=FALSE
- Context: Fix or remove non-evaluable code chunks
- Output: Vignettes with eval=TRUE, committed changes

### Phase 2: Verification

1. Run R CMD check on all fixed packages
2. Verify no new issues introduced
3. Confirm CI would pass

### Phase 3: Documentation

1. Update CI check scripts to catch these issues automatically
2. Add pre-commit hooks if needed
3. Document in CLAUDE.md

## Success Criteria

- [ ] All Rd files have lines ≤ 100 characters
- [ ] No non-R files in data/ directories
- [ ] No empty data/ directories
- [ ] All vignette code chunks use eval=TRUE (or have justified FALSE)
- [ ] R CMD check passes with 0 errors, 0 warnings for all packages
