#!/bin/bash
# Module: Modern CLI Tools
# Description: Modern replacements for traditional CLI tools
# Dependencies: package-manager.sh, common.sh

# Install modern CLI tools (batcat, ripgrep, fd-find, eza, etc.)
install_modern_cli_tools() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      MODERN CLI ARAÇLARI KURULUYOR            ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check which tools are already installed
    local already_installed=()
    local missing_tools=()

    # Check each tool
    (command -v bat &>/dev/null || command -v batcat &>/dev/null) && already_installed+=("bat") || missing_tools+=("bat")
    command -v rg &>/dev/null && already_installed+=("ripgrep") || missing_tools+=("ripgrep")
    (command -v fd &>/dev/null || command -v fdfind &>/dev/null) && already_installed+=("fd") || missing_tools+=("fd")
    command -v eza &>/dev/null && already_installed+=("eza") || missing_tools+=("eza")
    command -v starship &>/dev/null && already_installed+=("starship") || missing_tools+=("starship")
    command -v zoxide &>/dev/null && already_installed+=("zoxide") || missing_tools+=("zoxide")
    command -v fzf &>/dev/null && already_installed+=("fzf") || missing_tools+=("fzf")
    command -v vivid &>/dev/null && already_installed+=("vivid") || missing_tools+=("vivid")
    command -v fastfetch &>/dev/null && already_installed+=("fastfetch") || missing_tools+=("fastfetch")
    command -v lazygit &>/dev/null && already_installed+=("lazygit") || missing_tools+=("lazygit")
    command -v lazydocker &>/dev/null && already_installed+=("lazydocker") || missing_tools+=("lazydocker")

    # If all tools are installed, skip
    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo -e "${CYAN}[!]${NC} Tüm modern CLI araçları zaten kurulu (${#already_installed[@]}/11)"
        track_skip "Modern CLI Tools" "Tüm araçlar kurulu (${already_installed[*]})"
        return 0
    fi

    # Show status
    if [ ${#already_installed[@]} -gt 0 ]; then
        echo -e "${CYAN}[!]${NC} Kurulu: ${already_installed[*]}"
    fi
    echo -e "${YELLOW}[BİLGİ]${NC} Kurulacak: ${missing_tools[*]}"
    echo ""

    # Detect package manager
    if [ -z "$PKG_MANAGER" ]; then
        detect_package_manager
    fi

    # Install tools based on package manager
    case $PKG_MANAGER in
        apt)
            install_modern_tools_apt
            ;;
        dnf|yum)
            install_modern_tools_dnf
            ;;
        pacman)
            install_modern_tools_pacman
            ;;
        *)
            echo -e "${RED}[HATA]${NC} Desteklenmeyen paket yöneticisi: $PKG_MANAGER"
            return 1
            ;;
    esac

    # Final check and tracking
    local installed_count=0
    local final_installed=()
    local final_failed=()

    # Check which tools are now installed
    (command -v bat &>/dev/null || command -v batcat &>/dev/null) && final_installed+=("bat") || final_failed+=("bat")
    command -v rg &>/dev/null && final_installed+=("ripgrep") || final_failed+=("ripgrep")
    (command -v fd &>/dev/null || command -v fdfind &>/dev/null) && final_installed+=("fd") || final_failed+=("fd")
    command -v eza &>/dev/null && final_installed+=("eza") || final_failed+=("eza")
    command -v starship &>/dev/null && final_installed+=("starship") || final_failed+=("starship")
    command -v zoxide &>/dev/null && final_installed+=("zoxide") || final_failed+=("zoxide")
    command -v fzf &>/dev/null && final_installed+=("fzf") || final_failed+=("fzf")
    command -v vivid &>/dev/null && final_installed+=("vivid") || final_failed+=("vivid")
    command -v fastfetch &>/dev/null && final_installed+=("fastfetch") || final_failed+=("fastfetch")
    command -v lazygit &>/dev/null && final_installed+=("lazygit") || final_failed+=("lazygit")
    command -v lazydocker &>/dev/null && final_installed+=("lazydocker") || final_failed+=("lazydocker")

    installed_count=${#final_installed[@]}

    echo -e "\n${GREEN}[BAŞARILI]${NC} Modern CLI araçları kurulumu tamamlandı! ($installed_count/11)"

    if [ $installed_count -eq 11 ]; then
        track_success "Modern CLI Tools" "Tüm araçlar kuruldu (11/11)"
    elif [ $installed_count -gt 0 ]; then
        track_success "Modern CLI Tools" "$installed_count/11 kuruldu: ${final_installed[*]}"
        if [ ${#final_failed[@]} -gt 0 ]; then
            track_failure "Modern CLI Tools (eksik)" "Kurulamadı: ${final_failed[*]}"
        fi
    else
        track_failure "Modern CLI Tools" "Hiçbir araç kurulamadı"
        return 1
    fi
}

# Generic function to fix bat/fd symlinks (works across all distros)
fix_bat_fd_symlinks() {
    echo -e "${YELLOW}[BİLGİ]${NC} bat ve fd symlink'leri kontrol ediliyor..."

    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Create bat symlink if batcat exists but bat doesn't
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        local batcat_path
        batcat_path="$(which batcat)"
        if [ -n "$batcat_path" ]; then
            ln -sf "$batcat_path" "$HOME/.local/bin/bat"
            echo -e "${GREEN}[BAŞARILI]${NC} bat symlink oluşturuldu: batcat → bat"
        fi
    fi

    # Create fd symlink if fdfind exists but fd doesn't
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        local fdfind_path
        fdfind_path="$(which fdfind)"
        if [ -n "$fdfind_path" ]; then
            ln -sf "$fdfind_path" "$HOME/.local/bin/fd"
            echo -e "${GREEN}[BAŞARILI]${NC} fd symlink oluşturuldu: fdfind → fd"
        fi
    fi

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}[BİLGİ]${NC} ~/.local/bin PATH'e ekleniyor..."

        # Add to .bashrc if not already there
        if ! grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
            echo '' >> "$HOME/.bashrc"
            echo '# Add ~/.local/bin to PATH for user binaries' >> "$HOME/.bashrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            echo -e "${GREEN}[BAŞARILI]${NC} ~/.local/bin bashrc'ye eklendi"
        fi

        # Export for current session
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# Install modern tools for APT (Debian/Ubuntu)
install_modern_tools_apt() {
    echo -e "${YELLOW}[BİLGİ]${NC} APT paket yöneticisi kullanılıyor..."

    # Core tools available in repos
    sudo apt install -y bat ripgrep fd-find fzf

    # Fix bat/fd symlinks (Ubuntu installs as batcat/fdfind)
    fix_bat_fd_symlinks

    # Install eza (modern ls replacement)
    if ! command -v eza &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Eza kuruluyor..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    else
        echo -e "${GREEN}[BİLGİ]${NC} Eza zaten kurulu."
    fi

    # Initialize tool versions (fetch latest from GitHub with fallbacks)
    init_tool_versions

    # Install starship prompt
    if ! command -v starship &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Starship kuruluyor..."
        curl -sS "$STARSHIP_INSTALL_URL" | sh -s -- -y
    else
        echo -e "${GREEN}[BİLGİ]${NC} Starship zaten kurulu."
    fi

    # Install zoxide
    if ! command -v zoxide &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Zoxide kuruluyor..."
        curl -sS "$ZOXIDE_INSTALL_URL" | bash
    else
        echo -e "${GREEN}[BİLGİ]${NC} Zoxide zaten kurulu."
    fi

    # Install vivid (using centralized version from config/tool-versions.sh)
    if ! command -v vivid &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Vivid ${VIVID_VERSION} kuruluyor..."

        local vivid_deb="vivid_${VIVID_VERSION}_amd64.deb"
        local vivid_url="https://github.com/sharkdp/vivid/releases/download/v${VIVID_VERSION}/${vivid_deb}"
        local vivid_checksum_url="${vivid_url}.sha256"

        # Download with checksum verification
        if download_with_checksum "$vivid_url" "$vivid_deb" "$vivid_checksum_url"; then
            sudo dpkg -i "$vivid_deb"
            rm "$vivid_deb"
        else
            echo -e "${RED}[✗]${NC} Vivid kurulumu başarısız! (checksum doğrulanamadı)"
            rm -f "$vivid_deb"
        fi
    else
        echo -e "${GREEN}[BİLGİ]${NC} Vivid zaten kurulu."
    fi

    # Install fastfetch
    if ! command -v fastfetch &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Fastfetch kuruluyor..."

        # Try multiple installation methods
        if command -v snap &> /dev/null; then
            # Method 1: Snap (most reliable)
            echo -e "${CYAN}[BİLGİ]${NC} Snap ile kuruluyor..."
            sudo snap install fastfetch 2>/dev/null || {
                # Method 2: Download latest release from GitHub (using centralized URL)
                echo -e "${CYAN}[BİLGİ]${NC} GitHub'dan indiriliyor..."
                curl -sL "$FASTFETCH_DOWNLOAD_URL" -o /tmp/fastfetch.deb
                sudo dpkg -i /tmp/fastfetch.deb 2>/dev/null || sudo apt install -f -y
                rm -f /tmp/fastfetch.deb
            }
        else
            # Method 2: Direct download (using centralized URL)
            echo -e "${CYAN}[BİLGİ]${NC} GitHub'dan indiriliyor..."
            curl -sL "$FASTFETCH_DOWNLOAD_URL" -o /tmp/fastfetch.deb
            sudo dpkg -i /tmp/fastfetch.deb 2>/dev/null || sudo apt install -f -y
            rm -f /tmp/fastfetch.deb
        fi

        if command -v fastfetch &> /dev/null; then
            echo -e "${GREEN}[BAŞARILI]${NC} Fastfetch kuruldu!"
        else
            echo -e "${RED}[HATA]${NC} Fastfetch kurulamadı."
        fi
    else
        echo -e "${GREEN}[BİLGİ]${NC} Fastfetch zaten kurulu."
    fi

    # Install lazygit (using centralized version from config/tool-versions.sh)
    if ! command -v lazygit &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Lazygit ${LAZYGIT_VERSION} kuruluyor..."

        local lazygit_tarball="lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        local lazygit_url="https://github.com/jesseduffield/lazygit/releases/latest/download/${lazygit_tarball}"
        local lazygit_checksum_url="https://github.com/jesseduffield/lazygit/releases/latest/download/checksums.txt"

        # Download with checksum verification
        if download_with_checksum "$lazygit_url" "lazygit.tar.gz" "$lazygit_checksum_url"; then
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit lazygit.tar.gz
        else
            echo -e "${RED}[✗]${NC} Lazygit kurulumu başarısız! (checksum doğrulanamadı)"
            rm -f lazygit.tar.gz lazygit
        fi
    else
        echo -e "${GREEN}[BİLGİ]${NC} Lazygit zaten kurulu."
    fi

    # Install lazydocker
    if ! command -v lazydocker &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Lazydocker kuruluyor..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    else
        echo -e "${GREEN}[BİLGİ]${NC} Lazydocker zaten kurulu."
    fi
}

# Install modern tools for DNF/YUM (Fedora/RHEL)
install_modern_tools_dnf() {
    echo -e "${YELLOW}[BİLGİ]${NC} DNF/YUM paket yöneticisi kullanılıyor..."

    # Core tools
    sudo $PKG_MANAGER install -y bat ripgrep fd-find fzf

    # Fix bat/fd symlinks
    fix_bat_fd_symlinks

    # Install remaining tools using generic methods
    install_starship_generic
    install_zoxide_generic
    install_lazygit_generic
    install_lazydocker_generic

    echo -e "${YELLOW}[UYARI]${NC} Eza, Vivid, Fastfetch manuel kurulum gerektirebilir."
}

# Install modern tools for Pacman (Arch)
install_modern_tools_pacman() {
    echo -e "${YELLOW}[BİLGİ]${NC} Pacman paket yöneticisi kullanılıyor..."

    # Most tools available in Arch repos
    sudo pacman -S --noconfirm bat ripgrep fd fzf eza starship zoxide

    # Install remaining tools
    install_lazygit_generic
    install_lazydocker_generic

    echo -e "${YELLOW}[UYARI]${NC} Vivid, Fastfetch AUR'dan kurulabilir."
}

# Generic installer functions (using centralized versions from config/tool-versions.sh)
install_starship_generic() {
    if ! command -v starship &> /dev/null; then
        curl -sS "$STARSHIP_INSTALL_URL" | sh -s -- -y
    fi
}

install_zoxide_generic() {
    if ! command -v zoxide &> /dev/null; then
        curl -sS "$ZOXIDE_INSTALL_URL" | bash
    fi
}

install_lazygit_generic() {
    if ! command -v lazygit &> /dev/null; then
        # Initialize versions if not already done
        if [ -z "$LAZYGIT_VERSION" ]; then
            init_tool_versions
        fi

        local lazygit_tarball="lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        local lazygit_url="https://github.com/jesseduffield/lazygit/releases/latest/download/${lazygit_tarball}"
        local lazygit_checksum_url="https://github.com/jesseduffield/lazygit/releases/latest/download/checksums.txt"

        # Download with checksum verification
        if download_with_checksum "$lazygit_url" "lazygit.tar.gz" "$lazygit_checksum_url"; then
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit lazygit.tar.gz
        else
            echo -e "${RED}[✗]${NC} Lazygit kurulumu başarısız! (checksum doğrulanamadı)"
            rm -f lazygit.tar.gz lazygit
        fi
    fi
}

install_lazydocker_generic() {
    if ! command -v lazydocker &> /dev/null; then
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi
}

# Export functions
export -f install_modern_cli_tools
export -f fix_bat_fd_symlinks
export -f install_modern_tools_apt
export -f install_modern_tools_dnf
export -f install_modern_tools_pacman
export -f install_starship_generic
export -f install_zoxide_generic
export -f install_lazygit_generic
export -f install_lazydocker_generic
