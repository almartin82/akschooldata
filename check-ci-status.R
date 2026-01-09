#!/usr/bin/env Rscript

# Check CI status for all state schooldata packages
# This will help us identify which packages have actual CI failures

library(devtools)

packages <- list.dirs(".", recursive = FALSE, full.names = FALSE)
packages <- sort(packages[grepl("schooldata", packages)])

results <- data.frame(
  package = character(),
  status = character(),
  errors = integer(),
  warnings = integer(),
  notes = integer(),
  stringsAsFactors = FALSE
)

for (pkg in packages) {
  cat(sprintf("Checking %s...\n", pkg))

  check_dir <- paste0("temp_", pkg, "_check")

  result <- tryCatch({
    check(
      pkg,
      quiet = TRUE,
      check_dir = check_dir,
      args = "--no-manual"
    )
  }, error = function(e) {
    list(
      errors = 1,
      warnings = 0,
      notes = 0,
      status = "ERROR"
    )
  }, warning = function(w) {
    list(
      errors = 0,
      warnings = 1,
      notes = 0,
      status = "WARNING"
    )
  })

  # Determine status
  if (result$errors > 0) {
    status <- "FAIL"
  } else if (result$warnings > 0) {
    status <- "WARNING"
  } else if (result$notes > 0) {
    status <- "NOTE"
  } else {
    status <- "PASS"
  }

  results <- rbind(results, data.frame(
    package = pkg,
    status = status,
    errors = result$errors,
    warnings = result$warnings,
    notes = result$notes,
    stringsAsFactors = FALSE
  ))

  # Clean up temp check directory
  unlink(check_dir, recursive = TRUE)
}

# Print summary
cat("\n=== CI STATUS SUMMARY ===\n\n")
print(results)

# Count by status
cat("\n=== STATUS COUNTS ===\n")
print(table(results$status))

# List failing packages
cat("\n=== FAILING PACKAGES ===\n")
failures <- results[results$status == "FAIL", ]
if (nrow(failures) > 0) {
  print(failures$package)
} else {
  cat("None\n")
}

# List warning packages
cat("\n=== WARNING PACKAGES ===\n")
warnings <- results[results$status == "WARNING", ]
if (nrow(warnings) > 0) {
  print(warnings$package)
} else {
  cat("None\n")
}
