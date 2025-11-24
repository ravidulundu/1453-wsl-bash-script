#!/bin/bash
# Module: Modern CLI Tools
# Description: Modern replacements for traditional CLI tools
# Dependencies: package-manager.sh, common.sh

# Install Charm Gum - Modern TUI framework for shell scripts
install_gum() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    # Check if already installed
    if command -v gum &>/dev/null; then
        local version
        version=$(gum --version 2>/dev/null | head -1 || echo "unknown")
        # Silent success or debug log if needed, but for PRD compliance we avoid clutter
        # track_skip is internal logic, keep it but don't output to UI unless verbose
        track_skip "Charm Gum" "Zaten kurulu: $version"
        return 0
    fi

    gum_header "GUM KURULUMU" "Modern TUI Altyapısı Hazırlanıyor"

    # Detect package manager
    if [ -z "${PKG_MANAGER:-}" ]; then
        detect_package_manager
    fi

    local install_cmd=""
    
    case $PKG_MANAGER in
        apt)
            install_cmd="
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                echo 'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' | sudo tee /etc/apt/sources.list.d/charm.list
                sudo apt update -qq
                sudo apt install -y gum
            "
            ;;
        dnf)
            install_cmd="
                echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
                sudo dnf install -y gum
            "
            ;;
        yum)
            install_cmd="
                echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
                sudo yum install -y gum
            "
            ;;
        pacman)
            install_cmd="sudo pacman -S --noconfirm gum"
            ;;
        *)
            gum_alert "Hata" "Desteklenmeyen paket yöneticisi: $PKG_MANAGER"
            track_failure "Charm Gum" "Desteklenmeyen paket yöneticisi"
            return 1
            ;;
    esac

    # Execute installation with spinner and log hiding
    if gum_spin_run "Gum kuruluyor..." "$install_cmd"; then
        local version
        version=$(gum --version 2>/dev/null | head -1 || echo "unknown")
        gum_success "Başarılı" "Gum başarıyla kuruldu: $version"
        track_success "Charm Gum" "Kuruldu: $version"
        return 0
    else
        gum_alert "Hata" "Gum kurulumu başarısız oldu."
        track_failure "Charm Gum" "Kurulum başarısız"
        return 1
    fi
}

# Install modern CLI tools (batcat, ripgrep, fd-find, eza, etc.)
install_modern_cli_tools() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    echo ""
    gum_header "MODERN CLI ARAÇLARI" "Kurulum ve Yapılandırma"

    # Check which tools are already installed
    local already_installed=()
    local missing_tools=()

    # Check each tool
    (command -v bat &>/dev/null || command -v batcat &>/dev/null) && already_installed+=("bat") || missing_tools+=("bat")
    command -v rg &>/dev/null && already_installed+=("ripgrep") || missing_tools+=("ripgrep")
    (command -v fd &>/dev/null || command -v fdfind &>/dev/null) && already_installed+=("fd") || missing_tools+=("fd")
    command -v eza &>/dev/null && already_installed+=("eza") || missing_tools+=("eza")
    command -v starship &>/dev/null && already_installed+=("starship") || missing_tools+=("starship")
    command -v zoxide &>/dev/null && already_installed+=("zoxide") || missing_tools+=("zoxide")
    command -v fzf &>/dev/null && already_installed+=("fzf") || missing_tools+=("fzf")
    command -v vivid &>/dev/null && already_installed+=("vivid") || missing_tools+=("vivid")
    command -v fastfetch &>/dev/null && already_installed+=("fastfetch") || missing_tools+=("fastfetch")
    command -v lazygit &>/dev/null && already_installed+=("lazygit") || missing_tools+=("lazygit")
    command -v lazydocker &>/dev/null && already_installed+=("lazydocker") || missing_tools+=("lazydocker")
    command -v tree &>/dev/null && already_installed+=("tree") || missing_tools+=("tree")

    # If all tools are installed, skip
    if [ ${#missing_tools[@]} -eq 0 ]; then
        gum_success "Atlandı" "Tüm modern CLI araçları zaten kurulu (${#already_installed[@]}/12)"
        track_skip "Modern CLI Tools" "Tüm araçlar kurulu (${already_installed[*]})"
        return 0
    fi

    # Show status
    if [ ${#already_installed[@]} -gt 0 ]; then
        gum_info "Mevcut Araçlar" "${already_installed[*]}"
    fi

    # PRD FR-2.2: Use gum_filter_enhanced for tool selection
    echo ""
    gum_info "Bilgi" "Kurulacak ${#missing_tools[@]} araç bulundu"
    gum_style --foreground "$COLOR_GOLD_FG" "   💡 Bazı araçları seçmek için aşağıdaki filtreyi kullanabilirsiniz"
    echo ""

    if gum_confirm "Hangi araçları kuracağınızı seçmek ister misiniz?"; then
        # Use gum filter for fuzzy search
        local selected_tools
        selected_tools=$(printf '%s\n' "${missing_tools[@]}" | gum_filter_enhanced "Kurmak istediğiniz araçları seçin (Tab: Seç, Enter: Onayla)")

        if [ -z "$selected_tools" ]; then
            gum_alert "Uyarı" "Hiçbir araç seçilmedi!"
            return 0
        fi

        # Update missing_tools to only selected ones
        missing_tools=()
        while IFS= read -r tool; do
            missing_tools+=("$tool")
        done <<< "$selected_tools"

        gum_info "Seçilen Araçlar" "${missing_tools[*]}"
    else
        gum_info "Kurulacak Araçlar" "${missing_tools[*]}"
    fi
    echo ""

    # Detect package manager
    if [ -z "${PKG_MANAGER:-}" ]; then
        detect_package_manager
    fi

    # Install tools based on package manager
    case $PKG_MANAGER in
        apt)
            install_modern_tools_apt
            ;;
        dnf|yum)
            install_modern_tools_dnf
            ;;
        pacman)
            install_modern_tools_pacman
            ;;
        *)
            gum_alert "Hata" "Desteklenmeyen paket yöneticisi: $PKG_MANAGER"
            return 1
            ;;
    esac

    # Final check and tracking
    local installed_count=0
    local final_installed=()
    local final_failed=()

    # Check which tools are now installed
    (command -v bat &>/dev/null || command -v batcat &>/dev/null) && final_installed+=("bat") || final_failed+=("bat")
    command -v rg &>/dev/null && final_installed+=("ripgrep") || final_failed+=("ripgrep")
    (command -v fd &>/dev/null || command -v fdfind &>/dev/null) && final_installed+=("fd") || final_failed+=("fd")
    command -v eza &>/dev/null && final_installed+=("eza") || final_failed+=("eza")
    command -v starship &>/dev/null && final_installed+=("starship") || final_failed+=("starship")
    command -v zoxide &>/dev/null && final_installed+=("zoxide") || final_failed+=("zoxide")
    command -v fzf &>/dev/null && final_installed+=("fzf") || final_failed+=("fzf")
    command -v vivid &>/dev/null && final_installed+=("vivid") || final_failed+=("vivid")
    command -v fastfetch &>/dev/null && final_installed+=("fastfetch") || final_failed+=("fastfetch")
    command -v lazygit &>/dev/null && final_installed+=("lazygit") || final_failed+=("lazygit")
    command -v lazydocker &>/dev/null && final_installed+=("lazydocker") || final_failed+=("lazydocker")
    command -v tree &>/dev/null && final_installed+=("tree") || final_failed+=("tree")

    # Clear hash to ensure we find newly installed tools
    hash -r 2>/dev/null

    installed_count=${#final_installed[@]}

    echo ""
    if [ $installed_count -eq 12 ]; then
        gum_success "Tamamlandı" "Tüm modern CLI araçları başarıyla kuruldu! ($installed_count/12)"
        track_success "Modern CLI Tools" "Tüm araçlar kuruldu (12/12)"
    elif [ $installed_count -gt 0 ]; then
        gum_success "Kısmen Tamamlandı" "$installed_count/12 araç kuruldu."
        track_success "Modern CLI Tools" "$installed_count/12 kuruldu: ${final_installed[*]}"
        if [ ${#final_failed[@]} -gt 0 ]; then
            gum_alert "Eksik" "Kurulamayan araçlar: ${final_failed[*]}"
            track_failure "Modern CLI Tools (eksik)" "Kurulamadı: ${final_failed[*]}"
        fi
    else
        gum_alert "Başarısız" "Hiçbir araç kurulamadı."
        track_failure "Modern CLI Tools" "Hiçbir araç kurulamadı"
        return 1
    fi
}

# Generic function to fix bat/fd symlinks (works across all distros)
fix_bat_fd_symlinks() {
    gum_spin_run "Symlinkler kontrol ediliyor..." "
        mkdir -p \"$HOME/.local/bin\"
        
        # bat symlink
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            ln -sf \"\$(which batcat)\" \"$HOME/.local/bin/bat\"
        fi
        
        # fd symlink
        if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
            ln -sf \"\$(which fdfind)\" \"$HOME/.local/bin/fd\"
        fi
        
        # Add to PATH if needed
        if [[ \":\$PATH:\" != *\":$HOME/.local/bin:\"* ]]; then
            if ! grep -qF 'export PATH=\"\$HOME/.local/bin:\$PATH\"' \"$HOME/.bashrc\" 2>/dev/null; then
                echo '' >> \"$HOME/.bashrc\"
                echo '# Add ~/.local/bin to PATH for user binaries' >> \"$HOME/.bashrc\"
                echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> \"$HOME/.bashrc\"
            fi
        fi
    "
}

# REFACTOR O-5: Helper for eza installation
_apt_install_eza() {
    if ! command -v eza &> /dev/null; then
        gum_spin_run "Eza kuruluyor..." "
            sudo rm -f /etc/apt/sources.list.d/gierens.list 2>/dev/null
            sudo rm -f /etc/apt/keyrings/gierens.gpg 2>/dev/null
            
            if ! command -v gpg &>/dev/null; then
                sudo apt update -qq && sudo apt install -y gpg
            fi
            
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt update -qq
            sudo apt install -y eza
        "
    fi
}

# REFACTOR O-5: Helper for starship installation
_apt_install_starship() {
    if ! command -v starship &> /dev/null; then
        gum_spin_run "Starship kuruluyor..." "
            if ! sudo apt install -y starship 2>/dev/null; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
        "
    fi
}

# REFACTOR O-5: Helper for zoxide installation
_apt_install_zoxide() {
    if ! command -v zoxide &> /dev/null; then
        gum_spin_run "Zoxide kuruluyor..." "
            if ! sudo apt install -y zoxide 2>/dev/null; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
        "
    fi
}

# REFACTOR O-5: Helper for vivid installation
_apt_install_vivid() {
    if ! command -v vivid &> /dev/null; then
        gum_spin_run "Vivid kuruluyor..." "
            vivid_deb='vivid-musl_${VIVID_VERSION}_amd64.deb'
            vivid_url='https://github.com/sharkdp/vivid/releases/download/v${VIVID_VERSION}/'\"\$vivid_deb\"
            curl -fsSL \"\$vivid_url\" -o \"\$vivid_deb\"
            sudo dpkg -i \"\$vivid_deb\"
            rm -f \"\$vivid_deb\"
        "
    fi
}

# REFACTOR O-5: Helper for fastfetch installation
_apt_install_fastfetch() {
    if ! command -v fastfetch &> /dev/null; then
        gum_spin_run "Fastfetch kuruluyor..." "
            if command -v snap &> /dev/null; then
                sudo snap install fastfetch
            else
                curl -sL \"$FASTFETCH_DOWNLOAD_URL\" -o /tmp/fastfetch.deb
                sudo dpkg -i /tmp/fastfetch.deb || sudo apt install -f -y
                rm -f /tmp/fastfetch.deb
            fi
        "
    fi
}

# REFACTOR O-5: Helper for lazygit installation
_apt_install_lazygit() {
    if ! command -v lazygit &> /dev/null; then
        gum_spin_run "Lazygit kuruluyor..." "
            lazygit_tarball='lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz'
            curl -Lo lazygit.tar.gz \"https://github.com/jesseduffield/lazygit/releases/latest/download/\$lazygit_tarball\"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit lazygit.tar.gz
        "
    fi
}

# REFACTOR O-5: Helper for lazydocker installation
_apt_install_lazydocker() {
    if ! command -v lazydocker &> /dev/null; then
        gum_spin_run "Lazydocker kuruluyor..." "
            curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        "
    fi
}

# REFACTOR O-5: Main APT installation function
install_modern_tools_apt() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    gum_info "Paket Yöneticisi" "APT kullanılıyor..."

    # Install core tools from APT repositories
    gum_spin_run "Temel araçlar kuruluyor (bat, ripgrep, fd, fzf)..." "sudo apt install -y bat ripgrep fd-find fzf tree"

    # Fix bat/fd symlinks
    fix_bat_fd_symlinks

    # Install remaining tools using helper functions
    _apt_install_eza
    _apt_install_starship
    _apt_install_zoxide
    _apt_install_vivid
    _apt_install_fastfetch
    _apt_install_lazygit
    _apt_install_lazydocker

    gum_success "Tamamlandı" "APT araç kurulumu tamamlandı!"
}

# Install modern tools for DNF/YUM (Fedora/RHEL)
install_modern_tools_dnf() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    gum_info "Paket Yöneticisi" "DNF/YUM kullanılıyor..."
    gum_spin_run "Temel araçlar kuruluyor..." "sudo $PKG_MANAGER install -y bat ripgrep fd-find fzf tree"
    fix_bat_fd_symlinks
    install_starship_generic
    install_zoxide_generic
    install_lazygit_generic
    install_lazydocker_generic
    gum_alert "Uyarı" "Eza, Vivid, Fastfetch manuel kurulum gerektirebilir."
}

# Install modern tools for Pacman (Arch)
install_modern_tools_pacman() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    gum_info "Paket Yöneticisi" "Pacman kullanılıyor..."
    gum_spin_run "Araçlar kuruluyor..." "sudo pacman -S --noconfirm bat ripgrep fd fzf eza starship zoxide tree"
    install_lazygit_generic
    install_lazydocker_generic
    gum_alert "Uyarı" "Vivid, Fastfetch AUR'dan kurulabilir."
}

# Generic installer functions (using centralized versions from config/tool-versions.sh)
install_starship_generic() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    if ! command -v starship &> /dev/null; then
        gum_spin_run "Starship kuruluyor..." "curl -sS https://starship.rs/install.sh | sh -s -- -y"
    fi
}

install_zoxide_generic() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    if ! command -v zoxide &> /dev/null; then
        gum_spin_run "Zoxide kuruluyor..." "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
    fi
}

install_lazygit_generic() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    if ! command -v lazygit &> /dev/null; then
        _apt_install_lazygit # Reuse the same logic
    fi
}

install_lazydocker_generic() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    if ! command -v lazydocker &> /dev/null; then
        _apt_install_lazydocker # Reuse the same logic
    fi
}

# Export functions
export -f install_gum
export -f install_modern_cli_tools
export -f fix_bat_fd_symlinks

# Export APT helper functions (REFACTOR O-5)
export -f _apt_install_eza
export -f _apt_install_starship
export -f _apt_install_zoxide
export -f _apt_install_vivid
export -f _apt_install_fastfetch
export -f _apt_install_lazygit
export -f _apt_install_lazydocker

# Export main installation functions
export -f install_modern_tools_apt
export -f install_modern_tools_dnf
export -f install_modern_tools_pacman

# Export generic installer functions
export -f install_starship_generic
export -f install_zoxide_generic
export -f install_lazygit_generic
export -f install_lazydocker_generic

# Export functions
export -f install_gum
export -f install_modern_cli_tools
export -f fix_bat_fd_symlinks

# Export APT helper functions (REFACTOR O-5)
export -f _apt_install_eza
export -f _apt_install_starship
export -f _apt_install_zoxide
export -f _apt_install_vivid
export -f _apt_install_fastfetch
export -f _apt_install_lazygit
export -f _apt_install_lazydocker

# Export main installation functions
export -f install_modern_tools_apt
export -f install_modern_tools_dnf
export -f install_modern_tools_pacman

# Export generic installer functions
export -f install_starship_generic
export -f install_zoxide_generic
export -f install_lazygit_generic
export -f install_lazydocker_generic
