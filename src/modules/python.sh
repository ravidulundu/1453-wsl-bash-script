#!/bin/bash
# Module: Python Ecosystem
# Description: Python, pip, pipx, and uv installation functions
# Dependencies: lib/common.sh, lib/package-manager.sh

# Install Python3
install_python() {
    # PRD FR-2.4: AI thinking state
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "analyzing" 1
    fi
    
    echo ""
    gum_header "PYTHON KURULUMU" "Python Geliştirme Ortamı"

    # Ensure package manager is detected
    if [ -z "$INSTALL_CMD" ]; then
        detect_package_manager
    fi

    if command -v python3 &> /dev/null; then
        local version
        version=$(python3 --version 2>&1 | awk '{print $2}')
        
        # Check if pip module is available
        if python3 -m pip --version &>/dev/null; then
            gum_success "Atlandı" "Python zaten kurulu: $version"
            track_skip "Python" "Zaten kurulu ($version)"
        else
            gum_info "Eksik Modül" "pip modülü eksik, kuruluyor..."
            
            if gum_spin_run "python3-pip kuruluyor..." "sudo $INSTALL_CMD install -y python3-pip python3-venv"; then
                gum_success "Tamamlandı" "pip modülü eklendi."
                track_skip "Python" "Zaten kurulu ($version, pip eklendi)"
            else
                gum_alert "Hata" "python3-pip kurulumu başarısız!"
                track_failure "Python (pip modülü)" "pip kurulumu başarısız"
            fi
        fi
        return 0
    fi

    # Install Python
    if gum_spin_run "Python3, pip ve venv kuruluyor..." "sudo $INSTALL_CMD install -y python3 python3-pip python3-venv"; then
        local version
        version=$(python3 --version 2>&1 | awk '{print $2}')
        gum_success "Başarılı" "Python kurulumu tamamlandı: $version"
        track_success "Python" "$version"
    else
        gum_alert "Hata" "Python kurulumu başarısız!"
        track_failure "Python" "Kurulum başarısız"
        return 1
    fi
}

# Install/update pip
install_pip() {
    echo ""
    gum_header "PIP GÜNCELLEME" "Python Paket Yöneticisi"

    if ! command -v python3 &> /dev/null; then
        gum_info "Bilgi" "Python kurulu değil, önce Python kuruluyor..."
        install_python
    fi

    # Update pip with spinner
    local update_cmd="
        if command -v timeout &>/dev/null; then
            timeout \"$PIP_INSTALL_TIMEOUT_SECONDS\" python3 -m pip install --upgrade pip
        else
            python3 -m pip install --upgrade pip
        fi
    "
    
    # Handle PEP 668 fallback logic inside the command string or handle failure
    # Since gum_spin_run hides output, we try standard first, then break-system-packages if needed
    
    if gum_spin_run "Pip güncelleniyor..." "$update_cmd"; then
        gum_success "Başarılı" "Pip güncellendi: $(python3 -m pip --version | awk '{print $2}')"
    else
        gum_info "Bilgi" "Standart güncelleme başarısız, --break-system-packages deneniyor..."
        local force_update_cmd="python3 -m pip install --upgrade pip --break-system-packages"
        
        if gum_spin_run "Zorla güncelleniyor..." "$force_update_cmd"; then
            gum_success "Başarılı" "Pip güncellendi (break-system-packages): $(python3 -m pip --version | awk '{print $2}')"
        else
            gum_alert "Hata" "Pip güncellemesi başarısız!"
            return 1
        fi
    fi
    
    echo ""
    gum_info "İpucu" "Sanal ortam (venv) kullanımı önerilir."
}

# Install pipx
install_pipx() {
    echo ""
    gum_header "PIPX KURULUMU" "İzole Python Uygulamaları"

    # Check if already installed
    if command -v pipx &> /dev/null; then
        local version
        version=$(pipx --version 2>/dev/null || echo "unknown")
        gum_success "Atlandı" "Pipx zaten kurulu: $version"
        track_skip "Pipx" "Zaten kurulu ($version)"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        install_python
    fi

    # Try system package manager first
    local sys_install_cmd=""
    if [ "$PKG_MANAGER" = "apt" ]; then
        sys_install_cmd="sudo apt install -y pipx"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sys_install_cmd="sudo dnf install -y pipx"
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        sys_install_cmd="sudo pacman -S --noconfirm python-pipx"
    elif [ "$PKG_MANAGER" = "yum" ]; then
        sys_install_cmd="sudo yum install -y pipx"
    fi

    local installed=false
    
    if [ -n "$sys_install_cmd" ]; then
        if gum_spin_run "Sistem paketi ile kuruluyor..." "$sys_install_cmd"; then
            installed=true
        fi
    fi

    # Fallback to manual installation
    if [ "$installed" = false ]; then
        gum_info "Bilgi" "Sistem paketi başarısız, manuel kurulum yapılıyor..."
        
        local manual_cmd="
            python3 -m pip install --user pipx 2>/dev/null || \
            python3 -m pip install --user --break-system-packages pipx
            python3 -m pipx ensurepath 2>/dev/null || pipx ensurepath 2>/dev/null || true
        "
        
        if gum_spin_run "Pip ile kuruluyor..." "$manual_cmd"; then
            installed=true
        fi
    fi

    # Add to PATH immediately for current session
    export PATH="$HOME/.local/bin:$PATH"

    if [ "$installed" = true ] || command -v pipx &> /dev/null; then
        local version
        version=$(pipx --version 2>/dev/null || echo "unknown")
        gum_success "Başarılı" "Pipx kurulumu tamamlandı: $version"
        track_success "Pipx" "$version"
    else
        gum_alert "Hata" "Pipx kurulumu başarısız!"
        track_failure "Pipx" "Kurulum başarısız"
        return 1
    fi
}

# Install UV (Ultra-fast Python package installer)
install_uv() {
    echo ""
    gum_header "UV KURULUMU" "Ultra-hızlı Python Paket Yöneticisi"

    # Check if already installed
    if command -v uv &> /dev/null; then
        local version
        version=$(uv --version 2>/dev/null || echo "unknown")
        gum_success "Atlandı" "UV zaten kurulu: $version"
        track_skip "UV" "Zaten kurulu ($version)"
        return 0
    fi

    local install_cmd="curl -fsSL $UV_INSTALL_URL | sh"

    if gum_spin_run "UV indiriliyor ve kuruluyor..." "$install_cmd"; then
        # Add Cargo bin to PATH
        export PATH="$HOME/.cargo/bin:$PATH"
        
        # Update shell RC files
        for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$rc_file" ]; then
                if ! grep -q '.cargo/bin' "$rc_file"; then
                    echo '' >> "$rc_file"
                    echo "export PATH=\"$HOME/.cargo/bin:\$PATH\"" >> "$rc_file"
                fi
            fi
        done
        
        local version
        version=$(uv --version 2>/dev/null || echo "unknown")
        gum_success "Başarılı" "UV kurulumu tamamlandı: $version"
        track_success "UV" "$version"
    else
        gum_alert "Hata" "UV kurulumu başarısız!"
        track_failure "UV" "Kurulum başarısız"
        return 1
    fi
}

# Export functions for use in other modules
export -f install_python
export -f install_pip
export -f install_pipx
export -f install_uv