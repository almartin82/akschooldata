# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw Alaska enrollment data into
# a clean, standardized format matching the state schooldata schema.
#
# ==============================================================================

#' Process raw Alaska enrollment data
#'
#' Transforms raw NCES CCD or DEED data into a standardized schema combining
#' school and district data.
#'
#' @param raw_data List containing school and district data frames from get_raw_enr
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(raw_data, end_year) {

  # Process school data
  school_processed <- process_school_enr(raw_data$school, end_year)

  # Process district data
  district_processed <- process_district_enr(raw_data$district, end_year)

  # Create state aggregate
  state_processed <- create_state_aggregate(district_processed, end_year)

  # Combine all levels
  result <- dplyr::bind_rows(state_processed, district_processed, school_processed)

  result
}


#' Process school-level enrollment data
#'
#' @param df Raw school data frame (NCES CCD format)
#' @param end_year School year end
#' @return Processed school data frame
#' @keywords internal
process_school_enr <- function(df, end_year) {

  if (is.null(df) || nrow(df) == 0) {
    return(data.frame())
  }

  cols <- names(df)
  n_rows <- nrow(df)

  # Helper to find column by pattern (case-insensitive)
  find_col <- function(patterns) {
    for (pattern in patterns) {
      matched <- grep(paste0("^", pattern, "$"), cols, value = TRUE, ignore.case = TRUE)
      if (length(matched) > 0) return(matched[1])
    }
    NULL
  }

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("Campus", n_rows),
    stringsAsFactors = FALSE
  )

  # IDs - NCES uses SCHID for school, LEAID for district
  school_col <- find_col(c("SCHID", "NCESSCH", "SCHOOL_ID"))
  if (!is.null(school_col)) {
    result$campus_id <- trimws(as.character(df[[school_col]]))
  } else {
    result$campus_id <- NA_character_
  }

  district_col <- find_col(c("LEAID", "LEAID_ST", "LEA_ID"))
  if (!is.null(district_col)) {
    result$district_id <- trimws(as.character(df[[district_col]]))
  } else {
    result$district_id <- NA_character_
  }

  # Names
  school_name_col <- find_col(c("SCH_NAME", "SCHNAM", "SCHOOL_NAME"))
  if (!is.null(school_name_col)) {
    result$campus_name <- trimws(df[[school_name_col]])
  }

  district_name_col <- find_col(c("LEA_NAME", "LEANM", "DISTRICT_NAME"))
  if (!is.null(district_name_col)) {
    result$district_name <- trimws(df[[district_name_col]])
  }

  # Location
  city_col <- find_col(c("LCITY", "CITY", "MLOCALE"))
  if (!is.null(city_col)) {
    result$city <- trimws(df[[city_col]])
  }

  # Charter status (NCES uses CHARESSION or similar)
  charter_col <- find_col(c("CHARESSION", "CHARTER", "CHARTR"))
  if (!is.null(charter_col)) {
    result$charter_flag <- ifelse(
      tolower(trimws(df[[charter_col]])) %in% c("yes", "y", "1", "charter"),
      "Y", "N"
    )
  }

  # Total enrollment
  total_col <- find_col(c("TOTAL", "MEMBER", "ENROLL", "TOTMEMB"))
  if (!is.null(total_col)) {
    result$row_total <- safe_numeric(df[[total_col]])
  }

  # Demographics - NCES uses standard codes
  # AM = American Indian/Alaska Native
  # AS = Asian
  # HI = Hispanic
  # BL = Black/African American
  # WH = White
  # HP = Native Hawaiian/Pacific Islander
  # TR = Two or more races

  demo_map <- list(
    native_american = c("AM", "AIAN", "INDIAN", "NATIVE"),
    asian = c("AS", "ASIAN"),
    hispanic = c("HI", "HISP", "HISPANIC"),
    black = c("BL", "BLACK", "AFAM"),
    white = c("WH", "WHITE"),
    pacific_islander = c("HP", "NHPI", "PACIFIC"),
    multiracial = c("TR", "TWO", "MULTI", "MULTIRACE")
  )

  for (name in names(demo_map)) {
    col <- find_col(demo_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    }
  }

  # Gender
  male_col <- find_col(c("MALE", "M", "TOTMALE"))
  if (!is.null(male_col)) {
    result$male <- safe_numeric(df[[male_col]])
  }

  female_col <- find_col(c("FEMALE", "F", "TOTFEMALE"))
  if (!is.null(female_col)) {
    result$female <- safe_numeric(df[[female_col]])
  }

  # Grade levels - NCES uses PK, KG, G01-G12, UG
  grade_map <- list(
    grade_pk = c("PK", "PREPK", "PREK"),
    grade_k = c("KG", "KNDRGRT", "K"),
    grade_01 = c("G01", "GR01", "GRADE1"),
    grade_02 = c("G02", "GR02", "GRADE2"),
    grade_03 = c("G03", "GR03", "GRADE3"),
    grade_04 = c("G04", "GR04", "GRADE4"),
    grade_05 = c("G05", "GR05", "GRADE5"),
    grade_06 = c("G06", "GR06", "GRADE6"),
    grade_07 = c("G07", "GR07", "GRADE7"),
    grade_08 = c("G08", "GR08", "GRADE8"),
    grade_09 = c("G09", "GR09", "GRADE9"),
    grade_10 = c("G10", "GR10", "GRADE10"),
    grade_11 = c("G11", "GR11", "GRADE11"),
    grade_12 = c("G12", "GR12", "GRADE12")
  )

  for (name in names(grade_map)) {
    col <- find_col(grade_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    }
  }

  # Ungraded students
  ug_col <- find_col(c("UG", "UNGRADED"))
  if (!is.null(ug_col)) {
    result$grade_ug <- safe_numeric(df[[ug_col]])
  }

  result
}


#' Process district-level enrollment data
#'
#' @param df Raw district data frame
#' @param end_year School year end
#' @return Processed district data frame
#' @keywords internal
process_district_enr <- function(df, end_year) {

  if (is.null(df) || nrow(df) == 0) {
    return(data.frame())
  }

  cols <- names(df)
  n_rows <- nrow(df)

  # Helper to find column by pattern
  find_col <- function(patterns) {
    for (pattern in patterns) {
      matched <- grep(paste0("^", pattern, "$"), cols, value = TRUE, ignore.case = TRUE)
      if (length(matched) > 0) return(matched[1])
    }
    NULL
  }

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("District", n_rows),
    stringsAsFactors = FALSE
  )

  # IDs
  district_col <- find_col(c("LEAID", "LEAID_ST", "LEA_ID"))
  if (!is.null(district_col)) {
    result$district_id <- trimws(as.character(df[[district_col]]))
  }

  # Campus ID is NA for district rows
  result$campus_id <- rep(NA_character_, n_rows)

  # Names
  district_name_col <- find_col(c("LEA_NAME", "LEANM", "DISTRICT_NAME"))
  if (!is.null(district_name_col)) {
    result$district_name <- trimws(df[[district_name_col]])
  }

  result$campus_name <- rep(NA_character_, n_rows)

  # Charter status
  charter_col <- find_col(c("CHARESSION", "CHARTER", "CHARTR"))
  if (!is.null(charter_col)) {
    result$charter_flag <- ifelse(
      tolower(trimws(df[[charter_col]])) %in% c("yes", "y", "1"),
      "Y", "N"
    )
  }

  # Total enrollment
  total_col <- find_col(c("TOTAL", "MEMBER", "ENROLL", "TOTMEMB"))
  if (!is.null(total_col)) {
    result$row_total <- safe_numeric(df[[total_col]])
  }

  # Demographics
  demo_map <- list(
    native_american = c("AM", "AIAN", "INDIAN", "NATIVE"),
    asian = c("AS", "ASIAN"),
    hispanic = c("HI", "HISP", "HISPANIC"),
    black = c("BL", "BLACK", "AFAM"),
    white = c("WH", "WHITE"),
    pacific_islander = c("HP", "NHPI", "PACIFIC"),
    multiracial = c("TR", "TWO", "MULTI", "MULTIRACE")
  )

  for (name in names(demo_map)) {
    col <- find_col(demo_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    }
  }

  # Gender
  male_col <- find_col(c("MALE", "M", "TOTMALE"))
  if (!is.null(male_col)) {
    result$male <- safe_numeric(df[[male_col]])
  }

  female_col <- find_col(c("FEMALE", "F", "TOTFEMALE"))
  if (!is.null(female_col)) {
    result$female <- safe_numeric(df[[female_col]])
  }

  # Grade levels
  grade_map <- list(
    grade_pk = c("PK", "PREPK", "PREK"),
    grade_k = c("KG", "KNDRGRT", "K"),
    grade_01 = c("G01", "GR01"),
    grade_02 = c("G02", "GR02"),
    grade_03 = c("G03", "GR03"),
    grade_04 = c("G04", "GR04"),
    grade_05 = c("G05", "GR05"),
    grade_06 = c("G06", "GR06"),
    grade_07 = c("G07", "GR07"),
    grade_08 = c("G08", "GR08"),
    grade_09 = c("G09", "GR09"),
    grade_10 = c("G10", "GR10"),
    grade_11 = c("G11", "GR11"),
    grade_12 = c("G12", "GR12")
  )

  for (name in names(grade_map)) {
    col <- find_col(grade_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    }
  }

  result
}


#' Create state-level aggregate from district data
#'
#' @param district_df Processed district data frame
#' @param end_year School year end
#' @return Single-row data frame with state totals
#' @keywords internal
create_state_aggregate <- function(district_df, end_year) {

  # Columns to sum
  sum_cols <- c(
    "row_total",
    "white", "black", "hispanic", "asian",
    "pacific_islander", "native_american", "multiracial",
    "male", "female",
    "grade_pk", "grade_k",
    "grade_01", "grade_02", "grade_03", "grade_04",
    "grade_05", "grade_06", "grade_07", "grade_08",
    "grade_09", "grade_10", "grade_11", "grade_12"
  )

  # Filter to columns that exist
  sum_cols <- sum_cols[sum_cols %in% names(district_df)]

  # Create state row
  state_row <- data.frame(
    end_year = end_year,
    type = "State",
    district_id = NA_character_,
    campus_id = NA_character_,
    district_name = "Alaska",
    campus_name = NA_character_,
    charter_flag = NA_character_,
    stringsAsFactors = FALSE
  )

  # Sum each column
  for (col in sum_cols) {
    if (col %in% names(district_df)) {
      state_row[[col]] <- sum(district_df[[col]], na.rm = TRUE)
    }
  }

  state_row
}
