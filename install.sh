#!/bin/bash

# 1453.AI WSL Setup Script Installer
# This script downloads and sets up the modular WSL setup script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GitHub repository information
REPO_OWNER="altudev"
REPO_NAME="1453-wsl-bash-script"
BRANCH="master"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# Installation directory
INSTALL_DIR="$HOME/.1453-wsl-setup"

# ASCII Art Banner
show_banner() {
    echo -e "${CYAN}"
    echo '   /$$ /$$   /$$ /$$$$$$$   /$$$$$$ '
    echo ' /$$$$| $$  | $$| $$____/  /$$__  $$'
    echo '|_  $$| $$  | $$| $$      |__/  \ $$'
    echo '  | $$| $$$$$$$$| $$$$$$$    /$$$$$$/'
    echo '  | $$|_____  $$|_____  $$  |___  $$'
    echo '  | $$      | $$ /$$  \ $$ /$$  \ $$'
    echo ' /$$$$$$    | $$|  $$$$$$/|  $$$$$$/'
    echo '|______/    |__/ \______/  \______/ '
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         1453.AI WSL Setup Script - Quick Installer            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

# Function to download a file
download_file() {
    local url="$1"
    local dest="$2"
    local desc="$3"

    echo -e "${YELLOW}[DOWNLOADING]${NC} $desc"
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} $desc"
        return 0
    else
        echo -e "${RED}[✗]${NC} Failed to download: $desc"
        return 1
    fi
}

# Main installation function
main() {
    clear
    show_banner

    echo -e "${CYAN}[INFO]${NC} Starting 1453.AI WSL Setup Script Installation..."
    echo -e "${CYAN}[INFO]${NC} Installation directory: ${INSTALL_DIR}"
    echo ""

    # Check for curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} curl is required but not installed."
        echo -e "${YELLOW}[TIP]${NC} Install curl with: sudo apt install curl"
        exit 1
    fi

    # Create installation directory structure
    echo -e "${YELLOW}[SETUP]${NC} Creating directory structure..."
    mkdir -p "${INSTALL_DIR}/src"/{lib,config,modules}
    echo -e "${GREEN}[✓]${NC} Directory structure created"
    echo ""

    # List of files to download with their paths
    declare -a files=(
        "src/linux-ai-setup-script.sh:Main script"
        "src/lib/init.sh:Initialization module"
        "src/lib/common.sh:Common utilities"
        "src/lib/package-manager.sh:Package manager detection"
        "src/config/colors.sh:Color definitions"
        "src/config/php-versions.sh:PHP configuration"
        "src/config/banner.sh:Banner display"
        "src/modules/python.sh:Python ecosystem"
        "src/modules/javascript.sh:JavaScript ecosystem"
        "src/modules/php.sh:PHP ecosystem"
        "src/modules/ai-cli.sh:AI CLI tools"
        "src/modules/ai-frameworks.sh:AI frameworks"
        "src/modules/menus.sh:Menu system"
    )

    # Download all files
    echo -e "${CYAN}[INFO]${NC} Downloading modular components..."
    echo ""

    local failed=0
    for file_info in "${files[@]}"; do
        IFS=':' read -r file_path description <<< "$file_info"
        local url="${BASE_URL}/${file_path}"
        local dest="${INSTALL_DIR}/${file_path}"

        if ! download_file "$url" "$dest" "$description"; then
            ((failed++))
        fi
    done

    echo ""

    if [ $failed -gt 0 ]; then
        echo -e "${RED}[ERROR]${NC} Failed to download $failed file(s)."
        echo -e "${YELLOW}[TIP]${NC} You can try again or clone the repository directly:"
        echo -e "      git clone https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
        exit 1
    fi

    # Make the main script executable
    chmod +x "${INSTALL_DIR}/src/linux-ai-setup-script.sh"

    # Create a convenient launcher script
    echo -e "${YELLOW}[SETUP]${NC} Creating launcher script..."
    cat > "${INSTALL_DIR}/1453-setup" << 'LAUNCHER'
#!/bin/bash
# 1453.AI WSL Setup Launcher
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/src/linux-ai-setup-script.sh" "$@"
LAUNCHER

    chmod +x "${INSTALL_DIR}/1453-setup"
    echo -e "${GREEN}[✓]${NC} Launcher script created"
    echo ""

    # Add to PATH (optional)
    echo -e "${CYAN}[INFO]${NC} Installation completed successfully!"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    Installation Complete!                     ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}To run the setup script, use one of these methods:${NC}"
    echo ""
    echo -e "  1. Direct execution:"
    echo -e "     ${GREEN}${INSTALL_DIR}/1453-setup${NC}"
    echo ""
    echo -e "  2. Add to PATH (optional) for easy access:"
    echo -e "     ${GREEN}echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.bashrc${NC}"
    echo -e "     ${GREEN}source ~/.bashrc${NC}"
    echo -e "     ${GREEN}1453-setup${NC}"
    echo ""
    echo -e "  3. Create an alias (optional):"
    echo -e "     ${GREEN}echo 'alias 1453=\"${INSTALL_DIR}/1453-setup\"' >> ~/.bashrc${NC}"
    echo -e "     ${GREEN}source ~/.bashrc${NC}"
    echo -e "     ${GREEN}1453${NC}"
    echo ""
    echo -e "${CYAN}[TIP]${NC} The script is installed in: ${INSTALL_DIR}"
    echo -e "${CYAN}[TIP]${NC} To update, simply run this installer again"
    echo ""

    # Ask if user wants to run the setup now
    echo -ne "${YELLOW}Do you want to run the setup script now? (y/N): ${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        exec "${INSTALL_DIR}/1453-setup"
    fi
}

# Run the installer
main "$@"