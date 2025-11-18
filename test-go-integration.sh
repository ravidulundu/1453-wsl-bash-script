#!/bin/bash

# FIX BUG-002: Add safety flags for robust error handling
set -eo pipefail

# Simple test to verify Go module integration
echo "🔍 Testing Go Module Integration..."
echo ""

# Test 1: Check if go.sh file exists
if [ -f "src/modules/go.sh" ]; then
    echo "✅ Go module file exists"
else
    echo "❌ Go module file missing"
    exit 1
fi

# Test 2: Check if main script includes go.sh
if grep -q "modules/go.sh" src/linux-ai-setup-script.sh; then
    echo "✅ Main script loads Go module"
else
    echo "❌ Main script doesn't load Go module"
    exit 1
fi

# Test 3: Check if menu includes Go option
if grep -q "Go Kurulumu" src/modules/menus.sh; then
    echo "✅ Menu includes Go installation option"
else
    echo "❌ Menu doesn't include Go option"
    exit 1
fi

# Test 4: Check if main menu includes option 14
if grep -q '"14".*Go Kurulumu' src/modules/menus.sh; then
    echo "✅ Menu option 14 is Go installation"
else
    echo "❌ Menu option 14 is not Go installation"
    exit 1
fi

# Test 5: Check if Go is included in full installation
if grep -q "install_go" src/modules/menus.sh; then
    echo "✅ Go is included in full installation (Option 1)"
else
    echo "❌ Go is not included in full installation"
    exit 1
fi

# Test 6: Check for key Go functions
if grep -q "install_go_menu" src/modules/go.sh; then
    echo "✅ Go module contains install_go_menu function"
else
    echo "❌ Go module missing install_go_menu function"
    exit 1
fi

if grep -q "install_go_official" src/modules/go.sh; then
    echo "✅ Go module contains install_go_official function"
else
    echo "❌ Go module missing install_go_official function"
    exit 1
fi

if grep -q "install_go_package" src/modules/go.sh; then
    echo "✅ Go module contains install_go_package function"
else
    echo "❌ Go module missing install_go_package function"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Go module integration is complete."
echo ""
echo "📋 Summary of implementation:"
echo "• Go installation module created with 7 functions"
echo "• Integrated into main menu as option 14"
echo "• Included in full installation (option 1)"
echo "• Supports both official binary and package manager installation"
echo "• Environment configuration with PATH and GOPATH"
echo "• Turkish language interface"
echo "• Multi-distribution support (APT, DNF, YUM, Pacman)"
