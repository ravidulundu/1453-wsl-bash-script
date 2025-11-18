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
# FIX BUG-002: Safely handle package names with proper quoting to prevent command injection
install_package_with_retry() {
    local packages="$1"
    local max_retries="${2:-$MAX_PACKAGE_RETRIES}"
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        if [ $attempt -gt 1 ]; then
            echo -e "${YELLOW}[↻]${NC} Deneme $attempt/$max_retries..."
            sleep "$RETRY_DELAY_SECONDS"
        fi

        # Use array to safely execute INSTALL_CMD without eval
        local -a cmd_array
        local -a pkg_array
        IFS=' ' read -ra cmd_array <<< "$INSTALL_CMD"
        IFS=' ' read -ra pkg_array <<< "$packages"

        # SAFE: Both command and packages are properly expanded as arrays
        if "${cmd_array[@]}" "${pkg_array[@]}"; then
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
    # Safe execution without eval (prevents command injection)
    local cmd_array
    IFS=' ' read -ra cmd_array <<< "$UPDATE_CMD"

    local update_attempt=1
    while [ $update_attempt -le $MAX_UPDATE_RETRIES ]; do
        if [ $update_attempt -gt 1 ]; then
            echo -e "${YELLOW}[↻]${NC} Sistem güncellemesi tekrar deneniyor ($update_attempt/$MAX_UPDATE_RETRIES)..."
            sleep "$RETRY_DELAY_SECONDS"
        fi

        if "${cmd_array[@]}"; then
            echo -e "${GREEN}[✓]${NC} Sistem güncellemesi başarılı!"
            break
        fi

        if [ $update_attempt -eq $MAX_UPDATE_RETRIES ]; then
            echo -e "${RED}[✗]${NC} Sistem güncellemesi $MAX_UPDATE_RETRIES denemede başarısız!"
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
        while [ $dev_attempt -le $MAX_PACKAGE_RETRIES ]; do
            if [ $dev_attempt -gt 1 ]; then
                echo -e "${YELLOW}[↻]${NC} Deneme $dev_attempt/$MAX_PACKAGE_RETRIES..."
                sleep "$RETRY_DELAY_SECONDS"
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
        while [ $dev_attempt -le $MAX_PACKAGE_RETRIES ]; do
            if [ $dev_attempt -gt 1 ]; then
                echo -e "${YELLOW}[↻]${NC} Deneme $dev_attempt/$MAX_PACKAGE_RETRIES..."
                sleep "$RETRY_DELAY_SECONDS"
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
        while [ $dev_attempt -le $MAX_PACKAGE_RETRIES ]; do
            if [ $dev_attempt -gt 1 ]; then
                echo -e "${YELLOW}[↻]${NC} Deneme $dev_attempt/$MAX_PACKAGE_RETRIES..."
                sleep "$RETRY_DELAY_SECONDS"
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