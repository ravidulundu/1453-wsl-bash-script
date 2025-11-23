#!/bin/bash
# Installation Tracking System
# Tracks successful, failed, and skipped installations

# Global arrays to track installations
declare -a SUCCESSFUL_INSTALLATIONS=()
declare -a FAILED_INSTALLATIONS=()
declare -a SKIPPED_INSTALLATIONS=()

# Track successful installation
# Usage: track_success "Tool Name" "version"
track_success() {
    local tool_name="$1"
    local version="${2:-}"

    if [ -n "$version" ]; then
        SUCCESSFUL_INSTALLATIONS+=("$tool_name ($version)")
    else
        SUCCESSFUL_INSTALLATIONS+=("$tool_name")
    fi
}

# Track failed installation
# Usage: track_failure "Tool Name" "reason"
track_failure() {
    local tool_name="$1"
    local reason="${2:-Kurulum başarısız}"

    FAILED_INSTALLATIONS+=("$tool_name - $reason")
}

# Track skipped installation
# Usage: track_skip "Tool Name" "reason"
track_skip() {
    local tool_name="$1"
    local reason="${2:-Zaten kurulu}"

    SKIPPED_INSTALLATIONS+=("$tool_name - $reason")
}

# Show installation summary (AI CLI Style)
show_installation_summary() {
    local width=70
    local separator=$(printf '%*s' "$width" '' | tr ' ' '-')
    
    echo ""
    echo "$separator"
    echo "  Installation Summary"
    echo "$separator"
    echo ""

    # Count totals
    local success_count=${#SUCCESSFUL_INSTALLATIONS[@]}
    local failed_count=${#FAILED_INSTALLATIONS[@]}
    local skipped_count=${#SKIPPED_INSTALLATIONS[@]}
    local total_count=$((success_count + failed_count + skipped_count))

    if [ $total_count -eq 0 ]; then
        echo "  [INFO] No installations performed."
        return 0
    fi

    # Show successful installations
    if [ $success_count -gt 0 ]; then
        echo -e "  ${GREEN}Successful Installations ($success_count):${NC}"
        for item in "${SUCCESSFUL_INSTALLATIONS[@]}"; do
            echo -e "    [+] $item"
        done
        echo ""
    fi

    # Show skipped installations
    if [ $skipped_count -gt 0 ]; then
        echo -e "  ${CYAN}Skipped Installations ($skipped_count):${NC}"
        for item in "${SKIPPED_INSTALLATIONS[@]}"; do
            echo -e "    [ ] $item"
        done
        echo ""
    fi

    # Show failed installations
    if [ $failed_count -gt 0 ]; then
        echo -e "  ${RED}Failed Installations ($failed_count):${NC}"
        for item in "${FAILED_INSTALLATIONS[@]}"; do
            echo -e "    [-] $item"
        done
        echo ""
        echo "  [!] Manual installation may be required for failed items."
        echo "  [!] Check error messages above for details."
        echo ""
    fi

    # Status line
    echo "$separator"
    echo -e "  Total: $total_count | ${GREEN}Success: $success_count${NC} | ${CYAN}Skipped: $skipped_count${NC} | ${RED}Failed: $failed_count${NC}"
    echo "$separator"
    echo ""
    
    # Show post-installation instructions if there were successful installations
    if [ $success_count -gt 0 ]; then
        echo "  Post-Installation Steps:"
        echo ""
        echo "  1. Reload your shell environment:"
        echo "     > source ~/.bashrc              (fastest method)"
        echo "     > exec bash                     (if using bash)"
        echo "     > Close and reopen terminal     (most reliable)"
        echo ""
        echo "  2. Verify installations:"
        echo "     > python3 --version"
        echo "     > node --version"
        echo "     > which nvm"
        echo ""
        echo "  3. Explore new tools:"
        echo "     > bat --help                    (modern cat)"
        echo "     > eza --help                    (modern ls)"
        echo "     > lazygit                       (Git TUI)"
        echo ""
        echo "  [!] IMPORTANT: Run 'source ~/.bashrc' or restart terminal for changes to take effect."
        echo ""
    fi

    # Return non-zero if there are failures
    if [ $failed_count -gt 0 ]; then
        return 1
    fi
    return 0
}

# Reset tracking arrays (for fresh start)
reset_tracking() {
    SUCCESSFUL_INSTALLATIONS=()
    FAILED_INSTALLATIONS=()
    SKIPPED_INSTALLATIONS=()
}

# Export functions
export -f track_success
export -f track_failure
export -f track_skip
export -f show_installation_summary
export -f reset_tracking
