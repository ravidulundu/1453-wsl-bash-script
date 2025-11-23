#!/bin/bash
# Module: JavaScript Ecosystem
# Description: NVM and Bun.js installation functions
# Dependencies: lib/common.sh

# Install NVM (Node Version Manager)
install_nvm() {
    echo ""
    gum_header "NVM KURULUMU" "Node.js Sürüm Yöneticisi"

    # Check if NVM is already installed
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
        local nvm_version
        nvm_version=$(nvm --version 2>/dev/null || echo "unknown")

        # Check if Node is also installed
        if command -v node &> /dev/null; then
            local node_version
            node_version=$(node -v 2>/dev/null || echo "unknown")
            gum_success "Atlandı" "NVM ve Node.js zaten kurulu (NVM: v$nvm_version, Node: $node_version)"
            track_skip "NVM + Node.js" "Zaten kurulu (NVM: v$nvm_version, Node: $node_version)"
        else
            gum_info "Eksik" "NVM kurulu (v$nvm_version) ama Node.js yok, LTS kuruluyor..."
            
            local install_node_cmd="
                set +u
                . \"$NVM_DIR/nvm.sh\"
                nvm install --lts
                nvm use --lts
                set -u
            "
            
            if gum_spin_run "Node.js LTS kuruluyor..." "$install_node_cmd"; then
                local node_version
                node_version=$(node -v 2>/dev/null || echo "unknown")
                gum_success "Tamamlandı" "Node.js eklendi: $node_version"
                track_success "NVM + Node.js" "NVM mevcut, Node.js eklendi ($node_version)"
            else
                gum_alert "Hata" "Node.js kurulumu başarısız!"
                track_failure "NVM + Node.js" "Node.js kurulumu başarısız"
                return 1
            fi
        fi
        return 0
    fi

    # Download and install NVM
    local install_cmd="
        curl -fsSL --retry 3 --retry-delay 5 \"$NVM_INSTALL_URL\" | bash
    "

    if gum_spin_run "NVM indiriliyor ve kuruluyor..." "$install_cmd"; then
        # Set up NVM directory
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        # Update shell RC files
        for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$rc_file" ]; then
                if ! grep -q 'NVM_DIR' "$rc_file"; then
                    cat >> "$rc_file" << 'END_NVM_CONFIG'

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
END_NVM_CONFIG
                fi
            fi
        done

        # Load NVM again to ensure it's available
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        # Install Node.js LTS
        local install_node_cmd="
            set +u
            . \"$NVM_DIR/nvm.sh\"
            nvm install --lts
            nvm use --lts
            set -u
        "
        
        if gum_spin_run "Node.js LTS sürümü kuruluyor..." "$install_node_cmd"; then
            if command -v node &> /dev/null; then
                local node_version npm_version nvm_version
                node_version=$(node -v 2>/dev/null || echo "unknown")
                npm_version=$(npm -v 2>/dev/null || echo "unknown")
                nvm_version=$(nvm --version 2>/dev/null || echo "unknown")
                
                gum_success "Başarılı" "NVM ve Node.js kurulumu tamamlandı!"
                gum_info "Sürümler" "NVM: v$nvm_version | Node: $node_version | NPM: $npm_version"
                track_success "NVM + Node.js" "NVM: v$nvm_version, Node: $node_version"
            else
                gum_alert "Hata" "NVM kuruldu ama Node.js bulunamadı!"
                track_failure "NVM + Node.js" "Node.js kurulumu başarısız"
                return 1
            fi
        else
            gum_alert "Hata" "Node.js kurulumu başarısız!"
            track_failure "NVM + Node.js" "Kurulum başarısız"
            return 1
        fi
    else
        gum_alert "Hata" "NVM kurulumu başarısız!"
        track_failure "NVM" "Kurulum başarısız"
        return 1
    fi
}

# Install Bun.js
install_bun() {
    echo ""
    gum_header "BUN.JS KURULUMU" "Modern JavaScript Runtime"

    # Check if already installed
    if command -v bun &> /dev/null; then
        local version
        version=$(bun --version 2>/dev/null || echo "unknown")
        gum_success "Atlandı" "Bun.js zaten kurulu: $version"
        track_skip "Bun.js" "Zaten kurulu ($version)"
        return 0
    fi

    # Ensure package manager is detected
    if [ -z "$INSTALL_CMD" ]; then
        detect_package_manager
    fi

    # Check if unzip is installed (required by Bun installer)
    if ! command -v unzip &>/dev/null; then
        gum_info "Gereksinim" "unzip gerekli, kuruluyor..."
        if ! gum_spin_run "unzip kuruluyor..." "sudo $INSTALL_CMD install -y unzip"; then
            gum_alert "Hata" "unzip kurulumu başarısız! Lütfen elle kurun."
            return 1
        fi
    fi

    local install_cmd="curl -fsSL https://bun.sh/install | bash"

    if gum_spin_run "Bun.js indiriliyor ve kuruluyor..." "$install_cmd"; then
        # Set up Bun environment
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"

        # Update shell RC files
        for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$rc_file" ]; then
                if ! grep -q '.bun/bin' "$rc_file"; then
                    echo '' >> "$rc_file"
                    echo '# Bun.js PATH' >> "$rc_file"
                    echo "export BUN_INSTALL=\"\$HOME/.bun\"" >> "$rc_file"
                    echo "export PATH=\"\$BUN_INSTALL/bin:\$PATH\"" >> "$rc_file"
                fi
            fi
        done

        reload_shell_configs

        if command -v bun &> /dev/null; then
            local version
            version=$(bun --version 2>/dev/null || echo "unknown")
            gum_success "Başarılı" "Bun.js kurulumu tamamlandı: $version"
            gum_info "İpucu" "Hızlı başlangıç için: bun init"
            track_success "Bun.js" "$version"
        else
            gum_alert "Hata" "Bun.js kurulumu başarısız!"
            track_failure "Bun.js" "Kurulum başarısız"
            return 1
        fi
    else
        gum_alert "Hata" "Bun.js kurulumu başarısız!"
        track_failure "Bun.js" "Kurulum başarısız"
        return 1
    fi
}

# Export functions for use in other modules
export -f install_nvm
export -f install_bun

# Export functions for use in other modules
export -f install_nvm
export -f install_bun