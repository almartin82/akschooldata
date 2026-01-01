# Split Alaska DEED data into school and district levels

Alaska DEED data has districts and schools in the same file with a Type
column. This function splits them and assigns district info to schools.

## Usage

``` r
split_deed_data(merged_data)
```

## Arguments

- merged_data:

  Data frame with entity_type column

## Value

List with school and district data frames
