#!/bin/bash

# 1453.AI WSL Vibe Coder'lar İçin Otomatik Kurulum Scripti
# Version: 2.0 - Modular Architecture
# GitHub: https://github.com/altudev/1453-wsl-bash-script

# FIX BUG-002: Add safety flags for robust error handling
# Note: set -e may affect sourced modules, but this is an entry point script
set -eo pipefail

# Get the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Phase 1: Critical initialization (CRLF must run first)
# shellcheck source=lib/init.sh
source "${SCRIPT_DIR}/lib/init.sh"

# Phase 2: Load configurations
# shellcheck source=config/colors.sh
source "${SCRIPT_DIR}/config/colors.sh"

# shellcheck source=config/constants.sh
source "${SCRIPT_DIR}/config/constants.sh"

# shellcheck source=config/php-versions.sh
source "${SCRIPT_DIR}/config/php-versions.sh"

# shellcheck source=config/tool-versions.sh
source "${SCRIPT_DIR}/config/tool-versions.sh"

# shellcheck source=config/banner.sh
source "${SCRIPT_DIR}/config/banner.sh"

# Phase 3: Load core libraries
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# shellcheck source=lib/package-manager.sh
source "${SCRIPT_DIR}/lib/package-manager.sh"

# shellcheck source=lib/installation-tracker.sh
source "${SCRIPT_DIR}/lib/installation-tracker.sh"

# shellcheck source=lib/tui.sh
source "${SCRIPT_DIR}/lib/tui.sh"

# Phase 4: Load feature modules
# shellcheck source=modules/python.sh
source "${SCRIPT_DIR}/modules/python.sh"

# shellcheck source=modules/javascript.sh
source "${SCRIPT_DIR}/modules/javascript.sh"

# shellcheck source=modules/go.sh
source "${SCRIPT_DIR}/modules/go.sh"

# shellcheck source=modules/docker.sh
source "${SCRIPT_DIR}/modules/docker.sh"

# shellcheck source=modules/php.sh
source "${SCRIPT_DIR}/modules/php.sh"

# shellcheck source=modules/modern-tools.sh
source "${SCRIPT_DIR}/modules/modern-tools.sh"

# shellcheck source=modules/shell-setup.sh
source "${SCRIPT_DIR}/modules/shell-setup.sh"

# shellcheck source=modules/ai-cli.sh
source "${SCRIPT_DIR}/modules/ai-cli.sh"

# shellcheck source=modules/ai-frameworks.sh
source "${SCRIPT_DIR}/modules/ai-frameworks.sh"

# shellcheck source=modules/quickstart.sh
source "${SCRIPT_DIR}/modules/quickstart.sh"

# shellcheck source=modules/cleanup.sh
source "${SCRIPT_DIR}/modules/cleanup.sh"

# shellcheck source=modules/menus.sh
source "${SCRIPT_DIR}/modules/menus.sh"

# Phase 5: Fix stdin for interactive mode
# CRITICAL FIX: stdin might be in nonblocking mode, causing read to return immediately
# Fix nonblocking stdin first, then redirect to /dev/tty

# Fix nonblocking stdin issue - try multiple methods
if command -v perl &>/dev/null; then
    perl -MFcntl -e 'fcntl STDIN, F_SETFL, fcntl(STDIN, F_GETFL, 0) & ~O_NONBLOCK' 2>/dev/null
elif command -v python3 &>/dev/null; then
    python3 -c "import fcntl, os; flags = fcntl.fcntl(0, fcntl.F_GETFL); fcntl.fcntl(0, fcntl.F_SETFL, flags & ~os.O_NONBLOCK)" 2>/dev/null
elif command -v python &>/dev/null; then
    python -c "import fcntl, os; flags = fcntl.fcntl(0, fcntl.F_GETFL); fcntl.fcntl(0, fcntl.F_SETFL, flags & ~os.O_NONBLOCK)" 2>/dev/null
fi

# Redirect stdin to /dev/tty
if [ -e /dev/tty ]; then
    exec 0</dev/tty
fi

# Phase 6: Sudo authentication and keep-alive
# Request sudo password once at the start
echo -e "${YELLOW}[BİLGİ]${NC} Script bazı işlemler için sudo yetkisi gerektirir."
echo -e "${YELLOW}[BİLGİ]${NC} Lütfen bir kez sudo şifrenizi girin..."

if sudo -v; then
    echo -e "${GREEN}[✓]${NC} Sudo yetkisi alındı"

    # FIX BUG-012: Set trap BEFORE starting background process to prevent race condition
    # Cleanup function to kill background process on exit
    cleanup_sudo() {
        if [ -n "${SUDO_KEEPALIVE_PID:-}" ]; then
            kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
        fi
    }
    trap cleanup_sudo EXIT INT TERM

    # Keep-alive: update sudo timestamp in background every 60 seconds
    # This prevents repeated password prompts during long installations
    # CRITICAL: Close stdin/stdout/stderr to prevent blocking
    (
        while true; do
            sleep 60
            sudo -v
        done
    ) </dev/null >/dev/null 2>&1 &
    SUDO_KEEPALIVE_PID=$!
else
    echo -e "${YELLOW}[!]${NC} Sudo yetkisi verilmedi, bazı işlemler başarısız olabilir."
fi

echo ""

# Phase 7: Initialize TUI and run main program
init_tui
show_banner
main "$@"
