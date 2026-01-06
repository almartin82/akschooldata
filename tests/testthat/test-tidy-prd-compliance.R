# ==============================================================================
# PRD Compliance Tests for Tidy Output
# ==============================================================================
#
# These tests verify that fetch_enr(..., tidy=TRUE) output complies with
# the STATE_SCHOOLDATA_PRD.md specification.
#
# ==============================================================================

test_that("tidy output has all required PRD columns", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  required_cols <- c(
    "end_year", "district_id", "campus_id", "district_name", "campus_name",
    "type", "grade_level", "subgroup", "n_students", "pct"
  )

  expect_true(all(required_cols %in% names(data)),
              info = paste("Missing columns:",
                           paste(setdiff(required_cols, names(data)), collapse = ", ")))
})

test_that("tidy output has correct data types per PRD", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # IDs must be character to preserve leading zeros
  expect_true(is.character(data$district_id),
              info = "district_id must be character")
  expect_true(is.character(data$campus_id),
              info = "campus_id must be character")

  # Names must be character
  expect_true(is.character(data$district_name),
              info = "district_name must be character")
  expect_true(is.character(data$campus_name),
              info = "campus_name must be character")

  # Type must be character
  expect_true(is.character(data$type),
              info = "type must be character")

  # Grade level and subgroup must be character
  expect_true(is.character(data$grade_level),
              info = "grade_level must be character")
  expect_true(is.character(data$subgroup),
              info = "subgroup must be character")

  # n_students must be numeric
  expect_true(is.numeric(data$n_students),
              info = "n_students must be numeric")

  # pct must be numeric
  expect_true(is.numeric(data$pct),
              info = "pct must be numeric")
})

test_that("pct is on 0-1 scale, not 0-100", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  max_pct <- max(data$pct, na.rm = TRUE)
  min_pct <- min(data$pct, na.rm = TRUE)

  expect_true(max_pct <= 1,
              info = paste("pct max is", max_pct, "- should be <= 1 (0-1 scale)"))
  expect_true(min_pct >= 0,
              info = paste("pct min is", min_pct, "- should be >= 0"))
})

test_that("no NA values in core fields where data exists", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # n_students should never be NA
  expect_false(any(is.na(data$n_students)),
               info = "n_students should not have NA values")

  # pct should only be NA when row_total is 0
  # (Check: pct should be NA only for rows with n_students == 0)
  pct_na <- is.na(data$pct)
  if (any(pct_na)) {
    # If pct is NA, n_students should be 0
    expect_true(all(data$n_students[pct_na] == 0),
                info = "pct should only be NA when n_students is 0")
  }
})

test_that("type column contains only valid PRD values", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  valid_types <- c("State", "District", "Campus")
  actual_types <- unique(data$type)

  expect_true(all(actual_types %in% valid_types),
              info = paste("Invalid type values:",
                           paste(setdiff(actual_types, valid_types), collapse = ", ")))
})

test_that("grade_level contains standard PRD values", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expected_grades <- c("TOTAL", "PK", "K", "01", "02", "03", "04",
                       "05", "06", "07", "08", "09", "10", "11", "12")
  actual_grades <- unique(data$grade_level)

  # Check that all actual grades are in expected list
  unexpected <- setdiff(actual_grades, expected_grades)
  expect_true(length(unexpected) == 0,
              info = paste("Unexpected grade_level values:",
                           paste(unexpected, collapse = ", ")))
})

test_that("subgroup contains expected demographics", {
  skip_on_cran()

  data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expected_subgroups <- c(
    "total_enrollment", "white", "black", "hispanic", "asian",
    "native_american", "pacific_islander", "multiracial"
  )
  actual_subgroups <- unique(data$subgroup)

  # Check that expected subgroups are present (excluding gender/programs which AK doesn't have)
  expect_true(all(expected_subgroups %in% actual_subgroups),
              info = paste("Missing subgroups:",
                           paste(setdiff(expected_subgroups, actual_subgroups), collapse = ", ")))
})

test_that("tidy output maintains fidelity to wide format", {
  skip_on_cran()

  # Get both formats
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Check state total enrollment
  tidy_state_total <- tidy$n_students[
    tidy$type == "State" &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"
  ]

  wide_state_total <- wide$row_total[wide$type == "State"]

  expect_equal(length(tidy_state_total), 1,
               info = "Should have exactly one state total row")
  expect_equal(tidy_state_total, wide_state_total,
               info = "Tidy state total should match wide state total")
})
