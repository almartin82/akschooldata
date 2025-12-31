# ==============================================================================
# Utility Functions
# ==============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
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
#' Returns the range of years for which enrollment data is available.
#'
#' @return Named list with min_year and max_year
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  list(
    min_year = 1997,
    max_year = 2025,
    description = paste(
      "Alaska DEED enrollment data availability:",
      "- 1997-2010: School Ethnicity Reports (PDF, limited automation)",
      "- 2011-2025: NCES CCD (Common Core of Data) with detailed breakdowns",
      sep = "\n"
    )
  )
}


#' Build Alaska DEED URL for enrollment data
#'
#' Constructs URL for Alaska DEED enrollment data files.
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @param file_type Type of file to download
#' @return URL string
#' @keywords internal
build_deed_url <- function(end_year, file_type = "ethnicity") {
  # Alaska DEED School Ethnicity Reports
  # Pattern: https://education.alaska.gov/stats/SchoolEthnicity/YYYY_School_Ethnicity_Report.pdf
  if (file_type == "ethnicity") {
    return(paste0(
      "https://education.alaska.gov/stats/SchoolEthnicity/",
      end_year, "_School_Ethnicity_Report.pdf"
    ))
  }

  # ADM data
  if (file_type == "adm") {
    return("https://education.alaska.gov/stats/QuickFacts/ADM.pdf")
  }

  stop("Unknown file_type: ", file_type)
}


#' Build NCES CCD URL for enrollment data
#'
#' Constructs URL for NCES Common Core of Data files.
#' CCD is the primary source for detailed enrollment data by state.
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @param level Data level: "school" or "district"
#' @return URL string
#' @keywords internal
build_nces_url <- function(end_year, level = "school") {
  # NCES CCD files follow patterns like:
  # School: ccd_sch_052_YYYY_w_1a_MMDDYY.csv
  # District: ccd_lea_052_YYYY_w_1a_MMDDYY.csv

  # For recent years, use direct NCES API approach
  # Alaska FIPS code is 02

  # NCES provides data through their ELSI table generator
  # We'll use the direct download approach via nces.ed.gov/ccd/files.asp


  # Base URL for CCD flat files
  base_url <- "https://nces.ed.gov/ccd/Data/zip"

  # Construct school year string (e.g., 2023-24 for end_year 2024)
  start_year <- end_year - 1
  sy_short <- paste0(substr(as.character(start_year), 3, 4),
                     substr(as.character(end_year), 3, 4))

  # Membership file patterns vary by year
  # Recent years use ccd_sch_052_YYYY_MMDDYY.zip format
  if (level == "school") {
    # School-level membership data
    url <- paste0(base_url, "/ccd_sch_052_", start_year, end_year %% 100, "_w_1a_*.zip")
  } else {
    # District-level membership data
    url <- paste0(base_url, "/ccd_lea_052_", start_year, end_year %% 100, "_w_1a_*.zip")
  }

  url
}


#' Get Alaska district ID mapping
#'
#' Returns a data frame mapping Alaska district IDs to names.
#' Alaska uses 2-digit district IDs.
#'
#' @return Data frame with district_id and district_name
#' @keywords internal
get_ak_districts <- function() {
  # Alaska has ~54 school districts
  # District IDs are typically 2 digits (01-54 range)
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
