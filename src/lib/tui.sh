#!/bin/bash
# TUI Library - Terminal User Interface
# Hybrid approach: Dialog (if available) + Pure Bash fallback

# Global TUI state
TUI_MODE="bash"  # "dialog" or "bash"
TUI_WIDTH=70
TUI_HEIGHT=20

# Initialize TUI system
init_tui() {
    echo "[DEBUG TUI] Starting init_tui..." >&2

    # Check if dialog is available
    if command -v dialog &>/dev/null; then
        TUI_MODE="dialog"
        export DIALOGRC="${DIALOGRC:-}"
        echo "[DEBUG TUI] Dialog mode enabled" >&2
    else
        TUI_MODE="bash"
        echo "[DEBUG TUI] Bash mode (no dialog)" >&2
    fi

    # Get terminal dimensions
    echo "[DEBUG TUI] Getting terminal dimensions..." >&2
    if command -v tput &>/dev/null && [ -n "${TERM:-}" ]; then
        echo "[DEBUG TUI] Using tput..." >&2
        TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)
        TUI_HEIGHT=$(tput lines 2>/dev/null || echo 24)
        echo "[DEBUG TUI] Dimensions: ${TUI_WIDTH}x${TUI_HEIGHT}" >&2
    else
        TUI_WIDTH=80
        TUI_HEIGHT=24
        echo "[DEBUG TUI] Using defaults: 80x24" >&2
    fi

    # Ensure minimum dimensions
    [ -n "$TUI_WIDTH" ] && [ "$TUI_WIDTH" -lt 70 ] && TUI_WIDTH=70
    [ -n "$TUI_HEIGHT" ] && [ "$TUI_HEIGHT" -lt 20 ] && TUI_HEIGHT=20

    echo "[DEBUG TUI] init_tui completed!" >&2
}

# ═══════════════════════════════════════════════════════════
# PROGRESS BAR FUNCTIONS
# ═══════════════════════════════════════════════════════════

# Show progress bar
# Usage: show_progress_bar <current> <total> <message>
show_progress_bar() {
    local current=$1
    local total=$2
    local message="${3:-Processing...}"
    local percentage=$((current * 100 / total))

    if [ "$TUI_MODE" = "dialog" ]; then
        echo "$percentage" | dialog --gauge "$message" 7 50 0
    else
        # Pure bash progress bar
        local filled=$((percentage / 2))
        local empty=$((50 - filled))

        echo -ne "\r${CYAN}${message}${NC}\n"
        echo -ne "${CYAN}[${NC}"
        printf "%0.s█" $(seq 1 $filled)
        printf "%0.s░" $(seq 1 $empty)
        echo -ne "${CYAN}]${NC} ${GREEN}${percentage}%${NC}"
    fi
}

# Show spinner with message
# Usage: show_spinner <message> &
#        SPINNER_PID=$!
#        ... do work ...
#        kill $SPINNER_PID
show_spinner() {
    local message="${1:-Loading...}"
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local delay=0.1

    while true; do
        for (( i=0; i<${#spinstr}; i++ )); do
            echo -ne "\r${YELLOW}${spinstr:$i:1}${NC} ${message}  "
            sleep $delay
        done
    done
}

# Show installation progress with status icons
# Usage: show_install_status <item> <status>
# Status: pending, installing, success, failed, skipped
show_install_status() {
    local item="$1"
    local status="$2"
    local icon=""
    local color=""
    local status_text=""

    case "$status" in
        "pending")
            icon="○"
            color="$CYAN"
            status_text="Pending"
            ;;
        "installing")
            icon="⚙"
            color="$YELLOW"
            status_text="Installing..."
            ;;
        "success")
            icon="✓"
            color="$GREEN"
            status_text="Completed"
            ;;
        "failed")
            icon="✗"
            color="$RED"
            status_text="Failed"
            ;;
        "skipped")
            icon="⊘"
            color="$YELLOW"
            status_text="Skipped"
            ;;
    esac

    printf "  ${color}[%s]${NC} %-30s %s\n" "$icon" "$item" "$status_text"
}

# ═══════════════════════════════════════════════════════════
# BOX DRAWING FUNCTIONS
# ═══════════════════════════════════════════════════════════

# Draw a box with title
# Usage: draw_box <title> <width>
draw_box_top() {
    local title="$1"
    local width="${2:-70}"
    local title_len=${#title}
    local padding=$(( (width - title_len - 4) / 2 ))

    echo -e "${CYAN}╔$(printf '%0.s═' $(seq 1 $((width-2))))╗${NC}"
    echo -ne "${CYAN}║${NC}"
    printf "%0.s " $(seq 1 $padding)
    echo -ne "${YELLOW}${title}${NC}"
    printf "%0.s " $(seq 1 $((width - title_len - padding - 2)))
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}╠$(printf '%0.s═' $(seq 1 $((width-2))))╣${NC}"
}

draw_box_middle() {
    local content="$1"
    local width="${2:-70}"
    local content_len=${#content}
    local padding=$((width - content_len - 4))

    echo -ne "${CYAN}║${NC} "
    echo -ne "${content}"
    printf "%0.s " $(seq 1 $padding)
    echo -e " ${CYAN}║${NC}"
}

draw_box_bottom() {
    local width="${1:-70}"
    echo -e "${CYAN}╚$(printf '%0.s═' $(seq 1 $((width-2))))╝${NC}"
}

# ═══════════════════════════════════════════════════════════
# INSTALLATION PROGRESS DISPLAY
# ═══════════════════════════════════════════════════════════

# Global installation tracking
declare -A INSTALL_STATUS
INSTALL_TOTAL=0
INSTALL_CURRENT=0

# Initialize installation progress
init_install_progress() {
    local -n items=$1
    INSTALL_TOTAL=${#items[@]}
    INSTALL_CURRENT=0

    for item in "${items[@]}"; do
        INSTALL_STATUS["$item"]="pending"
    done
}

# Update installation progress
update_install_progress() {
    local item="$1"
    local status="$2"

    INSTALL_STATUS["$item"]="$status"

    if [ "$status" = "success" ] || [ "$status" = "failed" ] || [ "$status" = "skipped" ]; then
        ((INSTALL_CURRENT++))
    fi
}

# Display full installation progress
display_install_progress() {
    clear

    draw_box_top "🚀 1453.AI WSL Setup - Installation Progress" 70
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"

    # Show each item status
    for item in "${!INSTALL_STATUS[@]}"; do
        local status="${INSTALL_STATUS[$item]}"
        local line=$(show_install_status "$item" "$status")
        draw_box_middle "$line" 70
    done

    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"

    # Show total progress
    local percentage=$((INSTALL_CURRENT * 100 / INSTALL_TOTAL))
    local filled=$((percentage / 2))
    local empty=$((50 - filled))

    local progress_line="  Total Progress: "
    progress_line+="$(printf '%0.s█' $(seq 1 $filled))"
    progress_line+="$(printf '%0.s░' $(seq 1 $empty))"
    progress_line+=" ${percentage}%"

    draw_box_middle "$progress_line" 70

    draw_box_bottom 70
}

# ═══════════════════════════════════════════════════════════
# MENU FUNCTIONS
# ═══════════════════════════════════════════════════════════

# Show menu (Dialog or Pure Bash)
# Usage: tui_menu <title> <prompt> <option1> <option2> ...
tui_menu() {
    local title="$1"
    local prompt="$2"
    shift 2
    local options=("$@")

    if [ "$TUI_MODE" = "dialog" ]; then
        # Dialog menu
        local menu_items=()
        local i=1
        for opt in "${options[@]}"; do
            menu_items+=("$i" "$opt")
            ((i++))
        done

        local choice
        choice=$(dialog --stdout --title "$title" --menu "$prompt" 20 70 10 "${menu_items[@]}")
        echo "$choice"
    else
        # Pure bash menu
        clear
        draw_box_top "$title" 70
        echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
        draw_box_middle "${YELLOW}${prompt}${NC}" 70
        echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"

        local i=1
        for opt in "${options[@]}"; do
            draw_box_middle "  ${GREEN}${i}${NC}) ${opt}" 70
            ((i++))
        done

        echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
        draw_box_bottom 70

        echo -ne "\n${YELLOW}Seçiminiz (1-${#options[@]}): ${NC}"
        read -r choice </dev/tty
        echo "$choice"
    fi
}

# Show Yes/No dialog
# Usage: tui_yesno <title> <message>
# Returns: 0 for Yes, 1 for No
tui_yesno() {
    local title="$1"
    local message="$2"

    if [ "$TUI_MODE" = "dialog" ]; then
        dialog --title "$title" --yesno "$message" 10 60
        return $?
    else
        echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}${title}${NC}"
        echo -e "${BLUE}╠═══════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${message}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
        echo -ne "\n${YELLOW}(e/E=Evet, Enter=Hayır): ${NC}"
        read -r response </dev/tty
        [[ "$response" =~ ^[eE]$ ]]
        return $?
    fi
}

# Show info box
# Usage: tui_infobox <title> <message> <duration>
tui_infobox() {
    local title="$1"
    local message="$2"
    local duration="${3:-2}"

    if [ "$TUI_MODE" = "dialog" ]; then
        dialog --title "$title" --infobox "$message" 10 60
        sleep "$duration"
    else
        echo -e "\n${CYAN}╔═══════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC} ${GREEN}${title}${NC}"
        echo -e "${CYAN}╠═══════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC} ${message}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
        sleep "$duration"
    fi
}

# ═══════════════════════════════════════════════════════════
# EXPORT FUNCTIONS
# ═══════════════════════════════════════════════════════════

export TUI_MODE TUI_WIDTH TUI_HEIGHT
export -f init_tui
export -f show_progress_bar
export -f show_spinner
export -f show_install_status
export -f draw_box_top
export -f draw_box_middle
export -f draw_box_bottom
export -f init_install_progress
export -f update_install_progress
export -f display_install_progress
export -f tui_menu
export -f tui_yesno
export -f tui_infobox
