#!/bin/bash

# Check what uncommitted changes exist in packages with dirty working directories

echo "Packages with uncommitted changes:"
echo "=================================="
echo ""

PACKAGES=(
    "akschooldata"
    "azschooldata"
    "coschooldata"
    "ctschooldata"
    "gaschooldata"
    "hischooldata"
    "ilschooldata"
    "inschooldata"
    "ksschooldata"
    "maschooldata"
    "mdschooldata"
    "mischooldata"
    "ncschooldata"
    "neschooldata"
    "nhschooldata"
    "nyschooldata"
    "orschooldata"
    "paschooldata"
    "scschooldata"
    "sdschooldata"
    "txschooldata"
    "vaschooldata"
    "waschooldata"
    "wischooldata"
)

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "### $pkg"
        git -C "$pkg" status --short
        echo ""
    fi
done
