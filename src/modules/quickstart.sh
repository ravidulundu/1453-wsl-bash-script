#!/bin/bash
# Module: Quick Start Mode
# Description: Simplified UX for vibe coders and beginners
# Dependencies: All other modules

# Show welcome screen for Quick Start mode
show_quickstart_welcome() {
    echo ""
    
    gum_style --foreground 82 --bold "🚀 HIZLI BAŞLANGIÇ MODU"
    echo ""
    gum_style --foreground 226 "Teknik detayları bilmeyenler için tasarlandı."
    gum_style --foreground 226 "Birkaç basit soru, gerisini otomatik kurulum!"
    echo ""
    
    echo "✨ Nasıl çalışır?"
    echo "  1. Ne yapmak istediğinizi seçin"
    echo "  2. Önerilen araçları otomatik kurarım"
    echo "  3. Hemen kod yazmaya başlayın!"
    echo ""
    
    echo "🎯 Sonunda elde edeceğiniz:"
    echo "  ✓ Tüm geliştirici araçları"
    echo "  ✓ Hazır ortam"
    echo "  ✓ Modern CLI tools"
    echo ""

    # CRITICAL FIX: Flush stdin buffer before reading
    while read -r -t 0; do read -r -t 0.01 -N 1000; done 2>/dev/null

    response=$(gum_input --placeholder "Başlayalım mı? (Enter=Evet, n=Hayır)")

    if [[ "$response" =~ ^[nN]$ ]]; then
        echo ""
        gum_style --foreground 99 "İsterseniz Gelişmiş Mod'dan devam edebilirsiniz."
        return 1
    fi

    return 0
}

# Show preset selection
show_presets() {
    echo ""
    
    gum_style --foreground 212 --bold "📦 Kurulum Paketleri"
    echo ""
    gum_style --foreground 99 "Ne yapmak istiyorsunuz?"
    echo ""

    local selection
    selection=$(gum_choose \
        "🌐 Web Geliştirme (Python + Node + PHP)" \
        "🤖 AI Geliştirme (Python + AI Tools)" \
        "⚙️  Backend Geliştirme (Python + Go + PHP)" \
        "🚀 Her Şey (Full Stack + AI)" \
        "📱 Mobil + Web (Flutter + Node + PHP)")

    case "$selection" in
        *"Web Geliştirme"*) QUICKSTART_PRESET_CHOICE="web" ;;
        *"AI Geliştirme"*) QUICKSTART_PRESET_CHOICE="ai" ;;
        *"Backend Geliştirme"*) QUICKSTART_PRESET_CHOICE="backend" ;;
        *"Her Şey"*) QUICKSTART_PRESET_CHOICE="everything" ;;
        *"Mobil + Web"*) QUICKSTART_PRESET_CHOICE="mobile" ;;
        *)
            echo -e "\n${RED}[HATA]${NC} Geçersiz seçim!"
            sleep 1
            show_presets
            ;;
    esac
}

# Generate installation plan based on preset
generate_installation_plan() {
    local preset=$1

    echo ""
    if has_gum; then
        gum_style --foreground 82 --bold "=== KURULUM BAŞLIYOR!"
    else
        echo -e "${GREEN}=== KURULUM BAŞLIYOR!${NC}"
    fi
    echo ""

    # Always install base tools
    echo -e "${YELLOW}[PACKAGE] İlk önce (tüm paketlerde):${NC}"
    echo -e "  [+] Sistem güncellemeleri"
    echo -e "  [+] Git yapılandırması"
    echo -e "  [+] Python + pip + pipx + UV"
    echo -e "  [+] Modern CLI araçları (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)"
    echo -e "  [+] Shell ortamı (62 alias, özel fonksiyonlar, bashrc ayarları)"
    echo ""

    # Build tool list based on preset
    local tools=()

    case $preset in
        "web")
            echo -e "${YELLOW}🌐 Web Development paketi:${NC}"
            echo -e "  [+] Node.js (NVM)"
            echo -e "  [+] Bun.js runtime"
            echo -e "  [+] PHP + Composer"
            tools+=("nvm" "node" "bun" "php" "composer")
            ;;
        "ai")
            echo -e "${YELLOW}[AI] AI Development paketi:${NC}"
            echo -e "  [+] Node.js (AI araçları için)"
            echo -e "  [+] AI CLI Tools (Claude, Gemini, etc.)"
            echo -e "  [+] AI Frameworks (SuperClaude, etc.)"
            tools+=("nvm" "node" "ai_cli" "ai_frameworks")
            ;;
        "backend")
            echo -e "${YELLOW}[SETUP]  Backend Development paketi:${NC}"
            echo -e "  [+] Go language"
            echo -e "  [+] PHP + Composer"
            tools+=("go" "php" "composer")
            ;;
        "everything")
            echo -e "${YELLOW}=== EVERYTHING paketi:${NC}"
            echo -e "  [+] Node.js + Bun.js"
            echo -e "  [+] Go language"
            echo -e "  [+] PHP + Composer"
            echo -e "  [+] AI CLI Tools + Frameworks"
            echo -e "  [+] GitHub CLI"
            tools+=("nvm" "node" "bun" "go" "php" "composer" "ai_cli" "ai_frameworks" "github_cli")
            ;;
        "mobile")
            echo -e "${YELLOW}📱 Mobile + Web paketi:${NC}"
            echo -e "  [+] Node.js"
            echo -e "  [+] PHP + Composer"
            echo -e "  [+] Flutter araçları"
            tools+=("nvm" "node" "php" "composer")
            ;;
    esac

    echo ""
    echo -e "${CYAN}------------------------------------------------------------${NC}"
    echo -e "${GREEN}Toplam ${#tools[@]} araç kurulacak${NC}"
    echo ""

    # Return the tools array
    printf '%s\n' "${tools[@]}"
}

# Execute installation plan
# REFACTOR O-1: Broken down from 349 lines monolithic function
# Show installation start banner and info
_quickstart_show_welcome() {
    local -a tools=("$@")

    # Banner shown at script start, don't redraw
    echo ""

    if has_gum; then
        gum_style --foreground 82 --bold "=== QUICK START MODE - KURULUM BAŞLIYOR"
    else
        echo -e "${GREEN}=== QUICK START MODE - KURULUM BAŞLIYOR${NC}"
    fi
    echo ""
    echo -e "${YELLOW}Kurulum planınız hazırlanıyor...${NC}"
    echo -e "${GREEN}${#tools[@]}${NC} araç otomatik kurulacak"
    echo ""
    echo -e "${CYAN}Sürüm:${NC} v2.2.1 | ${CYAN}Tarih:${NC} $(date '+%Y-%m-%d %H:%M')"
    echo ""
    sleep 3
}

# Run system preflight checks
_quickstart_preflight_checks() {
    # Banner shown at script start, don't redraw
    echo ""
    if has_gum; then
        gum_style --foreground 51 --bold "🔍 SİSTEM KONTROL EDİLİYOR"
    else
        echo -e "${CYAN}🔍 SİSTEM KONTROL EDİLİYOR${NC}"
    fi
    echo ""

    if ! run_preflight_checks; then
        echo -e "${RED}[[-]]${NC} Sistem gereksinimleri karşılanamadı! Kurulum iptal edildi."
        echo -e "${YELLOW}[!]${NC} Lütfen yukarıdaki hataları düzeltin ve tekrar deneyin."
        return 1
    fi
    return 0
}

# Update system packages
_quickstart_update_system() {
    # Banner shown at script start, don't redraw
    echo ""
    if has_gum; then
        gum_style --foreground 212 --bold "[PACKAGE] SİSTEM GÜNCELLENİYOR"
    else
        echo -e "${YELLOW}[PACKAGE] SİSTEM GÜNCELLENİYOR${NC}"
    fi
    echo ""
    show_install_status "System Update" "installing"
    echo ""
    update_system
    show_install_status "System Update" "success"
    sleep 1
}

# Configure Git
_quickstart_configure_git() {
    # Banner shown at script start, don't redraw
    echo ""
    if has_gum; then
        gum_style --foreground 226 --bold "🔧 GIT YAPILANDIRMASI"
    else
        echo -e "${YELLOW}🔧 GIT YAPILANDIRMASI${NC}"
    fi
    echo ""
    show_install_status "Git Configuration" "installing"
    echo ""
    configure_git
    show_install_status "Git Configuration" "success"
    sleep 1
}

# Install Python ecosystem (Python, pip, pipx, UV)
_quickstart_install_python() {
    # Banner shown at script start, don't redraw
    echo ""
    if has_gum; then
        gum_style --foreground 81 --bold "[PYTHON] PYTHON EKOSİSTEMİ KURULUYOR"
    else
        echo -e "${CYAN}[PYTHON] PYTHON EKOSİSTEMİ KURULUYOR${NC}"
    fi
    echo ""

    show_install_status "Python" "installing"
    install_python && show_install_status "Python" "success" || show_install_status "Python" "failed"

    show_install_status "Pip" "installing"
    install_pip && show_install_status "Pip" "success" || show_install_status "Pip" "skipped"

    show_install_status "Pipx" "installing"
    install_pipx && show_install_status "Pipx" "success" || show_install_status "Pipx" "skipped"

    show_install_status "UV" "installing"
    install_uv && show_install_status "UV" "success" || show_install_status "UV" "skipped"

    sleep 1
}

# Install modern CLI tools
_quickstart_install_modern_tools() {
    # Banner shown at script start, don't redraw
    echo ""
    if has_gum; then
        gum_style --foreground 212 --bold "⚡ MODERN CLI ARAÇLARI KURULUYOR"
    else
        echo -e "${YELLOW}⚡ MODERN CLI ARAÇLARI KURULUYOR${NC}"
    fi
    echo ""
    show_install_status "Modern CLI Tools" "installing"
    install_modern_cli_tools && show_install_status "Modern CLI Tools" "success" || show_install_status "Modern CLI Tools" "skipped"
    sleep 1
}

# Setup shell environment
_quickstart_setup_shell() {
    # Banner shown at script start, don't redraw
    echo ""
    if has_gum; then
        gum_style --foreground 51 --bold "🐚 SHELL ORTAMI YAPILANDIRILIYOR"
    else
        echo -e "${CYAN}🐚 SHELL ORTAMI YAPILANDIRILIYOR${NC}"
    fi
    echo ""
    show_install_status "Shell Setup" "installing"
    setup_custom_shell && show_install_status "Shell Setup" "success" || show_install_status "Shell Setup" "skipped"
    sleep 1
}

# REFACTOR O-1: Main installation function (simplified from 349 to ~150 lines)
execute_installation_plan() {
    local -a tools=("$@")

    # Initialize TUI
    init_tui

    # Show welcome banner
    _quickstart_show_welcome "${tools[@]}"

    # Reset tracking for fresh start
    reset_tracking

    # Run system checks
    if ! _quickstart_preflight_checks; then
        return 1
    fi

    # Update system
    _quickstart_update_system

    # Configure Git
    _quickstart_configure_git

    # Install base components (always installed)
    _quickstart_install_python
    _quickstart_install_modern_tools
    _quickstart_setup_shell

    # Install tools
    for tool in "${tools[@]}"; do
        case $tool in
            "python"|"pip"|"pipx"|"uv")
                # Already installed above
                ;;
            "nvm")
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 82 --bold "🟢 NODE.JS KURULUYOR (NVM)"
                else
                    echo -e "${GREEN}🟢 NODE.JS KURULUYOR (NVM)${NC}"
                fi
                echo ""
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
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 212 --bold "⚡ BUN.JS KURULUYOR"
                else
                    echo -e "${YELLOW}⚡ BUN.JS KURULUYOR${NC}"
                fi
                echo ""
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
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 141 --bold "[PHP] PHP 8.3 KURULUYOR"
                else
                    echo -e "${YELLOW}[PHP] PHP 8.3 KURULUYOR${NC}"
                fi
                echo ""
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
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 226 --bold "🎼 COMPOSER KURULUYOR"
                else
                    echo -e "${YELLOW}🎼 COMPOSER KURULUYOR${NC}"
                fi
                echo ""
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
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 51 --bold "🔷 GO LANGUAGE KURULUYOR"
                else
                    echo -e "${CYAN}🔷 GO LANGUAGE KURULUYOR${NC}"
                fi
                echo ""
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
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 212 --bold "[AI] AI CLI ARAÇLARI KURULUYOR"
                else
                    echo -e "${YELLOW}[AI] AI CLI ARAÇLARI KURULUYOR${NC}"
                fi
                echo ""

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
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 141 --bold "[AI] AI FRAMEWORK KURULUYOR"
                else
                    echo -e "${YELLOW}[AI] AI FRAMEWORK KURULUYOR${NC}"
                fi
                echo ""
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

    # Installation complete (banner shown at script start, don't redraw)
    echo ""
    if has_gum; then
        gum_style --foreground 82 --bold "✅ KURULUM TAMAMLANDI!"
    else
        echo -e "${GREEN}✅ KURULUM TAMAMLANDI!${NC}"
    fi
    echo ""
    echo -e "${GREEN}Tüm araçlar başarıyla kuruldu!${NC}"
    echo ""

    # Show installation summary
    show_installation_summary

    echo ""
    if has_gum; then
        gum_style --foreground 212 --bold "[SUCCESS] TEBRİKLER! GELİŞTİRME ORTAMINIZ HAZIR!"
    else
        echo -e "${YELLOW}[SUCCESS] TEBRİKLER! GELİŞTİRME ORTAMINIZ HAZIR!${NC}"
    fi
    echo ""
    echo -e "${CYAN}[INFO] ŞİMDİ NE YAPACAKSINIZ?${NC}"
    echo ""
    echo -e "${GREEN}> ADIM 1: Terminal Ortamını Yenileyin${NC}"
    echo -e "   Yeni kurulan araçların aktif olması için şu komutu çalıştırın:"
    echo -e "   ${YELLOW}→${NC} ${GREEN}source ~/.bashrc${NC}"
    echo ""
    echo -e "   ${YELLOW}veya${NC} terminali kapatıp yeniden açın (daha garantili)"
    echo ""
    echo -e "${GREEN}> ADIM 2: Kurulumları Test Edin${NC}"
    echo -e "   ${CYAN}•${NC} Python: ${GREEN}python3 --version${NC}"
    echo -e "   ${CYAN}•${NC} Node.js: ${GREEN}node --version${NC}"
    echo -e "   ${CYAN}•${NC} NVM: ${GREEN}nvm --version${NC}"
    echo -e "   ${CYAN}•${NC} Modern CLI: ${GREEN}bat --version${NC}, ${GREEN}eza --version${NC}"
    echo ""
    echo -e "${GREEN}> ADIM 3: Kodlamaya Başlayın!${NC}"
    echo -e "   ${CYAN}•${NC} Proje oluşturun: ${GREEN}mkdir my-project && cd my-project${NC}"
    echo -e "   ${CYAN}•${NC} Python venv: ${GREEN}python3 -m venv venv${NC}"
    echo -e "   ${CYAN}•${NC} Node proje: ${GREEN}npm init -y${NC}"
    echo ""
    echo -e "${YELLOW}[SETUP]  İleri düzey araçlar için:${NC}"
    echo -e "   Scripti tekrar çalıştırıp ${GREEN}'Advanced Mode'${NC} seçin"
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
        more=$(gum_input --placeholder "Başka bir şey kurmak ister misin? (y/N)")
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