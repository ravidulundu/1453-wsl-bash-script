#!/bin/bash
# Banner and ASCII Art Configuration
# This file contains the script banner and header display functions
# Updated for 1453 WSL Architect (Blueprint Phase 1)

# Track if banner has been shown (prevents flicker)
BANNER_SHOWN=0

# Function to display the banner (Architect Style)
show_banner() {
    # Show banner ONLY once (PRD compliance - clean AI Agent experience)
    if [ "$BANNER_SHOWN" -eq 1 ]; then
        return 0
    fi

    # Clear screen and mark as shown
    clear
    BANNER_SHOWN=1

    # Check if gum-init functions are available (via linux-ai-setup-script.sh)
    if command -v gum_header &> /dev/null; then
        echo ""
        # Use the new Crimson/Gold theme via gum_header wrapper
        gum_header "1453 WSL ARCHITECT" "Automated Development Environment v2.5"
        
        # System Info (Blueprint FR-1.3)
        local wsl_info="WSL Detected"
        if [ -f /etc/os-release ]; then
            # Extract pretty name safely
            local distro_name
            distro_name=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d'"' -f2)
            wsl_info="$distro_name"
        fi
        
        # Display system info in muted color
        if command -v typewriter_effect &>/dev/null; then
            # PRD: Streaming Text - Daktilo efekti ile göster
            typewriter_effect "System: $wsl_info | User: $USER | Date: $(date '+%Y-%m-%d')" 0.02
        else
            gum style \
                --foreground "$COLOR_MUTED_FG" \
                --align center \
                "System: $wsl_info | User: $USER | Date: $(date '+%Y-%m-%d')"
        fi
            
        echo ""
    elif command -v gum &> /dev/null; then
        # Fallback to raw gum if wrappers not loaded yet
        echo ""
        gum style \
            --foreground 212 \
            --border double \
            --border-foreground 220 \
            --padding "1 4" \
            --align center \
            --bold \
            "1453 WSL ARCHITECT" "" "Automated Development Environment v2.5"
        echo ""
    else
        # Fallback for when gum is not yet installed (ASCII Art)
        echo ""
        echo -e "${ANSI_CRIMSON}========================================================================${ANSI_RESET}"
        echo -e "${ANSI_GOLD}  🚀 1453 WSL ARCHITECT v2.5${ANSI_RESET}"
        echo -e "${ANSI_CRIMSON}========================================================================${ANSI_RESET}"
        echo ""
        echo "  System:  $(grep "^PRETTY_NAME=" /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo 'Linux')"
        echo "  User:    $USER"
        echo "  Date:    $(date '+%Y-%m-%d')"
        echo ""
        echo -e "${ANSI_CRIMSON}========================================================================${ANSI_RESET}"
        echo ""
    fi
}

# Export the function and variable so they're available to other modules
export BANNER_SHOWN
export -f show_banner