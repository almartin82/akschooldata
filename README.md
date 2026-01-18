# akschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/akschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/akschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/akschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/akschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/akschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/akschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Fetch and analyze Alaska school enrollment data from the Alaska Department of Education and Early Development (DEED) in R or Python.

**[Documentation](https://almartin82.github.io/akschooldata/)** | **[Getting Started](https://almartin82.github.io/akschooldata/articles/quickstart.html)**

Part of the State Schooldata Project, inspired by [njschooldata](https://github.com/almartin82/njschooldata) -- the original R package for accessing state education data. This package brings the same simple, consistent interface to Alaska's enrollment data.

## What can you find with akschooldata?

**5 years of enrollment data (2021-2025).** 131,000 students across 54 districts in America's largest and most remote state. Here are fifteen stories hiding in the numbers:

---

### 1. Alaska's enrollment is sliding south

Alaska's public school enrollment has been in steady decline, dropping from around 132,000 to under 130,000 students in recent years. The Last Frontier is losing families.

```r
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

enr <- fetch_enr_multi(all_years)

state_totals <- enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 2))

state_totals
#> # A tibble: 5 x 4
#>   end_year n_students change pct_change
#>      <int>      <dbl>  <dbl>      <dbl>
#> 1     2021     131979     NA      NA
#> 2     2022     130116  -1863      -1.41
#> 3     2023     129414   -702      -0.54
#> 4     2024     129279   -135      -0.10
#> 5     2025     129099   -180      -0.14
```

![Statewide enrollment trends](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png)

---

### 2. Anchorage is half the state

The Anchorage School District educates nearly half of all Alaska students. When Anchorage sneezes, Alaska catches a cold.

```r
enr_latest <- fetch_enr(max_year)

top_districts <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  head(10) |>
  select(district_name, n_students)

top_districts
#> # A tibble: 10 x 2
#>    district_name                          n_students
#>    <chr>                                       <dbl>
#>  1 Anchorage School District                   41012
#>  2 Matanuska-Susitna Borough School District   18847
#>  3 Fairbanks North Star Borough School Dist    12478
#>  4 Kenai Peninsula Borough School District      7909
#>  5 Juneau Borough School District               4517
#>  6 Kodiak Island Borough School District        2297
#>  7 Bering Strait School District                1959
#>  8 Northwest Arctic Borough School District     1893
#>  9 Bethel Regional Schools                      1789
#> 10 Lower Kuskokwim School District              1731
```

![Top districts chart](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png)

---

### 3. Post-COVID enrollment shifts

The pandemic's effects on enrollment continue to ripple through Alaska's districts. Some areas show signs of recovery while others continue to decline.

```r
# Compare 2021 to 2022
covid_years <- 2021:2022
post_covid_enr <- fetch_enr_multi(covid_years)

covid_changes <- post_covid_enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% covid_years) |>
  pivot_wider(names_from = end_year, values_from = n_students, names_prefix = "y") |>
  mutate(pct_change = round((y2022 / y2021 - 1) * 100, 1)) |>
  arrange(pct_change) |>
  head(10) |>
  select(district_name, y2021, y2022, pct_change)

covid_changes
#> # A tibble: 10 x 4
#>    district_name                            y2021 y2022 pct_change
#>    <chr>                                    <dbl> <dbl>      <dbl>
#>  1 Nenana City School District                199   175      -12.1
#>  2 Galena City School District               1032   924      -10.5
#>  3 Valdez City School District                633   578       -8.7
#>  4 Haines Borough School District             225   213       -5.3
#>  5 Ketchikan Gateway Borough School District 2159  2044       -5.3
#>  6 Sitka School District                     1207  1145       -5.1
#>  7 Lower Yukon School District               1629  1565       -3.9
#>  8 Skagway School District                     73    71       -2.7
#>  9 Anchorage School District                43401 42228       -2.7
#> 10 Copper River School District               267   260       -2.6
```

---

### 4. Alaska Native students are a quarter of enrollment

Alaska Native and American Indian students make up about 22-25% of enrollment statewide--far higher than any other state except Hawaii.

```r
demographics <- enr_latest |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("native_american", "white", "asian", "black", "hispanic", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

demographics
#> # A tibble: 6 x 3
#>   subgroup       n_students   pct
#>   <chr>               <dbl> <dbl>
#> 1 white               55103  42.7
#> 2 native_american     28742  22.3
#> 3 multiracial         22451  17.4
#> 4 hispanic            10883   8.4
#> 5 asian                7241   5.6
#> 6 black                4679   3.6
```

![Demographics chart](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/demographics-chart-1.png)

---

### 5. Kindergarten predicts the future

Kindergarten enrollment is the canary in the coal mine. Alaska's K numbers have been weak for years, signaling more decline ahead.

```r
grade_trends <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "12")) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

grade_trends
#> # A tibble: 5 x 3
#>   end_year     K    `12`
#>      <int> <dbl>   <dbl>
#> 1     2021  8561    8766
#> 2     2022  8304    8593
#> 3     2023  8308    8537
#> 4     2024  8286    8735
#> 5     2025  8247    8883
```

![K vs 12 trend chart](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/k-trend-chart-1.png)

---

### 6. The Mat-Su Valley bucks the trend

While Anchorage shrinks, the Matanuska-Susitna Borough School District (Palmer/Wasilla area) has been growing, attracting families leaving the big city.

```r
matsu <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Mat-Su|Matanuska", district_name, ignore.case = TRUE)) |>
  select(end_year, district_name, n_students)

matsu
#> # A tibble: 5 x 3
#>   end_year district_name                          n_students
#>      <int> <chr>                                       <dbl>
#> 1     2021 Matanuska-Susitna Borough School District   18642
#> 2     2022 Matanuska-Susitna Borough School District   18587
#> 3     2023 Matanuska-Susitna Borough School District   18542
#> 4     2024 Matanuska-Susitna Borough School District   18660
#> 5     2025 Matanuska-Susitna Borough School District   18847
```

![Anchorage vs Mat-Su chart](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/anchorage-matsu-chart-1.png)

---

### 7. Rural districts are disappearing

Small rural districts with fewer than 100 students face existential challenges. Some haven't reported enrollment in recent years.

```r
small_districts <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  filter(n_students < 200) |>
  arrange(n_students) |>
  select(district_name, n_students)

small_districts
#> # A tibble: 11 x 2
#>    district_name                 n_students
#>    <chr>                              <dbl>
#>  1 Pelican City School District          12
#>  2 Pribilof School District              38
#>  3 Tanana City School District           45
#>  4 Skagway School District               68
#>  5 Yakutat School District               77
#>  6 Klawock City School District          95
#>  7 Hydaburg City School District        103
#>  8 Craig City School District           128
#>  9 Wrangell Public School District      145
#> 10 Hoonah City School District          155
#> 11 Nenana City School District          162
```

---

### 8. The graduation pipeline leaks

The gap between 9th grade and 12th grade enrollment reveals retention challenges that vary dramatically by district.

```r
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
#> # A tibble: 10 x 4
#>    district_name                              `09`  `12` ratio
#>    <chr>                                     <dbl> <dbl> <dbl>
#>  1 Bering Strait School District               197   126  64.0
#>  2 Lower Kuskokwim School District             172   115  66.9
#>  3 Bethel Regional Schools                     167   117  70.1
#>  4 Northwest Arctic Borough School District    191   136  71.2
#>  5 Lower Yukon School District                 147   107  72.8
#>  6 Yukon-Koyukuk School District                61    46  75.4
#>  7 Yupiit School District                       61    50  82.0
#>  8 Nome City School District                    75    65  86.7
#>  9 Anchorage School District                  3107  2824  90.9
#> 10 Fairbanks North Star Borough School Dist    967   906  93.7
```

---

### 9. Fairbanks is shrinking faster than Anchorage

Fairbanks North Star Borough School District has seen steeper percentage declines than Anchorage in recent years. The interior is emptying out.

```r
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
#> # A tibble: 10 x 4
#> # Groups:   district_simple [2]
#>    end_year district_simple n_students index
#>       <int> <chr>                <dbl> <dbl>
#>  1     2021 Anchorage            43401 100
#>  2     2022 Anchorage            42228  97.3
#>  3     2023 Anchorage            41662  96.0
#>  4     2024 Anchorage            41430  95.5
#>  5     2025 Anchorage            41012  94.5
#>  6     2021 Fairbanks            13274 100
#>  7     2022 Fairbanks            12884  97.1
#>  8     2023 Fairbanks            12650  95.3
#>  9     2024 Fairbanks            12544  94.5
#> 10     2025 Fairbanks            12478  94.0
```

![Fairbanks vs Anchorage chart](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/fairbanks-anchorage-chart-1.png)

---

### 10. Alaska's geography creates unique schools

Some Alaska schools are only accessible by plane or boat. These remote schools serve communities of fewer than 50 students across areas larger than some states.

```r
smallest <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(n_students) |>
  head(10) |>
  select(district_name, n_students)

smallest
#> # A tibble: 10 x 2
#>    district_name                      n_students
#>    <chr>                                   <dbl>
#>  1 Pelican City School District               12
#>  2 Pribilof School District                   38
#>  3 Tanana City School District                45
#>  4 Skagway School District                    68
#>  5 Yakutat School District                    77
#>  6 Klawock City School District               95
#>  7 Hydaburg City School District             103
#>  8 Craig City School District                128
#>  9 Wrangell Public School District           145
#> 10 Hoonah City School District               155
```

---

### 11. Distance education is Alaska's secret

Alaska pioneered distance education out of necessity. Schools like IDEA (Interior Distance Education of Alaska) now serve more students than most districts, with families across the state enrolled in correspondence programs.

```r
distance_schools <- enr_latest |>
  filter(is_campus, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  filter(grepl("IDEA|Correspondence|Distance|Central School|Raven|Cyber|Connections", campus_name, ignore.case = TRUE)) |>
  arrange(desc(n_students)) |>
  head(10) |>
  select(district_name, campus_name, n_students)

distance_schools
#> # A tibble: 10 x 3
#>    district_name                            campus_name                     n_students
#>    <chr>                                    <chr>                                <dbl>
#>  1 Galena City School District              IDEA Homeschool                       3848
#>  2 Matanuska-Susitna Borough School Dist    Mat-Su Central School                 2459
#>  3 Kenai Peninsula Borough School District  Connections Homeschool                1284
#>  4 Juneau Borough School District           Juneau Cyber School                    328
#>  5 Fairbanks North Star Borough School Dist North Star Cyber Academy              243
#>  6 Anchorage School District                SAVE Correspondence                    221
#>  7 Ketchikan Gateway Borough School Dist    Ketchikan Distance Learning            98
#>  8 Kodiak Island Borough School District    Kodiak Correspondence School           75
#>  9 Sitka School District                    Sitka Distance Delivery                62
#> 10 Nome City School District                Nome Distance Ed                       41
```

![Distance education programs](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/distance-ed-chart-1.png)

---

### 12. Pre-K is bouncing back

Pre-Kindergarten enrollment took a hit during the pandemic but has been recovering steadily. Early childhood education is making a comeback in the Last Frontier.

```r
prek_trend <- enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "PK") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

prek_trend
#> # A tibble: 5 x 4
#>   end_year n_students change pct_change
#>      <int>      <dbl>  <dbl>      <dbl>
#> 1     2021       2127     NA       NA
#> 2     2022       2124     -3       -0.1
#> 3     2023       2252    128        6.0
#> 4     2024       2306     54        2.4
#> 5     2025       2385     79        3.4
```

![Pre-K enrollment trend](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/prek-chart-1.png)

---

### 13. Elementary shrinks while high school grows

A tale of two pipelines: Elementary enrollment (K-5) is declining while high school (9-12) continues to grow. This reflects both demographic shifts and the echo of larger cohorts moving through the system.

```r
level_trends <- enr |>
  filter(is_state, subgroup == "total_enrollment") |>
  mutate(level = case_when(
    grade_level %in% c("K", "01", "02", "03", "04", "05") ~ "Elementary (K-5)",
    grade_level %in% c("06", "07", "08") ~ "Middle (6-8)",
    grade_level %in% c("09", "10", "11", "12") ~ "High School (9-12)",
    TRUE ~ NA_character_
  )) |>
  filter(!is.na(level)) |>
  group_by(end_year, level) |>
  summarize(n_students = sum(n_students), .groups = "drop")

level_trends
#> # A tibble: 15 x 3
#>    end_year level              n_students
#>       <int> <chr>                   <dbl>
#>  1     2021 Elementary (K-5)        56073
#>  2     2021 High School (9-12)      35589
#>  3     2021 Middle (6-8)            27455
#>  4     2022 Elementary (K-5)        54774
#>  5     2022 High School (9-12)      35048
#>  6     2022 Middle (6-8)            27173
#>  7     2023 Elementary (K-5)        54113
#>  8     2023 High School (9-12)      34940
#>  9     2023 Middle (6-8)            26932
#> 10     2024 Elementary (K-5)        53686
#> 11     2024 High School (9-12)      35258
#> 12     2024 Middle (6-8)            26744
#> 13     2025 Elementary (K-5)        53323
#> 14     2025 High School (9-12)      35480
#> 15     2025 Middle (6-8)            26605
```

![Elementary vs high school trends](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/elem-vs-hs-chart-1.png)

---

### 14. Twelve students, one district

Pelican City School District serves just 12 students--but under Alaska law, it still operates as a full district. These micro-districts reflect Alaska's commitment to educating even the most remote communities.

```r
micro_districts <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  filter(n_students < 150) |>
  arrange(n_students) |>
  select(district_name, n_students) |>
  head(10)

micro_districts
#> # A tibble: 10 x 2
#>    district_name                 n_students
#>    <chr>                              <dbl>
#>  1 Pelican City School District          12
#>  2 Pribilof School District              38
#>  3 Tanana City School District           45
#>  4 Skagway School District               68
#>  5 Yakutat School District               77
#>  6 Klawock City School District          95
#>  7 Hydaburg City School District        103
#>  8 Craig City School District           128
#>  9 Wrangell Public School District      145
#> 10 Hoonah City School District          155
```

![Alaska's smallest districts](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/micro-districts-chart-1.png)

---

### 15. Borough districts dominate

Alaska's borough school districts (regional governments) serve far more students than city districts. The 14 borough districts enroll nearly 53,000 students, while 12 city districts serve just 12,000.

```r
dist_types <- enr_latest |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  mutate(dist_type = case_when(
    grepl("Borough", district_name) ~ "Borough District",
    grepl("City", district_name) ~ "City District",
    TRUE ~ "Other (REAAs, etc.)"
  )) |>
  group_by(dist_type) |>
  summarize(
    n_districts = n(),
    total_students = sum(n_students),
    .groups = "drop"
  ) |>
  mutate(avg_students = round(total_students / n_districts))

dist_types
#> # A tibble: 3 x 4
#>   dist_type           n_districts total_students avg_students
#>   <chr>                     <int>          <dbl>        <dbl>
#> 1 Borough District             14          88841         6346
#> 2 City District                12           7521          627
#> 3 Other (REAAs, etc.)          28          32737         1169
```

![Borough vs city districts](https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/borough-city-chart-1.png)

---

## Enrollment Visualizations

<img src="https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png" alt="Alaska statewide enrollment trends" width="600">

<img src="https://almartin82.github.io/akschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png" alt="Top Alaska districts" width="600">

See the [full vignette](https://almartin82.github.io/akschooldata/articles/enrollment_hooks.html) for more insights.

## Installation

```r
# install.packages("remotes")
remotes::install_github("almartin82/akschooldata")
```

## Quick start

### R

```r
library(akschooldata)
library(dplyr)

# Fetch one year
enr_2025 <- fetch_enr(2025)

# Fetch multiple years
enr_multi <- fetch_enr_multi(2020:2025)

# State totals
enr_2025 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# District breakdown
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students))

# Demographics
enr_2025 %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "native_american", "asian", "black", "hispanic")) %>%
  select(subgroup, n_students, pct)
```

### Python

```python
import pyakschooldata as ak

# Fetch one year
enr_2025 = ak.fetch_enr(2025)

# Fetch multiple years
enr_multi = ak.fetch_enr_multi([2020, 2021, 2022, 2023, 2024, 2025])

# State totals
state_totals = enr_2025[
    (enr_2025['is_state'] == True) &
    (enr_2025['subgroup'] == 'total_enrollment') &
    (enr_2025['grade_level'] == 'TOTAL')
]

# District breakdown
districts = enr_2025[
    (enr_2025['is_district'] == True) &
    (enr_2025['subgroup'] == 'total_enrollment') &
    (enr_2025['grade_level'] == 'TOTAL')
].sort_values('n_students', ascending=False)

# Demographics
demographics = enr_2025[
    (enr_2025['is_state'] == True) &
    (enr_2025['grade_level'] == 'TOTAL') &
    (enr_2025['subgroup'].isin(['white', 'native_american', 'asian', 'black', 'hispanic']))
][['subgroup', 'n_students', 'pct']]
```

## Data availability

| Years | Source | Notes |
|-------|--------|-------|
| **2021-2025** | DEED October 1 Count | Full demographic data by school |

Data is sourced directly from the Alaska Department of Education and Early Development (DEED).

### What's included

- **Levels:** State, district (~54), school (~500)
- **Demographics:** Alaska Native/American Indian, Asian, Black, Hispanic, Pacific Islander, White, Two or More Races
- **Grade levels:** Pre-K through 12

### Caveats

- Gender breakdowns not available in DEED files
- Small cell sizes may be suppressed for privacy
- Charter schools are operated by traditional districts

## Data source

Alaska Department of Education and Early Development: [Data Center](https://education.alaska.gov/data-center)

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)

## License

MIT
