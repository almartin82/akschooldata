# ==============================================================================
# Utility Functions
# ==============================================================================
#
# IMPORTANT: This package uses ONLY Alaska DEED data sources.
# No federal data sources (NCES, Urban Institute, etc.) are used.
#
# ==============================================================================

#' @importFrom rlang .data
NULL


#' Convert to numeric, handling suppression markers
#'
#' Alaska DEED uses various markers for suppressed data (*, N/A, etc.)
#' and may use commas in large numbers.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("*", ".", "-", "-1", "<5", "N/A", "NA", "", "n/a", "**")] <- NA_character_

  suppressWarnings(as.numeric(x))
}


#' Get available years for Alaska enrollment data
#'
#' Returns the range of years for which enrollment data is available
#' from Alaska DEED's statistics portal.
#'
#' Data is downloaded directly from:
#' https://education.alaska.gov/Stats/enrollment/
#'
#' @return Named list with min_year, max_year, and description
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  list(
    min_year = 2021,
    max_year = 2025,
    description = paste(
      "Alaska DEED enrollment data availability:",
      "- 2021-2025: Excel files from DEED Statistics Portal",
      "  (Enrollment by School by Grade & Enrollment by School by Ethnicity)",
      "",
      "Data source: https://education.alaska.gov/Stats/enrollment/",
      "",
      "Note: Earlier years may be available as PDF reports but are not",
      "currently supported for automated download.",
      sep = "\n"
    )
  )
}


#' Get Alaska district reference data
#'
#' Returns a data frame with Alaska school district names.
#' Alaska has approximately 54 school districts.
#'
#' @return Data frame with district_id and district_name
#' @keywords internal
get_ak_districts <- function() {
  # Alaska has ~54 school districts
  # This provides a reference mapping for common districts

  data.frame(
    district_id = c(
      "01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
      "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
      "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
      "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
      "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
      "51", "52", "53", "54"
    ),
    district_name = c(
      "Alaska Gateway School District",
      "Denali Borough School District",
      "Aleutians East Borough School District",
      "Aleutian Region School District",
      "Anchorage School District",
      "Annette Island School District",
      "Bering Strait School District",
      "Bristol Bay Borough School District",
      "Chatham School District",
      "Chugach School District",
      "Copper River School District",
      "Cordova City School District",
      "Craig City School District",
      "Delta/Greely School District",
      "Dillingham City School District",
      "Fairbanks North Star Borough School District",
      "Galena City School District",
      "Haines Borough School District",
      "Hoonah City School District",
      "Hydaburg City School District",
      "Iditarod Area School District",
      "Juneau Borough School District",
      "Kake City School District",
      "Kashunamiut School District",
      "Kenai Peninsula Borough School District",
      "Ketchikan Gateway Borough School District",
      "Klawock City School District",
      "Kodiak Island Borough School District",
      "Kuspuk School District",
      "Lake and Peninsula Borough School District",
      "Lower Kuskokwim School District",
      "Lower Yukon School District",
      "Matanuska-Susitna Borough School District",
      "Nenana City School District",
      "Nome City School District",
      "North Slope Borough School District",
      "Northwest Arctic Borough School District",
      "Pelican City School District",
      "Petersburg City School District",
      "Pribilof Island School District",
      "Saint Mary's School District",
      "Sitka Borough School District",
      "Skagway City School District",
      "Southeast Island School District",
      "Southwest Region School District",
      "Tanana School District",
      "Unalaska City School District",
      "Valdez City School District",
      "Wrangell City School District",
      "Yakutat City School District",
      "Yukon Flats School District",
      "Yukon-Koyukuk School District",
      "Yupiit School District",
      "Mt. Edgecumbe High School"
    ),
    stringsAsFactors = FALSE
  )
}


#' Build Alaska DEED enrollment URL
#'
#' Constructs URL for Alaska DEED enrollment data files.
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @param file_type Type of file: "grade" or "ethnicity"
#' @return URL string
#' @keywords internal
build_deed_enrollment_url <- function(end_year, file_type = "grade") {
  # Build school year string (e.g., "2023-24" for end_year 2024)
  start_year <- end_year - 1
  sy_string <- paste0(start_year, "-", substr(as.character(end_year), 3, 4))

  base_url <- "https://education.alaska.gov/Stats/enrollment/"

  if (file_type == "grade") {
    # "2- Enrollment by School by Grade YYYY-YY.xlsx"
    filename <- paste0("2- Enrollment by School by Grade ", sy_string, ".xlsx")
  } else if (file_type == "ethnicity") {
    # "5- Enrollment by School by ethnicity YYYY-YY.xlsx"
    filename <- paste0("5- Enrollment by School by ethnicity ", sy_string, ".xlsx")
  } else {
    stop("Unknown file_type: ", file_type, ". Use 'grade' or 'ethnicity'.")
  }

  paste0(base_url, utils::URLencode(filename, reserved = TRUE))
}
