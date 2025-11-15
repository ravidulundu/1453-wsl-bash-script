#!/bin/bash
# Module: Quick Start Mode
# Description: Simplified UX for vibe coders and beginners
# Dependencies: All other modules

# Show welcome screen for Quick Start mode
show_quickstart_welcome() {
    clear

    echo -e "${CYAN}"
    cat << 'EOF'
    ╔════════════════════════════════════════════════════════════════╗
    ║                                                                ║
    ║        🚀 1453.AI QUICK START - VIBE CODERS İÇİN 🚀           ║
    ║                                                                ║
    ╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${GREEN}Merhaba vibe coder! 👋${NC}"
    echo ""
    echo -e "${YELLOW}Bu mod, teknik detayları bilmeyenler için tasarlandı.${NC}"
    echo -e "${YELLOW}Size birkaç basit soru soracağım, gerisini bana bırakın! ✨${NC}"
    echo ""
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}💡 Nasıl çalışır?${NC}"
    echo -e "  1. Deneyim seviyenizi belirtirsiniz"
    echo -e "  2. Ne yapmak istediğinizi seçersiniz"
    echo -e "  3. Size önerilen araçları otomatik kurarım"
    echo ""
    echo -e "${YELLOW}🎯 Sonunda şunları elde edersiniz:${NC}"
    echo -e "  ✓ İhtiyacınız olan tüm geliştirici araçları"
    echo -e "  ✓ Hazır ortam"
    echo -e "  ✓ Hemen kod yazmaya başlayabilirsiniz!"
    echo ""
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
    echo ""

    # CRITICAL FIX: Flush stdin buffer before reading
    # Clear any pending input that might cause read to return immediately
    while read -r -t 0; do read -r -t 0.01 -N 1000; done 2>/dev/null

    echo -ne "${YELLOW}Başlayalım mı? (Enter=Evet, n=Hayır): ${NC}"
    read -r response </dev/tty

    if [[ "$response" =~ ^[nN]$ ]]; then
        echo -e "\n${CYAN}ℹ️  ${NC}İsterseniz Advanced Mode'dan devam edebilirsiniz."
        echo -e "${YELLOW}⚙️  Advanced Mode${NC} → Detaylı menü ile kendiniz seçim yapabilirsiniz."
        return 1
    fi

    return 0
}

# Show preset selection
show_presets() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    KURULUM PAKETLERİ                        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Ne yapmak istiyorsun? Hangi paketi istiyorsun: ${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) 🌐 ${YELLOW}WEB DEVELOPMENT${NC}"
    echo -e "     ${CYAN}Python + Node.js + PHP + Composer${NC}"
    echo -e "     ${CYAN}Web siteleri, API'ler, full-stack uygulamalar için${NC}"
    echo ""
    echo -e "  ${GREEN}2${NC}) 🤖 ${YELLOW}AI DEVELOPMENT${NC}"
    echo -e "     ${CYAN}Python + AI CLI Tools + AI Frameworks${NC}"
    echo -e "     ${CYAN}Makine öğrenmesi, AI modelleri, veri analizi${NC}"
    echo ""
    echo -e "  ${GREEN}3${NC}) ⚙️  ${YELLOW}BACKEND DEVELOPMENT${NC}"
    echo -e "     ${CYAN}Python + Go + PHP + Composer${NC}"
    echo -e "     ${CYAN}API'ler, mikroservisler, sunucu tarafı${NC}"
    echo ""
    echo -e "  ${GREEN}4${NC}) 🚀 ${YELLOW}EVERYTHING${NC}"
    echo -e "     ${CYAN}Her şeyi kur, full-stack + AI + Backend${NC}"
    echo -e "     ${CYAN}Her türlü geliştirme için komple ortam${NC}"
    echo ""
    echo -e "  ${GREEN}5${NC}) 📱 ${YELLOW}MOBILE + WEB${NC}"
    echo -e "     ${CYAN}Python + Node.js + PHP + Flutter araçları${NC}"
    echo -e "     ${CYAN}Mobil + web uygulamaları${NC}"
    echo ""
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
    echo ""

    # CRITICAL FIX: Flush stdin buffer before reading
    while read -r -t 0; do read -r -t 0.01 -N 1000; done 2>/dev/null

    echo -ne "${YELLOW}Seç (1-5) → Enter'a bas, kurulsun: ${NC}"
    read -r preset </dev/tty

    case $preset in
        1)
            QUICKSTART_PRESET_CHOICE="web"
            ;;
        2)
            QUICKSTART_PRESET_CHOICE="ai"
            ;;
        3)
            QUICKSTART_PRESET_CHOICE="backend"
            ;;
        4)
            QUICKSTART_PRESET_CHOICE="everything"
            ;;
        5)
            QUICKSTART_PRESET_CHOICE="mobile"
            ;;
        *)
            echo -e "\n${RED}[HATA]${NC} 1-5 arası seç, toy! 😄"
            sleep 1
            show_presets
            ;;
    esac
}

# Generate installation plan based on preset
generate_installation_plan() {
    local preset=$1

    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  KURULUM BAŞLIYOR! 🚀                       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Always install base tools
    echo -e "${YELLOW}📦 İlk önce (tüm paketlerde):${NC}"
    echo -e "  ✓ Sistem güncellemeleri"
    echo -e "  ✓ Git yapılandırması"
    echo -e "  ✓ Python + pip + pipx + UV"
    echo -e "  ✓ Modern CLI araçları (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)"
    echo -e "  ✓ Shell ortamı (62 alias, özel fonksiyonlar, bashrc ayarları)"
    echo ""

    # Build tool list based on preset
    local tools=()

    case $preset in
        "web")
            echo -e "${YELLOW}🌐 Web Development paketi:${NC}"
            echo -e "  ✓ Node.js (NVM)"
            echo -e "  ✓ Bun.js runtime"
            echo -e "  ✓ PHP + Composer"
            tools+=("nvm" "node" "bun" "php" "composer")
            ;;
        "ai")
            echo -e "${YELLOW}🤖 AI Development paketi:${NC}"
            echo -e "  ✓ Node.js (AI araçları için)"
            echo -e "  ✓ AI CLI Tools (Claude, Gemini, etc.)"
            echo -e "  ✓ AI Frameworks (SuperClaude, etc.)"
            tools+=("nvm" "node" "ai_cli" "ai_frameworks")
            ;;
        "backend")
            echo -e "${YELLOW}⚙️  Backend Development paketi:${NC}"
            echo -e "  ✓ Go language"
            echo -e "  ✓ PHP + Composer"
            tools+=("go" "php" "composer")
            ;;
        "everything")
            echo -e "${YELLOW}🚀 EVERYTHING paketi:${NC}"
            echo -e "  ✓ Node.js + Bun.js"
            echo -e "  ✓ Go language"
            echo -e "  ✓ PHP + Composer"
            echo -e "  ✓ AI CLI Tools + Frameworks"
            echo -e "  ✓ GitHub CLI"
            tools+=("nvm" "node" "bun" "go" "php" "composer" "ai_cli" "ai_frameworks" "github_cli")
            ;;
        "mobile")
            echo -e "${YELLOW}📱 Mobile + Web paketi:${NC}"
            echo -e "  ✓ Node.js"
            echo -e "  ✓ PHP + Composer"
            echo -e "  ✓ Flutter araçları"
            tools+=("nvm" "node" "php" "composer")
            ;;
    esac

    echo ""
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}Toplam ${#tools[@]} araç kurulacak${NC}"
    echo ""

    # Return the tools array
    printf '%s\n' "${tools[@]}"
}

# Execute installation plan
execute_installation_plan() {
    local -a tools=("$@")

    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    KURULUM BAŞLIYOR!                        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Run pre-flight checks first
    if ! run_preflight_checks; then
        echo -e "${RED}[✗]${NC} Sistem gereksinimleri karşılanamadı! Kurulum iptal edildi."
        echo -e "${YELLOW}[!]${NC} Lütfen yukarıdaki hataları düzeltin ve tekrar deneyin."
        return 1
    fi

    # Update system and configure git
    update_system
    configure_git

    # Install Python + modern CLI tools first (base for all presets)
    install_python
    install_pip
    install_pipx
    install_uv
    install_modern_cli_tools
    setup_custom_shell

    # Install tools
    for tool in "${tools[@]}"; do
        case $tool in
            "python"|"pip"|"pipx"|"uv")
                # Already installed above
                ;;
            "nvm")
                install_nvm
                ;;
            "node")
                # Already installed with nvm
                ;;
            "bun")
                install_bun
                ;;
            "php")
                # Quick Start: Install PHP 8.3 (stable) automatically without menu
                echo -e "${YELLOW}[QUICK START]${NC} PHP 8.3 otomatik kuruluyor..."
                install_php_version "8.3"
                ;;
            "composer")
                install_composer
                ;;
            "go")
                install_go
                ;;
            "ai_cli")
                # Quick Start: Install essential AI CLI tools automatically
                echo -e "${YELLOW}[QUICK START]${NC} AI CLI araçları otomatik kuruluyor..."
                install_claude_code
                install_github_cli
                ;;
            "ai_frameworks")
                # Quick Start: Install SuperClaude framework automatically
                echo -e "${YELLOW}[QUICK START]${NC} SuperClaude framework otomatik kuruluyor..."
                install_superclaude
                ;;
            "git_config")
                # Already configured
                ;;
        esac
    done

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  ✅ KURULUM TAMAMLANDI!                      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}🎉 Tebrikler! Geliştirme ortamınız hazır!${NC}"
    echo ""
    echo -e "${CYAN}💡 Sonraki adımlar:${NC}"
    echo -e "  1. ${GREEN}source ~/.bashrc${NC} (ya da terminali yeniden başlat)"
    echo -e "  2. ${GREEN}Python --version${NC} ile test edin"
    echo -e "  3. ${GREEN}node --version${NC} ile test edin"
    echo -e "  4. 🚀 Kodlamaya başlayın!"
    echo ""
    echo -e "${YELLOW}⚙️  İleri düzey araçlar için:${NC}"
    echo -e "    Scripti tekrar çalıştırıp 'Advanced Mode' seçin"
    echo ""
}

# Main Quick Start flow
run_quickstart_mode() {
    # Show welcome
    if ! show_quickstart_welcome; then
        return 1
    fi

    # Show preset selection
    show_presets
    local preset="$QUICKSTART_PRESET_CHOICE"

    echo -e "\n${CYAN}⚡ Bir saniye, başlıyorum...${NC}"
    sleep 1

    # Generate and show plan
    local -a tools=($(generate_installation_plan "$preset"))

    # Execute installation immediately
    execute_installation_plan "${tools[@]}"
    echo -e "\n${YELLOW}Başka bir şey kurmak ister misin? (y/N): ${NC}"
    read -r more </dev/tty
    if [[ ! "$more" =~ ^[yY]$ ]]; then
        exit 0
    fi

    return 0
}

# Export functions
export -f show_quickstart_welcome
export -f show_presets
export -f generate_installation_plan
export -f execute_installation_plan
export -f run_quickstart_mode