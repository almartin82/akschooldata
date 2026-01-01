# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from
# Alaska Department of Education & Early Development (DEED).
#
# Data sources (all from Alaska DEED):
# - Enrollment by School by Grade: https://education.alaska.gov/Stats/enrollment/
# - Enrollment by School by Ethnicity: https://education.alaska.gov/Stats/enrollment/
#
# IMPORTANT: This package uses ONLY Alaska DEED data sources.
# No federal data sources (NCES, Urban Institute, etc.) are used.
#
# ==============================================================================

#' Download raw enrollment data from Alaska DEED
#'
#' Downloads school enrollment data directly from Alaska Department of
#' Education & Early Development (DEED). This function downloads both
#' grade-level and ethnicity enrollment files from DEED's statistics portal.
#'
#' @param end_year School year end (2023-24 = 2024)
#' @return List with school and district data frames
#' @keywords internal
get_raw_enr <- function(end_year) {

  # Validate year against available range
  available <- get_available_years()
  if (end_year < available$min_year || end_year > available$max_year) {
    stop("end_year must be between ", available$min_year, " and ", available$max_year, ". ",
         "Use get_available_years() to see data availability.")
  }


  message(paste("Downloading Alaska DEED enrollment data for", end_year, "..."))

  # Download enrollment by grade data
  grade_data <- download_deed_enrollment_by_grade(end_year)

  # Download enrollment by ethnicity data
  ethnicity_data <- download_deed_enrollment_by_ethnicity(end_year)

  # Merge the two datasets
  school_data <- merge_deed_enrollment_data(grade_data, ethnicity_data)

  # Create district aggregates from school data
  district_data <- aggregate_to_district(school_data)

  list(
    school = school_data,
    district = district_data,
    end_year = end_year,
    source = "deed"
  )
}


#' Download enrollment by grade from Alaska DEED
#'
#' Downloads the "Enrollment by School by Grade" Excel file from DEED.
#' Files are located at: https://education.alaska.gov/Stats/enrollment/
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return Data frame with grade-level enrollment by school
#' @keywords internal
download_deed_enrollment_by_grade <- function(end_year) {

  # Build school year string (e.g., "2023-24" for end_year 2024)
  start_year <- end_year - 1
  sy_string <- paste0(start_year, "-", substr(as.character(end_year), 3, 4))

  # DEED file naming pattern:
  # "2- Enrollment by School by Grade YYYY-YY.xlsx"
  filename <- paste0("2- Enrollment by School by Grade ", sy_string, ".xlsx")

  # URL encode the filename (handle spaces)
  url <- paste0(
    "https://education.alaska.gov/Stats/enrollment/",
    utils::URLencode(filename, reserved = TRUE)
  )

  message(paste0("  Downloading grade enrollment from: ", url))

  # Download to temp file

  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("akschooldata R package")
    )

    if (httr::status_code(response) != 200) {
      stop("Failed to download file. HTTP status: ", httr::status_code(response))
    }

    # Read the Excel file
    df <- readxl::read_excel(temp_file, sheet = 1)

    # Clean up
    unlink(temp_file)

    df

  }, error = function(e) {
    unlink(temp_file)
    stop("Failed to download DEED enrollment by grade data for ", end_year, ": ", e$message)
  })
}


#' Download enrollment by ethnicity from Alaska DEED
#'
#' Downloads the "Enrollment by School by Ethnicity" Excel file from DEED.
#' Files are located at: https://education.alaska.gov/Stats/enrollment/
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return Data frame with ethnicity enrollment by school
#' @keywords internal
download_deed_enrollment_by_ethnicity <- function(end_year) {

  # Build school year string (e.g., "2024-25" for end_year 2025)
  start_year <- end_year - 1
  sy_string <- paste0(start_year, "-", substr(as.character(end_year), 3, 4))

  # DEED file naming pattern:
  # "5- Enrollment by School by ethnicity YYYY-YY.xlsx"
  filename <- paste0("5- Enrollment by School by ethnicity ", sy_string, ".xlsx")

  # URL encode the filename (handle spaces)
  url <- paste0(
    "https://education.alaska.gov/Stats/enrollment/",
    utils::URLencode(filename, reserved = TRUE)
  )

  message(paste0("  Downloading ethnicity enrollment from: ", url))

  # Download to temp file
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("akschooldata R package")
    )

    if (httr::status_code(response) != 200) {
      stop("Failed to download file. HTTP status: ", httr::status_code(response))
    }

    # Read the Excel file
    df <- readxl::read_excel(temp_file, sheet = 1)

    # Clean up
    unlink(temp_file)

    df

  }, error = function(e) {
    unlink(temp_file)
    stop("Failed to download DEED enrollment by ethnicity data for ", end_year, ": ", e$message)
  })
}


#' Merge DEED enrollment data files
#'
#' Combines grade-level and ethnicity enrollment data into a single dataset.
#'
#' @param grade_data Data frame from download_deed_enrollment_by_grade
#' @param ethnicity_data Data frame from download_deed_enrollment_by_ethnicity
#' @return Merged data frame with all enrollment columns
#' @keywords internal
merge_deed_enrollment_data <- function(grade_data, ethnicity_data) {

  # Standardize column names for merging
  # DEED files typically have columns like:
  # - District Name, School Name, School ID (or similar)
  # - Grade columns: PK, K, 1, 2, ... 12, Total
  # - Ethnicity columns: American Indian/Alaska Native, Asian, Black, Hispanic, etc.

  # Find common key columns for merging
  grade_cols <- tolower(names(grade_data))
  eth_cols <- tolower(names(ethnicity_data))

  # Identify the school identifier column
  school_id_patterns <- c("school.*id", "schoolid", "sch.*id", "nces")
  school_name_patterns <- c("school.*name", "schoolname", "school")
  district_name_patterns <- c("district.*name", "districtname", "district")

  # Normalize grade data column names
  names(grade_data) <- normalize_deed_colnames(names(grade_data))

  # Normalize ethnicity data column names
  names(ethnicity_data) <- normalize_deed_colnames(names(ethnicity_data))

  # Merge on school identifiers
  # Use school name and district as the merge key if no ID column
  merge_keys <- intersect(names(grade_data), names(ethnicity_data))
  merge_keys <- merge_keys[merge_keys %in% c("district_name", "school_name", "school_id", "district_id")]

  if (length(merge_keys) == 0) {
    # Fallback: use row binding with a warning
    warning("Could not identify merge keys. Using grade data as primary.")
    return(grade_data)
  }

  # Identify columns unique to each dataset
  grade_only_cols <- setdiff(names(grade_data), names(ethnicity_data))
  eth_only_cols <- setdiff(names(ethnicity_data), names(grade_data))

  # Merge datasets
  merged <- dplyr::left_join(
    grade_data,
    ethnicity_data[, c(merge_keys, eth_only_cols)],
    by = merge_keys
  )

  merged
}


#' Normalize DEED column names
#'
#' Converts DEED Excel column names to standardized format.
#'
#' @param colnames Character vector of column names
#' @return Normalized column names
#' @keywords internal
normalize_deed_colnames <- function(colnames) {

  # Start with lowercase
  result <- tolower(colnames)

  # Remove special characters and extra spaces
  result <- gsub("[^a-z0-9 ]", "", result)
  result <- trimws(result)
  result <- gsub("\\s+", "_", result)

  # Standardize common column names
  result <- gsub("^district$", "district_name", result)
  result <- gsub("^district_name$", "district_name", result)
  result <- gsub("^school$", "school_name", result)
  result <- gsub("^school_name$", "school_name", result)
  result <- gsub("schoolid", "school_id", result)
  result <- gsub("districtid", "district_id", result)

  # Standardize grade columns
  result <- gsub("^pk$", "grade_pk", result)
  result <- gsub("^prek$", "grade_pk", result)
  result <- gsub("^pre_k$", "grade_pk", result)
  result <- gsub("^k$", "grade_k", result)
  result <- gsub("^kindergarten$", "grade_k", result)
  result <- gsub("^1$", "grade_01", result)
  result <- gsub("^2$", "grade_02", result)
  result <- gsub("^3$", "grade_03", result)
  result <- gsub("^4$", "grade_04", result)
  result <- gsub("^5$", "grade_05", result)
  result <- gsub("^6$", "grade_06", result)
  result <- gsub("^7$", "grade_07", result)
  result <- gsub("^8$", "grade_08", result)
  result <- gsub("^9$", "grade_09", result)
  result <- gsub("^10$", "grade_10", result)
  result <- gsub("^11$", "grade_11", result)
  result <- gsub("^12$", "grade_12", result)

  # Standardize ethnicity columns
  result <- gsub("american_indian.*alaska_native", "native_american", result)
  result <- gsub("alaska_native.*american_indian", "native_american", result)
  result <- gsub("^aian$", "native_american", result)
  result <- gsub("native_hawaiian.*pacific_islander", "pacific_islander", result)
  result <- gsub("^nhpi$", "pacific_islander", result)
  result <- gsub("^asian$", "asian", result)
  result <- gsub("^black.*african.*american$", "black", result)
  result <- gsub("^black$", "black", result)
  result <- gsub("^hispanic.*latino$", "hispanic", result)
  result <- gsub("^hispanic$", "hispanic", result)
  result <- gsub("^white$", "white", result)
  result <- gsub("two_or_more.*races", "multiracial", result)
  result <- gsub("^multiracial$", "multiracial", result)

  # Gender columns
  result <- gsub("^male$", "male", result)
  result <- gsub("^female$", "female", result)

  # Total column
  result <- gsub("^total$", "row_total", result)
  result <- gsub("^total_enrollment$", "row_total", result)

  result
}


#' Aggregate school data to district level
#'
#' Creates district-level aggregates from school-level data.
#'
#' @param school_data Data frame with school-level enrollment
#' @return Data frame with district-level enrollment
#' @keywords internal
aggregate_to_district <- function(school_data) {

  if (is.null(school_data) || nrow(school_data) == 0) {
    return(data.frame())
  }

  # Identify numeric columns to sum
  numeric_cols <- names(school_data)[sapply(school_data, is.numeric)]
  numeric_cols <- numeric_cols[!numeric_cols %in% c("school_id", "district_id")]

  # Group by district and sum
  district_data <- school_data |>
    dplyr::group_by(district_name) |>
    dplyr::summarize(
      dplyr::across(dplyr::all_of(numeric_cols), ~sum(.x, na.rm = TRUE)),
      .groups = "drop"
    )

  # Add district_id if available in school data
  if ("district_id" %in% names(school_data)) {
    district_ids <- school_data |>
      dplyr::select(district_name, district_id) |>
      dplyr::distinct()

    district_data <- dplyr::left_join(district_data, district_ids, by = "district_name")
  }

  district_data
}


#' Import local DEED enrollment files
#'
#' Fallback function to import locally downloaded DEED enrollment files.
#' Use this if automatic download fails due to network issues.
#'
#' @param grade_file Path to local "Enrollment by School by Grade" xlsx file
#' @param ethnicity_file Path to local "Enrollment by School by Ethnicity" xlsx file
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return List with school and district data frames
#' @export
#' @examples
#' \dontrun{
#' # Download files manually from:
#' # https://education.alaska.gov/Stats/enrollment/
#'
#' raw_data <- import_local_deed_enrollment(
#'   grade_file = "2- Enrollment by School by Grade 2023-24.xlsx",
#'   ethnicity_file = "5- Enrollment by School by ethnicity 2023-24.xlsx",
#'   end_year = 2024
#' )
#' }
import_local_deed_enrollment <- function(grade_file, ethnicity_file, end_year) {

  if (!file.exists(grade_file)) {
    stop("Grade enrollment file not found: ", grade_file)
  }
  if (!file.exists(ethnicity_file)) {
    stop("Ethnicity enrollment file not found: ", ethnicity_file)
  }

  message("Importing local DEED enrollment files...")

  grade_data <- readxl::read_excel(grade_file, sheet = 1)
  ethnicity_data <- readxl::read_excel(ethnicity_file, sheet = 1)

  school_data <- merge_deed_enrollment_data(grade_data, ethnicity_data)
  district_data <- aggregate_to_district(school_data)

  list(
    school = school_data,
    district = district_data,
    end_year = end_year,
    source = "deed_local"
  )
}
