# Add ethnicity data to districts by aggregating from schools

The DEED data only provides ethnicity breakdowns at the school level.
This function sums school ethnicity counts to create district totals.

## Usage

``` r
add_district_ethnicity_from_schools(district_df, school_df)
```

## Arguments

- district_df:

  Processed district data frame

- school_df:

  Processed school data frame with ethnicity columns

## Value

District data frame with ethnicity columns added
