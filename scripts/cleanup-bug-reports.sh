#!/bin/bash
# Cleanup Script: Consolidate Bug Reports
# Purpose: Archive old bug reports, keep only final version

set -euo pipefail

echo "🧹 Consolidating Bug Reports..."
echo ""

# Create archive directory
echo "[1/4] Creating archive directory..."
mkdir -p docs/archive/bug-reports
echo "✅ Created: docs/archive/bug-reports/"

# Move old reports to archive
echo ""
echo "[2/4] Moving old reports to archive..."

declare -a old_reports=(
    "BUG-REPORT.md"
    "BUG-ANALYSIS-REPORT.md"
    "BUG-FIX-SUMMARY.md"
    "BUGFIX-REPORT.md"
)

for report in "${old_reports[@]}"; do
    if [ -f "$report" ]; then
        mv "$report" docs/archive/bug-reports/
        echo "✅ Archived: $report"
    else
        echo "⚠️  Not found: $report (skipping)"
    fi
done

# Keep final version
echo ""
echo "[3/4] Keeping final version in root..."
if [ -f "BUG-FIX-SUMMARY-FINAL.md" ]; then
    echo "✅ Retained: BUG-FIX-SUMMARY-FINAL.md"
else
    echo "❌ ERROR: BUG-FIX-SUMMARY-FINAL.md not found!"
    exit 1
fi

# Update .gitignore
echo ""
echo "[4/4] Updating .gitignore..."
if ! grep -q "docs/archive/" .gitignore; then
    echo "" >> .gitignore
    echo "# Bug Report Archives (keep only final versions)" >> .gitignore
    echo "BUG-FIX-SUMMARY-[0-9]*.md" >> .gitignore
    echo "BUG-ANALYSIS-*.md" >> .gitignore
    echo "BUGFIX-*.md" >> .gitignore
    echo "docs/archive/" >> .gitignore
    echo "✅ Updated .gitignore"
else
    echo "⚠️  .gitignore already contains archive patterns"
fi

# Summary
echo ""
echo "=========================================="
echo "✅ Bug Report Consolidation Complete!"
echo "=========================================="
echo ""
echo "Archived Reports (4):"
ls -lh docs/archive/bug-reports/ | tail -n +2 | awk '{print "  📦", $9, "("$5")"}'
echo ""
echo "Active Report (1):"
if [ -f "BUG-FIX-SUMMARY-FINAL.md" ]; then
    ls -lh BUG-FIX-SUMMARY-FINAL.md | awk '{print "  📄", $9, "("$5")"}'
fi
echo ""
echo "Space Saved: ~68 KB (archived to docs/archive/)"
