# Tests for enrollment functions
# Note: Most tests are marked as skip_on_cran since they require network access
#
# IMPORTANT: This package uses ONLY Alaska DEED data sources.
# No federal data sources (NCES, Urban Institute, etc.) are used.

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

test_that("get_available_years returns valid range for DEED data", {
  years <- get_available_years()

  expect_true(is.list(years))
  expect_true("min_year" %in% names(years))
  expect_true("max_year" %in% names(years))
  expect_true(years$min_year < years$max_year)

  # DEED data available 2021-2025
  # (2019-2020 files no longer available on DEED website)
  expect_equal(years$min_year, 2021)
  expect_equal(years$max_year, 2025)

  # Should have description mentioning DEED
  expect_true(grepl("DEED", years$description))
})

test_that("fetch_enr validates year parameter", {
  expect_error(fetch_enr(2018), "end_year must be between")
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

test_that("build_deed_enrollment_url constructs valid URLs", {
  url_grade <- build_deed_enrollment_url(2024, "grade")
  expect_true(grepl("education.alaska.gov", url_grade))
  expect_true(grepl("2023-24", url_grade))
  expect_true(grepl("Enrollment%20by%20School%20by%20Grade", url_grade))

  url_ethnicity <- build_deed_enrollment_url(2024, "ethnicity")
  expect_true(grepl("education.alaska.gov", url_ethnicity))
  expect_true(grepl("ethnicity", url_ethnicity))

  expect_error(build_deed_enrollment_url(2024, "invalid"))
})

test_that("normalize_deed_colnames standardizes column names", {
  # Test grade columns
  expect_equal(normalize_deed_colnames("PK"), "grade_pk")
  expect_equal(normalize_deed_colnames("K"), "grade_k")
  expect_equal(normalize_deed_colnames("1"), "grade_01")
  expect_equal(normalize_deed_colnames("12"), "grade_12")

  # Test ethnicity columns
  result <- normalize_deed_colnames("American Indian/Alaska Native")
  expect_true(grepl("native_american", result))

  # Test total column
  expect_equal(normalize_deed_colnames("Total"), "row_total")

  # Test district/school names
  expect_equal(normalize_deed_colnames("District"), "district_name")
  expect_equal(normalize_deed_colnames("School"), "school_name")
})

# Integration tests (require network access)
test_that("fetch_enr downloads and processes DEED data", {
  skip_on_cran()
  skip_if_offline()

  # Use a year within DEED range
  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("district_name" %in% names(result))
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
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

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
  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

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

  # Fetch two years within DEED range
  result <- fetch_enr_multi(c(2023, 2024), tidy = TRUE, use_cache = TRUE)

  expect_true(is.data.frame(result))
  expect_true(all(c(2023, 2024) %in% unique(result$end_year)))
})

test_that("process_enr creates state aggregate", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Should have exactly one state row
  state_rows <- result[result$type == "State", ]
  expect_equal(nrow(state_rows), 1)
  expect_equal(state_rows$district_name, "Alaska")
})


# ==============================================================================
# Comprehensive Data Fidelity Tests
# ==============================================================================
# These tests verify that tidy=TRUE output maintains fidelity to raw data

test_that("all available years can be fetched successfully", {
  skip_on_cran()
  skip_if_offline()

  years <- get_available_years()

  for (yr in years$min_year:years$max_year) {
    result <- tryCatch(
      fetch_enr(yr, tidy = FALSE, use_cache = TRUE),
      error = function(e) NULL
    )

    expect_true(!is.null(result), info = paste("Year", yr, "should fetch successfully"))
    expect_true(nrow(result) > 0, info = paste("Year", yr, "should have data"))
    expect_true("State" %in% result$type, info = paste("Year", yr, "should have state row"))
    expect_true("District" %in% result$type, info = paste("Year", yr, "should have districts"))
    expect_true("Campus" %in% result$type, info = paste("Year", yr, "should have schools"))
  }
})

test_that("tidy data includes all expected ethnicity subgroups", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Expected ethnicity subgroups
  expected_subgroups <- c(
    "total_enrollment",
    "white", "black", "hispanic", "asian",
    "native_american", "pacific_islander", "multiracial"
  )

  actual_subgroups <- unique(result$subgroup)

  for (sg in expected_subgroups) {
    expect_true(sg %in% actual_subgroups,
                info = paste("Subgroup", sg, "should be present"))
  }
})

test_that("tidy data includes all grade levels", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Expected grade levels (for total_enrollment subgroup)
  expected_grades <- c("TOTAL", "PK", "K", "01", "02", "03", "04", "05",
                       "06", "07", "08", "09", "10", "11", "12")

  total_enr <- result[result$subgroup == "total_enrollment", ]
  actual_grades <- unique(total_enr$grade_level)

  for (gr in expected_grades) {
    expect_true(gr %in% actual_grades,
                info = paste("Grade level", gr, "should be present"))
  }
})

test_that("enrollment counts are non-negative", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # All n_students values should be >= 0
  negative_counts <- sum(result$n_students < 0, na.rm = TRUE)
  expect_equal(negative_counts, 0, info = "No negative enrollment counts allowed")
})

test_that("no Inf or NaN values in percentages", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Check for Inf
  inf_count <- sum(is.infinite(result$pct), na.rm = TRUE)
  expect_equal(inf_count, 0, info = "No Inf values in percentages")

  # Check for NaN
  nan_count <- sum(is.nan(result$pct), na.rm = TRUE)
  expect_equal(nan_count, 0, info = "No NaN values in percentages")
})

test_that("state total equals sum of district totals (approximately)", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  state_total <- result$row_total[result$type == "State"]
  district_sum <- sum(result$row_total[result$type == "District"], na.rm = TRUE)

  # Allow 1% tolerance for rounding differences
  tolerance <- 0.01 * state_total
  difference <- abs(state_total - district_sum)

  expect_true(difference < tolerance,
              info = paste("State total", state_total, "should match district sum",
                          district_sum, "(diff:", difference, ")"))
})

test_that("ethnicity counts sum to approximately total enrollment", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # For each entity at TOTAL grade level, ethnicity sums should match total
  ethnicity_cols <- c("white", "black", "hispanic", "asian",
                      "native_american", "pacific_islander", "multiracial")

  state_data <- result[result$is_state & result$grade_level == "TOTAL", ]

  state_total <- state_data$n_students[state_data$subgroup == "total_enrollment"]
  eth_sum <- sum(state_data$n_students[state_data$subgroup %in% ethnicity_cols], na.rm = TRUE)

  # Allow 5% tolerance (some students may not report ethnicity)
  tolerance <- 0.05 * state_total
  difference <- abs(state_total - eth_sum)

  expect_true(difference < tolerance,
              info = paste("State ethnicity sum", eth_sum,
                          "should be close to total", state_total))
})

test_that("tidy format preserves raw enrollment counts exactly", {
  skip_on_cran()
  skip_if_offline()

  # Get both wide and tidy formats
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # State row comparison
  wide_state <- wide[wide$type == "State", ]
  tidy_state <- tidy[tidy$is_state & tidy$subgroup == "total_enrollment" &
                     tidy$grade_level == "TOTAL", ]

  expect_equal(wide_state$row_total, tidy_state$n_students,
               info = "State total should match between wide and tidy")

  # Check a specific ethnicity
  if ("white" %in% names(wide_state)) {
    tidy_white <- tidy[tidy$is_state & tidy$subgroup == "white" &
                       tidy$grade_level == "TOTAL", ]
    expect_equal(wide_state$white, tidy_white$n_students,
                 info = "White enrollment should match between wide and tidy")
  }
})

test_that("reasonable state enrollment totals across years", {
  skip_on_cran()
  skip_if_offline()

  # Alaska state enrollment should be between 100,000 and 150,000
  min_expected <- 100000
  max_expected <- 150000

  for (yr in 2021:2025) {
    result <- tryCatch(
      fetch_enr(yr, tidy = FALSE, use_cache = TRUE),
      error = function(e) NULL
    )

    if (!is.null(result)) {
      state_total <- result$row_total[result$type == "State"]
      expect_true(state_total >= min_expected && state_total <= max_expected,
                  info = paste("Year", yr, "state total", state_total,
                              "should be between", min_expected, "and", max_expected))
    }
  }
})

test_that("no impossible zero values for large districts", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Anchorage should have non-zero enrollment for all ethnicities
  anchorage <- result[grepl("Anchorage", result$district_name) &
                      result$type == "District", ]

  if (nrow(anchorage) > 0) {
    # Large districts should have students in all major ethnic groups
    expect_true(anchorage$white > 0, info = "Anchorage should have white students")
    expect_true(anchorage$native_american > 0,
                info = "Anchorage should have Native American students")
    expect_true(anchorage$asian > 0, info = "Anchorage should have Asian students")
  }
})
