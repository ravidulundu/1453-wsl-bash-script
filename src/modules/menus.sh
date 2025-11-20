#!/bin/bash
# Module: Interactive Menus
# Description: Main menu system and user interaction
# Dependencies: All other modules

# Configure Git
configure_git() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Git yapılandırması başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

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
        echo -ne "${YELLOW}Yeni yapılandırma yapmak istiyor musunuz? (e/E=Evet, Enter=Hayır): ${NC}"
        read -r reconfigure </dev/tty

        if [[ ! "$reconfigure" =~ ^[eE]$ ]]; then
            echo -e "${CYAN}[!]${NC} Git yapılandırması değiştirilmedi"
            track_skip "Git Yapılandırması" "Mevcut yapılandırma korundu"
            return 0
        fi
    fi

    echo -ne "${YELLOW}Git kullanıcı adınızı girin: ${NC}"
    read -r git_user </dev/tty

    echo -ne "${YELLOW}Git e-posta adresinizi girin: ${NC}"
    read -r git_email </dev/tty

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
    draw_box_top "ADVANCED MODE - ANA MENÜ" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}Python & JavaScript:${NC}" 70
    draw_box_middle "    ${GREEN}3${NC}) Python  ${GREEN}4${NC}) Pip  ${GREEN}5${NC}) Pipx  ${GREEN}6${NC}) UV" 70
    draw_box_middle "    ${GREEN}7${NC}) NVM  ${GREEN}8${NC}) Bun.js" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}Backend & Languages:${NC}" 70
    draw_box_middle "    ${GREEN}9${NC}) PHP  ${GREEN}10${NC}) Composer  ${GREEN}14${NC}) Go" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}AI & Modern Tools:${NC}" 70
    draw_box_middle "    ${GREEN}11${NC}) AI CLI Araçları  ${GREEN}12${NC}) AI Frameworks" 70
    draw_box_middle "    ${GREEN}15${NC}) Modern CLI Tools  ${GREEN}16${NC}) Shell Ortamı" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}Docker & Utilities:${NC}" 70
    draw_box_middle "    ${GREEN}18${NC}) Docker (Engine + lazydocker)" 70
    draw_box_middle "" 70
    draw_box_middle "  ${CYAN}Quick Actions:${NC}" 70
    draw_box_middle "    ${GREEN}1${NC}) Tam Kurulum (Önerilen)" 70
    draw_box_middle "    ${GREEN}2${NC}) Hazırlık (Sistem + Git)" 70
    draw_box_middle "    ${RED}13${NC}) AI Frameworks Kaldır" 70
    draw_box_middle "    ${RED}17${NC}) Temizleme & Sıfırlama" 70
    draw_box_middle "" 70
    draw_box_middle "  ${GREEN}0${NC}) Ana Menüye Dön" 70
    draw_box_middle "" 70
    draw_box_bottom 70
}

# Show mode selection menu
show_mode_selection() {
    while true; do
        clear
        show_banner
        echo ""

        # TUI Mode Selection
        draw_box_top "1453.AI - MOD SEÇİMİ" 70
        draw_box_middle "" 70
        draw_box_middle "  ${YELLOW}Hangi kurulum modunu tercih edersiniz?${NC}" 70
        draw_box_middle "" 70
        draw_box_middle "  ${GREEN}1${NC}) ${CYAN}QUICK START MODE${NC} ${YELLOW}(Önerilen)${NC}" 70
        draw_box_middle "      → Vibe coder'lar ve yeni başlayanlar için" 70
        draw_box_middle "      → Basit sorular, otomatik kurulum" 70
        draw_box_middle "      → Sizi yormaz, sadece gerekli araçları kurar" 70
        draw_box_middle "" 70
        draw_box_middle "  ${GREEN}2${NC}) ${CYAN}ADVANCED MODE${NC}" 70
        draw_box_middle "      → İleri düzey kullanıcılar için" 70
        draw_box_middle "      → Detaylı kontrol, her aracı ayrı seçin" 70
        draw_box_middle "      → 18 farklı kurulum seçeneği" 70
        draw_box_middle "" 70
        draw_box_middle "  ${GREEN}0${NC}) ${RED}Çıkış${NC}" 70
        draw_box_middle "" 70
        draw_box_bottom 70
        echo ""

        # CRITICAL FIX: Flush stdin buffer before reading
        while read -r -t 0; do read -r -t 0.01 -N 1000; done 2>/dev/null

        echo -ne "${YELLOW}Seçiminiz (0-2): ${NC}"
        read -r mode_choice </dev/tty

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
                # Quick start bittikten sonra tekrar menüye dön
                continue
                ;;
            2)
                echo ""
                run_advanced_mode
                # Advanced mode bittikten sonra çık
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
    done
}

# Advanced mode menu (current menu system)
show_advanced_menu() {
    clear
    show_banner
    show_menu
}

# Main program loop - Advanced Mode
run_advanced_mode() {
    # Run pre-flight checks with TUI
    clear
    draw_box_top "ADVANCED MODE - SİSTEM KONTROLÜ" 70
    draw_box_middle "" 70

    if ! run_preflight_checks; then
        draw_box_middle "" 70
        draw_box_middle "  ${RED}[✗]${NC} Sistem gereksinimleri karşılanamadı!" 70
        draw_box_middle "  ${YELLOW}[!]${NC} Menüye yönlendiriliyorsunuz..." 70
        draw_box_middle "  ${CYAN}[ℹ]${NC} Bazı kurulumlar başarısız olabilir." 70
        draw_box_middle "" 70
        draw_box_bottom 70
        sleep 3
    else
        draw_box_middle "  ${GREEN}[✓]${NC} Sistem kontrolleri başarılı!" 70
        draw_box_middle "" 70
        draw_box_bottom 70
        sleep 1
    fi

    # Detect package manager on startup with TUI
    clear
    draw_box_top "PAKET YÖNETİCİSİ TESPİT EDİLİYOR" 70
    draw_box_middle "" 70
    detect_package_manager
    draw_box_middle "" 70
    draw_box_middle "  ${GREEN}[✓]${NC} Paket yöneticisi: ${CYAN}${PKG_MANAGER}${NC}" 70
    draw_box_middle "" 70
    draw_box_bottom 70
    sleep 1

    # Track installed components
    local NVM_INSTALLED=false
    local PYTHON_INSTALLED=false

    while true; do
        show_advanced_menu
        echo -ne "\n${YELLOW}Seçiminizi yapın (virgülle ayırarak birden fazla seçebilirsiniz): ${NC}"
        read -r choices </dev/tty

        # Convert choices to array
        IFS=',' read -ra choice_array <<< "$choices"

        for choice in "${choice_array[@]}"; do
            # Trim whitespace
            choice=$(echo "$choice" | xargs)

            case $choice in
                1)
                    clear
                    draw_box_top "TAM KURULUM BAŞLATILIYOR" 70
                    draw_box_middle "" 70
                    draw_box_middle "  ${YELLOW}Tüm temel araçlar kurulacak...${NC}" 70
                    draw_box_middle "" 70
                    draw_box_bottom 70
                    sleep 2

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

                    clear
                    draw_box_top "TAM KURULUM TAMAMLANDI" 70
                    draw_box_middle "" 70
                    draw_box_middle "  ${GREEN}[✓]${NC} Tüm araçlar başarıyla kuruldu!" 70
                    draw_box_middle "" 70
                    draw_box_bottom 70
                    sleep 2
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
                0)
                    echo -e "\n${GREEN}[BİLGİ]${NC} Ana menüye dönülüyor..."
                    sleep 1
                    show_mode_selection
                    ;;
                *)
                    echo -e "${RED}[HATA]${NC} Geçersiz seçim: $choice"
                    ;;
            esac
        done

        # Check if critical tools were installed
        if [ "$NVM_INSTALLED" = true ] || [ "$PYTHON_INSTALLED" = true ]; then
            echo -e "\n${YELLOW}[ÖNEMLİ]${NC} Yeni kurulumlar tespit edildi."
            echo -e "${CYAN}[İPUCU]${NC} Değişikliklerin aktif olması için:"
            echo -e "  1) ${GREEN}source ~/.bashrc${NC} veya ${GREEN}source ~/.zshrc${NC} komutunu çalıştırın"
            echo -e "  2) Ya da terminali yeniden başlatın"
        fi

        echo -e "\n${YELLOW}Devam etmek için Enter'a basın...${NC}"
        read -r </dev/tty
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
