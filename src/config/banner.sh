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

    if command -v gum &> /dev/null; then
        echo ""
        gum style --foreground 212 --bold "🚀 1453 WSL Setup v2.4"
        gum style --foreground 99 "Automated Development Environment for AI Coders"
        echo ""
    else
        # Fallback for when gum is not yet installed
        echo ""
        echo "========================================================================"
        echo "  🚀 1453 WSL Setup v2.4 - Automated Development Environment"
        echo "========================================================================"
        echo ""
        echo "  GitHub:  github.com/ravidulundu/1453-wsl-bash-script"
        echo "  Date:    $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "========================================================================"
        echo ""
    fi
}

# Export the function and variable so they're available to other modules
export BANNER_SHOWN
export -f show_banner