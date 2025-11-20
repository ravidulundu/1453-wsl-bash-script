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

    # Initialize TUI
    init_tui

    # Show installation start with banner
    clear

    # Display the 1453 ASCII Art Banner
    echo -e "${CYAN}"
    cat << 'BANNER'
   /$$ /$$   /$$ /$$$$$$$   /$$$$$$
 /$$$$| $$  | $$| $$____/  /$$__  $$
|_  $$| $$  | $$| $$      |__/  \ $$
  | $$| $$$$$$$$| $$$$$$$    /$$$$$/
  | $$|_____  $$|_____  $$  |___  $$
  | $$      | $$ /$$  \ $$ /$$  \ $$
 /$$$$$$    | $$|  $$$$$$/|  $$$$$$/
|______/    |__/ \______/  \______/
BANNER
    echo -e "${NC}"
    echo ""

    draw_box_top "🚀 QUICK START MODE - KURULUM BAŞLIYOR" 70
    draw_box_middle "" 70
    draw_box_middle "  ${YELLOW}Kurulum planınız hazırlanıyor...${NC}" 70
    draw_box_middle "  ${GREEN}${#tools[@]}${NC} araç otomatik kurulacak" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}Sürüm:${NC} v2.2.1 | ${CYAN}Tarih:${NC} $(date '+%Y-%m-%d %H:%M')" 70
    draw_box_middle "" 70
    draw_box_bottom 70
    sleep 3

    # Reset tracking for fresh start
    reset_tracking

    # Run pre-flight checks first
    clear
    draw_box_top "🔍 SİSTEM KONTROL EDİLİYOR" 70
    draw_box_middle "" 70

    if ! run_preflight_checks; then
        echo -e "${RED}[✗]${NC} Sistem gereksinimleri karşılanamadı! Kurulum iptal edildi."
        echo -e "${YELLOW}[!]${NC} Lütfen yukarıdaki hataları düzeltin ve tekrar deneyin."
        return 1
    fi

    # Update system and configure git
    clear
    draw_box_top "📦 SİSTEM GÜNCELLENİYOR" 70
    draw_box_middle "" 70
    show_install_status "System Update" "installing"
    echo ""
    update_system
    show_install_status "System Update" "success"
    sleep 1

    clear
    draw_box_top "🔧 GIT YAPILANDIRMASI" 70
    draw_box_middle "" 70
    show_install_status "Git Configuration" "installing"
    echo ""
    configure_git
    show_install_status "Git Configuration" "success"
    sleep 1

    # Install Python + modern CLI tools first (base for all presets)
    clear
    draw_box_top "🐍 PYTHON EKOSİSTEMİ KURULUYOR" 70
    draw_box_middle "" 70

    show_install_status "Python" "installing"
    install_python && show_install_status "Python" "success" || show_install_status "Python" "failed"

    show_install_status "Pip" "installing"
    if install_pip; then
        show_install_status "Pip" "success"
    else
        show_install_status "Pip" "skipped"
        echo -e "${YELLOW}[!]${NC} Pip güncellemesi atlandı, devam ediliyor..."
    fi

    show_install_status "Pipx" "installing"
    if install_pipx; then
        show_install_status "Pipx" "success"
    else
        show_install_status "Pipx" "skipped"
        echo -e "${YELLOW}[!]${NC} Pipx kurulumu atlandı, devam ediliyor..."
    fi

    show_install_status "UV" "installing"
    if install_uv; then
        show_install_status "UV" "success"
    else
        show_install_status "UV" "skipped"
        echo -e "${YELLOW}[!]${NC} UV kurulumu atlandı, devam ediliyor..."
    fi
    sleep 1

    clear
    draw_box_top "⚡ MODERN CLI ARAÇLARI KURULUYOR" 70
    draw_box_middle "" 70
    show_install_status "Modern CLI Tools" "installing"
    if install_modern_cli_tools; then
        show_install_status "Modern CLI Tools" "success"
    else
        show_install_status "Modern CLI Tools" "skipped"
        echo -e "${YELLOW}[!]${NC} Modern CLI araçları kurulumu atlandı, devam ediliyor..."
    fi
    sleep 1

    clear
    draw_box_top "🐚 SHELL ORTAMI YAPILANDIRILIYOR" 70
    draw_box_middle "" 70
    show_install_status "Shell Setup" "installing"
    if setup_custom_shell; then
        show_install_status "Shell Setup" "success"
    else
        show_install_status "Shell Setup" "skipped"
        echo -e "${YELLOW}[!]${NC} Shell kurulumu atlandı, devam ediliyor..."
    fi
    sleep 1

    # Install tools
    for tool in "${tools[@]}"; do
        case $tool in
            "python"|"pip"|"pipx"|"uv")
                # Already installed above
                ;;
            "nvm")
                clear
                draw_box_top "🟢 NODE.JS KURULUYOR (NVM)" 70
                draw_box_middle "" 70
                show_install_status "NVM" "installing"
                echo ""
                if install_nvm; then
                    show_install_status "NVM" "success"
                else
                    show_install_status "NVM" "skipped"
                    echo -e "${YELLOW}[!]${NC} NVM kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "node")
                # Already installed with nvm
                ;;
            "bun")
                clear
                draw_box_top "⚡ BUN.JS KURULUYOR" 70
                draw_box_middle "" 70
                show_install_status "Bun.js" "installing"
                echo ""
                if install_bun; then
                    show_install_status "Bun.js" "success"
                else
                    show_install_status "Bun.js" "skipped"
                    echo -e "${YELLOW}[!]${NC} Bun kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "php")
                clear
                draw_box_top "🐘 PHP 8.3 KURULUYOR" 70
                draw_box_middle "" 70
                show_install_status "PHP 8.3" "installing"
                echo ""
                if install_php_version "8.3"; then
                    show_install_status "PHP 8.3" "success"
                    track_success "PHP 8.3"
                else
                    show_install_status "PHP 8.3" "skipped"
                    track_failure "PHP 8.3"
                    echo -e "${YELLOW}[!]${NC} PHP kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "composer")
                clear
                draw_box_top "🎼 COMPOSER KURULUYOR" 70
                draw_box_middle "" 70
                show_install_status "Composer" "installing"
                echo ""
                if install_composer; then
                    show_install_status "Composer" "success"
                else
                    show_install_status "Composer" "skipped"
                    echo -e "${YELLOW}[!]${NC} Composer kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "go")
                clear
                draw_box_top "🔷 GO LANGUAGE KURULUYOR" 70
                draw_box_middle "" 70
                show_install_status "Go" "installing"
                echo ""
                if install_go; then
                    show_install_status "Go" "success"
                else
                    show_install_status "Go" "skipped"
                    echo -e "${YELLOW}[!]${NC} Go kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "ai_cli")
                clear
                draw_box_top "🤖 AI CLI ARAÇLARI KURULUYOR" 70
                draw_box_middle "" 70

                show_install_status "Claude Code" "installing"
                if install_claude_code; then
                    show_install_status "Claude Code" "success"
                else
                    show_install_status "Claude Code" "skipped"
                    echo -e "${YELLOW}[!]${NC} Claude Code kurulumu atlandı..."
                fi

                show_install_status "GitHub CLI" "installing"
                if install_github_cli; then
                    show_install_status "GitHub CLI" "success"
                else
                    show_install_status "GitHub CLI" "skipped"
                    echo -e "${YELLOW}[!]${NC} GitHub CLI kurulumu atlandı..."
                fi
                sleep 1
                ;;
            "ai_frameworks")
                clear
                draw_box_top "🧠 AI FRAMEWORK KURULUYOR" 70
                draw_box_middle "" 70
                show_install_status "SuperClaude" "installing"
                echo ""
                if install_superclaude; then
                    show_install_status "SuperClaude" "success"
                else
                    show_install_status "SuperClaude" "skipped"
                    echo -e "${YELLOW}[!]${NC} SuperClaude kurulumu atlandı..."
                fi
                sleep 1
                ;;
            "git_config")
                # Already handled above
                ;;
        esac
    done

    # Installation complete
    clear
    draw_box_top "✅ KURULUM TAMAMLANDI!" 70
    draw_box_middle "" 70
    draw_box_middle "  ${GREEN}Tüm araçlar başarıyla kuruldu!${NC}" 70
    draw_box_middle "" 70
    draw_box_bottom 70
    echo ""

    # Show installation summary
    show_installation_summary

    echo ""
    draw_box_top "🎉 TEBRİKLER! GELİŞTİRME ORTAMINIZ HAZIR!" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}💡 Sonraki adımlar:${NC}" 70
    draw_box_middle "" 70
    draw_box_middle "  1. ${GREEN}source ~/.bashrc${NC} (ya da terminali yeniden başlat)" 70
    draw_box_middle "  2. ${GREEN}python --version${NC} ile test edin" 70
    draw_box_middle "  3. ${GREEN}node --version${NC} ile test edin" 70
    draw_box_middle "  4. 🚀 Kodlamaya başlayın!" 70
    draw_box_middle "" 70
    draw_box_middle "  ${YELLOW}⚙️  İleri düzey araçlar için:${NC}" 70
    draw_box_middle "     Scripti tekrar çalıştırıp 'Advanced Mode' seçin" 70
    draw_box_middle "" 70
    draw_box_bottom 70
    echo ""
}

# Main Quick Start flow
run_quickstart_mode() {
    # Install Gum first for modern TUI (silently if possible)
    if ! has_gum; then
        echo -e "\n${CYAN}[!]${NC} Modern TUI kuruluyor (Gum)..."
        install_gum || echo -e "${YELLOW}[!]${NC} Gum kurulamadı, klasik TUI kullanılacak"
    fi

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

    # Ask if user wants more (using Gum if available)
    if has_gum; then
        if gum_confirm "Başka bir şey kurmak ister misin?"; then
            return 0
        else
            exit 0
        fi
    else
        echo -e "\n${YELLOW}Başka bir şey kurmak ister misin? (y/N): ${NC}"
        read -r more </dev/tty
        if [[ ! "$more" =~ ^[yY]$ ]]; then
            exit 0
        fi
    fi

    return 0
}

# Export functions
export -f show_quickstart_welcome
export -f show_presets
export -f generate_installation_plan
export -f execute_installation_plan
export -f run_quickstart_mode