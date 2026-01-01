# akschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/akschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/akschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/akschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/akschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/akschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/akschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Fetch and analyze Alaska school enrollment data from the Alaska Department of Education and Early Development (DEED) in R or Python.

**[Documentation](https://almartin82.github.io/akschooldata/)** | **[Getting Started](https://almartin82.github.io/akschooldata/articles/quickstart.html)**

## What can you find with akschooldata?

**7 years of enrollment data (2019-2025).** 131,000 students across 54 districts in America's largest and most remote state. Here are ten stories hiding in the numbers:

---

### 1. Alaska's enrollment is sliding south

Alaska's public school enrollment has been in steady decline, dropping from around 132,000 to under 130,000 students in recent years. The Last Frontier is losing families.

```r
library(akschooldata)
library(dplyr)

enr <- fetch_enr_multi(2019:2025)

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students))
```

---

### 2. Anchorage is half the state

The Anchorage School District educates nearly half of all Alaska students. When Anchorage sneezes, Alaska catches a cold.

```r
enr_2025 <- fetch_enr(2025)

enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(5) %>%
  select(district_name, n_students)
```

---

### 3. COVID hit bush Alaska differently

Remote villages with limited internet access faced unique pandemic challenges. Enrollment patterns diverged sharply between urban and rural districts.

```r
enr <- fetch_enr_multi(2019:2022)

enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% c(2020, 2021)) %>%
  tidyr::pivot_wider(names_from = end_year, values_from = n_students) %>%
  mutate(pct_change = round((`2021` / `2020` - 1) * 100, 1)) %>%
  arrange(pct_change) %>%
  head(10) %>%
  select(district_name, `2020`, `2021`, pct_change)
```

---

### 4. Alaska Native students are a quarter of enrollment

Alaska Native and American Indian students make up about 22-25% of enrollment statewide--far higher than any other state except Hawaii.

```r
enr_2025 %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("native_american", "white", "asian", "black", "hispanic", "multiracial")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(subgroup, n_students, pct) %>%
  arrange(desc(n_students))
```

---

### 5. Kindergarten predicts the future

Kindergarten enrollment is the canary in the coal mine. Alaska's K numbers have been weak for years, signaling more decline ahead.

```r
enr <- fetch_enr_multi(2019:2025)

enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "12")) %>%
  select(end_year, grade_level, n_students) %>%
  tidyr::pivot_wider(names_from = grade_level, values_from = n_students)
```

---

### 6. The Mat-Su Valley bucks the trend

While Anchorage shrinks, the Matanuska-Susitna Borough School District (Palmer/Wasilla area) has been growing, attracting families leaving the big city.

```r
enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Mat-Su|Matanuska", district_name, ignore.case = TRUE)) %>%
  select(end_year, district_name, n_students)
```

---

### 7. Rural districts are disappearing

Small rural districts with fewer than 100 students face existential challenges. Some haven't reported enrollment in recent years.

```r
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  filter(n_students < 200) %>%
  arrange(n_students) %>%
  select(district_name, n_students)
```

---

### 8. The graduation pipeline leaks

The gap between 9th grade and 12th grade enrollment reveals retention challenges that vary dramatically by district.

```r
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment",
         grade_level %in% c("09", "12")) %>%
  tidyr::pivot_wider(names_from = grade_level, values_from = n_students) %>%
  mutate(ratio = round(`12` / `09` * 100, 1)) %>%
  filter(`09` >= 50) %>%
  arrange(ratio) %>%
  head(10) %>%
  select(district_name, `09`, `12`, ratio)
```

---

### 9. Fairbanks is shrinking faster than Anchorage

Fairbanks North Star Borough School District has seen steeper percentage declines than Anchorage in recent years. The interior is emptying out.

```r
enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Fairbanks|Anchorage", district_name)) %>%
  group_by(district_name) %>%
  mutate(index = round(n_students / first(n_students) * 100, 1)) %>%
  select(end_year, district_name, n_students, index)
```

---

### 10. Alaska's geography creates unique schools

Some Alaska schools are only accessible by plane or boat. These remote schools serve communities of fewer than 50 students across areas larger than some states.

```r
# Smallest districts often serve isolated communities
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(n_students) %>%
  head(10) %>%
  select(district_name, n_students)
```

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
| **2019-2025** | DEED October 1 Count | Full demographic data by school |

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
