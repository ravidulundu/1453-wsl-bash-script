#!/bin/bash

# ==========================================
# Go Installation Module
# 1453 WSL Setup Script
# ==========================================

# Check if Go is already installed
is_go_installed() {
    if command -v go &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Configure Go environment variables
configure_go_env() {
    # Add Go binary to PATH
    local go_bin_path="/usr/local/go/bin"
    
    # Create or update shell RC files
    local rc_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    
    for rc_file in "${rc_files[@]}"; do
        if [ -f "$rc_file" ]; then
            # Check if Go PATH is already configured
            if ! grep -q "export PATH=\$PATH:$go_bin_path" "$rc_file" 2>/dev/null; then
                echo "" >> "$rc_file"
                echo "# Go binary path" >> "$rc_file"
                echo "export PATH=\$PATH:$go_bin_path" >> "$rc_file"
            fi
            
            # Check if GOPATH is already configured
            if ! grep -q "export GOPATH=\$HOME/go" "$rc_file" 2>/dev/null; then
                echo "export GOPATH=\$HOME/go" >> "$rc_file"
                echo "export PATH=\$PATH:\$GOPATH/bin" >> "$rc_file"
            fi
        fi
    done
}

# Install Go using official binary
install_go_official() {
    echo ""
    gum_header "GO KURULUMU" "Resmi Binary Yöntemi"

    # Check if already installed
    if is_go_installed; then
        local version
        version=$(go version 2>/dev/null | awk '{print $3}' || echo "unknown")
        gum_success "Atlandı" "Go zaten kurulu: $version"
        return 0
    fi

    # Detect architecture
    local arch="amd64"
    case $(uname -m) in
        "x86_64") arch="amd64" ;;
        "aarch64" | "arm64") arch="arm64" ;;
        "armv7l" | "armv6l") arch="armv6l" ;;
        "i686" | "i386") arch="386" ;;
        "ppc64le") arch="ppc64le" ;;
        "s390x") arch="s390x" ;;
        *)
            gum_alert "Hata" "Desteklenmeyen mimari: $(uname -m)"
            return 1
            ;;
    esac

    # Get latest version
    gum_info "Sürüm" "Son Go sürümü kontrol ediliyor..."
    local go_version
    local attempt=1
    local max_attempts=3

    while [ $attempt -le $max_attempts ]; do
        go_version=$(curl -s --connect-timeout 5 https://go.dev/VERSION?m=text 2>/dev/null | head -n1)
        [ -n "$go_version" ] && break
        ((attempt++))
        [ $attempt -le $max_attempts ] && sleep 2
    done

    if [ -z "$go_version" ]; then
        gum_info "Uyarı" "Sürüm bilgisi alınamadı, varsayılan sürüm (1.21.5) kullanılıyor."
        go_version="1.21.5"
    else
        # Remove 'go' prefix if present for display, but keep for filename if needed
        local display_version=${go_version#go}
        gum_info "Bulundu" "Son sürüm: $display_version"
        # Ensure version string for filename has 'go' prefix if curl returned it, or add it if missing
        if [[ ! "$go_version" == go* ]]; then
            go_version="go$go_version"
        fi
        # Actually, the filename format is go<version>.linux-<arch>.tar.gz
        # The curl output usually includes 'go' prefix (e.g., go1.22.0)
    fi

    local go_tarball="${go_version}.linux-${arch}.tar.gz"
    local download_url="https://go.dev/dl/${go_tarball}"

    local install_cmd="
        # Download
        if ! curl -fsSL --retry 3 --retry-delay 5 -O \"$download_url\"; then
            exit 1
        fi

        # Remove old
        if [ -d \"/usr/local/go\" ]; then
            sudo rm -rf /usr/local/go
        fi

        # Extract
        if ! sudo tar -C /usr/local -xzf \"$go_tarball\"; then
            rm -f \"$go_tarball\"
            exit 1
        fi

        rm -f \"$go_tarball\"
    "

    if gum_spin_run "Go indiriliyor ve kuruluyor..." "$install_cmd"; then
        configure_go_env
        reload_shell_configs
        
        # Verify
        if is_go_installed; then
            local version
            version=$(go version 2>/dev/null | awk '{print $3}' || echo "unknown")
            gum_success "Başarılı" "Go kurulumu tamamlandı: $version"
            return 0
        else
            gum_alert "Hata" "Go kurulumu doğrulanamadı!"
            return 1
        fi
    else
        gum_alert "Hata" "Go kurulumu başarısız!"
        return 1
    fi
}

# Install Go using package manager
install_go_package() {
    echo ""
    gum_header "GO KURULUMU" "Paket Yöneticisi Yöntemi"

    # Check if already installed
    if is_go_installed; then
        local version
        version=$(go version 2>/dev/null | awk '{print $3}' || echo "unknown")
        gum_success "Atlandı" "Go zaten kurulu: $version"
        return 0
    fi

    local pkg_name="golang"
    case "$PKG_MANAGER" in
        "apt") pkg_name="golang-go" ;;
        "dnf"|"yum") pkg_name="golang" ;;
        "pacman") pkg_name="go" ;;
    esac

    if gum_spin_run "Paket yöneticisi ile kuruluyor..." "sudo $INSTALL_CMD install -y $pkg_name"; then
        configure_go_env
        reload_shell_configs
        
        if is_go_installed; then
            local version
            version=$(go version 2>/dev/null | awk '{print $3}' || echo "unknown")
            gum_success "Başarılı" "Go kuruldu: $version"
            return 0
        else
            gum_alert "Hata" "Go kurulumu doğrulanamadı!"
            return 1
        fi
    else
        gum_alert "Hata" "Paket yöneticisi ile kurulum başarısız!"
        return 1
    fi
}

# Main Go installation function (intelligent selection)
install_go() {
    echo ""
    gum_header "GO DİLİ" "Kurulum Yöneticisi"

    # Check if already installed
    if is_go_installed; then
        local version
        version=$(go version 2>/dev/null | awk '{print $3}' || echo "unknown")
        gum_success "Atlandı" "Go zaten kurulu: $version"
        track_skip "Go" "Zaten kurulu ($version)"
        return 0
    fi

    gum_info "Seçim" "Önce paket yöneticisi deneniyor (daha hızlı)..."

    if install_go_package; then
        track_success "Go" "Paket Yöneticisi"
        return 0
    else
        gum_info "Fallback" "Paket yöneticisi başarısız, resmi binary deneniyor..."
        if install_go_official; then
            track_success "Go" "Resmi Binary"
            return 0
        else
            gum_alert "Hata" "Go kurulumu tamamen başarısız!"
            track_failure "Go" "Tüm yöntemler başarısız"
            return 1
        fi
    fi
}

# Interactive Go installation menu
install_go_menu() {
    echo ""
    gum_header "GO MENÜSÜ" "Go Dili Yönetimi"

    local selection
    selection=$(gum_choose_enhanced \
        "🚀 Otomatik Kurulum (Önerilen)" \
        "📦 Resmi Binary Kurulumu" \
        "🔧 Paket Yöneticisi Kurulumu" \
        "🗑️  Go Kaldır" \
        "ℹ️  Bilgi Göster" \
        "🔙 Ana menüye dön")

    case "$selection" in
        *"Otomatik"*) install_go ;;
        *"Binary"*) install_go_official ;;
        *"Paket"*) install_go_package ;;
        *"Kaldır"*) remove_go ;;
        *"Bilgi"*) show_go_info ;;
        *"Ana menüye dön"*|"") return ;;
    esac
}

# Uninstall Go
remove_go() {
    echo ""
    gum_header "KALDIRMA" "Go Dili Siliniyor"

    if ! gum_confirm "Go dilini ve ilgili dosyaları kaldırmak istiyor musunuz?"; then
        gum_info "İptal" "İşlem iptal edildi."
        return 0
    fi

    local remove_cmd="
        if [ -d \"/usr/local/go\" ]; then
            sudo rm -rf /usr/local/go
        fi
        
        # Remove from RC files
        for rc_file in \"$HOME/.bashrc\" \"$HOME/.zshrc\" \"$HOME/.profile\"; do
            if [ -f \"\$rc_file\" ]; then
                sed -i '/export PATH=\$PATH:\/usr\/local\/go\/bin/d' \"\$rc_file\" 2>/dev/null
                sed -i '/# Go binary path/d' \"\$rc_file\" 2>/dev/null
                sed -i '/export GOPATH=\$HOME\/go/d' \"\$rc_file\" 2>/dev/null
                sed -i '/export PATH=\$PATH:\$GOPATH\/bin/d' \"\$rc_file\" 2>/dev/null
            fi
        done
    "

    if gum_spin_run "Go kaldırılıyor..." "$remove_cmd"; then
        reload_shell_configs
        gum_success "Başarılı" "Go tamamen kaldırıldı."
    else
        gum_alert "Hata" "Kaldırma işlemi sırasında hata oluştu."
    fi
}

# Show Go information
show_go_info() {
    echo ""
    gum_header "GO BİLGİSİ" "Mevcut Kurulum Durumu"

    if is_go_installed; then
        local version=$(go version 2>/dev/null)
        local goroot=$(go env GOROOT 2>/dev/null)
        local gopath=$(go env GOPATH 2>/dev/null)
        
        gum_info "Sürüm" "$version"
        gum_info "GOROOT" "$goroot"
        gum_info "GOPATH" "$gopath"
    else
        gum_info "Durum" "Go henüz kurulu değil."
    fi
}

# Export functions for use in other modules
export -f install_go
export -f install_go_official
export -f install_go_package
export -f install_go_menu
export -f remove_go
export -f show_go_info
export -f configure_go_env
export -f is_go_installed
