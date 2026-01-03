# Download enrollment by ethnicity from Alaska DEED

Downloads the "Enrollment by School by Ethnicity" Excel file from DEED.
Files are located at: https://education.alaska.gov/Stats/enrollment/

## Usage

``` r
download_deed_enrollment_by_ethnicity(end_year)
```

## Arguments

- end_year:

  School year end (e.g., 2024 for 2023-24)

## Value

Data frame with ethnicity enrollment by school

## Details

Note: File formats vary by year:

- 2021-2023: Title row in row 1, headers in row 2, uses ID/District /
  School/Ethnicity

- 2024-2025: Headers in row 1, uses Type/id/District/School/Ethnicity
