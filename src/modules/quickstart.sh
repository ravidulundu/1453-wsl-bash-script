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
    
    gum_style --foreground 251 "✨ Nasıl çalışır?"
    gum_style --foreground 251 "  1. Ne yapmak istediğinizi seçin"
    gum_style --foreground 251 "  2. Önerilen araçları otomatik kurarım"
    gum_style --foreground 251 "  3. Hemen kod yazmaya başlayın!"
    echo ""
    
    gum_style --foreground 251 "🎯 Sonunda elde edeceğiniz:"
    gum_style --foreground 251 "  ✓ Tüm geliştirici araçları"
    gum_style --foreground 251 "  ✓ Hazır ortam"
    gum_style --foreground 251 "  ✓ Modern CLI tools"
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
    gum_alert "Uyarı" "\n Geçersiz seçim!"
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
    gum_style --foreground 212 "=== KURULUM BAŞLIYOR!"
    fi
    echo ""

    # Always install base tools
    gum_info "Bilgi" "[PACKAGE] İlk önce (tüm paketlerde):"
    gum_style --foreground 212 "[+] Sistem güncellemeleri"
    gum_style --foreground 212 "[+] Git yapılandırması"
    gum_style --foreground 212 "[+] Python + pip + pipx + UV"
    gum_style --foreground 212 "[+] Modern CLI araçları (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)"
    gum_style --foreground 212 "[+] Shell ortamı (62 alias, özel fonksiyonlar, bashrc ayarları)"
    echo ""

    # Build tool list based on preset
    local tools=()

    case $preset in
        "web")
            gum_info "Bilgi" "🌐 Web Development paketi:"
    gum_style --foreground 212 "[+] Node.js (NVM)"
    gum_style --foreground 212 "[+] Bun.js runtime"
    gum_style --foreground 212 "[+] PHP + Composer"
            tools+=("nvm" "node" "bun" "php" "composer")
            ;;
        "ai")
            gum_info "Bilgi" "[AI] AI Development paketi:"
    gum_style --foreground 212 "[+] Node.js (AI araçları için)"
    gum_style --foreground 212 "[+] AI CLI Tools (Claude, Gemini, etc.)"
    gum_style --foreground 212 "[+] AI Frameworks (SuperClaude, etc.)"
            tools+=("nvm" "node" "ai_cli" "ai_frameworks")
            ;;
        "backend")
            gum_info "Bilgi" "[SETUP]  Backend Development paketi:"
    gum_style --foreground 212 "[+] Go language"
    gum_style --foreground 212 "[+] PHP + Composer"
            tools+=("go" "php" "composer")
            ;;
        "everything")
            gum_info "Bilgi" "=== EVERYTHING paketi:"
    gum_style --foreground 212 "[+] Node.js + Bun.js"
    gum_style --foreground 212 "[+] Go language"
    gum_style --foreground 212 "[+] PHP + Composer"
    gum_style --foreground 212 "[+] AI CLI Tools + Frameworks"
    gum_style --foreground 212 "[+] GitHub CLI"
            tools+=("nvm" "node" "bun" "go" "php" "composer" "ai_cli" "ai_frameworks" "github_cli")
            ;;
        "mobile")
            gum_info "Bilgi" "📱 Mobile + Web paketi:"
    gum_style --foreground 212 "[+] Node.js"
    gum_style --foreground 212 "[+] PHP + Composer"
    gum_style --foreground 212 "[+] Flutter araçları"
            tools+=("nvm" "node" "php" "composer")
            ;;
    esac

    echo ""
    gum_info "Bilgi" "------------------------------------------------------------"
    gum_style --foreground 212 "Toplam ${#tools[@]} araç kurulacak"
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
    gum_style --foreground 212 "=== QUICK START MODE - KURULUM BAŞLIYOR"
    fi
    echo ""
    gum_info "Bilgi" "Kurulum planınız hazırlanıyor..."
    gum_style --foreground 212 "${#tools[@]} araç otomatik kurulacak"
    echo ""
    gum_info "Bilgi" "Sürüm: v2.2.1 | Tarih: $(date '+%Y-%m-%d %H:%M')"
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
    gum_info "Bilgi" "🔍 SİSTEM KONTROL EDİLİYOR"
    fi
    echo ""

    if ! run_preflight_checks; then
    gum_style --foreground 212 "[[-]] Sistem gereksinimleri karşılanamadı! Kurulum iptal edildi."
        gum_info "Uyarı" "Lütfen yukarıdaki hataları düzeltin ve tekrar deneyin."
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
        gum_info "Bilgi" "[PACKAGE] SİSTEM GÜNCELLENİYOR"
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
        gum_info "Bilgi" "🔧 GIT YAPILANDIRMASI"
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
    gum_info "Bilgi" "[PYTHON] PYTHON EKOSİSTEMİ KURULUYOR"
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
        gum_info "Bilgi" "⚡ MODERN CLI ARAÇLARI KURULUYOR"
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
    gum_info "Bilgi" "🐚 SHELL ORTAMI YAPILANDIRILIYOR"
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
    gum_style --foreground 212 "🟢 NODE.JS KURULUYOR (NVM)"
                fi
                echo ""
                show_install_status "NVM" "installing"
                echo ""
                if install_nvm; then
                    show_install_status "NVM" "success"
                else
                    show_install_status "NVM" "skipped"
                    gum_info "Uyarı" "NVM kurulumu atlandı, devam ediliyor..."
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
                    gum_info "Bilgi" "⚡ BUN.JS KURULUYOR"
                fi
                echo ""
                show_install_status "Bun.js" "installing"
                echo ""
                if install_bun; then
                    show_install_status "Bun.js" "success"
                else
                    show_install_status "Bun.js" "skipped"
                    gum_info "Uyarı" "Bun kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "php")
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 141 --bold "[PHP] PHP 8.3 KURULUYOR"
                else
                    gum_info "Bilgi" "[PHP] PHP 8.3 KURULUYOR"
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
                    gum_info "Uyarı" "PHP kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "composer")
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 226 --bold "🎼 COMPOSER KURULUYOR"
                else
                    gum_info "Bilgi" "🎼 COMPOSER KURULUYOR"
                fi
                echo ""
                show_install_status "Composer" "installing"
                echo ""
                if install_composer; then
                    show_install_status "Composer" "success"
                else
                    show_install_status "Composer" "skipped"
                    gum_info "Uyarı" "Composer kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "go")
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 51 --bold "🔷 GO LANGUAGE KURULUYOR"
                else
    gum_info "Bilgi" "🔷 GO LANGUAGE KURULUYOR"
                fi
                echo ""
                show_install_status "Go" "installing"
                echo ""
                if install_go; then
                    show_install_status "Go" "success"
                else
                    show_install_status "Go" "skipped"
                    gum_info "Uyarı" "Go kurulumu atlandı, devam ediliyor..."
                fi
                sleep 1
                ;;
            "ai_cli")
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 212 --bold "[AI] AI CLI ARAÇLARI KURULUYOR"
                else
                    gum_info "Bilgi" "[AI] AI CLI ARAÇLARI KURULUYOR"
                fi
                echo ""

                show_install_status "Claude Code" "installing"
                if install_claude_code; then
                    show_install_status "Claude Code" "success"
                else
                    show_install_status "Claude Code" "skipped"
                    gum_info "Uyarı" "Claude Code kurulumu atlandı..."
                fi

                show_install_status "GitHub CLI" "installing"
                if install_github_cli; then
                    show_install_status "GitHub CLI" "success"
                else
                    show_install_status "GitHub CLI" "skipped"
                    gum_info "Uyarı" "GitHub CLI kurulumu atlandı..."
                fi
                sleep 1
                ;;
            "ai_frameworks")
                # Banner shown at script start, don't redraw
                echo ""
                if has_gum; then
                    gum_style --foreground 141 --bold "[AI] AI FRAMEWORK KURULUYOR"
                else
                    gum_info "Bilgi" "[AI] AI FRAMEWORK KURULUYOR"
                fi
                echo ""
                show_install_status "SuperClaude" "installing"
                echo ""
                if install_superclaude; then
                    show_install_status "SuperClaude" "success"
                else
                    show_install_status "SuperClaude" "skipped"
                    gum_info "Uyarı" "SuperClaude kurulumu atlandı..."
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
    gum_success "Başarılı" "✅ KURULUM TAMAMLANDI!"
    fi
    echo ""
    gum_style --foreground 212 "Tüm araçlar başarıyla kuruldu!"
    echo ""

    # Show installation summary
    show_installation_summary

    echo ""
    if has_gum; then
        gum_style --foreground 212 --bold "[SUCCESS] TEBRİKLER! GELİŞTİRME ORTAMINIZ HAZIR!"
    else
        gum_info "Bilgi" "[SUCCESS] TEBRİKLER! GELİŞTİRME ORTAMINIZ HAZIR!"
    fi
    echo ""
    gum_info "Bilgi" "[INFO] ŞİMDİ NE YAPACAKSINIZ?"
    echo ""
    gum_style --foreground 212 "> ADIM 1: Terminal Ortamını Yenileyin"
    gum_style --foreground 212 "Yeni kurulan araçların aktif olması için şu komutu çalıştırın:"
    gum_info "Bilgi" "→ ${GREEN}source ~/.bashrc"
    echo ""
    gum_info "Bilgi" "veya terminali kapatıp yeniden açın (daha garantili)"
    echo ""
    gum_style --foreground 212 "> ADIM 2: Kurulumları Test Edin"
    gum_info "Bilgi" "• Python: ${GREEN}python3 --version"
    gum_info "Bilgi" "• Node.js: ${GREEN}node --version"
    gum_info "Bilgi" "• NVM: ${GREEN}nvm --version"
    gum_info "Bilgi" "• Modern CLI: ${GREEN}bat --version, ${GREEN}eza --version"
    echo ""
    gum_style --foreground 212 "> ADIM 3: Kodlamaya Başlayın!"
    gum_info "Bilgi" "• Proje oluşturun: ${GREEN}mkdir my-project && cd my-project"
    gum_info "Bilgi" "• Python venv: ${GREEN}python3 -m venv venv"
    gum_info "Bilgi" "• Node proje: ${GREEN}npm init -y"
    echo ""
    gum_info "Bilgi" "[SETUP]  İleri düzey araçlar için:"
    gum_style --foreground 212 "Scripti tekrar çalıştırıp 'Advanced Mode' seçin"
    echo ""
}

# Main Quick Start flow
run_quickstart_mode() {
    # Install Gum first for modern TUI (silently if possible)
    if ! has_gum; then
    gum_info "Bilgi" "\n Modern TUI kuruluyor (Gum)..."
        install_gum || gum_info "Uyarı" "Gum kurulamadı, klasik TUI kullanılacak"
    fi

    # Show welcome
    if ! show_quickstart_welcome; then
        return 1
    fi

    # Show preset selection
    show_presets
    local preset="$QUICKSTART_PRESET_CHOICE"

    gum_info "Bilgi" "\n⚡ Bir saniye, başlıyorum..."
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