#!/bin/bash
# Module: Interactive Menus
# Description: Main menu system and user interaction
# Dependencies: All other modules

# Configure Git
configure_git() {
    echo ""
    gum_info "Bilgi" "Git yapılandırması başlatılıyor..."

    # Check existing git configuration
    local current_user
    local current_email
    current_user=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [ -n "$current_user" ] && [ -n "$current_email" ]; then
        gum_info "Bilgi" "Mevcut Git yapılandırması:"
    gum_style --foreground "$COLOR_TEXT_FG" "Kullanıcı: $current_user"
    gum_style --foreground "$COLOR_TEXT_FG" "E-posta: $current_email"
        echo ""

        # Use Gum confirm if available
        if ! gum_confirm "Yeni yapılandırma yapmak istiyor musunuz?"; then
            gum_info "Bilgi" "Git yapılandırması değiştirilmedi"
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
        gum_alert "Hata" "Kullanıcı adı ve e-posta gereklidir!"
        track_failure "Git Yapılandırması" "Eksik bilgi"
        return 1
    fi

    git config --global user.name "$git_user"
    git config --global user.email "$git_email"

    gum_success "Başarılı" "Git yapılandırması tamamlandı!"
    gum_style --foreground "$COLOR_TEXT_FG" "Kullanıcı: $git_user"
    gum_style --foreground "$COLOR_TEXT_FG" "E-posta: $git_email"
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
    draw_box_top "[SETUP]  ADVANCED MODE - ANA MENÜ" 80
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
    draw_box_middle "    ${GREEN}1${NC})  Tam Kurulum (Önerilen)" 80
    draw_box_middle "    ${GREEN}2${NC}) 🔧 Hazırlık (Sistem + Git)" 80
    draw_box_middle "    ${RED}13${NC}) ❌ AI Frameworks Kaldır" 80
    draw_box_middle "    ${RED}17${NC}) [DELETE]  Temizleme & Sıfırlama" 80
    draw_box_middle "" 80
    draw_box_middle "  ${GREEN}0${NC}) < Ana Menüye Dön" 80
    draw_box_middle "" 80
    draw_box_bottom 80
}

# Show mode selection menu
show_mode_selection() {
    while true; do
        # Banner shown at script start, don't redraw
        echo ""

        # Show mode selection question
        gum_header "KURULUM MODU SEÇİMİ" "Nasıl devam etmek istersiniz?"

        local selection
        selection=$(gum_choose_enhanced "Bir mod seçin:" \
            "$ICON_ROCKET Hızlı Başlangıç (Önerilen)" \
            "$ICON_GEAR Gelişmiş Mod" \
            "$ICON_EXIT Çıkış")

        case "$selection" in
            *"Hızlı Başlangıç"*)
                echo ""
                run_quickstart_mode
                continue
                ;;
            *"Gelişmiş Mod"*)
                echo ""
                run_advanced_mode
                break
                ;;
            *"Çıkış"*)
    gum_style --foreground "$COLOR_TEXT_FG" "\n[BİLGİ] Kurulum scripti sonlandırılıyor..."
                exit 0
                ;;
            *)
                continue
                ;;
        esac
    done
}

# Advanced mode menu (current menu system)
show_advanced_menu() {
    # Banner shown at script start, don't redraw
    show_menu
}

# Main program loop - Advanced Mode
# REFACTOR O-3: Broken down from 236 lines monolithic function
# Initialize advanced mode (Gum + preflight checks)
_advanced_mode_init() {
    # Install Gum first for modern TUI (optional, skip if fails)
    if ! has_gum; then
        echo ""
        echo "  Modern TUI kuruluyor (Gum - opsiyonel)..."
        if install_gum 2>/dev/null; then
            gum_info "Başarılı" "Modern TUI kuruldu!"
        else
            echo "  Gum kurulumu atlandı (klasik UI kullanılacak)"
        fi
        sleep 1
    fi

    # Run pre-flight checks with TUI
    echo ""
    gum_header "SİSTEM KONTROLÜ" "Advanced Mode Başlatılıyor"

    if ! run_preflight_checks; then
        gum_alert "Hata" "Sistem gereksinimleri karşılanamadı! Bazı kurulumlar başarısız olabilir."
        sleep 2
    else
        gum_success "Başarılı" "Sistem kontrolleri tamamlandı."
        sleep 1
    fi

    # Detect package manager
    echo ""
    detect_package_manager
    gum_info "Paket Yöneticisi" "$PKG_MANAGER tespit edildi."
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
        # Banner shown at script start, don't redraw
        echo ""

        # Menu header
        gum_header "GELİŞMİŞ KURULUM MENÜSÜ" "Yapmak istediğiniz işlemi seçin"

        # Modern Gum menu
        local selection
        selection=$(gum_choose_enhanced "Kategoriler:" \
            "$ICON_PACKAGE Tam Kurulum (Tüm Araçlar)" \
            "$ICON_TARGET Çoklu Bileşen Seçimi (Multi-Select)" \
            "$ICON_TOOLS Sistem Hazırlığı (Update + Git)" \
            "━━━ Python & JavaScript ━━━" \
            "$ICON_PYTHON Python Ekosistemi (pip, pipx, uv)" \
            "$ICON_NODE Node.js (NVM)" \
            "$ICON_BUN Bun.js Runtime" \
            "━━━ Backend & Languages ━━━" \
            "$ICON_PHP PHP Kurulumu" \
            "$ICON_COMPOSER Composer" \
            "$ICON_GO Go Dili" \
            "━━━ AI & Modern Tools ━━━" \
            "$ICON_AI AI CLI Araçları" \
            "$ICON_BRAIN AI Frameworks" \
            "$ICON_ROCKET Modern CLI Araçları" \
            "$ICON_SHELL Shell Yapılandırması" \
            "━━━ Docker & Utilities ━━━" \
            "$ICON_DOCKER Docker Ortamı" \
            "━━━ PRD Özel Özellikler ━━━" \
            "$ICON_SEARCH Dotfiles Yöneticisi (Fuzzy Search)" \
            "$ICON_WEB Windows Font Kontrolü (WSL)" \
            "━━━ Bakım & Onarım ━━━" \
            "$ICON_TRASH AI Frameworks Kaldır" \
            "$ICON_WARNING Temizleme ve Sıfırlama" \
            "━━━━━━━━━━━━━━━━━━━━━" \
            "$ICON_BACK Ana Menüye Dön" \
            "$ICON_EXIT Çıkış")

        case "$selection" in
            *"Tam Kurulum"*)
                echo ""
                gum_info "Bilgi" "Tam kurulum başlatılıyor..."
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

                # PRD FR-4.1: Markdown report at end of installation
                show_installation_summary

                echo ""
                gum_success "Tamamlandı" "Tam kurulum başarıyla tamamlandı!"
                sleep 2
                ;;
            *"Çoklu Bileşen"*)
                # PRD FR-2.1: Multi-select installation
                echo ""
                gum_style --foreground "$COLOR_GOLD_FG" "   ⏎ Space ile seçim yapın, Enter ile onaylayın"
                echo ""

                local components
                components=$(gum_multiselect "Kurulacak bileşenleri seçin:" \
                    "$ICON_TOOLS Sistem Güncellemesi" \
                    "$ICON_TOOLS Git Yapılandırması" \
                    "$ICON_PYTHON Python Ekosistemi (Python + pip + pipx + uv)" \
                    "$ICON_NODE Node.js (NVM)" \
                    "$ICON_BUN Bun.js Runtime" \
                    "$ICON_PHP PHP + Composer" \
                    "$ICON_GO Go Dili" \
                    "$ICON_AI AI CLI Araçları" \
                    "$ICON_BRAIN AI Frameworks" \
                    "$ICON_ROCKET Modern CLI Araçları" \
                    "$ICON_SHELL Shell Yapılandırması" \
                    "$ICON_DOCKER Docker Ortamı")

                if [ -z "$components" ]; then
                    gum_alert "Uyarı" "Hiçbir bileşen seçilmedi!"
                    continue
                fi

                echo ""
                gum_info "Bilgi" "Seçilen bileşenler kuruluyor..."
                sleep 1

                # Process selections
                while IFS= read -r component; do
                    case "$component" in
                        *"Sistem Güncellemesi"*) update_system ;;
                        *"Git Yapılandırması"*) configure_git ;;
                        *"Python Ekosistemi"*)
                            install_python && PYTHON_INSTALLED=true
                            install_pip
                            install_pipx
                            install_uv
                            ;;
                        *"Node.js"*) install_nvm && NVM_INSTALLED=true ;;
                        *"Bun.js"*) install_bun ;;
                        *"PHP"*) install_php_version_menu; install_composer ;;
                        *"Go Dili"*) install_go_menu ;;
                        *"AI CLI"*) install_ai_cli_tools_menu ;;
                        *"AI Frameworks"*) install_ai_frameworks_menu ;;
                        *"Modern CLI"*) install_modern_cli_tools ;;
                        *"Shell"*) setup_custom_shell ;;
                        *"Docker"*) install_docker_menu ;;
                    esac
                done <<< "$components"

                echo ""

                # PRD FR-4.1: Markdown report at end of installation
                show_installation_summary

                echo ""
                gum_success "Tamamlandı" "Seçilen tüm bileşenler kuruldu!"
                sleep 2
                ;;
            *"Sistem Hazırlığı"*)
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
            *"PHP Kurulumu"*)
                install_php_version_menu
                ;;
            *"Composer"*)
                install_composer
                ;;
            *"Go Dili"*)
                install_go_menu
                ;;
            *"AI CLI Araçları"*)
                install_ai_cli_tools_menu
                ;;
            *"AI Frameworks"*)
                install_ai_frameworks_menu
                ;;
            *"Modern CLI Araçları"*)
                install_modern_cli_tools
                ;;
            *"Shell Yapılandırması"*)
                setup_custom_shell
                ;;
            *"Docker"*)
                install_docker_menu
                ;;
            *"Dotfiles Yöneticisi"*)
                manage_dotfiles_menu
                ;;
            *"Windows Font Kontrolü"*)
                manage_windows_fonts
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
                gum_success "Hoşçakalın" "Görüşmek üzere!"
                exit 0
                ;;
            "━"*)
                # Separator selected, ignore
                continue
                ;;
        esac

        # Check if critical tools were installed
        if [ "$NVM_INSTALLED" = true ] || [ "$PYTHON_INSTALLED" = true ]; then
            gum_alert "Dikkat" "Yeni kurulumlar tespit edildi! Değişikliklerin aktif olması için terminali yeniden başlatın."
        fi

        echo ""
        gum_confirm_enhanced "Menüye dönmek istiyor musunuz?" || exit 0
    done
}

# Main program loop - entry point
main() {
    # Show banner ONCE at script start (BANNER_SHOWN flag prevents redraw)
    show_banner

    # Enter main menu (no banner redraw in loops)
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
