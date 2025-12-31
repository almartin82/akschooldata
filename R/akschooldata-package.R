#' akschooldata: Fetch and Process Alaska School Data
#'
#' Downloads and processes school data from the Alaska Department of Education
#' and Early Development (DEED). Provides functions for fetching enrollment data
#' including October 1 counts by school, district, grade level, and demographic
#' groups, and transforming it into tidy format for analysis.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_multi}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{tidy_enr}}}{Transform wide data to tidy (long) format}
#'   \item{\code{\link{id_enr_aggs}}}{Add aggregation level flags}
#'   \item{\code{\link{enr_grade_aggs}}}{Create grade-level aggregations}
#'   \item{\code{\link{get_available_years}}}{View available year range}
#' }
#'
#' @section Cache functions:
#' \describe{
#'   \item{\code{\link{cache_status}}}{View cached data files}
#'   \item{\code{\link{clear_cache}}}{Remove cached data files}
#' }
#'
#' @section ID System:
#' Alaska uses a hierarchical ID system:
#' \itemize{
#'   \item State FIPS: 02
#'   \item District IDs (LEAID): 02XXXXX (NCES LEA ID format)
#'   \item School IDs (SCHID): 02XXXXXXXXXX (NCES School ID format)
#' }
#' Alaska has approximately 54 school districts and 500 schools.
#'
#' @section Data Sources:
#' Data is sourced from:
#' \itemize{
#'   \item NCES CCD (primary): \url{https://nces.ed.gov/ccd/}
#'   \item Alaska DEED Data Center: \url{https://education.alaska.gov/data-center}
#'   \item Alaska DEED Statistics: \url{https://education.alaska.gov/stats}
#' }
#'
#' @section Demographics:
#' Alaska has unique demographic composition:
#' \itemize{
#'   \item 22% Alaska Native/American Indian (highest in US)
#'   \item 3% Native Hawaiian/Pacific Islander (among highest in US)
#'   \item Approximately 131,000 total students
#'   \item 53 school districts
#' }
#'
#' @docType package
#' @name akschooldata-package
#' @aliases akschooldata
#' @keywords internal
"_PACKAGE"

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
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
