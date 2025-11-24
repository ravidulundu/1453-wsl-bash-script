#!/bin/bash
# Module: PHP Ecosystem
# Description: PHP version management, Composer, and Laravel support
# Dependencies: lib/common.sh, lib/package-manager.sh, config/php-versions.sh

# Ensure PHP repository is configured
ensure_php_repository() {
    if [ "$PKG_MANAGER" = "apt" ]; then
        # Check if already added
        if grep -R "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null | grep -q ondrej; then
            return 0
        fi

        gum_info "Repo" "Ondřej Surý PHP deposu ekleniyor..."
        
        local repo_cmd="
            sudo apt-get install -y software-properties-common ca-certificates apt-transport-https lsb-release gnupg
            sudo add-apt-repository -y ppa:ondrej/php
            sudo apt-get update -qq
        "
        
        if gum_spin_run "PPA ekleniyor..." "$repo_cmd"; then
            gum_success "Başarılı" "PHP deposu eklendi."
        else
            gum_alert "Hata" "PHP deposu eklenemedi!"
            return 1
        fi

    elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
        if ! rpm -qa | grep -qi remi-release; then
            gum_info "Repo" "Remi PHP deposu ekleniyor..."
            
            local repo_cmd="
                if [ -f /etc/os-release ]; then . /etc/os-release; fi
                if [ \"\${ID:-}\" = \"fedora\" ]; then
                    fedora_ver=\"\${VERSION_ID:-}\"
                    if [ -z \"\$fedora_ver\" ]; then fedora_ver=\$(rpm -E %fedora 2>/dev/null || echo \"\"); fi
                    if [ -n \"\$fedora_ver\" ]; then
                        sudo $PKG_MANAGER install -y \"https://rpms.remirepo.net/fedora/remi-release-\${fedora_ver}.rpm\"
                    else
                        exit 1
                    fi
                else
                    rhel_version=\$(rpm -E %rhel 2>/dev/null || echo \"\")
                    if [ -n \"\$rhel_version\" ]; then
                        sudo $PKG_MANAGER install -y \"https://rpms.remirepo.net/enterprise/remi-release-\${rhel_version}.rpm\"
                    else
                        exit 1
                    fi
                fi
            "
            
            if gum_spin_run "Remi deposu ekleniyor..." "$repo_cmd"; then
                gum_success "Başarılı" "Remi deposu eklendi."
            else
                gum_alert "Hata" "Remi deposu eklenemedi!"
                return 1
            fi
        fi
    fi

    return 0
}

# Install Composer
install_composer() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    echo ""
    gum_header "COMPOSER KURULUMU" "PHP Paket Yöneticisi"

    if command -v composer &> /dev/null; then
        local version
        version=$(composer --version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
        gum_success "Atlandı" "Composer zaten kurulu: $version"
        track_skip "Composer" "Zaten kurulu ($version)"
        return 0
    fi

    if ! command -v php &> /dev/null; then
        gum_alert "Hata" "Composer kurulumu için PHP gereklidir. Lütfen önce PHP kurun."
        track_failure "Composer" "PHP gereksinimi karşılanamadı"
        return 1
    fi

    local install_cmd="
        temp_dir=\$(mktemp -d)
        installer_path=\"\$temp_dir/composer-setup.php\"
        installer_sig_url=\"https://composer.github.io/installer.sig\"
        installer_url=\"https://getcomposer.org/installer\"

        expected_checksum=\$(curl -sS \"\$installer_sig_url\") || exit 1
        php -r \"copy('\$installer_url', '\$installer_path');\" || exit 1
        
        actual_checksum=\$(php -r \"echo hash_file('sha384', '\$installer_path');\")
        if [ \"\$expected_checksum\" != \"\$actual_checksum\" ]; then
            rm -rf \"\$temp_dir\"
            exit 1
        fi

        sudo php \"\$installer_path\" --quiet --install-dir=/usr/local/bin --filename=composer
        rm -rf \"\$temp_dir\"
    "

    if gum_spin_run "Composer indiriliyor ve kuruluyor..." "$install_cmd"; then
        if command -v composer &> /dev/null; then
            local version
            version=$(composer --version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
            gum_success "Başarılı" "Composer kurulumu tamamlandı: $version"
            
            echo ""
            gum_header "COMPOSER KULLANIM İPUÇLARI"
            local instructions="
## 📌 Kullanım Örnekleri:

*   **Proje bağımlılıklarını kurma:** \`composer install\`
*   **Paket ekleme:** \`composer require paket/adi\`
*   **Laravel kurulumu:** \`composer global require laravel/installer\`
"
            gum_markdown "$instructions"
            
            track_success "Composer" "$version"
            return 0
        else
            gum_alert "Hata" "Composer kurulumu başarısız!"
            track_failure "Composer" "Kurulum başarısız"
            return 1
        fi
    else
        gum_alert "Hata" "Composer kurulumu başarısız!"
        track_failure "Composer" "Kurulum başarısız"
        return 1
    fi
}

# Install a specific PHP version with extensions
install_php_version() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    local version="$1"
    echo ""
    gum_header "PHP ${version} KURULUMU" "Web Geliştirme Dili"
    
    # Check if this PHP version is already installed
    if command -v "php$version" &> /dev/null; then
        local installed_version
        installed_version=$("php$version" --version 2>&1 | head -n1)
        gum_success "Atlandı" "PHP $version zaten kurulu: $installed_version"
        track_skip "PHP $version" "Zaten kurulu"
        return 0
    fi
    
    # Ensure repo first
    if ! ensure_php_repository; then
        return 1
    fi

    # Build package list
    local pkgs_to_install=()
    local skipped_exts=()

    case "$PKG_MANAGER" in
        apt)
            pkgs_to_install+=("php${version}" "php${version}-cli" "php${version}-common" "php${version}-fpm")
            for ext in "${PHP_EXTENSION_PACKAGES[@]}"; do
                case "$ext" in
                    fpm) continue ;;
                    tokenizer) skipped_exts+=("tokenizer"); continue ;;
                    *) pkgs_to_install+=("php${version}-${ext}") ;;
                esac
            done
            ;;
        dnf|yum)
            local rpm_suffix
            rpm_suffix=$(echo "$version" | tr -d '.')
            local base="php${rpm_suffix}-php"
            pkgs_to_install+=("${base}" "${base}-cli" "${base}-common" "${base}-fpm")
            for ext in "${PHP_EXTENSION_PACKAGES[@]}"; do
                local ext_name="$ext"
                case "$ext" in
                    fpm) continue ;;
                    tokenizer) skipped_exts+=("tokenizer"); continue ;;
                    sqlite3) ext_name="pdo_sqlite" ;;
                    mysql) ext_name="mysqlnd" ;;
                    pgsql) ext_name="pdo_pgsql" ;;
                esac
                pkgs_to_install+=("${base}-${ext_name}")
            done
            ;;
        pacman)
            gum_alert "Uyarı" "Arch Linux için PHP kurulumu manuel olarak yapılandırılmalıdır."
            pkgs_to_install+=("php" "php-fpm")
            ;;
    esac

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        local install_cmd=""
        if [ "$PKG_MANAGER" = "apt" ]; then
            install_cmd="sudo apt-get install -y ${pkgs_to_install[*]}"
        elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
            install_cmd="sudo $PKG_MANAGER install -y ${pkgs_to_install[*]}"
        elif [ "$PKG_MANAGER" = "pacman" ]; then
            install_cmd="sudo pacman -S --noconfirm ${pkgs_to_install[*]}"
        fi

        if gum_spin_run "PHP ${version} ve eklentileri kuruluyor..." "$install_cmd"; then
            gum_success "Başarılı" "PHP ${version} kurulumu tamamlandı!"
            if [ ${#skipped_exts[@]} -gt 0 ]; then
                gum_info "Not" "Bazı eklentiler çekirdeğe dahil olduğu için atlandı: ${skipped_exts[*]}"
            fi
        else
            gum_alert "Hata" "PHP ${version} kurulumu başarısız!"
            return 1
        fi
    fi
}

# Menu for PHP version selection
install_php_version_menu() {
    if command -v show_ai_thinking &>/dev/null; then
        show_ai_thinking "building" 1
    fi

    echo ""
    gum_header "PHP MENÜSÜ" "Sürüm Yönetimi"

    # Build menu options
    local -a options=()
    for ver in "${PHP_SUPPORTED_VERSIONS[@]}"; do
        options+=("PHP ${ver}")
    done
    options+=("📦 Tüm sürümleri kur")
    options+=("🔙 Ana menüye dön")

    local selection
    selection=$(gum_choose_enhanced "${options[@]}")

    case "$selection" in
        *"Ana menüye dön"*)
            return
            ;;
        *"Tüm sürümleri kur"*)
            for ver in "${PHP_SUPPORTED_VERSIONS[@]}"; do
                install_php_version "$ver"
            done
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