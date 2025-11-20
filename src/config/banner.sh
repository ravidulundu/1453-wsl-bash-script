#!/bin/bash
# Banner and ASCII Art Configuration
# This file contains the script banner and header display functions

# Function to display the banner
show_banner() {
    clear

    # Check if Gum is available for modern display
    if command -v gum &>/dev/null; then
        # Modern Gum banner
        gum style \
            --foreground 51 --bold \
            --align center --width 80 \
            '   /$$ /$$   /$$ /$$$$$$$   /$$$$$$ ' \
            ' /$$$$| $$  | $$| $$____/  /$$__  $$' \
            '|_  $$| $$  | $$| $$      |__/  \ $$' \
            '  | $$| $$$$$$$$| $$$$$$$    /$$$$$$/' \
            '  | $$|_____  $$|_____  $$  |___  $$' \
            '  | $$      | $$ /$$  \ $$ /$$  \ $$' \
            ' /$$$$$$    | $$|  $$$$$$/|  $$$$$$/' \
            '|______/    |__/ \______/  \______/ '

        echo ""

        gum style \
            --foreground 212 --border rounded --align center \
            --width 76 --padding "1 2" \
            "1453.AI - WSL Vibe Coder'lar İçin Otomatik Kurulum Rehberi"

        echo ""

        gum style --foreground 226 "📌 Script Sürümü: v2.0 Modular"
        gum style --foreground 51 "🔗 GitHub: https://github.com/ravidulundu/1453-wsl-bash-script"
        gum style --foreground 141 "📅 Tarih: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
    else
        # Traditional ASCII banner (fallback)
        echo -e "${CYAN}"
        echo '   /$$ /$$   /$$ /$$$$$$$   /$$$$$$ '
        echo ' /$$$$| $$  | $$| $$____/  /$$__  $$'
        echo '|_  $$| $$  | $$| $$      |__/  \\ $$'
        echo '  | $$| $$$$$$$$| $$$$$$$    /$$$$$$/'
        echo '  | $$|_____  $$|_____  $$  |___  $$'
        echo '  | $$      | $$ /$$  \\ $$ /$$  \\ $$'
        echo ' /$$$$$$    | $$|  $$$$$$/|  $$$$$$/'
        echo '|______/    |__/ \\______/  \\______/ '
        echo -e "${NC}"
        echo ""

        echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   1453.AI - WSL Vibe Coder'lar İçin Otomatik Kurulum Rehberi   ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\\n"

        # Script Information
        echo -e "${YELLOW}Script Sürümü:${NC} v2.0 Modular"
        echo -e "${YELLOW}GitHub:${NC} https://github.com/ravidulundu/1453-wsl-bash-script"
        echo -e "${YELLOW}Tarih:${NC} $(date '+%Y-%m-%d %H:%M:%S')\\n"
    fi
}

# Export the function so it's available to other modules
export -f show_banner