#!/bin/bash
# Module: PHP Ecosystem
# Description: PHP version management, Composer, and Laravel support
# Dependencies: lib/common.sh, lib/package-manager.sh, config/php-versions.sh

# Ensure PHP repository is configured
ensure_php_repository() {
    if [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "\n${YELLOW}[BİLGİ]${NC} PHP için Ondřej Surý deposu kontrol ediliyor..."
        # FIX BUG-004: Use safe_install_packages() to prevent command injection
        safe_install_packages software-properties-common ca-certificates apt-transport-https lsb-release gnupg
        if ! grep -R "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null | grep -q ondrej; then
            echo -e "${YELLOW}[BİLGİ]${NC} Ondřej Surý PPA ekleniyor..."
            sudo add-apt-repository -y ppa:ondrej/php
        fi
        sudo apt update
    elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
        if ! rpm -qa | grep -qi remi-release; then
            echo -e "${YELLOW}[BİLGİ]${NC} Remi PHP deposu ekleniyor..."
            if [ -f /etc/os-release ]; then
                # shellcheck disable=SC1091
                . /etc/os-release
            fi
            if [ "${ID:-}" = "fedora" ]; then
                local fedora_ver
                fedora_ver="${VERSION_ID:-}"
                if [ -z "$fedora_ver" ]; then
                    fedora_ver=$(rpm -E %fedora 2>/dev/null || echo "")
                fi
                if [ -n "$fedora_ver" ]; then
                    sudo "$PKG_MANAGER" install -y "https://rpms.remirepo.net/fedora/remi-release-${fedora_ver}.rpm"
                else
                    echo -e "${RED}[HATA]${NC} Fedora sürümü tespit edilemedi."
                    return 1
                fi
            else
                local rhel_version
                rhel_version=$(rpm -E %rhel 2>/dev/null || echo "")
                if [ -n "$rhel_version" ]; then
                    sudo "$PKG_MANAGER" install -y "https://rpms.remirepo.net/enterprise/remi-release-${rhel_version}.rpm"
                else
                    echo -e "${RED}[HATA]${NC} Remi deposu otomatik eklenemedi. Lütfen manuel olarak yapılandırın."
                    return 1
                fi
            fi
        fi
    fi

    return 0
}

# Install Composer
install_composer() {
    echo ""
    echo -e "${YELLOW}[BİLGİ]${NC} Composer kurulumu denetleniyor..."

    if command -v composer &> /dev/null; then
        local version
        version=$(composer --version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
        echo -e "${CYAN}[!]${NC} Composer zaten kurulu: $version"
        track_skip "Composer" "Zaten kurulu ($version)"
        return 0
    fi

    if ! command -v php &> /dev/null; then
        echo -e "${RED}[HATA]${NC} Composer kurulumu için PHP gereklidir. Lütfen önce PHP kurun."
        track_failure "Composer" "PHP gereksinimi karşılanamadı"
        return 1
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    if [ ! -d "$temp_dir" ]; then
        echo -e "${RED}[HATA]${NC} Geçici dizin oluşturulamadı."
        return 1
    fi

    local installer_path="$temp_dir/composer-setup.php"
    local installer_sig_url="https://composer.github.io/installer.sig"
    local installer_url="https://getcomposer.org/installer"

    echo -e "${YELLOW}[BİLGİ]${NC} Composer installer indiriliyor..."
    local expected_checksum
    expected_checksum=$(curl -sS "$installer_sig_url") || true
    if [ -z "$expected_checksum" ]; then
        echo -e "${RED}[HATA]${NC} Installer imza bilgisi alınamadı."
        rm -rf "$temp_dir"
        return 1
    fi

    if ! php -r "copy('$installer_url', '$installer_path');"; then
        echo -e "${RED}[HATA]${NC} Composer installer indirilemedi."
        rm -rf "$temp_dir"
        return 1
    fi

    local actual_checksum
    actual_checksum=$(php -r "echo hash_file('sha384', '$installer_path');")
    if [ "$expected_checksum" != "$actual_checksum" ]; then
        echo -e "${RED}[HATA]${NC} İmza doğrulaması başarısız! Kurulum iptal edildi."
        rm -rf "$temp_dir"
        return 1
    fi

    echo -e "${YELLOW}[BİLGİ]${NC} Installer doğrulandı, Composer yükleniyor..."
    if ! sudo php "$installer_path" --quiet --install-dir=/usr/local/bin --filename=composer; then
        echo -e "${RED}[HATA]${NC} Composer kurulumu başarısız oldu."
        rm -rf "$temp_dir"
        return 1
    fi

    rm -rf "$temp_dir"

    if command -v composer &> /dev/null; then
        local version
        version=$(composer --version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
        echo -e "${GREEN}[BAŞARILI]${NC} Composer kurulumu tamamlandı: $version"
        echo -e "\n${CYAN}[BİLGİ]${NC} Composer Kullanım İpuçları:"
        echo -e "  ${GREEN}•${NC} Proje bağımlılıklarını kurma: ${GREEN}composer install${NC}"
        echo -e "  ${GREEN}•${NC} Paket ekleme: ${GREEN}composer require paket/adi${NC}"
        echo -e "  ${GREEN}•${NC} Laravel kurulumu: ${GREEN}composer global require laravel/installer${NC}"
        echo -e "  ${GREEN}•${NC} Paketleri güncelleme: ${GREEN}composer update${NC}"
        track_success "Composer" "$version"
        return 0
    else
        echo -e "${RED}[HATA]${NC} Composer kurulumu başarısız!"
        track_failure "Composer" "Kurulum başarısız"
        return 1
    fi
}

# Install a specific PHP version with extensions
install_php_version() {
    local version="$1"
    echo ""
    echo -e "${YELLOW}[BİLGİ]${NC} PHP ${version} ve Laravel eklentileri kuruluyor..."

    ensure_php_repository || return 1

    declare -A pkg_map=()
    local skipped_exts=()

    case "$PKG_MANAGER" in
        apt)
            pkg_map["php${version}"]=1
            pkg_map["php${version}-cli"]=1
            pkg_map["php${version}-common"]=1
            pkg_map["php${version}-fpm"]=1
            for ext in "${PHP_EXTENSION_PACKAGES[@]}"; do
                local pkg_name=""
                case "$ext" in
                    fpm)
                        continue
                        ;;
                    tokenizer)
                        skipped_exts+=("tokenizer (PHP çekirdeği ile geliyor)")
                        continue
                        ;;
                    *)
                        pkg_name="php${version}-${ext}"
                        ;;
                esac
                pkg_map["$pkg_name"]=1
            done
            ;;
        dnf|yum)
            local rpm_suffix
            rpm_suffix=$(echo "$version" | tr -d '.')
            local base="php${rpm_suffix}-php"
            pkg_map["${base}"]=1
            pkg_map["${base}-cli"]=1
            pkg_map["${base}-common"]=1
            pkg_map["${base}-fpm"]=1
            for ext in "${PHP_EXTENSION_PACKAGES[@]}"; do
                local ext_name="$ext"
                case "$ext" in
                    fpm)
                        continue
                        ;;
                    tokenizer)
                        skipped_exts+=("tokenizer (PHP çekirdeği ile geliyor)")
                        continue
                        ;;
                    sqlite3)
                        ext_name="pdo_sqlite"
                        ;;
                    mysql)
                        ext_name="mysqlnd"
                        ;;
                    pgsql)
                        ext_name="pdo_pgsql"
                        ;;
                esac
                pkg_map["${base}-${ext_name}"]=1
            done
            ;;
        pacman)
            echo -e "${YELLOW}[UYARI]${NC} Arch Linux için PHP kurulumu manuel olarak yapılandırılmalıdır."
            # FIX BUG-004: Use safe_install_packages() to prevent command injection
            safe_install_packages php php-fpm
            ;;
    esac

    local pkgs_to_install=()
    for pkg in "${!pkg_map[@]}"; do
        pkgs_to_install+=("$pkg")
    done

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Kurulacak paketler: ${pkgs_to_install[*]}"
        # FIX BUG-004: Use safe_install_packages() to prevent command injection
        safe_install_packages "${pkgs_to_install[@]}"
    fi

    if [ ${#skipped_exts[@]} -gt 0 ]; then
        echo -e "${YELLOW}[UYARI]${NC} Atlanılan eklentiler (zaten mevcut): ${skipped_exts[*]}"
    fi

    echo -e "${GREEN}[BAŞARILI]${NC} PHP ${version} kurulumu tamamlandı!"
}

# Menu for PHP version selection
install_php_version_menu() {
    echo ""
    gum_style --foreground 212 --bold "🐘 PHP Sürüm Seçimi"
    echo ""

    # Build menu options
    local -a options=()
    for ver in "${PHP_SUPPORTED_VERSIONS[@]}"; do
        options+=("PHP ${ver}")
    done
    options+=("━━━━━━━━━━━━━━━━━━━━━")
    options+=("📦 Tüm sürümleri kur")
    options+=("◀ Ana menüye dön")

    local selection
    selection=$(gum_choose "${options[@]}")

    case "$selection" in
        "◀ Ana menüye dön"|"")
            return
            ;;
        "📦 Tüm sürümleri kur")
            for ver in "${PHP_SUPPORTED_VERSIONS[@]}"; do
                install_php_version "$ver"
            done
            ;;
        "━"*)
            # Separator, ignore
            return
            ;;
        "PHP "*)
            local version="${selection#PHP }"
            install_php_version "$version"
            ;;
    esac
}

# Export functions for use in other modules
export -f ensure_php_repository
export -f install_composer
export -f install_php_version
export -f install_php_version_menu