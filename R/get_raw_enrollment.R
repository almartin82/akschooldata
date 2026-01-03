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
  merged_data <- merge_deed_enrollment_data(grade_data, ethnicity_data)

  # Split into school and district data (Alaska has both in same file)
  split_data <- split_deed_data(merged_data)

  list(
    school = split_data$school,
    district = split_data$district,
    end_year = end_year,
    source = "deed"
  )
}


#' Download enrollment by grade from Alaska DEED
#'
#' Downloads the "Enrollment by School by Grade" Excel file from DEED.
#' Files are located at: https://education.alaska.gov/Stats/enrollment/
#'
#' Note: File formats vary by year:
#' - 2021-2023: Title row in row 1, headers in row 2, uses ID/District/School Name
#' - 2024-2025: Headers in row 1, uses Type/id/District/School
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
    # 2021-2023 files have a title row that needs to be skipped
    # 2024+ files have headers in row 1
    if (end_year <= 2023) {
      df <- readxl::read_excel(temp_file, sheet = 1, skip = 1)
      # Standardize column names for older format
      df <- standardize_old_format_grade(df)
    } else {
      df <- readxl::read_excel(temp_file, sheet = 1)
    }

    # Clean up
    unlink(temp_file)

    df

  }, error = function(e) {
    unlink(temp_file)
    stop("Failed to download DEED enrollment by grade data for ", end_year, ": ", e$message)
  })
}


#' Standardize old format grade enrollment data
#'
#' Converts 2021-2023 format (ID, District, School Name) to 2024+ format
#' (Type, id, District/School).
#'
#' @param df Data frame from old format file
#' @return Data frame with standardized column names
#' @keywords internal
standardize_old_format_grade <- function(df) {
  # Old format: ID, District, School Name, PK, KG, 1, ..., 12, Total KG-12, Total PK-12
  # New format: Type, id, District/School, PK, KG, 1, ..., 12, Total KG-12, Total PK-12

  if (!"ID" %in% names(df)) {
    return(df)  # Already in new format or unknown format
  }

  # Filter out footer/summary rows (n/a, end of table, etc.)
  # These appear at the end of the file with non-numeric IDs
  valid_rows <- !is.na(suppressWarnings(as.numeric(df$ID))) &
                !grepl("^(n/a|end of table|total)$", df$ID, ignore.case = TRUE) &
                !grepl("^(n/a|end of table|total)$", df$`School Name`, ignore.case = TRUE)
  df <- df[valid_rows, ]

  # Rename columns
  names(df)[names(df) == "ID"] <- "id"
  names(df)[names(df) == "District"] <- "district"

  # Clean up Total column names (may have \r\n)
  names(df) <- gsub("\\r\\n", " ", names(df))
  names(df) <- gsub("Total KG-12", "Total KG-12", names(df))
  names(df) <- gsub("Total PK-12", "Total PK-12", names(df))

  # Determine Type based on School Name
  # Districts have "Enrollment Count" in School Name, or NA
  # Schools have actual school names
  is_district <- is.na(df$`School Name`) |
                 df$`School Name` == "Enrollment Count" |
                 grepl("^Enrollment", df$`School Name`, ignore.case = TRUE)

  df$Type <- ifelse(is_district, "District", "School")

  # Create District/School column combining district and school name
  df$`District/School` <- ifelse(
    is_district,
    df$district,
    df$`School Name`
  )

  # Convert id to numeric if it's character
  if (is.character(df$id)) {
    df$id <- suppressWarnings(as.numeric(df$id))
  }

  # Reorder columns to match new format
  cols <- c("Type", "id", "District/School")
  other_cols <- setdiff(names(df), c(cols, "district", "School Name"))
  df <- df[, c(cols, other_cols)]

  df
}


#' Download enrollment by ethnicity from Alaska DEED
#'
#' Downloads the "Enrollment by School by Ethnicity" Excel file from DEED.
#' Files are located at: https://education.alaska.gov/Stats/enrollment/
#'
#' Note: File formats vary by year:
#' - 2021-2023: Title row in row 1, headers in row 2, uses ID/District / School/Ethnicity
#' - 2024-2025: Headers in row 1, uses Type/id/District/School/Ethnicity
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
    # 2021-2023 files have a title row that needs to be skipped
    # 2024+ files have headers in row 1
    if (end_year <= 2023) {
      df <- readxl::read_excel(temp_file, sheet = 1, skip = 1)
      # Standardize column names for older format
      df <- standardize_old_format_ethnicity(df)
    } else {
      df <- readxl::read_excel(temp_file, sheet = 1)
    }

    # Clean up
    unlink(temp_file)

    df

  }, error = function(e) {
    unlink(temp_file)
    stop("Failed to download DEED enrollment by ethnicity data for ", end_year, ": ", e$message)
  })
}


#' Standardize old format ethnicity enrollment data
#'
#' Converts 2021-2023 format (ID, District / School, Ethnicity) to 2024+ format
#' (Type, id, District/School, Ethnicity).
#'
#' @param df Data frame from old format file
#' @return Data frame with standardized column names
#' @keywords internal
standardize_old_format_ethnicity <- function(df) {
  # Old format: ID, District / School, Ethnicity, PK, KG, ...
  # New format: Type, id, District/School, Ethnicity, PK, KG, ...

  if (!"ID" %in% names(df)) {
    return(df)  # Already in new format or unknown format
  }

  # Filter out footer/summary rows (n/a, end of table, etc.)
  valid_rows <- !grepl("^(n/a|end of table|total)$", df$ID, ignore.case = TRUE)
  df <- df[valid_rows, ]

  # Rename columns
  names(df)[names(df) == "ID"] <- "id"
  names(df)[names(df) == "District / School"] <- "District/School"

  # Clean up Total column names (may have \r\n)
  names(df) <- gsub("\\r\\n", " ", names(df))

  # Standardize ethnicity values
  # Old format uses "Enrollment Count" instead of "All Races"
  df$Ethnicity <- gsub("Enrollment Count", "All Races", df$Ethnicity)

  # Determine Type based on ID pattern
  # District IDs are small numbers (< 100), school IDs are 5 digits
  if (is.character(df$id)) {
    df$id <- suppressWarnings(as.numeric(df$id))
  }
  df$Type <- ifelse(df$id < 100 | is.na(df$id), "District", "School")

  # Clean up district names (remove " Total" suffix)
  df$`District/School` <- gsub(" Total$", "", df$`District/School`)

  # Reorder columns to match new format
  cols <- c("Type", "id", "District/School", "Ethnicity")
  other_cols <- setdiff(names(df), cols)
  df <- df[, c(cols, other_cols)]

  df
}


#' Merge DEED enrollment data files
#'
#' Combines grade-level and ethnicity enrollment data into a single dataset.
#' The ethnicity file has multiple rows per school (one per ethnicity), so we
#' pivot it to wide format before merging with the grade data.
#'
#' @param grade_data Data frame from download_deed_enrollment_by_grade
#' @param ethnicity_data Data frame from download_deed_enrollment_by_ethnicity
#' @return Merged data frame with all enrollment columns
#' @keywords internal
merge_deed_enrollment_data <- function(grade_data, ethnicity_data) {

  # Normalize column names for both datasets
  names(grade_data) <- normalize_deed_colnames(names(grade_data))
  names(ethnicity_data) <- normalize_deed_colnames(names(ethnicity_data))

  # The ethnicity data has school names only on the first row of each entity
  # Fill down the entity_name column
  if ("entity_name" %in% names(ethnicity_data)) {
    ethnicity_data <- tidyr::fill(ethnicity_data, entity_name, .direction = "down")
  }

  # Pivot ethnicity data from long to wide
  # Filter out "All Races" rows as they duplicate the total
  if ("ethnicity" %in% names(ethnicity_data)) {
    # Identify the ethnicity-specific rows
    eth_rows <- ethnicity_data[!is.na(ethnicity_data$ethnicity) &
                               ethnicity_data$ethnicity != "all_races", ]

    if (nrow(eth_rows) > 0) {
      # Map ethnicity values to standardized column names
      eth_rows$ethnicity <- normalize_ethnicity_values(eth_rows$ethnicity)

      # Determine which total column to use
      # Ethnicity data has total_k12, grade data has row_total
      values_col <- if ("total_k12" %in% names(eth_rows)) "total_k12" else "row_total"

      # Some ethnicities (American Indian and Alaska Native) map to the same
      # normalized name (native_american), so we need to sum them first
      eth_summed <- eth_rows |>
        dplyr::group_by(entity_type, entity_id, entity_name, ethnicity) |>
        dplyr::summarize(
          !!values_col := sum(.data[[values_col]], na.rm = TRUE),
          .groups = "drop"
        )

      # Pivot to wide format using entity_id as the key
      eth_wide <- tidyr::pivot_wider(
        eth_summed,
        id_cols = c("entity_type", "entity_id", "entity_name"),
        names_from = "ethnicity",
        values_from = dplyr::all_of(values_col),
        values_fill = 0
      )

      # Merge with grade data
      merge_keys <- c("entity_type", "entity_id", "entity_name")
      merge_keys <- merge_keys[merge_keys %in% names(grade_data) &
                               merge_keys %in% names(eth_wide)]

      if (length(merge_keys) > 0) {
        # Identify ethnicity columns to add
        eth_cols <- setdiff(names(eth_wide), merge_keys)

        merged <- dplyr::left_join(
          grade_data,
          eth_wide[, c(merge_keys, eth_cols)],
          by = merge_keys
        )
        return(merged)
      }
    }
  }

  # Fallback: return grade data if merge not possible
  grade_data
}


#' Normalize ethnicity values
#'
#' Converts ethnicity string values from DEED to standardized column names.
#'
#' @param x Vector of ethnicity strings
#' @return Normalized ethnicity names
#' @keywords internal
normalize_ethnicity_values <- function(x) {
  x <- tolower(x)
  x <- gsub("american indian", "native_american", x)
  x <- gsub("alaska native", "native_american", x)
  x <- gsub("native hawaiian.*pacific islander", "pacific_islander", x)
  x <- gsub("two or more races.*", "multiracial", x)
  x <- gsub("black.*", "black", x)
  x <- gsub("hispanic.*", "hispanic", x)
  # Keep simple ones as-is
  x <- gsub("^white$", "white", x)
  x <- gsub("^asian$", "asian", x)
  x
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
  result <- gsub("^districtschool$", "entity_name", result)  # Combined district/school column
  result <- gsub("^school$", "school_name", result)
  result <- gsub("schoolid", "school_id", result)
  result <- gsub("districtid", "district_id", result)
  result <- gsub("^type$", "entity_type", result)
  result <- gsub("^id$", "entity_id", result)

  # Standardize grade columns
  result <- gsub("^pk$", "grade_pk", result)
  result <- gsub("^prek$", "grade_pk", result)
  result <- gsub("^pre_k$", "grade_pk", result)
  result <- gsub("^k$", "grade_k", result)
  result <- gsub("^kg$", "grade_k", result)
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

  # Total columns
  result <- gsub("^total_kg12$", "row_total", result)
  result <- gsub("^total_pk12$", "total_pk12", result)

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


#' Split Alaska DEED data into school and district levels
#'
#' Alaska DEED data has districts and schools in the same file with a Type column.
#' This function splits them and assigns district info to schools.
#'
#' @param merged_data Data frame with entity_type column
#' @return List with school and district data frames
#' @keywords internal
split_deed_data <- function(merged_data) {

  if (is.null(merged_data) || nrow(merged_data) == 0) {
    return(list(school = data.frame(), district = data.frame()))
  }

  # Check if we have the expected columns
  if (!"entity_type" %in% names(merged_data)) {
    warning("entity_type column not found. Returning data as-is.")
    return(list(school = merged_data, district = data.frame()))
  }

  # Normalize entity_type values
  merged_data$entity_type <- tolower(trimws(merged_data$entity_type))

  # Split into district and school rows
  district_data <- merged_data |>
    dplyr::filter(entity_type == "district") |>
    dplyr::rename(district_name = entity_name, district_id = entity_id) |>
    dplyr::select(-entity_type)

  # For schools, we need to assign them to districts

  # Alaska IDs: district_id is first digits, school_id adds more digits
  # e.g., district 2, school 20010
  school_data <- merged_data |>
    dplyr::filter(entity_type == "school") |>
    dplyr::rename(school_name = entity_name, school_id = entity_id) |>
    dplyr::select(-entity_type)

  # Derive district_id from school_id (first 1-2 digits before the school suffix)
  # School IDs appear to be: district_id * 10000 + school_number
  if (nrow(school_data) > 0 && "school_id" %in% names(school_data)) {
    school_data <- school_data |>
      dplyr::mutate(
        district_id = as.integer(floor(school_id / 10000))
      )

    # Join district names
    if (nrow(district_data) > 0) {
      district_lookup <- district_data |>
        dplyr::select(district_id, district_name) |>
        dplyr::distinct()

      school_data <- dplyr::left_join(school_data, district_lookup, by = "district_id")
    }
  }

  list(school = school_data, district = district_data)
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

  merged_data <- merge_deed_enrollment_data(grade_data, ethnicity_data)
  split_data <- split_deed_data(merged_data)

  list(
    school = split_data$school,
    district = split_data$district,
    end_year = end_year,
    source = "deed_local"
  )
}
