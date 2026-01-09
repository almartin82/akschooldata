#!/bin/bash

# Fix data directory issues
# Target: akschooldata (non-R files), ilschooldata (empty data/)

echo "=== Fixing Data Directory Issues ==="
echo "Started: $(date)"
echo ""

# Fix akschooldata: Move non-R data files to inst/extdata
echo "### Fixing akschooldata"
if [ -d "akschooldata/data/graduation" ]; then
    echo "  📁 Found data/graduation with non-R files"

    # Create inst/extdata if not exists
    mkdir -p "akschooldata/inst/extdata"

    # Move graduation directory
    if [ ! -d "akschooldata/inst/extdata/graduation" ]; then
        mv "akschooldata/data/graduation" "akschooldata/inst/extdata/"
        echo "  ✅ Moved data/graduation to inst/extdata/graduation"
    else
        echo "  ⚠ inst/extdata/graduation already exists, skipping"
    fi

    # Check if data/ is now empty
    if [ -z "$(ls -A akschooldata/data 2>/dev/null)" ]; then
        rmdir "akschooldata/data"
        echo "  ✅ Removed empty data/ directory"
    fi
else
    echo "  ℹ No data/graduation found"
fi

echo ""

# Fix ilschooldata: Remove empty data/ directory
echo "### Fixing ilschooldata"
if [ -d "ilschooldata/data" ]; then
    if [ -z "$(ls -A ilschooldata/data 2>/dev/null)" ]; then
        rmdir "ilschooldata/data"
        echo "  ✅ Removed empty data/ directory"
    else
        echo "  ℹ data/ directory not empty, contains:"
        ls -1 "ilschooldata/data"
    fi
else
    echo "  ℹ No data/ directory found"
fi

echo ""
echo "=== Data Directory Fixes Complete ==="
echo "Finished: $(date)"
echo ""
echo "Next steps:"
echo "1. Review changes"
echo "2. Run R CMD check on affected packages"
echo "3. Commit if checks pass"
