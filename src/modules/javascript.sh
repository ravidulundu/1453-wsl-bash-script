#!/bin/bash
# Module: JavaScript Ecosystem
# Description: NVM and Bun.js installation functions
# Dependencies: lib/common.sh

# Install NVM (Node Version Manager)
install_nvm() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} NVM kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if NVM is already installed
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
        local nvm_version
        nvm_version=$(nvm --version 2>/dev/null || echo "unknown")

        # Check if Node is also installed
        if command -v node &> /dev/null; then
            local node_version
            node_version=$(node -v 2>/dev/null || echo "unknown")
            echo -e "${CYAN}[!]${NC} NVM zaten kurulu: v$nvm_version"
            echo -e "${CYAN}[!]${NC} Node.js: $node_version"
            track_skip "NVM + Node.js" "Zaten kurulu (NVM: v$nvm_version, Node: $node_version)"
        else
            echo -e "${CYAN}[!]${NC} NVM kurulu (v$nvm_version) ama Node.js yok, LTS kuruluyor..."
            nvm install --lts
            nvm use --lts
            local node_version
            node_version=$(node -v 2>/dev/null || echo "unknown")
            track_success "NVM + Node.js" "NVM mevcut, Node.js eklendi ($node_version)"
        fi
        return 0
    fi

    # Download and install NVM (using centralized version from config/tool-versions.sh)
    echo -e "${YELLOW}[BİLGİ]${NC} NVM ${NVM_VERSION} indiriliyor..."

    # FIX BUG-001: Download to temp file first instead of piping directly to shell
    local temp_script
    temp_script=$(mktemp)
    trap 'rm -f "$temp_script"' RETURN

    if ! curl -fsSL "$NVM_INSTALL_URL" -o "$temp_script"; then
        echo -e "${RED}[HATA]${NC} NVM installer indirilirken hata oluştu"
        track_failure "NVM" "İndirme hatası"
        return 1
    fi

    if ! bash "$temp_script"; then
        echo -e "${RED}[HATA]${NC} NVM kurulum başarısız!"
        track_failure "NVM" "Kurulum başarısız"
        return 1
    fi

    # Set up NVM directory
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Update shell RC files
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$rc_file" ]; then
            if ! grep -q 'NVM_DIR' "$rc_file"; then
                echo -e "${YELLOW}[BİLGİ]${NC} NVM $rc_file dosyasına ekleniyor..."
                # FIX BUG-020: Simplify NVM PATH escaping using cat with heredoc
                cat >> "$rc_file" << 'END_NVM_CONFIG'

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
END_NVM_CONFIG
            fi
        fi
    done

    # Load NVM again to ensure it's available
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo -e "${YELLOW}[BİLGİ]${NC} Node.js LTS sürümü kuruluyor..."
    if nvm install --lts && nvm use --lts; then
        if command -v node &> /dev/null; then
            local node_version npm_version nvm_version
            node_version=$(node -v 2>/dev/null || echo "unknown")
            npm_version=$(npm -v 2>/dev/null || echo "unknown")
            nvm_version=$(nvm --version 2>/dev/null || echo "unknown")
            echo -e "\n${GREEN}[BAŞARILI]${NC} NVM kurulumu tamamlandı!"
            echo -e "${GREEN}[BAŞARILI]${NC} NVM sürümü: v$nvm_version"
            echo -e "${GREEN}[BAŞARILI]${NC} Node.js sürümü: $node_version"
            echo -e "${GREEN}[BAŞARILI]${NC} NPM sürümü: $npm_version"
            track_success "NVM + Node.js" "NVM: v$nvm_version, Node: $node_version"
        else
            echo -e "${RED}[HATA]${NC} NVM kuruldu ama Node.js bulunamadı!"
            track_failure "NVM + Node.js" "Node.js kurulumu başarısız"
            return 1
        fi
    else
        echo -e "${RED}[HATA]${NC} NVM veya Node.js kurulumu başarısız!"
        track_failure "NVM + Node.js" "Kurulum başarısız"
        return 1
    fi
}

# Install Bun.js
install_bun() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Bun.js kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v bun &> /dev/null; then
        local version
        version=$(bun --version 2>/dev/null || echo "unknown")
        echo -e "${CYAN}[!]${NC} Bun.js zaten kurulu: $version"
        track_skip "Bun.js" "Zaten kurulu ($version)"
        return 0
    fi

    # Ensure package manager is detected
    if [ -z "$INSTALL_CMD" ]; then
        echo -e "${YELLOW}[!]${NC} Paket yöneticisi tespit ediliyor..."
        detect_package_manager
    fi

    # Check if unzip is installed (required by Bun installer)
    if ! command -v unzip &>/dev/null; then
        echo -e "${YELLOW}[!]${NC} unzip gerekli, kuruluyor..."
        if ! install_package_with_retry "unzip"; then
            echo -e "${RED}[✗]${NC} unzip kurulumu başarısız!"
            echo -e "${YELLOW}[!]${NC} Elle kurun: sudo apt install -y unzip"
            return 1
        fi
        echo -e "${GREEN}[✓]${NC} unzip kuruldu"
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Bun.js (curl) ile kuruluyor..."

    # FIX BUG-001: Download to temp file first instead of piping directly to shell
    local temp_script
    temp_script=$(mktemp)
    trap 'rm -f "$temp_script"' RETURN

    if ! curl -fsSL https://bun.sh/install -o "$temp_script"; then
        echo -e "${RED}[HATA]${NC} Bun.js installer indirilirken hata oluştu"
        track_failure "Bun.js" "İndirme hatası"
        return 1
    fi

    if ! bash "$temp_script"; then
        echo -e "${RED}[HATA]${NC} Bun.js kurulum başarısız!"
        echo -e "${YELLOW}[UYARI]${NC} Network bağlantısını ve https://bun.sh erişilebilirliğini kontrol edin."
        return 1
    fi

    # Set up Bun environment
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # Update shell RC files
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$rc_file" ]; then
            if ! grep -q '.bun/bin' "$rc_file"; then
                echo '' >> "$rc_file"
                echo '# Bun.js PATH' >> "$rc_file"
                echo "export BUN_INSTALL=\"\$HOME/.bun\"" >> "$rc_file"
                echo "export PATH=\"\$BUN_INSTALL/bin:\$PATH\"" >> "$rc_file"
            fi
        fi
    done

    reload_shell_configs

    if command -v bun &> /dev/null; then
        local version
        version=$(bun --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} Bun.js kurulumu tamamlandı: $version"
        echo -e "\n${CYAN}[BİLGİ]${NC} Bun.js Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Proje başlatma: ${GREEN}bun init${NC}"
        echo -e "  ${GREEN}•${NC} Paket kurma: ${GREEN}bun add paket_adi${NC}"
        echo -e "  ${GREEN}•${NC} Script çalıştırma: ${GREEN}bun run start${NC}"
        echo -e "  ${GREEN}•${NC} Güncelleme: ${GREEN}bun upgrade${NC}"
        track_success "Bun.js" "$version"
    else
        echo -e "${RED}[HATA]${NC} Bun.js kurulumu başarısız!"
        track_failure "Bun.js" "Kurulum başarısız"
        return 1
    fi
}

# Export functions for use in other modules
export -f install_nvm
export -f install_bun