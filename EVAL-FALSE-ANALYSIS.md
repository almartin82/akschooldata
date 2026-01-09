# eval=FALSE Analysis - Action Plan

## Quick Summary

**What**: 96 code chunks across 15 packages marked with `eval=FALSE`
**Why it matters**: Code doesn't run during CI, broken code goes undetected
**Current status**: Documented, ready for action

---

## Categories & Recommendations

### ✅ Category 1: Installation Instructions (KEEP)

**Pattern**: Package installation commands
**Why eval=FALSE**: Users run these manually, not during vignette build
**Action**: Keep as-is, maybe add explanatory comment

**Packages**:
- arschooldata (line 27): `install` chunk
- rischooldata (line 23): `install` chunk

**Example**:
```markdown
```{r install, eval=FALSE}
# Installation: Users run this manually
devtools::install_github("almartin82/arschooldata")
```
```

**Priority**: LOW - Document and move on

---

### ⚠️ Category 2: Data Fetching (FIX or REMOVE)

**Pattern**: Basic data fetching that should work
**Why eval=FALSE**: Unknown - possibly slow API calls or broken code
**Action**: Test with eval=TRUE, fix or remove

**Packages**:
- akschooldata (line 48): `fetch-data` in quickstart.Rmd
- caschooldata (line 48): `fetch-data` in quickstart.Rmd
- ilschooldata (line 58): `fetch-all-years` in data-quality-qa.Rmd

**Example**:
```markdown
```{r fetch-data, eval=TRUE}
# Should work - if not, fix the code!
enr <- fetch_enr(2024)
```
```

**Priority**: HIGH - These should work, fix or document why not

---

### ⚠️ Category 3: Visualizations & Analysis (FIX or DOCUMENT)

**Pattern**: Complex plotting or analysis code
**Why eval=FALSE**: May be slow, use local data, or broken
**Action**: Test, fix if simple, document reason if keeping FALSE

**Packages**:
- nyschooldata (line 359): `viz-state-trend` in quickstart.Rmd
- txschooldata (line 516): `explore-example` in district-hooks.Rmd
- ohschooldata (line 416): `import-local` in quickstart.Rmd
- okschooldata (line 99): `demographics-chart` in enrollment_hooks.Rmd
- ndschooldata (line 412): `learn-more` in enrollment_hooks.Rmd
- nmschooldata (line 42): `era1-example` in data_availability.Rmd
- hischooldata (line 42): (unnamed) in hischooldata.Rmd
- ctschooldata (line 25): (unnamed) in ctschooldata.Rmd
- orschooldata (line 23): (unnamed) in getting_started.Rmd
- paschooldata (line 30): `load-packages` in district-hooks.Rmd

**Priority**: MEDIUM - Test each, fix what's easy, document the rest

---

## Proposed Action Plan

### Phase 1: Quick Wins (1-2 hours)

1. **Add comments to install chunks** (2 packages)
   ```r
   ```{r install, eval=FALSE}
   # Installation: Run manually to install package
   devtools::install_github("...")
   ```
   ```

2. **Fix simple data fetch chunks** (3 packages)
   - Test with `eval=TRUE`
   - If works: remove eval=FALSE
   - If fails: fix code or add `# eval=FALSE because: ...`

### Phase 2: Moderate Fixes (2-4 hours)

3. **Test visualization chunks** (10 packages)
   - Enable `eval=TRUE`
   - Run R CMD check
   - Fix what breaks
   - Document what can't be fixed

### Phase 3: Documentation (1 hour)

4. **Add explanatory comments** to all remaining eval=FALSE
   - Why is it FALSE?
   - What would it take to make it TRUE?
   - Is it OK to leave it FALSE?

---

## Decision Matrix

| Package | Type | Effort | Impact | Priority |
|---------|------|--------|--------|----------|
| arschooldata | Install | Low | Low | 5 |
| rischooldata | Install | Low | Low | 6 |
| akschooldata | Fetch | Low | High | 2 |
| caschooldata | Fetch | Low | High | 3 |
| ilschooldata | Fetch | Med | High | 1 |
| nyschooldata | Viz | Med | Med | 4 |
| txschooldata | Viz | High | High | 7 |
| Others | Mixed | Varies | Varies | 8+ |

---

## Tools & Approach

### Automated Testing
```r
# For each package with eval=FALSE
# 1. Remove eval=FALSE from chunk
# 2. Run devtools::check()
# 3. If passes: ✓ Fixed
# 4. If fails: ⚠️ Fix code or document reason
```

### Documentation Template
```markdown
```{r chunk-name, eval=FALSE}
# eval=FALSE because: [REASON]
# To fix: [WHAT WOULD BE NEEDED]
# [CODE HERE]
```
```

---

## Questions for You

1. **Priority**: Should I fix eval=FALSE issues or focus on Rd widths first?

2. **Approach**:
   - A) Fix all eval=FALSE systematically (4-6 hours)
   - B) Fix only high-priority packages (ar, ca, il, ny, tx) (2-3 hours)
   - C) Just add documentation comments (1 hour)
   - D) Defer and focus on Rd widths

3. **Standard**: What's your policy on eval=FALSE?
   - Always avoid unless necessary?
   - OK for install/demonstration chunks?
   - Current approach is fine?

4. **CI**: Should eval=FALSE cause CI to fail, or just NOTE?
   - If fail: we need to fix all 96 chunks
   - If note: we can prioritize and document

---

## Current Status

✅ **Completed**: Inventory of all 96 chunks across 15 packages
⏳ **Pending**: Your decision on approach
📋 **Ready**: Action plan and scripts (once you decide)

Let me know which approach you'd like, and I'll implement it!
