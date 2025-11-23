#!/bin/bash
# Module: AI Frameworks
# Description: AI framework installation and management (SuperGemini, SuperQwen, SuperClaude)
# Dependencies: lib/common.sh, modules/python.sh

# Install SuperGemini Framework
install_supergemini() {
    echo ""
    gum_header "SUPERGEMINI FRAMEWORK" "Google Gemini CLI Aracı"

    if ! command -v pipx &> /dev/null; then
        gum_alert "Gereksinim" "Pipx kurulu değil. Önce pipx kurun."
        install_pipx
    fi

    # Check if already installed
    if pipx list 2>/dev/null | grep -q "supergemini"; then
        gum_info "Güncelleme" "SuperGemini zaten kurulu, yeniden kurulacak"
        if gum_spin_run "Eski sürüm kaldırılıyor..." "pipx uninstall supergemini 2>/dev/null || true"; then
            gum_success "Temizlendi" "Eski sürüm kaldırıldı"
        fi
    fi

    if gum_spin_run "SuperGemini kuruluyor..." "pipx install supergemini"; then
        reload_shell_configs
        
        if command -v supergemini &> /dev/null; then
            local version
            version=$(supergemini --version 2>/dev/null | head -n1 || echo "installed")
            track_success "SuperGemini Framework" "$version"
            gum_success "Başarılı" "SuperGemini kuruldu: $version"
            gum_info "İpucu" "Başlatmak için: supergemini"
            return 0
        else
            track_failure "SuperGemini Framework" "Kurulum başarısız"
            gum_alert "Hata" "SuperGemini kurulumu başarısız!"
            return 1
        fi
    else
        track_failure "SuperGemini Framework" "Pipx kurulumu başarısız"
        gum_alert "Hata" "Pipx ile kurulum başarısız!"
        return 1
    fi
}

# Install SuperQwen Framework
install_superqwen() {
    echo ""
    gum_header "SUPERQWEN FRAMEWORK" "Alibaba Qwen CLI Aracı"

    if ! command -v pipx &> /dev/null; then
        gum_alert "Gereksinim" "Pipx kurulu değil. Önce pipx kurun."
        install_pipx
    fi

    # Check if already installed
    if pipx list 2>/dev/null | grep -q "superqwen"; then
        gum_info "Güncelleme" "SuperQwen zaten kurulu, yeniden kurulacak"
        if gum_spin_run "Eski sürüm kaldırılıyor..." "pipx uninstall superqwen 2>/dev/null || true"; then
            gum_success "Temizlendi" "Eski sürüm kaldırıldı"
        fi
    fi

    if gum_spin_run "SuperQwen kuruluyor..." "pipx install superqwen"; then
        reload_shell_configs
        
        if command -v superqwen &> /dev/null; then
            local version
            version=$(superqwen --version 2>/dev/null | head -n1 || echo "installed")
            track_success "SuperQwen Framework" "$version"
            gum_success "Başarılı" "SuperQwen kuruldu: $version"
            gum_info "İpucu" "API key: export QWEN_API_KEY='your-key'"
            return 0
        else
            track_failure "SuperQwen Framework" "Kurulum başarısız"
            gum_alert "Hata" "SuperQwen kurulumu başarısız!"
            return 1
        fi
    else
        track_failure "SuperQwen Framework" "Pipx kurulumu başarısız"
        gum_alert "Hata" "Pipx ile kurulum başarısız!"
        return 1
    fi
}

# Install SuperClaude Framework
install_superclaude() {
    echo ""
    gum_header "SUPERCLAUDE FRAMEWORK" "Anthropic Claude CLI Aracı"

    if ! command -v pipx &> /dev/null; then
        gum_alert "Gereksinim" "Pipx kurulu değil. Önce pipx kurun."
        install_pipx
    fi

    # Check if already installed
    if pipx list 2>/dev/null | grep -q "superclaude"; then
        gum_info "Güncelleme" "SuperClaude zaten kurulu, yeniden kurulacak"
        if gum_spin_run "Eski sürüm kaldırılıyor..." "pipx uninstall superclaude 2>/dev/null || true"; then
            gum_success "Temizlendi" "Eski sürüm kaldırıldı"
        fi
    fi

    if gum_spin_run "SuperClaude kuruluyor..." "pipx install superclaude"; then
        reload_shell_configs
        
        if command -v superclaude &> /dev/null; then
            local version
            version=$(superclaude --version 2>/dev/null | head -n1 || echo "installed")
            track_success "SuperClaude Framework" "$version"
            gum_success "Başarılı" "SuperClaude kuruldu: $version"
            gum_info "İpucu" "API key: export ANTHROPIC_API_KEY='your-key'"
            return 0
        else
            track_failure "SuperClaude Framework" "Kurulum başarısız"
            gum_alert "Hata" "SuperClaude kurulumu başarısız!"
            return 1
        fi
    else
        track_failure "SuperClaude Framework" "Pipx kurulumu başarısız"
        gum_alert "Hata" "Pipx ile kurulum başarısız!"
        return 1
    fi
}

# Remove SuperGemini Framework
remove_supergemini() {
    echo ""
    gum_header "KALDIR" "SuperGemini Kaldırılıyor"

    if pipx list 2>/dev/null | grep -q "supergemini"; then
        if gum_spin_run "SuperGemini kaldırılıyor..." "pipx uninstall supergemini"; then
            gum_success "Başarılı" "SuperGemini kaldırıldı"
        else
            gum_alert "Hata" "Kaldırma başarısız"
        fi
    else
        gum_info "Bilgi" "SuperGemini kurulu değil"
    fi
}

# Remove SuperQwen Framework
remove_superqwen() {
    echo ""
    gum_header "KALDIR" "SuperQwen Kaldırılıyor"

    if pipx list 2>/dev/null | grep -q "superqwen"; then
        if gum_spin_run "SuperQwen kaldırılıyor..." "pipx uninstall superqwen"; then
            gum_success "Başarılı" "SuperQwen kaldırıldı"
        else
            gum_alert "Hata" "Kaldırma başarısız"
        fi
    else
        gum_info "Bilgi" "SuperQwen kurulu değil"
    fi
}

# Remove SuperClaude Framework
remove_superclaude() {
    echo ""
    gum_header "KALDIR" "SuperClaude Kaldırılıyor"

    if pipx list 2>/dev/null | grep -q "superclaude"; then
        if gum_spin_run "SuperClaude kaldırılıyor..." "pipx uninstall superclaude"; then
            gum_success "Başarılı" "SuperClaude kaldırıldı"
        else
            gum_alert "Hata" "Kaldırma başarısız"
        fi
    else
        gum_info "Bilgi" "SuperClaude kurulu değil"
    fi
}

# AI Frameworks installation menu
install_ai_frameworks_menu() {
    echo ""
    gum_header "AI FRAMEWORKS" "AI CLI Araçları Kurulumu"

    local selection
    selection=$(gum_choose_enhanced \
        "🤖 SuperGemini (Gemini Framework)" \
        "🌟 SuperQwen (Qwen Framework)" \
        "🧠 SuperClaude (Claude Framework)" \
        "📦 Tümünü Kur" \
        "🔙 Ana menüye dön")

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
    esac
}

# AI Frameworks removal menu
remove_ai_frameworks_menu() {
    echo ""
    gum_header "KALDIR" "AI Framework Kaldırma"

    local selection
    selection=$(gum_choose_enhanced \
        "🗑️  SuperGemini'yi Kaldır" \
        "🗑️  SuperQwen'i Kaldır" \
        "🗑️  SuperClaude'u Kaldır" \
        "�️ Tümünü Kaldır" \
        "🔙 Ana menüye dön")

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
    esac
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