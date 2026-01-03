# Download enrollment by grade from Alaska DEED

Downloads the "Enrollment by School by Grade" Excel file from DEED.
Files are located at: https://education.alaska.gov/Stats/enrollment/

## Usage

``` r
download_deed_enrollment_by_grade(end_year)
```

## Arguments

- end_year:

  School year end (e.g., 2024 for 2023-24)

## Value

Data frame with grade-level enrollment by school

## Details

Note: File formats vary by year:

- 2021-2023: Title row in row 1, headers in row 2, uses
  ID/District/School Name

- 2024-2025: Headers in row 1, uses Type/id/District/School
