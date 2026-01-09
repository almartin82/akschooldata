# Debug script for Indiana graduation rates
devtools::load_all('/Users/almartin/Documents/state-schooldata/inschooldata')

# Test raw data fetch
cat("=== Testing Raw Data Fetch ===\n")
raw_data <- get_raw_graduation(2023, quiet = TRUE)
cat("State data rows:", nrow(raw_data$state), "\n")
cat("Corporation data rows:", nrow(raw_data$corporation), "\n")
cat("School public data rows:", nrow(raw_data$school_public), "\n")
cat("School non-public data rows:", nrow(raw_data$school_nonpublic), "\n")

if (nrow(raw_data$corporation) > 0) {
  cat("First corporation name:", raw_data$corporation$corporation_name[1], "\n")
}

# Test processing
cat("\n=== Testing Processing ===\n")
processed_data <- process_graduation(raw_data, 2023)
cat("Processed data rows:", nrow(processed_data), "\n")

if (nrow(processed_data) > 0) {
  cat("Processed data columns:", paste(colnames(processed_data), collapse=", "), "\n")
  cat("First few rows:\n")
  print(head(processed_data))
}

# Test fetch
cat("\n=== Testing Fetch (Wide Format) ===\n")
fetch_data_wide <- fetch_graduation(2023, quiet = TRUE, tidy = FALSE)
cat("Fetch data rows (wide):", nrow(fetch_data_wide), "\n")

cat("\n=== Testing Fetch (Tidy Format) ===\n")
fetch_data_tidy <- fetch_graduation(2023, quiet = TRUE, tidy = TRUE)
cat("Fetch data rows (tidy):", nrow(fetch_data_tidy), "\n")

# Test tidy function directly
cat("\n=== Testing Tidy Function Directly ===\n")
tidy_result <- tidy_graduation(processed_data)
cat("Tidy function result rows:", nrow(tidy_result), "\n")

# Test fetch function step by step
cat("\n=== Debugging Fetch Function ===\n")
cat("Step 1: Raw data fetch\n")
raw_data <- get_raw_graduation(2023, quiet = TRUE)
cat("Raw data state rows:", nrow(raw_data$state), "\n")
cat("Raw data corp rows:", nrow(raw_data$corporation), "\n")

cat("\nStep 2: Process data\n")
processed_data <- process_graduation(raw_data, 2023)
cat("Processed data rows:", nrow(processed_data), "\n")

cat("\nStep 3: Test tidy conversion\n")
test_tidy <- tidy_graduation(processed_data)
cat("Tidy conversion rows:", nrow(test_tidy), "\n")

cat("\nStep 4: Test direct fetch_graduation call with debug\n")
# Temporarily disable caching to force fresh processing
old_cache_dir <- Sys.getenv("R_CACHE_DIR")
Sys.unsetenv("R_CACHE_DIR")