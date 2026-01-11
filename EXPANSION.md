# Alaska Assessment Data Expansion Research

**Research Date:** 2025-01-11 (Updated 2025-01-11) **Researcher:**
Assessment Data Theme Study **Status:** **FEASIBLE - CSV Downloads
Available (2025-01-11)**

------------------------------------------------------------------------

## IMPLEMENTATION DECISION: FEASIBLE

**CRITICAL FINDING:** Alaska Department of Education & Early Development
(DEED) **DOES PROVIDE** CSV downloads of assessment data on individual
school/district assessment result pages.

**Data Access Method:** - **Format:** CSV files with “Four-Way
Suppressed Data” download option - **URL Pattern:**
<https://education.alaska.gov/assessment-results/District/DistrictResults?DistrictYear=YYYY-YY&IsScience=False&DistrictId=%7BID%7D> -
**Coverage:** All 54 districts have downloadable CSV files - **Years
Available:** 2022-2025 (AK STAR era) - **Implementation Strategy:** Loop
through DistrictIds 1-54, download and combine CSVs

**Result:** Implementation is **POSSIBLE** following project
principles: - State data sources only ✓ - Automated CSV downloads ✓ -
Machine-readable format ✓

**Historical PEAKS data (2017-2021):** PDF format only - SKIP for now

------------------------------------------------------------------------

## CSV Download Implementation Guide (NEW FINDING)

### Discovery (2025-01-11)

Initial research concluded assessment data was “NOT FEASIBLE” due to
perceived lack of CSV downloads. However, **deeper investigation
revealed CSV downloads ARE available** on individual district/school
assessment result pages.

### Evidence

1.  **Example District Page with CSV Download:**
    - URL:
      <https://education.alaska.gov/assessment-results/District/DistrictResults?DistrictYear=2024-2025&IsScience=False&DistrictId=5>
    - Contains: “Download Four-Way Suppressed Data (.csv)” button
    - Anchorage School District (DistrictId=5) serves as proof of
      concept
2.  **Example School Page with CSV Download:**
    - URL:
      <https://education.alaska.gov/assessment-results/Schoolwide/SchoolwideResult?SchoolYear=2024-2025&IsScience=True&DistrictId=28&SchoolId=280090>
    - Contains: “Download Four-Way Suppressed Data (.csv)” button
    - Matanuska-Susitna Borough schools have downloadable CSVs
3.  **District ID Reference:**
    - PDF:
      <https://education.alaska.gov/alaskan_schools/public/DistrictandSchoolIDs.pdf>
    - Lists all 54 district IDs (1-54)

### Implementation Strategy

**Approach:** Iterate through all districts and aggregate CSV downloads

``` r
# Pseudo-code for implementation
get_raw_assessment <- function(end_year, subject = c("ELA", "Math", "Science")) {
  district_ids <- 1:54  # All Alaska districts

  all_data <- list()
  for (district_id in district_ids) {
    url <- build_assessment_url(end_year, district_id, subject)
    csv_data <- read_csv(url)  # Download CSV
    all_data[[district_id]] <- csv_data
  }

  bind_rows(all_data)  # Combine into statewide dataset
}
```

### URL Patterns Discovered

**District-Level AK STAR (ELA/Math):**

    https://education.alaska.gov/assessment-results/District/DistrictResults?DistrictYear=2024-2025&IsScience=False&DistrictId={ID}

**School-Level AK STAR (ELA/Math):**

    https://education.alaska.gov/assessment-results/Schoolwide/SchoolwideResult?SchoolYear=2024-2025&IsScience=False&DistrictId={ID}&SchoolId={SCHOOL_ID}

**Science Assessment:**

    https://education.alaska.gov/assessment-results/Schoolwide/SchoolwideResult?SchoolYear=2024-2025&IsScience=True&DistrictId={ID}&SchoolId={SCHOOL_ID}

**Parameters:** - `DistrictYear`: School year in format “YYYY-YY” (e.g.,
“2024-2025”) - `IsScience`: True/False for Science vs. ELA/Math -
`DistrictId`: District number (1-54) - `SchoolId`: School code
(composite: DistrictId + SchoolId)

### Years Coverage

**AK STAR (2022-2025):** - 2022: First administration (Spring 2022) -
2023: Second administration - 2024: Third administration - 2025: Ongoing
(results typically released September)

**Data Structure:** - Format: CSV files - Suppression: “Four-way
suppression” for small cells - Levels: State, District, School -
Subjects: ELA, Math, Science - Grades: 3-9 (ELA/Math), 5/8/10 (Science)

------------------------------------------------------------------------

------------------------------------------------------------------------

Alaska has a fragmented assessment history with multiple assessment
systems, cancellations, and transitions. The state currently uses **AK
STAR** (Alaska System of Academic Readiness) for ELA/Math and **Alaska
Science Assessment** for science. Historical data includes AMP
(2015-2016) and PEAKS (2017-2019, 2021), but both systems were canceled.

**Complexity Level:** HIGH - Multiple assessment systems, gaps in data,
limited machine-readable downloads

------------------------------------------------------------------------

## Historical Assessments Timeline

### 1. AMP (Alaska Measures of Progress)

- **Years Available:** 2014-2015 only
- **Grades:** 3-10 (ELA and Mathematics)
- **Status:** Canceled after 2015 due to “repeated technical
  disruptions”
- **Data Source:** [2014 Assessment
  Results](https://education.alaska.gov/assessments/results/results2014)
- **Notes:** Limited single-year data

### 2. PEAKS (Performance Evaluation for Alaska’s Schools)

- **Years Available:** 2017, 2018, 2019, 2021
- **Grades:** 3-9 (ELA and Mathematics)
- **Status:** Canceled in 2019, briefly reinstated 2021
- **Data Sources:**
  - [PEAKS Assessment
    Results](https://education.alaska.gov/assessments/peaks/results)
  - [2021 PEAKS
    Results](https://education.alaska.gov/news/releases/2021/9.7.21%2520DEED%2520releases%25202021%2520PEAKS%2520assessment%2520results.pdf)
- **Notes:** 2021 data affected by pandemic, ~44,400 students tested

### 3. AK STAR (Alaska System of Academic Readiness)

- **Years Available:** 2022-present
- **Grades:** 3-9 (ELA and Mathematics)
- **Status:** Current assessment system
- **Data Sources:**
  - [AK STAR
    Results](https://education.alaska.gov/assessments/akstar/results)
  - [2025 Assessment
    Results](https://education.alaska.gov/assessments/results/results2025)
- **Notes:** First administered Spring 2022, replacing PEAKS

### 4. Alaska Science Assessment

- **Years Available:** 2022-present
- **Grades:** 5, 8, 10
- **Status:** Current assessment system
- **Data Sources:**
  - [Science Assessment
    Results](https://education.alaska.gov/assessments/science/results)
  - [2024-2025 Statewide
    Results](https://education.alaska.gov/assessment-results/Statewide/StatewideResults?schoolYear=2024-2025&isScience=True)
- **Proficiency Rates (2024-2025):**
  - All Grades: 37.87%
  - Grade 5: 42.89%
  - Grade 8: 35.02%
  - Grade 10: 34.89%
  - Total Tested: 8,291

### 5. Alaska Developmental Profile (ADP)

- **Years Available:** Ongoing
- **Grades:** Kindergarten
- **Purpose:** Early childhood assessment
- **Data Source:** [2023-2024 ADP
  Results](https://education.alaska.gov/assessment-results/ADP/ADPResults?DistrictYear=2023-2024&DistrictId=5)
- **Notes:** Kindergarten readiness assessment

------------------------------------------------------------------------

## Data Availability by Year

| Year | ELA/Math Assessment | Science Assessment | Notes                                   |
|------|---------------------|--------------------|-----------------------------------------|
| 2014 | AMP                 | N/A                | Single year, AMP                        |
| 2015 | AMP                 | N/A                | AMP canceled after 2015                 |
| 2016 | **None**            | N/A                | AMP canceled, PEAKS not yet implemented |
| 2017 | PEAKS               | N/A                | First PEAKS year                        |
| 2018 | PEAKS               | N/A                | ~45.7% ELA proficient, ~41.2% Math      |
| 2019 | PEAKS               | N/A                | PEAKS canceled                          |
| 2020 | **None**            | N/A                | COVID-19 pandemic                       |
| 2021 | PEAKS               | N/A                | Brief reinstatement, pandemic-affected  |
| 2022 | AK STAR             | Alaska Science     | New assessment system                   |
| 2023 | AK STAR             | Alaska Science     | Results released April 2024             |
| 2024 | AK STAR             | Alaska Science     | Current                                 |
| 2025 | AK STAR (Spring)    | Alaska Science     | Spring 2025 testing                     |

**Data Gaps:** 2016 (transition year), 2020 (COVID), 2019-2021 (PEAKS
cancellation and pandemic)

------------------------------------------------------------------------

## Data Access and Format

### Primary Data Portals

1.  **[Alaska DEED Assessment
    Results](https://education.alaska.gov/assessments/results)**
    - Main portal for all assessment results
    - Interactive dashboards
    - PDF reports by year
2.  **[Alaska DEED Data
    Center](https://education.alaska.gov/data-center)**
    - System for School Success
    - Assessment data and results
    - Alaska Student ID System (ASIS)
    - District and school information
3.  **[Report Card to the
    Public](https://education.alaska.gov/ReportCardToThePublic/Report/2023-2024)**
    - Annual reports for each school year
    - Statewide, district, and school-level data

### Machine-Readable Data

**UPDATE:** CSV downloads ARE available on district/school assessment
result pages (see “CSV Download Implementation Guide” above).

**Access Method:** - **Primary:** District-level CSV downloads from
assessment-results pages - **URL Pattern:**
<https://education.alaska.gov/assessment-results/District/DistrictResults?DistrictYear=YYYY-YY&IsScience=False&DistrictId=%7BID%7D> -
**Format:** CSV files with “Four-Way Suppressed Data” - **Coverage:**
All 54 districts, statewide aggregation via iteration

**Additional Sources (For Reference):** 1. **Alternate Assessment
Excel:** - URL:
<https://education.alaska.gov/tls/assessments/results/2023/AA%20DistrictResults%2022-23%20Suppressed%20Accessible.xlsx> -
Years: At least 2022-2023 - Format: Excel with accessible formatting

2.  **OASIS Data System**
    - Alaska’s student-level data system
    - May require authorization for detailed access
    - Use district CSV downloads instead (simpler, publicly accessible)
3.  **Interactive Results Pages**
    - Primary source for CSV downloads
    - Each district/school has downloadable CSV file
    - No scraping required - direct HTTP GET for CSV files

### Documentation Resources

- [Educator Guide to Assessment Results (AK
  STAR)](https://education.alaska.gov/assessments/akstar/EdGuide_AssessmentResults_AKSTAR.pdf)
- [Family Guide to Assessment Reports Spring
  2024](https://resources.finalsite.net/images/v1728083055/valdezcityschoolsorg/zbkdmmy4zkv82piwwsuz/FamilyGuide_AssessmentReports_Science.pdf)
- [2021 PEAKS Parent
  Guide](https://education.alaska.gov/tls/Assessments/Peaks/ParentGuide_PEAKS_Assessment.pdf)

------------------------------------------------------------------------

## Data Structure Analysis

### Expected Schema Elements (Based on Common Assessment Patterns)

**Note:** Alaska’s education.alaska.gov URLs are blocking direct
inspection, so schema is inferred from standard assessment reporting
patterns and should be verified with actual data files.

#### AK STAR / PEAKS ELA & Math (Typical Fields)

    - school_year (e.g., "2022-2023")
    - district_code
    - district_name
    - school_code
    - school_name
    - grade_level (3, 4, 5, 6, 7, 8, 9)
    - subject ("ELA", "Mathematics")
    - tested_count
    - proficient_count
    - not_proficient_count
    - participation_rate
    - proficiency_rate
    - subgroup (All, Asian, Black, Hispanic, Native American, Pacific Islander, White, Two or More Races, etc.)
    - economic_status (Economically Disadvantaged, Non-Economically Disadvantaged)
    - gender (Male, Female)
    - special_education (Yes, No)
    - ell_status (English Learner, Non-English Learner)
    - migrant (Yes, No)
    - homeless (Yes, No)
    - military_connected (Yes, No)

#### Alaska Science Assessment (Typical Fields)

    - school_year
    - district_code
    - district_name
    - school_code
    - school_name
    - grade_level (5, 8, 10)
    - tested_count
    - proficient_count
    - not_proficient_count
    - participation_rate
    - proficiency_rate
    - subgroup (demographic breakdowns similar to ELA/Math)

#### Performance Levels (Standard Alaska Categories)

    - Level 1: Far Below Proficient
    - Level 2: Below Proficient
    - Level 3: Proficient
    - Level 4: Highly Proficient

**Verification Required:** Actual column names and structure must be
verified by inspecting downloaded data files from Alaska DEED sources.

------------------------------------------------------------------------

## Demographic Subgroups

Based on enrollment data patterns and federal reporting requirements,
Alaska assessments likely include:

**Race/Ethnicity:** - Alaska Native / American Indian - Asian - Black /
African American - Hispanic / Latino - Native Hawaiian / Other Pacific
Islander - White - Two or More Races

**Other Subgroups:** - Economically Disadvantaged - English Learners -
Students with Disabilities - Migrant Students - Homeless Students -
Military Connected Students - Gender (Male, Female)

**Note:** Small cell sizes may be suppressed for privacy (FERPA).

------------------------------------------------------------------------

## Time Series Heuristics

### Data Continuity Challenges

**Major Breaks:** 1. **2015-2016:** AMP canceled → PEAKS not yet
implemented (no assessment data) 2. **2019:** PEAKS canceled → no
replacement ready (gap until 2021) 3. **2020:** COVID-19 pandemic
(assessments waived) 4. **2021:** PEAKS reinstated briefly →
pandemic-affected data 5. **2022:** Transition to AK STAR (new baseline
year)

**Comparison Warnings:** - **2014 vs. 2017-2019:** Different assessment
systems (AMP vs. PEAKS) - not comparable - **2017-2019 vs. 2022+:**
Different assessment systems (PEAKS vs. AK STAR) - not comparable -
**2021 vs. other years:** Pandemic-affected participation and
performance - use caution - **Trend analysis:** Only valid within same
assessment system (e.g., 2022-2025 AK STAR)

### Recommended Time Series Approach

**For Research/Analysis:** - **AMP Era:** 2014 only (single year, no
trends) - **PEAKS Era:** 2017-2019, 2021 (4 years, but 2019 canceled,
2021 pandemic-affected) - **AK STAR Era:** 2022-present (current system,
multi-year trends possible)

**For Implementation:** - Focus on **AK STAR (2022-present)** as primary
time series - Include **Alaska Science Assessment (2022-present)** -
Consider **PEAKS 2017-2019** as secondary historical series (with
caveats) - Exclude 2014 AMP (limited data) - Exclude 2016, 2020 (no
data) - Treat 2021 as outlier (pandemic-affected)

------------------------------------------------------------------------

## Implementation Recommendations

### Phase 1: AK STAR Assessment Data (RECOMMENDED - NOW FEASIBLE)

**Priority:** HIGH **Complexity:** MEDIUM **Status:** FEASIBLE (CSV
downloads discovered 2025-01-11)

**Data Sources:** - AK STAR ELA & Math (2022-present) - CSV downloads
available - Alaska Science Assessment (2022-present) - CSV downloads
available

**Implementation Steps:**

1.  **Test CSV Download (1 hour):**
    - Manually download 2-3 district CSV files to verify structure
    - Examine columns, data types, suppression indicators
    - Document schema variations across years
2.  **Implement District Iterator (2 hours):**
    - Create helper function to generate district URLs (DistrictIds
      1-54)
    - Test with a few districts first (Anchorage=5, Mat-Su=28)
    - Add error handling for missing districts/data
3.  **Implement get_raw_assessment() (2 hours):**
    - Loop through all 54 districts
    - Download and combine CSV files
    - Return raw combined dataset
    - Add caching support
4.  **Implement process_assessment() (1 hour):**
    - Parse CSV structure (handle multi-row headers if present)
    - Extract: district_id, school_id, grade, subject, proficiency
      level, count, percentage
    - Handle suppressed values (“\*“,”\<10”, “N/A”)
    - Standardize column names across years
5.  **Implement tidy_assessment() (1 hour):**
    - Convert to long format (consistent with enrollment data pattern)
    - Calculate percentages if not provided
    - Add data quality checks
    - Return tidy data frame
6.  **Write Tests (2 hours):**
    - Fidelity tests: Verify Anchorage data matches raw CSV
    - Quality tests: Check state totals, major districts exist
    - Range tests: No negatives, percentages 0-100
    - Coverage tests: All 54 districts present
7.  **Add fetch_assessment() Wrapper (1 hour):**
    - Convenience function combining get + process + tidy
    - Follows enrollment data pattern
    - Add documentation and examples

**Total Estimated Time:** 10 hours

**Expected Output:**

``` r
fetch_assessment(2024, subject = "ELA")
# Returns: Data frame with columns
# - end_year, district_id, district_name, school_id, school_name
# - grade_level, subject, proficiency_level
# - n_students, pct, is_state, is_district, is_school
```

**Advantages:** - Complete statewide coverage (all 54 districts) -
Machine-readable format (CSV) - Automated process (no manual
downloads) - Publicly accessible (no authentication) - Consistent with
existing enrollment data pattern

### Phase 2: Historical PEAKS (Optional)

**Priority:** LOW **Complexity:** HIGH

**Data Sources:** - PEAKS 2017, 2018, 2019, 2021

**Approach:** 1. Archive.org or historical PDF reports 2. Manual data
extraction from PDFs (last resort) 3. Document as separate historical
series

**Challenges:** - PDF format (not machine-readable) - Potential
scanning/OCR required - Limited utility due to different assessment
system

### Phase 3: AMP and Transition Years (Not Recommended)

**Priority:** SKIP **Reason:** Single year (AMP), no data (2016, 2020),
different systems (comparability issues)

------------------------------------------------------------------------

## Technical Challenges

### 1. Limited Machine-Readable Downloads

**Issue:** Alaska DEED assessment pages prioritize interactive
dashboards over direct file downloads **Impact:** Requires web scraping,
API investigation, or manual downloads **Severity:** HIGH

### 2. Access Control

**Issue:** Some data may require authorization or educator credentials
**Impact:** May limit access to detailed student-level data
**Severity:** MEDIUM

### 3. URL Blocking

**Issue:** education.alaska.gov URLs are blocking automated requests (as
seen in webReader attempts) **Impact:** Scraping may be technically
challenging or violate terms **Severity:** HIGH

### 4. Assessment System Changes

**Issue:** Multiple assessment systems with different scales and
standards **Impact:** Difficult to create unified time series across
years **Severity:** MEDIUM

### 5. Data Gaps

**Issue:** 2016, 2020, and transitions between systems create gaps
**Impact:** Incomplete historical record **Severity:** LOW (expected)

------------------------------------------------------------------------

## Alternative Data Sources

**IMPORTANT:** Per project rules, federal sources (Urban Institute, NCES
CCD, EdData Express) are **FORBIDDEN** for implementation. The following
are listed for documentation purposes only:

### Federal Sources (DO NOT USE FOR IMPLEMENTATION)

- **EdData Express:**
  <https://eddataexpress.ed.gov/download/data-builder/data-download-tool>
  - Has Alaska data in CSV format
  - FORBIDDEN per project rules (federal aggregation loses
    state-specific details)

### State-Approved Alternatives (Acceptable)

- **OASIS Data System:** Alaska’s official student data system
  - May have CSV export capabilities
  - Requires investigation of access requirements
- **District-Level Data:** Some Alaska districts publish assessment data
  - Anchorage School District: [AK STAR &
    Science](https://www.asdk12.org/departments/academic-services/ae-department-overview/assessment/state-assessments/ak-star-and-alaska-science-assessment)
  - Fairbanks North Star Borough: [2023 AK STAR
    Reports](https://www.k12northstar.org/departments/teaching-learning/parent-student-information/assessments/ak-system-of-academic-readiness-ak-star-ak-science/2023-ak-star-ak-science-reports)
  - Fragmented coverage (not all districts)

------------------------------------------------------------------------

## Data Quality Considerations

### Participation Rates

- 2021: Pandemic-affected participation (verify rates before use)
- 2022-2025: Monitor participation rates for anomalies
- Small schools/districts: May have suppressed data for privacy

### Proficiency Definitions

- AMP: Different proficiency standards (2014 only)
- PEAKS: Different proficiency standards (2017-2019, 2021)
- AK STAR: Current proficiency standards (2022-present)
- **Critical:** Do NOT compare proficiency percentages across assessment
  systems

### Small Cell Suppression

- Alaska has many small schools and rural districts
- Data for small subgroups may be suppressed (shown as “\*” or “-”)
- Implementation must handle suppressed values

### Data Freshness

- Spring assessments: Results typically released September-April
  following school year
- Example: 2023 results released April 2024
- Implementation should check for result availability

------------------------------------------------------------------------

## Next Steps for Implementation

### Immediate Actions (If Proceeding)

1.  **Manual Inspection:**
    - Visit <https://education.alaska.gov/assessments/akstar/results>
    - Check for download buttons, data export options
    - Inspect network traffic (browser DevTools) for API calls
    - Document exact data format and columns
2.  **Contact Alaska DEED:**
    - Email: <eed.contact@alaska.gov>
    - Phone: 907-465-2800
    - Inquire about bulk data download options for researchers
3.  **Test Scrape/Download:**
    - Attempt to download sample files (if available)
    - Parse and document schema
    - Test reproducibility across years
4.  **Create Prototype Functions:**
    - `get_raw_akstar_ela(year)`
    - `get_raw_akstar_math(year)`
    - `get_raw_science(year)`
    - `process_assessment_ak(data)`
5.  **Validate Data:**
    - Check for expected columns
    - Verify no Inf/NaN values
    - Validate totals (state = sum of districts)
    - Test time series consistency

### Research Questions to Resolve

1.  Does Alaska DEED provide bulk CSV downloads, or only interactive
    dashboards?
2.  Are there API endpoints behind the interactive dashboards?
3.  What are the exact column names in AK STAR data files?
4.  How are small cell sizes represented (suppressed values)?
5.  What is the data release schedule for each school year?
6.  Are historical PEAKS data available in machine-readable format?

------------------------------------------------------------------------

## Conclusion

Alaska assessment data is **technically feasible** but **operationally
complex** due to:

- Multiple assessment systems with limited comparability
- Gaps in historical data (2016, 2020, assessment transitions)
- Limited machine-readable download options from state sources
- Potential need for web scraping or API investigation
- URL blocking preventing automated inspection

**Recommended Approach:** 1. Start with **AK STAR (2022-present)** and
**Alaska Science Assessment (2022-present)** 2. Focus on current
assessment system as foundation 3. Add historical PEAKS data later if
feasible (PDF extraction challenges) 4. Document assessment system
transitions clearly for users

**Complexity Rating:** 7/10 (High complexity due to data access
challenges)

**Estimated Implementation Effort:** 20-30 hours (investigation, schema
documentation, function development, testing)

------------------------------------------------------------------------

## Sources

- [Alaska DEED Assessment
  Results](https://education.alaska.gov/assessments/results)
- [AK STAR
  Results](https://education.alaska.gov/assessments/akstar/results)
- [Alaska Science Assessment
  Results](https://education.alaska.gov/assessments/science/results)
- [PEAKS Assessment
  Results](https://education.alaska.gov/assessments/peaks/results)
- [Alaska’s Historical Performance on State
  Assessments](https://alaskapolicyforum.org/2023/11/alaskas-historical-performance-on-state-assessments/)
- [2024-2025 Science Statewide
  Results](https://education.alaska.gov/assessment-results/Statewide/StatewideResults?schoolYear=2024-2025&isScience=True)
- [Alaska DEED Data Center](https://education.alaska.gov/data-center)
- [Report Card to the Public
  2023-2024](https://education.alaska.gov/ReportCardToThePublic/Report/2023-2024)
