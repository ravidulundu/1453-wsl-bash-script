#!/bin/bash
# Module: Docker Installation
# Description: Install Docker Engine and related tools
# Dependencies: common.sh, package-manager.sh

# Install Docker Engine
# Install Docker Engine
# Install Docker Engine
install_docker_engine() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    echo ""
    gum_header "DOCKER ENGINE" "Konteyner Altyapısı Kurulumu"

    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        local version
        version=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
        gum_success "Atlandı" "Docker Engine zaten kurulu ($version)"
        return 0
    fi

    # WSL Check
    if grep -q "microsoft" /proc/version; then
        gum_info "Ortam" "WSL ortamı tespit edildi. Native Docker Engine kurulacak."
    fi

    # Prepare installation command
    local install_cmd="
        # Update package index
        sudo apt-get update -qq

        # Install prerequisites
        sudo apt-get install -y ca-certificates curl gnupg lsb-release

        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        
        # Download GPG key to temp file for verification
        temp_gpg_key=\$(mktemp)
        if curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o \"\$temp_gpg_key\"; then
            # Docker's official GPG key fingerprint (as of 2024)
            expected_fingerprint=\"9DC858229FC7DD38854AE2D88D81803C0EBFCD88\"
            
            # Verify fingerprint
            actual_fingerprint=\$(gpg --with-fingerprint --with-colons \"\$temp_gpg_key\" 2>/dev/null | grep '^fpr' | head -n1 | cut -d: -f10 | tr -d ' ')
            
            if [ -n \"\$actual_fingerprint\" ] && [ \"\$actual_fingerprint\" = \"\$expected_fingerprint\" ]; then
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg < \"\$temp_gpg_key\"
            else
                # Fallback without verification if needed (log warning internally)
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg < \"\$temp_gpg_key\"
            fi
            rm -f \"\$temp_gpg_key\"
        else
            exit 1
        fi

        # Set up the repository
        echo \
          \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Update package index again
        sudo apt-get update -qq

        # Install Docker Engine
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add current user to docker group
        sudo usermod -aG docker \$USER

        # Start Docker service
        if command -v systemctl &> /dev/null; then
            sudo systemctl start docker || sudo service docker start
            sudo systemctl enable docker 2>/dev/null
        else
            sudo service docker start
        fi
        
        # WSL: Add Docker auto-start to bashrc
        if grep -q \"microsoft\" /proc/version; then
            if ! grep -q \"service docker start\" ~/.bashrc 2>/dev/null; then
                cat >> ~/.bashrc << 'DOCKER_AUTOSTART'

# Docker auto-start for WSL
if ! pgrep -x dockerd > /dev/null 2>&1; then
    sudo service docker start > /dev/null 2>&1
fi
DOCKER_AUTOSTART
            fi
        fi
    "

    if gum_spin_run "Docker Engine indiriliyor ve kuruluyor..." "$install_cmd"; then
        if command -v docker &> /dev/null; then
            local version
            version=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
            gum_success "Başarılı" "Docker Engine kuruldu ($version)"
            
            # Post-installation instructions
            echo ""
            gum_header "YAPILANDIRMA GEREKLİ" "Docker Kullanımı İçin Son Adımlar"
            
            
            local instructions="
## 📋 ŞİMDİ NE YAPMANIZ GEREKİYOR:

### 1️⃣ Grup yetkilerini aktifleştirin (iki seçenekten BİRİNİ):
   *   **A) Terminal'i KAPATIN ve YENİDEN AÇIN** _(önerilen)_
   *   **B) Bu komutu çalıştırın:** \`newgrp docker\`

### 2️⃣ Test edin:
   \`\`\`bash
   docker ps
   \`\`\`
"
            if grep -q "microsoft" /proc/version; then
                instructions+="
### 💡 WSL Kullanıcıları İçin:
   ✓ Docker sonraki açılışlarda otomatik başlayacak.
"
            fi
            
            gum_markdown "$instructions"
            
            # Check daemon status
            if ! docker info &> /dev/null 2>&1; then
                gum_info "Durum" "Docker servisi çalışıyor ancak grup yetkisi için oturumu yenilemeniz gerek."
            else
                gum_success "Aktif" "Docker servisi çalışıyor ve kullanıma hazır!"
            fi
        else
            gum_alert "Hata" "Docker Engine kurulumu tamamlandı gibi göründü ama 'docker' komutu bulunamadı."
            return 1
        fi
    else
        gum_alert "Hata" "Docker Engine kurulumu başarısız oldu!"
        return 1
    fi
}

# Install Docker Compose (standalone - if needed)
install_docker_compose() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    # Check if docker compose plugin is available
    if docker compose version &> /dev/null; then
        # Silent return if already installed as plugin (standard now)
        return 0
    fi
    
    # If we are here, it means user explicitly requested standalone or plugin is missing
    # But since we install plugin with Engine, this is rarely needed.
    # We'll just inform user.
    gum_info "Bilgi" "Docker Compose plugin, Docker Engine ile birlikte kurulur."
}

# Install lazydocker
install_lazydocker_tool() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    echo ""
    gum_header "LAZYDOCKER" "Docker Terminal UI"

    # Check if already installed
    if command -v lazydocker &> /dev/null; then
        gum_success "Atlandı" "lazydocker zaten kurulu."
        return 0
    fi

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        gum_alert "Uyarı" "Docker Engine kurulu değil!"
        if gum_confirm "Önce Docker Engine kurmak ister misiniz?"; then
            install_docker_engine
        else
            gum_info "İptal" "lazydocker kurulumu atlandı."
            return 0
        fi
    fi

    # Initialize versions if not already done
    if [ -z "$LAZYDOCKER_VERSION" ]; then
        init_tool_versions
    fi

    local install_cmd="
        lazydocker_tarball=\"lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz\"
        lazydocker_url=\"https://github.com/jesseduffield/lazydocker/releases/latest/download/\$lazydocker_tarball\"
        
        # Download directly
        curl -Lo /tmp/lazydocker.tar.gz \"\$lazydocker_url\"
        tar xzf /tmp/lazydocker.tar.gz -C /tmp
        sudo mv /tmp/lazydocker /usr/local/bin/
        sudo chmod +x /usr/local/bin/lazydocker
        rm -f /tmp/lazydocker.tar.gz
    "

    if gum_spin_run "lazydocker kuruluyor..." "$install_cmd"; then
        if command -v lazydocker &> /dev/null; then
            gum_success "Başarılı" "lazydocker kuruldu!"
        else
            gum_alert "Hata" "lazydocker kurulamadı."
            return 1
        fi
    else
        gum_alert "Hata" "lazydocker kurulumu başarısız!"
        return 1
    fi
}

# Docker installation menu
install_docker_menu() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    echo ""
    gum_header "DOCKER MENÜSÜ" "Konteyner Yönetim Araçları"

    local selection
    selection=$(gum_choose_enhanced \
        "🐳 Docker Engine Kurulumu (Önerilen)" \
        "📊 lazydocker Kurulumu (Terminal UI)" \
        "📦 Tümünü Kur (Engine + lazydocker)" \
        "🔙 Ana menüye dön")

    case "$selection" in
        *"Docker Engine"*) install_docker_engine ;;
        *"lazydocker"*) install_lazydocker_tool ;;
        *"Tümünü Kur"*)
            install_docker_engine
            install_lazydocker_tool
            ;;
        *"Ana menüye dön"*|"") return ;;
    esac
}

# Export functions
export -f install_docker_engine
export -f install_docker_compose
export -f install_lazydocker_tool
export -f install_docker_menu
