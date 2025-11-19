#!/bin/bash
# Cleanup Script: Organize Test Files
# Purpose: Move development test files to tests/ directory

set -euo pipefail

echo "🧪 Organizing Test Files..."
echo ""

# Create tests directory
echo "[1/4] Creating tests directory..."
mkdir -p tests
echo "✅ Created: tests/"

# Move development test files
echo ""
echo "[2/4] Moving development test files..."

declare -a test_files=(
    "test-go-function.sh"
    "test-go-integration.sh"
)

for test_file in "${test_files[@]}"; do
    if [ -f "$test_file" ]; then
        mv "$test_file" tests/
        echo "✅ Moved: $test_file → tests/"
    else
        echo "⚠️  Not found: $test_file (skipping)"
    fi
done

# Keep test-setup.sh in root (it's a validation tool)
echo ""
echo "[3/4] Verification..."
if [ -f "test-setup.sh" ]; then
    echo "✅ Kept in root: test-setup.sh (production validation tool)"
else
    echo "⚠️  test-setup.sh not found in root"
fi

# Create tests README
echo ""
echo "[4/4] Creating tests/README.md..."
cat > tests/README.md << 'EOF'
# Test Scripts

This directory contains development and integration test scripts for the 1453 WSL Setup Script.

## Test Files

### Go Module Tests
- **test-go-function.sh** - Unit tests for Go installation functions
- **test-go-integration.sh** - Integration tests for Go module

## Running Tests

```bash
# Run Go function tests
bash tests/test-go-function.sh

# Run Go integration tests
bash tests/test-go-integration.sh
```

## Validation Script

The main validation script `test-setup.sh` is located in the root directory. It validates the entire installation and should be run after setup completion.

```bash
# Run full validation
./test-setup.sh
```

## Adding New Tests

When adding new test scripts:
1. Name them `test-<module>-<type>.sh`
2. Place them in this `tests/` directory
3. Update this README with test documentation
4. Ensure they are executable: `chmod +x tests/test-*.sh`
EOF

echo "✅ Created: tests/README.md"

echo ""
echo "=========================================="
echo "✅ Test Organization Complete!"
echo "=========================================="
echo ""
echo "Test Directory Structure:"
echo "  tests/"
ls -lh tests/ 2>/dev/null | tail -n +2 | awk '{print "    -", $9, "("$5")"}' || echo "    (empty or error)"
echo ""
echo "Root Validation Tool:"
if [ -f "test-setup.sh" ]; then
    ls -lh test-setup.sh | awk '{print "    -", $9, "("$5")"}'
fi
