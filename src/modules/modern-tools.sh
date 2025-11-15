#!/bin/bash
# Module: Modern CLI Tools
# Description: Modern replacements for traditional CLI tools
# Dependencies: package-manager.sh, common.sh

# Install modern CLI tools (batcat, ripgrep, fd-find, eza, etc.)
install_modern_cli_tools() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      MODERN CLI ARAÇLARI KURULUYOR            ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    echo -e "\n${YELLOW}[BİLGİ]${NC} Modern CLI araçları kurulacak:"
    echo -e "  ✓ bat (cat yerine)"
    echo -e "  ✓ ripgrep (grep yerine)"
    echo -e "  ✓ fd (find yerine)"
    echo -e "  ✓ eza (ls yerine)"
    echo -e "  ✓ starship (modern prompt)"
    echo -e "  ✓ zoxide (akıllı cd)"
    echo -e "  ✓ fzf (fuzzy finder)"
    echo -e "  ✓ vivid (LS_COLORS)"
    echo -e "  ✓ fastfetch (sistem bilgisi)"
    echo -e "  ✓ lazygit (git UI)"
    echo -e "  ✓ lazydocker (docker UI)"
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

    echo -e "\n${GREEN}[BAŞARILI]${NC} Modern CLI araçları kurulumu tamamlandı!"
}

# Generic function to fix bat/fd symlinks (works across all distros)
fix_bat_fd_symlinks() {
    echo -e "${YELLOW}[BİLGİ]${NC} bat ve fd symlink'leri kontrol ediliyor..."

    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Create bat symlink if batcat exists but bat doesn't
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        echo -e "${GREEN}[BAŞARILI]${NC} bat symlink oluşturuldu: batcat → bat"
    fi

    # Create fd symlink if fdfind exists but fd doesn't
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        echo -e "${GREEN}[BAŞARILI]${NC} fd symlink oluşturuldu: fdfind → fd"
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

    # Install starship prompt
    if ! command -v starship &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Starship kuruluyor..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo -e "${GREEN}[BİLGİ]${NC} Starship zaten kurulu."
    fi

    # Install zoxide
    if ! command -v zoxide &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Zoxide kuruluyor..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
        echo -e "${GREEN}[BİLGİ]${NC} Zoxide zaten kurulu."
    fi

    # Install vivid
    if ! command -v vivid &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Vivid kuruluyor..."
        VIVID_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/vivid/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        wget -q "https://github.com/sharkdp/vivid/releases/download/v${VIVID_VERSION}/vivid_${VIVID_VERSION}_amd64.deb"
        sudo dpkg -i "vivid_${VIVID_VERSION}_amd64.deb"
        rm "vivid_${VIVID_VERSION}_amd64.deb"
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
                # Method 2: Download latest release from GitHub
                echo -e "${CYAN}[BİLGİ]${NC} GitHub'dan indiriliyor..."
                FASTFETCH_VERSION=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
                curl -sL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb" -o /tmp/fastfetch.deb
                sudo dpkg -i /tmp/fastfetch.deb 2>/dev/null || sudo apt install -f -y
                rm -f /tmp/fastfetch.deb
            }
        else
            # Method 2: Direct download
            echo -e "${CYAN}[BİLGİ]${NC} GitHub'dan indiriliyor..."
            curl -sL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb" -o /tmp/fastfetch.deb
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

    # Install lazygit
    if ! command -v lazygit &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Lazygit kuruluyor..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
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

# Generic installer functions
install_starship_generic() {
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
}

install_zoxide_generic() {
    if ! command -v zoxide &> /dev/null; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
}

install_lazygit_generic() {
    if ! command -v lazygit &> /dev/null; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
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
