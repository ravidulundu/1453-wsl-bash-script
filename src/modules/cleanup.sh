#!/bin/bash
# Module: Cleanup and Reset
# Description: Cleanup installations, configs, and reset system
# Dependencies: All other modules

# Backup configurations before cleanup
backup_configs() {
    local backup_dir="$HOME/.1453-backup-$(date +%Y%m%d_%H%M%S)"
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
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  KURULU BİLEŞENLER                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
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
    echo -e "${CYAN}[Modern CLI Tools]${NC}"
    local tools=("bat" "eza" "starship" "zoxide" "vivid" "fastfetch" "lazygit" "lazydocker")
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

# Cleanup Python ecosystem
cleanup_python() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Python Ekosistemi Temizleniyor     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    # pipx packages
    if command -v pipx &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} pipx paketleri kaldırılıyor..."
        pipx uninstall-all 2>/dev/null
        rm -rf ~/.local/pipx
        echo -e "${GREEN}[BAŞARILI]${NC} pipx paketleri kaldırıldı"
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

    echo -e "\n${YELLOW}[BİLGİ]${NC} Python3 sistem paketi olabilir, manuel kaldırma:"
    echo -e "  ${CYAN}sudo apt remove python3-pip${NC}"
    echo -e "\n${GREEN}[BAŞARILI]${NC} Python ekosistemi temizlendi"
}

# Cleanup Node.js and NVM
cleanup_nodejs() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Node.js Ekosistemi Temizleniyor   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    # NVM
    if [ -d "$HOME/.nvm" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} NVM kaldırılıyor..."
        rm -rf ~/.nvm

        # Remove NVM from shell configs
        sed -i '/NVM_DIR/d' ~/.bashrc 2>/dev/null
        sed -i '/nvm.sh/d' ~/.bashrc 2>/dev/null
        sed -i '/bash_completion/d' ~/.bashrc 2>/dev/null

        echo -e "${GREEN}[BAŞARILI]${NC} NVM kaldırıldı"
    fi

    # Bun
    if command -v bun &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Bun kaldırılıyor..."
        rm -rf ~/.bun
        sed -i '/BUN_INSTALL/d' ~/.bashrc 2>/dev/null
        echo -e "${GREEN}[BAŞARILI]${NC} Bun kaldırıldı"
    fi

    echo -e "\n${GREEN}[BAŞARILI]${NC} Node.js ekosistemi temizlendi"
}

# Cleanup PHP and Composer
cleanup_php() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       PHP Ekosistemi Temizleniyor      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    # Composer
    if command -v composer &>/dev/null; then
        echo -e "${YELLOW}[BİLGİ]${NC} Composer kaldırılıyor..."
        sudo rm -f /usr/local/bin/composer
        rm -rf ~/.composer
        echo -e "${GREEN}[BAŞARILI]${NC} Composer kaldırıldı"
    fi

    echo -e "\n${YELLOW}[BİLGİ]${NC} PHP sürümlerini kaldırmak için:"
    echo -e "  ${CYAN}sudo apt remove php*${NC}"
    echo -e "\n${GREEN}[BAŞARILI]${NC} PHP ekosistemi temizlendi"
}

# Cleanup Go
cleanup_go() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Go Temizleniyor               ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    if [ -d "/usr/local/go" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Go kaldırılıyor..."
        sudo rm -rf /usr/local/go

        # Remove from PATH
        sed -i '/\/usr\/local\/go\/bin/d' ~/.bashrc 2>/dev/null
        sed -i '/GOPATH/d' ~/.bashrc 2>/dev/null

        echo -e "${GREEN}[BAŞARILI]${NC} Go kaldırıldı"
    else
        echo -e "${CYAN}[BİLGİ]${NC} Go kurulu değil"
    fi
}

# Cleanup Modern CLI Tools
cleanup_modern_tools() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Modern CLI Tools Temizleniyor       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    echo -e "${CYAN}[BİLGİ]${NC} Sadece 1453 WSL Setup'ın kurduğu araçlar kaldırılacak"
    echo -e "${CYAN}[BİLGİ]${NC} APT paket yöneticisinden kurulan araçlar korunacak"
    echo ""

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

    # Lazydocker (manual install via GitHub)
    if [ -f /usr/local/bin/lazydocker ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Lazydocker kaldırılıyor..."
        sudo rm -f /usr/local/bin/lazydocker
        echo -e "${GREEN}[BAŞARILI]${NC} Lazydocker kaldırıldı"
    fi

    # Clean up symlinks created by this script
    echo -e "${YELLOW}[BİLGİ]${NC} Script symlink'leri temizleniyor..."
    if [ -L ~/.local/bin/bat ]; then
        rm -f ~/.local/bin/bat
        echo -e "${GREEN}[BAŞARILI]${NC} bat symlink kaldırıldı"
    fi
    if [ -L ~/.local/bin/fd ]; then
        rm -f ~/.local/bin/fd
        echo -e "${GREEN}[BAŞARILI]${NC} fd symlink kaldırıldı"
    fi

    echo ""
    echo -e "${CYAN}[BİLGİ]${NC} ${YELLOW}NOT:${NC} APT paketleri (bat, ripgrep, fd-find, fzf) korundu"
    echo -e "${CYAN}[BİLGİ]${NC} Bu paketler script öncesinde de kurulu olmuş olabilir"
    echo -e "${CYAN}[BİLGİ]${NC} Manuel silmek için: ${YELLOW}sudo apt remove bat ripgrep fd-find fzf${NC}"
    echo ""
    echo -e "${GREEN}[BAŞARILI]${NC} 1453 WSL Setup'ın kurduğu modern tools kaldırıldı"
}

# Cleanup Shell Configs
cleanup_shell_configs() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Shell Config Temizleniyor          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    # Backup first
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}[BAŞARILI]${NC} .bashrc yedeklendi"
    fi

    # Remove .bash_aliases completely
    if [ -f ~/.bash_aliases ]; then
        rm -f ~/.bash_aliases
        echo -e "${GREEN}[BAŞARILI]${NC} .bash_aliases silindi"
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

            # Skip 1453 WSL Setup comment blocks
            if [[ "$line" =~ "# Custom Functions - 1453 WSL Setup" ]] || \
               [[ "$line" =~ "# Enhanced Bash Config - 1453 WSL Setup" ]] || \
               [[ "$line" =~ "# 1453 WSL Setup" ]]; then
                in_1453_block=1
                skip_line=1
            fi

            # If in 1453 block, skip until empty line
            if [ $in_1453_block -eq 1 ]; then
                skip_line=1
                if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
                    in_1453_block=0
                fi
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
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      AI CLI Tools Temizleniyor         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

    local tools=("claude" "qoder" "gh")

    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "${YELLOW}[BİLGİ]${NC} $tool kaldırılıyor..."

            # Remove from pipx if installed via pipx
            if pipx list 2>/dev/null | grep -q "$tool"; then
                pipx uninstall "$tool"
            else
                sudo rm -f "/usr/local/bin/$tool"
                rm -f "$HOME/.local/bin/$tool"
            fi

            echo -e "${GREEN}[BAŞARILI]${NC} $tool kaldırıldı"
        fi
    done

    echo -e "\n${GREEN}[BAŞARILI]${NC} AI CLI tools temizlendi"
}

# Cleanup AI Frameworks
cleanup_ai_frameworks() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     AI Frameworks Temizleniyor         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

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

# Cleanup all installations (keep configs)
cleanup_installations() {
    echo -e "\n${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              TÜM KURULUMLAR TEMİZLENİYOR                    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}\n"

    if ! confirm_cleanup "Tüm kurulumlar (Python, Node, PHP, Go, Modern Tools, AI Tools)"; then
        return 1
    fi

    cleanup_python
    cleanup_nodejs
    cleanup_php
    cleanup_go
    cleanup_modern_tools
    cleanup_ai_tools
    cleanup_ai_frameworks

    echo -e "\n${GREEN}[BAŞARILI]${NC} Tüm kurulumlar temizlendi (Config dosyaları korundu)"
}

# Full reset (white flag)
cleanup_full_reset() {
    clear
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                  🔴 TAM SIFIRLAMA 🔴                         ║${NC}"
    echo -e "${RED}║              WSL'i İLK HALİNE GETİR                          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}\n"

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
    cleanup_python
    cleanup_nodejs
    cleanup_php
    cleanup_go
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

    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  ✅ TAM SIFIRLAMA TAMAMLANDI                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
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
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║              TEK TEK TEMİZLEME MENÜSÜ                       ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "  ${GREEN}1${NC}) Python (python3, pip, pipx, uv)"
        echo -e "  ${GREEN}2${NC}) Node.js (nvm, node, npm, bun)"
        echo -e "  ${GREEN}3${NC}) PHP (php, composer)"
        echo -e "  ${GREEN}4${NC}) Go"
        echo -e "  ${GREEN}5${NC}) Modern CLI Tools (bat, eza, starship, etc.)"
        echo -e "  ${GREEN}6${NC}) Shell Config (.bashrc, .bash_aliases, starship)"
        echo -e "  ${GREEN}7${NC}) AI CLI Tools"
        echo -e "  ${GREEN}8${NC}) AI Frameworks"
        echo -e "  ${GREEN}0${NC}) ← Geri"
        echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

        echo -ne "\n${YELLOW}Seçiminiz (0-8): ${NC}"
        read -r choice </dev/tty

        case $choice in
            1)
                if confirm_cleanup "Python ekosistemi"; then
                    cleanup_python
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            2)
                if confirm_cleanup "Node.js ekosistemi"; then
                    cleanup_nodejs
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            3)
                if confirm_cleanup "PHP ekosistemi"; then
                    cleanup_php
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            4)
                if confirm_cleanup "Go"; then
                    cleanup_go
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            5)
                if confirm_cleanup "Modern CLI Tools"; then
                    cleanup_modern_tools
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            6)
                if confirm_cleanup "Shell Config"; then
                    cleanup_shell_configs
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            7)
                if confirm_cleanup "AI CLI Tools"; then
                    cleanup_ai_tools
                    read -p "Devam etmek için Enter'a basın..."
                fi
                ;;
            8)
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
}

# Main cleanup menu
show_cleanup_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           🗑️  TEMİZLEME VE SIFIRLAMA MENÜSÜ               ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
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
}

# Export functions
export -f backup_configs
export -f confirm_cleanup
export -f show_installed_items
export -f cleanup_python
export -f cleanup_nodejs
export -f cleanup_php
export -f cleanup_go
export -f cleanup_modern_tools
export -f cleanup_shell_configs
export -f cleanup_ai_tools
export -f cleanup_ai_frameworks
export -f cleanup_installations
export -f cleanup_full_reset
export -f show_individual_cleanup_menu
export -f show_cleanup_menu
