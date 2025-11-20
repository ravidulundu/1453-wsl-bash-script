#!/bin/bash
# TUI Library - Terminal User Interface
# Hybrid approach: Dialog (if available) + Pure Bash fallback

# Global TUI state
TUI_MODE="bash"  # "dialog" or "bash"
TUI_WIDTH=70
TUI_HEIGHT=20

# Get actual display width of string (handles ANSI codes + emojis)
# Uses wcwidth for Unicode characters (emojis count as 2)
get_display_width() {
    local str="$1"

    # Strip ANSI color codes first
    local visible
    visible=$(echo -e "$str" | sed 's/\x1b\[[0-9;]*m//g')

    # Try wcwidth for accurate emoji/Unicode width
    if command -v python3 &>/dev/null; then
        local width
        # Escape single quotes for Python
        local escaped="${visible//\'/\\\'}"
        width=$(python3 -c "
try:
    import wcwidth
    print(wcwidth.wcswidth('$escaped'))
except:
    print(len('$escaped'))
" 2>/dev/null)

        # If wcwidth returned valid number, use it
        if [ -n "$width" ] && [ "$width" -ge 0 ]; then
            echo "$width"
            return
        fi
    fi

    # Fallback: count emojis as 2 chars (common emoji range)
    local emoji_count
    emoji_count=$(echo "$visible" | grep -o '[🀀-🿿]' | wc -l 2>/dev/null || echo 0)
    local regular_len=${#visible}
    echo $((regular_len + emoji_count))
}

# Initialize TUI system
init_tui() {
    echo -e "${YELLOW}[DEBUG]${NC} init_tui: start" >&2

    # Check if dialog is available
    echo -e "${YELLOW}[DEBUG]${NC} init_tui: checking dialog" >&2
    if command -v dialog &>/dev/null; then
        TUI_MODE="dialog"
        export DIALOGRC="${DIALOGRC:-}"
        echo -e "${YELLOW}[DEBUG]${NC} init_tui: dialog found" >&2
    else
        TUI_MODE="bash"
        echo -e "${YELLOW}[DEBUG]${NC} init_tui: dialog not found" >&2
    fi

    # Get terminal dimensions
    echo -e "${YELLOW}[DEBUG]${NC} init_tui: getting terminal dimensions" >&2
    if command -v tput &>/dev/null && [ -n "${TERM:-}" ]; then
        echo -e "${YELLOW}[DEBUG]${NC} init_tui: tput available, TERM=$TERM" >&2
        TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)
        echo -e "${YELLOW}[DEBUG]${NC} init_tui: cols done, WIDTH=$TUI_WIDTH" >&2
        TUI_HEIGHT=$(tput lines 2>/dev/null || echo 24)
        echo -e "${YELLOW}[DEBUG]${NC} init_tui: lines done, HEIGHT=$TUI_HEIGHT" >&2
    else
        TUI_WIDTH=80
        TUI_HEIGHT=24
        echo -e "${YELLOW}[DEBUG]${NC} init_tui: using defaults" >&2
    fi

    # Ensure minimum dimensions (wider for emoji support)
    echo -e "${YELLOW}[DEBUG]${NC} init_tui: checking minimum dimensions" >&2
    [ -n "$TUI_WIDTH" ] && [ "$TUI_WIDTH" -lt 80 ] && TUI_WIDTH=80
    [ -n "$TUI_HEIGHT" ] && [ "$TUI_HEIGHT" -lt 20 ] && TUI_HEIGHT=20
    echo -e "${YELLOW}[DEBUG]${NC} init_tui: done - WIDTH=$TUI_WIDTH HEIGHT=$TUI_HEIGHT" >&2
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
    local width="${2:-80}"

    # Get actual display width (handles emojis correctly)
    local title_len
    title_len=$(get_display_width "$title")
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
    local width="${2:-80}"

    # Get actual display width (handles emojis correctly)
    local content_len
    content_len=$(get_display_width "$content")
    local padding=$((width - content_len - 4))

    echo -ne "${CYAN}║${NC} "
    echo -ne "${content}"
    printf "%0.s " $(seq 1 $padding)
    echo -e " ${CYAN}║${NC}"
}

draw_box_bottom() {
    local width="${1:-80}"
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
        echo ""
        echo -e "${YELLOW}${title}${NC}"
        echo -e "${message}"
        echo ""
        echo -ne "${YELLOW}(e/E=Evet, Enter=Hayır): ${NC}"
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
        echo ""
        echo -e "${GREEN}${title}${NC}"
        echo -e "${message}"
        echo ""
        sleep "$duration"
    fi
}

# ═══════════════════════════════════════════════════════════
# GUM TUI WRAPPER FUNCTIONS
# ═══════════════════════════════════════════════════════════

# Check if Gum is available
has_gum() {
    command -v gum &>/dev/null
}

# Gum-powered menu selection
# Usage: gum_choose "option1" "option2" "option3"
# Returns: selected option
gum_choose() {
    if has_gum; then
        gum choose "$@"
    else
        # Fallback to traditional menu
        local options=("$@")
        PS3="Seçiminiz (1-${#options[@]}): "
        select opt in "${options[@]}"; do
            if [ -n "$opt" ]; then
                echo "$opt"
                return 0
            fi
        done
    fi
}

# Gum-powered input
# Usage: gum_input --placeholder "Enter value" [--password]
# Returns: user input
gum_input() {
    if has_gum; then
        gum input "$@"
    else
        # Fallback to read
        local placeholder=""
        local is_password=false

        while [[ $# -gt 0 ]]; do
            case $1 in
                --placeholder)
                    placeholder="$2"
                    shift 2
                    ;;
                --password)
                    is_password=true
                    shift
                    ;;
                *)
                    shift
                    ;;
            esac
        done

        if [ -n "$placeholder" ]; then
            echo -ne "${YELLOW}${placeholder}: ${NC}"
        fi

        if [ "$is_password" = true ]; then
            read -rs input
            echo "" # New line after password
        else
            if [ -e /dev/tty ] && [ -c /dev/tty ]; then
                read -r input </dev/tty
            else
                read -r input
            fi
        fi

        echo "$input"
    fi
}

# Gum-powered confirmation
# Usage: gum_confirm "Are you sure?"
# Returns: 0 for yes, 1 for no
gum_confirm() {
    local message="$1"

    if has_gum; then
        gum confirm "$message"
    else
        # Fallback to traditional yes/no
        echo -ne "${YELLOW}${message} (e/E=Evet, Enter=Hayır): ${NC}"
        if [ -e /dev/tty ] && [ -c /dev/tty ]; then
            read -r response </dev/tty
        else
            read -r response
        fi
        [[ "$response" =~ ^[eE]$ ]]
    fi
}

# Gum-powered spinner
# Usage: gum_spin --title "Loading..." -- command args
# Runs command with spinner
gum_spin() {
    if has_gum; then
        gum spin "$@"
    else
        # Fallback: just run the command
        local title=""
        local cmd=()
        local parsing_cmd=false

        while [[ $# -gt 0 ]]; do
            case $1 in
                --title)
                    title="$2"
                    shift 2
                    ;;
                --spinner)
                    shift 2  # Skip spinner type
                    ;;
                --)
                    parsing_cmd=true
                    shift
                    ;;
                *)
                    if [ "$parsing_cmd" = true ]; then
                        cmd+=("$1")
                    fi
                    shift
                    ;;
            esac
        done

        if [ -n "$title" ]; then
            echo -e "${YELLOW}${title}${NC}"
        fi

        "${cmd[@]}"
    fi
}

# Gum-powered styled output
# Usage: gum_style --foreground 212 --border double "text"
# Outputs styled text with automatic responsive padding
gum_style() {
    if has_gum; then
        # Check if padding/margin already specified
        local has_spacing=false
        for arg in "$@"; do
            if [[ "$arg" == "--padding" ]] || [[ "$arg" == "--margin" ]]; then
                has_spacing=true
                break
            fi
        done

        # Add default responsive margin if not specified
        if [ "$has_spacing" = false ]; then
            # Calculate responsive margin based on terminal width
            local margin_left=2
            if [ -n "${TUI_WIDTH:-}" ] && [ "$TUI_WIDTH" -gt 100 ]; then
                margin_left=$((($TUI_WIDTH - 80) / 2))
                [ "$margin_left" -lt 2 ] && margin_left=2
                [ "$margin_left" -gt 10 ] && margin_left=10
            fi

            # Unset conflicting environment variables to prevent Gum errors
            # Gum reads BOLD, ITALIC, UNDERLINE, etc. as flag values
            (
                unset BOLD ITALIC UNDERLINE STRIKETHROUGH FAINT
                unset FOREGROUND BACKGROUND BORDER BORDER_BACKGROUND BORDER_FOREGROUND
                unset ALIGN HEIGHT WIDTH MARGIN PADDING
                gum style --margin "0 $margin_left" "$@"
            )
        else
            # User specified spacing, use as-is
            (
                unset BOLD ITALIC UNDERLINE STRIKETHROUGH FAINT
                unset FOREGROUND BACKGROUND BORDER BORDER_BACKGROUND BORDER_FOREGROUND
                unset ALIGN HEIGHT WIDTH MARGIN PADDING
                gum style "$@"
            )
        fi
    else
        # Fallback: add 2-space padding
        echo -e "  ${CYAN}${!#}${NC}"
    fi
}

# Gum-powered filter (fuzzy search)
# Usage: echo -e "option1\noption2\noption3" | gum_filter
# Returns: selected option
gum_filter() {
    if has_gum; then
        gum filter "$@"
    else
        # Fallback: use grep or just cat
        if [ -t 0 ]; then
            echo -e "${RED}[HATA]${NC} No input to filter"
            return 1
        fi

        # Simple line numbering for selection
        cat
    fi
}

# ═══════════════════════════════════════════════════════════
# EXPORT FUNCTIONS
# ═══════════════════════════════════════════════════════════

export TUI_MODE TUI_WIDTH TUI_HEIGHT
export -f get_display_width
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
# Gum wrappers
export -f has_gum
export -f gum_choose
export -f gum_input
export -f gum_confirm
export -f gum_spin
export -f gum_style
export -f gum_filter
