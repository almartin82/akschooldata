# Get available years for Alaska enrollment data

Returns the range of years for which enrollment data is available from
Alaska DEED's statistics portal.

## Usage

``` r
get_available_years()
```

## Value

Named list with min_year, max_year, and description

## Details

Data is downloaded directly from:
https://education.alaska.gov/Stats/enrollment/

## Examples

``` r
get_available_years()
#> $min_year
#> [1] 2019
#> 
#> $max_year
#> [1] 2025
#> 
#> $description
#> [1] "Alaska DEED enrollment data availability:\n- 2019-2025: Excel files from DEED Statistics Portal\n  (Enrollment by School by Grade & Enrollment by School by Ethnicity)\n\nData source: https://education.alaska.gov/Stats/enrollment/\n\nNote: Earlier years may be available as PDF reports but are not\ncurrently supported for automated download."
#> 
```
