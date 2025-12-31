# Tests for enrollment functions
# Note: Most tests are marked as skip_on_cran since they require network access

test_that("safe_numeric handles various inputs", {
  # Normal numbers
  expect_equal(safe_numeric("100"), 100)
  expect_equal(safe_numeric("1,234"), 1234)

  # Suppressed values
  expect_true(is.na(safe_numeric("*")))
  expect_true(is.na(safe_numeric("-1")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("")))
  expect_true(is.na(safe_numeric("N/A")))
  expect_true(is.na(safe_numeric("n/a")))
  expect_true(is.na(safe_numeric("**")))

  # Whitespace handling
  expect_equal(safe_numeric("  100  "), 100)
})

test_that("get_available_years returns valid range", {
  years <- get_available_years()

  expect_true(is.list(years))
  expect_true("min_year" %in% names(years))
  expect_true("max_year" %in% names(years))
  expect_true(years$min_year < years$max_year)
  expect_equal(years$min_year, 1997)
  expect_true(years$max_year >= 2024)
})

test_that("fetch_enr validates year parameter", {
  expect_error(fetch_enr(1990), "end_year must be between")
  expect_error(fetch_enr(2050), "end_year must be between")
})

test_that("get_ak_districts returns valid data", {
  districts <- get_ak_districts()

  expect_true(is.data.frame(districts))
  expect_true("district_id" %in% names(districts))
  expect_true("district_name" %in% names(districts))
  expect_true(nrow(districts) >= 50)  # Alaska has ~54 districts

  # Check for known districts
  expect_true(any(grepl("Anchorage", districts$district_name)))
  expect_true(any(grepl("Fairbanks", districts$district_name)))
  expect_true(any(grepl("Juneau", districts$district_name)))
})

test_that("get_cache_dir returns valid path", {
  cache_dir <- get_cache_dir()
  expect_true(is.character(cache_dir))
  expect_true(grepl("akschooldata", cache_dir))
})

test_that("cache functions work correctly", {
  # Test cache path generation
  path <- get_cache_path(2024, "tidy")
  expect_true(grepl("enr_tidy_2024.rds", path))

  # Test cache_exists returns FALSE for non-existent cache
  # (Assuming no cache exists for year 9999)
  expect_false(cache_exists(9999, "tidy"))
})

test_that("build_deed_url constructs valid URLs", {
  url <- build_deed_url(2018, "ethnicity")
  expect_true(grepl("education.alaska.gov", url))
  expect_true(grepl("2018", url))
  expect_true(grepl("School_Ethnicity_Report.pdf", url))

  url_adm <- build_deed_url(2024, "adm")
  expect_true(grepl("ADM.pdf", url_adm))
})

test_that("create_ak_enrollment_template returns valid structure", {
  # District template
  dist_df <- create_ak_enrollment_template(2024, "district")
  expect_true(is.data.frame(dist_df))
  expect_true("FIPST" %in% names(dist_df))
  expect_true("LEAID" %in% names(dist_df))
  expect_true("LEA_NAME" %in% names(dist_df))
  expect_true("TOTAL" %in% names(dist_df))

  # School template
  school_df <- create_ak_enrollment_template(2024, "school")
  expect_true(is.data.frame(school_df))
  expect_true("SCHID" %in% names(school_df))
  expect_true("SCH_NAME" %in% names(school_df))
  expect_true(nrow(school_df) > nrow(dist_df))  # More schools than districts
})

# Integration tests (require network access)
test_that("fetch_enr downloads and processes data", {
  skip_on_cran()
  skip_if_offline()

  # Use a recent year
  result <- fetch_enr(2023, tidy = FALSE, use_cache = FALSE)

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("district_id" %in% names(result))
  expect_true("campus_id" %in% names(result))
  expect_true("type" %in% names(result))

  # Check we have all levels
  expect_true("State" %in% result$type)
  expect_true("District" %in% result$type)
  expect_true("Campus" %in% result$type)
})

test_that("tidy_enr produces correct long format", {
  skip_on_cran()
  skip_if_offline()

  # Get wide data
  wide <- fetch_enr(2023, tidy = FALSE, use_cache = TRUE)

  # Tidy it
  tidy_result <- tidy_enr(wide)

  # Check structure
  expect_true("grade_level" %in% names(tidy_result))
  expect_true("subgroup" %in% names(tidy_result))
  expect_true("n_students" %in% names(tidy_result))
  expect_true("pct" %in% names(tidy_result))

  # Check subgroups include expected values
  subgroups <- unique(tidy_result$subgroup)
  expect_true("total_enrollment" %in% subgroups)
})

test_that("id_enr_aggs adds correct flags", {
  skip_on_cran()
  skip_if_offline()

  # Get tidy data with aggregation flags
  result <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)

  # Check flags exist
  expect_true("is_state" %in% names(result))
  expect_true("is_district" %in% names(result))
  expect_true("is_campus" %in% names(result))
  expect_true("is_charter" %in% names(result))

  # Check flags are boolean
  expect_true(is.logical(result$is_state))
  expect_true(is.logical(result$is_district))
  expect_true(is.logical(result$is_campus))
  expect_true(is.logical(result$is_charter))

  # Check mutual exclusivity (each row is only one type)
  type_sums <- result$is_state + result$is_district + result$is_campus
  expect_true(all(type_sums == 1))
})

test_that("fetch_enr_multi handles multiple years", {
  skip_on_cran()
  skip_if_offline()

  # Fetch two years
  result <- fetch_enr_multi(c(2022, 2023), tidy = TRUE, use_cache = TRUE)

  expect_true(is.data.frame(result))
  expect_true(all(c(2022, 2023) %in% unique(result$end_year)))
})

test_that("process_enr creates state aggregate", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2023, tidy = FALSE, use_cache = TRUE)

  # Should have exactly one state row
  state_rows <- result[result$type == "State", ]
  expect_equal(nrow(state_rows), 1)
  expect_equal(state_rows$district_name, "Alaska")
})
