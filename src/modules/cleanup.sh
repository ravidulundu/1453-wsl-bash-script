#!/bin/bash
# Module: Cleanup and Reset
# Description: Cleanup installations, configs, and reset system
# Dependencies: All other modules

# Backup configurations before cleanup
backup_configs() {
    local backup_root="$HOME/.1453-backups"
    local backup_name="backup-$(date +%Y%m%d_%H%M%S)"
    local backup_dir="$backup_root/$backup_name"

    # Create backup root directory
    mkdir -p "$backup_root"
    mkdir -p "$backup_dir"

    echo -e "${CYAN}[BİLGİ]${NC} Yedek oluşturuluyor: $backup_dir"

    # Backup config files
    [ -f ~/.bashrc ] && cp ~/.bashrc "$backup_dir/"
    [ -f ~/.bash_aliases ] && cp ~/.bash_aliases "$backup_dir/"
    [ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml "$backup_dir/"
    [ -f ~/.zshrc ] && cp ~/.zshrc "$backup_dir/"

    # Backup installation directory
    [ -d ~/.1453-wsl-setup ] && cp -r ~/.1453-wsl-setup "$backup_dir/"

    echo -e "${GREEN}[BAŞARILI]${NC} Yedek oluşturuldu: $backup_dir"

    # Cleanup old backups (keep only last 3)
    cleanup_old_backups "$backup_root"
}

# Cleanup old backups (keep only last 3)
cleanup_old_backups() {
    local backup_root="$1"

    # Count backups
    local backup_count=$(find "$backup_root" -maxdepth 1 -type d -name "backup-*" 2>/dev/null | wc -l)

    if [ "$backup_count" -gt 3 ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Eski yedekler temizleniyor (son 3 korunuyor)..."

        # List backups sorted by date (oldest first), skip last 3, delete rest
        find "$backup_root" -maxdepth 1 -type d -name "backup-*" -printf "%T@ %p\n" 2>/dev/null | \
            sort -n | \
            head -n -3 | \
            cut -d' ' -f2- | \
            while IFS= read -r old_backup; do
                echo -e "${CYAN}[SİLİNİYOR]${NC} $(basename "$old_backup")"
                rm -rf "$old_backup"
            done

        echo -e "${GREEN}[BAŞARILI]${NC} Eski yedekler temizlendi (son 3 korundu)"
    fi
}

# Confirmation mechanism
confirm_cleanup() {
    local item="$1"

    echo ""
    echo -e "${RED}⚠️  UYARI: Bu işlem GERİ ALINAMAZ!${NC}"
    echo -e "${YELLOW}Şunlar silinecek: $item${NC}"
    echo ""

    # Backup option
    echo -ne "${YELLOW}Devam etmeden önce yedek oluşturulsun mu? (e/h): ${NC}"
    read -r backup </dev/tty
    if [[ "$backup" =~ ^[Ee]$ ]]; then
        backup_configs
    fi

    echo ""
    echo -ne "${RED}Silme işlemine devam edilsin mi? (evet yazın): ${NC}"
    read -r confirm </dev/tty

    if [[ "$confirm" != "evet" ]]; then
        echo -e "${CYAN}[BİLGİ]${NC} İptal edildi."
        return 1
    fi

    return 0
}

# Show installed items
show_installed_items() {
    clear
    echo ""
    echo ""

    echo -e "${CYAN}[Python Ekosistemi]${NC}"
    if command -v python3 &>/dev/null; then
        echo -e "  ${GREEN}✅ Python: $(python3 --version 2>&1 | cut -d' ' -f2)${NC}"
    else
        echo -e "  ${RED}❌ Python: Kurulu değil${NC}"
    fi

    if command -v pip &>/dev/null; then
        echo -e "  ${GREEN}✅ pip: $(pip --version 2>&1 | cut -d' ' -f2)${NC}"
    else
        echo -e "  ${RED}❌ pip: Kurulu değil${NC}"
    fi

    if command -v pipx &>/dev/null; then
        echo -e "  ${GREEN}✅ pipx: Kurulu${NC}"
    else
        echo -e "  ${RED}❌ pipx: Kurulu değil${NC}"
    fi

    if command -v uv &>/dev/null; then
        echo -e "  ${GREEN}✅ UV: $(uv --version 2>&1 | cut -d' ' -f2)${NC}"
    else
        echo -e "  ${RED}❌ UV: Kurulu değil${NC}"
    fi

    echo ""
    echo -e "${CYAN}[JavaScript Ekosistemi]${NC}"
    if command -v node &>/dev/null; then
        echo -e "  ${GREEN}✅ Node.js: $(node --version)${NC}"
        echo -e "  ${GREEN}✅ npm: $(npm --version)${NC}"
    else
        echo -e "  ${RED}❌ Node.js: Kurulu değil${NC}"
    fi

    if [ -d "$HOME/.nvm" ]; then
        echo -e "  ${GREEN}✅ NVM: Kurulu${NC}"
    else
        echo -e "  ${RED}❌ NVM: Kurulu değil${NC}"
    fi

    if command -v bun &>/dev/null; then
        echo -e "  ${GREEN}✅ Bun: $(bun --version)${NC}"
    else
        echo -e "  ${RED}❌ Bun: Kurulu değil${NC}"
    fi

    echo ""
    echo -e "${CYAN}[PHP Ekosistemi]${NC}"
    if command -v php &>/dev/null; then
        echo -e "  ${GREEN}✅ PHP: $(php --version 2>&1 | head -1 | cut -d' ' -f2)${NC}"
    else
        echo -e "  ${RED}❌ PHP: Kurulu değil${NC}"
    fi

    if command -v composer &>/dev/null; then
        echo -e "  ${GREEN}✅ Composer: Kurulu${NC}"
    else
        echo -e "  ${RED}❌ Composer: Kurulu değil${NC}"
    fi

    echo ""
    echo -e "${CYAN}[Go]${NC}"
    if command -v go &>/dev/null; then
        echo -e "  ${GREEN}✅ Go: $(go version | cut -d' ' -f3)${NC}"
    else
        echo -e "  ${RED}❌ Go: Kurulu değil${NC}"
    fi

    echo ""
    echo -e "${CYAN}[Docker]${NC}"
    if command -v docker &>/dev/null; then
        echo -e "  ${GREEN}✅ Docker Engine: $(docker --version 2>&1 | cut -d' ' -f3 | cut -d',' -f1)${NC}"
    else
        echo -e "  ${RED}❌ Docker Engine: Kurulu değil${NC}"
    fi
    if command -v lazydocker &>/dev/null; then
        echo -e "  ${GREEN}✅ lazydocker${NC}"
    else
        echo -e "  ${RED}❌ lazydocker${NC}"
    fi

    echo ""
    echo -e "${CYAN}[Modern CLI Tools]${NC}"
    local tools=("bat" "eza" "starship" "zoxide" "vivid" "fastfetch" "lazygit")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}✅ $tool${NC}"
        else
            echo -e "  ${RED}❌ $tool${NC}"
        fi
    done

    echo ""
    echo -e "${CYAN}[Config Dosyaları]${NC}"
    [ -f ~/.bash_aliases ] && echo -e "  ${GREEN}✅ .bash_aliases${NC}" || echo -e "  ${RED}❌ .bash_aliases${NC}"
    [ -f ~/.config/starship.toml ] && echo -e "  ${GREEN}✅ starship.toml${NC}" || echo -e "  ${RED}❌ starship.toml${NC}"

    echo ""
    echo -e "${CYAN}[Kurulum Dizini]${NC}"
    [ -d ~/.1453-wsl-setup ] && echo -e "  ${GREEN}✅ ~/.1453-wsl-setup${NC}" || echo -e "  ${RED}❌ ~/.1453-wsl-setup${NC}"

    echo ""
}

# Cleanup System Packages (installed by update_system())
cleanup_system_packages() {
    echo ""

    echo -e "${CYAN}[BİLGİ]${NC} update_system() tarafından kurulan paketler kaldırılıyor..."
    echo ""

    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Temel paketler kaldırılıyor (jq, zip, unzip, p7zip-full)..."
        sudo apt remove -y jq zip unzip p7zip-full 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Temel paketler kaldırıldı"

        echo -e "${YELLOW}[BİLGİ]${NC} Build tools kaldırılıyor (build-essential)..."
        sudo apt remove -y build-essential 2>/dev/null
        sudo apt autoremove -y 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Build tools kaldırıldı"

    elif [ "$PKG_MANAGER" = "dnf" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Temel paketler kaldırılıyor..."
        sudo dnf remove -y jq zip unzip p7zip 2>/dev/null
        sudo dnf groupremove "Development Tools" -y 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Paketler kaldırıldı"

    elif [ "$PKG_MANAGER" = "yum" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Temel paketler kaldırılıyor..."
        sudo yum remove -y jq zip unzip p7zip 2>/dev/null
        sudo yum groupremove "Development Tools" -y 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Paketler kaldırıldı"

    elif [ "$PKG_MANAGER" = "pacman" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Temel paketler kaldırılıyor..."
        sudo pacman -R --noconfirm jq zip unzip p7zip base-devel 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Paketler kaldırıldı"
    fi

    echo -e "${CYAN}[BİLGİ]${NC} curl, wget, git korundu (sistem için kritik olabilir)"
    echo -e "\n${GREEN}[BAŞARILI]${NC} Sistem paketleri temizlendi"
}

# Cleanup Python ecosystem
cleanup_python() {
    echo ""

    # pipx packages and executable
    if command -v pipx &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} pipx paketleri kaldırılıyor..."
        pipx uninstall-all 2>/dev/null
        rm -rf ~/.local/pipx

        # Remove pipx itself if installed via APT
        if [ "$PKG_MANAGER" = "apt" ]; then
            sudo apt remove -y pipx 2>/dev/null
        fi
        echo -e "${GREEN}[BAŞARILI]${NC} pipx kaldırıldı"
    fi

    # UV
    if command -v uv &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} UV kaldırılıyor..."
        rm -f ~/.local/bin/uv
        rm -rf ~/.local/share/uv
        echo -e "${GREEN}[BAŞARILI]${NC} UV kaldırıldı"
    fi

    # pip cache
    if command -v pip &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} pip cache temizleniyor..."
        pip cache purge 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} pip cache temizlendi"
    fi

    # Python APT packages installed by script
    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Python APT paketleri kaldırılıyor..."
        sudo apt remove -y python3-pip python3-venv 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Python APT paketleri kaldırıldı"
        echo -e "${CYAN}[BİLGİ]${NC} python3 korundu (sistem paketi olabilir)"
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} Python ekosistemi temizlendi"
}

# Cleanup Node.js and NVM
cleanup_nodejs() {
    echo ""

    # NVM
    if [ -d "$HOME/.nvm" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} NVM kaldırılıyor..."
        rm -rf ~/.nvm

        # FIX BUG-014: Use portable temp file approach instead of sed -i
        # Remove NVM from shell configs
        # FIX BUG-030: Use specific patterns to avoid deleting unrelated lines
        sed '/export NVM_DIR=/d' ~/.bashrc > ~/.bashrc.tmp 2>/dev/null && mv ~/.bashrc.tmp ~/.bashrc
        sed '/NVM_DIR\/nvm.sh/d' ~/.bashrc > ~/.bashrc.tmp 2>/dev/null && mv ~/.bashrc.tmp ~/.bashrc
        sed '/NVM_DIR\/bash_completion/d' ~/.bashrc > ~/.bashrc.tmp 2>/dev/null && mv ~/.bashrc.tmp ~/.bashrc

        echo -e "${GREEN}[BAŞARILI]${NC} NVM kaldırıldı"
    fi

    # Bun
    if command -v bun &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Bun kaldırılıyor..."
        rm -rf ~/.bun
        # FIX BUG-014: Use portable temp file approach instead of sed -i
        sed '/BUN_INSTALL/d' ~/.bashrc > ~/.bashrc.tmp 2>/dev/null && mv ~/.bashrc.tmp ~/.bashrc
        echo -e "${GREEN}[BAŞARILI]${NC} Bun kaldırıldı"
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} Node.js ekosistemi temizlendi"
}

# Cleanup PHP and Composer
cleanup_php() {
    echo ""

    # Composer
    if command -v composer &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Composer kaldırılıyor..."
        sudo rm -f /usr/local/bin/composer
        rm -rf ~/.composer
        echo -e "${GREEN}[BAŞARILI]${NC} Composer kaldırıldı"
    fi

    # Remove PHP packages installed via APT
    if [ "$PKG_MANAGER" = "apt" ] && command -v php &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} PHP paketleri kaldırılıyor..."
        # FIX BUG-005: Properly quote package list to prevent word splitting issues
        # Get list of installed PHP packages safely using dpkg
        local php_packages
        # FIX BUG-016: Improved regex to match ALL PHP packages
        # Matches: php8, php8.3, php8.3-cli, php8.3-fpm, php-common, etc.
        local -a pkg_array
        mapfile -t pkg_array < <(dpkg -l | grep '^ii' | grep -E 'php[0-9]*(\.[0-9]+)?(-[a-z0-9]+)?' | awk '{print $2}')
        if [ "${#pkg_array[@]}" -gt 0 ]; then
            sudo apt remove -y "${pkg_array[@]}" 2>/dev/null
            sudo apt autoremove -y 2>/dev/null
        fi

        # Remove Ondřej Surý PPA
        if grep -R "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null | grep -q ondrej; then
            echo -e "${YELLOW}[BİLGİ]${NC} Ondřej Surý PPA kaldırılıyor..."
            sudo add-apt-repository --remove -y ppa:ondrej/php 2>/dev/null
        fi
        echo -e "${GREEN}[BAŞARILI]${NC} PHP paketleri kaldırıldı"
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} PHP ekosistemi temizlendi"
}

# Cleanup Go
cleanup_go() {
    echo ""

    if [ -d "/usr/local/go" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Go kaldırılıyor..."
        sudo rm -rf /usr/local/go

        # FIX BUG-014: Use portable temp file approach instead of sed -i
        # Remove from PATH
        sed '/\/usr\/local\/go\/bin/d' ~/.bashrc > ~/.bashrc.tmp 2>/dev/null && mv ~/.bashrc.tmp ~/.bashrc
        sed '/GOPATH/d' ~/.bashrc > ~/.bashrc.tmp 2>/dev/null && mv ~/.bashrc.tmp ~/.bashrc

        echo -e "${GREEN}[BAŞARILI]${NC} Go kaldırıldı"
    else
        echo -e "${CYAN}[BİLGİ]${NC} Go kurulu değil"
    fi
}

# Cleanup Modern CLI Tools
cleanup_modern_tools() {
    echo ""

    echo -e "${CYAN}[BİLGİ]${NC} 1453 WSL Setup'ın kurduğu modern CLI tools kaldırılıyor..."
    echo ""

    # APT packages installed by this script
    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} APT paketleri kaldırılıyor (bat, ripgrep, fd-find, fzf)..."
        sudo apt remove -y bat ripgrep fd-find fzf 2>/dev/null && \
            echo -e "${GREEN}[BAŞARILI]${NC} APT paketleri kaldırıldı"
    fi

    # Starship (manual install via curl)
    if command -v starship &>/dev/null && [ -f /usr/local/bin/starship ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Starship kaldırılıyor..."
        sudo rm -f /usr/local/bin/starship
        rm -f ~/.config/starship.toml
        echo -e "${GREEN}[BAŞARILI]${NC} Starship kaldırıldı"
    fi

    # Zoxide (manual install via curl)
    if [ -f ~/.local/bin/zoxide ] || [ -f /usr/local/bin/zoxide ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Zoxide kaldırılıyor..."
        rm -f ~/.local/bin/zoxide
        sudo rm -f /usr/local/bin/zoxide
        echo -e "${GREEN}[BAŞARILI]${NC} Zoxide kaldırıldı"
    fi

    # Eza (manual install via repository)
    if command -v eza &>/dev/null && [ -f /etc/apt/sources.list.d/gierens.list ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Eza kaldırılıyor..."
        sudo apt remove -y eza 2>/dev/null
        sudo rm -f /etc/apt/sources.list.d/gierens.list
        sudo rm -f /etc/apt/keyrings/gierens.gpg
        echo -e "${GREEN}[BAŞARILI]${NC} Eza kaldırıldı"
    fi

    # Vivid (manual .deb install)
    if command -v vivid &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Vivid kaldırılıyor..."
        sudo apt remove -y vivid 2>/dev/null || sudo rm -f /usr/bin/vivid
        echo -e "${GREEN}[BAŞARILI]${NC} Vivid kaldırıldı"
    fi

    # Fastfetch (manual install via snap or GitHub)
    if command -v fastfetch &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Fastfetch kaldırılıyor..."
        if snap list | grep -q fastfetch 2>/dev/null; then
            sudo snap remove fastfetch
            echo -e "${GREEN}[BAŞARILI]${NC} Fastfetch (snap) kaldırıldı"
        else
            sudo apt remove -y fastfetch 2>/dev/null
            echo -e "${GREEN}[BAŞARILI]${NC} Fastfetch kaldırıldı"
        fi
    fi

    # Lazygit (manual install via GitHub)
    if [ -f /usr/local/bin/lazygit ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Lazygit kaldırılıyor..."
        sudo rm -f /usr/local/bin/lazygit
        echo -e "${GREEN}[BAŞARILI]${NC} Lazygit kaldırıldı"
    fi

    # Note: lazydocker is cleaned up in cleanup_docker()

    # Clean up symlinks created by this script
    echo -e "${YELLOW}[BİLGİ]${NC} Script symlink'leri temizleniyor..."
    rm -f ~/.local/bin/bat ~/.local/bin/fd
    echo -e "${GREEN}[BAŞARILI]${NC} Symlink'ler temizlendi"

    echo ""
    echo -e "${GREEN}[BAŞARILI]${NC} Modern CLI tools tamamen kaldırıldı"
}

# Cleanup Shell Configs
cleanup_shell_configs() {
    echo ""

    # Backup first
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}[BAŞARILI]${NC} .bashrc yedeklendi"
    fi

    if [ -f ~/.bash_aliases ]; then
        cp ~/.bash_aliases ~/.bash_aliases.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}[BAŞARILI]${NC} .bash_aliases yedeklendi"
    fi

    # Remove .bash_aliases completely (script creates this entire file)
    if [ -f ~/.bash_aliases ]; then
        rm -f ~/.bash_aliases
        echo -e "${GREEN}[BAŞARILI]${NC} .bash_aliases silindi"
    fi

    # FIX BUG-008: Validate marker integrity before cleanup
    # Count START and END markers to ensure they're balanced
    if [ -f ~/.bashrc ]; then
        local start_count=$(grep -c "$BASHRC_MARKER_GENERIC_PATTERN" ~/.bashrc 2>/dev/null || echo "0")
        local end_count=$(grep -c "===== END:.*1453 WSL Setup =====" ~/.bashrc 2>/dev/null || echo "0")

        if [ "$start_count" -ne "$end_count" ]; then
            echo -e "${RED}[UYARI]${NC} .bashrc'de eşleşmeyen START/END marker'ları bulundu!"
            echo -e "${YELLOW}[BİLGİ]${NC} START marker'ları: $start_count, END marker'ları: $end_count"
            echo -e "${YELLOW}[BİLGİ]${NC} Elle kontrol etmeniz önerilir: ~/.bashrc"
            echo -e "${YELLOW}[!]${NC} Temizleme atlanıyor (güvenlik için)."
            return 1
        fi
    fi

    # Remove 1453 Setup related lines from .bashrc - SAFE CLEANUP
    if [ -f ~/.bashrc ]; then
        # Create a temp file for safe editing
        local temp_bashrc=$(mktemp)
        local in_1453_block=0
        local line_num=0

        while IFS= read -r line; do
            ((line_num++))
            local skip_line=0

            # Detect START of 1453 WSL Setup blocks
            # FIX BUG-017: Use constants instead of hardcoded magic strings
            if [[ "$line" =~ "$BASHRC_MARKER_FUNCTIONS_START" ]] || \
               [[ "$line" =~ "$BASHRC_MARKER_CONFIG_START" ]] || \
               [[ "$line" =~ $BASHRC_MARKER_GENERIC_PATTERN ]]; then
                in_1453_block=1
                skip_line=1
            fi

            # Detect END of 1453 WSL Setup blocks
            # FIX BUG-017: Use constants instead of hardcoded magic strings
            if [[ "$line" =~ "$BASHRC_MARKER_FUNCTIONS_END" ]] || \
               [[ "$line" =~ "$BASHRC_MARKER_CONFIG_END" ]] || \
               [[ "$line" =~ "===== END:".*"1453 WSL Setup =====" ]]; then
                in_1453_block=0
                skip_line=1
            fi

            # If in 1453 block, skip all lines
            if [ $in_1453_block -eq 1 ]; then
                skip_line=1
            fi

            # Skip specific lines we added (exact matches only)
            if [[ "$line" == *'eval "$(starship init bash)"'* ]] || \
               [[ "$line" == *'eval "$(zoxide init bash)"'* ]] || \
               [[ "$line" == 'export NVM_DIR="$HOME/.nvm"' ]] || \
               [[ "$line" == *'[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'* ]] || \
               [[ "$line" == *'[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'* ]] || \
               [[ "$line" == 'export BUN_INSTALL="$HOME/.bun"' ]] || \
               [[ "$line" == *'export PATH="$BUN_INSTALL/bin:$PATH"'* ]] || \
               [[ "$line" == *'export LS_COLORS="$(vivid generate'* ]] || \
               [[ "$line" == *'[ -f ~/.fzf.bash ] && source ~/.fzf.bash'* ]] || \
               [[ "$line" == *'source ~/.bash_aliases'* && "$line" == *'# 1453'* ]]; then
                skip_line=1
            fi

            # Keep the line if not skipping
            if [ $skip_line -eq 0 ]; then
                echo "$line" >> "$temp_bashrc"
            fi
        done < ~/.bashrc

        # Replace bashrc with cleaned version
        mv "$temp_bashrc" ~/.bashrc
        echo -e "${GREEN}[BAŞARILI]${NC} .bashrc güvenli bir şekilde temizlendi"
    fi

    # Remove starship config
    if [ -f ~/.config/starship.toml ]; then
        rm -f ~/.config/starship.toml
        echo -e "${GREEN}[BAŞARILI]${NC} Starship config silindi"
    fi

    # Remove fzf
    if [ -d ~/.fzf ]; then
        rm -rf ~/.fzf
        echo -e "${GREEN}[BAŞARILI]${NC} FZF dizini silindi"
    fi

    if [ -f ~/.fzf.bash ]; then
        rm -f ~/.fzf.bash
        echo -e "${GREEN}[BAŞARILI]${NC} FZF bash config silindi"
    fi

    echo -e "\n${YELLOW}[BİLGİ]${NC} Değişikliklerin aktif olması için:"
    echo -e "  ${CYAN}source ~/.bashrc${NC}"
    echo -e "  ${YELLOW}veya terminali yeniden başlatın${NC}"
    echo -e "\n${GREEN}[BAŞARILI]${NC} Shell config tamamen temizlendi"
}

# Cleanup AI CLI Tools
cleanup_ai_tools() {
    echo ""

    # Tools installed via native installers (curl | bash)
    # These are NOT installed via pipx, they use their own installers
    local native_tools=("claude" "qoder" "kiro")

    for tool in "${native_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            local tool_path
            tool_path=$(command -v "$tool")
            echo -e "${YELLOW}[BİLGİ]${NC} $tool kaldırılıyor (native installer)..."
            sudo rm -f "$tool_path" 2>/dev/null
            echo -e "${GREEN}[BAŞARILI]${NC} $tool kaldırıldı: $tool_path"
        fi
    done

    # Tools installed via pipx
    # Only gemini-cli, opencode, and qwen use pipx
    local pipx_tools=("gemini-cli" "opencode" "qwen")

    for tool in "${pipx_tools[@]}"; do
        if command -v pipx &>/dev/null && pipx list 2>/dev/null | grep -q "$tool"; then
            echo -e "${YELLOW}[BİLGİ]${NC} $tool kaldırılıyor (pipx)..."
            pipx uninstall "$tool" 2>/dev/null
            echo -e "${GREEN}[BAŞARILI]${NC} $tool kaldırıldı"
        fi
    done

    # GitHub Copilot CLI (installed via npm)
    if command -v copilot &>/dev/null || command -v github-copilot-cli &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} GitHub Copilot CLI kaldırılıyor (npm)..."
        npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} GitHub Copilot CLI kaldırıldı"
    fi

    # GitHub CLI (installed via APT)
    if command -v gh &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} GitHub CLI kaldırılıyor..."
        if [ "$PKG_MANAGER" = "apt" ]; then
            sudo apt remove -y gh 2>/dev/null
            # Remove GitHub CLI repository
            sudo rm -f /etc/apt/sources.list.d/github-cli.list
            sudo rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo -e "${GREEN}[BAŞARILI]${NC} GitHub CLI kaldırıldı"
        else
            sudo rm -f /usr/local/bin/gh
            echo -e "${GREEN}[BAŞARILI]${NC} GitHub CLI binary kaldırıldı"
        fi
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} AI CLI tools temizlendi"
}

# Cleanup AI Frameworks
cleanup_ai_frameworks() {
    echo ""

    # Use existing cleanup functions from ai-frameworks.sh
    if declare -f remove_supergemini &>/dev/null; then
        remove_supergemini
    fi

    if declare -f remove_superqwen &>/dev/null; then
        remove_superqwen
    fi

    if declare -f remove_superclaude &>/dev/null; then
        remove_superclaude
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} AI frameworks temizlendi"
}

# Cleanup Docker
cleanup_docker() {
    echo ""

    # Check if Docker is installed
    if ! command -v docker &>/dev/null && [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        echo -e "${CYAN}[BİLGİ]${NC} Docker kurulu değil, temizleme atlanıyor..."
        return 0
    fi

    # Remove Docker APT packages
    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Docker paketleri kaldırılıyor..."
        sudo apt remove -y \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin \
            docker-compose 2>/dev/null
        sudo apt autoremove -y 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Docker paketleri kaldırıldı"
    fi

    # Remove Docker repository
    if [ -f /etc/apt/sources.list.d/docker.list ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Docker repository kaldırılıyor..."
        sudo rm -f /etc/apt/sources.list.d/docker.list
        echo -e "${GREEN}[BAŞARILI]${NC} Docker repository kaldırıldı"
    fi

    # Remove Docker GPG key
    if [ -f /etc/apt/keyrings/docker.gpg ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Docker GPG anahtarı kaldırılıyor..."
        sudo rm -f /etc/apt/keyrings/docker.gpg
        echo -e "${GREEN}[BAŞARILI]${NC} Docker GPG anahtarı kaldırıldı"
    fi

    # Remove user from docker group
    if id -nG "$USER" | grep -qw docker; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kullanıcı docker grubundan çıkarılıyor..."
        sudo deluser "$USER" docker 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Docker grup üyeliği kaldırıldı"
    fi

    # Remove lazydocker
    if [ -f /usr/local/bin/lazydocker ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} lazydocker kaldırılıyor..."
        sudo rm -f /usr/local/bin/lazydocker
        echo -e "${GREEN}[BAŞARILI]${NC} lazydocker kaldırıldı"
    fi

    # Ask about Docker data
    echo ""
    echo -e "${YELLOW}[!]${NC} Docker imajları ve volume'leri de silinsin mi?"
    echo -e "${YELLOW}[!]${NC} Bu işlem GERİ ALINAMAZ! Tüm container, image, volume, network silinecek."
    echo -ne "${YELLOW}Docker verilerini de sil? (e/h): ${NC}"

    # Check if running in interactive mode
    if [ -t 0 ]; then
        read -r delete_data </dev/tty
    else
        # Default to 'no' in non-interactive mode (CI/CD, scripts)
        delete_data="h"
        echo -e "\n${CYAN}[BİLGİ]${NC} Non-interactive mod: Docker verileri korunuyor"
    fi

    if [[ "$delete_data" =~ ^[Ee]$ ]]; then
        echo -e "${RED}[UYARI]${NC} Docker verileri siliniyor..."
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
        echo -e "${GREEN}[BAŞARILI]${NC} Docker verileri silindi"
    else
        echo -e "${CYAN}[BİLGİ]${NC} Docker verileri korundu (/var/lib/docker)"
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} Docker temizlendi"
    echo -e "${YELLOW}[!]${NC} Değişikliklerin tam aktif olması için terminali yeniden başlatın"
}

# Cleanup all installations (keep configs)
cleanup_installations() {
    echo ""
    echo -e "${RED}🗑️  TÜM KURULUMLAR TEMİZLENİYOR${NC}"
    echo ""

    if ! confirm_cleanup "Tüm kurulumlar (Sistem paketleri, Python, Node, PHP, Go, Docker, Modern Tools, AI Tools)"; then
        return 1
    fi

    cleanup_system_packages
    cleanup_python
    cleanup_nodejs
    cleanup_php
    cleanup_go
    cleanup_docker
    cleanup_modern_tools
    cleanup_ai_tools
    cleanup_ai_frameworks

    echo -e "\n${GREEN}[BAŞARILI]${NC} Tüm kurulumlar temizlendi (Config dosyaları korundu)"
}

# Full reset (white flag)
cleanup_full_reset() {
    clear
    echo ""
    echo -e "${RED}🔴 TAM SIFIRLAMA - WSL'i İLK HALİNE GETİR${NC}"
    echo ""

    echo -e "${RED}⚠️  UYARI: Bu işlem GERİ ALINAMAZ!${NC}\n"
    echo -e "${YELLOW}Silinecekler:${NC}"
    echo -e "  • ${RED}Tüm kurulumlar${NC} (Python, Node, PHP, Go, Docker, etc.)"
    echo -e "  • ${RED}Tüm modern CLI tools${NC} (bat, eza, starship, zoxide, fzf, etc.)"
    echo -e "  • ${RED}Shell config değişiklikleri${NC} (.bashrc, .bash_aliases)"
    echo -e "  • ${RED}AI tools ve frameworks${NC}"
    echo -e "  • ${RED}Kurulum dizini${NC} (~/.1453-wsl-setup)"
    echo -e "  • ${RED}Kaynak kod dizini${NC} (~/1453-wsl-bash-script - eğer varsa)"
    echo -e "  • ${RED}Config dosyaları${NC} (starship, fzf, zoxide)"
    echo ""
    echo -e "${YELLOW}WSL ilk kurulduğu haline gelecek!${NC}"
    echo ""

    if ! confirm_cleanup "HER ŞEY (WSL İLK HALİNE GELECEK)"; then
        return 1
    fi

    # Cleanup everything - AGGRESSIVE MODE
    cleanup_system_packages
    cleanup_python
    cleanup_nodejs
    cleanup_php
    cleanup_go
    cleanup_docker
    cleanup_modern_tools
    cleanup_shell_configs  # Now much more aggressive
    cleanup_ai_tools
    cleanup_ai_frameworks

    # Remove installation directory
    if [ -d ~/.1453-wsl-setup ]; then
        echo -e "\n${YELLOW}[BİLGİ]${NC} Kurulum dizini kaldırılıyor..."
        rm -rf ~/.1453-wsl-setup
        echo -e "${GREEN}[BAŞARILI]${NC} Kurulum dizini kaldırıldı"
    fi

    # Remove source code directory if exists
    echo -e "\n${YELLOW}[BİLGİ]${NC} Kaynak kod dizini kontrol ediliyor..."
    local source_dirs=(
        "$HOME/1453-wsl-bash-script"
        "$HOME/Downloads/1453-wsl-bash-script"
        "$HOME/projects/1453-wsl-bash-script"
    )

    for dir in "${source_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${YELLOW}[BİLGİ]${NC} Kaynak kod dizini bulundu: $dir"
            echo -ne "${RED}Bu dizini de silmek ister misiniz? (e/h): ${NC}"
            read -r remove_source </dev/tty
            if [[ "$remove_source" =~ ^[Ee]$ ]]; then
                rm -rf "$dir"
                echo -e "${GREEN}[BAŞARILI]${NC} Kaynak kod dizini silindi: $dir"
            else
                echo -e "${CYAN}[BİLGİ]${NC} Kaynak kod dizini korundu: $dir"
            fi
        fi
    done

    # Force reload shell to default state
    echo -e "\n${YELLOW}[BİLGİ]${NC} Shell sıfırlanıyor..."
    if [ -f ~/.bashrc ]; then
        # Source the cleaned bashrc
        source ~/.bashrc 2>/dev/null || true
    fi

    echo ""
    echo -e "${GREEN}✅ TAM SIFIRLAMA TAMAMLANDI${NC}"
    echo ""
    echo -e "${CYAN}[BİLGİ]${NC} WSL ilk kurulum haline getirildi."
    echo -e "${YELLOW}[ÖNEMLİ]${NC} Değişikliklerin tam aktif olması için:"
    echo -e "  ${RED}1. Tüm terminal pencerelerini kapatın${NC}"
    echo -e "  ${RED}2. WSL'i yeniden başlatın: ${CYAN}wsl --shutdown${NC}"
    echo -e "  ${RED}3. Yeni terminal açın${NC}"
    echo ""
    echo -e "${CYAN}[BİLGİ]${NC} Script'i tekrar çalıştırarak yeniden kurulum yapabilirsiniz."
}

# Individual cleanup menu
show_individual_cleanup_menu() {
    if has_gum; then
        # Modern Gum menu
        echo ""
        gum_style --foreground 226 --bold "📦 Tek Tek Temizleme Menüsü"
        echo ""

        local selection
        selection=$(gum_choose \
            "🔧 Sistem Paketleri (jq, zip, build-essential)" \
            "🐍 Python (python3, pip, pipx, uv)" \
            "📦 Node.js (nvm, node, npm, bun)" \
            "🐘 PHP (php, composer)" \
            "🐹 Go" \
            "🐳 Docker (docker-ce, lazydocker)" \
            "✨ Modern CLI Tools (bat, eza, starship)" \
            "🎨 Shell Config (.bashrc, aliases)" \
            "🤖 AI CLI Tools" \
            "🧠 AI Frameworks" \
            "◀ Geri")

        case "$selection" in
            *"Sistem Paketleri"*)
                if confirm_cleanup "Sistem paketleri"; then
                    cleanup_system_packages
                fi
                ;;
            *"Python"*)
                if confirm_cleanup "Python ekosistemi"; then
                    cleanup_python
                fi
                ;;
            *"Node.js"*)
                if confirm_cleanup "Node.js ekosistemi"; then
                    cleanup_nodejs
                fi
                ;;
            *"PHP"*)
                if confirm_cleanup "PHP ekosistemi"; then
                    cleanup_php
                fi
                ;;
            *"Go"*)
                if confirm_cleanup "Go"; then
                    cleanup_go
                fi
                ;;
            *"Docker"*)
                if confirm_cleanup "Docker"; then
                    cleanup_docker
                fi
                ;;
            *"Modern CLI Tools"*)
                if confirm_cleanup "Modern CLI Tools"; then
                    cleanup_modern_tools
                fi
                ;;
            *"Shell Config"*)
                if confirm_cleanup "Shell Config"; then
                    cleanup_shell_configs
                fi
                ;;
            *"AI CLI Tools"*)
                if confirm_cleanup "AI CLI Tools"; then
                    cleanup_ai_tools
                fi
                ;;
            *"AI Frameworks"*)
                if confirm_cleanup "AI Frameworks"; then
                    cleanup_ai_frameworks
                fi
                ;;
            *"Geri"*|"") return ;;
        esac
    else
        # Fallback: Traditional menu
        while true; do
            clear
    echo ""
            echo -e "  ${GREEN}1${NC}) Sistem Paketleri (jq, zip, unzip, build-essential)"
            echo -e "  ${GREEN}2${NC}) Python (python3, pip, pipx, uv)"
            echo -e "  ${GREEN}3${NC}) Node.js (nvm, node, npm, bun)"
            echo -e "  ${GREEN}4${NC}) PHP (php, composer)"
            echo -e "  ${GREEN}5${NC}) Go"
            echo -e "  ${GREEN}6${NC}) Docker (docker-ce, lazydocker)"
            echo -e "  ${GREEN}7${NC}) Modern CLI Tools (bat, eza, starship, etc.)"
            echo -e "  ${GREEN}8${NC}) Shell Config (.bashrc, .bash_aliases, starship)"
            echo -e "  ${GREEN}9${NC}) AI CLI Tools"
            echo -e "  ${GREEN}10${NC}) AI Frameworks"
            echo -e "  ${GREEN}0${NC}) ← Geri"
            echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

            echo -ne "\n${YELLOW}Seçiminiz (0-10): ${NC}"
            read -r choice </dev/tty

            case $choice in
                1)
                    if confirm_cleanup "Sistem paketleri"; then
                        cleanup_system_packages
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                2)
                    if confirm_cleanup "Python ekosistemi"; then
                        cleanup_python
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                3)
                    if confirm_cleanup "Node.js ekosistemi"; then
                        cleanup_nodejs
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                4)
                    if confirm_cleanup "PHP ekosistemi"; then
                        cleanup_php
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                5)
                    if confirm_cleanup "Go"; then
                        cleanup_go
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                6)
                    if confirm_cleanup "Docker"; then
                        cleanup_docker
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                7)
                    if confirm_cleanup "Modern CLI Tools"; then
                        cleanup_modern_tools
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                8)
                    if confirm_cleanup "Shell Config"; then
                        cleanup_shell_configs
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                9)
                    if confirm_cleanup "AI CLI Tools"; then
                        cleanup_ai_tools
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                10)
                    if confirm_cleanup "AI Frameworks"; then
                        cleanup_ai_frameworks
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                0)
                    break
                    ;;
                *)
                    echo -e "${RED}[HATA]${NC} Geçersiz seçim!"
                    sleep 1
                    ;;
            esac
        done
    fi
}

# Main cleanup menu
show_cleanup_menu() {
    if has_gum; then
        # Modern Gum menu
        echo ""
        gum_style --foreground 196 --bold "🗑️  TEMİZLEME VE SIFIRLAMA MENÜSÜ"
        echo ""

        local selection
        selection=$(gum_choose \
            "🔴 TAM SIFIRLAMA (Beyaz Bayrak) - ⚠️  TEHLİKELİ" \
            "🧹 Kurulumları Temizle (Config korunur)" \
            "📦 Tek Tek Temizle" \
            "⚙️  Sadece Config Temizle (Kurulumlar korunur)" \
            "━━━━━━━━━━━━━━━━━━━━━" \
            "📊 Kurulu Olanları Göster" \
            "◀ Ana Menüye Dön")

        case "$selection" in
            *"TAM SIFIRLAMA"*)
                echo ""
                gum_style --foreground 196 --border rounded --padding "1 2" \
                    "⚠️  UYARI: TÜM KURULUMLAR VE AYARLAR SİLİNECEK!" \
                    "Bu işlem geri alınamaz!"
                echo ""
                if gum_confirm "Devam etmek istediğinizden emin misiniz?"; then
                    cleanup_full_reset
                fi
                ;;
            *"Kurulumları Temizle"*)
                cleanup_installations
                ;;
            *"Tek Tek Temizle"*)
                show_individual_cleanup_menu
                ;;
            *"Config Temizle"*)
                if confirm_cleanup "Shell Config dosyaları"; then
                    cleanup_shell_configs
                fi
                ;;
            *"Kurulu Olanları"*)
                show_installed_items
                ;;
            *"Ana Menüye Dön"*|"") return ;;
            "━"*) return ;; # Separator
        esac
    else
        # Fallback: Traditional menu
        while true; do
            clear
    echo ""
            echo ""
            echo -e "  ${RED}1${NC}) ${RED}🔴 TAM SIFIRLAMA (Beyaz Bayrak)${NC}"
            echo -e "     ${YELLOW}Her şeyi sil, temiz kurulum için hazırla${NC}"
            echo -e "     ${RED}⚠️  UYARI: Tüm kurulumlar ve ayarlar silinecek!${NC}"
            echo ""
            echo -e "  ${GREEN}2${NC}) ${YELLOW}🧹 KURULUMARI TEMİZLE${NC}"
            echo -e "     ${CYAN}Python, Node, PHP, Go, AI tools'ları kaldır${NC}"
            echo -e "     ${CYAN}Config dosyaları korunur${NC}"
            echo ""
            echo -e "  ${GREEN}3${NC}) ${YELLOW}📦 TEK TEK TEMİZLE${NC}"
            echo -e "     ${CYAN}İstediğin bileşeni seç ve temizle${NC}"
            echo ""
            echo -e "  ${GREEN}4${NC}) ${YELLOW}⚙️  SADECE CONFIG TEMİZLE${NC}"
            echo -e "     ${CYAN}.bashrc, .bash_aliases, starship config temizle${NC}"
            echo -e "     ${CYAN}Kurulumlar korunur${NC}"
            echo ""
            echo -e "  ${GREEN}5${NC}) ${CYAN}📊 KURULU OLANLAR${NC}"
            echo -e "     ${CYAN}Şu anda nelerin kurulu olduğunu göster${NC}"
            echo ""
            echo -e "  ${GREEN}0${NC}) ← Ana Menüye Dön"
            echo ""
            echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

            echo -ne "\n${YELLOW}Seçiminiz (0-5): ${NC}"
            read -r choice </dev/tty

            case $choice in
                1)
                    cleanup_full_reset
                    read -p "Devam etmek için Enter'a basın..."
                    ;;
                2)
                    cleanup_installations
                    read -p "Devam etmek için Enter'a basın..."
                    ;;
                3)
                    show_individual_cleanup_menu
                    ;;
                4)
                    if confirm_cleanup "Shell Config dosyaları"; then
                        cleanup_shell_configs
                        read -p "Devam etmek için Enter'a basın..."
                    fi
                    ;;
                5)
                    show_installed_items
                    read -p "Devam etmek için Enter'a basın..."
                    ;;
                0)
                    break
                    ;;
                *)
                    echo -e "${RED}[HATA]${NC} Geçersiz seçim!"
                    sleep 1
                    ;;
            esac
        done
    fi
}

# Export functions
export -f backup_configs
export -f cleanup_old_backups
export -f confirm_cleanup
export -f show_installed_items
export -f cleanup_system_packages
export -f cleanup_python
export -f cleanup_nodejs
export -f cleanup_php
export -f cleanup_go
export -f cleanup_docker
export -f cleanup_modern_tools
export -f cleanup_shell_configs
export -f cleanup_ai_tools
export -f cleanup_ai_frameworks
export -f cleanup_installations
export -f cleanup_full_reset
export -f show_individual_cleanup_menu
export -f show_cleanup_menu
