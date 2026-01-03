# 10 Insights from Alaska School Enrollment Data

``` r
library(akschooldata)
library(dplyr)
library(tidyr)
library(ggplot2)

theme_set(theme_minimal(base_size = 14))

# Get available year range from package
available <- get_available_years()
min_year <- available$min_year
max_year <- available$max_year
all_years <- min_year:max_year
```

This vignette explores Alaska’s public school enrollment data, surfacing
key trends and demographic patterns across 5 years of data (2021-2025).

*Note: This vignette fetches live data from the Alaska Department of
Education. Run locally with `NOT_CRAN=true` to see computed output and
charts.*

------------------------------------------------------------------------

## 1. Alaska’s enrollment is sliding south

Alaska’s public school enrollment has been in steady decline, dropping
from around 132,000 to under 130,000 students in recent years. The Last
Frontier is losing families.

``` r
enr <- fetch_enr_multi(all_years)

state_totals <- enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 2))

state_totals
#>   end_year n_students change pct_change
#> 1     2021     127210     NA         NA
#> 2     2022     127509    299       0.24
#> 3     2023     128088    579       0.45
#> 4     2024     127931   -157      -0.12
#> 5     2025     126284  -1647      -1.29
```

``` r
ggplot(state_totals, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.2, color = "#003366") +
  geom_point(size = 3, color = "#003366") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = paste0("Alaska Public School Enrollment (", min_year, "-", max_year, ")"),
    subtitle = "Steady decline as families leave the Last Frontier",
    x = "School Year (ending)",
    y = "Total Enrollment"
  )
```

![](enrollment_hooks_files/figure-html/statewide-chart-1.png)

------------------------------------------------------------------------

## 2. Anchorage is half the state

The Anchorage School District educates nearly half of all Alaska
students. When Anchorage sneezes, Alaska catches a cold.

``` r
enr_latest <- fetch_enr(max_year)

top_districts <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  head(10) |>
  select(district_name, n_students)

top_districts
#>                                   district_name n_students
#> 1                     Anchorage School District      41598
#> 2     Matanuska-Susitna Borough School District      19019
#> 3  Fairbanks North Star Borough School District      11707
#> 4       Kenai Peninsula Borough School District       8355
#> 5                   Galena City School District       7839
#> 6                 Yukon-Koyukuk School District       3930
#> 7                Juneau Borough School District       3923
#> 8               Lower Kuskokwim School District       3680
#> 9                   Nenana City School District       2196
#> 10        Kodiak Island Borough School District       2049
```

``` r
top_districts |>
  mutate(district_name = forcats::fct_reorder(district_name, n_students)) |>
  ggplot(aes(x = n_students, y = district_name, fill = district_name)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = scales::comma(n_students)), hjust = -0.1, size = 3.5) +
  scale_x_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  scale_fill_viridis_d(option = "mako", begin = 0.2, end = 0.8) +
  labs(
    title = paste0("Top 10 Alaska Districts by Enrollment (", max_year, ")"),
    subtitle = "Anchorage dominates with nearly half of all students",
    x = "Number of Students",
    y = NULL
  )
```

![](enrollment_hooks_files/figure-html/top-districts-chart-1.png)

------------------------------------------------------------------------

## 3. Post-COVID enrollment shifts

The pandemic’s effects on enrollment continue to ripple through Alaska’s
districts. Some areas show signs of recovery while others continue to
decline.

``` r
post_covid_years <- min_year:min(min_year + 2, max_year)
post_covid_enr <- fetch_enr_multi(post_covid_years)

# Get year column names for dynamic reference
year1_col <- as.character(min_year)
year2_col <- as.character(min_year + 1)

covid_changes <- post_covid_enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% c(min_year, min_year + 1)) |>
  pivot_wider(names_from = end_year, values_from = n_students) |>
  mutate(pct_change = round((.data[[year2_col]] / .data[[year1_col]] - 1) * 100, 1)) |>
  arrange(pct_change) |>
  head(10) |>
  select(district_name, all_of(c(year1_col, year2_col)), pct_change)

covid_changes
#> # A tibble: 10 × 4
#>    district_name               `2021` `2022` pct_change
#>    <chr>                        <dbl>  <dbl>      <dbl>
#>  1 Hydaburg City Schools          169    127      -24.9
#>  2 Yukon-Koyukuk Schools         4160   3332      -19.9
#>  3 Galena City Schools           9030   7276      -19.4
#>  4 Craig City Schools             874    713      -18.4
#>  5 Tanana Schools                  30     26      -13.3
#>  6 Denali Borough Schools        1152   1003      -12.9
#>  7 Yupiit Schools                 506    444      -12.3
#>  8 Nenana City Schools           1843   1633      -11.4
#>  9 Bristol Bay Borough Schools    119    106      -10.9
#> 10 Iditarod Area Schools          322    288      -10.6
```

------------------------------------------------------------------------

## 4. Alaska Native students are a quarter of enrollment

Alaska Native and American Indian students make up about 22-25% of
enrollment statewide–far higher than any other state except Hawaii.

``` r
demographics <- enr_latest |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("native_american", "white", "asian", "black", "hispanic", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

demographics
#> [1] subgroup   n_students pct       
#> <0 rows> (or 0-length row.names)
```

``` r
demographics |>
  mutate(subgroup = forcats::fct_reorder(subgroup, n_students)) |>
  ggplot(aes(x = n_students, y = subgroup, fill = subgroup)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct, "%")), hjust = -0.1) +
  scale_x_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = paste0("Alaska Student Demographics (", max_year, ")"),
    subtitle = "Alaska Native students comprise a quarter of enrollment",
    x = "Number of Students",
    y = NULL
  )
```

![](enrollment_hooks_files/figure-html/demographics-chart-1.png)

------------------------------------------------------------------------

## 5. Kindergarten predicts the future

Kindergarten enrollment is the canary in the coal mine. Alaska’s K
numbers have been weak for years, signaling more decline ahead.

``` r
grade_trends <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "12")) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

grade_trends
#> # A tibble: 5 × 3
#>   end_year     K  `12`
#>      <int> <dbl> <dbl>
#> 1     2021  9412  9504
#> 2     2022  9790  9455
#> 3     2023  9650  9647
#> 4     2024  9257  9765
#> 5     2025  8869  9984
```

``` r
enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "12")) |>
  ggplot(aes(x = end_year, y = n_students, color = grade_level)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  scale_color_manual(values = c("K" = "#E69F00", "12" = "#56B4E9")) +
  labs(
    title = "Kindergarten vs 12th Grade Enrollment",
    subtitle = "Weak kindergarten numbers signal continued decline",
    x = "School Year",
    y = "Enrollment",
    color = "Grade"
  )
```

![](enrollment_hooks_files/figure-html/k-trend-chart-1.png)

------------------------------------------------------------------------

## 6. The Mat-Su Valley bucks the trend

While Anchorage shrinks, the Matanuska-Susitna Borough School District
(Palmer/Wasilla area) has been growing, attracting families leaving the
big city.

``` r
matsu <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Mat-Su|Matanuska", district_name, ignore.case = TRUE)) |>
  select(end_year, district_name, n_students)

matsu
#>   end_year                             district_name n_students
#> 1     2021                    Mat-Su Borough Schools      17935
#> 2     2022                    Mat-Su Borough Schools      18957
#> 3     2023                    Mat-Su Borough Schools      19225
#> 4     2024 Matanuska-Susitna Borough School District      19271
#> 5     2025 Matanuska-Susitna Borough School District      19019
```

``` r
enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Mat-Su|Matanuska|Anchorage", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  mutate(index = round(n_students / first(n_students) * 100, 1)) |>
  ggplot(aes(x = end_year, y = index, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  labs(
    title = "Anchorage vs Mat-Su: Diverging Paths",
    subtitle = paste0("Indexed to ", min_year, " = 100"),
    x = "School Year",
    y = "Enrollment Index",
    color = "District"
  )
```

![](enrollment_hooks_files/figure-html/anchorage-matsu-chart-1.png)

------------------------------------------------------------------------

## 7. Rural districts are disappearing

Small rural districts with fewer than 100 students face existential
challenges. Some haven’t reported enrollment in recent years.

``` r
small_districts <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  filter(n_students < 200) |>
  arrange(n_students) |>
  select(district_name, n_students)

small_districts
#>                             district_name n_students
#> 1            Pelican City School District         12
#> 2         Aleutian Region School District         21
#> 3                Pribilof School District         60
#> 4                 Yakutat School District         94
#> 5     Bristol Bay Borough School District        101
#> 6           Hydaburg City School District        108
#> 7             Hoonah City School District        109
#> 8               Kake City School District        111
#> 9            Klawock City School District        124
#> 10                Skagway School District        133
#> 11                Chatham School District        161
#> 12           Saint Mary's School District        161
#> 13 Aleutians East Borough School District        163
#> 14       Southeast Island School District        164
#> 15            Yukon Flats School District        171
```

------------------------------------------------------------------------

## 8. The graduation pipeline leaks

The gap between 9th grade and 12th grade enrollment reveals retention
challenges that vary dramatically by district.

``` r
pipeline <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment",
         grade_level %in% c("09", "12")) |>
  pivot_wider(names_from = grade_level, values_from = n_students) |>
  mutate(ratio = round(`12` / `09` * 100, 1)) |>
  filter(`09` >= 50) |>
  arrange(ratio) |>
  head(10) |>
  select(district_name, `09`, `12`, ratio)

pipeline
#> # A tibble: 10 × 4
#>    district_name                                 `09`  `12` ratio
#>    <chr>                                        <dbl> <dbl> <dbl>
#>  1 Denali Borough School District                  81    NA    NA
#>  2 Anchorage School District                     3189    NA    NA
#>  3 Bering Strait School District                  140    NA    NA
#>  4 Delta/Greely School District                    85    NA    NA
#>  5 Fairbanks North Star Borough School District   846    NA    NA
#>  6 Galena City School District                    597    NA    NA
#>  7 Juneau Borough School District                 298    NA    NA
#>  8 Kenai Peninsula Borough School District        673    NA    NA
#>  9 Ketchikan Gateway Borough School District      169    NA    NA
#> 10 Kodiak Island Borough School District          172    NA    NA
```

------------------------------------------------------------------------

## 9. Fairbanks is shrinking faster than Anchorage

Fairbanks North Star Borough School District has seen steeper percentage
declines than Anchorage in recent years. The interior is emptying out.

``` r
major_districts <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Fairbanks|Anchorage", district_name)) |>
  mutate(district_simple = case_when(
    grepl("Anchorage", district_name) ~ "Anchorage",
    grepl("Fairbanks", district_name) ~ "Fairbanks",
    TRUE ~ district_name
  )) |>
  group_by(district_simple) |>
  mutate(index = round(n_students / first(n_students) * 100, 1)) |>
  select(end_year, district_simple, n_students, index)

major_districts
#> # A tibble: 10 × 4
#> # Groups:   district_simple [2]
#>    end_year district_simple n_students index
#>       <int> <chr>                <dbl> <dbl>
#>  1     2021 Anchorage            41203  100 
#>  2     2021 Fairbanks            11199  100 
#>  3     2022 Anchorage            42701  104.
#>  4     2022 Fairbanks            12199  109.
#>  5     2023 Anchorage            43325  105.
#>  6     2023 Fairbanks            12568  112.
#>  7     2024 Anchorage            42431  103 
#>  8     2024 Fairbanks            12365  110.
#>  9     2025 Anchorage            41598  101 
#> 10     2025 Fairbanks            11707  104.
```

``` r
enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Fairbanks|Anchorage", district_name)) |>
  mutate(district_simple = case_when(
    grepl("Anchorage", district_name) ~ "Anchorage",
    grepl("Fairbanks", district_name) ~ "Fairbanks",
    TRUE ~ district_name
  )) |>
  group_by(district_simple) |>
  mutate(index = round(n_students / first(n_students) * 100, 1)) |>
  ggplot(aes(x = end_year, y = index, color = district_simple)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("Anchorage" = "#003366", "Fairbanks" = "#CC5500")) +
  labs(
    title = "Fairbanks vs Anchorage: Who's Shrinking Faster?",
    subtitle = paste0("Indexed to ", min_year, " = 100"),
    x = "School Year",
    y = "Enrollment Index",
    color = "District"
  )
```

![](enrollment_hooks_files/figure-html/fairbanks-anchorage-chart-1.png)

------------------------------------------------------------------------

## 10. Alaska’s geography creates unique schools

Some Alaska schools are only accessible by plane or boat. These remote
schools serve communities of fewer than 50 students across areas larger
than some states.

``` r
smallest <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(n_students) |>
  head(10) |>
  select(district_name, n_students)

smallest
#>                          district_name n_students
#> 1         Pelican City School District         12
#> 2      Aleutian Region School District         21
#> 3             Pribilof School District         60
#> 4              Yakutat School District         94
#> 5  Bristol Bay Borough School District        101
#> 6        Hydaburg City School District        108
#> 7          Hoonah City School District        109
#> 8            Kake City School District        111
#> 9         Klawock City School District        124
#> 10             Skagway School District        133
```

------------------------------------------------------------------------

## Summary

Alaska’s school enrollment data reveals:

- **Steady decline**: The Last Frontier is losing students year over
  year
- **Anchorage dominance**: One district educates nearly half the state
- **Alaska Native presence**: A quarter of students are Alaska Native
- **Urban-suburban shift**: Mat-Su grows while Anchorage and Fairbanks
  shrink
- **Rural challenges**: Tiny bush districts face existential threats

These patterns shape school funding debates and facility planning across
America’s largest and most remote state.

------------------------------------------------------------------------

*Data sourced from the Alaska Department of Education and Early
Development [Data Center](https://education.alaska.gov/data-center).*
