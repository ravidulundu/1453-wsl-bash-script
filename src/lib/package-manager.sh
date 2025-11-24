#!/bin/bash
# Package Manager Detection and System Updates
# This file detects the OS package manager and provides system update functions

# FIX BUG-004: Safe package installation wrapper function
# This prevents command injection by using proper array expansion
# Usage: safe_install_packages package1 package2 package3
safe_install_packages() {
    if [ $# -eq 0 ]; then
        gum_alert "Hata" "safe_install_packages: Paket adı gerekli"
        return 1
    fi

    # Auto-detect package manager if not already set
    # FIX BUG-027: Use ${PKG_MANAGER:-} to prevent 'unbound variable' error with set -u
    if [ -z "${PKG_MANAGER:-}" ]; then
        detect_package_manager
    fi

    case "$PKG_MANAGER" in
        "apt")
            sudo DEBIAN_FRONTEND=noninteractive apt install -y "$@"
            ;;
        "dnf")
            sudo dnf install -y "$@"
            ;;
        "yum")
            sudo yum install -y "$@"
            ;;
        "pacman")
            sudo pacman -S --noconfirm "$@"
            ;;
        *)
            gum_alert "Hata" "Bilinmeyen paket yöneticisi: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# FIX BUG-004: Safe system update wrapper function
# This prevents command injection for complex update commands (e.g., apt update && apt upgrade)
safe_update_system() {
    # Auto-detect package manager if not already set
    # FIX BUG-027: Use ${PKG_MANAGER:-} to prevent 'unbound variable' error with set -u
    if [ -z "${PKG_MANAGER:-}" ]; then
        detect_package_manager
    fi

    case "$PKG_MANAGER" in
        "apt")
            sudo DEBIAN_FRONTEND=noninteractive apt update && \
            sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
            ;;
        "dnf")
            sudo dnf upgrade -y
            ;;
        "yum")
            sudo yum upgrade -y
            ;;
        "pacman")
            sudo pacman -Syu --noconfirm
            ;;
        *)
            gum_alert "Hata" "Bilinmeyen paket yöneticisi: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Detect the system package manager and set global variables
detect_package_manager() {
    gum_info "Sistem" "İşletim sistemi ve paket yöneticisi tespit ediliyor..."

    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="sudo dnf upgrade -y"
        # NOTE: INSTALL_CMD kept for backward compatibility, but safe_install_packages() is preferred
        INSTALL_CMD="sudo dnf install -y"
    elif command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        UPDATE_CMD="sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y"
        # NOTE: INSTALL_CMD kept for backward compatibility, but safe_install_packages() is preferred
        INSTALL_CMD="sudo DEBIAN_FRONTEND=noninteractive apt install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        UPDATE_CMD="sudo yum update -y"
        # NOTE: INSTALL_CMD kept for backward compatibility, but safe_install_packages() is preferred
        INSTALL_CMD="sudo yum install -y"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        UPDATE_CMD="sudo pacman -Syu --noconfirm"
        # NOTE: INSTALL_CMD kept for backward compatibility, but safe_install_packages() is preferred
        INSTALL_CMD="sudo pacman -S --noconfirm"
    fi

    if [ -z "$PKG_MANAGER" ]; then
        gum_alert "Hata" "Desteklenen bir paket yöneticisi bulunamadı!"
        return 1
    fi

    gum_success "Başarılı" "Paket yöneticisi: $PKG_MANAGER"

    # Export variables and functions for use in other modules
    export PKG_MANAGER
    # SECURITY FIX Y-1: Deprecated - use safe_install_packages() and safe_update_system() instead
    # These are kept ONLY for backward compatibility checks (not for actual usage)
    # NOTE: If any module still uses eval with these, it's a security vulnerability
    export UPDATE_CMD  # DEPRECATED: Use safe_update_system() instead
    export INSTALL_CMD  # DEPRECATED: Use safe_install_packages() instead
    export -f safe_install_packages
    export -f safe_update_system
}

# Install package with retry mechanism
# Usage: install_package_with_retry "package_name" [max_retries]
# FIX BUG-004: Use safe_install_packages() to prevent command injection
# REFACTOR O-9: Added input validation
install_package_with_retry() {
    local packages="$1"
    local max_retries="${2:-$MAX_PACKAGE_RETRIES}"
    local attempt=1

    # SECURITY FIX O-9: Input validation
    if [ -z "$packages" ]; then
        gum_alert "Hata" "install_package_with_retry: Boş paket listesi"
        return 1
    fi

    # Validate package names (alphanumeric, dash, underscore, dot)
    if ! [[ "$packages" =~ ^[a-zA-Z0-9\ \._-]+$ ]]; then
        gum_alert "Hata" "install_package_with_retry: Geçersiz paket adı karakteri"
        gum_info "Bilgi" "İzin verilen: a-z A-Z 0-9 . _ - boşluk"
        return 1
    fi

    # Convert space-separated packages to array for safe expansion
    local -a pkg_array
    IFS=' ' read -ra pkg_array <<< "$packages"

    while [ $attempt -le $max_retries ]; do
        if [ $attempt -gt 1 ]; then
            gum_info "Tekrar" "Deneme $attempt/$max_retries..."
            sleep "$RETRY_DELAY_SECONDS"
        fi

        # Use safe wrapper function (prevents command injection)
        if safe_install_packages "${pkg_array[@]}"; then
            return 0
        fi

        ((attempt++))
    done

    return 1
}

# Update system packages and install essential tools with retry
update_system() {
    # Auto-detect package manager if not already set
    # FIX BUG-027: Use ${PKG_MANAGER:-} to prevent 'unbound variable' error with set -u
    if [ -z "${PKG_MANAGER:-}" ]; then
        gum_info "Sistem" "Paket yöneticisi tespit ediliyor..."
        detect_package_manager
    fi

    gum_info "Sistem" "Sistem güncelleniyor..."

    # FIX BUG-004: Use safe wrapper function for system updates
    local update_attempt=1
    while [ $update_attempt -le $MAX_UPDATE_RETRIES ]; do
        if [ $update_attempt -gt 1 ]; then
            gum_info "Tekrar" "Sistem güncellemesi tekrar deneniyor ($update_attempt/$MAX_UPDATE_RETRIES)..."
            sleep "$RETRY_DELAY_SECONDS"
        fi

        if safe_update_system; then
            gum_success "Başarılı" "Sistem güncellemesi başarılı!"
            break
        fi

        if [ $update_attempt -eq $MAX_UPDATE_RETRIES ]; then
            gum_alert "Hata" "Sistem güncellemesi $MAX_UPDATE_RETRIES denemede başarısız!"
            gum_warning "Uyarı" "Paket kurulumları yapılacak ama bazıları başarısız olabilir..."
        fi
        ((update_attempt++))
    done

    gum_info "Paketler" "Temel paketler, sıkıştırma ve geliştirme araçları kuruluyor..."

    if [ "$PKG_MANAGER" = "apt" ]; then
        gum_info "Kurulum" "Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip-full"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip-full" 3; then
            gum_alert "Hata" "Bazı temel paketler 3 denemede kurulamadı!"
            gum_info "Bilgi" "Lütfen elle kurun: sudo apt install -y curl wget git jq zip unzip p7zip-full"
        else
            gum_success "Başarılı" "Temel paketler kuruldu"
        fi

        gum_info "Kurulum" "Geliştirme araçları (build-essential) kuruluyor..."
        if ! install_package_with_retry "build-essential" 3; then
            gum_alert "Hata" "build-essential 3 denemede kurulamadı!"
            gum_info "Bilgi" "Lütfen elle kurun: sudo apt install -y build-essential"
        else
            gum_success "Başarılı" "build-essential kuruldu"
        fi

    elif [ "$PKG_MANAGER" = "dnf" ]; then
        gum_info "Kurulum" "Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip" 3; then
            gum_alert "Hata" "Bazı temel paketler 3 denemede kurulamadı!"
        else
            gum_success "Başarılı" "Temel paketler kuruldu"
        fi

        gum_info "Kurulum" "Geliştirme araçları (Development Tools) kuruluyor..."
        local dev_attempt=1
        while [ $dev_attempt -le $MAX_PACKAGE_RETRIES ]; do
            if [ $dev_attempt -gt 1 ]; then
                gum_info "Tekrar" "Deneme $dev_attempt/$MAX_PACKAGE_RETRIES..."
                sleep "$RETRY_DELAY_SECONDS"
            fi
            if sudo dnf groupinstall "Development Tools" -y; then
                gum_success "Başarılı" "Development Tools kuruldu"
                break
            fi
            ((dev_attempt++))
        done

    elif [ "$PKG_MANAGER" = "pacman" ]; then
        gum_info "Kurulum" "Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip" 3; then
            gum_alert "Hata" "Bazı temel paketler 3 denemede kurulamadı!"
        else
            gum_success "Başarılı" "Temel paketler kuruldu"
        fi

        gum_info "Kurulum" "Geliştirme araçları (base-devel) kuruluyor..."
        local dev_attempt=1
        while [ $dev_attempt -le $MAX_PACKAGE_RETRIES ]; do
            if [ $dev_attempt -gt 1 ]; then
                gum_info "Tekrar" "Deneme $dev_attempt/$MAX_PACKAGE_RETRIES..."
                sleep "$RETRY_DELAY_SECONDS"
            fi
            if sudo pacman -S base-devel --noconfirm; then
                gum_success "Başarılı" "base-devel kuruldu"
                break
            fi
            ((dev_attempt++))
        done

    elif [ "$PKG_MANAGER" = "yum" ]; then
        gum_info "Kurulum" "Kuruluyor: curl, wget, git, jq, zip, unzip, p7zip"
        if ! install_package_with_retry "curl wget git jq zip unzip p7zip" 3; then
            gum_alert "Hata" "Bazı temel paketler 3 denemede kurulamadı!"
        else
            gum_success "Başarılı" "Temel paketler kuruldu"
        fi

        gum_info "Kurulum" "Geliştirme araçları (Development Tools) kuruluyor..."
        local dev_attempt=1
        while [ $dev_attempt -le $MAX_PACKAGE_RETRIES ]; do
            if [ $dev_attempt -gt 1 ]; then
                gum_info "Tekrar" "Deneme $dev_attempt/$MAX_PACKAGE_RETRIES..."
                sleep "$RETRY_DELAY_SECONDS"
            fi
            if sudo yum groupinstall "Development Tools" -y; then
                gum_success "Başarılı" "Development Tools kuruldu"
                break
            fi
            ((dev_attempt++))
        done
    fi

    gum_success "Başarılı" "Sistem paket kurulumu tamamlandı!"
    gum_info "Bilgi" "Eksik paketler varsa yukarıdaki mesajlara bakın."
}

# REFACTOR O-8: Safe package removal with package manager detection
# Usage: safe_remove_packages package1 package2 package3
safe_remove_packages() {
    if [ $# -eq 0 ]; then
        gum_alert "Hata" "safe_remove_packages: Paket adı gerekli"
        return 1
    fi

    # Auto-detect package manager if not already set
    if [ -z "${PKG_MANAGER:-}" ]; then
        detect_package_manager
    fi

    case "$PKG_MANAGER" in
        "apt")
            sudo DEBIAN_FRONTEND=noninteractive apt remove -y "$@" 2>/dev/null
            sudo DEBIAN_FRONTEND=noninteractive apt autoremove -y 2>/dev/null
            ;;
        "dnf")
            sudo dnf remove -y "$@" 2>/dev/null
            sudo dnf autoremove -y 2>/dev/null
            ;;
        "yum")
            sudo yum remove -y "$@" 2>/dev/null
            sudo yum autoremove -y 2>/dev/null
            ;;
        "pacman")
            sudo pacman -Rs --noconfirm "$@" 2>/dev/null
            ;;
        *)
            gum_alert "Hata" "Bilinmeyen paket yöneticisi: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Get install command hint for error messages
# Usage: get_install_command_hint "package_name"
get_install_command_hint() {
    local package="$1"

    if [ -z "${PKG_MANAGER:-}" ]; then
        detect_package_manager
    fi

    case "$PKG_MANAGER" in
        "apt")
            echo "sudo apt install -y $package"
            ;;
        "dnf")
            echo "sudo dnf install -y $package"
            ;;
        "yum")
            echo "sudo yum install -y $package"
            ;;
        "pacman")
            echo "sudo pacman -S --noconfirm $package"
            ;;
        *)
            echo "sudo $PKG_MANAGER install $package"
            ;;
    esac
}

# Export functions
export -f detect_package_manager
export -f install_package_with_retry
export -f update_system
export -f safe_remove_packages
export -f get_install_command_hint