#!/bin/bash
# Cleanup Script: Rename Documentation Files
# Purpose: Fix filenames with spaces and clarify documentation structure

set -euo pipefail

echo "📝 Renaming Documentation Files..."
echo ""

# Rename Go installation guide (remove spaces)
echo "[1/2] Renaming Go installation guide..."
if [ -f "docs/how to install go on linux.md" ]; then
    mv "docs/how to install go on linux.md" "docs/how-to-install-go-on-linux.md"
    echo "✅ Renamed: 'how to install go on linux.md' → 'how-to-install-go-on-linux.md'"
else
    echo "⚠️  File not found: 'docs/how to install go on linux.md'"
fi

# Rename docs README to INDEX for clarity
echo ""
echo "[2/2] Renaming docs README to INDEX..."
if [ -f "docs/README.md" ]; then
    mv "docs/README.md" "docs/INDEX.md"
    echo "✅ Renamed: 'docs/README.md' → 'docs/INDEX.md'"
    echo "   (Avoids confusion with root README.md)"
else
    echo "⚠️  File not found: 'docs/README.md'"
fi

echo ""
echo "=========================================="
echo "✅ Documentation Rename Complete!"
echo "=========================================="
