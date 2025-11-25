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
# PRD: Responsive design with centered layout
gum_alert() {
    local title="$1"
    local message="$2"

    # Responsive width calculation
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local box_width=$((term_width > 70 ? 70 : term_width - 4))

    gum style \
        --foreground "$COLOR_ERROR_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_ERROR_FG" \
        --width "$box_width" \
        --padding "1 2" \
        --margin "1 0" \
        --align center \
        "$ICON_ERROR $title" "" "$message"
}

# Success Box (Green Info Box)
# PRD: Responsive design with centered layout
gum_success() {
    local title="$1"
    local message="$2"

    # Responsive width calculation
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local box_width=$((term_width > 70 ? 70 : term_width - 4))

    gum style \
        --foreground "$COLOR_SUCCESS_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_SUCCESS_FG" \
        --width "$box_width" \
        --padding "1 2" \
        --margin "1 0" \
        --align center \
        "$ICON_SUCCESS $title" "" "$message"
}

# Info Box (Blue/Crimson Info Box)
# PRD: Responsive design with centered layout
gum_info() {
    local title="$1"
    local message="$2"

    # Responsive width calculation
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local box_width=$((term_width > 70 ? 70 : term_width - 4))

    gum style \
        --foreground "$COLOR_INFO_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_INFO_FG" \
        --width "$box_width" \
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
# PRD: Responsive design - adjusts to terminal width
gum_header() {
    local title="$1"
    local subtitle="${2:-}"

    # Get terminal width and calculate responsive box width
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local box_width=$((term_width > 80 ? 80 : term_width - 4))

    if [ -n "$subtitle" ]; then
        gum style \
            --foreground "$COLOR_CRIMSON_FG" \
            --border "$STYLE_BORDER_DOUBLE" \
            --border-foreground "$COLOR_GOLD_FG" \
            --width "$box_width" \
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
            --width "$box_width" \
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

# Spinner with Log Hiding (Executes command, hides output, shows logs on error)
gum_spin_run() {
    local title="$1"
    local command="$2"
    local log_file="/tmp/1453-install-$(date +%s).log"
    
    # Run command with spinner
    if gum spin --spinner dot --title "$title" --show-output -- bash -c "$command > $log_file 2>&1"; then
        # Success
        rm -f "$log_file"
        return 0
    else
        # Failure
        gum_alert "Hata Oluştu" "İşlem başarısız oldu. Loglar aşağıdadır:"
        echo ""
        cat "$log_file"
        echo ""
        rm -f "$log_file"
        return 1
    fi
}

# ==============================================================================
# ADDITIONAL WRAPPERS (PRD Compliance)
# ==============================================================================

# Warning Box (Orange Warning Box)
# PRD Requirement: Contextual warnings with proper styling + responsive design
gum_warning() {
    local title="$1"
    local message="$2"

    # Responsive width calculation
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local box_width=$((term_width > 70 ? 70 : term_width - 4))

    gum style \
        --foreground "$COLOR_WARNING_FG" \
        --border "$STYLE_BORDER_ROUNDED" \
        --border-foreground "$COLOR_WARNING_FG" \
        --width "$box_width" \
        --padding "1 2" \
        --margin "1 0" \
        --align center \
        "$ICON_WARNING $title" "" "$message"
}

# Thinking State Animation
# PRD Requirement: FR-2.4 - Never leave user with blank cursor
# Usage: gum_thinking "Analyzing system..." [duration]
gum_thinking() {
    local message="$1"
    local duration="${2:-2}"
    
    gum spin --spinner dots --title "$message" -- sleep "$duration"
}

# Enhanced Spin with better error handling
# PRD Requirement: FR-3.2 - Error management with user options
# Usage: gum_spin_enhanced "title" "command"
# Returns: 0 on success, prompts user on failure
gum_spin_enhanced() {
    local title="$1"
    local command="$2"
    local log_file="/tmp/1453-install-$(date +%s).log"
    
    # Run command with spinner
    if gum spin --spinner dot --title "$title" -- bash -c "$command > $log_file 2>&1"; then
        # Success - cleanup log
        rm -f "$log_file"
        return 0
    else
        # Failure - show alert with options
        gum_alert "İşlem Başarısız" "$title sırasında hata oluştu"
        
        echo ""
        local choice=$(gum choose "Logları Göster" "Yeniden Dene" "Atla" --header "Ne yapmak istersiniz?")
        
        case "$choice" in
            "Logları Göster")
                echo ""
                gum format --type markdown "## 📋 Hata Logları"
                echo ""
                cat "$log_file"
                echo ""
                rm -f "$log_file"
                
                # Ask again after showing logs
                if gum confirm "Yeniden denemek ister misiniz?"; then
                    gum_spin_enhanced "$title" "$command"
                    return $?
                fi
                return 1
                ;;
            "Yeniden Dene")
                rm -f "$log_file"
                gum_spin_enhanced "$title" "$command"
                return $?
                ;;
            "Atla")
                rm -f "$log_file"
                return 1
                ;;
        esac
    fi
}

# Markdown render wrapper
# PRD Requirement: Use gum format instead of raw echo
# Usage: gum_markdown "## Title\n\nContent"
gum_markdown() {
    local content="$1"
    echo "$content" | gum format --type markdown
}

# Multi-select with enhanced styling
# Usage: gum_multiselect "header" "option1" "option2" "option3"
gum_multiselect() {
    local header="$1"
    shift
    
    gum choose --no-limit \
        --header "$header" \
        --cursor.foreground "$COLOR_CRIMSON_FG" \
        --item.foreground "$COLOR_TEXT_FG" \
        --selected.foreground "$COLOR_GOLD_FG" \
        "$@"
}

# Fuzzy filter with styling
# PRD Requirement: FR-2.2 - Fuzzy search for file selection
# Usage: echo -e "opt1\nopt2\nopt3" | gum_filter_enhanced "placeholder"
gum_filter_enhanced() {
    local placeholder="${1:-Arama yapın...}"
    
    gum filter \
        --placeholder "$placeholder" \
        --indicator "▶" \
        --indicator.foreground "$COLOR_CRIMSON_FG" \
        --match.foreground "$COLOR_GOLD_FG"
}

# Export new functions
export -f gum_warning
export -f gum_thinking
export -f gum_spin_enhanced
export -f gum_markdown
export -f gum_multiselect
export -f gum_filter_enhanced

# Standard Confirm Wrapper (Alias for enhanced)
gum_confirm() {
    gum_confirm_enhanced "$@"
}

# Input Wrapper
gum_input() {
    gum input \
        --cursor.foreground "$COLOR_CRIMSON_FG" \
        --prompt.foreground "$COLOR_GOLD_FG" \
        "$@"
}

export -f gum_confirm
export -f gum_input
