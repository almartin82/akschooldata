#!/bin/bash

# Quick check for common CI issues across all packages
# This is much faster than running R CMD check on everything

echo "=== Checking for common CI issues ==="
echo ""

PACKAGES=$(find . -maxdepth 1 -name "*schooldata" -type d | sort)

for pkg in $PACKAGES; do
    pkg_name=$(basename "$pkg")
    echo "### $pkg_name"

    issues=0

    # 1. Check for empty data directory (WARNING)
    if [ -d "$pkg/data" ] && [ -z "$(ls -A $pkg/data 2>/dev/null)" ]; then
        echo "  ⚠ Empty data/ directory (causes WARNING)"
        issues=$((issues + 1))
    fi

    # 2. Check for non-R data files in data/ (WARNING)
    if [ -d "$pkg/data" ]; then
        non_r_files=$(find "$pkg/data" -type f ! -name "*.rda" ! -name "*.rdata" 2>/dev/null)
        if [ -n "$non_r_files" ]; then
            echo "  ⚠ Non-R data files in data/ (causes WARNING)"
            issues=$((issues + 1))
        fi
    fi

    # 3. Check for Rd files with long lines (>100 chars)
    long_rd=$(grep -r '^[^#].\{101,\}' "$pkg/man/" 2>/dev/null | head -1)
    if [ -n "$long_rd" ]; then
        echo "  ⚠ Rd files with lines > 100 chars (causes WARNING)"
        issues=$((issues + 1))
    fi

    # 4. Check for DESCRIPTION issues
    if [ -f "$pkg/DESCRIPTION" ]; then
        # Check for missing Imports in NAMESPACE
        if [ -f "$pkg/NAMESPACE" ]; then
            imports=$(grep "^Imports:" "$pkg/DESCRIPTION" | sed 's/^Imports: //' | tr ',' '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            for pkg_dep in $imports; do
                if ! grep -q "$pkg_dep" "$pkg/NAMESPACE" 2>/dev/null; then
                    echo "  ⚠ Package '$pkg_dep' in Imports but not in NAMESPACE (causes NOTE)"
                    issues=$((issues + 1))
                    break
                fi
            done
        fi
    fi

    # 5. Check for vignette issues
    if [ -d "$pkg/vignettes" ]; then
        # Check for eval=FALSE (cheating)
        eval_false=$(grep -r "eval=FALSE" "$pkg/vignettes/" 2>/dev/null)
        if [ -n "$eval_false" ]; then
            echo "  ⚠ Vignettes have eval=FALSE (may indicate broken code)"
            issues=$((issues + 1))
        fi

        # Check for non-matching README code (basic check)
        if [ -f "$pkg/README.md" ]; then
            readme_blocks=$(grep -c '^```r' "$pkg/README.md" 2>/dev/null || echo 0)
            if [ "$readme_blocks" -gt 0 ]; then
                vignette_blocks=$(find "$pkg/vignettes" -name "*.Rmd" -exec grep -c '^```r' {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
                if [ -n "$vignette_blocks" ] && [ "$readme_blocks" -gt "$vignette_blocks" ]; then
                    echo "  ⚠ README has more code blocks than vignettes (possible mismatch)"
                    issues=$((issues + 1))
                fi
            fi
        fi
    fi

    if [ $issues -eq 0 ]; then
        echo "  ✓ No obvious CI issues found"
    fi

    echo ""
done
