# akschooldata: Fetch and Process Alaska School Data

Downloads and processes school data from the Alaska Department of
Education and Early Development (DEED). Provides functions for fetching
enrollment data including October 1 counts by school, district, grade
level, and demographic groups, and transforming it into tidy format for
analysis.

## Details

IMPORTANT: This package uses ONLY Alaska DEED data sources. No federal
data sources (NCES CCD, Urban Institute API, etc.) are used.

## Main functions

- [`fetch_enr`](https://almartin82.github.io/akschooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/akschooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- [`tidy_enr`](https://almartin82.github.io/akschooldata/reference/tidy_enr.md):

  Transform wide data to tidy (long) format

- [`enr_grade_aggs`](https://almartin82.github.io/akschooldata/reference/enr_grade_aggs.md):

  Create grade-level aggregations

- [`get_available_years`](https://almartin82.github.io/akschooldata/reference/get_available_years.md):

  View available year range

- [`import_local_deed_enrollment`](https://almartin82.github.io/akschooldata/reference/import_local_deed_enrollment.md):

  Import locally downloaded DEED files

## Cache functions

- [`cache_status`](https://almartin82.github.io/akschooldata/reference/cache_status.md):

  View cached data files

- [`clear_cache`](https://almartin82.github.io/akschooldata/reference/clear_cache.md):

  Remove cached data files

## Data Source

All data is sourced directly from Alaska DEED:

- DEED Data Center: <https://education.alaska.gov/data-center>

- DEED Statistics: <https://education.alaska.gov/stats>

- Enrollment Files: <https://education.alaska.gov/Stats/enrollment/>

The package downloads two Excel files for each school year:

- Enrollment by School by Grade (grade-level counts)

- Enrollment by School by Ethnicity (demographic breakdowns)

## Data Availability

Available years: 2019-2025 (Excel files from DEED Statistics Portal)

## Demographics

Alaska has unique demographic composition:

- 22% Alaska Native/American Indian (highest in US)

- 3% Native Hawaiian/Pacific Islander (among highest in US)

- Approximately 131,000 total students

- 53 school districts (plus Mt. Edgecumbe High School)

## See also

Useful links:

- <https://almartin82.github.io/akschooldata/>

- <https://github.com/almartin82/akschooldata>

- Report bugs at <https://github.com/almartin82/akschooldata/issues>
