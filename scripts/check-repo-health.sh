#!/bin/bash

# Script to check repository health of all state schooldata packages
# Issues we're looking for:
# 1. .gitdir files pointing to submodules (should be proper git repos)
# 2. Missing .git directories
# 3. Git repo status

echo "Checking repository health for all packages..."
echo "============================================="
echo ""

PACKAGES=$(find . -maxdepth 1 -name "*schooldata" -type d | sort)

for pkg in $PACKAGES; do
    pkg_name=$(basename "$pkg")
    echo "### $pkg_name"

    # Check if it's a git directory
    if [ -d "$pkg/.git" ]; then
        echo "  ✓ Has .git directory"

        # Check if it's a proper git repo
        if git -C "$pkg" rev-parse --git-dir > /dev/null 2>&1; then
            echo "  ✓ Valid git repository"

            # Check branch
            branch=$(git -C "$pkg" branch --show-current 2>/dev/null || echo "no-branch")
            echo "  Branch: $branch"

            # Check for uncommitted changes
            if git -C "$pkg" diff --quiet 2>/dev/null; then
                echo "  ✓ Working directory clean"
            else
                echo "  ⚠ Has uncommitted changes"
            fi
        else
            echo "  ✗ .git directory exists but not a valid git repo"
        fi

    # Check for gitdir file (submodule issue)
    elif [ -f "$pkg/.git" ]; then
        echo "  ✗ Has .git FILE instead of directory (submodule issue)"
        gitdir_content=$(cat "$pkg/.git")
        echo "     Points to: $gitdir_content"

    # No git setup at all
    else
        echo "  ⚠ No .git directory or file (not a git repo)"
    fi

    echo ""
done

echo "============================================="
echo "Summary:"
echo "✓ = OK"
echo "✗ = PROBLEM"
echo "⚠ = WARNING"
