## ----setup, include=FALSE-----------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.height = 5,
  eval = NOT_CRAN
)

## ----load-packages------------------------------------------------------------
# library(akschooldata)
# library(dplyr)
# library(tidyr)
# library(ggplot2)
# 
# theme_set(theme_minimal(base_size = 14))

## ----statewide-trend----------------------------------------------------------
# enr <- fetch_enr_multi(2021:2025)
# 
# state_totals <- enr |>
#   filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
#   select(end_year, n_students) |>
#   mutate(change = n_students - lag(n_students),
#          pct_change = round(change / lag(n_students) * 100, 2))
# 
# state_totals

## ----statewide-chart----------------------------------------------------------
# ggplot(state_totals, aes(x = end_year, y = n_students)) +
#   geom_line(linewidth = 1.2, color = "#003366") +
#   geom_point(size = 3, color = "#003366") +
#   scale_y_continuous(labels = scales::comma) +
#   labs(
#     title = "Alaska Public School Enrollment (2021-2025)",
#     subtitle = "Steady decline as families leave the Last Frontier",
#     x = "School Year (ending)",
#     y = "Total Enrollment"
#   )

## ----top-districts------------------------------------------------------------
# enr_2025 <- fetch_enr(2025)
# 
# top_districts <- enr_2025 |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
#   arrange(desc(n_students)) |>
#   head(10) |>
#   select(district_name, n_students)
# 
# top_districts

## ----top-districts-chart------------------------------------------------------
# top_districts |>
#   mutate(district_name = forcats::fct_reorder(district_name, n_students)) |>
#   ggplot(aes(x = n_students, y = district_name, fill = district_name)) +
#   geom_col(show.legend = FALSE) +
#   geom_text(aes(label = scales::comma(n_students)), hjust = -0.1, size = 3.5) +
#   scale_x_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
#   scale_fill_viridis_d(option = "mako", begin = 0.2, end = 0.8) +
#   labs(
#     title = "Top 10 Alaska Districts by Enrollment (2025)",
#     subtitle = "Anchorage dominates with nearly half of all students",
#     x = "Number of Students",
#     y = NULL
#   )

## ----post-covid-impact--------------------------------------------------------
# post_covid_enr <- fetch_enr_multi(2021:2023)
#
# covid_changes <- post_covid_enr |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
#          end_year %in% c(2021, 2022)) |>
#   pivot_wider(names_from = end_year, values_from = n_students) |>
#   mutate(pct_change = round((`2022` / `2021` - 1) * 100, 1)) |>
#   arrange(pct_change) |>
#   head(10) |>
#   select(district_name, `2021`, `2022`, pct_change)
#
# covid_changes

## ----demographics-------------------------------------------------------------
# demographics <- enr_2025 |>
#   filter(is_state, grade_level == "TOTAL",
#          subgroup %in% c("native_american", "white", "asian", "black", "hispanic", "multiracial")) |>
#   mutate(pct = round(pct * 100, 1)) |>
#   select(subgroup, n_students, pct) |>
#   arrange(desc(n_students))
# 
# demographics

## ----demographics-chart-------------------------------------------------------
# demographics |>
#   mutate(subgroup = forcats::fct_reorder(subgroup, n_students)) |>
#   ggplot(aes(x = n_students, y = subgroup, fill = subgroup)) +
#   geom_col(show.legend = FALSE) +
#   geom_text(aes(label = paste0(pct, "%")), hjust = -0.1) +
#   scale_x_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
#   scale_fill_brewer(palette = "Set2") +
#   labs(
#     title = "Alaska Student Demographics (2025)",
#     subtitle = "Alaska Native students comprise a quarter of enrollment",
#     x = "Number of Students",
#     y = NULL
#   )

## ----k-vs-12------------------------------------------------------------------
# grade_trends <- enr |>
#   filter(is_state, subgroup == "total_enrollment",
#          grade_level %in% c("K", "12")) |>
#   select(end_year, grade_level, n_students) |>
#   pivot_wider(names_from = grade_level, values_from = n_students)
# 
# grade_trends

## ----k-trend-chart------------------------------------------------------------
# enr |>
#   filter(is_state, subgroup == "total_enrollment",
#          grade_level %in% c("K", "12")) |>
#   ggplot(aes(x = end_year, y = n_students, color = grade_level)) +
#   geom_line(linewidth = 1.2) +
#   geom_point(size = 2) +
#   scale_y_continuous(labels = scales::comma) +
#   scale_color_manual(values = c("K" = "#E69F00", "12" = "#56B4E9")) +
#   labs(
#     title = "Kindergarten vs 12th Grade Enrollment",
#     subtitle = "Weak kindergarten numbers signal continued decline",
#     x = "School Year",
#     y = "Enrollment",
#     color = "Grade"
#   )

## ----matsu-trend--------------------------------------------------------------
# matsu <- enr |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
#          grepl("Mat-Su|Matanuska", district_name, ignore.case = TRUE)) |>
#   select(end_year, district_name, n_students)
# 
# matsu

## ----anchorage-matsu-chart----------------------------------------------------
# enr |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
#          grepl("Mat-Su|Matanuska|Anchorage", district_name, ignore.case = TRUE)) |>
#   group_by(district_name) |>
#   mutate(index = round(n_students / first(n_students) * 100, 1)) |>
#   ggplot(aes(x = end_year, y = index, color = district_name)) +
#   geom_line(linewidth = 1.2) +
#   geom_point(size = 2) +
#   geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
#   labs(
#     title = "Anchorage vs Mat-Su: Diverging Paths",
#     subtitle = "Indexed to 2021 = 100",
#     x = "School Year",
#     y = "Enrollment Index",
#     color = "District"
#   )

## ----small-districts----------------------------------------------------------
# small_districts <- enr_2025 |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
#   filter(n_students < 200) |>
#   arrange(n_students) |>
#   select(district_name, n_students)
# 
# small_districts

## ----graduation-pipeline------------------------------------------------------
# pipeline <- enr_2025 |>
#   filter(is_district, subgroup == "total_enrollment",
#          grade_level %in% c("09", "12")) |>
#   pivot_wider(names_from = grade_level, values_from = n_students) |>
#   mutate(ratio = round(`12` / `09` * 100, 1)) |>
#   filter(`09` >= 50) |>
#   arrange(ratio) |>
#   head(10) |>
#   select(district_name, `09`, `12`, ratio)
# 
# pipeline

## ----fairbanks-anchorage------------------------------------------------------
# major_districts <- enr |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
#          grepl("Fairbanks|Anchorage", district_name)) |>
#   group_by(district_name) |>
#   mutate(index = round(n_students / first(n_students) * 100, 1)) |>
#   select(end_year, district_name, n_students, index)
# 
# major_districts

## ----fairbanks-anchorage-chart------------------------------------------------
# enr |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
#          grepl("Fairbanks|Anchorage", district_name)) |>
#   group_by(district_name) |>
#   mutate(index = round(n_students / first(n_students) * 100, 1)) |>
#   ggplot(aes(x = end_year, y = index, color = district_name)) +
#   geom_line(linewidth = 1.2) +
#   geom_point(size = 2) +
#   geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
#   scale_color_manual(values = c("#003366", "#CC5500")) +
#   labs(
#     title = "Fairbanks vs Anchorage: Who's Shrinking Faster?",
#     subtitle = "Indexed to 2021 = 100",
#     x = "School Year",
#     y = "Enrollment Index",
#     color = "District"
#   )

## ----smallest-districts-------------------------------------------------------
# smallest <- enr_2025 |>
#   filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
#   arrange(n_students) |>
#   head(10) |>
#   select(district_name, n_students)
# 
# smallest

