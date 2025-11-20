#!/bin/bash
# Banner and ASCII Art Configuration
# This file contains the script banner and header display functions

# Function to display the banner
show_banner() {
    clear

    # Check if Gum is available for modern display
    if command -v gum &>/dev/null; then
        # Calculate responsive widths based on terminal size
        local ascii_width=80
        local title_width=76
        local info_width=76

        # If terminal is wider than 80, use dynamic widths
        if [ -n "${TUI_WIDTH:-}" ] && [ "$TUI_WIDTH" -gt 80 ]; then
            ascii_width=$TUI_WIDTH
            title_width=$((TUI_WIDTH - 4))
            info_width=$((TUI_WIDTH - 4))
        fi

        # Modern Gum banner - ASCII art (responsive)
        gum style \
            --foreground 51 --bold \
            --align center --width "$ascii_width" \
            '   /$$ /$$   /$$ /$$$$$$$   /$$$$$$ ' \
            ' /$$$$| $$  | $$| $$____/  /$$__  $$' \
            '|_  $$| $$  | $$| $$      |__/  \ $$' \
            '  | $$| $$$$$$$$| $$$$$$$    /$$$$$$/' \
            '  | $$|_____  $$|_____  $$  |___  $$' \
            '  | $$      | $$ /$$  \ $$ /$$  \ $$' \
            ' /$$$$$$    | $$|  $$$$$$/|  $$$$$$/' \
            '|______/    |__/ \______/  \______/ '

        echo ""

        # Title box (responsive)
        gum style \
            --foreground 212 --border rounded --align center \
            --width "$title_width" --padding "1 2" \
            "1453.AI - WSL Vibe Coder'lar İçin Otomatik Kurulum Rehberi"

        echo ""

        # Info lines (centered + responsive)
        gum style --foreground 226 --align center --width "$info_width" "📌 Script Sürümü: v2.0 Modular"
        gum style --foreground 51 --align center --width "$info_width" "🔗 GitHub: https://github.com/ravidulundu/1453-wsl-bash-script"
        gum style --foreground 141 --align center --width "$info_width" "📅 Tarih: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
    else
        # Traditional ASCII banner (fallback with padding)
        echo ""
        echo -e "  ${CYAN}"
        echo '     /$$ /$$   /$$ /$$$$$$$   /$$$$$$ '
        echo '   /$$$$| $$  | $$| $$____/  /$$__  $$'
        echo '  |_  $$| $$  | $$| $$      |__/  \ $$'
        echo '    | $$| $$$$$$$$| $$$$$$$    /$$$$$$/'
        echo '    | $$|_____  $$|_____  $$  |___  $$'
        echo '    | $$      | $$ /$$  \ $$ /$$  \ $$'
        echo '   /$$$$$$    | $$|  $$$$$$/|  $$$$$$/'
        echo '  |______/    |__/ \______/  \______/ '
        echo -e "${NC}"
        echo ""

        echo -e "  ${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${BLUE}║   1453.AI - WSL Vibe Coder'lar İçin Otomatik Kurulum Rehberi   ║${NC}"
        echo -e "  ${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        # Script Information (with padding)
        echo -e "  ${YELLOW}Script Sürümü:${NC} v2.0 Modular"
        echo -e "  ${YELLOW}GitHub:${NC} https://github.com/ravidulundu/1453-wsl-bash-script"
        echo -e "  ${YELLOW}Tarih:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
    fi
}

# Export the function so it's available to other modules
export -f show_banner