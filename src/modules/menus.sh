#!/bin/bash
# Module: Interactive Menus
# Description: Main menu system and user interaction
# Dependencies: All other modules

# Configure Git
configure_git() {
    echo ""
    echo -e "${YELLOW}[BİLGİ]${NC} Git yapılandırması başlatılıyor..."

    # Check existing git configuration
    local current_user
    local current_email
    current_user=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [ -n "$current_user" ] && [ -n "$current_email" ]; then
        echo -e "${CYAN}[!]${NC} Mevcut Git yapılandırması:"
        echo -e "  Kullanıcı: ${GREEN}$current_user${NC}"
        echo -e "  E-posta: ${GREEN}$current_email${NC}"
        echo ""

        # Use Gum confirm if available
        if ! gum_confirm "Yeni yapılandırma yapmak istiyor musunuz?"; then
            echo -e "${CYAN}[!]${NC} Git yapılandırması değiştirilmedi"
            track_skip "Git Yapılandırması" "Mevcut yapılandırma korundu"
            return 0
        fi
    fi

    # Use Gum input if available
    local git_user
    local git_email

    git_user=$(gum_input --placeholder "Git kullanıcı adınızı girin" --value "$current_user")
    git_email=$(gum_input --placeholder "Git e-posta adresinizi girin" --value "$current_email")

    if [ -z "$git_user" ] || [ -z "$git_email" ]; then
        echo -e "${RED}[HATA]${NC} Kullanıcı adı ve e-posta gereklidir!"
        track_failure "Git Yapılandırması" "Eksik bilgi"
        return 1
    fi

    git config --global user.name "$git_user"
    git config --global user.email "$git_email"

    echo -e "${GREEN}[BAŞARILI]${NC} Git yapılandırması tamamlandı!"
    echo -e "  Kullanıcı: $git_user"
    echo -e "  E-posta: $git_email"
    track_success "Git Yapılandırması" "$git_user <$git_email>"
}

# Prepare and configure Git
prepare_and_configure_git() {
    update_system
    configure_git
}

# Display main menu
show_menu() {
    echo ""
    draw_box_top "⚙️  ADVANCED MODE - ANA MENÜ" 80
    draw_box_middle "" 80
    draw_box_middle "  ${CYAN}Python & JavaScript:${NC}" 80
    draw_box_middle "    ${GREEN}3${NC}) Python  ${GREEN}4${NC}) Pip  ${GREEN}5${NC}) Pipx  ${GREEN}6${NC}) UV" 80
    draw_box_middle "    ${GREEN}7${NC}) NVM  ${GREEN}8${NC}) Bun.js" 80
    draw_box_middle "" 80
    draw_box_middle "  ${CYAN}Backend & Languages:${NC}" 80
    draw_box_middle "    ${GREEN}9${NC}) PHP  ${GREEN}10${NC}) Composer  ${GREEN}14${NC}) Go" 80
    draw_box_middle "" 80
    draw_box_middle "  ${CYAN}AI & Modern Tools:${NC}" 80
    draw_box_middle "    ${GREEN}11${NC}) AI CLI Araçları  ${GREEN}12${NC}) AI Frameworks" 80
    draw_box_middle "    ${GREEN}15${NC}) Modern CLI Tools  ${GREEN}16${NC}) Shell Ortamı" 80
    draw_box_middle "" 80
    draw_box_middle "  ${CYAN}Docker & Utilities:${NC}" 80
    draw_box_middle "    ${GREEN}18${NC}) 🐳 Docker (Engine + lazydocker)" 80
    draw_box_middle "" 80
    draw_box_middle "  ${CYAN}Quick Actions:${NC}" 80
    draw_box_middle "    ${GREEN}1${NC}) ✨ Tam Kurulum (Önerilen)" 80
    draw_box_middle "    ${GREEN}2${NC}) 🔧 Hazırlık (Sistem + Git)" 80
    draw_box_middle "    ${RED}13${NC}) ❌ AI Frameworks Kaldır" 80
    draw_box_middle "    ${RED}17${NC}) 🗑️  Temizleme & Sıfırlama" 80
    draw_box_middle "" 80
    draw_box_middle "  ${GREEN}0${NC}) ◀ Ana Menüye Dön" 80
    draw_box_middle "" 80
    draw_box_bottom 80
}

# Show mode selection menu
show_mode_selection() {
    while true; do
        clear
        show_banner
        echo ""

        # Modern TUI with Gum if available
        if has_gum; then
            # Banner shown above, now show mode selection question
            gum_style --foreground 212 --bold "🎯 Hangi kurulum modunu tercih edersiniz?"
            echo ""

            local selection
            selection=$(gum_choose \
                "🚀 QUICK START MODE (Önerilen)" \
                "⚙️  ADVANCED MODE" \
                "❌ Çıkış")

            case "$selection" in
                "🚀 QUICK START MODE (Önerilen)")
                    echo ""
                    run_quickstart_mode
                    continue
                    ;;
                "⚙️  ADVANCED MODE")
                    echo ""
                    run_advanced_mode
                    break
                    ;;
                "❌ Çıkış")
                    echo -e "\n${GREEN}[BİLGİ]${NC} Kurulum scripti sonlandırılıyor..."
                    exit 0
                    ;;
                *)
                    continue
                    ;;
            esac
        else
            # Fallback: Traditional menu
            draw_box_top "🎯 1453.AI - MOD SEÇİMİ" 80
            draw_box_middle "" 80
            draw_box_middle "  ${YELLOW}Hangi kurulum modunu tercih edersiniz?${NC}" 80
            draw_box_middle "" 80
            draw_box_middle "  ${GREEN}1${NC}) ${CYAN}🚀 QUICK START MODE${NC} ${YELLOW}(Önerilen)${NC}" 80
            draw_box_middle "      → Vibe coder'lar ve yeni başlayanlar için" 80
            draw_box_middle "      → Basit sorular, otomatik kurulum" 80
            draw_box_middle "      → Sizi yormaz, sadece gerekli araçları kurar" 80
            draw_box_middle "" 80
            draw_box_middle "  ${GREEN}2${NC}) ${CYAN}⚙️  ADVANCED MODE${NC}" 80
            draw_box_middle "      → İleri düzey kullanıcılar için" 80
            draw_box_middle "      → Detaylı kontrol, her aracı ayrı seçin" 80
            draw_box_middle "      → 18 farklı kurulum seçeneği" 80
            draw_box_middle "" 80
            draw_box_middle "  ${GREEN}0${NC}) ${RED}❌ Çıkış${NC}" 80
            draw_box_middle "" 80
            draw_box_bottom 80
            echo ""

            # CRITICAL FIX: Flush stdin buffer before reading
            if [ -t 0 ]; then
                while read -r -t 0 <&0; do
                    read -r -t 0.01 -N 1000 <&0 || break
                done 2>/dev/null
            fi

            echo -ne "${YELLOW}Seçiminiz (0-2): ${NC}"

            # Read from /dev/tty if available, otherwise from stdin
            if [ -e /dev/tty ] && [ -c /dev/tty ]; then
                read -r mode_choice </dev/tty 2>/dev/null || read -r mode_choice
            else
                read -r mode_choice
            fi

            # Boş input kontrolü
            if [ -z "$mode_choice" ]; then
                echo -e "\n${RED}[HATA]${NC} Boş giriş! Lütfen 0, 1 veya 2 girin."
                sleep 2
                continue
            fi

            case $mode_choice in
                1)
                    echo ""
                    run_quickstart_mode
                    continue
                    ;;
                2)
                    echo ""
                    run_advanced_mode
                    break
                    ;;
                0)
                    echo -e "\n${GREEN}[BİLGİ]${NC} Kurulum scripti sonlandırılıyor..."
                    exit 0
                    ;;
                *)
                    echo -e "\n${RED}[HATA]${NC} Geçersiz seçim! Lütfen 0, 1 veya 2 girin."
                    sleep 2
                    continue
                    ;;
            esac
        fi
    done
}

# Advanced mode menu (current menu system)
show_advanced_menu() {
    clear
    show_banner
    show_menu
}

# Main program loop - Advanced Mode
# REFACTOR O-3: Broken down from 236 lines monolithic function
# Initialize advanced mode (Gum + preflight checks)
_advanced_mode_init() {
    # Install Gum first for modern TUI (optional, skip if fails)
    if ! has_gum; then
        echo -e "\n${CYAN}[!]${NC} Modern TUI kuruluyor (Gum - opsiyonel)..."
        install_gum 2>/dev/null || echo -e "${YELLOW}[!]${NC} Gum kurulumunu atlandı"
        sleep 1
    fi

    # Run pre-flight checks with TUI
    clear
    if has_gum; then
        gum_style --foreground 212 --border double --align center --width 60 --margin "1 2" --padding "1 4" \
            "🔍 ADVANCED MODE - SİSTEM KONTROLÜ"
        echo ""
    else
        draw_box_top "🔍 ADVANCED MODE - SİSTEM KONTROLÜ" 80
        draw_box_middle "" 80
    fi

    if ! run_preflight_checks; then
        if has_gum; then
            gum_style --foreground 196 --border rounded --align center --width 60 --padding "1 2" \
                "❌ Sistem gereksinimleri karşılanamadı!" \
                "Bazı kurulumlar başarısız olabilir."
        else
            draw_box_middle "" 80
            draw_box_middle "  ${RED}[✗]${NC} Sistem gereksinimleri karşılanamadı!" 80
            draw_box_middle "  ${CYAN}[ℹ]${NC} Bazı kurulumlar başarısız olabilir." 80
            draw_box_middle "" 80
            draw_box_bottom 80
        fi
        sleep 2
    else
        if has_gum; then
            gum_style --foreground 82 "✅ Sistem kontrolleri başarılı!"
        else
            draw_box_middle "  ${GREEN}[✓]${NC} Sistem kontrolleri başarılı!" 80
            draw_box_middle "" 80
            draw_box_bottom 80
        fi
        sleep 1
    fi

    # Detect package manager
    echo ""
    detect_package_manager
    if has_gum; then
        gum_style --foreground 82 "📦 Paket yöneticisi: $PKG_MANAGER"
    else
        echo -e "${GREEN}[✓]${NC} Paket yöneticisi: ${CYAN}${PKG_MANAGER}${NC}"
    fi
    sleep 1
}

# REFACTOR O-3: Main advanced mode loop (simplified)
run_advanced_mode() {
    # Initialize
    _advanced_mode_init

    # Track installed components
    local NVM_INSTALLED=false
    local PYTHON_INSTALLED=false

    while true; do
        clear
        show_banner
        echo ""

        if has_gum; then
            # Modern Gum menu (banner already shown)
            local selection
            selection=$(gum_choose \
                "✨ Tam Kurulum (Tüm Araçlar)" \
                "🔧 Hazırlık (Sistem + Git)" \
                "━━━ Python & JavaScript ━━━" \
                "  🐍 Python Ekosistemi (Python, pip, pipx, UV)" \
                "  📦 NVM (Node Version Manager)" \
                "  ⚡ Bun.js" \
                "━━━ Backend & Languages ━━━" \
                "  🐘 PHP Kurulum" \
                "  🎼 Composer" \
                "  🐹 Go Language" \
                "━━━ AI & Modern Tools ━━━" \
                "  🤖 AI CLI Araçları" \
                "  🧠 AI Frameworks" \
                "  ✨ Modern CLI Tools" \
                "  🎨 Shell Ortamı Yapılandırma" \
                "━━━ Docker & Utilities ━━━" \
                "  🐳 Docker (Engine + lazydocker)" \
                "━━━ Maintenance ━━━" \
                "  ❌ AI Frameworks Kaldır" \
                "  🗑️  Temizleme & Sıfırlama" \
                "━━━━━━━━━━━━━━━━━━━━━" \
                "◀ Ana Menüye Dön" \
                "🚪 Çıkış")

            case "$selection" in
                "✨ Tam Kurulum (Tüm Araçlar)")
                    echo ""
                    gum_style --foreground 226 "🚀 Tam kurulum başlatılıyor..."
                    sleep 1
                    update_system
                    configure_git
                    install_python && PYTHON_INSTALLED=true
                    install_pip
                    install_pipx
                    install_uv
                    install_nvm && NVM_INSTALLED=true
                    install_bun
                    install_composer
                    install_claude_code
                    install_github_cli
                    install_go
                    echo ""
                    gum_style --foreground 82 --border rounded --padding "1 3" "✅ Tam kurulum tamamlandı!"
                    sleep 2
                    ;;
                "🔧 Hazırlık (Sistem + Git)")
                    prepare_and_configure_git
                    ;;
                *"Python Ekosistemi"*)
                    install_python && PYTHON_INSTALLED=true
                    install_pip
                    install_pipx
                    install_uv
                    ;;
                *"NVM"*)
                    install_nvm && NVM_INSTALLED=true
                    ;;
                *"Bun.js"*)
                    install_bun
                    ;;
                *"PHP Kurulum"*)
                    install_php_version_menu
                    ;;
                *"Composer"*)
                    install_composer
                    ;;
                *"Go Language"*)
                    install_go_menu
                    ;;
                *"AI CLI Araçları"*)
                    install_ai_cli_tools_menu
                    ;;
                *"AI Frameworks"*)
                    install_ai_frameworks_menu
                    ;;
                *"Modern CLI Tools"*)
                    install_modern_cli_tools
                    ;;
                *"Shell Ortamı"*)
                    setup_custom_shell
                    ;;
                *"Docker"*)
                    install_docker_menu
                    ;;
                *"AI Frameworks Kaldır"*)
                    remove_ai_frameworks_menu
                    ;;
                *"Temizleme"*)
                    show_cleanup_menu
                    ;;
                *"Ana Menüye Dön"*)
                    show_mode_selection
                    ;;
                *"Çıkış"*)
                    echo ""
                    gum_style --foreground 82 "👋 Görüşürüz!"
                    exit 0
                    ;;
                "━"*)
                    # Separator selected, ignore
                    continue
                    ;;
            esac
        else
            # Fallback: Traditional menu
            show_menu
            echo -ne "\n${YELLOW}Seçiminizi yapın (0-18): ${NC}"
            read -r choice </dev/tty

            case $choice in
                1)
                    update_system
                    configure_git
                    install_python && PYTHON_INSTALLED=true
                    install_pip
                    install_pipx
                    install_uv
                    install_nvm && NVM_INSTALLED=true
                    install_bun
                    install_composer
                    install_claude_code
                    install_github_cli
                    install_go
                    ;;
                2) prepare_and_configure_git ;;
                3) install_python && PYTHON_INSTALLED=true ;;
                4) install_pip ;;
                5) install_pipx ;;
                6) install_uv ;;
                7) install_nvm && NVM_INSTALLED=true ;;
                8) install_bun ;;
                9) install_php_version_menu ;;
                10) install_composer ;;
                11) install_ai_cli_tools_menu ;;
                12) install_ai_frameworks_menu ;;
                13) remove_ai_frameworks_menu ;;
                14) install_go_menu ;;
                15) install_modern_cli_tools ;;
                16) setup_custom_shell ;;
                17) show_cleanup_menu ;;
                18) install_docker_menu ;;
                0) show_mode_selection ;;
                *) echo -e "${RED}[HATA]${NC} Geçersiz seçim!" ;;
            esac
        fi

        # Check if critical tools were installed
        if [ "$NVM_INSTALLED" = true ] || [ "$PYTHON_INSTALLED" = true ]; then
            echo ""
            if has_gum; then
                gum_style --foreground 226 --border rounded --padding "1 2" \
                    "⚠️  Yeni kurulumlar tespit edildi!" \
                    "Değişikliklerin aktif olması için:" \
                    "  • source ~/.bashrc (veya ~/.zshrc)" \
                    "  • Ya da terminali yeniden başlatın"
            else
                echo -e "${YELLOW}[ÖNEMLİ]${NC} Yeni kurulumlar tespit edildi."
                echo -e "${CYAN}[İPUCU]${NC} source ~/.bashrc veya terminali yeniden başlatın"
            fi
        fi

        echo ""
        if has_gum; then
            gum_confirm "Menüye dön?" || exit 0
        else
            echo -ne "${YELLOW}Devam için Enter...${NC}"
            read -r </dev/tty
        fi
    done
}

# Main program loop - entry point
main() {
    show_mode_selection
}

# Export functions for use in other modules
export -f configure_git
export -f prepare_and_configure_git
export -f show_menu
export -f show_mode_selection
export -f show_advanced_menu
export -f run_advanced_mode
export -f run_quickstart_mode
export -f main
