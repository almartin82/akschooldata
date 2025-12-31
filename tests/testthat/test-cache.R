# Tests for cache functions

test_that("cache directory is created correctly", {
  cache_dir <- get_cache_dir()

  expect_true(is.character(cache_dir))
  expect_true(nchar(cache_dir) > 0)
  expect_true(grepl("akschooldata", cache_dir))
  expect_true(dir.exists(cache_dir))
})

test_that("cache path generation works", {
  path_2024_tidy <- get_cache_path(2024, "tidy")
  path_2024_wide <- get_cache_path(2024, "wide")
  path_2023_tidy <- get_cache_path(2023, "tidy")

  # Check correct filename patterns

  expect_true(grepl("enr_tidy_2024\\.rds$", path_2024_tidy))
  expect_true(grepl("enr_wide_2024\\.rds$", path_2024_wide))
  expect_true(grepl("enr_tidy_2023\\.rds$", path_2023_tidy))

  # Check different years have different paths
  expect_false(path_2024_tidy == path_2023_tidy)

  # Check different types have different paths
  expect_false(path_2024_tidy == path_2024_wide)
})

test_that("cache_exists returns FALSE for non-existent cache", {
  # Use an unlikely year
  expect_false(cache_exists(1900, "tidy"))
  expect_false(cache_exists(2100, "wide"))
})

test_that("cache roundtrip works", {
  skip_on_cran()

  # Create test data
  test_data <- data.frame(
    end_year = 9999,
    district_id = "TEST",
    value = 42,
    stringsAsFactors = FALSE
  )

  # Write to cache
  write_cache(test_data, 9999, "test")

  # Verify it exists
  expect_true(cache_exists(9999, "test"))

  # Read back
  read_data <- read_cache(9999, "test")

  # Compare
  expect_equal(test_data$end_year, read_data$end_year)
  expect_equal(test_data$district_id, read_data$district_id)
  expect_equal(test_data$value, read_data$value)

  # Clean up
  clear_cache(9999, "test")
  expect_false(cache_exists(9999, "test"))
})

test_that("clear_cache removes files", {
  skip_on_cran()

  # Create test cache files
  test_data <- data.frame(x = 1)
  write_cache(test_data, 9998, "tidy")
  write_cache(test_data, 9998, "wide")

  # Verify they exist
  expect_true(cache_exists(9998, "tidy"))
  expect_true(cache_exists(9998, "wide"))

  # Clear only tidy
  clear_cache(9998, "tidy")
  expect_false(cache_exists(9998, "tidy"))
  expect_true(cache_exists(9998, "wide"))

  # Clear remaining
  clear_cache(9998)
  expect_false(cache_exists(9998, "wide"))
})

test_that("cache_status runs without error", {
  skip_on_cran()

  # Should not error even if cache is empty
  expect_no_error(suppressMessages(cache_status()))
})
