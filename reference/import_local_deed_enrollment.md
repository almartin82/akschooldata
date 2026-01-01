# Import local DEED enrollment files

Fallback function to import locally downloaded DEED enrollment files.
Use this if automatic download fails due to network issues.

## Usage

``` r
import_local_deed_enrollment(grade_file, ethnicity_file, end_year)
```

## Arguments

- grade_file:

  Path to local "Enrollment by School by Grade" xlsx file

- ethnicity_file:

  Path to local "Enrollment by School by Ethnicity" xlsx file

- end_year:

  School year end (e.g., 2024 for 2023-24)

## Value

List with school and district data frames

## Examples

``` r
if (FALSE) { # \dontrun{
# Download files manually from:
# https://education.alaska.gov/Stats/enrollment/

raw_data <- import_local_deed_enrollment(
  grade_file = "2- Enrollment by School by Grade 2023-24.xlsx",
  ethnicity_file = "5- Enrollment by School by ethnicity 2023-24.xlsx",
  end_year = 2024
)
} # }
```
