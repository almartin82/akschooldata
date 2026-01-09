#!/bin/bash

# Fix Rd line width issues - Group 2 (10 packages)
# Target: nhschooldata, njschooldata, nvschooldata, txschooldata, utschooldata,
#         vtschooldata, waschooldata, wischooldata, wvschooldata, wyschooldata

echo "=== Fixing Rd Line Widths - Group 2 ==="
echo "Started: $(date)"
echo ""

PACKAGES=(
    "nhschooldata"
    "njschooldata"
    "nvschooldata"
    "txschooldata"
    "utschooldata"
    "vtschooldata"
    "waschooldata"
    "wischooldata"
    "wvschooldata"
    "wyschooldata"
)

for pkg in "${PACKAGES[@]}"; do
    echo "### Processing $pkg"

    if [ ! -d "$pkg" ]; then
        echo "  ⚠ Package directory not found, skipping"
        continue
    fi

    # Find all Rd files with lines > 100 chars
    rd_files=$(find "$pkg/man" -name "*.Rd" -type f 2>/dev/null)

    if [ -z "$rd_files" ]; then
        echo "  ℹ No Rd files found"
        continue
    fi

    fixed_count=0

    for rd_file in $rd_files; do
        # Check if file has lines > 100 chars in examples
        long_lines=$(grep -n '^\\examples' "$rd_file" -A 100 | grep '^\s*[^#].\{101,\}' || true)

        if [ -n "$long_lines" ]; then
            echo "  📝 Fixing: $(basename $rd_file)"

            # Save original
            cp "$rd_file" "$rd_file.bak"

            # Fix common patterns (same as Group 1)
            sed -i '' 's/\(grad <- import_local_graduation("\)/\1\n    /' "$rd_file"
            sed -i '' 's/\(\.xlsx", \)/\1\n    /' "$rd_file"
            sed -i '' 's/ %>-%/\n    %>%\n    /' "$rd_file"
            sed -i '' 's/\("[^"]\{80,\}\")/\1\n    /' "$rd_file"

            # Check if fixed
            if ! grep -q '.\{101,\}' "$rd_file"; then
                echo "  ✅ Fixed"
                rm "$rd_file.bak"
                fixed_count=$((fixed_count + 1))
            else
                echo "  ⚠ Still has long lines, may need manual fix"
                mv "$rd_file.bak" "$rd_file"
            fi
        fi
    done

    echo "  Fixed $fixed_count Rd files"
    echo ""
done

echo "=== Group 2 Complete ==="
echo "Finished: $(date)"
