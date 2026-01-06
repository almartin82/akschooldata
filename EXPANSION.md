# Alaska School Data Expansion Research

**Last Updated:** 2026-01-03 **Theme Researched:** graduation

## Current Package Status

- **R-CMD-check:** FAILING (must be fixed before implementing new
  features)
- **Python tests:** Passing
- **pkgdown:** Passing
- **Current capabilities:** Enrollment data only (2021-2025)
- **No graduation functions exist**

------------------------------------------------------------------------

## Data Sources Found

### Source 1: Statewide Graduation Rates by Subgroup (PRIMARY)

- **URL Pattern:**
  `https://education.alaska.gov/Stats/HSGraduates/2%20-%20{YEAR}GradRatesSubgroup.xlsx`
- **HTTP Status:** 200 (requires browser User-Agent header)
- **Format:** Excel (.xlsx)
- **Years Available:** 2020, 2021, 2022, 2023, 2024 (5 years verified)
- **Access Method:** Direct download with User-Agent header
- **Update Frequency:** Annual (typically released following school year
  end)

| Year | HTTP Status | File Size    | Valid Excel         |
|------|-------------|--------------|---------------------|
| 2024 | 200         | 16,252 bytes | Yes                 |
| 2023 | 200         | 16,219 bytes | Yes                 |
| 2022 | 200         | 16,295 bytes | Yes                 |
| 2021 | 200         | 16,920 bytes | Yes                 |
| 2020 | 200         | 16,983 bytes | Yes                 |
| 2019 | 404         | \-           | No (file not found) |
| 2018 | 404         | \-           | No (file not found) |

**Note:** Years 2019 and earlier return 404 errors. Historical data may
exist in different format (PDF) at `/stats/GradRatesSub/` but not in
machine-readable form.

### Source 2: Report Card System (COMPASS)

- **URL:** `https://education.alaska.gov/compass/Report/{YEAR}`
- **HTTP Status:** 403 (blocks programmatic access)
- **Format:** Web dashboard with “Download Excel” option
- **Access Method:** Browser-only (WAF blocks automated requests)
- **Notes:** May contain district/school level graduation data but
  cannot be accessed programmatically

### Source 3: Alaska GIS Data Portal

- **URL:**
  `https://gis.data.alaska.gov/datasets/DCCED::high-school-graduation-rate-four-year/about`
- **HTTP Status:** 403 (API access forbidden)
- **Format:** ArcGIS Feature Service
- **Notes:** Contains school-level graduation rates but API access is
  restricted

### Source 4: Graduation Rate Interpretation Guides (PDF)

- **URL Pattern:**
  `https://education.alaska.gov/reportcard/{YEAR}/GraduationRates-Report-Card-Interpretation-Guide.pdf`
- **Format:** PDF (not machine-readable)
- **Notes:** Contains year-over-year analysis and methodology
  explanations

------------------------------------------------------------------------

## Data NOT Available for Programmatic Access

| Data Type                       | Status    | Notes                                                        |
|---------------------------------|-----------|--------------------------------------------------------------|
| District-level graduation rates | NOT FOUND | No Excel files at expected URLs; may be in COMPASS (blocked) |
| School-level graduation rates   | NOT FOUND | Only in COMPASS dashboard (blocked)                          |
| Years prior to 2020             | NOT FOUND | Files return 404; may exist as PDF only                      |
| Dropout rates by district       | NOT FOUND | Referenced in search results but URLs not working            |

------------------------------------------------------------------------

## Schema Analysis

### File Structure

- **Sheet 1:** Graduation data (contains both 4-year and 5-year cohort
  tables)
- **Sheet 2:** Footnotes (methodology notes)

### Header Rows

- Row 1: Title (e.g., “2023-2024 Graduation Rates by Subgroup”)
- Row 2: Description text
- Row 3: Table 1 header
- Row 4: Column headers
- Rows 5-21: 4-year cohort data
- Row 22: Table separator (“end of table 1 of 2”)
- Row 23: Table 2 header
- Row 24: Column headers (repeated)
- Rows 25-41: 5-year cohort data
- Row 42: Table separator

### Column Names (Consistent 2020-2024)

| Column                       | Description                                                                    |
|------------------------------|--------------------------------------------------------------------------------|
| Category                     | Subgroup name (Statewide, Male, Female, race/ethnicity, program participation) |
| Graduates in {N} Year Cohort | Count of graduates                                                             |
| Members in {N} Year Cohort   | Total students in cohort                                                       |
| Cohort Graduation Rate %     | Rate as percentage (0-100)                                                     |

### Available Subgroups

1.  **Total:** Statewide
2.  **Gender:** Male, Female
3.  **Race/Ethnicity:**
    - African American
    - Alaska Native
    - American Indian
    - Alaska Native & American Indian (combined)
    - Asian/Pacific Islander
    - Caucasian
    - Hispanic
    - Two or More Races
4.  **Program Participation:**
    - Students with Disability
    - Students without Disability
    - English Learners
    - Economically Disadvantaged
    - Active Duty Parent
    - Homeless

### Schema Changes Noted

- **2020-2024:** Consistent schema, no changes detected
- Column names are identical across all available years
- File structure (two tables) is consistent

### Known Data Issues

1.  **Floating point representation:** Rates stored as decimal strings
    with extended precision (e.g., “76.349999999999994”)
2.  **Combined ethnicity row:** “Alaska Native & American Indian” is a
    rollup row (not double-counting)
3.  **Multi-row headers:** Requires skipping 3 rows when parsing
4.  **Two tables in one sheet:** 4-year and 5-year cohorts in same
    sheet, separated by text row

------------------------------------------------------------------------

## Time Series Heuristics

### Expected Ranges (based on 2020-2024 data)

| Metric                | Min   | Max   | Notes                          |
|-----------------------|-------|-------|--------------------------------|
| Statewide 4-year rate | 77%   | 80%   | Stable around 78%              |
| Statewide 5-year rate | 82%   | 85%   | ~4-5 points higher than 4-year |
| Total cohort size     | 9,400 | 9,800 | Relatively stable              |
| Graduate count        | 7,400 | 7,700 | Relatively stable              |

### Year-over-Year Validation Rules

``` r
# 4-year graduation rate should be 70-85%
expect_gte(rate_4yr, 70)
expect_lte(rate_4yr, 85)

# 5-year rate should exceed 4-year rate
expect_gt(rate_5yr, rate_4yr)

# YoY change should be < 5 percentage points
expect_lt(abs(rate_current - rate_previous), 5)

# Cohort size should be 8,000-11,000
expect_gte(cohort_size, 8000)
expect_lte(cohort_size, 11000)
```

### Reference Values for Fidelity Tests

| Year | 4-Year Rate | 5-Year Rate | 4-Year Cohort Size | 4-Year Graduates |
|------|-------------|-------------|--------------------|------------------|
| 2024 | 78.31%      | 82.88%      | 9,728              | 7,618            |
| 2023 | 77.91%      | 82.84%      | 9,630              | 7,503            |
| 2022 | 78.02%      | 82.82%      | 9,633              | 7,515            |
| 2021 | 78.74%      | 82.28%      | 9,348              | 7,361            |
| 2020 | 79.04%      | 82.58%      | 9,410              | 7,438            |

------------------------------------------------------------------------

## Access Requirements

### HTTP Headers Required

``` r
httr::GET(
  url,
  httr::add_headers(
    `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  )
)
```

### Without User-Agent

- Some requests return HTML error pages instead of Excel files
- HTTP status may show 200 but content is blocked

------------------------------------------------------------------------

## Recommended Implementation

### Priority: MEDIUM

- Valuable graduation data for statewide subgroup analysis
- Limited to statewide aggregates only (no district/school breakdowns)

### Complexity: EASY

- Consistent schema across all years
- Direct URL pattern
- Simple parsing (skip 3 rows, read table)

### Estimated Files to Create/Modify

1.  `R/fetch_graduation.R` - Main fetch function (NEW)
2.  `R/get_raw_graduation.R` - Raw data download (NEW)
3.  `R/process_graduation.R` - Data processing (NEW)
4.  `R/tidy_graduation.R` - Tidy transformation (NEW)
5.  `R/utils.R` - Update
    [`get_available_years()`](https://almartin82.github.io/akschooldata/reference/get_available_years.md)
    (MODIFY)
6.  `tests/testthat/test-graduation.R` - Tests (NEW)
7.  `tests/testthat/test-graduation-pipeline-live.R` - Live pipeline
    tests (NEW)

### Implementation Steps

1.  **Create `get_raw_grad()` function:**
    - Download Excel file from URL pattern
    - Handle User-Agent header requirement
    - Parse both 4-year and 5-year tables
    - Return list with `four_year` and `five_year` data frames
2.  **Create `process_grad()` function:**
    - Standardize column names
    - Handle floating-point precision issues in rates
    - Add `cohort_type` column (4-year vs 5-year)
    - Add `end_year` column
3.  **Create `tidy_grad()` function:**
    - Pivot subgroups into rows
    - Map category names to standardized subgroup names
    - Calculate percentage from counts for verification
4.  **Create `fetch_grad()` function:**
    - Main entry point
    - Support `end_year`, `tidy`, `use_cache` parameters
    - Support `cohort_type` parameter (“4-year”, “5-year”, “both”)

------------------------------------------------------------------------

## Test Requirements

### Raw Data Fidelity Tests Needed

``` r
test_that("2024: Statewide 4-year rate matches raw value", {
  data <- fetch_grad(2024, cohort_type = "4-year")
  statewide <- data |> filter(category == "Statewide")
  expect_equal(statewide$graduation_rate, 78.31, tolerance = 0.01)
  expect_equal(statewide$graduates, 7618)
  expect_equal(statewide$cohort_size, 9728)
})

test_that("2020: Statewide 5-year rate matches raw value", {
  data <- fetch_grad(2020, cohort_type = "5-year")
  statewide <- data |> filter(category == "Statewide")
  expect_equal(statewide$graduation_rate, 82.58, tolerance = 0.01)
})

test_that("2023: Alaska Native 4-year rate matches raw value", {
  data <- fetch_grad(2023, cohort_type = "4-year")
  native <- data |> filter(category == "Alaska Native")
  expect_equal(native$graduation_rate, 66.28, tolerance = 0.01)
})
```

### Data Quality Checks

``` r
test_that("Graduation rates are in valid range", {
  data <- fetch_grad(2024)
  expect_true(all(data$graduation_rate >= 0 & data$graduation_rate <= 100))
})

test_that("Graduates do not exceed cohort size", {
  data <- fetch_grad(2024)
  expect_true(all(data$graduates <= data$cohort_size))
})

test_that("5-year rate exceeds 4-year rate", {
  four_yr <- fetch_grad(2024, cohort_type = "4-year") |>
    filter(category == "Statewide")
  five_yr <- fetch_grad(2024, cohort_type = "5-year") |>
    filter(category == "Statewide")
  expect_gt(five_yr$graduation_rate, four_yr$graduation_rate)
})
```

### Live Pipeline Tests

1.  URL availability (HTTP 200)
2.  File download (valid Excel, not HTML)
3.  File parsing (readxl succeeds)
4.  Column structure (expected columns present)
5.  Year filtering (each year returns data)
6.  Data quality (no Inf/NaN, valid percentages)
7.  Aggregation (graduates \<= cohort)
8.  Output fidelity (tidy matches raw)

------------------------------------------------------------------------

## Limitations

1.  **Statewide only:** No district or school-level graduation data
    available via programmatic access
2.  **Limited year range:** Only 2020-2024 available (5 years)
3.  **No historical data:** Pre-2020 data appears to be PDF-only
4.  **Access restrictions:** COMPASS dashboard and GIS portal block
    automated access
5.  **No dropout data:** Dropout rate files not found at expected URLs

------------------------------------------------------------------------

## Future Enhancement Opportunities

1.  **Browser automation:** Use Selenium/RSelenium to access COMPASS
    dashboard for district/school data
2.  **Historical PDF parsing:** Extract data from pre-2020 PDF reports
    using tabulizer or pdftools
3.  **Contact DEED:** Request bulk data export or API access from data
    management team
4.  **GIS integration:** Investigate authentication options for Alaska
    GIS portal

------------------------------------------------------------------------

## Contacts for Data Questions

- John Jones: <john.jones2@alaska.gov>
- Nancy Eagan (Data Manager): <nancy.eagan@alaska.gov>
- General: <eed.contact@alaska.gov>
- Phone: 907-465-2800
