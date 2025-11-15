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

# Update system packages and install essential tools
update_system() {
    echo -e "\n${YELLOW}[BİLGİ]${NC} Sistem güncelleniyor..."
    if ! eval "$UPDATE_CMD"; then
        echo -e "${RED}[HATA]${NC} Sistem güncellemesi başarısız!"
        echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor ama bazı paketler eksik olabilir."
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Temel paketler, sıkıştırma ve geliştirme araçları kuruluyor..."

    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip-full"
        if ! eval "$INSTALL_CMD" curl wget git jq zip unzip p7zip-full; then
            echo -e "${RED}[HATA]${NC} Bazı temel paketler kurulamadı!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi
        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (build-essential) kuruluyor..."
        if ! eval "$INSTALL_CMD" build-essential; then
            echo -e "${RED}[HATA]${NC} build-essential kurulamadı (make, gcc eksik olabilir)!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi

    elif [ "$PKG_MANAGER" = "dnf" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! eval "$INSTALL_CMD" curl wget git jq zip unzip p7zip; then
            echo -e "${RED}[HATA]${NC} Bazı temel paketler kurulamadı!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi
        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (Development Tools) kuruluyor..."
        if ! sudo dnf groupinstall "Development Tools" -y; then
            echo -e "${RED}[HATA]${NC} Development Tools kurulamadı (make, gcc eksik olabilir)!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi

    elif [ "$PKG_MANAGER" = "pacman" ]; then
        if ! eval "$INSTALL_CMD" curl wget git jq zip unzip p7zip; then
            echo -e "${RED}[HATA]${NC} Bazı temel paketler kurulamadı!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi
        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (base-devel) kuruluyor..."
        if ! sudo pacman -S base-devel --noconfirm; then
            echo -e "${RED}[HATA]${NC} base-devel kurulamadı (make, gcc eksik olabilir)!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi

    elif [ "$PKG_MANAGER" = "yum" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! eval "$INSTALL_CMD" curl wget git jq zip unzip p7zip; then
            echo -e "${RED}[HATA]${NC} Bazı temel paketler kurulamadı!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi
        echo -e "${YELLOW}[BİLGİ]${NC} Geliştirme araçları (Development Tools) kuruluyor..."
        if ! sudo yum groupinstall "Development Tools" -y; then
            echo -e "${RED}[HATA]${NC} Development Tools kurulamadı (make, gcc eksik olabilir)!"
            echo -e "${YELLOW}[UYARI]${NC} Kuruluma devam ediliyor..."
        fi
    fi

    echo -e "${GREEN}[BAŞARILI]${NC} Sistem güncelleme ve temel paket kurulumu tamamlandı!"
    echo -e "${CYAN}[BİLGİ]${NC} Eksik paketler varsa yukarıdaki hata mesajlarını kontrol edin."
}

# Export functions
export -f detect_package_manager
export -f update_system