#!/bin/bash
# Module: Docker Installation
# Description: Install Docker Engine and related tools
# Dependencies: common.sh, package-manager.sh

# Install Docker Engine
# Install Docker Engine
install_docker_engine() {
    echo ""
    echo -e "${YELLOW}Docker Engine Kurulumu${NC}"
    echo ""

    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}[BİLGİ]${NC} Docker Engine zaten kurulu."
        docker --version
        return 0
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Docker Engine kuruluyor..."

    # WSL Check
    if grep -q "microsoft" /proc/version; then
        echo -e "${YELLOW}[BİLGİ]${NC} WSL ortamı tespit edildi."
        echo -e "${CYAN}[BİLGİ]${NC} Native Docker Engine kurulumu yapılıyor (Docker Desktop yerine)."
    fi

    # Update package index
    sudo apt-get update

    # Install prerequisites
    echo -e "${CYAN}[BİLGİ]${NC} Gerekli paketler kuruluyor..."
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    # FIX BUG-006: Verify GPG key fingerprint before installing
    echo -e "${CYAN}[BİLGİ]${NC} Docker GPG anahtarı ekleniyor..."
    sudo mkdir -p /etc/apt/keyrings

    # Download GPG key to temp file for verification
    local temp_gpg_key
    temp_gpg_key=$(mktemp)

    if curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$temp_gpg_key"; then
        # Docker's official GPG key fingerprint (as of 2024)
        local expected_fingerprint="9DC858229FC7DD38854AE2D88D81803C0EBFCD88"

        # Verify fingerprint
        local actual_fingerprint
        actual_fingerprint=$(gpg --with-fingerprint --with-colons "$temp_gpg_key" 2>/dev/null | grep '^fpr' | head -n1 | cut -d: -f10 | tr -d ' ')

        if [ -n "$actual_fingerprint" ] && [ "$actual_fingerprint" = "$expected_fingerprint" ]; then
            echo -e "${GREEN}[[+]]${NC} GPG anahtarı doğrulandı."
            sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg < "$temp_gpg_key"
        else
            echo -e "${RED}[[-]]${NC} GPG anahtarı doğrulanamadı!"
            echo -e "${YELLOW}[UYARI]${NC} Güvenlik nedeniyle kurulum devam ediyor ama GPG doğrulaması başarısız!"
            sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg < "$temp_gpg_key"
        fi
        rm -f "$temp_gpg_key"
    else
        echo -e "${RED}[HATA]${NC} GPG anahtarı indirilemedi!"
        return 1
    fi

    # Set up the repository
    echo -e "${CYAN}[BİLGİ]${NC} Docker repository ayarlanıyor..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package index again
    sudo apt-get update

    # Install Docker Engine
    echo -e "${CYAN}[BİLGİ]${NC} Docker Engine kuruluyor..."
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # Add current user to docker group
    echo -e "${CYAN}[BİLGİ]${NC} Kullanıcı docker grubuna ekleniyor..."
    sudo usermod -aG docker $USER

    # Start Docker service
    echo -e "${CYAN}[BİLGİ]${NC} Docker servisi başlatılıyor..."
    if command -v systemctl &> /dev/null; then
        sudo systemctl start docker || sudo service docker start
        sudo systemctl enable docker 2>/dev/null
    else
        sudo service docker start
    fi
    
    # WSL: Add Docker auto-start to bashrc
    if grep -q "microsoft" /proc/version; then
        if ! grep -q "service docker start" ~/.bashrc 2>/dev/null; then
            echo -e "${CYAN}[BİLGİ]${NC} WSL için Docker otomatik başlatma ekleniyor..."
            cat >> ~/.bashrc << 'DOCKER_AUTOSTART'

# Docker auto-start for WSL
if ! pgrep -x dockerd > /dev/null 2>&1; then
    sudo service docker start > /dev/null 2>&1
fi
DOCKER_AUTOSTART
            echo -e "${GREEN}[+]${NC} Docker bir sonraki terminal açılışında otomatik başlayacak"
        fi
    fi

    # Verify installation
    if command -v docker &> /dev/null; then
        echo -e "\n${GREEN}[BAŞARILI]${NC} Docker Engine kurulumu tamamlandı!"
        docker --version

        # Check daemon status
        if ! docker info &> /dev/null; then
            echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}⚠️  ÖNEMLİ: Docker Permission Ayarı Gerekli!${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "\n${CYAN}Docker çalışıyor ama yetki ayarı gerekiyor.${NC}"
            echo -e "\n${GREEN}Şunları yapmanız gerekiyor:${NC}"
            echo -e "\n${YELLOW}1️⃣  Docker daemon'ı başlatın:${NC}"
            echo -e "   ${CYAN}sudo service docker start${NC}"
            echo -e "\n${YELLOW}2️⃣  Yeni grup yetkilerini aktifleştirin (iki yöntemden birini):${NC}"
            echo -e "   ${GREEN}A)${NC} Terminal'i kapatıp yeniden açın (önerilen)"
            echo -e "   ${GREEN}B)${NC} Şu komutu çalıştırın: ${CYAN}newgrp docker${NC}"
            echo -e "\n${YELLOW}3️⃣  Test edin:${NC}"
            echo -e "   ${CYAN}docker ps${NC}"
            
            if grep -q "microsoft" /proc/version; then
                echo -e "\n${CYAN}💡 WSL İpucu: Docker'ın otomatik başlaması için:${NC}"
                echo -e "   ${GREEN}echo 'sudo service docker start 2>/dev/null' >> ~/.bashrc${NC}"
            fi
            
            echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        else
            echo -e "${GREEN}[+]${NC} Docker Daemon çalışıyor."
        fi
    else
        echo -e "${RED}[HATA]${NC} Docker Engine kurulumu başarısız!"
        return 1
    fi
}

# Install Docker Compose (standalone - if needed)
install_docker_compose() {
    echo ""
    echo -e "${YELLOW}Docker Compose Kurulumu${NC}"
    echo ""

    # Check if docker compose plugin is available
    if docker compose version &> /dev/null; then
        echo -e "${GREEN}[BİLGİ]${NC} Docker Compose (plugin) zaten kurulu."
        docker compose version
        return 0
    fi

    echo -e "${CYAN}[BİLGİ]${NC} Docker Compose plugin Docker Engine ile birlikte gelir."
    echo -e "${YELLOW}[BİLGİ]${NC} Önce Docker Engine kurun."
}

# Install lazydocker
install_lazydocker_tool() {
    echo ""
    echo -e "${YELLOW}lazydocker Kurulumu${NC}"
    echo ""

    # Check if already installed
    if command -v lazydocker &> /dev/null; then
        echo -e "${GREEN}[BİLGİ]${NC} lazydocker zaten kurulu."
        lazydocker --version
        return 0
    fi

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}[UYARI]${NC} Docker Engine kurulu değil!"
        echo -e "${CYAN}[BİLGİ]${NC} lazydocker çalışması için Docker Engine gereklidir."
        install_docker=$(gum_input --placeholder "Önce Docker Engine kurmak ister misiniz? (e/h)")

        if [[ "$install_docker" =~ ^[Ee]$ ]]; then
            install_docker_engine
        else
            echo -e "${CYAN}[BİLGİ]${NC} lazydocker kurulumu atlandı."
            return 0
        fi
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} lazydocker kuruluyor..."

    # Initialize versions if not already done (using centralized version from config/tool-versions.sh)
    if [ -z "$LAZYDOCKER_VERSION" ]; then
        init_tool_versions
    fi

    echo -e "${CYAN}[BİLGİ]${NC} Version: $LAZYDOCKER_VERSION"

    local lazydocker_tarball="lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    local lazydocker_url="https://github.com/jesseduffield/lazydocker/releases/latest/download/${lazydocker_tarball}"
    local lazydocker_checksum_url="https://github.com/jesseduffield/lazydocker/releases/latest/download/checksums.txt"

    # Download with checksum verification
    if download_with_checksum "$lazydocker_url" "/tmp/lazydocker.tar.gz" "$lazydocker_checksum_url"; then
        tar xzf /tmp/lazydocker.tar.gz -C /tmp
        sudo mv /tmp/lazydocker /usr/local/bin/
        sudo chmod +x /usr/local/bin/lazydocker
        rm -f /tmp/lazydocker.tar.gz
    else
        echo -e "${RED}[[-]]${NC} Lazydocker kurulumu başarısız! (checksum doğrulanamadı)"
        rm -f /tmp/lazydocker.tar.gz
        return 1
    fi

    # Verify installation
    if command -v lazydocker &> /dev/null; then
        echo -e "${GREEN}[BAŞARILI]${NC} lazydocker kuruldu!"
        lazydocker --version
    else
        echo -e "${RED}[HATA]${NC} lazydocker kurulumu başarısız!"
        return 1
    fi
}

# Docker installation menu
install_docker_menu() {
    echo ""
    gum_style --foreground 39 --bold "🐳 Docker Kurulum Menüsü"
    echo ""

    local selection
    selection=$(gum_choose \
        "🐳 Docker Engine Kurulumu (Önerilen)" \
        "📊 lazydocker Kurulumu (Terminal UI)" \
        "━━━━━━━━━━━━━━━━━━━━━" \
        "[PACKAGE] Tümünü Kur (Engine + lazydocker)" \
        "< Ana menüye dön")

    case "$selection" in
        *"Docker Engine"*) install_docker_engine ;;
        *"lazydocker"*) install_lazydocker_tool ;;
        *"Tümünü Kur"*)
            install_docker_engine
            install_lazydocker_tool
            ;;
        *"Ana menüye dön"*|"") return ;;
        "━"*) return ;; # Separator
    esac
}

# Export functions
export -f install_docker_engine
export -f install_docker_compose
export -f install_lazydocker_tool
export -f install_docker_menu
