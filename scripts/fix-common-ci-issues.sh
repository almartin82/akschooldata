#!/bin/bash

# Script to fix common CI issues across all state schooldata packages
# Issues:
# 1. .venv directories (Python virtual environments)
# 2. __pycache__ directories
# 3. .tar.gz files (built packages)
# 4. check_output.log, rcmd_check.log files
# 5. data-cache directories

echo "Fixing common CI issues across all packages..."
echo "=============================================="
echo ""

PACKAGES=$(find . -maxdepth 1 -name "*schooldata" -type d | sort)

for pkg in $PACKAGES; do
    pkg_name=$(basename "$pkg")
    echo "### $pkg_name"

    # Check for .venv
    if [ -d "$pkg/.venv" ]; then
        echo "  ⚠ Found .venv directory (should be removed)"
        du -sh "$pkg/.venv" 2>/dev/null | sed 's/^/     /'
    fi

    # Check for __pycache__
    if [ -d "$pkg/tests/__pycache__" ]; then
        echo "  ⚠ Found tests/__pycache__ (should be in .gitignore)"
    fi

    # Check for .tar.gz files
    if ls "$pkg"/*.tar.gz 2> /dev/null; then
        echo "  ⚠ Found .tar.gz files (build artifacts)"
        ls "$pkg"/*.tar.gz 2>/dev/null | sed 's/^/     /'
    fi

    # Check for log files
    if ls "$pkg"/*check*.log "$pkg"/*output*.log 2> /dev/null; then
        echo "  ⚠ Found log files (build artifacts)"
        ls "$pkg"/*check*.log "$pkg"/*output*.log 2>/dev/null | sed 's/^/     /'
    fi

    # Check for data-cache
    if [ -d "$pkg/data-cache" ]; then
        echo "  ⚠ Found data-cache directory (should be in .gitignore)"
    fi

    # Check for docs directory with HTML
    if [ -d "$pkg/docs" ] && ls "$pkg/docs"/*.html 2> /dev/null; then
        echo "  ⚠ Found docs/ with HTML files (pkgdown artifacts)"
    fi

    # Check if all is good
    if [ ! -d "$pkg/.venv" ] && \
       [ ! -d "$pkg/tests/__pycache__" ] && \
       ! ls "$pkg"/*.tar.gz 2> /dev/null && \
       ! ls "$pkg"/*check*.log "$pkg"/*output*.log 2> /dev/null && \
       [ ! -d "$pkg/data-cache" ] && \
       [ ! -d "$pkg/docs" ]; then
        echo "  ✓ No common CI issues found"
    fi

    echo ""
done

echo "=============================================="
echo ""
echo "Summary of packages with issues:"
echo ""
echo "Packages with .venv:"
find . -maxdepth 2 -name ".venv" -type d | sed 's|^\./||' | sed 's|/.venv||' | grep schooldata

echo ""
echo "Packages with __pycache__:"
find . -maxdepth 3 -name "__pycache__" -type d | sed 's|^\./||' | sed 's|/.*||' | grep schooldata | sort -u

echo ""
echo "Packages with .tar.gz files:"
find . -maxdepth 2 -name "*.tar.gz" -type f | sed 's|^\./||' | sed 's|/.*||' | grep schooldata | sort -u

echo ""
echo "Packages with log files:"
find . -maxdepth 2 -name "*check*.log" -o -name "*output*.log" | sed 's|^\./||' | sed 's|/.*||' | grep schooldata | sort -u

echo ""
echo "Packages with data-cache:"
find . -maxdepth 2 -name "data-cache" -type d | sed 's|^\./||' | sed 's|/data-cache||' | grep schooldata

echo ""
echo "Packages with docs/:"
find . -maxdepth 2 -name "docs" -type d | sed 's|^\./||' | sed 's|/docs||' | grep schooldata
