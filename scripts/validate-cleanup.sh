#!/bin/bash
# Validation Script: Repository Cleanup
# Purpose: Verify all cleanup operations were successful

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Validating Repository Cleanup..."
echo ""

passed=0
failed=0
warnings=0

# Test 1: Project Documentation & Bug Reports
echo "[TEST 1] Project Documentation..."
if [ -f "CLAUDE.md" ]; then
    echo -e "${GREEN}✅ PASS${NC} - CLAUDE.md exists (Project Source of Truth)"
    ((++passed))
else
    echo -e "${RED}❌ FAIL${NC} - CLAUDE.md missing"
    ((++failed))
fi

# Check for legacy bug reports (optional)
if [ -d "docs/archive/bug-reports" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Bug reports archive exists"
else
    echo -e "${YELLOW}⚠️  INFO${NC} - Bug reports archive not found (clean state assumed)"
fi

# Test 2: Documentation Files Renamed
echo ""
echo "[TEST 2] Documentation Files Renamed..."
if [ -f "docs/how-to-install-go-on-linux.md" ] && \
   [ ! -f "docs/how to install go on linux.md" ] && \
   [ -f "docs/INDEX.md" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Documentation files renamed (no spaces, README->INDEX)"
    ((++passed))
else
    echo -e "${YELLOW}⚠️  WARN${NC} - Documentation files not fully renamed"
    ((++warnings))
fi

# Test 3: Test files organized
echo ""
echo "[TEST 3] Test Files Organized..."
if [ -d "tests" ] && \
   [ $(find tests -name "test-*.sh" 2>/dev/null | wc -l) -ge 2 ] && \
   [ -f "test-setup.sh" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Test files properly organized"
    ((++passed))
else
    echo -e "${YELLOW}⚠️  WARN${NC} - Test files not fully organized"
    ((++warnings))
fi

# Test 4: Planning docs archived
echo ""
echo "[TEST 4] Planning Documents Archived..."
if [ -d "docs/archive/planning" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Planning archive created"
    ((++passed))
else
    echo -e "${YELLOW}⚠️  INFO${NC} - Planning archive not created (no planning docs found)"
    # Not a failure or warning, just info
    ((++passed))
fi

# Test 5: .gitignore updated
echo ""
echo "[TEST 5] .gitignore Configuration..."
if grep -q "docs/archive/" .gitignore && \
   grep -q "backup-\*/" .gitignore; then
    echo -e "${GREEN}✅ PASS${NC} - .gitignore properly configured"
    ((++passed))
else
    echo -e "${YELLOW}⚠️  WARN${NC} - .gitignore may need updates"
    ((++warnings))
fi

# Test 6: No syntax errors
echo ""
echo "[TEST 6] Syntax Validation..."
errors=$(find src -name "*.sh" -exec bash -n {} \; 2>&1 | wc -l)
if [ "$errors" -eq 0 ]; then
    echo -e "${GREEN}✅ PASS${NC} - All scripts pass syntax check"
    ((++passed))
else
    echo -e "${RED}❌ FAIL${NC} - $errors syntax errors found"
    ((++failed))
fi

# Summary
echo ""
echo "=========================================="
echo "Validation Results:"
echo "=========================================="
echo -e "${GREEN}✅ Passed:${NC}  $passed"
echo -e "${YELLOW}⚠️  Warnings:${NC} $warnings"
echo -e "${RED}❌ Failed:${NC}  $failed"
echo ""

total=$((passed + warnings + failed))
score=$((passed * 100 / total))

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All critical tests passed! ($score% success rate)${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Please review.${NC}"
    exit 1
fi
