#!/bin/bash

# FIX BUG-002: Add safety flags for robust error handling
set -eo pipefail

# Test script to verify install_go_menu function is available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the main script components needed
source "${SCRIPT_DIR}/src/lib/init.sh"
source "${SCRIPT_DIR}/src/config/colors.sh"
source "${SCRIPT_DIR}/src/lib/common.sh"
source "${SCRIPT_DIR}/src/lib/package-manager.sh"
source "${SCRIPT_DIR}/src/modules/go.sh"

# Check if install_go_menu function exists
if declare -f install_go_menu > /dev/null; then
    echo "✅ SUCCESS: install_go_menu function is available!"
    echo "Function type:"
    type install_go_menu
else
    echo "❌ FAIL: install_go_menu function is NOT available!"
fi
