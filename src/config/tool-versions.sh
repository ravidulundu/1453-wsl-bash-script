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
# FIX: Starship install URL changed (https://starship.rs/install.sh returns 403)
# Using GitHub raw URL instead (verified working)
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

# Kiro CLI
KIRO_INSTALL_URL="https://cli.kiro.dev/install"

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
    local cache_dir="/tmp/1453-version-cache"
    local cache_file="${cache_dir}/${repo//\//_}.version"
    local cache_ttl=3600 # 1 hour cache

    # Create cache directory if it doesn't exist
    if [ ! -d "$cache_dir" ]; then
        mkdir -p "$cache_dir" 2>/dev/null
    fi

    # Check cache (if file exists and is younger than TTL)
    if [ -f "$cache_file" ]; then
        # Use find to check if file was modified less than 60 minutes ago (portable way)
        if [ -n "$(find "$cache_file" -mmin -60 2>/dev/null)" ]; then
            cat "$cache_file"
            return
        fi
    fi

    local version=""

    # Strategy 0: Custom Proxy API (Rate Limit Bypass)
    # This is the preferred method as it avoids GitHub rate limits entirely
    local proxy_url="https://api.dulundu.dev/version?repo=${repo}"
    
    # Try proxy first (fast timeout)
    version=$(curl -s --connect-timeout 3 "$proxy_url" 2>/dev/null)
    
    # Validate proxy response (must be a valid version number, not error html/json)
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        version=""
    fi

    # Strategy 1: Try GitHub CLI (gh) if available and authenticated
    # This has a much higher rate limit (5000/hr)
    if [ -z "$version" ] && command -v gh &>/dev/null && gh auth status &>/dev/null; then
        version=$(gh api "repos/${repo}/releases/latest" --jq .tag_name 2>/dev/null | sed 's/^v//')
    fi

    # Strategy 2: Fallback to curl (with token if available)
    if [ -z "$version" ]; then
        local api_url="https://api.github.com/repos/${repo}/releases/latest"
        local auth_header=""
        
        # Use GITHUB_TOKEN if available
        if [ -n "${GITHUB_TOKEN:-}" ]; then
            auth_header="Authorization: token $GITHUB_TOKEN"
        fi

        if [ -n "$auth_header" ]; then
            version=$(curl -s -H "$auth_header" "$api_url" 2>/dev/null | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -n1)
        else
            version=$(curl -s "$api_url" 2>/dev/null | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -n1)
        fi
    fi

    # Result handling
    if [ -n "$version" ]; then
        # Success: Cache it and return
        echo "$version" > "$cache_file"
        echo "$version"
    else
        # Failure: Return fallback (do not cache failure)
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
    export CLAUDE_CODE_INSTALL_URL QODER_INSTALL_URL KIRO_INSTALL_URL UV_INSTALL_URL
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
export KIRO_INSTALL_URL
export UV_INSTALL_URL

# Export functions
export -f fetch_github_version
export -f init_tool_versions
