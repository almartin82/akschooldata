#!/usr/bin/env Rscript

# Simpler CI status check for all packages

packages <- list.dirs(".", recursive = FALSE, full.names = FALSE)
packages <- sort(packages[grepl("schooldata", packages)])

cat("Checking", length(packages), "packages...\n\n")

results <- list()

for (pkg in packages) {
  cat(sprintf("=== %s ===\n", pkg))

  check_dir <- paste0("/tmp/check_", pkg)

  # Run R CMD check
  result <- system2(
    "R",
    c("CMD", "check", pkg, "--output", check_dir, "--no-manual"),
    stdout = FALSE,
    stderr = FALSE
  )

  # Read the check log
  log_file <- paste0(check_dir, ".Rcheck/00check.log")
  if (file.exists(log_file)) {
    log_content <- readLines(log_file, warn = FALSE)

    # Extract status
    status_line <- grep("\\* checking for .* ...", log_content, value = TRUE)
    errors <- grep("\\* .* ERROR", status_line)
    warnings <- grep("\\* .* WARNING", status_line)

    # Count final status
    final_status <- "UNKNOWN"
    if (any(grepl("ERROR:", log_content))) {
      final_status <- "FAIL"
    } else if (any(grepl("WARNING:", log_content))) {
      final_status <- "WARNING"
    } else {
      final_status <- "PASS"
    }

    # Get summary line
    summary_lines <- log_content[grep("errors.*warnings.*notes", log_content)]
    if (length(summary_lines) > 0) {
      summary <- tail(summary_lines, 1)
      cat(summary, "\n")
    }

    results[[pkg]] <- list(
      status = final_status,
      exit_code = result
    )
  } else {
    cat("ERROR: Could not read log file\n")
    results[[pkg]] <- list(status = "ERROR", exit_code = -1)
  }

  cat("\n")
}

# Print summary
cat("\n=== SUMMARY ===\n\n")

for (pkg in names(results)) {
  cat(sprintf("%-20s %s\n", pkg, results[[pkg]]$status))
}

cat("\n=== COUNTS ===\n")
statuses <- sapply(results, function(x) x$status)
print(table(statuses))
