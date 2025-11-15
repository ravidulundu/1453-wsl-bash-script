#!/bin/bash
# Package Manager Detection and System Updates
# This file detects the OS package manager and provides system update functions

# Detect the system package manager and set global variables
detect_package_manager() {
    echo -e "${YELLOW}[BİLGİ]${NC} İşletim sistemi ve paket yöneticisi tespit ediliyor..."

    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="sudo dnf upgrade -y"
        INSTALL_CMD="sudo dnf install -y"
    elif command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        UPDATE_CMD="sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y"
        INSTALL_CMD="sudo DEBIAN_FRONTEND=noninteractive apt install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        UPDATE_CMD="sudo yum update -y"
        INSTALL_CMD="sudo yum install -y"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        UPDATE_CMD="sudo pacman -Syu --noconfirm"
        INSTALL_CMD="sudo pacman -S --noconfirm"
    else
        echo -e "${RED}[HATA]${NC} Desteklenen bir paket yöneticisi bulunamadı!"
        exit 1
    fi

    echo -e "${GREEN}[BAŞARILI]${NC} Paket yöneticisi: $PKG_MANAGER"

    # Export variables for use in other modules
    export PKG_MANAGER
    export UPDATE_CMD
    export INSTALL_CMD
}

# Install package with retry mechanism
# Usage: install_package_with_retry "package_name" [max_retries]
install_package_with_retry() {
    local packages="$1"
    local max_retries="${2:-3}"
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        if [ $attempt -gt 1 ]; then
            echo -e "${YELLOW}[↻]${NC} Deneme $attempt/$max_retries..."
            sleep 2
        fi

        # Use array to safely execute INSTALL_CMD without eval
        local cmd_array
        IFS=' ' read -ra cmd_array <<< "$INSTALL_CMD"
        if "${cmd_array[@]}" $packages; then
            return 0
        fi

        ((attempt++))
    done

    return 1
}

# Update system packages and install essential tools with retry
update_system() {
    echo -e "\n${YELLOW}[BİLGİ]${NC} Sistem güncelleniyor..."

    # Try system update with retry
    local update_attempt=1
    local max_update_retries=3
    while [ $update_attempt -le $max_update_retries ]; do
        if [ $update_attempt -gt 1 ]; then
            echo -e "${YELLOW}[↻]${NC} Sistem güncellemesi tekrar deneniyor ($update_attempt/$max_update_retries)..."
            sleep 2
        fi

        if eval "$UPDATE_CMD"; then
            echo -e "${GREEN}[✓]${NC} Sistem güncellemesi başarılı!"
            break
        fi

        if [ $update_attempt -eq $max_update_retries ]; then
            echo -e "${RED}[✗]${NC} Sistem güncellemesi $max_update_retries denemede başarısız!"
            echo -e "${YELLOW}[!]${NC} Paket kurulumları yapılacak ama bazıları başarısız olabilir..."
        fi
        ((update_attempt++))
    done

    echo -e "\n${YELLOW}[BİLGİ]${NC} Temel paketler, sıkıştırma ve geliştirme araçları kuruluyor..."

    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip-full"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip-full" 3; then
            echo -e "${RED}[✗]${NC} Bazı temel paketler 3 denemede kurulamadı!"
            echo -e "${YELLOW}[!]${NC} Lütfen elle kurun: sudo apt install -y curl wget git jq zip unzip p7zip-full"
        else
            echo -e "${GREEN}[✓]${NC} Temel paketler kuruldu"
        fi

        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (build-essential) kuruluyor..."
        if ! install_package_with_retry "build-essential" 3; then
            echo -e "${RED}[✗]${NC} build-essential 3 denemede kurulamadı!"
            echo -e "${YELLOW}[!]${NC} Lütfen elle kurun: sudo apt install -y build-essential"
        else
            echo -e "${GREEN}[✓]${NC} build-essential kuruldu"
        fi

    elif [ "$PKG_MANAGER" = "dnf" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip" 3; then
            echo -e "${RED}[✗]${NC} Bazı temel paketler 3 denemede kurulamadı!"
        else
            echo -e "${GREEN}[✓]${NC} Temel paketler kuruldu"
        fi

        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (Development Tools) kuruluyor..."
        local dev_attempt=1
        while [ $dev_attempt -le 3 ]; do
            if [ $dev_attempt -gt 1 ]; then
                echo -e "${YELLOW}[↻]${NC} Deneme $dev_attempt/3..."
                sleep 2
            fi
            if sudo dnf groupinstall "Development Tools" -y; then
                echo -e "${GREEN}[✓]${NC} Development Tools kuruldu"
                break
            fi
            ((dev_attempt++))
        done

    elif [ "$PKG_MANAGER" = "pacman" ]; then
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip" 3; then
            echo -e "${RED}[✗]${NC} Bazı temel paketler 3 denemede kurulamadı!"
        else
            echo -e "${GREEN}[✓]${NC} Temel paketler kuruldu"
        fi

        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (base-devel) kuruluyor..."
        local dev_attempt=1
        while [ $dev_attempt -le 3 ]; do
            if [ $dev_attempt -gt 1 ]; then
                echo -e "${YELLOW}[↻]${NC} Deneme $dev_attempt/3..."
                sleep 2
            fi
            if sudo pacman -S base-devel --noconfirm; then
                echo -e "${GREEN}[✓]${NC} base-devel kuruldu"
                break
            fi
            ((dev_attempt++))
        done

    elif [ "$PKG_MANAGER" = "yum" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip" 3; then
            echo -e "${RED}[✗]${NC} Bazı temel paketler 3 denemede kurulamadı!"
        else
            echo -e "${GREEN}[✓]${NC} Temel paketler kuruldu"
        fi

        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (Development Tools) kuruluyor..."
        local dev_attempt=1
        while [ $dev_attempt -le 3 ]; do
            if [ $dev_attempt -gt 1 ]; then
                echo -e "${YELLOW}[↻]${NC} Deneme $dev_attempt/3..."
                sleep 2
            fi
            if sudo yum groupinstall "Development Tools" -y; then
                echo -e "${GREEN}[✓]${NC} Development Tools kuruldu"
                break
            fi
            ((dev_attempt++))
        done
    fi

    echo ""
    echo -e "${GREEN}[✓]${NC} Sistem paket kurulumu tamamlandı!"
    echo -e "${CYAN}[ℹ]${NC} Eksik paketler varsa yukarıdaki mesajlara bakın."
}

# Export functions
export -f detect_package_manager
export -f install_package_with_retry
export -f update_system