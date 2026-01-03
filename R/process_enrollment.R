# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw Alaska DEED enrollment data
# into a clean, standardized format matching the state schooldata schema.
#
# IMPORTANT: This package uses ONLY Alaska DEED data sources.
# No federal data sources (NCES, Urban Institute, etc.) are used.
#
# ==============================================================================

#' Process raw Alaska DEED enrollment data
#'
#' Transforms raw DEED data into a standardized schema combining
#' school and district data.
#'
#' @param raw_data List containing school and district data frames from get_raw_enr
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(raw_data, end_year) {

  # Process school data (has ethnicity breakdowns)
  school_processed <- process_school_enr(raw_data$school, end_year)

  # Process district data (grade totals only, no ethnicity breakdown in source)
  district_processed <- process_district_enr(raw_data$district, end_year)

  # Add ethnicity aggregates from schools to districts
  district_processed <- add_district_ethnicity_from_schools(
    district_processed,
    school_processed
  )

  # Create state aggregate (summing from schools, not districts, to ensure accuracy)
  state_processed <- create_state_aggregate(school_processed, end_year)

  # Combine all levels
  result <- dplyr::bind_rows(state_processed, district_processed, school_processed)

  result
}


#' Add ethnicity data to districts by aggregating from schools
#'
#' The DEED data only provides ethnicity breakdowns at the school level.
#' This function sums school ethnicity counts to create district totals.
#'
#' @param district_df Processed district data frame
#' @param school_df Processed school data frame with ethnicity columns
#' @return District data frame with ethnicity columns added
#' @keywords internal
add_district_ethnicity_from_schools <- function(district_df, school_df) {

  if (is.null(district_df) || nrow(district_df) == 0) {
    return(district_df)
  }
  if (is.null(school_df) || nrow(school_df) == 0) {
    return(district_df)
  }

  # Ethnicity columns to aggregate
  eth_cols <- c("native_american", "asian", "hispanic", "black",
                "white", "pacific_islander", "multiracial")
  eth_cols <- eth_cols[eth_cols %in% names(school_df)]

  if (length(eth_cols) == 0) {
    return(district_df)
  }

  # Aggregate school ethnicity by district
  eth_agg <- school_df |>
    dplyr::group_by(district_id) |>
    dplyr::summarize(
      dplyr::across(dplyr::all_of(eth_cols), ~ sum(.x, na.rm = TRUE)),
      .groups = "drop"
    )

  # Join back to district data
  # First remove any existing ethnicity columns from district_df
  district_df <- district_df[, !names(district_df) %in% eth_cols]

  dplyr::left_join(district_df, eth_agg, by = "district_id")
}


#' Process school-level enrollment data
#'
#' @param df Raw school data frame (DEED format)
#' @param end_year School year end
#' @return Processed school data frame
#' @keywords internal
process_school_enr <- function(df, end_year) {

  if (is.null(df) || nrow(df) == 0) {
    return(data.frame())
  }

  cols <- names(df)
  n_rows <- nrow(df)

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("Campus", n_rows),
    stringsAsFactors = FALSE
  )

  # District name
  if ("district_name" %in% cols) {
    result$district_name <- trimws(as.character(df$district_name))
  }

  # School/campus name
  if ("school_name" %in% cols) {
    result$campus_name <- trimws(as.character(df$school_name))
  }

  # School ID if available
  if ("school_id" %in% cols) {
    result$campus_id <- trimws(as.character(df$school_id))
  } else {
    result$campus_id <- NA_character_
  }

  # District ID if available
  if ("district_id" %in% cols) {
    result$district_id <- trimws(as.character(df$district_id))
  } else {
    result$district_id <- NA_character_
  }

  # Total enrollment
  if ("row_total" %in% cols) {
    result$row_total <- safe_numeric(df$row_total)
  }

  # Demographics
  demo_cols <- c("native_american", "asian", "hispanic", "black",
                 "white", "pacific_islander", "multiracial")
  for (col in demo_cols) {
    if (col %in% cols) {
      result[[col]] <- safe_numeric(df[[col]])
    }
  }

  # Gender (if available in DEED data)
  if ("male" %in% cols) {
    result$male <- safe_numeric(df$male)
  }
  if ("female" %in% cols) {
    result$female <- safe_numeric(df$female)
  }

  # Grade levels
  grade_cols <- c("grade_pk", "grade_k",
                  "grade_01", "grade_02", "grade_03", "grade_04",
                  "grade_05", "grade_06", "grade_07", "grade_08",
                  "grade_09", "grade_10", "grade_11", "grade_12")
  for (col in grade_cols) {
    if (col %in% cols) {
      result[[col]] <- safe_numeric(df[[col]])
    }
  }

  # Charter flag (default to N for DEED data unless specified)
  result$charter_flag <- rep("N", n_rows)

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

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("District", n_rows),
    stringsAsFactors = FALSE
  )

  # District name
  if ("district_name" %in% cols) {
    result$district_name <- trimws(as.character(df$district_name))
  }

  # Campus ID is NA for district rows
  result$campus_id <- rep(NA_character_, n_rows)
  result$campus_name <- rep(NA_character_, n_rows)

  # District ID if available
  if ("district_id" %in% cols) {
    result$district_id <- trimws(as.character(df$district_id))
  } else {
    result$district_id <- NA_character_
  }

  # Total enrollment
  if ("row_total" %in% cols) {
    result$row_total <- safe_numeric(df$row_total)
  }

  # Demographics
  demo_cols <- c("native_american", "asian", "hispanic", "black",
                 "white", "pacific_islander", "multiracial")
  for (col in demo_cols) {
    if (col %in% cols) {
      result[[col]] <- safe_numeric(df[[col]])
    }
  }

  # Gender (if available)
  if ("male" %in% cols) {
    result$male <- safe_numeric(df$male)
  }
  if ("female" %in% cols) {
    result$female <- safe_numeric(df$female)
  }

  # Grade levels
  grade_cols <- c("grade_pk", "grade_k",
                  "grade_01", "grade_02", "grade_03", "grade_04",
                  "grade_05", "grade_06", "grade_07", "grade_08",
                  "grade_09", "grade_10", "grade_11", "grade_12")
  for (col in grade_cols) {
    if (col %in% cols) {
      result[[col]] <- safe_numeric(df[[col]])
    }
  }

  # Charter status - districts are not charters
  result$charter_flag <- rep(NA_character_, n_rows)

  result
}


#' Create state-level aggregate from district data
#'
#' @param district_df Processed district data frame
#' @param end_year School year end
#' @return Single-row data frame with state totals
#' @keywords internal
create_state_aggregate <- function(district_df, end_year) {

  if (is.null(district_df) || nrow(district_df) == 0) {
    # Return minimal state row
    return(data.frame(
      end_year = end_year,
      type = "State",
      district_id = NA_character_,
      campus_id = NA_character_,
      district_name = "Alaska",
      campus_name = NA_character_,
      charter_flag = NA_character_,
      row_total = NA_integer_,
      stringsAsFactors = FALSE
    ))
  }

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
