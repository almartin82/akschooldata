#!/bin/bash

# Remove eval=FALSE from vignettes
# This script finds and reports eval=FALSE usage
# Actual fixes may require manual review

echo "=== Finding eval=FALSE in Vignettes ==="
echo "Started: $(date)"
echo ""

PACKAGES=$(find . -maxdepth 1 -name "*schooldata" -type d | sort)

total_chunks=0
packages_with_issues=0

for pkg in $PACKAGES; do
    pkg_name=$(basename "$pkg")

    # Find all .Rmd vignettes
    vignettes=$(find "$pkg/vignettes" -name "*.Rmd" -type f 2>/dev/null)

    if [ -z "$vignettes" ]; then
        continue
    fi

    pkg_chunks=0

    for vig in $vignettes; do
        # Find chunks with eval=FALSE
        eval_false=$(grep -n '```{r.*eval=FALSE' "$vig" 2>/dev/null || true)

        if [ -n "$eval_false" ]; then
            if [ $pkg_chunks -eq 0 ]; then
                echo "### $pkg_name"
                packages_with_issues=$((packages_with_issues + 1))
            fi

            echo "  📄 $(basename $vig)"
            echo "$eval_false" | while read line; do
                echo "    $line"
            done

            pkg_chunks=$((pkg_chunks + $(echo "$eval_false" | wc -l)))
        fi
    done

    total_chunks=$((total_chunks + pkg_chunks))

    if [ $pkg_chunks -gt 0 ]; then
        echo "  Total chunks with eval=FALSE: $pkg_chunks"
        echo ""
    fi
done

echo "=== Summary ==="
echo "Packages with eval=FALSE: $packages_with_issues"
echo "Total chunks with eval=FALSE: $total_chunks"
echo ""
echo "⚠️  MANUAL REVIEW REQUIRED:"
echo "eval=FALSE usage must be reviewed case-by-case:"
echo "  - If code is broken: FIX the code"
echo "  - If code is obsolete: REMOVE the chunk"
echo "  - If code is for demo only: KEEP eval=FALSE with comment"
echo ""
echo "Finished: $(date)"
