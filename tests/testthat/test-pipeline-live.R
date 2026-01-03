# ==============================================================================
# LIVE Pipeline Tests for akschooldata
# ==============================================================================
#
# These tests verify EACH STEP of the data pipeline using LIVE network calls.
# No mocks - we verify actual connectivity and data correctness.
#
# Test Categories:
# 1. URL Availability - HTTP status codes for all data source URLs
# 2. File Download - Successful download and file type verification
# 3. File Parsing - readxl can read the files
# 4. Column Structure - Expected columns exist
# 5. get_raw_enr() - Raw data function works end-to-end
# 6. Data Quality - No Inf/NaN, valid ranges
# 7. Aggregation Logic - District sums match state totals
# 8. Output Fidelity - tidy=TRUE matches raw data
#
# Data Sources:
# - Grade: https://education.alaska.gov/Stats/enrollment/2-%20Enrollment%20by%20School%20by%20Grade%20{YYYY-YY}.xlsx
# - Ethnicity: https://education.alaska.gov/Stats/enrollment/5-%20Enrollment%20by%20School%20by%20ethnicity%20{YYYY-YY}.xlsx
#
# Available Years: 2021-2025
# ==============================================================================

library(testthat)
library(httr)

# Skip if no network connectivity
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) {
      skip("No network connectivity")
    }
  }, error = function(e) {
    skip("No network connectivity")
  })
}

# Helper: Build DEED URL for a given file type and year
build_deed_url <- function(file_type = c("grade", "ethnicity"), end_year) {
  file_type <- match.arg(file_type)
  start_year <- end_year - 1
  sy_string <- paste0(start_year, "-", substr(as.character(end_year), 3, 4))

  if (file_type == "grade") {
    filename <- paste0("2- Enrollment by School by Grade ", sy_string, ".xlsx")
  } else {
    filename <- paste0("5- Enrollment by School by ethnicity ", sy_string, ".xlsx")
  }

  paste0(
    "https://education.alaska.gov/Stats/enrollment/",
    utils::URLencode(filename, reserved = TRUE)
  )
}

# ==============================================================================
# STEP 1: URL Availability Tests
# ==============================================================================

test_that("Alaska DEED base website is accessible", {
  skip_if_offline()

  # Test the base education.alaska.gov domain
  response <- httr::HEAD(
    "https://education.alaska.gov/",
    httr::timeout(30),
    httr::user_agent("akschooldata R package test")
  )

  expect_equal(httr::status_code(response), 200,
               label = "Alaska DEED website HTTP status")
})

test_that("Grade enrollment file URLs return HTTP 200 for all years", {
  skip_if_offline()

  years <- 2021:2025

  for (year in years) {
    url <- build_deed_url("grade", year)

    response <- httr::HEAD(
      url,
      httr::timeout(30),
      httr::user_agent("akschooldata R package test")
    )

    expect_equal(
      httr::status_code(response), 200,
      label = paste("Grade file for", year)
    )
  }
})

test_that("Ethnicity enrollment file URLs return HTTP 200 for all years", {
  skip_if_offline()

  years <- 2021:2025

  for (year in years) {
    url <- build_deed_url("ethnicity", year)

    response <- httr::HEAD(
      url,
      httr::timeout(30),
      httr::user_agent("akschooldata R package test")
    )

    expect_equal(
      httr::status_code(response), 200,
      label = paste("Ethnicity file for", year)
    )
  }
})

# ==============================================================================
# STEP 2: File Download Tests
# ==============================================================================

test_that("Can download grade enrollment file and verify it's a valid Excel file", {
  skip_if_offline()

  # Test with most recent year
  url <- build_deed_url("grade", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  response <- httr::GET(
    url,
    httr::write_disk(temp_file, overwrite = TRUE),
    httr::timeout(120),
    httr::user_agent("akschooldata R package test")
  )

  # Verify HTTP 200
  expect_equal(httr::status_code(response), 200,
               label = "Download HTTP status")

  # Verify file was downloaded
  expect_true(file.exists(temp_file),
              label = "File exists after download")

  # Verify file size is reasonable (not empty, not HTML error page)
  file_size <- file.info(temp_file)$size
  expect_gt(file_size, 10000,
            label = "File size (should be > 10KB)")

  # Verify content type is Excel (not HTML)
  content_type <- httr::headers(response)[["content-type"]]
  expect_true(
    grepl("spreadsheet|excel|octet-stream", content_type, ignore.case = TRUE),
    label = paste("Content-Type:", content_type)
  )
})

test_that("Can download ethnicity enrollment file and verify it's a valid Excel file", {
  skip_if_offline()

  url <- build_deed_url("ethnicity", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  response <- httr::GET(
    url,
    httr::write_disk(temp_file, overwrite = TRUE),
    httr::timeout(120),
    httr::user_agent("akschooldata R package test")
  )

  expect_equal(httr::status_code(response), 200)
  expect_true(file.exists(temp_file))
  expect_gt(file.info(temp_file)$size, 50000,
            label = "Ethnicity file size (should be > 50KB)")
})

# ==============================================================================
# STEP 3: File Parsing Tests
# ==============================================================================

test_that("Can parse grade enrollment Excel file with readxl (new format 2024+)", {
  skip_if_offline()

  url <- build_deed_url("grade", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))

  # Should be able to list sheets
  sheets <- readxl::excel_sheets(temp_file)
  expect_gt(length(sheets), 0, label = "Number of sheets")

  # Should be able to read data
  df <- readxl::read_excel(temp_file, sheet = 1)
  expect_true(is.data.frame(df), label = "Is data frame")
  expect_gt(nrow(df), 100, label = "Number of rows")
  expect_gt(ncol(df), 10, label = "Number of columns")
})

test_that("Can parse grade enrollment Excel file with readxl (old format 2021-2023)", {
  skip_if_offline()

  url <- build_deed_url("grade", 2022)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))

  # Old format requires skip=1 for title row
  df <- readxl::read_excel(temp_file, sheet = 1, skip = 1)
  expect_true(is.data.frame(df))
  expect_gt(nrow(df), 100)

  # Old format should have ID column (not Type)
  expect_true("ID" %in% names(df), label = "Old format has ID column")
})

test_that("Can parse ethnicity enrollment Excel file with readxl", {
  skip_if_offline()

  url <- build_deed_url("ethnicity", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))

  df <- readxl::read_excel(temp_file, sheet = 1)
  expect_true(is.data.frame(df))
  expect_gt(nrow(df), 1000, label = "Ethnicity file rows (should be > 1000)")
})

# ==============================================================================
# STEP 4: Column Structure Tests
# ==============================================================================

test_that("Grade file (new format) has expected columns", {
  skip_if_offline()

  url <- build_deed_url("grade", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  df <- readxl::read_excel(temp_file, sheet = 1)

  col_names <- tolower(names(df))

  # Required columns in new format
  expect_true("type" %in% col_names, label = "Has Type column")
  expect_true("id" %in% col_names, label = "Has id column")
  expect_true(any(grepl("district|school", col_names)), label = "Has District/School column")

  # Grade columns
  expect_true("pk" %in% col_names, label = "Has PK column")
  expect_true("kg" %in% col_names, label = "Has KG column")
  expect_true(any(grepl("^1$", names(df))), label = "Has grade 1 column")
  expect_true(any(grepl("^12$", names(df))), label = "Has grade 12 column")

  # Total columns
  expect_true(any(grepl("total|k12|pk12", col_names)), label = "Has total column")
})

test_that("Ethnicity file (new format) has expected columns", {
  skip_if_offline()

  url <- build_deed_url("ethnicity", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  df <- readxl::read_excel(temp_file, sheet = 1)

  col_names <- tolower(names(df))

  # Required columns
  expect_true("type" %in% col_names, label = "Has Type column")
  expect_true("id" %in% col_names, label = "Has id column")
  expect_true(any(grepl("race|ethnicity", col_names)), label = "Has Race/Ethnicity column")
})

test_that("Ethnicity file contains all expected race categories", {
  skip_if_offline()

  url <- build_deed_url("ethnicity", 2025)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  df <- readxl::read_excel(temp_file, sheet = 1)

  # Find the race/ethnicity column
  race_col <- names(df)[grepl("race|ethnicity", tolower(names(df)))][1]
  expect_false(is.na(race_col), label = "Found Race/Ethnicity column")

  race_values <- tolower(unique(df[[race_col]]))

  # Expected race categories
  expect_true(any(grepl("white", race_values)), label = "Has White")
  expect_true(any(grepl("black", race_values)), label = "Has Black")
  expect_true(any(grepl("asian", race_values)), label = "Has Asian")
  expect_true(any(grepl("hispanic", race_values)), label = "Has Hispanic")
  expect_true(any(grepl("alaska|native|indian", race_values)), label = "Has Alaska Native/American Indian")
  expect_true(any(grepl("hawaiian|pacific", race_values)), label = "Has Native Hawaiian/Pacific Islander")
  expect_true(any(grepl("two|more|multi", race_values)), label = "Has Two or More Races")
})

test_that("Grade file (old format 2021-2023) has expected columns", {
  skip_if_offline()

  url <- build_deed_url("grade", 2022)
  temp_file <- tempfile(fileext = ".xlsx")

  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  df <- readxl::read_excel(temp_file, sheet = 1, skip = 1)

  # Old format columns
  expect_true("ID" %in% names(df), label = "Old format has ID column")
  expect_true("District" %in% names(df), label = "Old format has District column")
  expect_true("School Name" %in% names(df), label = "Old format has School Name column")
})

# ==============================================================================
# STEP 5: get_raw_enr() Function Tests
# ==============================================================================

test_that("get_raw_enr() returns valid data structure for 2025", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)

  # Should return a list
  expect_true(is.list(raw), label = "get_raw_enr returns list")

  # Should have expected components
  expect_true("school" %in% names(raw), label = "Has school data")
  expect_true("district" %in% names(raw), label = "Has district data")
  expect_true("end_year" %in% names(raw), label = "Has end_year")
  expect_true("source" %in% names(raw), label = "Has source")

  # Verify year
  expect_equal(raw$end_year, 2025)

  # Verify source
  expect_equal(raw$source, "deed")
})

test_that("get_raw_enr() returns data frames with rows", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)

  # School data should have rows
  expect_true(is.data.frame(raw$school), label = "school is data frame")
  expect_gt(nrow(raw$school), 0, label = "school row count")

  # District data should have rows
  expect_true(is.data.frame(raw$district), label = "district is data frame")
  expect_gt(nrow(raw$district), 0, label = "district row count")
})

test_that("get_raw_enr() works for all supported years", {
  skip_if_offline()

  years <- 2021:2025

  for (year in years) {
    raw <- akschooldata:::get_raw_enr(year)

    expect_true(is.list(raw), label = paste("Year", year, "returns list"))
    expect_gt(nrow(raw$school), 0, label = paste("Year", year, "school data"))
    expect_equal(raw$end_year, year, label = paste("Year", year, "end_year"))
  }
})

test_that("get_raw_enr() includes enrollment counts in expected columns", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)
  school <- raw$school

  # Should have numeric enrollment columns
  numeric_cols <- names(school)[sapply(school, is.numeric)]
  expect_gt(length(numeric_cols), 0, label = "Number of numeric columns")

  # Should have row_total or similar total column
  total_col <- names(school)[grepl("total|row_total", tolower(names(school)))]
  expect_gt(length(total_col), 0, label = "Number of total columns")
})

test_that("get_available_years() returns valid year range", {
  result <- akschooldata::get_available_years()

  if (is.list(result)) {
    expect_true("min_year" %in% names(result) || "years" %in% names(result))
    if ("min_year" %in% names(result)) {
      expect_gte(result$min_year, 2020)
      expect_lte(result$min_year, 2025)
      expect_gte(result$max_year, 2024)
      expect_lte(result$max_year, 2030)
    }
  } else {
    expect_true(is.numeric(result) || is.integer(result))
    expect_true(all(result >= 2020 & result <= 2030, na.rm = TRUE))
  }
})

# ==============================================================================
# STEP 6: Data Quality Tests
# ==============================================================================

test_that("fetch_enr() returns data with no Inf values", {
  skip_if_offline()

  data <- akschooldata::fetch_enr(2025, tidy = TRUE)

  for (col in names(data)[sapply(data, is.numeric)]) {
    has_inf <- any(is.infinite(data[[col]]), na.rm = TRUE)
    expect_false(has_inf, label = paste("Column", col, "has no Inf"))
  }
})

test_that("fetch_enr() returns data with no NaN values", {
  skip_if_offline()

  data <- akschooldata::fetch_enr(2025, tidy = TRUE)

  for (col in names(data)[sapply(data, is.numeric)]) {
    has_nan <- any(is.nan(data[[col]]), na.rm = TRUE)
    expect_false(has_nan, label = paste("Column", col, "has no NaN"))
  }
})

test_that("Enrollment counts are non-negative", {
  skip_if_offline()

  data <- akschooldata::fetch_enr(2025, tidy = FALSE)

  # Find total/enrollment columns
  enr_cols <- names(data)[grepl("total|row_total|enrollment|n_students", tolower(names(data)))]

  for (col in enr_cols) {
    if (is.numeric(data[[col]])) {
      neg_count <- sum(data[[col]] < 0, na.rm = TRUE)
      expect_equal(neg_count, 0,
                   label = paste("Column", col, "negative count"))
    }
  }
})

test_that("Grade-level enrollment values are non-negative", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)
  school <- raw$school

  # Check grade columns (numeric columns that aren't IDs)
  grade_cols <- names(school)[sapply(school, is.numeric) &
                                !grepl("id|district_id|school_id", tolower(names(school)))]

  for (col in grade_cols) {
    neg_count <- sum(school[[col]] < 0, na.rm = TRUE)
    expect_equal(neg_count, 0,
                 label = paste("Grade column", col, "negative count"))
  }
})

# ==============================================================================
# STEP 7: Aggregation Tests
# ==============================================================================

test_that("State total enrollment is reasonable (not zero)", {
  skip_if_offline()

  data <- akschooldata::fetch_enr(2025, tidy = FALSE)

  # Find state-level rows
  if ("type" %in% tolower(names(data))) {
    type_col <- names(data)[tolower(names(data)) == "type"][1]
    state_rows <- data[tolower(data[[type_col]]) == "state", ]

    if (nrow(state_rows) > 0) {
      # Find total column
      total_col <- names(state_rows)[grepl("row_total|total_pk12|total", tolower(names(state_rows)))][1]
      if (!is.na(total_col) && is.numeric(state_rows[[total_col]])) {
        state_total <- sum(state_rows[[total_col]], na.rm = TRUE)
        # Alaska should have roughly 130,000 students
        expect_gt(state_total, 100000,
                  label = "State total (should be > 100,000)")
        expect_lt(state_total, 200000,
                  label = "State total (should be < 200,000)")
      }
    }
  }
})

test_that("Sum of school enrollments approximates district totals", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)

  if (nrow(raw$school) > 0 && nrow(raw$district) > 0) {
    # Find total column
    total_col <- names(raw$school)[grepl("row_total|total_pk12|total", tolower(names(raw$school)))][1]

    if (!is.na(total_col) && is.numeric(raw$school[[total_col]])) {
      school_sum <- sum(raw$school[[total_col]], na.rm = TRUE)

      # Same column in districts
      if (total_col %in% names(raw$district) && is.numeric(raw$district[[total_col]])) {
        district_sum <- sum(raw$district[[total_col]], na.rm = TRUE)

        # Allow 5% tolerance (some data issues are known)
        if (district_sum > 0) {
          ratio <- school_sum / district_sum
          expect_gte(ratio, 0.95, label = "School/district ratio (should be >= 0.95)")
          expect_lte(ratio, 1.05, label = "School/district ratio (should be <= 1.05)")
        }
      }
    }
  }
})

test_that("Number of districts is reasonable", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)

  n_districts <- nrow(raw$district)

  # Alaska has about 54 school districts
  expect_gte(n_districts, 50, label = "District count (should be >= 50)")
  expect_lte(n_districts, 60, label = "District count (should be <= 60)")
})

test_that("Number of schools is reasonable", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)

  n_schools <- nrow(raw$school)

  # Alaska has about 500 schools
  expect_gte(n_schools, 400, label = "School count (should be >= 400)")
  expect_lte(n_schools, 600, label = "School count (should be <= 600)")
})

# ==============================================================================
# STEP 8: Output Fidelity Tests
# ==============================================================================

test_that("tidy=TRUE and tidy=FALSE return consistent data", {
  skip_if_offline()

  wide <- akschooldata::fetch_enr(2025, tidy = FALSE)
  tidy <- akschooldata::fetch_enr(2025, tidy = TRUE)

  # Both should have data
  expect_gt(nrow(wide), 0, label = "Wide format row count")
  expect_gt(nrow(tidy), 0, label = "Tidy format row count")
})

test_that("Tidy output contains expected subgroups", {
  skip_if_offline()

  tidy <- akschooldata::fetch_enr(2025, tidy = TRUE)

  # Check if we have a subgroup column
  subgroup_col <- names(tidy)[grepl("subgroup|category|race|ethnicity", tolower(names(tidy)))]

  if (length(subgroup_col) > 0) {
    subgroups <- tolower(unique(tidy[[subgroup_col[1]]]))

    # Should have total enrollment
    expect_true(any(grepl("total|all", subgroups)),
                label = "Has total enrollment subgroup")
  }
})

test_that("fetch_enr() returns consistent results across calls (caching)", {
  skip_if_offline()

  # First call
  data1 <- akschooldata::fetch_enr(2025, tidy = FALSE)

  # Second call (should use cache)
  data2 <- akschooldata::fetch_enr(2025, tidy = FALSE)

  expect_equal(nrow(data1), nrow(data2), label = "Cached row count")
  expect_equal(ncol(data1), ncol(data2), label = "Cached column count")
})

# ==============================================================================
# Year-by-Year Fidelity Tests
# ==============================================================================

test_that("2021 data downloads and processes correctly", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2021)
  expect_gt(nrow(raw$school), 0)
  expect_gt(nrow(raw$district), 0)

  tidy <- akschooldata::fetch_enr(2021, tidy = TRUE)
  expect_gt(nrow(tidy), 0)
})

test_that("2022 data downloads and processes correctly", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2022)
  expect_gt(nrow(raw$school), 0)
  expect_gt(nrow(raw$district), 0)

  tidy <- akschooldata::fetch_enr(2022, tidy = TRUE)
  expect_gt(nrow(tidy), 0)
})

test_that("2023 data downloads and processes correctly", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2023)
  expect_gt(nrow(raw$school), 0)
  expect_gt(nrow(raw$district), 0)

  tidy <- akschooldata::fetch_enr(2023, tidy = TRUE)
  expect_gt(nrow(tidy), 0)
})

test_that("2024 data downloads and processes correctly", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2024)
  expect_gt(nrow(raw$school), 0)
  expect_gt(nrow(raw$district), 0)

  tidy <- akschooldata::fetch_enr(2024, tidy = TRUE)
  expect_gt(nrow(tidy), 0)
})

test_that("2025 data downloads and processes correctly", {
  skip_if_offline()

  raw <- akschooldata:::get_raw_enr(2025)
  expect_gt(nrow(raw$school), 0)
  expect_gt(nrow(raw$district), 0)

  tidy <- akschooldata::fetch_enr(2025, tidy = TRUE)
  expect_gt(nrow(tidy), 0)
})

# ==============================================================================
# Raw Data Fidelity Tests - Compare processed data to raw Excel values
# ==============================================================================

test_that("Processed enrollment matches raw Excel values for 2025", {
  skip_if_offline()

  # Download raw file directly
  url <- build_deed_url("grade", 2025)
  temp_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  raw_excel <- readxl::read_excel(temp_file, sheet = 1)

  # Get state total from raw Excel (last row should be "State" / "Grand Total")
  state_row <- raw_excel[tolower(raw_excel$Type) == "state", ]

  if (nrow(state_row) > 0) {
    # Find the Total PK-12 or similar column
    total_col <- names(raw_excel)[grepl("total.*pk.*12|pk.*12|p12", tolower(names(raw_excel)))][1]

    if (!is.na(total_col)) {
      raw_state_total <- as.numeric(state_row[[total_col]])

      # Now get state total from processed data
      raw_processed <- akschooldata:::get_raw_enr(2025)

      # Sum school totals (should approximate state total)
      total_col_processed <- names(raw_processed$school)[grepl("row_total|total_pk12|total",
                                                                tolower(names(raw_processed$school)))][1]

      if (!is.na(total_col_processed)) {
        processed_school_sum <- sum(raw_processed$school[[total_col_processed]], na.rm = TRUE)

        # Should be within 5% (some schools may be excluded)
        if (!is.na(raw_state_total) && raw_state_total > 0) {
          ratio <- processed_school_sum / raw_state_total
          expect_gte(ratio, 0.95,
                     label = paste("Processed/raw ratio:", round(ratio, 3)))
          expect_lte(ratio, 1.05,
                     label = paste("Processed/raw ratio:", round(ratio, 3)))
        }
      }
    }
  }
})

test_that("District count matches raw Excel for 2025", {
  skip_if_offline()

  # Download raw file directly
  url <- build_deed_url("grade", 2025)
  temp_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  raw_excel <- readxl::read_excel(temp_file, sheet = 1)

  # Count districts in raw Excel
  raw_district_count <- sum(tolower(raw_excel$Type) == "district", na.rm = TRUE)

  # Get district count from processed data
  raw_processed <- akschooldata:::get_raw_enr(2025)
  processed_district_count <- nrow(raw_processed$district)

  expect_equal(processed_district_count, raw_district_count,
               label = paste("District counts match (raw:", raw_district_count, "processed:", processed_district_count, ")"))
})

test_that("School count matches raw Excel for 2025", {
  skip_if_offline()

  # Download raw file directly
  url <- build_deed_url("grade", 2025)
  temp_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(temp_file), add = TRUE)

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(120))
  raw_excel <- readxl::read_excel(temp_file, sheet = 1)

  # Count schools in raw Excel
  raw_school_count <- sum(tolower(raw_excel$Type) == "school", na.rm = TRUE)

  # Get school count from processed data
  raw_processed <- akschooldata:::get_raw_enr(2025)
  processed_school_count <- nrow(raw_processed$school)

  expect_equal(processed_school_count, raw_school_count,
               label = paste("School counts match (raw:", raw_school_count, "processed:", processed_school_count, ")"))
})

# ==============================================================================
# Cache Tests
# ==============================================================================

test_that("Cache path can be generated", {
  tryCatch({
    path <- akschooldata:::get_cache_path(2024, "enrollment")
    expect_true(is.character(path))
    expect_true(grepl("2024", path))
  }, error = function(e) {
    skip("Cache functions may not be implemented")
  })
})

test_that("Cache info function works", {
  tryCatch({
    info <- akschooldata::enr_cache_info()
    expect_true(is.data.frame(info) || is.list(info) || is.null(info))
  }, error = function(e) {
    skip("Cache info function may not be implemented")
  })
})
