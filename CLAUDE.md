# akschooldata Package

## Data Source

**CRITICAL**: This package uses ONLY Alaska DEED (Department of
Education & Early Development) data sources. Do NOT use: - NCES CCD
(Common Core of Data) - Urban Institute Education Data API - Any other
federal data sources

All enrollment data comes directly from Alaska DEED at: -
<https://education.alaska.gov/Stats/enrollment/>

## Data Files

The package downloads two Excel files per school year:

1.  **Enrollment by School by Grade**
    - URL pattern:
      `https://education.alaska.gov/Stats/enrollment/2- Enrollment by School by Grade YYYY-YY.xlsx`
    - Contains: PK through 12th grade enrollment counts by school
2.  **Enrollment by School by Ethnicity**
    - URL pattern:
      `https://education.alaska.gov/Stats/enrollment/5- Enrollment by School by ethnicity YYYY-YY.xlsx`
    - Contains: Demographic breakdowns (Alaska Native, Asian, Black,
      Hispanic, Pacific Islander, White, Two or More)

## Available Years

- **Range**: 2019-2025 (7 years)
- Earlier years may exist as PDF reports but are not supported for
  automated download

## Key Functions

- `fetch_enr(end_year)` - Main function to get enrollment data
- `fetch_enr_multi(end_years)` - Get multiple years at once
- [`get_available_years()`](https://almartin82.github.io/akschooldata/reference/get_available_years.md) -
  Returns min/max years (2019-2025)
- [`import_local_deed_enrollment()`](https://almartin82.github.io/akschooldata/reference/import_local_deed_enrollment.md) -
  Fallback for local file import

## Column Naming

DEED Excel files have varied column names. The
[`normalize_deed_colnames()`](https://almartin82.github.io/akschooldata/reference/normalize_deed_colnames.md)
function handles: - Grade columns: “PK”, “K”, “1”-“12” -\> “grade_pk”,
“grade_k”, “grade_01”-“grade_12” - Ethnicity columns: Various names -\>
“native_american”, “asian”, “black”, “hispanic”, “pacific_islander”,
“white”, “multiracial” - Total column: “Total” -\> “row_total”

## Notes

- Alaska has ~54 school districts and ~500 schools
- October 1 is the official enrollment count date
- Small cell sizes may be suppressed for privacy
- Gender data (male/female) is NOT available in current DEED files
