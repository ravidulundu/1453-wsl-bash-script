#!/bin/bash
# Tool Version Configuration
# Centralized version management for all external tools
# Each tool has a fallback version for when API calls fail

# ==========================================
# Node.js Ecosystem
# ==========================================
# NVM (Node Version Manager)
NVM_VERSION="${NVM_VERSION:-0.40.3}"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh"

# ==========================================
# Modern CLI Tools
# ==========================================
# Vivid (LS_COLORS generator)
VIVID_FALLBACK_VERSION="0.10.1"
VIVID_VERSION="${VIVID_VERSION:-}"

# Lazygit (Git TUI)
LAZYGIT_FALLBACK_VERSION="0.44.1"
LAZYGIT_VERSION="${LAZYGIT_VERSION:-}"

# Lazydocker (Docker TUI)
LAZYDOCKER_FALLBACK_VERSION="0.23.3"
LAZYDOCKER_VERSION="${LAZYDOCKER_VERSION:-}"

# Starship (prompt)
# FIX BUG-030: Old URL (https://starship.rs/install.sh) returns 403 Forbidden
# Using GitHub raw URL instead
STARSHIP_INSTALL_URL="https://raw.githubusercontent.com/starship/starship/master/install/install.sh"

# Zoxide (smart cd)
ZOXIDE_INSTALL_URL="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"

# Fastfetch (system info)
FASTFETCH_DOWNLOAD_URL="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"

# ==========================================
# AI CLI Tools
# ==========================================
# Claude Code CLI (Official native installer)
CLAUDE_CODE_INSTALL_URL="https://claude.ai/install.sh"

# Qoder CLI
QODER_INSTALL_URL="https://qoder.com/install"

# ==========================================
# Python Tools
# ==========================================
# UV (fast Python package manager)
UV_INSTALL_URL="https://astral.sh/uv/install.sh"

# ==========================================
# Version Fetching Functions
# ==========================================

# Fetch latest version from GitHub API with fallback
# Usage: fetch_github_version "owner/repo" "fallback_version"
fetch_github_version() {
    local repo="$1"
    local fallback="$2"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"

    # Try to fetch latest version
    # FIX BUG-013: Use portable sed instead of GNU grep -P
    local version
    version=$(curl -s "$api_url" 2>/dev/null | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -n1)

    if [ -n "$version" ]; then
        echo "$version"
    else
        echo "$fallback"
    fi
}

# Initialize dynamic versions (call this before using version variables)
init_tool_versions() {
    # Only fetch if not already set
    if [ -z "$VIVID_VERSION" ]; then
        VIVID_VERSION=$(fetch_github_version "sharkdp/vivid" "$VIVID_FALLBACK_VERSION")
    fi

    if [ -z "$LAZYGIT_VERSION" ]; then
        LAZYGIT_VERSION=$(fetch_github_version "jesseduffield/lazygit" "$LAZYGIT_FALLBACK_VERSION")
    fi

    if [ -z "$LAZYDOCKER_VERSION" ]; then
        LAZYDOCKER_VERSION=$(fetch_github_version "jesseduffield/lazydocker" "$LAZYDOCKER_FALLBACK_VERSION")
    fi

    # Export all version variables
    export NVM_VERSION NVM_INSTALL_URL
    export VIVID_VERSION VIVID_FALLBACK_VERSION
    export LAZYGIT_VERSION LAZYGIT_FALLBACK_VERSION
    export LAZYDOCKER_VERSION LAZYDOCKER_FALLBACK_VERSION
    export STARSHIP_INSTALL_URL ZOXIDE_INSTALL_URL FASTFETCH_DOWNLOAD_URL
    export CLAUDE_CODE_INSTALL_URL QODER_INSTALL_URL UV_INSTALL_URL
}

# Export version variables for use in other modules
export NVM_VERSION
export VIVID_FALLBACK_VERSION
export LAZYGIT_FALLBACK_VERSION
export LAZYDOCKER_FALLBACK_VERSION
export NVM_INSTALL_URL
export STARSHIP_INSTALL_URL
export ZOXIDE_INSTALL_URL
export FASTFETCH_DOWNLOAD_URL
export CLAUDE_CODE_INSTALL_URL
export QODER_INSTALL_URL
export UV_INSTALL_URL

# Export functions
export -f fetch_github_version
export -f init_tool_versions
