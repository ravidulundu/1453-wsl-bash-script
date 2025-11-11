#!/bin/bash

# ==========================================
# Go Installation Module
# 1453 WSL Setup Script
# ==========================================

# Check if Go is already installed
is_go_installed() {
    if command -v go &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Configure Go environment variables
configure_go_env() {
    echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Go ortam değişkenleri yapılandırılıyor..."
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

    # Add Go binary to PATH
    local go_bin_path="/usr/local/go/bin"
    
    # Create or update shell RC files
    local rc_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    
    for rc_file in "${rc_files[@]}"; do
        if [ -f "$rc_file" ]; then
            # Check if Go PATH is already configured
            if ! grep -q "export PATH=\$PATH:$go_bin_path" "$rc_file" 2>/dev/null; then
                echo "" >> "$rc_file"
                echo "# Go binary path" >> "$rc_file"
                echo "export PATH=\$PATH:$go_bin_path" >> "$rc_file"
            fi
            
            # Check if GOPATH is already configured
            if ! grep -q "export GOPATH=\$HOME/go" "$rc_file" 2>/dev/null; then
                echo "export GOPATH=\$HOME/go" >> "$rc_file"
                echo "export PATH=\$PATH:\$GOPATH/bin" >> "$rc_file"
            fi
        fi
    done

    echo -e "${GREEN}[BAŞARILI]${NC} Go ortam değişkenleri yapılandırıldı!"
}

# Install Go using official binary
install_go_official() {
    echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Go resmi binary kurulumu başlatılıyor..."
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

    # Check if already installed
    if is_go_installed; then
        echo -e "${GREEN}[BAŞARILI]${NC} Go zaten kurulu: $(go version)"
        return 0
    fi

    # Detect architecture
    local arch="amd64"
    case $(uname -m) in
        "x86_64") arch="amd64" ;;
        "aarch64") arch="arm64" ;;
        *) echo -e "${RED}[HATA]${NC} Desteklenmeyen mimari: $(uname -m)"; return 1 ;;
    esac

    # Get latest version
    echo -e "${YELLOW}[BİLGİ]${NC} Son Go sürümü kontrol ediliyor..."
    local go_version=$(curl -s https://go.dev/VERSION?m=text | head -n1)
    
    if [ -z "$go_version" ]; then
        echo -e "${RED}[HATA]${NC} Go sürüm bilgisi alınamadı!"
        return 1
    fi

    local go_tarball="go${go_version}.linux-${arch}.tar.gz"
    local download_url="https://go.dev/dl/${go_tarball}"

    echo -e "${YELLOW}[BİLGİ]${NC} İndiriliyor: $go_tarball"

    # Download Go
    if ! curl -fsSL -O "$download_url"; then
        echo -e "${RED}[HATA]${NC} Go indirme başarısız!"
        return 1
    fi

    # Remove old Go installation if exists
    if [ -d "/usr/local/go" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Eski Go kurulumu kaldırılıyor..."
        sudo rm -rf /usr/local/go
    fi

    # Extract to /usr/local
    echo -e "${YELLOW}[BİLGİ]${NC} Go /usr/local dizinine çıkarılıyor..."
    if ! sudo tar -C /usr/local -xzf "$go_tarball"; then
        echo -e "${RED}[HATA]${NC} Go çıkarma başarısız!"
        rm -f "$go_tarball"
        return 1
    fi

    # Clean up
    rm -f "$go_tarball"

    # Configure environment
    configure_go_env

    # Reload shell configuration
    reload_shell_configs

    # Verify installation
    if is_go_installed; then
        echo -e "${GREEN}[BAŞARILI]${NC} Go resmi kurulum tamamlandı!"
        echo -e "${GREEN}[BAŞARILI]${NC} Kurulu sürüm: $(go version)"
        return 0
    else
        echo -e "${RED}[HATA]${NC} Go kurulum doğrulanamadı!"
        return 1
    fi
}

# Install Go using package manager
install_go_package() {
    echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Go paket yöneticisi kurulumu başlatılıyor..."
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

    # Check if already installed
    if is_go_installed; then
        echo -e "${GREEN}[BAŞARILI]${NC} Go zaten kurulu: $(go version)"
        return 0
    fi

    # Detect package manager and install
    case "$PKG_MANAGER" in
        "apt")
            echo -e "${YELLOW}[BİLGİ]${NC} APT ile Go kuruluyor..."
            if eval "$INSTALL_CMD" golang-go; then
                echo -e "${GREEN}[BAŞARILI]${NC} Go APT ile kuruldu!"
            else
                echo -e "${RED}[HATA]${NC} APT ile Go kurulumu başarısız!"
                return 1
            fi
            ;;
        "dnf")
            echo -e "${YELLOW}[BİLGİ]${NC} DNF ile Go kuruluyor..."
            if eval "$INSTALL_CMD" golang; then
                echo -e "${GREEN}[BAŞARILI]${NC} Go DNF ile kuruldu!"
            else
                echo -e "${RED}[HATA]${NC} DNF ile Go kurulumu başarısız!"
                return 1
            fi
            ;;
        "yum")
            echo -e "${YELLOW}[BİLGİ]${NC} YUM ile Go kuruluyor..."
            if eval "$INSTALL_CMD" golang; then
                echo -e "${GREEN}[BAŞARILI]${NC} Go YUM ile kuruldu!"
            else
                echo -e "${RED}[HATA]${NC} YUM ile Go kurulumu başarısız!"
                return 1
            fi
            ;;
        "pacman")
            echo -e "${YELLOW}[BİLGİ]${NC} Pacman ile Go kuruluyor..."
            if eval "$INSTALL_CMD" go; then
                echo -e "${GREEN}[BAŞARILI]${NC} Go Pacman ile kuruldu!"
            else
                echo -e "${RED}[HATA]${NC} Pacman ile Go kurulumu başarısız!"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}[HATA]${NC} Desteklenmeyen paket yöneticisi: $PKG_MANAGER"
            return 1
            ;;
    esac

    # Configure environment
    configure_go_env

    # Reload shell configuration
    reload_shell_configs

    # Verify installation
    if is_go_installed; then
        echo -e "${GREEN}[BAŞARILI]${NC} Go paket yöneticisi kurulumu tamamlandı!"
        echo -e "${GREEN}[BAŞARILI]${NC} Kurulu sürüm: $(go version)"
        return 0
    else
        echo -e "${RED}[HATA]${NC} Go kurulum doğrulanamadı!"
        return 1
    fi
}

# Main Go installation function (intelligent selection)
install_go() {
    echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Go kurulumu başlatılıyor..."
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

    # Check if already installed
    if is_go_installed; then
        echo -e "${GREEN}[BAŞARILI]${NC} Go zaten kurulu: $(go version)"
        return 0
    fi

    # Try package manager first (faster), fallback to official binary
    echo -e "${YELLOW}[BİLGİ]${NC} Önce paket yöneticisi ile kurulum deneniyor..."
    
    if install_go_package; then
        echo -e "${GREEN}[BAŞARILI]${NC} Go paket yöneticisi ile başarıyla kuruldu!"
        return 0
    else
        echo -e "${YELLOW}[UYARI]${NC} Paket yöneticisi kurulumu başarısız, resmi binary deneniyor..."
        if install_go_official; then
            echo -e "${GREEN}[BAŞARILI]${NC} Go resmi binary ile başarıyla kuruldu!"
            return 0
        else
            echo -e "${RED}[HATA]${NC} Go kurulumu başarısız!"
            return 1
        fi
    fi
}

# Interactive Go installation menu
install_go_menu() {
    echo -e "\n${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              Go Kurulum              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
    echo -e "  ${GREEN}1${NC}) Otomatik Kurulum (Önerilen)"
    echo -e "  ${GREEN}2${NC}) Resmi Binary Kurulumu"
    echo -e "  ${GREEN}3${NC}) Paket Yöneticisi Kurulumu"
    echo -e "  ${GREEN}0${NC}) Ana menüye dön"

    echo -ne "\n${YELLOW}Seçiminizi yapın: ${NC}"
    read -r choice

    case $choice in
        1)
            install_go
            ;;
        2)
            install_go_official
            ;;
        3)
            install_go_package
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}[HATA]${NC} Geçersiz seçim!"
            install_go_menu
            ;;
    esac
}

# Uninstall Go
remove_go() {
    echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Go kaldırılıyor..."
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

    # Remove Go binary
    if [ -d "/usr/local/go" ]; then
        sudo rm -rf /usr/local/go
        echo -e "${GREEN}[BAŞARILI]${NC} Go binary kaldırıldı!"
    fi

    # Remove Go from PATH in shell RC files
    local rc_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    
    for rc_file in "${rc_files[@]}"; do
        if [ -f "$rc_file" ]; then
            # Remove Go PATH configuration
            sed -i '/export PATH=\$PATH:\/usr\/local\/go\/bin/d' "$rc_file" 2>/dev/null
            sed -i '/# Go binary path/d' "$rc_file" 2>/dev/null
            
            # Remove GOPATH configuration
            sed -i '/export GOPATH=\$HOME\/go/d' "$rc_file" 2>/dev/null
            sed -i '/export PATH=\$PATH:\$GOPATH\/bin/d' "$rc_file" 2>/dev/null
        fi
    done

    # Reload shell configuration
    reload_shell_configs

    echo -e "${GREEN}[BAŞARILI]${NC} Go tamamen kaldırıldı!"
}

# Show Go information
show_go_info() {
    echo -e "\n${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              Go Bilgisi              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"

    if is_go_installed; then
        echo -e "${GREEN}Kurulu Sürüm:${NC} $(go version)"
        echo -e "${GREEN}Go Dizini:${NC} $(go env GOROOT)"
        echo -e "${GREEN}GOPATH:${NC} $(go env GOPATH)"
        echo -e "${GREEN}PATH:${NC} $(echo $PATH | grep -o '[^:]*go/bin[^:]*' | head -n1)"
    else
        echo -e "${YELLOW}Go henüz kurulu değil.${NC}"
    fi
}

# Export functions for use in other modules
export -f install_go
export -f install_go_official
export -f install_go_package
export -f install_go_menu
export -f remove_go
export -f show_go_info
export -f configure_go_env
export -f is_go_installed
