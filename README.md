# akschooldata

An R package for fetching, processing, and analyzing school enrollment data from Alaska's Department of Education and Early Development (DEED).

## Installation

```r
# Install from GitHub
devtools::install_github("almartin82/akschooldata")
```
## Quick Start

```r
library(akschooldata)

# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get multiple years
enr_multi <- fetch_enr_multi(2020:2024)

# View state totals
enr_2024 %>%
  dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# Filter to Anchorage School District
anchorage <- enr_2024 %>%
  dplyr::filter(grepl("Anchorage", district_name))

# View available years
get_available_years()
```

## Data Availability

### Years Available

| Format Era | Years | Data Source | Notes |
|------------|-------|-------------|-------|
| **NCES CCD Era** | 2011-2025 | NCES Common Core of Data | Best data quality, detailed demographics |
| **DEED Legacy Era** | 2002-2010 | DEED School Ethnicity Reports | PDF-based, limited automation |
| **Early Era** | 1997-2001 | Historical records | Limited data available |

**Earliest available year**: 1997
**Most recent available year**: 2025
**Total years of data**: 29 years

### What's Available

- **Aggregation levels**: State, District, School (Campus)
- **Demographics**:
  - Alaska Native/American Indian
  - Asian
  - Black/African American
  - Hispanic/Latino
  - Native Hawaiian/Pacific Islander
  - White
  - Two or More Races
- **Gender**: Male, Female
- **Grade levels**: PK, K, 1-12

### Alaska-Specific Demographics

Alaska has unique demographic characteristics relevant to education data:

- **22% Alaska Native/American Indian** - One of the highest proportions in the US
- **3% Native Hawaiian/Pacific Islander** - Among the highest in the US
- **~131,000 total students** enrolled
- **53 school districts** (plus Mt. Edgecumbe High School as a state-operated school)

### What's NOT Available

- Special education student counts (available separately via DEED)
- Economically disadvantaged counts (not consistently reported)
- English Learner (EL/LEP) counts (limited availability)
- Staff/teacher counts (separate data collection)

### Known Caveats

1. **October 1 Count**: All enrollment data represents the official count date of October 1
2. **NCES vs DEED**: NCES CCD data may have slight differences from DEED published totals due to data submission timing
3. **Suppression**: Small cell sizes (<5 students) may be suppressed for privacy
4. **Charter Schools**: Alaska has relatively few charter schools; most are operated by traditional districts
5. **Correspondence Schools**: Alaska has a significant correspondence/homeschool program that may be reported differently

## Data Sources

### Primary: NCES Common Core of Data (CCD)

The package primarily uses data from the National Center for Education Statistics (NCES) Common Core of Data:

- **Website**: https://nces.ed.gov/ccd/
- **Data Files**: https://nces.ed.gov/ccd/files.asp
- **Table Generator**: https://nces.ed.gov/ccd/elsi/

### Secondary: Alaska DEED

Additional data and validation from Alaska Department of Education and Early Development:

- **Data Center**: https://education.alaska.gov/data-center
- **Statistics**: https://education.alaska.gov/stats
- **Report Cards**: https://education.alaska.gov/reportcard

## ID System

Alaska uses NCES identification codes:

| Identifier | Format | Example | Description |
|------------|--------|---------|-------------|
| State FIPS | 2 digits | 02 | Alaska state code |
| District ID (LEAID) | 02XXXXX | 0200180 | NCES LEA identifier |
| School ID (SCHID) | 02XXXXXXXXXX | 020018000253 | NCES school identifier |

## Output Format

### Wide Format (tidy = FALSE)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end (2024 = 2023-24) |
| district_id | character | NCES district identifier |
| campus_id | character | NCES school identifier |
| district_name | character | District name |
| campus_name | character | School name |
| type | character | "State", "District", or "Campus" |
| row_total | integer | Total enrollment |
| white, black, hispanic, asian, native_american, pacific_islander, multiracial | integer | Race/ethnicity counts |
| male, female | integer | Gender counts |
| grade_pk through grade_12 | integer | Grade-level enrollment |

### Tidy Format (tidy = TRUE, default)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end |
| district_id | character | District identifier |
| campus_id | character | School identifier |
| type | character | Aggregation level |
| grade_level | character | "TOTAL", "PK", "K", "01"-"12" |
| subgroup | character | "total_enrollment", demographic group, etc. |
| n_students | integer | Student count |
| pct | numeric | Percentage of total (0-1 scale) |
| is_state | logical | TRUE if state-level row |
| is_district | logical | TRUE if district-level row |
| is_campus | logical | TRUE if school-level row |
| is_charter | logical | TRUE if charter school |

## Caching

Data is cached locally to avoid repeated downloads:

```r
# View cache status
cache_status()

# Clear specific year
clear_cache(2024)

# Clear all cache
clear_cache()
```

Cache location: `rappdirs::user_cache_dir("akschooldata")`

## Related Packages

This package is part of the state schooldata family:

- [txschooldata](https://github.com/almartin82/txschooldata) - Texas
- [ilschooldata](https://github.com/almartin82/ilschooldata) - Illinois
- [nyschooldata](https://github.com/almartin82/nyschooldata) - New York
- [ohschooldata](https://github.com/almartin82/ohschooldata) - Ohio
- [paschooldata](https://github.com/almartin82/paschooldata) - Pennsylvania
- [caschooldata](https://github.com/almartin82/caschooldata) - California

## License
MIT
