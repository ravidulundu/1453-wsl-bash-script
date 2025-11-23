#!/bin/bash
# Module: AI CLI Tools (REFACTORED - PRD Compliant)
# All remaining functions with Gum UI

# Install Gemini CLI
install_gemini_cli() {
    echo ""
    gum_header "GEMINI CLI" "Google AI SDK"

    if python3 -c "import google.generativeai" 2>/dev/null; then
        gum_success "Atlandı" "Gemini CLI zaten kurulu"
        track_skip "Gemini CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        gum_alert "Gereksinim" "Python kurulu değil"
        install_python || return 1
    fi

    if gum_spin_run "Google AI SDK kuruluyor..." "python3 -m pip install google-generativeai --break-system-packages 2>/dev/null || python3 -m pip install google-generativeai"; then
        local version
        version=$(python3 -c "import google.generativeai; print(google.generativeai.__version__)" 2>/dev/null || echo "unknown")
        gum_success "Başarılı" "Gemini CLI kuruldu: $version"
        track_success "Gemini CLI" "$version"
        return 0
    else
        gum_alert "Hata" "Gemini CLI kurulumu başarısız!"
        track_failure "Gemini CLI" "pip install başarısız"
        return 1
    fi
}

# Install OpenCode CLI
install_opencode_cli() {
    echo ""
    gum_header "OPENCODE CLI" "AI Code Assistant"

    if command -v opencode &> /dev/null; then
        local version
        version=$(opencode --version 2>/dev/null | head -n1 || echo "unknown")
        gum_success "Atlandı" "OpenCode CLI zaten kurulu: $version"
        track_skip "OpenCode CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        gum_alert "Gereksinim" "NPM kurulu değil"
        install_nvm || return 1
    fi

    if gum_spin_run "OpenCode CLI kuruluyor..." "npm install -g opencode-cli"; then
        reload_shell_configs
        if command -v opencode &> /dev/null; then
            local version
            version=$(opencode --version 2>/dev/null | head -n1 || echo "unknown")
            gum_success "Başarılı" "OpenCode CLI kuruldu: $version"
            track_success "OpenCode CLI" "$version"
            return 0
        else
            gum_alert "Dikkat" "Kurulum tamamlandı ama 'opencode' komutu bulunamadı"
            track_failure "OpenCode CLI" "Komut bulunamadı"
            return 1
        fi
    else
        gum_alert "Hata" "OpenCode CLI kurulumu başarısız!"
        track_failure "OpenCode CLI" "npm install başarısız"
        return 1
    fi
}

# Install Qwen CLI
install_qwen_cli() {
    echo ""
    gum_header "QWEN CLI" "Alibaba Qwen Assistant"

    if command -v qwen &> /dev/null; then
        local version
        version=$(qwen --version 2>/dev/null | head -n1 || echo "unknown")
        gum_success "Atlandı" "Qwen CLI zaten kurulu: $version"
        track_skip "Qwen CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        gum_alert "Gereksinim" "NPM kurulu değil"
        install_nvm || return 1
    fi

    if gum_spin_run "Qwen CLI kuruluyor..." "npm install -g @alibaba-inc/qwen-cli"; then
        reload_shell_configs
        if command -v qwen &> /dev/null; then
            local version
            version=$(qwen --version 2>/dev/null | head -n1 || echo "unknown")
            gum_success "Başarılı" "Qwen CLI kuruldu: $version"
            gum_info "İpucu" "API key: export QWEN_API_KEY='your-key'"
            track_success "Qwen CLI" "$version"
            return 0
        else
            gum_alert "Dikkat" "Shell'i yenileyin: source ~/.bashrc"
            track_failure "Qwen CLI" "Komut bulunamadı"
            return 1
        fi
    else
        gum_alert "Hata" "Qwen CLI kurulumu başarısız!"
        track_failure "Qwen CLI" "npm install başarısız"
        return 1
    fi
}

# Install Copilot CLI
install_copilot_cli() {
    echo ""
    gum_header "GITHUB COPILOT CLI" "AI Pair Programming"

    if command -v github-copilot-cli &> /dev/null; then
        local version
        version=$(npm list -g @githubnext/github-copilot-cli 2>/dev/null | grep github-copilot-cli | awk '{print $2}' || echo "unknown")
        gum_success "Atlandı" "GitHub Copilot CLI zaten kurulu: $version"
        track_skip "GitHub Copilot CLI" "Zaten kurulu"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        gum_alert "Gereksinim" "NPM kurulu değil"
        install_nvm || return 1
    fi

    if gum_spin_run "GitHub Copilot CLI kuruluyor..." "npm install -g @githubnext/github-copilot-cli"; then
        reload_shell_configs
        local version
        version=$(npm list -g @githubnext/github-copilot-cli 2>/dev/null | grep github-copilot-cli | awk '{print $2}' || echo "unknown")
        gum_success "Başarılı" "GitHub Copilot CLI kuruldu: $version"
        gum_info "İpucu" "Giriş için: github-copilot-cli auth"
        track_success "GitHub Copilot CLI" "$version"
        return 0
    else
        gum_alert "Hata" "GitHub Copilot CLI kurulumu başarısız!"
        track_failure "GitHub Copilot CLI" "npm install başarısız"
        return 1
    fi
}

# Install Qoder CLI
install_qoder_cli() {
    echo ""
    gum_header "QODER CLI" "AI Code Generator"

    if command -v qoder &> /dev/null; then
        local version
        version=$(qod

er --version 2>/dev/null | head -n1 || echo "unknown")
        gum_success "Atlandı" "Qoder CLI zaten kurulu: $version"
        track_skip "Qoder CLI" "Zaten kurulu"
        return 0
    fi

    local temp_installer=$(mktemp)
    local install_cmd="
        if curl -fsSL \"$QODER_INSTALL_URL\" -o \"$temp_installer\" 2>/dev/null; then
            bash \"$temp_installer\"
            rm -f \"$temp_installer\"
        else
            rm -f \"$temp_installer\"
            exit 1
        fi
    "

    if gum_spin_run "Qoder CLI kuruluyor..." "$install_cmd"; then
        reload_shell_configs
        if command -v qoder &> /dev/null; then
            local version
            version=$(qoder --version 2>/dev/null | head -n1 || echo "unknown")
            gum_success "Başarılı" "Qoder CLI kuruldu: $version"
            track_success "Qoder CLI" "$version"
            return 0
        else
            gum_alert "Dikkat" "Shell'i yenileyin: source ~/.bashrc"
            track_failure "Qoder CLI" "Komut bulunamadı"
            return 1
        fi
    else
        gum_alert "Hata" "Qoder CLI kurulumu başarısız!"
        track_failure "Qoder CLI" "İndirme veya kurulum başarısız"
        return 1
    fi
}

# Install Kiro CLI
install_kiro_cli() {
    echo ""
    gum_header "KIRO CLI" "AI Assistant"

    if command -v kiro &> /dev/null; then
        local version
        version=$(kiro --version 2>/dev/null | head -n1 || echo "unknown")
        gum_success "Atlandı" "Kiro CLI zaten kurulu: $version"
        track_skip "Kiro CLI" "Zaten kurulu"
        return 0
    fi

    local temp_installer=$(mktemp)
    local install_cmd="
        if curl -fsSL \"$KIRO_INSTALL_URL\" -o \"$temp_installer\" 2>/dev/null; then
            bash \"$temp_installer\"
            rm -f \"$temp_installer\"
        else
            rm -f \"$temp_installer\"
            exit 1
        fi
    "

    if gum_spin_run "Kiro CLI kuruluyor..." "$install_cmd"; then
        reload_shell_configs
        if command -v kiro &> /dev/null; then
            local version
            version=$(kiro --version 2>/dev/null | head -n1 || echo "unknown")
            gum_success "Başarılı" "Kiro CLI kuruldu: $version"
            track_success "Kiro CLI" "$version"
            return 0
        else
            gum_alert "Dikkat" "Shell'i yenileyin: source ~/.bashrc"
            track_failure "Kiro CLI" "Komut bulunamadı"
            return 1
        fi
    else
        gum_alert "Hata" "Kiro CLI kurulumu başarısız!"
        track_failure "Kiro CLI" "İndirme veya kurulum başarısız"
        return 1
    fi
}

# AI CLI Tools installation menu
install_ai_cli_tools_menu() {
    echo ""
    gum_header "AI CLI TOOLS" "Terminal AI Asistanları"

    local selection
    selection=$(gum_choose_enhanced \
        "🧠 Claude Code CLI" \
        "🔷 Gemini CLI" \
        "💻 OpenCode CLI" \
        "🌟 Qwen CLI" \
        "🤖 GitHub Copilot CLI" \
        "⚡ Qoder CLI" \
        "🎯 Kiro CLI" \
        "📦 GitHub CLI (gh)" \
        "🔙 Ana menüye dön")

    case "$selection" in
        *"Claude Code"*) install_claude_code ;;
        *"Gemini"*) install_gemini_cli ;;
        *"OpenCode"*) install_opencode_cli ;;
        *"Qwen"*) install_qwen_cli ;;
        *"Copilot"*) install_copilot_cli ;;
        *"Qoder"*) install_qoder_cli ;;
        *"Kiro"*) install_kiro_cli ;;
        *"GitHub CLI"*) install_github_cli ;;
        *"Ana menüye dön"*|"") return ;;
    esac
}

# Export functions
export -f install_gemini_cli
export -f install_opencode_cli
export -f install_qwen_cli
export -f install_copilot_cli
export -f install_qoder_cli
export -f install_kiro_cli
export -f install_ai_cli_tools_menu
