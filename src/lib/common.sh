#!/bin/bash
# Common Utility Functions
# This file contains shared utilities used across all modules

# Safe read function that handles /dev/tty availability
# Usage: safe_read -r variable_name
# Falls back to stdin if /dev/tty is not available
safe_read() {
    if [ -e /dev/tty ] && [ -c /dev/tty ]; then
        read "$@" </dev/tty 2>/dev/null || read "$@"
    else
        read "$@"
    fi
}

# Safe remove function to prevent accidents
# Usage: safe_rm "/path/to/remove"
safe_rm() {
    local target="$1"
    
    if [ -z "$target" ]; then
        echo -e "${RED}[HATA]${NC} safe_rm: Hedef belirtilmedi!"
        return 1
    fi

    # Block dangerous paths
    if [[ "$target" == "/" ]] || [[ "$target" == "$HOME" ]] || [[ "$target" == "/usr" ]] || [[ "$target" == "/bin" ]] || [[ "$target" == "/etc" ]]; then
        echo -e "${RED}[HATA]${NC} safe_rm: Kritik dizin silinemez: $target"
        return 1
    fi

    if [ -e "$target" ]; then
        rm -rf "$target"
    fi
}

# Reload shell configuration files
# Usage: reload_shell_configs [mode]
# mode: "verbose" (default) or "silent"
reload_shell_configs() {
    local mode="${1:-verbose}"
    local candidates=()
    local shell_name
    shell_name=$(basename "${SHELL:-}")

    case "$shell_name" in
        zsh)
            candidates=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile")
            ;;
        bash)
            candidates=("$HOME/.bashrc" "$HOME/.profile" "$HOME/.zshrc")
            ;;
        *)
            candidates=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
            ;;
    esac

    local sourced_file=""
    for rc_file in "${candidates[@]}"; do
        if [ -f "$rc_file" ]; then
            # shellcheck source=/dev/null
            . "$rc_file" && sourced_file="$rc_file" && break
        fi
    done

    if [ "$mode" = "silent" ]; then
        return
    fi

    if [ -n "$sourced_file" ]; then
        echo -e "${GREEN}[BİLGİ]${NC} Shell yapılandırmaları otomatik olarak yüklendi (${sourced_file})."
    else
        echo -e "${YELLOW}[UYARI]${NC} Shell yapılandırma dosyaları bulunamadı; gerekirse terminalinizi yeniden başlatın."
    fi
}

# Mask sensitive data for display
# Usage: mask_secret "sensitive_string"
# Shows first 4 and last 4 characters, masks the middle
mask_secret() {
    local secret="$1"
    local length=${#secret}
    if [ "$length" -le 8 ]; then
        echo "$secret"
        return
    fi

    local prefix=${secret:0:4}
    local suffix=${secret: -4}
    local middle_length=$((length - 8))
    local mask=""
    while [ ${#mask} -lt "$middle_length" ]; do
        mask="${mask}*"
    done
    echo "${prefix}${mask}${suffix}"
}

# Check internet connection
check_internet_connection() {
    # PRD: Use AI-like thinking state instead of raw echo
    if command -v gum &>/dev/null; then
        gum_thinking "🔍 İnternet bağlantısı kontrol ediliyor..." 1
    else
        echo "İnternet bağlantısı kontrol ediliyor..."
    fi

    # FIX BUG-015: Use configurable DNS servers instead of hardcoded values
    # Try multiple methods: primary DNS, secondary DNS, and fallback URL
    if ping -c 1 -W 2 "$PRIMARY_DNS_SERVER" &>/dev/null || \
       ping -c 1 -W 2 "$SECONDARY_DNS_SERVER" &>/dev/null || \
       curl -s --connect-timeout "$NETWORK_TIMEOUT_SECONDS" --retry 3 --retry-delay 5 "$DNS_TEST_URL" &>/dev/null; then
        
        if command -v gum &>/dev/null; then
            gum_success "İnternet Bağlantısı" "Bağlantı aktif ve çalışıyor"
        else
            echo -e "${GREEN}[[+]]${NC} İnternet bağlantısı: OK"
        fi
        return 0
    else
        if command -v gum &>/dev/null; then
            gum_alert "Bağlantı Hatası" "İnternet bağlantısı yok! Lütfen ağ ayarlarınızı kontrol edin."
        else
            echo -e "${RED}[[-]]${NC} İnternet bağlantısı yok!"
            echo -e "${YELLOW}[!]${NC} Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin."
        fi
        return 1
    fi
}

# Start sudo keepalive in background
# Keeps sudo cache fresh throughout script execution
# FIX BUG-003: Pass parent_pid via environment variable to subshell for proper scoping
start_sudo_keepalive() {
    # Store parent PID before launching subshell
    local parent_pid=$$

    # Background process that refreshes sudo cache every 60 seconds
    # Use environment variable to pass parent_pid to subshell
    (
        PARENT_PROCESS_PID="$parent_pid"
        while true; do
            # Refresh sudo timestamp (non-interactive)
            sudo -n true 2>/dev/null
            sleep "$SUDO_KEEPALIVE_INTERVAL"

            # Check if parent process still exists
            # If parent died, exit gracefully
            kill -0 "$PARENT_PROCESS_PID" 2>/dev/null || exit 0
        done
    ) &

    # Store PID for cleanup
    SUDO_REFRESH_PID=$!
    export SUDO_REFRESH_PID

    # Setup trap to kill background process on script exit
    trap 'kill $SUDO_REFRESH_PID 2>/dev/null' EXIT INT TERM
}

# Check sudo access
check_sudo_access() {
    if command -v gum &>/dev/null; then
        gum_thinking "🔑 Sudo yetkisi kontrol ediliyor..." 1
    else
        echo "Sudo yetkisi kontrol ediliyor..."
    fi

    if sudo -n true 2>/dev/null; then
        if command -v gum &>/dev/null; then
            gum_success "Sudo Yetkisi" "Yetki mevcut ve aktif"
        else
            echo -e "${GREEN}[[+]]${NC} Sudo yetkisi: OK"
        fi
        return 0
    else
        if command -v gum &>/dev/null; then
            gum_warning "Yetki Gerekli" "Sudo şifresi girilmesi gerekiyor..."
        else
            echo -e "${YELLOW}[!]${NC} Sudo şifresi gerekiyor..."
        fi
        
        if sudo true; then
            if command -v gum &>/dev/null; then
                gum_success "Sudo Yetkisi" "Yetki başarıyla alındı"
            else
                echo -e "${GREEN}[[+]]${NC} Sudo yetkisi: OK"
            fi

            # Start background sudo keepalive
            start_sudo_keepalive
            
            if command -v gum &>/dev/null; then
                gum_info "Sudo Cache" "Şifre script boyunca geçerli olacak"
            else
                echo -e "${CYAN}[ℹ]${NC} Sudo cache aktif tutulacak (script boyunca şifre sormayacak)"
            fi

            return 0
        else
            if command -v gum &>/dev/null; then
                gum_alert "Yetki Hatası" "Sudo yetkisi alınamadı!"
            else
                echo -e "${RED}[[-]]${NC} Sudo yetkisi alınamadı!"
            fi
            return 1
        fi
    fi
}

# Check disk space (minimum 2GB recommended)
check_disk_space() {
    if command -v gum &>/dev/null; then
        gum_thinking "💾 Disk alanı kontrol ediliyor..." 1
    else
        echo "Disk alanı kontrol ediliyor..."
    fi

    local available_mb
    available_mb=$(df -m "$HOME" | awk 'NR==2 {print $4}')

    if [ "$available_mb" -ge "$RECOMMENDED_DISK_SPACE_MB" ]; then
        if command -v gum &>/dev/null; then
            gum_success "Disk Alanı" "${available_mb} MB mevcut (yeterli)"
        else
            echo -e "${GREEN}[[+]]${NC} Disk alanı: ${available_mb} MB mevcut"
        fi
        return 0
    elif [ "$available_mb" -ge "$WARNING_DISK_SPACE_MB" ]; then
        if command -v gum &>/dev/null; then
            gum_warning "Disk Alanı Düşük" "${available_mb} MB mevcut (${RECOMMENDED_DISK_SPACE_MB}MB önerilir). Devam ediliyor ancak bazı kurulumlar başarısız olabilir."
        else
            echo -e "${YELLOW}[!]${NC} Disk alanı: ${available_mb} MB (düşük, en az ${RECOMMENDED_DISK_SPACE_MB}MB önerilir)"
            echo -e "${YELLOW}[!]${NC} Devam ediliyor ama bazı kurulumlar başarısız olabilir..."
        fi
        return 0
    else
        if command -v gum &>/dev/null; then
            gum_alert "Disk Alanı Yetersiz" "${available_mb} MB mevcut. En az ${WARNING_DISK_SPACE_MB}MB boş alan gerekiyor!"
        else
            echo -e "${RED}[[-]]${NC} Disk alanı: ${available_mb} MB (yetersiz!)"
            echo -e "${YELLOW}[!]${NC} En az ${WARNING_DISK_SPACE_MB}MB boş alan gerekiyor!"
        fi
        return 1
    fi
}

# Check APT repositories access (for APT-based systems)
check_apt_repositories() {
    if [ "${PKG_MANAGER:-}" != "apt" ]; then
        return 0  # Skip for non-APT systems
    fi

    if command -v gum &>/dev/null; then
        gum_thinking "📦 APT repository erişimi kontrol ediliyor..." 1
    else
        echo "APT repository erişimi kontrol ediliyor..."
    fi

    # Check if timeout command is available
    if command -v timeout &>/dev/null; then
        if timeout "$APT_UPDATE_TIMEOUT_SECONDS" sudo apt-get update -qq 2>&1 | grep -q "Err:" ; then
            if command -v gum &>/dev/null; then
                gum_warning "APT Uyarısı" "Repository uyarıları var (yine de devam edilebilir)"
            else
                echo -e "${YELLOW}[!]${NC} APT repository uyarıları var (yine de devam edilebilir)"
            fi
            return 0
        elif timeout "$APT_UPDATE_TIMEOUT_SECONDS" sudo apt-get update -qq &>/dev/null; then
            if command -v gum &>/dev/null; then
                gum_success "APT Repository" "Erişim başarılı"
            else
                echo -e "${GREEN}[[+]]${NC} APT repository erişimi: OK"
            fi
            return 0
        else
            if command -v gum &>/dev/null; then
                gum_alert "APT Hatası" "'sudo apt update' komutu çalıştırılamadı"
            else
                echo -e "${RED}[[-]]${NC} APT repository erişim sorunu!"
                echo -e "${YELLOW}[!]${NC} 'sudo apt update' komutu çalıştırılamadı"
            fi
            return 1
        fi
    else
        # Fallback without timeout command
        if sudo apt-get update -qq 2>&1 | grep -q "Err:" ; then
            if command -v gum &>/dev/null; then
                gum_warning "APT Uyarısı" "Repository uyarıları var (yine de devam edilebilir)"
            else
                echo -e "${YELLOW}[!]${NC} APT repository uyarıları var (yine de devam edilebilir)"
            fi
            return 0
        elif sudo apt-get update -qq &>/dev/null; then
            if command -v gum &>/dev/null; then
                gum_success "APT Repository" "Erişim başarılı"
            else
                echo -e "${GREEN}[[+]]${NC} APT repository erişimi: OK"
            fi
            return 0
        else
            if command -v gum &>/dev/null; then
                gum_alert "APT Hatası" "'sudo apt update' komutu çalıştırılamadı"
            else
                echo -e "${RED}[[-]]${NC} APT repository erişim sorunu!"
                echo -e "${YELLOW}[!]${NC} 'sudo apt update' komutu çalıştırılamadı"
            fi
            return 1
        fi
    fi
}

# Run all pre-flight checks
# Returns 0 if all critical checks pass, 1 otherwise
run_preflight_checks() {
    echo ""
    
    if command -v gum &>/dev/null; then
        show_phase "Sistem Gereksinimleri Kontrol Ediliyor" "1/4"
    else
        echo -e "${CYAN}🔍 SİSTEM GEREKSİNİMLERİ KONTROL EDİLİYOR${NC}"
    fi
    
    echo ""

    local all_passed=true

    # Critical checks (must pass)
    if ! check_internet_connection; then
        all_passed=false
    fi

    if ! check_sudo_access; then
        all_passed=false
    fi

    # Non-critical checks (warnings only)
    check_disk_space || true
    check_apt_repositories || true

    echo ""
    if [ "$all_passed" = true ]; then
        if command -v gum &>/dev/null; then
            gum_success "Kontroller Tamamlandı" "Tüm kritik kontroller başarılı! Kuruluma başlanıyor..."
        else
            echo -e "${GREEN}[[+]]${NC} Tüm kritik kontroller başarılı! Kuruluma başlanıyor..."
        fi
        echo ""
        return 0
    else
        if command -v gum &>/dev/null; then
            gum_alert "Kontrol Başarısız" "Bazı kritik kontroller başarısız! Yukarıdaki hataları düzeltin ve tekrar deneyin."
        else
            echo -e "${RED}[[-]]${NC} Bazı kritik kontroller başarısız!"
            echo -e "${YELLOW}[!]${NC} Yukarıdaki hataları düzeltin ve tekrar deneyin."
        fi
        echo ""
        return 1
    fi
}

# Verify file checksum (SHA256)
# Usage: verify_checksum "file_path" "expected_checksum" ["checksum_url"]
# Returns: 0 if checksum matches, 1 otherwise
verify_checksum() {
    local file_path="$1"
    local expected_checksum="$2"
    local checksum_url="${3:-}"

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}[[-]]${NC} Dosya bulunamadı: $file_path"
        return 1
    fi

    # If checksum URL provided and no expected checksum, fetch it
    if [ -n "$checksum_url" ] && [ -z "$expected_checksum" ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Checksum indiriliyor: $checksum_url"
        expected_checksum=$(curl -sL --retry 3 --retry-delay 5 "$checksum_url" | head -n1 | awk '{print $1}')

        if [ -z "$expected_checksum" ]; then
            echo -e "${RED}[[-]]${NC} SECURITY ERROR: Checksum indirilemedi!"
            echo -e "${RED}[!]${NC} Güvenlik nedeniyle indirme başarısız sayılıyor."
            return 1  # SECURITY FIX: Fail if checksum cannot be fetched
        fi
    fi

    # FIX BUG-023: Validate checksum format (64 hex characters for SHA256)
    if ! [[ "$expected_checksum" =~ ^[a-fA-F0-9]{64}$ ]]; then
        echo -e "${RED}[[-]]${NC} SECURITY ERROR: Geçersiz checksum formatı!"
        echo -e "${RED}[!]${NC} SHA256 checksum 64 hex karakter olmalı"
        echo -e "${RED}[!]${NC} Alınan: ${expected_checksum:0:32}..."
        return 1  # SECURITY FIX: Fail on invalid checksum format
    fi

    # Calculate actual checksum
    local actual_checksum
    if command -v sha256sum &>/dev/null; then
        actual_checksum=$(sha256sum "$file_path" | awk '{print $1}')
    elif command -v shasum &>/dev/null; then
        actual_checksum=$(shasum -a 256 "$file_path" | awk '{print $1}')
    else
        echo -e "${RED}[[-]]${NC} SECURITY ERROR: SHA256 aracı bulunamadı!"
        echo -e "${RED}[!]${NC} Checksum doğrulaması yapılamıyor (sha256sum veya shasum gerekli)"
        echo -e "${RED}[!]${NC} Güvenlik nedeniyle işlem iptal ediliyor."
        return 1  # SECURITY FIX: Fail if no checksum tool available (CRITICAL)
    fi

    # Compare checksums (case-insensitive)
    # FIX BUG-012: Use portable tr instead of bash 4.0+ ${var,,} syntax
    local actual_lower expected_lower
    actual_lower=$(echo "$actual_checksum" | tr '[:upper:]' '[:lower:]')
    expected_lower=$(echo "$expected_checksum" | tr '[:upper:]' '[:lower:]')

    if [ "$actual_lower" = "$expected_lower" ]; then
        echo -e "${GREEN}[[+]]${NC} Checksum doğrulandı: ${expected_checksum:0:$CHECKSUM_DISPLAY_LENGTH}..."
        return 0
    else
        echo -e "${RED}[[-]]${NC} Checksum uyuşmuyor!"
        echo -e "${YELLOW}[!]${NC} Beklenen: ${expected_checksum:0:$CHECKSUM_FULL_DISPLAY}..."
        echo -e "${YELLOW}[!]${NC} Bulunan:  ${actual_checksum:0:$CHECKSUM_FULL_DISPLAY}..."
        echo -e "${RED}[!]${NC} Dosya bozuk veya güvenlik sorunu olabilir!"
        return 1
    fi
}

# Download file with checksum verification
# Usage: download_with_checksum "url" "output_path" ["checksum" | "checksum_url"]
# Returns: 0 on success, 1 on failure
download_with_checksum() {
    local url="$1"
    local output_path="$2"
    local checksum_or_url="${3:-}"

    echo -e "${YELLOW}[BİLGİ]${NC} İndiriliyor: $(basename "$url")"

    # Download file
    if ! curl -fsSL --retry 3 --retry-delay 30 -o "$output_path" "$url"; then
        echo -e "${RED}[[-]]${NC} İndirme başarısız: $url"
        return 1
    fi

    echo -e "${GREEN}[[+]]${NC} İndirme tamamlandı: $(basename "$output_path")"

    # Verify checksum if provided
    if [ -n "$checksum_or_url" ]; then
        local expected_checksum=""

        # Check if it's a URL or direct checksum
        if [[ "$checksum_or_url" =~ ^https?:// ]]; then
            # Download checksum file
            local checksum_file="/tmp/checksum_$$.txt"
            if curl -fsSL -o "$checksum_file" "$checksum_or_url" 2>/dev/null; then
                # Extract checksum for our specific file
                local filename
                filename=$(basename "$url")

                # Try to find checksum in the file (format: "<checksum> <filename>" or "<checksum>  <filename>")
                expected_checksum=$(grep -i "$filename" "$checksum_file" 2>/dev/null | awk '{print $1}' | head -n1)

                # If not found, assume it's a single checksum file
                if [ -z "$expected_checksum" ]; then
                    expected_checksum=$(head -n1 "$checksum_file" | awk '{print $1}')
                fi

                rm -f "$checksum_file"
            fi

            if [ -n "$expected_checksum" ]; then
                if ! verify_checksum "$output_path" "$expected_checksum" ""; then
                    rm -f "$output_path"  # Cleanup on verification failure
                    return 1
                fi
            else
                echo -e "${RED}[[-]]${NC} SECURITY ERROR: Checksum dosyası indirilemedi!"
                echo -e "${RED}[!]${NC} Dosya silinecek: $(basename "$output_path")"
                rm -f "$output_path"  # SECURITY FIX: Remove file if checksum unavailable
                return 1
            fi
        else
            if ! verify_checksum "$output_path" "$checksum_or_url" ""; then
                rm -f "$output_path"  # Cleanup on verification failure
                return 1
            fi
        fi
    else
        # SECURITY NOTE: If checksum is not provided, it's caller's responsibility
        # This allows backward compatibility for downloads without checksums
        echo -e "${YELLOW}[⚠]${NC} UYARI: Checksum belirtilmedi (güvenlik riski!)"
        echo -e "${YELLOW}[!]${NC} İndirilen dosyanın doğruluğu garanti edilemiyor"
        return 0
    fi
}

# Export functions for use in other modules
export -f reload_shell_configs
export -f mask_secret
export -f check_internet_connection
export -f start_sudo_keepalive
export -f check_sudo_access
export -f safe_read
export -f check_disk_space
export -f check_apt_repositories
export -f run_preflight_checks
export -f verify_checksum
export -f download_with_checksum