# Merge DEED enrollment data files

Combines grade-level and ethnicity enrollment data into a single
dataset.

## Usage

``` r
merge_deed_enrollment_data(grade_data, ethnicity_data)
```

## Arguments

- grade_data:

  Data frame from download_deed_enrollment_by_grade

- ethnicity_data:

  Data frame from download_deed_enrollment_by_ethnicity

## Value

Merged data frame with all enrollment columns
