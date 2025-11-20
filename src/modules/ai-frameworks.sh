#!/bin/bash
# Module: AI Frameworks
# Description: AI framework installation and management (SuperGemini, SuperQwen, SuperClaude)
# Dependencies: lib/common.sh, modules/python.sh

# Install SuperGemini Framework
install_supergemini() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} SuperGemini Framework kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if ! command -v pipx &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Pipx kurulu değil. Önce pipx kuruluyor..."
        install_pipx
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Mevcut SuperGemini kurulumu kontrol ediliyor..."
    if pipx list 2>/dev/null | grep -q "supergemini"; then
        echo -e "${YELLOW}[BİLGİ]${NC} SuperGemini zaten kurulu, kaldırılıp yeniden kurulacak..."
        pipx uninstall supergemini --verbose 2>/dev/null || true
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} SuperGemini pipx ile kuruluyor..."
    pipx install supergemini

    reload_shell_configs

    if command -v supergemini &> /dev/null; then
        local version
        version=$(supergemini --version 2>/dev/null | head -n1 || echo "installed")
        track_success "SuperGemini Framework" "$version"
        echo -e "${GREEN}[BAŞARILI]${NC} SuperGemini kurulumu tamamlandı!"
        echo -e "\n${CYAN}[BİLGİ]${NC} SuperGemini Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Başlatma: ${GREEN}supergemini${NC}"
        echo -e "  ${GREEN}•${NC} Model seçimi: ${GREEN}supergemini --model gemini-pro${NC}"
        echo -e "  ${GREEN}•${NC} Yardım: ${GREEN}supergemini --help${NC}"
        return 0
    else
        track_failure "SuperGemini Framework" "Kurulum başarısız"
        echo -e "${RED}[HATA]${NC} SuperGemini kurulumu başarısız!"
        return 1
    fi
}

# Install SuperQwen Framework
install_superqwen() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} SuperQwen Framework kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if ! command -v pipx &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Pipx kurulu değil. Önce pipx kuruluyor..."
        install_pipx
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Mevcut SuperQwen kurulumu kontrol ediliyor..."
    if pipx list 2>/dev/null | grep -q "superqwen"; then
        echo -e "${YELLOW}[BİLGİ]${NC} SuperQwen zaten kurulu, kaldırılıp yeniden kurulacak..."
        pipx uninstall superqwen --verbose 2>/dev/null || true
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} SuperQwen pipx ile kuruluyor..."
    pipx install superqwen

    reload_shell_configs

    if command -v superqwen &> /dev/null; then
        local version
        version=$(superqwen --version 2>/dev/null | head -n1 || echo "installed")
        track_success "SuperQwen Framework" "$version"
        echo -e "${GREEN}[BAŞARILI]${NC} SuperQwen kurulumu tamamlandı!"
        echo -e "\n${CYAN}[BİLGİ]${NC} SuperQwen Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Başlatma: ${GREEN}superqwen${NC}"
        echo -e "  ${GREEN}•${NC} Model seçimi: ${GREEN}superqwen --model qwen-turbo${NC}"
        echo -e "  ${GREEN}•${NC} API key ayarlama: ${GREEN}export QWEN_API_KEY='your-api-key'${NC}"
        return 0
    else
        track_failure "SuperQwen Framework" "Kurulum başarısız"
        echo -e "${RED}[HATA]${NC} SuperQwen kurulumu başarısız!"
        return 1
    fi
}

# Install SuperClaude Framework
install_superclaude() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} SuperClaude Framework kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if ! command -v pipx &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Pipx kurulu değil. Önce pipx kuruluyor..."
        install_pipx
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Mevcut SuperClaude kurulumu kontrol ediliyor..."
    if pipx list 2>/dev/null | grep -q "superclaude"; then
        echo -e "${YELLOW}[BİLGİ]${NC} SuperClaude zaten kurulu, kaldırılıp yeniden kurulacak..."
        pipx uninstall superclaude --verbose 2>/dev/null || true
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} SuperClaude pipx ile kuruluyor..."
    pipx install superclaude

    reload_shell_configs

    if command -v superclaude &> /dev/null; then
        local version
        version=$(superclaude --version 2>/dev/null | head -n1 || echo "installed")
        track_success "SuperClaude Framework" "$version"
        echo -e "${GREEN}[BAŞARILI]${NC} SuperClaude kurulumu tamamlandı!"
        echo -e "\n${CYAN}[BİLGİ]${NC} SuperClaude Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Başlatma: ${GREEN}superclaude${NC}"
        echo -e "  ${GREEN}•${NC} Model seçimi: ${GREEN}superclaude --model claude-3${NC}"
        echo -e "  ${GREEN}•${NC} API key ayarlama: ${GREEN}export ANTHROPIC_API_KEY='your-api-key'${NC}"
        return 0
    else
        track_failure "SuperClaude Framework" "Kurulum başarısız"
        echo -e "${RED}[HATA]${NC} SuperClaude kurulumu başarısız!"
        return 1
    fi
}

# Remove SuperGemini Framework
remove_supergemini() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} SuperGemini Framework kaldırılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if pipx list 2>/dev/null | grep -q "supergemini"; then
        pipx uninstall supergemini
        echo -e "${GREEN}[BAŞARILI]${NC} SuperGemini başarıyla kaldırıldı!"
    else
        echo -e "${YELLOW}[UYARI]${NC} SuperGemini kurulu değil."
    fi
}

# Remove SuperQwen Framework
remove_superqwen() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} SuperQwen Framework kaldırılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if pipx list 2>/dev/null | grep -q "superqwen"; then
        pipx uninstall superqwen
        echo -e "${GREEN}[BAŞARILI]${NC} SuperQwen başarıyla kaldırıldı!"
    else
        echo -e "${YELLOW}[UYARI]${NC} SuperQwen kurulu değil."
    fi
}

# Remove SuperClaude Framework
remove_superclaude() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} SuperClaude Framework kaldırılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if pipx list 2>/dev/null | grep -q "superclaude"; then
        pipx uninstall superclaude
        echo -e "${GREEN}[BAŞARILI]${NC} SuperClaude başarıyla kaldırıldı!"
    else
        echo -e "${YELLOW}[UYARI]${NC} SuperClaude kurulu değil."
    fi
}

# AI Frameworks installation menu
install_ai_frameworks_menu() {
    if has_gum; then
        # Modern Gum menu
        echo ""
        gum_style --foreground 212 --border double --align center --width 60 --padding "1 3" \
            "🧠 AI Framework'leri Kurulumu"
        echo ""

        local selection
        selection=$(gum_choose \
            "✨ SuperGemini (Gemini Framework)" \
            "🌟 SuperQwen (Qwen Framework)" \
            "🧠 SuperClaude (Claude Framework)" \
            "━━━━━━━━━━━━━━━━━━━━━" \
            "📦 Tümünü Kur" \
            "◀ Ana menüye dön")

        case "$selection" in
            *"SuperGemini"*) install_supergemini ;;
            *"SuperQwen"*) install_superqwen ;;
            *"SuperClaude"*) install_superclaude ;;
            *"Tümünü Kur"*)
                install_supergemini
                install_superqwen
                install_superclaude
                ;;
            *"Ana menüye dön"*|"") return ;;
            "━"*) return ;; # Separator
        esac
    else
        # Fallback: Traditional menu
        echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║       AI Framework'leri Kurulumu              ║${NC}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
        echo -e "  ${CYAN}1${NC}) SuperGemini (Gemini Framework)"
        echo -e "  ${CYAN}2${NC}) SuperQwen (Qwen Framework)"
        echo -e "  ${CYAN}3${NC}) SuperClaude (Claude Framework)"
        echo -e "  ${CYAN}4${NC}) Tümünü Kur"
        echo -e "  ${CYAN}5${NC}) Ana menüye dön"

        echo -ne "\n${YELLOW}Seçiminizi yapın (1-5): ${NC}"
        read -r choice </dev/tty

        case $choice in
            1) install_supergemini ;;
            2) install_superqwen ;;
            3) install_superclaude ;;
            4)
                install_supergemini
                install_superqwen
                install_superclaude
                ;;
            5) return ;;
            *) echo -e "${RED}[HATA]${NC} Geçersiz seçim!" ;;
        esac
    fi
}

# AI Frameworks removal menu
remove_ai_frameworks_menu() {
    if has_gum; then
        # Modern Gum menu
        echo ""
        gum_style --foreground 196 --border double --align center --width 60 --padding "1 3" \
            "❌ AI Framework'leri Kaldırma"
        echo ""

        local selection
        selection=$(gum_choose \
            "🗑️  SuperGemini'yi Kaldır" \
            "🗑️  SuperQwen'i Kaldır" \
            "🗑️  SuperClaude'u Kaldır" \
            "━━━━━━━━━━━━━━━━━━━━━" \
            "🚮 Tümünü Kaldır" \
            "◀ Ana menüye dön")

        case "$selection" in
            *"SuperGemini"*) remove_supergemini ;;
            *"SuperQwen"*) remove_superqwen ;;
            *"SuperClaude"*) remove_superclaude ;;
            *"Tümünü Kaldır"*)
                remove_supergemini
                remove_superqwen
                remove_superclaude
                ;;
            *"Ana menüye dön"*|"") return ;;
            "━"*) return ;; # Separator
        esac
    else
        # Fallback: Traditional menu
        echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║       AI Framework'leri Kaldırma              ║${NC}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
        echo -e "  ${CYAN}1${NC}) SuperGemini'yi Kaldır"
        echo -e "  ${CYAN}2${NC}) SuperQwen'i Kaldır"
        echo -e "  ${CYAN}3${NC}) SuperClaude'u Kaldır"
        echo -e "  ${CYAN}4${NC}) Tümünü Kaldır"
        echo -e "  ${CYAN}5${NC}) Ana menüye dön"

        echo -ne "\n${YELLOW}Seçiminizi yapın (1-5): ${NC}"
        read -r choice </dev/tty

        case $choice in
            1) remove_supergemini ;;
            2) remove_superqwen ;;
            3) remove_superclaude ;;
            4)
                remove_supergemini
                remove_superqwen
                remove_superclaude
                ;;
            5) return ;;
            *) echo -e "${RED}[HATA]${NC} Geçersiz seçim!" ;;
        esac
    fi
}

# Export functions for use in other modules
export -f install_supergemini
export -f install_superqwen
export -f install_superclaude
export -f remove_supergemini
export -f remove_superqwen
export -f remove_superclaude
export -f install_ai_frameworks_menu
export -f remove_ai_frameworks_menu