# Merge DEED enrollment data files

Combines grade-level and ethnicity enrollment data into a single
dataset. The ethnicity file has multiple rows per school (one per
ethnicity), so we pivot it to wide format before merging with the grade
data.

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
