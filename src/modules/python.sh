#!/bin/bash
# Module: Python Ecosystem
# Description: Python, pip, pipx, and uv installation functions
# Dependencies: lib/common.sh, lib/package-manager.sh

# Install Python3
install_python() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Python kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Ensure package manager is detected
    if [ -z "$INSTALL_CMD" ]; then
        echo -e "${YELLOW}[!]${NC} Paket yöneticisi tespit ediliyor..."
        detect_package_manager
    fi

    if command -v python3 &> /dev/null; then
        local version
        version=$(python3 --version 2>&1 | awk '{print $2}')
        echo -e "${CYAN}[!]${NC} Python zaten kurulu: $version"

        # Check if pip module is available
        if python3 -m pip --version &>/dev/null; then
            echo -e "${GREEN}[✓]${NC} pip modülü mevcut"
            track_skip "Python" "Zaten kurulu ($version)"
        else
            echo -e "${YELLOW}[!]${NC} pip modülü eksik, python3-pip kuruluyor..."

            # Use install_package_with_retry for safer installation
            if ! install_package_with_retry "python3-pip python3-venv"; then
                echo -e "${RED}[✗]${NC} python3-pip kurulumu başarısız!"
                echo -e "${YELLOW}[!]${NC} Elle kurun: sudo apt install -y python3-pip python3-venv"
                track_failure "Python (pip modülü)" "pip kurulumu başarısız"
            else
                track_skip "Python" "Zaten kurulu ($version, pip eklendi)"
            fi
        fi
        return 0
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Python3, pip ve venv kuruluyor..."

    # Use install_package_with_retry instead of direct command
    if ! install_package_with_retry "python3 python3-pip python3-venv"; then
        echo -e "${RED}[✗]${NC} Python kurulumu başarısız!"
        echo -e "${YELLOW}[!]${NC} Elle kurun: sudo apt install -y python3 python3-pip python3-venv"
        return 1
    fi

    if command -v python3 &> /dev/null; then
        local version
        version=$(python3 --version 2>&1 | awk '{print $2}')
        echo -e "${GREEN}[BAŞARILI]${NC} Python kurulumu tamamlandı: $version"

        # Verify pip module
        if python3 -m pip --version &>/dev/null; then
            echo -e "${GREEN}[✓]${NC} pip modülü başarıyla kuruldu"
        else
            echo -e "${YELLOW}[!]${NC} pip modülü kontrol edilemiyor, devam ediliyor..."
        fi
        track_success "Python" "$version"
    else
        echo -e "${RED}[HATA]${NC} Python kurulumu başarısız!"
        track_failure "Python" "Kurulum başarısız"
        return 1
    fi
}

# Install/update pip
install_pip() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Pip kurulumu/güncelleme başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Python kurulu değil, önce Python kuruluyor..."
        install_python
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Pip güncelleniyor..."

    # Handle PEP 668 externally-managed-environment error
    # FIX BUG-011: Capture exit code properly from pip install, not from if/else or grep
    # FIX BUG-028: Capture output first, only run pip once (not twice)
    local pip_output
    pip_output=$(python3 -m pip install --upgrade pip 2>&1)
    local pip_exit_code=$?

    # If PEP 668 error detected, retry with --break-system-packages
    if echo "$pip_output" | grep -q "externally-managed-environment"; then
        echo -e "${YELLOW}[BİLGİ]${NC} Externally-managed-environment hatası, --break-system-packages ile deneniyor..."
        python3 -m pip install --upgrade pip --break-system-packages
        pip_exit_code=$?
    fi

    if [ $pip_exit_code -eq 0 ]; then
        echo -e "${GREEN}[BAŞARILI]${NC} Pip sürümü: $(python3 -m pip --version)"
        echo -e "\n${CYAN}[BİLGİ]${NC} Pip Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Paket kurma: ${GREEN}pip install paket_adi${NC}"
        echo -e "  ${GREEN}•${NC} Sanal ortamda kurma (önerilen): ${GREEN}python3 -m venv myenv && source myenv/bin/activate${NC}"
        echo -e "  ${GREEN}•${NC} Sistem geneli kurma: ${GREEN}pip install --break-system-packages paket_adi${NC}"
        echo -e "  ${YELLOW}•${NC} Not: Modern sistemlerde sanal ortam kullanımı önerilir (PEP 668)"
    else
        echo -e "${RED}[HATA]${NC} Pip güncellemesi başarısız!"
        return 1
    fi
}

# Install pipx
install_pipx() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Pipx kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v pipx &> /dev/null; then
        local version
        version=$(pipx --version 2>/dev/null || echo "unknown")
        echo -e "${CYAN}[!]${NC} Pipx zaten kurulu: $version"
        track_skip "Pipx" "Zaten kurulu ($version)"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Python kurulu değil, önce Python kuruluyor..."
        if ! install_python; then
            track_failure "Pipx" "Python gereksinimi karşılanamadı"
            return 1
        fi
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Sistem paket yöneticisi ile pipx kuruluyor..."

    # FIX BUG-004: IFS splitting - Safe for current INSTALL_CMD values
    # WARNING: This won't handle INSTALL_CMD with quoted arguments
    # Try installing pipx using the system package manager (safe execution)
    local cmd_array
    IFS=' ' read -ra cmd_array <<< "$INSTALL_CMD"

    if [ "$PKG_MANAGER" = "apt" ]; then
        "${cmd_array[@]}" pipx
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        "${cmd_array[@]}" pipx
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        "${cmd_array[@]}" python-pipx
    elif [ "$PKG_MANAGER" = "yum" ]; then
        "${cmd_array[@]}" pipx
    fi

    # If system package manager failed, try manual installation
    if ! command -v pipx &> /dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Sistem paketi bulunamadı, manuel kurulum yapılıyor..."

        # FIX BUG-024: Improved PEP 668 detection - check before attempting install
        # FIX BUG-027: Use --user instead of copying from temp venv (preserves dependencies)
        local pep668_marker="/usr/lib/python3*/EXTERNALLY-MANAGED"
        if compgen -G "$pep668_marker" > /dev/null 2>&1; then
            echo -e "${YELLOW}[BİLGİ]${NC} PEP 668 detected (externally-managed environment)"
            echo -e "${YELLOW}[BİLGİ]${NC} Using --user approach for safe installation..."

            # Use temporary venv to bootstrap user installation (preserves all dependencies)
            local TEMP_VENV="/tmp/pipx_install_venv_$$"
            python3 -m venv "$TEMP_VENV"
            "$TEMP_VENV/bin/pip" install --quiet --user pipx

            # Cleanup temp venv (user installation is in ~/.local)
            rm -rf "$TEMP_VENV"
        else
            # No PEP 668 restriction, safe to install directly
            python3 -m pip install --user pipx 2>/dev/null || \
                python3 -m pip install --user --break-system-packages pipx
        fi

        # Ensure pipx path
        if command -v pipx &> /dev/null; then
            python3 -m pipx ensurepath 2>/dev/null || pipx ensurepath 2>/dev/null || true
        fi
    fi

    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Update shell RC files
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$rc_file" ]; then
            if ! grep -q '.local/bin' "$rc_file"; then
                echo '' >> "$rc_file"
                echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$rc_file"
            fi
        fi
    done

    reload_shell_configs

    if command -v pipx &> /dev/null; then
        local version
        version=$(pipx --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} Pipx kurulumu tamamlandı: $version"
        echo -e "\n${CYAN}[BİLGİ]${NC} Pipx Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Paket kurma: ${GREEN}pipx install paket_adi${NC}"
        echo -e "  ${GREEN}•${NC} Paket listesi: ${GREEN}pipx list${NC}"
        echo -e "  ${GREEN}•${NC} Paket kaldırma: ${GREEN}pipx uninstall paket_adi${NC}"
        echo -e "  ${GREEN}•${NC} Tüm paketleri güncelle: ${GREEN}pipx upgrade-all${NC}"
        track_success "Pipx" "$version"
    else
        echo -e "${RED}[HATA]${NC} Pipx kurulumu başarısız!"
        echo -e "${YELLOW}[BİLGİ]${NC} Manuel kurulum için: sudo apt install pipx"
        track_failure "Pipx" "Kurulum başarısız"
        return 1
    fi
}

# Install UV (Ultra-fast Python package installer)
install_uv() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} UV (Ultra-fast Python package installer) kurulumu başlatılıyor..."
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

    # Check if already installed
    if command -v uv &> /dev/null; then
        local version
        version=$(uv --version 2>/dev/null || echo "unknown")
        echo -e "${CYAN}[!]${NC} UV zaten kurulu: $version"
        track_skip "UV" "Zaten kurulu ($version)"
        return 0
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} UV kuruluyor..."
    curl -LsSf "$UV_INSTALL_URL" | sh

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

    # Source cargo env if exists
    source "$HOME/.cargo/env" 2>/dev/null || true

    if command -v uv &> /dev/null; then
        local version
        version=$(uv --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} UV kurulumu tamamlandı: $version"
        echo -e "\n${CYAN}[BİLGİ]${NC} UV Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Paket kurma: ${GREEN}uv pip install paket_adi${NC}"
        echo -e "  ${GREEN}•${NC} Sanal ortam oluşturma: ${GREEN}uv venv${NC}"
        echo -e "  ${GREEN}•${NC} Python kurma: ${GREEN}uv python install 3.12${NC}"
        track_success "UV" "$version"
    else
        echo -e "${RED}[HATA]${NC} UV kurulumu başarısız!"
        track_failure "UV" "Kurulum başarısız"
        return 1
    fi
}

# Export functions for use in other modules
export -f install_python
export -f install_pip
export -f install_pipx
export -f install_uv