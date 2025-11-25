#!/bin/bash
# Windows Interop Module
# PRD FR-3.3: Windows Font Check and Installation
# Description: WSL-Windows integration for font management

# Check if we're running in WSL
is_wsl() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        return 0
    fi
    return 1
}

# Check if Nerd Fonts are installed on Windows side
# PRD FR-3.3: Font kontrolü
check_windows_nerd_fonts() {
    if ! is_wsl; then
        return 2  # Not in WSL, skip
    fi

    # Common Nerd Fonts to check
    local fonts=(
        "CascadiaCode NF"
        "JetBrainsMono NF"
        "FiraCode NF"
        "Hack NF"
        "MesloLGS NF"
    )

    local found_fonts=()
    local missing_fonts=()

    echo ""
    gum_info "Font Kontrolü" "Windows Nerd Fonts kontrol ediliyor..."
    echo ""

    for font in "${fonts[@]}"; do
        # Check Windows font directory via PowerShell
        if command -v powershell.exe &>/dev/null; then
            local result=$(powershell.exe -NoProfile -Command \
                "Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' | Select-String '$font'" \
                2>/dev/null)

            if [ -n "$result" ]; then
                found_fonts+=("$font")
                echo "  ✅ $font - Kurulu"
            else
                missing_fonts+=("$font")
                echo "  ❌ $font - Eksik"
            fi
        fi
    done

    echo ""

    if [ ${#missing_fonts[@]} -eq 0 ]; then
        gum_success "Font Kontrolü Tamamlandı" "Tüm önerilen Nerd Fonts kurulu!"
        return 0
    else
        gum_warning "Eksik Fontlar Bulundu" "${#missing_fonts[@]} font eksik"
        return 1
    fi
}

# Install Nerd Fonts on Windows via winget
# PRD FR-3.3: Font kurulumu
install_windows_nerd_fonts() {
    if ! is_wsl; then
        gum_alert "Hata" "Bu özellik sadece WSL içinde çalışır"
        return 1
    fi

    echo ""
    gum_header "NERD FONTS KURULUMU" "Windows tarafına font kurulumu"
    echo ""

    gum_info "Bilgi" "Nerd Fonts modern terminal deneyimi için önemlidir:"
    echo ""
    echo "  • İkonlar ve semboller düzgün görüntülenir"
    echo "  • Starship prompt tam çalışır"
    echo "  • Eza, bat gibi araçlar görsel çıktı verir"
    echo "  • Modern CLI deneyimi sağlar"
    echo ""

    if ! gum_confirm "Windows tarafına Nerd Fonts kurmak ister misiniz?"; then
        gum_info "İptal" "Font kurulumu atlandı"
        return 0
    fi

    # Check if winget is available
    if ! command -v winget.exe &>/dev/null; then
        gum_alert "Winget Bulunamadı" "Windows Package Manager (winget) gerekli"
        echo ""
        echo "  Winget'i kurmak için:"
        echo "  1. Windows Store'dan 'App Installer' uygulamasını güncelleyin"
        echo "  2. Veya: https://aka.ms/getwinget"
        echo ""
        return 1
    fi

    # Font IDs for winget
    local font_packages=(
        "Cascadia.CascadiaCode.Nerd"
        "JetBrains.JetBrainsMono.Nerd"
        "FiraCode.FiraCode.Nerd"
    )

    echo ""
    gum_info "Kurulum" "Fontlar Windows'a kuruluyor (birkaç dakika sürebilir)..."
    echo ""

    local installed_count=0
    local failed_count=0

    for package in "${font_packages[@]}"; do
        local font_name=$(echo "$package" | cut -d'.' -f2)
        echo "  📦 Kuruluyor: $font_name..."

        if winget.exe install --id "$package" --silent --accept-package-agreements --accept-source-agreements 2>&1 | grep -qi "successfully"; then
            echo "  ✅ $font_name kuruldu"
            ((installed_count++))
        else
            echo "  ⚠️  $font_name kurulamadı (zaten kurulu olabilir)"
            ((failed_count++))
        fi
        echo ""
    done

    echo ""
    if [ $installed_count -gt 0 ]; then
        gum_success "Kurulum Tamamlandı" "$installed_count font başarıyla kuruldu"
        echo ""
        gum_info "Önemli" "Windows Terminal'i yeniden başlatın ve font ayarlarından Nerd Font seçin:"
        echo ""
        echo "  1. Windows Terminal açın"
        echo "  2. Settings (Ctrl+,)"
        echo "  3. Defaults → Appearance → Font face"
        echo "  4. 'CascadiaCode NF' veya 'JetBrainsMono NF' seçin"
        echo ""
    else
        gum_warning "Kurulum" "Yeni font kurulmadı (zaten kurulu olabilir)"
    fi

    return 0
}

# Main function: Check fonts and offer installation
# PRD FR-3.3: Ana font yönetimi fonksiyonu
manage_windows_fonts() {
    if ! is_wsl; then
        return 0  # Skip silently if not in WSL
    fi

    # Check fonts
    if ! check_windows_nerd_fonts; then
        echo ""
        if gum_confirm "Eksik fontları şimdi kurmak ister misiniz?"; then
            install_windows_nerd_fonts
        else
            gum_info "İptal" "Fontları daha sonra manuel kurabilirsiniz"
            echo ""
            echo "  Manuel kurulum için:"
            echo "  $ winget install Cascadia.CascadiaCode.Nerd"
            echo ""
        fi
    fi
}

# Export functions
export -f is_wsl
export -f check_windows_nerd_fonts
export -f install_windows_nerd_fonts
export -f manage_windows_fonts
