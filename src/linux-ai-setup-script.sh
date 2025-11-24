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

# PRD: Load AI text effects library for streaming text and thinking states
# shellcheck source=lib/ai-text.sh
source "${SCRIPT_DIR}/lib/ai-text.sh"

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
# PRD: Use AI thinking state instead of raw echo
if command -v gum &>/dev/null; then
    show_ai_thinking "init" 1
else
    echo "Araç versiyonları hazırlanıyor..."
fi

init_tool_versions

if command -v gum &>/dev/null; then
    gum_success "Hazırlık Tamamlandı" "Araç versiyonları yüklendi"
else
    echo -e "${GREEN}[[+]]${NC} Araç versiyonları hazır"
fi

# Phase 7: Ensure Gum is installed for modern TUI (critical dependency)
# PRD Requirement: Modern UI framework must be available
# Moved before sudo auth to allow using gum for password input
if ! command -v gum &>/dev/null; then
    echo "🎨 Modern TUI (Gum) kuruluyor..."
    if command -v ensure_gum_installed &>/dev/null; then
        if ensure_gum_installed 2>/dev/null; then
            echo "✅ Gum başarıyla kuruldu"
        else
            echo "⚠️  Gum kurulamadı, klasik TUI kullanılacak"
        fi
    fi
fi

# Phase 8: Sudo authentication and keep-alive
# PRD Requirement: Use gum for password input (FR-2.3)
# Request sudo password once at the start
if command -v gum &>/dev/null; then
    gum_info "Yetkilendirme" "Script bazı işlemler için sudo yetkisi gerektirir"
else
    echo "Script bazı işlemler için sudo yetkisi gerektirir."
fi

echo ""

# Authenticate with sudo (using Gum if available)
sudo_success=0
if command -v gum &>/dev/null; then
    # Use Gum for password input (masked) - PRD FR-2.3
    # Loop up to 3 times for incorrect password
    for i in {1..3}; do
        if gum_password "🔑 Sudo şifresi (Gerekli)" | sudo -S -v 2>/dev/null; then
            sudo_success=1
            break
        fi
        gum_alert "Yanlış Şifre" "Lütfen tekrar deneyin ($i/3)"
    done
else
    # Fallback to standard sudo prompt
    echo "Lütfen bir kez sudo şifrenizi girin..."
    if sudo -v; then
        sudo_success=1
    fi
fi

if [ $sudo_success -eq 1 ]; then
    if command -v gum &>/dev/null; then
        gum_success "Yetkilendirme Başarılı" "Sudo yetkisi alındı"
    else
        echo -e "${GREEN}[[+]]${NC} Sudo yetkisi alındı"
    fi
    # DEBUG: Trap kuruluyor...

    # FIX BUG-012: Set trap BEFORE starting background process to prevent race condition
    # Cleanup function to kill background process on exit
    cleanup_sudo() {
        if [ -n "${SUDO_KEEPALIVE_PID:-}" ]; then
            kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
        fi
    }
    trap cleanup_sudo EXIT INT TERM
    # DEBUG: Trap kuruldu

    # DEBUG: Background process başlatılıyor...
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
    # DEBUG: Background PID: $SUDO_KEEPALIVE_PID
else
    if command -v gum &>/dev/null; then
        gum_warning "Yetki Yok" "Sudo yetkisi verilmedi, bazı işlemler başarısız olabilir"
    else
        echo -e "${YELLOW}[!]${NC} Sudo yetkisi verilmedi, bazı işlemler başarısız olabilir."
    fi
    # Optional: Exit if sudo is strictly required
    # exit 1
fi

# Phase 9: Initialize TUI and run main program
# PRD: Show AI-like welcome before main execution
init_tui
# DEBUG: init_tui tamamlandı

# PRD FR-1.2: Show banner with double border gold theme
if command -v show_banner &>/dev/null; then
    show_banner
fi

# DEBUG: main çağrılıyor...

# PRD: AI-like initialization message
if command -v gum &>/dev/null; then
    echo ""
    show_ai_thinking "analyzing" 2
    echo ""
fi

main "$@"
