#!/bin/bash
# 1453 WSL Architect - Gum Initialization & Wrappers
# Description: Advanced Gum wrapper functions with TrueColor support and error handling
# Dependencies: src/config/theme.sh

# Load theme configuration
if [ -f "${SCRIPT_DIR}/src/config/theme.sh" ]; then
    source "${SCRIPT_DIR}/src/config/theme.sh"
fi

# ==============================================================================
# GUM INSTALLATION & CHECK
# ==============================================================================

# Ensure Gum is installed (Enhanced version of install_gum_minimal)
ensure_gum_installed() {
    if command -v gum &>/dev/null; then
        return 0
    fi

    echo "Gum is required but not installed. Installing..."
    
    # Detect package manager and install
    if command -v apt &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install -y gum
    elif command -v dnf &>/dev/null; then
        echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
        sudo dnf install -y gum
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm gum
    else
        # Fallback to binary download
        local GUM_VERSION="0.14.0"
        curl -fsSL "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_linux_x86_64.tar.gz" | tar xz
        sudo mv gum /usr/local/bin/
    fi
}

# ==============================================================================
# ADVANCED UI COMPONENTS
# ==============================================================================

# Alert Box (Red Error Box)
gum_alert() {
    local title="$1"
    local message="$2"
    
    gum style \
        --foreground "$COLOR_ERROR_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_ERROR_FG" \
        --padding "1 2" \
        --margin "1 0" \
        --align center \
        "$ICON_ERROR $title" "" "$message"
}

# Success Box (Green Info Box)
gum_success() {
    local title="$1"
    local message="$2"
    
    gum style \
        --foreground "$COLOR_SUCCESS_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_SUCCESS_FG" \
        --padding "1 2" \
        --margin "1 0" \
        --align center \
        "$ICON_SUCCESS $title" "" "$message"
}

# Info Box (Blue/Crimson Info Box)
gum_info() {
    local title="$1"
    local message="$2"
    
    gum style \
        --foreground "$COLOR_INFO_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_INFO_FG" \
        --padding "1 2" \
        --margin "1 0" \
        --align center \
        "$ICON_INFO $title" "" "$message"
}

# Password Input (Masked)
gum_password() {
    local placeholder="${1:-Şifre girin}"
    gum input --password --placeholder "$placeholder"
}

# Header (Crimson Brand Header)
gum_header() {
    local title="$1"
    local subtitle="${2:-}"
    
    if [ -n "$subtitle" ]; then
        gum style \
            --foreground "$COLOR_CRIMSON_FG" \
            --border "$STYLE_BORDER_DOUBLE" \
            --border-foreground "$COLOR_GOLD_FG" \
            --padding "1 4" \
            --margin "1 0" \
            --align center \
            --bold \
            "$title" "" "$subtitle"
    else
        gum style \
            --foreground "$COLOR_CRIMSON_FG" \
            --border "$STYLE_BORDER_DOUBLE" \
            --border-foreground "$COLOR_GOLD_FG" \
            --padding "1 4" \
            --margin "1 0" \
            --align center \
            --bold \
            "$title"
    fi
}

# Enhanced Confirm (Yes/No with styling)
gum_confirm_enhanced() {
    local prompt="$1"
    local affirm="${2:-Evet}"
    local negate="${3:-Hayır}"
    
    gum confirm "$prompt" \
        --affirmative "$affirm" \
        --negative "$negate" \
        --selected.background "$COLOR_CRIMSON_FG" \
        --selected.foreground "$COLOR_TEXT_FG"
}

# Enhanced Choose (Selection menu with styling)
gum_choose_enhanced() {
    local header="$1"
    shift
    
    gum choose \
        --header "$header" \
        --cursor.foreground "$COLOR_CRIMSON_FG" \
        --item.foreground "$COLOR_TEXT_FG" \
        --selected.foreground "$COLOR_GOLD_FG" \
        "$@"
}
