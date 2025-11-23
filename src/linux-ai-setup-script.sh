#!/bin/bash

# 1453.AI WSL Vibe Coder'lar İçin Otomatik Kurulum Scripti
# Version: 2.0 - Modular Architecture
# GitHub: https://github.com/ravidulundu/1453-wsl-bash-script

# FIX BUG-002: Add safety flags for robust error handling
# Note: set -e may affect sourced modules, but this is an entry point script
# SECURITY FIX: Added -u flag to catch undefined variable usage (prevents rm -rf $UNDEF/ scenarios)
set -euo pipefail

# Get the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Phase 1: Critical initialization (CRLF must run first)
# shellcheck source=lib/init.sh
source "${SCRIPT_DIR}/lib/init.sh"

# Phase 2: Load configurations
# shellcheck source=config/colors.sh
source "${SCRIPT_DIR}/config/colors.sh"

# shellcheck source=config/theme.sh
source "${SCRIPT_DIR}/config/theme.sh"

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

# shellcheck source=lib/gum-init.sh
source "${SCRIPT_DIR}/lib/gum-init.sh"

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

# CRITICAL FIX: Don't use exec for stdin redirection
# exec causes the script to hang when stdin is already redirected
# Instead, all read operations will explicitly use /dev/tty or safe_read
# This line is commented out to prevent hanging
# if [ -e /dev/tty ]; then
#     exec 0</dev/tty 2>/dev/null || true
# fi

# Phase 6: Initialize tool versions (must be called before any installations)
echo -e "${YELLOW}[BİLGİ]${NC} Araç versiyonları hazırlanıyor..."
init_tool_versions
echo -e "${GREEN}[[+]]${NC} Araç versiyonları hazır"

# Phase 7: Ensure Gum is installed for modern TUI (critical dependency)
# Moved before sudo auth to allow using gum for password input
if ! command -v gum &>/dev/null; then
    echo -e "${YELLOW}[BİLGİ]${NC} Modern TUI (Gum) kuruluyor..."
    if command -v ensure_gum_installed &>/dev/null; then
        ensure_gum_installed 2>/dev/null || echo -e "${YELLOW}[!]${NC} Gum kurulamadı, klasik TUI kullanılacak"
    fi
fi

# Phase 8: Sudo authentication and keep-alive
# Request sudo password once at the start
echo -e "${YELLOW}[BİLGİ]${NC} Script bazı işlemler için sudo yetkisi gerektirir."

# Authenticate with sudo (using Gum if available)
sudo_success=0
if command -v gum &>/dev/null; then
    # Use Gum for password input (masked)
    # Loop up to 3 times for incorrect password
    for i in {1..3}; do
        if gum_password "Sudo şifresi (Gerekli)" | sudo -S -v 2>/dev/null; then
            sudo_success=1
            break
        fi
        gum_alert "Hata" "Yanlış şifre, lütfen tekrar deneyin ($i/3)"
    done
else
    # Fallback to standard sudo prompt
    echo -e "${YELLOW}[BİLGİ]${NC} Lütfen bir kez sudo şifrenizi girin..."
    if sudo -v; then
        sudo_success=1
    fi
fi

if [ $sudo_success -eq 1 ]; then
    echo -e "${GREEN}[[+]]${NC} Sudo yetkisi alındı"
    echo -e "${YELLOW}[DEBUG]${NC} Trap kuruluyor..." >&2

    # FIX BUG-012: Set trap BEFORE starting background process to prevent race condition
    # Cleanup function to kill background process on exit
    cleanup_sudo() {
        if [ -n "${SUDO_KEEPALIVE_PID:-}" ]; then
            kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
        fi
    }
    trap cleanup_sudo EXIT INT TERM
    echo -e "${YELLOW}[DEBUG]${NC} Trap kuruldu" >&2

    echo -e "${YELLOW}[DEBUG]${NC} Background process başlatılıyor..." >&2
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
    echo -e "${YELLOW}[DEBUG]${NC} Background PID: $SUDO_KEEPALIVE_PID" >&2
else
    echo -e "${YELLOW}[!]${NC} Sudo yetkisi verilmedi, bazı işlemler başarısız olabilir."
    # Optional: Exit if sudo is strictly required
    # exit 1
fi

# Phase 8: Initialize TUI and run main program
init_tui
echo -e "${YELLOW}[DEBUG]${NC} init_tui tamamlandı" >&2
echo -e "${YELLOW}[DEBUG]${NC} main çağrılıyor..." >&2
# NOTE: show_banner() will be called by show_mode_selection() inside main()
# Don't call it here to prevent double banner display
main "$@"
