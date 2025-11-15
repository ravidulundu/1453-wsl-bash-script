#!/bin/bash
# Module: Quick Start Mode
# Description: Simplified UX for vibe coders and beginners
# Dependencies: All other modules

# Show welcome screen for Quick Start mode
show_quickstart_welcome() {
    clear

    # DEBUG: stdin durumunu kontrol et
    echo "[DEBUG] stdin test ediliyor..." >&2
    if [ -t 0 ]; then
        echo "[DEBUG] stdin IS a terminal (TTY)" >&2
    else
        echo "[DEBUG] stdin is NOT a terminal" >&2
    fi

    if [ -e /dev/tty ]; then
        echo "[DEBUG] /dev/tty mevcut" >&2
    else
        echo "[DEBUG] /dev/tty MEVCUT DEĞİL!" >&2
    fi

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

    echo "[DEBUG] read komutu çalıştırılıyor..." >&2
    echo -ne "${YELLOW}Başlayalım mı? (Enter=Evet, n=Hayır): ${NC}"

    read -r response
    echo "[DEBUG] read tamamlandı, yanıt: '$response'" >&2

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
    echo "[DEBUG] Preset seçimi bekleniyor..." >&2
    echo -ne "${YELLOW}Seç (1-5) → Enter'a bas, kurulsun: ${NC}"
    read -r preset
    echo "[DEBUG] Preset seçildi: '$preset'" >&2

    case $preset in
        1)
            echo "[DEBUG] Web Development seçildi, dönüyor: 'web'" >&2
            echo "web"
            ;;
        2)
            echo "[DEBUG] AI Development seçildi, dönüyor: 'ai'" >&2
            echo "ai"
            ;;
        3)
            echo "[DEBUG] Backend Development seçildi, dönüyor: 'backend'" >&2
            echo "backend"
            ;;
        4)
            echo "[DEBUG] Everything seçildi, dönüyor: 'everything'" >&2
            echo "everything"
            ;;
        5)
            echo "[DEBUG] Mobile + Web seçildi, dönüyor: 'mobile'" >&2
            echo "mobile"
            ;;
        *)
            echo "[DEBUG] Geçersiz seçim: '$preset', tekrar soruluyor..." >&2
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

    # Update system and configure git first
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
                install_php_version_menu
                ;;
            "composer")
                install_composer
                ;;
            "go")
                install_go
                ;;
            "ai_cli")
                install_ai_cli_tools_menu
                ;;
            "ai_frameworks")
                install_ai_frameworks_menu
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
    echo "[DEBUG] run_quickstart_mode başladı" >&2

    # Show welcome
    echo "[DEBUG] show_quickstart_welcome çağrılıyor..." >&2
    if ! show_quickstart_welcome; then
        echo "[DEBUG] Kullanıcı 'n' dedi, geri dönüyor" >&2
        return 1
    fi
    echo "[DEBUG] show_quickstart_welcome başarılı, devam ediliyor" >&2

    # Show preset selection
    echo "[DEBUG] show_presets çağrılıyor..." >&2
    local preset=$(show_presets)
    echo "[DEBUG] Seçilen preset: '$preset'" >&2

    echo -e "\n${CYAN}⚡ Bir saniye, başlıyorum...${NC}"
    sleep 1

    # Generate and show plan
    echo "[DEBUG] generate_installation_plan çağrılıyor..." >&2
    local -a tools=($(generate_installation_plan "$preset"))
    echo "[DEBUG] Araçlar: ${tools[*]}" >&2

    # Execute installation immediately
    echo "[DEBUG] execute_installation_plan çağrılıyor..." >&2
    execute_installation_plan "${tools[@]}"

    echo "[DEBUG] Kurulum tamamlandı, kullanıcıya soruluyor..." >&2
    echo -e "\n${YELLOW}Başka bir şey kurmak ister misin? (y/N): ${NC}"
    read -r more
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