#!/bin/bash
# Cleanup Script: Archive Planning Document
# Purpose: Move completed planning docs to archive

set -euo pipefail

echo "📦 Archiving Planning Documents..."
echo ""

# Create archive directory
echo "[1/2] Creating archive directory..."
mkdir -p docs/archive/planning
echo "✅ Created: docs/archive/planning/"

# Move planning document
echo ""
echo "[2/2] Moving planning document..."
if [ -f "todo-go-implementation.md" ]; then
    mv "todo-go-implementation.md" docs/archive/planning/
    echo "✅ Archived: todo-go-implementation.md"
    echo "   (Completed work, kept for historical reference)"
else
    echo "⚠️  Not found: todo-go-implementation.md"
fi

echo ""
echo "=========================================="
echo "✅ Planning Archive Complete!"
echo "=========================================="
