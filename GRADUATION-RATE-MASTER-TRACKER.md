# Graduation Rate Master Implementation Tracker

**Last Updated:** 2026-01-09
**Overall Progress:** 19/51 states complete (37%)
**Remaining States:** 32 states

---

## Quick Reference: Implementation Status

| State | Status | Tests | Vignette | README Updated | Priority |
|-------|--------|-------|----------|----------------|----------|
| **COMPLETED (19 states)** | | | | | |
| AZ | ✅ Complete | - | ❌ | ❌ | Low |
| CA | ✅ Complete | - | ❌ | ❌ | Low |
| CO | ✅ Complete | - | ❌ | ❌ | Low |
| FL | ✅ Complete | - | ❌ | ❌ | Low |
| GA | ✅ Complete | - | ❌ | ❌ | Low |
| IL | ✅ Complete | - | ✅ | ✅ | Done |
| MA | ✅ Complete | - | ❌ | ❌ | Low |
| MD | ✅ Complete | - | ❌ | ❌ | Low |
| MI | ✅ Complete | - | ❌ | ❌ | Low |
| NC | ✅ Complete | - | ❌ | ❌ | Low |
| ND | ✅ Complete | 166 | ❌ | ✅ | Done |
| NJ | ✅ Complete | - | ✅ | ❌ | Medium |
| NY | ✅ Complete | - | ❌ | ❌ | Low |
| OR | ✅ Complete | 100+ | ❌ | ❌ | Low |
| PA | ✅ Complete | - | ❌ | ❌ | Low |
| TX | ✅ Complete | - | ❌ | ❌ | Low |
| VA | ✅ Complete | 104 | ❌ | ❌ | Low |
| WA | ✅ Complete | - | ❌ | ❌ | Low |
| WI | ✅ Complete | - | ❌ | ❌ | Low |
| **NEED IMPLEMENTATION (32)** | | | | | |
| AK | ❌ None | - | - | - | Medium |
| AL | ❌ None | - | - | - | Low |
| AR | ❌ None | - | - | - | Low |
| CT | ❌ None | - | - | - | Low |
| DE | ❌ None | - | - | - | Low |
| HI | ❌ None | - | - | - | Low |
| IA | ❌ None | - | - | - | Low |
| ID | ❌ None | - | - | - | Low |
| IN | ❌ None | - | - | - | Low |
| KS | ❌ None | - | - | - | Low |
| KY | ❌ None | - | - | - | Low |
| LA | ❌ None | - | - | - | Low |
| ME | ❌ None | - | ✅ | ❌ | Medium |
| MN | ❌ None | - | - | - | Low |
| MO | ❌ None | - | - | - | Low |
| MS | ⚠️  Tier 4 (Skip) | - | - | - | N/A |
| MT | ❌ None | - | - | - | Low |
| NE | ❌ None | - | - | - | Low |
| NH | ❌ None | - | - | - | Low |
| NM | ❌ None | - | - | - | Low |
| NV | ❌ None | - | - | - | Low |
| OH | ❌ None | - | - | - | Low |
| OK | ❌ None | - | - | - | Low |
| RI | ❌ None | - | - | - | Low |
| SC | ❌ None | - | - | - | Low |
| SD | ❌ None | - | - | - | Low |
| TN | ❌ None | - | - | - | Low |
| UT | ❌ None | - | - | - | Low |
| VT | ❌ None | - | ✅ | ❌ | Medium |
| WV | ❌ None | - | - | - | Low |
| WY | ❌ None | - | - | - | Low |

---

## Implementation Checklist Template (Per State)

For each state needing implementation, follow this 4-stage process:

### Stage 1: Research (Data Source Discovery)
- [ ] Locate state DOE graduation rate data
- [ ] Verify URL accessibility (HTTP 200)
- [ ] Download sample files (3+ years)
- [ ] Document schema and any era changes
- [ ] Identify suppression markers and data quirks
- [ ] Create research report in `{state}schooldata/docs/`

**Estimated Time:** 1-2 hours per state

### Stage 2: TDD (Test-Driven Development)
- [ ] Write LIVE pipeline tests (8 categories):
  - [ ] URL availability
  - [ ] File download verification
  - [ ] File parsing (readxl/readr)
  - [ ] Column structure validation
  - [ ] Year filtering
  - [ ] Aggregation logic
  - [ ] Data quality checks
  - [ ] Output fidelity
- [ ] Write fidelity tests (100+ tests):
  - [ ] State totals (3+ years)
  - [ ] School-level spot checks
  - [ ] Subgroup breakdowns
  - [ ] Data quality validation
- [ ] Verify tests FAIL (no implementation yet)

**Estimated Time:** 2-3 hours per state

### Stage 3: Implementation
- [ ] Create `R/get_raw_graduation.R` - Download function
- [ ] Create `R/process_graduation.R` - Schema standardization
- [ ] Create `R/tidy_graduation.R` - Long format transformation
- [ ] Create `R/fetch_graduation.R` - User-facing functions
- [ ] Update `NAMESPACE` with exports
- [ ] Update `DESCRIPTION` if dependencies needed
- [ ] Run tests until all PASS

**Estimated Time:** 2-3 hours per state

### Stage 4: Documentation
- [ ] Update README.md with graduation rate section
- [ ] Add usage examples (with code output)
- [ ] Create vignette (if package has vignettes)
- [ ] Ensure README-vignette code matching (CRITICAL)
- [ ] Run `devtools::check()` - 0 errors, 0 warnings
- [ ] Run `pkgdown::build_site()` - verify documentation

**Estimated Time:** 1-2 hours per state

**Total Time Per State:** 6-10 hours

---

## Standard Output Schema (14 Columns)

All implementations MUST use this exact schema:

| Column | Type | Description |
|--------|------|-------------|
| `end_year` | integer | School year end (2023-24 = 2024) |
| `type` | character | "State", "District", or "School" |
| `district_id` | character | District ID (preserve leading zeros) |
| `district_name` | character | District name |
| `school_id` | character | School ID (preserve leading zeros) |
| `school_name` | character | School name |
| `subgroup` | character | Standardized subgroup name |
| `metric` | character | "4_year" or "5_year" |
| `grad_rate` | numeric | Graduation rate (0-1 scale, decimals) |
| `cohort_count` | integer | Number of students in cohort |
| `graduate_count` | integer | Number of graduates |
| `is_state` | logical | TRUE for state-level rows |
| `is_district` | logical | TRUE for district-level rows |
| `is_school` | logical | TRUE for school-level rows |

### Standardized Subgroup Names

Map state-specific names to these standard names:
- **All:** `all`
- **Gender:** `male`, `female`
- **Race/ethnicity:** `native_american`, `asian`, `black`, `hispanic`, `white`, `pacific_islander`, `multiracial`
- **Special populations:** `english_learner`, `special_ed`, `low_income`, `homeless`, `migrant`, `foster_care`, `military`

---

## Data Source Categories by Access Method

### Tier 1: Direct HTTP Downloads (Easiest)
**Examples:** TX, FL, VA, OR, WI, ND
- Direct file downloads (Excel/CSV)
- Stable URLs
- No authentication
- **Implementation time:** 2-3 hours

**Reference implementations:**
- ND: `/Users/almartin/Documents/state-schooldata/ndschooldata/`
- VA: `/Users/almartin/Documents/state-schooldata/vaschooldata/`
- OR: `/Users/almartin/Documents/state-schooldata/orschooldata/`

### Tier 2: API-Based Access (Medium)
**Examples:** MA, NY, GA (CKAN)
- JSON API with consistent schema
- Query parameters
- Often 15+ years of historical data
- **Implementation time:** 3-4 hours

**Reference implementations:**
- MA: `/Users/almartin/Documents/state-schooldata/maschooldata/`
- NY: `/Users/almartin/Documents/state-schooldata/nyschooldata/`

### Tier 3: Special Cases (Challenging)
**Examples:** AZ (Cloudflare blocking)
- Requires workarounds
- May need bundled files
- Alternative state sources
- **Implementation time:** 4-6 hours

**Reference implementation:**
- AZ: `/Users/almartin/Documents/state-schooldata/azschooldata/docs/GRADUATION-IMPLEMENTATION-SUMMARY.md`

---

## Vignette Requirements (CRITICAL)

### Why Vignettes Matter

As of 2026-01-08, ALL code blocks in the README MUST match code in a vignette EXACTLY (1:1 correspondence). This prevents bugs like:
- Wrong district/entity names (case sensitivity, typos)
- Text claims that contradict actual data
- Broken code that fails silently
- Missing data output in examples

### README Story Structure (REQUIRED)

Every section in the README MUST follow this structure:

1. **Claim**: Factual statement about the data
2. **Explication**: Brief explanation of why this matters
3. **Code**: R code that fetches and analyzes the data (MUST exist in a vignette)
4. **Code Output**: Data table/print statement showing actual values (REQUIRED)
5. **Visualization**: Chart from vignette (auto-generated from pkgdown)

### Example

```markdown
### 1. State graduation rate increased 5% since 2010

State graduation rates have steadily improved from 82% in 2010 to 87% in 2024.

```r
library(xxschooldata)
library(dplyr)

grad <- fetch_graduation_multi(2010:2024)

grad %>%
  filter(is_state, subgroup == "all", metric == "4_year") %>%
  select(end_year, grad_rate, cohort_count) %>%
  filter(end_year %in% c(2010, 2024)) %>%
  mutate(rate_pct = round(grad_rate * 100, 1),
         change = rate_pct - lag(rate_pct))
# Prints: 2010=82.0%, 2024=87.0%, change=+5.0%
```

![Graduation rate trend](https://almartin82.github.io/xxschooldata/articles/graduation-trends_files/figure-html/grad-trend-1.png)
```

### Vignette Template

Create `vignettes/graduation-trends.Rmd`:

```markdown
---
title: "Graduation Rate Trends"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{graduation-trends}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include=FALSE}
library(xxschooldata)
library(dplyr)
library(ggplot2)
knitr::opts_chunk$set(fig.width = 7, fig.height = 4)
```

## State Graduation Rates Over Time

### Recent Trends

State graduation rates have [trend description].

```{r state-trend}
grad <- fetch_graduation_multi(2015:2024)

state_trend <- grad %>%
  filter(is_state, subgroup == "all", metric == "4_year") %>%
  select(end_year, grad_rate, cohort_count) %>%
  arrange(end_year)

state_trend %>%
  mutate(rate_pct = round(grad_rate * 100, 1)) %>%
  head(5)
```

### Visualization

```{r grad-trend, echo=FALSE}
ggplot(state_trend, aes(x = end_year, y = grad_rate * 100)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(title = "State 4-Year Graduation Rates (2015-2024)",
       x = "Year",
       y = "Graduation Rate (%)") +
  scale_y_continuous(limits = c(70, 100)) +
  theme_minimal()
```
```

---

## Testing Framework

### LIVE Pipeline Tests (8 Categories)

All states must include `tests/testthat/test-graduation-live.R`:

```r
# LIVE Pipeline Tests for [State] Graduation Rate Data
# Test Categories:
# 1. URL Availability - HTTP 200 checks
# 2. File Download - Verify actual file (not HTML error)
# 3. File Parsing - readxl/readr succeeds
# 4. Column Structure - Expected columns exist
# 5. get_raw_graduation() - Raw data function works
# 6. Data Quality - No Inf/NaN, valid ranges
# 7. Aggregation - State total is reasonable
# 8. Output Fidelity - tidy=TRUE matches raw

skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) skip("No network connectivity")
  }, error = function(e) skip("No network connectivity"))
}

test_that("Graduation URLs return HTTP 200", {
  skip_if_offline()

  urls <- list(
    "2024" = build_grad_url(2024),
    "2020" = build_grad_url(2020),
    "2015" = build_grad_url(2015)
  )

  for (year in names(urls)) {
    response <- httr::HEAD(urls[[year]], httr::timeout(10))
    expect_false(httr::http_error(response),
                info = paste(year, "URL should return HTTP 200"))
  }
})

# ... 7 more test categories
```

### Fidelity Tests (100+ Tests)

All states must include `tests/testthat/test-graduation-fidelity.R`:

```r
# Raw Data Fidelity Tests for [State] Graduation Rate Data
# All values verified against actual source files on [DATE]

test_that("2024 state total matches raw data", {
  grad <- fetch_graduation(2024)

  state_total <- grad %>%
    filter(is_state, subgroup == "all", metric == "4_year")

  expect_equal(state_total$grad_rate, 0.XXX,
               tolerance = 0.0001,
               info = "State grad rate should match raw data")

  expect_equal(state_total$cohort_count, XXXXX,
               tolerance = 1,
               info = "State cohort count should match raw data")

  expect_equal(state_total$graduate_count, XXXX,
               tolerance = 1,
               info = "State graduate count should match raw data")
})

# ... 100+ more tests
```

---

## Reference Implementations by Tier

### Tier 1: Direct Downloads (Best Examples)

**North Dakota (ndschooldata)** - Simple CSV download
- Path: `/Users/almartin/Documents/state-schooldata/ndschooldata/`
- Docs: `GRADUATION_IMPLEMENTATION_SUMMARY.md`
- Tests: 166 tests total (138 fidelity + 28 LIVE)
- Years: 2013-2024 (12 years)
- Schema: Consistent, no era detection needed
- Key feature: HTML meta tag handling

**Virginia (vaschooldata)** - CKAN API
- Path: `/Users/almartin/Documents/state-schooldata/vaschooldata/`
- Docs: `GRADUATION-TEST-SUMMARY.md`
- Tests: 104 tests (25 LIVE + 79 fidelity)
- Years: 2019-2023 (5 years)
- Schema: v1 (2019-2022) vs v2 (2023+)
- Key feature: Era detection with Level column

**Oregon (orschooldata)** - Excel with eras
- Path: `/Users/almartin/Documents/state-schooldata/orschooldata/`
- Docs: `GRADUATION-IMPLEMENTATION-REPORT.md`
- Tests: 100+ tests
- Years: 2015-2024 (10 years, Era 2+3)
- Schema: 3 eras (2009-2014 not implemented)
- Key feature: Embedded `\r\n` in column names

### Tier 2: API Access

**Massachusetts (maschooldata)** - Socrata API
- Path: `/Users/almartin/Documents/state-schooldata/maschooldata/`
- Docs: `CLAUDE.md` (Graduation Rate Data section)
- Years: 2006-2024 (19 years - longest history)
- Schema: Consistent across all years
- Key feature: JSON API with SoQL queries

### Tier 3: Special Cases

**Arizona (azschooldata)** - Bundled files
- Path: `/Users/almartin/Documents/state-schooldata/azschooldata/`
- Docs: `docs/GRADUATION-IMPLEMENTATION-SUMMARY.md`
- Years: 2018-2024
- Schema: Standard (from bundled Excel)
- Key feature: Cloudflare blocking workaround

---

## Known Data Source Patterns

### Percentage Parsing
Most states use one of these formats:
- `"   83.71%"` (leading spaces + % suffix) → VA, OR
- `"83.71%"` (% suffix) → Common
- `"0.884"` (already decimal) → MA, ND
- `"88.4"` (percentage as number) → Some states

**Solution:** Detect format and parse accordingly

### Suppression Markers
| Marker | Meaning | States |
|--------|---------|--------|
| `*` | Small count (< 10) | AZ, ND, OR |
| `<` | Suppressed rate | VA |
| `**` | Double suppression | Some states |
| `.` or `.00%` | Real zero, NOT suppression | VA, OR |

### ID Preservation
**CRITICAL:** Always store IDs as character to preserve leading zeros
- District IDs: Often 5-8 digits
- School IDs: Often 8-10 digits
- State IDs: Fixed values (e.g., "99999", "00000000")

---

## README Update Template

Add this section to each package's README.md:

```markdown
## Graduation Rate Data

### Availability

Graduation rate data is available for [YEARS].

### Years Available

| Year | 4-Year Rate | 5-Year Rate | Notes |
|------|-------------|-------------|-------|
| [YEAR] | ✅ | ✅ | [Notes] |

### Usage

```r
library(xxschooldata)

# Get single year
grad_2024 <- fetch_graduation(2024)

# Get multiple years
grad_multi <- fetch_graduation_multi(2020:2024)

# State total
state_total <- grad_2024 %>%
  filter(is_state, subgroup == "all") %>%
  select(grad_rate, cohort_count, graduate_count)

# District comparison
districts <- grad_2024 %>%
  filter(is_district, subgroup == "all") %>%
  arrange(desc(grad_rate)) %>%
  select(district_name, grad_rate, cohort_count)
```

### Data Source

[STATE] Department of Education
- URL: [URL]
- File format: [CSV/Excel/API]
- Access method: [Direct download/API]

### Subgroups Available

[List available subgroups]

### Notes

[Any special notes about suppression, era changes, etc.]
```

---

## Quality Gates (Before PR)

Each state implementation must pass these checks:

### Code Quality
- [ ] `devtools::check()` returns 0 errors, 0 warnings
- [ ] All graduation tests pass (100+ fidelity + 8 LIVE)
- [ ] No test skips except `skip_if_offline()`

### Data Quality
- [ ] No Inf values in grad_rate
- [ ] No NaN values in grad_rate
- [ ] All grad_rate values in [0, 1]
- [ ] Cohort counts >= graduate counts
- [ ] State totals reasonable (verify with raw data)

### Documentation
- [ ] README.md updated with graduation section
- [ ] All README code blocks exist in vignettes (1:1 match)
- [ ] Vignette renders without errors
- [ ] `pkgdown::build_site()` succeeds
- [ ] All functions have roxygen2 documentation

### Git Workflow
- [ ] Feature branch created (not main)
- [ ] Commit messages normal (no AI attribution)
- [ ] PR created with description
- [ ] Auto-merge enabled
- [ ] CI checks passing (R-CMD-check, pkgdown)

---

## Priority Rankings for Remaining States

### High Priority (Large States, Data Likely Available)
1. **OH** (Ohio) - Large population, likely has good data
2. **MI** (Michigan) - Already has enrollment, check for grad rates
3. **GA** (Georgia) - Already complete, verify
4. **NC** (North Carolina) - Already complete, verify
5. **NJ** (New Jersey) - Already complete, needs vignette

### Medium Priority (Medium States, Some Implementation Started)
6. **KY** (Kentucky) - Has enrollment, check grad rate source
7. **OK** (Oklahoma) - Has enrollment, check grad rate source
8. **SC** (South Carolina) - Has enrollment, check grad rate source
9. **TN** (Tennessee) - Has enrollment, check grad rate source
10. **UT** (Utah) - Has enrollment, check grad rate source

### Low Priority (Smaller States, Research Needed)
11-32. Remaining smaller states (AL, AR, CT, DE, HI, IA, ID, IN, KS, LA, ME, MN, MO, MS, MT, NE, NH, NM, NV, RI, SD, VT, WV, WY)

---

## Automation Strategy

### Batch Processing (5 Parallel Agents)

Use the Task tool to launch 5 parallel background agents:

```r
# Example: Research phase for 5 states
states_to_research <- c("AK", "AL", "AR", "CT", "DE")

for (state in states_to_research) {
  Task(
    subagent_type = "general-purpose",
    description = paste("Research", state, "graduation data"),
    prompt = paste0(
      "Research graduation rate data source for ", state, ".\n",
      "1. Locate state DOE graduation rate data\n",
      "2. Verify URL accessibility (HTTP 200)\n",
      "3. Download sample files (3+ years)\n",
      "4. Document schema and era changes\n",
      "5. Identify suppression markers\n",
      "6. Create research report\n\n",
      "Return: Data source details, URLs, years available, schema info, "
      "estimated implementation tier (1/2/3), and any blocking issues."
    )
  )
}
```

### Progress Tracking

After each batch completes:
1. Update master tracker with findings
2. Assign implementation tier
3. Prioritize next batch
4. Launch next 5 agents

---

## Success Metrics

### Completion Criteria
- [ ] All 51 states have graduation rate functions
- [ ] All states have 100+ tests passing
- [ ] All states have README updates
- [ ] All states have vignettes (or explicit decision not to)
- [ ] All README-vignette code verified matching

### Timeline Estimate
- **Research phase:** 32 states × 1-2 hours = 32-64 hours (parallelizable with 5 agents)
- **Implementation phase:** 32 states × 4-6 hours = 128-192 hours (parallelizable)
- **Documentation phase:** 32 states × 1-2 hours = 32-64 hours (parallelizable)

**Total:** ~200-300 hours of work (can be done in parallel across multiple developers/agents)

---

## Contact and Support

### Questions?
- GitHub Issues: https://github.com/almartin82/state-schooldata/issues
- Reference Implementations: See individual package directories
- Documentation: See `CLAUDE.md` in each package

### Key Documentation Files
- This tracker: `GRADUATION-RATE-MASTER-TRACKER.md`
- Main project docs: `/Users/almartin/Documents/state-schooldata/CLAUDE.md`
- Implementation examples: See completed states above

---

**Last Updated:** 2026-01-09
**Next Update:** After each batch of 5 states completes
