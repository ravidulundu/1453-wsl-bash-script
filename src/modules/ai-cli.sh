#!/bin/bash
# Module: AI CLI Tools
# Description: AI command-line tools installation functions including Qoder CLI
# Dependencies: lib/common.sh, lib/package-manager.sh, modules/javascript.sh

# Install Claude Code CLI
install_claude_code() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Claude Code CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed (command is 'claude', not 'claude-code')
    if command -v claude &> /dev/null; then
        local version
        version=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${CYAN}[!]${NC} Claude Code CLI zaten kurulu: $version"
        track_skip "Claude Code CLI" "Zaten kurulu"
        return 0
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Claude Code CLI indiriliyor: $CLAUDE_CODE_INSTALL_URL"

    # Download installer to temp file for better error handling
    local temp_installer
    temp_installer=$(mktemp)

    if curl -fsSL "$CLAUDE_CODE_INSTALL_URL" -o "$temp_installer" 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} İndirme başarılı, kuruluyor..."

        # Run installer
        if bash "$temp_installer"; then
            rm -f "$temp_installer"
            reload_shell_configs

            # Check for 'claude' command (not 'claude-code')
            if command -v claude &> /dev/null; then
                local version
                version=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
                echo -e "${GREEN}[BAŞARILI]${NC} Claude Code CLI kurulumu tamamlandı: $version"
                echo -e "${CYAN}[ℹ]${NC} Komut: ${GREEN}claude${NC} (not claude-code)"
                track_success "Claude Code CLI" "$version"
                return 0
            else
                echo -e "${RED}[HATA]${NC} Kurulum tamamlandı ama claude komutu bulunamadı!"
                echo -e "${YELLOW}[!]${NC} Shell'i yeniden yükleyin: source ~/.bashrc"
                echo -e "${YELLOW}[!]${NC} veya yeni terminal açın"
                track_failure "Claude Code CLI" "Komut bulunamadı (shell reload gerekli)"
                return 1
            fi
        else
            rm -f "$temp_installer"
            echo -e "${RED}[HATA]${NC} Kurulum scripti başarısız!"
            track_failure "Claude Code CLI" "Kurulum scripti başarısız"
            return 1
        fi
    else
        rm -f "$temp_installer"
        echo -e "${RED}[HATA]${NC} Claude Code CLI indirilemedi!"
        echo -e "${YELLOW}[!]${NC} URL: $CLAUDE_CODE_INSTALL_URL"
        echo -e "${YELLOW}[!]${NC} Muhtemel nedenler:"
        echo -e "    - URL geçersiz olabilir (404)"
        echo -e "    - İnternet bağlantısı sorunu"
        echo -e "    - GitHub erişim sorunu"
        echo -e "${CYAN}[ℹ]${NC} Elle kurmak için: npm install -g @anthropic-ai/claude-code"
        track_failure "Claude Code CLI" "İndirme başarısız (URL veya ağ sorunu)"
        return 1
    fi
}

# Install Gemini CLI
install_gemini_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Gemini CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if python3 -c "import google.generativeai" 2>/dev/null; then
        echo -e "${CYAN}[!]${NC} Gemini CLI (Google AI SDK) zaten kurulu"
        track_skip "Gemini CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Python kurulu değil. Önce Python kuruluyor..."
        if ! install_python; then
            track_failure "Gemini CLI" "Python gereksinimi karşılanamadı"
            return 1
        fi
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Google AI Python SDK kuruluyor..."
    if python3 -m pip install google-generativeai --break-system-packages 2>/dev/null || \
       python3 -m pip install google-generativeai; then
        local version
        version=$(python3 -c "import google.generativeai; print(google.generativeai.__version__)" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} Gemini CLI için Google AI SDK kuruldu!"
        track_success "Gemini CLI" "$version"
        return 0
    else
        echo -e "${RED}[HATA]${NC} Gemini CLI kurulumu başarısız!"
        track_failure "Gemini CLI" "pip install başarısız"
        return 1
    fi
}

# Install OpenCode CLI
install_opencode_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} OpenCode CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v opencode &> /dev/null; then
        local version
        version=$(opencode --version 2>/dev/null || echo "unknown")
        echo -e "${CYAN}[!]${NC} OpenCode CLI zaten kurulu: $version"
        track_skip "OpenCode CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} NPM kurulu değil. NVM ile Node.js kuruluyor..."
        if ! install_nvm; then
            track_failure "OpenCode CLI" "NPM gereksinimi karşılanamadı"
            return 1
        fi
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} OpenCode CLI npm ile kuruluyor..."
    if npm install -g opencode-cli; then
        reload_shell_configs

        if command -v opencode &> /dev/null; then
            local version
            version=$(opencode --version 2>/dev/null || echo "unknown")
            echo -e "${GREEN}[BAŞARILI]${NC} OpenCode CLI kurulumu tamamlandı!"
            track_success "OpenCode CLI" "$version"
            return 0
        else
            echo -e "${RED}[HATA]${NC} OpenCode CLI kurulumu başarısız!"
            track_failure "OpenCode CLI" "Komut bulunamadı"
            return 1
        fi
    else
        echo -e "${RED}[HATA]${NC} OpenCode CLI kurulumu başarısız!"
        track_failure "OpenCode CLI" "npm install başarısız"
        return 1
    fi
}

# Install Qwen CLI
install_qwen_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Qwen CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v qwen &> /dev/null; then
        local version
        version=$(qwen --version 2>/dev/null || echo "unknown")
        echo -e "${CYAN}[!]${NC} Qwen CLI zaten kurulu: $version"
        track_skip "Qwen CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v pipx &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Pipx kurulu değil. Önce pipx kuruluyor..."
        if ! install_pipx; then
            track_failure "Qwen CLI" "Pipx gereksinimi karşılanamadı"
            return 1
        fi
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Qwen CLI pipx ile kuruluyor..."
    if pipx install qwen-cli; then
        reload_shell_configs

        if command -v qwen &> /dev/null; then
            local version
            version=$(qwen --version 2>/dev/null || echo "unknown")
            echo -e "${GREEN}[BAŞARILI]${NC} Qwen CLI kurulumu tamamlandı!"
            track_success "Qwen CLI" "$version"
            return 0
        else
            echo -e "${RED}[HATA]${NC} Qwen CLI kurulumu başarısız!"
            track_failure "Qwen CLI" "Komut bulunamadı"
            return 1
        fi
    else
        echo -e "${RED}[HATA]${NC} Qwen CLI kurulumu başarısız!"
        track_failure "Qwen CLI" "pipx install başarısız"
        return 1
    fi
}

# Install Copilot CLI
install_copilot_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} GitHub Copilot CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v github-copilot-cli &> /dev/null; then
        local version
        version=$(npm list -g @githubnext/github-copilot-cli 2>/dev/null | grep github-copilot-cli | awk '{print $2}' || echo "unknown")
        echo -e "${CYAN}[!]${NC} GitHub Copilot CLI zaten kurulu: $version"
        track_skip "GitHub Copilot CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} NPM kurulu değil. NVM ile Node.js kuruluyor..."
        if ! install_nvm; then
            track_failure "GitHub Copilot CLI" "NPM gereksinimi karşılanamadı"
            return 1
        fi
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} GitHub Copilot CLI npm ile kuruluyor..."
    if npm install -g @githubnext/github-copilot-cli; then
        reload_shell_configs

        local version
        version=$(npm list -g @githubnext/github-copilot-cli 2>/dev/null | grep github-copilot-cli | awk '{print $2}' || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} GitHub Copilot CLI kurulumu tamamlandı!"
        echo -e "\n${CYAN}[BİLGİ]${NC} GitHub hesabınızla oturum açmak için:"
        echo -e "  ${GREEN}github-copilot-cli auth${NC}"
        track_success "GitHub Copilot CLI" "$version"
        return 0
    else
        echo -e "${RED}[HATA]${NC} GitHub Copilot CLI kurulumu başarısız!"
        track_failure "GitHub Copilot CLI" "npm install başarısız"
        return 1
    fi
}

# Install GitHub CLI
install_github_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} GitHub CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v gh &> /dev/null; then
        local version
        version=$(gh --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${CYAN}[!]${NC} GitHub CLI zaten kurulu: $version"
        track_skip "GitHub CLI" "Zaten kurulu"
        return 0
    fi

    # Ensure package manager is detected
    if [ -z "$INSTALL_CMD" ]; then
        detect_package_manager
    fi

    # Safe execution without eval (prevents command injection)
    local cmd_array
    IFS=' ' read -ra cmd_array <<< "$INSTALL_CMD"

    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} GitHub GPG key ekleniyor..."
        if ! curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg; then
            track_failure "GitHub CLI" "GPG key eklenemedi"
            return 1
        fi
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        if ! "${cmd_array[@]}" gh; then
            track_failure "GitHub CLI" "apt install başarısız"
            return 1
        fi

    elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        if ! "${cmd_array[@]}" gh; then
            track_failure "GitHub CLI" "dnf install başarısız"
            return 1
        fi

    elif [ "$PKG_MANAGER" = "pacman" ]; then
        if ! "${cmd_array[@]}" github-cli; then
            track_failure "GitHub CLI" "pacman install başarısız"
            return 1
        fi
    fi

    if command -v gh &> /dev/null; then
        local version
        version=$(gh --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} GitHub CLI kurulumu tamamlandı: $version"
        echo -e "\n${CYAN}[BİLGİ]${NC} GitHub hesabınızla oturum açmak için:"
        echo -e "  ${GREEN}gh auth login${NC}"
        track_success "GitHub CLI" "$version"
        return 0
    else
        echo -e "${RED}[HATA]${NC} GitHub CLI kurulumu başarısız!"
        track_failure "GitHub CLI" "Kurulum tamamlandı ama komut bulunamadı"
        return 1
    fi
}

# AI CLI Tools installation menu
install_ai_cli_tools_menu() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         AI CLI Araçları Kurulumu              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
    echo -e "  ${CYAN}1${NC}) Claude Code CLI"
    echo -e "  ${CYAN}2${NC}) Gemini CLI"
    echo -e "  ${CYAN}3${NC}) OpenCode CLI"
    echo -e "  ${CYAN}4${NC}) Qwen CLI"
    echo -e "  ${CYAN}5${NC}) GitHub Copilot CLI"
    echo -e "  ${CYAN}6${NC}) GitHub CLI"
    echo -e "  ${CYAN}7${NC}) Qoder CLI"
    echo -e "  ${CYAN}8${NC}) Kiro CLI"
    echo -e "  ${CYAN}9${NC}) Tümünü Kur"
    echo -e "  ${CYAN}10${NC}) Ana menüye dön"

    echo -ne "\n${YELLOW}Seçiminizi yapın (1-10): ${NC}"
    read -r choice </dev/tty

    case $choice in
        1) install_claude_code ;;
        2) install_gemini_cli ;;
        3) install_opencode_cli ;;
        4) install_qwen_cli ;;
        5) install_copilot_cli ;;
        6) install_github_cli ;;
        7) install_qoder_cli ;;
        8) install_kiro_cli ;;
        9)
            install_claude_code
            install_gemini_cli
            install_opencode_cli
            install_qwen_cli
            install_copilot_cli
            install_github_cli
            install_qoder_cli
            install_kiro_cli
            ;;
        10) return ;;
        *) echo -e "${RED}[HATA]${NC} Geçersiz seçim!" ;;
    esac
}

# Install Qoder CLI
install_qoder_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Qoder CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v qoder &> /dev/null; then
        local version
        version=$(qoder --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${CYAN}[!]${NC} Qoder CLI zaten kurulu: $version"
        track_skip "Qoder CLI" "Zaten kurulu"
        return 0
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Qoder CLI indiriliyor: $QODER_INSTALL_URL"

    # Download installer to temp file for better error handling
    local temp_installer
    temp_installer=$(mktemp)

    if curl -fsSL "$QODER_INSTALL_URL" -o "$temp_installer" 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} İndirme başarılı, kuruluyor..."

        # Run installer
        if bash "$temp_installer"; then
            rm -f "$temp_installer"
            reload_shell_configs

            if command -v qoder &> /dev/null; then
                local version
                version=$(qoder --version 2>/dev/null | head -n1 || echo "unknown")
                echo -e "${GREEN}[BAŞARILI]${NC} Qoder CLI kurulumu tamamlandı: $version"
                track_success "Qoder CLI" "$version"
                return 0
            else
                echo -e "${RED}[HATA]${NC} Kurulum tamamlandı ama qoder komutu bulunamadı!"
                echo -e "${YELLOW}[!]${NC} Shell'i yeniden yükleyin: source ~/.bashrc"
                track_failure "Qoder CLI" "Komut bulunamadı (shell reload gerekli)"
                return 1
            fi
        else
            rm -f "$temp_installer"
            echo -e "${RED}[HATA]${NC} Kurulum scripti başarısız!"
            track_failure "Qoder CLI" "Kurulum scripti başarısız"
            return 1
        fi
    else
        rm -f "$temp_installer"
        echo -e "${RED}[HATA]${NC} Qoder CLI indirilemedi!"
        echo -e "${YELLOW}[!]${NC} URL: $QODER_INSTALL_URL"
        echo -e "${YELLOW}[!]${NC} Muhtemel nedenler:"
        echo -e "    - URL geçersiz olabilir (404)"
        echo -e "    - İnternet bağlantısı sorunu"
        track_failure "Qoder CLI" "İndirme başarısız (URL veya ağ sorunu)"
        return 1
    fi
}

# Install Kiro CLI
install_kiro_cli() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Kiro CLI kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v kiro &> /dev/null; then
        local version
        version=$(kiro --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${CYAN}[!]${NC} Kiro CLI zaten kurulu: $version"
        track_skip "Kiro CLI" "Zaten kurulu"
        return 0
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Kiro CLI indiriliyor: $KIRO_INSTALL_URL"

    # Download installer to temp file for better error handling
    local temp_installer
    temp_installer=$(mktemp)

    if curl -fsSL "$KIRO_INSTALL_URL" -o "$temp_installer" 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} İndirme başarılı, kuruluyor..."

        # Run installer
        if bash "$temp_installer"; then
            rm -f "$temp_installer"
            reload_shell_configs

            if command -v kiro &> /dev/null; then
                local version
                version=$(kiro --version 2>/dev/null | head -n1 || echo "unknown")
                echo -e "${GREEN}[BAŞARILI]${NC} Kiro CLI kurulumu tamamlandı: $version"
                track_success "Kiro CLI" "$version"
                return 0
            else
                echo -e "${RED}[HATA]${NC} Kurulum tamamlandı ama kiro komutu bulunamadı!"
                echo -e "${YELLOW}[!]${NC} Shell'i yeniden yükleyin: source ~/.bashrc"
                track_failure "Kiro CLI" "Komut bulunamadı (shell reload gerekli)"
                return 1
            fi
        else
            rm -f "$temp_installer"
            echo -e "${RED}[HATA]${NC} Kurulum scripti başarısız!"
            track_failure "Kiro CLI" "Kurulum scripti başarısız"
            return 1
        fi
    else
        rm -f "$temp_installer"
        echo -e "${RED}[HATA]${NC} Kiro CLI indirilemedi!"
        echo -e "${YELLOW}[!]${NC} URL: $KIRO_INSTALL_URL"
        echo -e "${YELLOW}[!]${NC} Muhtemel nedenler:"
        echo -e "    - URL geçersiz olabilir (404)"
        echo -e "    - İnternet bağlantısı sorunu"
        track_failure "Kiro CLI" "İndirme başarısız (URL veya ağ sorunu)"
        return 1
    fi
}

# Export functions for use in other modules
export -f install_kiro_cli
export -f install_qoder_cli
export -f install_claude_code
export -f install_gemini_cli
export -f install_opencode_cli
export -f install_qwen_cli
export -f install_copilot_cli
export -f install_github_cli
export -f install_ai_cli_tools_menu
