#!/bin/bash
# Banner and ASCII Art Configuration
# This file contains the script banner and header display functions

# Track if banner has been shown (prevents flicker)
BANNER_SHOWN=0

# Function to display the banner (AI CLI Style)
show_banner() {
    # ONLY clear screen on first call (prevents flicker)
    if [ "$BANNER_SHOWN" -eq 0 ]; then
        clear
        BANNER_SHOWN=1
    fi

    if command -v gum &>/dev/null; then
        gum style \
            --border double \
            --margin "1 2" \
            --padding "1 4" \
            --border-foreground 212 \
            --foreground 212 \
            --align center \
            "1453.AI WSL Setup" \
            "Automated Development Environment" \
            "" \
            "v2.0 Modular"
    else
        # Fallback for when gum is not yet installed
        local width=70
        local separator=$(printf '%*s' "$width" '' | tr ' ' '=')
        
        echo ""
        echo "$separator"
        echo "  1453.AI WSL Setup - Automated Development Environment"
        echo "$separator"
        echo ""
        echo "  Version: v2.0 Modular"
        echo "  GitHub:  github.com/ravidulundu/1453-wsl-bash-script"
        echo "  Date:    $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "$separator"
        echo ""
    fi
}

# Export the function and variable so they're available to other modules
export BANNER_SHOWN
export -f show_banner