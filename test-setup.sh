#!/bin/bash
# ===================================================================================================
# 1453 WSL Setup Script - Validation & Test Script
# ===================================================================================================
# Bu script WSL kurulumunuzun doğru yapıldığını kontrol eder ve detaylı rapor sunar.
#
# Kullanım:
#   ./test-setup.sh              # Standart test
#   ./test-setup.sh --verbose    # Detaylı çıktı
#   ./test-setup.sh --json       # JSON formatında rapor
#   ./test-setup.sh --log FILE   # Log dosyasına kaydet
#
# Version: 1.0.0
# ===================================================================================================

# ===================================================================================================
# Renkler ve Global Değişkenler
# ===================================================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Test sonuçları
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0

# Test kategorileri
declare -A CATEGORY_PASSED
declare -A CATEGORY_FAILED
declare -A CATEGORY_WARNING
declare -A CATEGORY_TOTAL

# Detaylı log mesajları
declare -a LOG_MESSAGES=()
declare -a FAILED_ITEMS=()
declare -a WARNING_ITEMS=()

# Seçenekler
VERBOSE=false
JSON_OUTPUT=false
LOG_FILE=""
START_TIME=$(date +%s)

# ===================================================================================================
# Yardımcı Fonksiyonlar
# ===================================================================================================

# Banner göster
show_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██╗██╗  ██╗███████╗██████╗      █████╗ ██╗                ║
║  ███║██║  ██║██╔════╝╚════██╗    ██╔══██╗██║                ║
║  ╚██║███████║███████╗ █████╔╝    ███████║██║                ║
║   ██║╚════██║╚════██║ ╚═══██╗    ██╔══██║██║                ║
║   ██║     ██║███████║██████╔╝    ██║  ██║██║                ║
║   ╚═╝     ╚═╝╚══════╝╚═════╝     ╚═╝  ╚═╝╚═╝                ║
║                                                               ║
║           WSL Kurulum Test & Validation Scripti               ║
║                      Version 1.0.0                            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Kullanım bilgisi
show_usage() {
    cat << EOF
${BOLD}Kullanım:${NC}
    ./test-setup.sh [SEÇENEKLER]

${BOLD}Seçenekler:${NC}
    --verbose, -v       Detaylı çıktı
    --json, -j          JSON formatında rapor
    --log FILE, -l FILE Log dosyasına kaydet
    --help, -h          Bu yardım mesajını göster

${BOLD}Örnekler:${NC}
    ./test-setup.sh                          # Standart test
    ./test-setup.sh --verbose                # Detaylı test
    ./test-setup.sh --json > report.json     # JSON rapor
    ./test-setup.sh --log test-results.log   # Log dosyasına kaydet
EOF
}

# Log mesajı ekle
add_log() {
    local message="$1"
    LOG_MESSAGES+=("$(date '+%Y-%m-%d %H:%M:%S') - $message")

    if [ -n "$LOG_FILE" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
    fi

    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[LOG]${NC} $message"
    fi
}

# Test sonucu kaydet
record_test() {
    local category="$1"
    local status="$2"  # PASS, FAIL, WARNING
    local message="$3"

    ((TOTAL_TESTS++))
    ((CATEGORY_TOTAL[$category]++))

    case "$status" in
        PASS)
            ((PASSED_TESTS++))
            ((CATEGORY_PASSED[$category]++))
            echo -e "  ${GREEN}✓${NC} $message"
            add_log "[$category] PASS: $message"
            ;;
        FAIL)
            ((FAILED_TESTS++))
            ((CATEGORY_FAILED[$category]++))
            echo -e "  ${RED}✗${NC} $message"
            FAILED_ITEMS+=("[$category] $message")
            add_log "[$category] FAIL: $message"
            ;;
        WARNING)
            ((WARNING_TESTS++))
            ((CATEGORY_WARNING[$category]++))
            echo -e "  ${YELLOW}⚠${NC} $message"
            WARNING_ITEMS+=("[$category] $message")
            add_log "[$category] WARNING: $message"
            ;;
    esac
}

# Komut varlığını kontrol et
check_command() {
    local cmd="$1"
    local category="$2"
    local description="$3"

    if command -v "$cmd" &> /dev/null; then
        local version=""
        case "$cmd" in
            python3)
                version=$(python3 --version 2>&1 | awk '{print $2}')
                ;;
            pip|pip3)
                version=$(pip3 --version 2>&1 | awk '{print $2}')
                ;;
            node)
                version=$(node --version 2>&1)
                ;;
            npm)
                version=$(npm --version 2>&1)
                ;;
            php)
                version=$(php --version 2>&1 | head -n1 | awk '{print $2}')
                ;;
            composer)
                version=$(composer --version 2>&1 | awk '{print $3}')
                ;;
            go)
                version=$(go version 2>&1 | awk '{print $3}' | sed 's/go//')
                ;;
            docker)
                version=$(docker --version 2>&1 | awk '{print $3}' | tr -d ',')
                ;;
            *)
                version=$($cmd --version 2>&1 | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
                ;;
        esac

        if [ -n "$version" ]; then
            record_test "$category" "PASS" "$description kurulu (Versiyon: $version)"
        else
            record_test "$category" "PASS" "$description kurulu"
        fi
        return 0
    else
        record_test "$category" "FAIL" "$description kurulu değil"
        return 1
    fi
}

# Dosya varlığını kontrol et
check_file() {
    local file="$1"
    local category="$2"
    local description="$3"

    if [ -f "$file" ]; then
        record_test "$category" "PASS" "$description mevcut ($file)"
        return 0
    else
        record_test "$category" "FAIL" "$description bulunamadı ($file)"
        return 1
    fi
}

# Dizin varlığını kontrol et
check_directory() {
    local dir="$1"
    local category="$2"
    local description="$3"

    if [ -d "$dir" ]; then
        record_test "$category" "PASS" "$description mevcut ($dir)"
        return 0
    else
        record_test "$category" "WARNING" "$description bulunamadı ($dir)"
        return 1
    fi
}

# Ortam değişkeni kontrolü
check_env_var() {
    local var="$1"
    local category="$2"
    local description="$3"

    if [ -n "${!var}" ]; then
        record_test "$category" "PASS" "$description ayarlanmış (${!var})"
        return 0
    else
        record_test "$category" "WARNING" "$description ayarlanmamış"
        return 1
    fi
}

# Shell config kontrolü
check_shell_config() {
    local file="$1"
    local pattern="$2"
    local category="$3"
    local description="$4"

    if [ -f "$file" ] && grep -q "$pattern" "$file" 2>/dev/null; then
        record_test "$category" "PASS" "$description yapılandırılmış"
        return 0
    else
        record_test "$category" "WARNING" "$description yapılandırılmamış"
        return 1
    fi
}

# ===================================================================================================
# Test Kategorileri
# ===================================================================================================

# Kategori başlığı göster
show_category() {
    local category="$1"
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $category${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 1. Sistem Bilgileri
test_system_info() {
    local category="Sistem Bilgileri"
    show_category "$category"

    # OS bilgisi
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        record_test "$category" "PASS" "İşletim Sistemi: $PRETTY_NAME"
    fi

    # Kernel bilgisi
    local kernel=$(uname -r)
    record_test "$category" "PASS" "Kernel: $kernel"

    # WSL versiyonu
    if grep -qi microsoft /proc/version 2>/dev/null; then
        record_test "$category" "PASS" "WSL ortamı tespit edildi"
    else
        record_test "$category" "WARNING" "WSL ortamı tespit edilemedi (Native Linux olabilir)"
    fi

    # Paket yöneticisi
    if command -v apt &> /dev/null; then
        record_test "$category" "PASS" "Paket Yöneticisi: APT (Debian/Ubuntu)"
    elif command -v dnf &> /dev/null; then
        record_test "$category" "PASS" "Paket Yöneticisi: DNF (Fedora/RHEL)"
    elif command -v yum &> /dev/null; then
        record_test "$category" "PASS" "Paket Yöneticisi: YUM (CentOS)"
    elif command -v pacman &> /dev/null; then
        record_test "$category" "PASS" "Paket Yöneticisi: Pacman (Arch)"
    else
        record_test "$category" "WARNING" "Paket yöneticisi tespit edilemedi"
    fi
}

# 2. Temel Araçlar
test_basic_tools() {
    local category="Temel Araçlar"
    show_category "$category"

    check_command "git" "$category" "Git"
    check_command "curl" "$category" "curl"
    check_command "wget" "$category" "wget"
    check_command "jq" "$category" "jq"
    check_command "zip" "$category" "zip"
    check_command "unzip" "$category" "unzip"

    # Build essentials
    if command -v gcc &> /dev/null; then
        check_command "gcc" "$category" "GCC Compiler"
        check_command "make" "$category" "Make"
    else
        record_test "$category" "WARNING" "Build essentials kurulu değil"
    fi
}

# 3. Python Ekosistemi
test_python() {
    local category="Python Ekosistemi"
    show_category "$category"

    check_command "python3" "$category" "Python 3"
    check_command "pip3" "$category" "pip"
    check_command "pipx" "$category" "pipx"
    check_command "uv" "$category" "UV (Ultra-fast Python package manager)"

    # Python PATH kontrolü
    if command -v python3 &> /dev/null; then
        local python_path=$(which python3)
        add_log "Python yolu: $python_path"
    fi

    # pip yapılandırması
    if [ -f "$HOME/.config/pip/pip.conf" ]; then
        record_test "$category" "PASS" "pip yapılandırma dosyası mevcut"
    fi
}

# 4. JavaScript Ekosistemi
test_javascript() {
    local category="JavaScript Ekosistemi"
    show_category "$category"

    # NVM kontrolü
    if [ -d "$HOME/.nvm" ]; then
        record_test "$category" "PASS" "NVM kurulu dizini mevcut"

        # NVM yükle
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        if command -v nvm &> /dev/null; then
            local nvm_version=$(nvm --version 2>&1)
            record_test "$category" "PASS" "NVM çalışıyor (Versiyon: $nvm_version)"
        fi
    else
        record_test "$category" "FAIL" "NVM kurulu değil"
    fi

    check_command "node" "$category" "Node.js"
    check_command "npm" "$category" "npm"
    check_command "bun" "$category" "Bun.js"

    # Shell config'de NVM kontrolü
    check_shell_config "$HOME/.bashrc" "NVM_DIR" "$category" "NVM .bashrc'de yapılandırılmış"
}

# 5. PHP Ekosistemi
test_php() {
    local category="PHP Ekosistemi"
    show_category "$category"

    check_command "php" "$category" "PHP"
    check_command "composer" "$category" "Composer"

    # PHP versiyonları
    if command -v php &> /dev/null; then
        # update-alternatives kontrolü
        if command -v update-alternatives &> /dev/null; then
            local php_alternatives=$(update-alternatives --list php 2>/dev/null | wc -l)
            if [ "$php_alternatives" -gt 1 ]; then
                record_test "$category" "PASS" "Birden fazla PHP versiyonu kurulu ($php_alternatives versiyon)"
            fi
        fi

        # PHP extensions
        local extensions=$(php -m 2>/dev/null | wc -l)
        record_test "$category" "PASS" "PHP extensions yüklü ($extensions adet)"
    fi

    # Composer global dizini
    if [ -d "$HOME/.composer" ] || [ -d "$HOME/.config/composer" ]; then
        record_test "$category" "PASS" "Composer global dizini mevcut"
    fi
}

# 6. Go
test_go() {
    local category="Go Language"
    show_category "$category"

    check_command "go" "$category" "Go"

    # Go PATH kontrolü
    check_env_var "GOPATH" "$category" "GOPATH"
    check_env_var "GOROOT" "$category" "GOROOT"

    # Go workspace
    if [ -d "$HOME/go" ]; then
        record_test "$category" "PASS" "Go workspace mevcut ($HOME/go)"
    fi
}

# 7. Modern CLI Araçları
test_modern_tools() {
    local category="Modern CLI Araçları"
    show_category "$category"

    check_command "bat" "$category" "bat (modern cat)"
    check_command "rg" "$category" "ripgrep"
    check_command "fd" "$category" "fd (modern find)"
    check_command "eza" "$category" "eza (modern ls)"
    check_command "starship" "$category" "Starship prompt"
    check_command "zoxide" "$category" "zoxide (smart cd)"
    check_command "fzf" "$category" "fzf (fuzzy finder)"
    check_command "vivid" "$category" "vivid (LS_COLORS generator)"
    check_command "fastfetch" "$category" "fastfetch (system info)"
    check_command "lazygit" "$category" "lazygit (Git UI)"
    check_command "lazydocker" "$category" "lazydocker (Docker UI)"

    # Starship config
    check_file "$HOME/.config/starship.toml" "$category" "Starship yapılandırma dosyası"
}

# 8. Shell Ortamı
test_shell_environment() {
    local category="Shell Ortamı"
    show_category "$category"

    # Bash aliases
    check_file "$HOME/.bash_aliases" "$category" ".bash_aliases dosyası"

    # Bashrc enhancements
    check_shell_config "$HOME/.bashrc" "1453" "$category" ".bashrc 1453 yapılandırması"

    # Custom functions
    if [ -f "$HOME/.bash_aliases" ]; then
        if grep -q "function mcd" "$HOME/.bash_aliases" 2>/dev/null; then
            record_test "$category" "PASS" "Custom fonksiyonlar tanımlı (mcd, vb.)"
        fi
    fi

    # FZF integration
    check_shell_config "$HOME/.bashrc" "FZF" "$category" "FZF shell entegrasyonu"

    # Zoxide integration
    check_shell_config "$HOME/.bashrc" "zoxide" "$category" "Zoxide shell entegrasyonu"

    # Starship prompt
    check_shell_config "$HOME/.bashrc" "starship" "$category" "Starship prompt aktif"

    # Alias sayısı
    if [ -f "$HOME/.bash_aliases" ]; then
        local alias_count=$(grep -c "^alias" "$HOME/.bash_aliases" 2>/dev/null || echo "0")
        if [ "$alias_count" -gt 0 ]; then
            record_test "$category" "PASS" "Bash aliases tanımlı ($alias_count adet)"
        fi
    fi
}

# 9. AI CLI Araçları
test_ai_cli_tools() {
    local category="AI CLI Araçları"
    show_category "$category"

    check_command "claude" "$category" "Claude Code CLI"
    check_command "gh" "$category" "GitHub CLI"
    check_command "gemini-cli" "$category" "Gemini CLI"

    # Claude Code global NPM package
    if command -v npm &> /dev/null; then
        if npm list -g @anthropic-ai/claude-code 2>/dev/null | grep -q "claude-code"; then
            record_test "$category" "PASS" "Claude Code (NPM global package)"
        fi
    fi

    # GitHub CLI auth check
    if command -v gh &> /dev/null; then
        if gh auth status &>/dev/null; then
            record_test "$category" "PASS" "GitHub CLI authenticated"
        else
            record_test "$category" "WARNING" "GitHub CLI kurulu ama authenticated değil"
        fi
    fi
}

# 10. AI Frameworks
test_ai_frameworks() {
    local category="AI Frameworks"
    show_category "$category"

    # SuperGemini
    if [ -d "$HOME/SuperGemini" ]; then
        record_test "$category" "PASS" "SuperGemini framework kurulu"
        check_file "$HOME/SuperGemini/.env" "$category" "SuperGemini .env dosyası"
    else
        record_test "$category" "WARNING" "SuperGemini framework kurulu değil"
    fi

    # SuperQwen
    if [ -d "$HOME/SuperQwen" ]; then
        record_test "$category" "PASS" "SuperQwen framework kurulu"
        check_file "$HOME/SuperQwen/.env" "$category" "SuperQwen .env dosyası"
    else
        record_test "$category" "WARNING" "SuperQwen framework kurulu değil"
    fi

    # SuperClaude
    if [ -d "$HOME/SuperClaude" ]; then
        record_test "$category" "PASS" "SuperClaude framework kurulu"
        check_file "$HOME/SuperClaude/.env" "$category" "SuperClaude .env dosyası"
    else
        record_test "$category" "WARNING" "SuperClaude framework kurulu değil"
    fi

    # MCP config
    if [ -f "$HOME/.config/claude/claude_desktop_config.json" ]; then
        record_test "$category" "PASS" "Claude Desktop MCP config mevcut"
    fi
}

# 11. Docker
test_docker() {
    local category="Docker"
    show_category "$category"

    check_command "docker" "$category" "Docker Engine"

    if command -v docker &> /dev/null; then
        # Docker daemon kontrolü
        if docker ps &>/dev/null; then
            record_test "$category" "PASS" "Docker daemon çalışıyor"
        else
            record_test "$category" "WARNING" "Docker kurulu ama daemon çalışmıyor"
        fi

        # Docker group kontrolü
        if groups | grep -q docker; then
            record_test "$category" "PASS" "Kullanıcı docker grubunda"
        else
            record_test "$category" "WARNING" "Kullanıcı docker grubunda değil (sudo gerekebilir)"
        fi
    fi

    check_command "docker-compose" "$category" "Docker Compose"
    check_command "lazydocker" "$category" "lazydocker"
}

# 12. Kurulum Dizini
test_installation_directory() {
    local category="Kurulum Dizini"
    show_category "$category"

    # 1453 setup dizini
    if [ -d "$HOME/.1453-wsl-setup" ]; then
        record_test "$category" "PASS" "1453 kurulum dizini mevcut"

        # Launcher script
        check_file "$HOME/.1453-wsl-setup/1453-setup" "$category" "Launcher script"

        # Modüller
        check_directory "$HOME/.1453-wsl-setup/src/modules" "$category" "Modüller dizini"
        check_directory "$HOME/.1453-wsl-setup/src/lib" "$category" "Kütüphane dizini"
        check_directory "$HOME/.1453-wsl-setup/src/config" "$category" "Config dizini"

        # Ana script
        check_file "$HOME/.1453-wsl-setup/src/linux-ai-setup-script.sh" "$category" "Ana setup script"
    else
        record_test "$category" "WARNING" "1453 kurulum dizini bulunamadı (manuel kurulum olabilir)"
    fi
}

# ===================================================================================================
# Rapor Oluşturma
# ===================================================================================================

# Özet rapor
show_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))

    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  TEST ÖZET RAPORU${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Genel istatistikler
    echo -e "${BOLD}Genel İstatistikler:${NC}"
    echo -e "  Toplam Test: ${BOLD}$TOTAL_TESTS${NC}"
    echo -e "  ${GREEN}✓ Başarılı: $PASSED_TESTS${NC}"
    echo -e "  ${RED}✗ Başarısız: $FAILED_TESTS${NC}"
    echo -e "  ${YELLOW}⚠ Uyarı: $WARNING_TESTS${NC}"
    echo -e "  Süre: ${duration} saniye"
    echo ""

    # Kategori bazında istatistikler
    if [ ${#CATEGORY_TOTAL[@]} -gt 0 ]; then
        echo -e "${BOLD}Kategori Bazında Sonuçlar:${NC}"
        for category in "${!CATEGORY_TOTAL[@]}"; do
            local total=${CATEGORY_TOTAL[$category]}
            local passed=${CATEGORY_PASSED[$category]:-0}
            local failed=${CATEGORY_FAILED[$category]:-0}
            local warning=${CATEGORY_WARNING[$category]:-0}

            echo -e "  ${BOLD}$category:${NC}"
            echo -e "    Toplam: $total | ${GREEN}✓ $passed${NC} | ${RED}✗ $failed${NC} | ${YELLOW}⚠ $warning${NC}"
        done
        echo ""
    fi

    # Başarısız testler
    if [ ${#FAILED_ITEMS[@]} -gt 0 ]; then
        echo -e "${BOLD}${RED}Başarısız Testler:${NC}"
        for item in "${FAILED_ITEMS[@]}"; do
            echo -e "  ${RED}✗${NC} $item"
        done
        echo ""
    fi

    # Uyarılar
    if [ ${#WARNING_ITEMS[@]} -gt 0 ]; then
        echo -e "${BOLD}${YELLOW}Uyarılar:${NC}"
        for item in "${WARNING_ITEMS[@]}"; do
            echo -e "  ${YELLOW}⚠${NC} $item"
        done
        echo ""
    fi

    # Genel sonuç
    echo -e "${BOLD}Genel Sonuç:${NC}"
    if [ $FAILED_TESTS -eq 0 ]; then
        if [ $WARNING_TESTS -eq 0 ]; then
            echo -e "  ${GREEN}${BOLD}✓ MÜKEMMEL!${NC} Tüm testler başarılı."
        else
            echo -e "  ${GREEN}${BOLD}✓ İYİ!${NC} Tüm testler geçti, bazı uyarılar var."
        fi
    else
        local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "  ${YELLOW}${BOLD}⚠ DİKKAT!${NC} Başarı oranı: %${success_rate}"
        echo -e "  ${RED}Bazı bileşenler kurulu değil veya hatalı yapılandırılmış.${NC}"
    fi

    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# JSON rapor
generate_json_report() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))

    cat << EOF
{
  "test_report": {
    "version": "1.0.0",
    "timestamp": "$(date -Iseconds)",
    "duration_seconds": $duration,
    "summary": {
      "total_tests": $TOTAL_TESTS,
      "passed": $PASSED_TESTS,
      "failed": $FAILED_TESTS,
      "warnings": $WARNING_TESTS,
      "success_rate": $(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    },
    "categories": {
EOF

    local first=true
    for category in "${!CATEGORY_TOTAL[@]}"; do
        if [ "$first" = false ]; then
            echo ","
        fi
        first=false

        local total=${CATEGORY_TOTAL[$category]}
        local passed=${CATEGORY_PASSED[$category]:-0}
        local failed=${CATEGORY_FAILED[$category]:-0}
        local warning=${CATEGORY_WARNING[$category]:-0}

        cat << EOF
      "$(echo "$category" | sed 's/ /_/g')": {
        "total": $total,
        "passed": $passed,
        "failed": $failed,
        "warnings": $warning
      }
EOF
    done

    cat << EOF

    },
    "failed_items": [
EOF

    first=true
    for item in "${FAILED_ITEMS[@]}"; do
        if [ "$first" = false ]; then
            echo ","
        fi
        first=false
        echo "      \"$(echo "$item" | sed 's/"/\\"/g')\""
    done

    cat << EOF

    ],
    "warning_items": [
EOF

    first=true
    for item in "${WARNING_ITEMS[@]}"; do
        if [ "$first" = false ]; then
            echo ","
        fi
        first=false
        echo "      \"$(echo "$item" | sed 's/"/\\"/g')\""
    done

    cat << EOF

    ],
    "log_messages": [
EOF

    first=true
    for msg in "${LOG_MESSAGES[@]}"; do
        if [ "$first" = false ]; then
            echo ","
        fi
        first=false
        echo "      \"$(echo "$msg" | sed 's/"/\\"/g')\""
    done

    cat << EOF

    ]
  }
}
EOF
}

# ===================================================================================================
# Ana Program
# ===================================================================================================

# Argüman işleme
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Bilinmeyen seçenek: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Log dosyası başlat
if [ -n "$LOG_FILE" ]; then
    echo "1453 WSL Setup Test - $(date)" > "$LOG_FILE"
    echo "======================================" >> "$LOG_FILE"
    add_log "Test başlatıldı"
fi

# JSON output değilse banner göster
if [ "$JSON_OUTPUT" = false ]; then
    show_banner
    echo -e "${CYAN}Test başlatılıyor...${NC}"
    echo -e "${CYAN}Sistem kontrolü yapılıyor...${NC}"
    echo ""
fi

# Tüm testleri çalıştır
test_system_info
test_basic_tools
test_python
test_javascript
test_php
test_go
test_modern_tools
test_shell_environment
test_ai_cli_tools
test_ai_frameworks
test_docker
test_installation_directory

# Rapor göster
if [ "$JSON_OUTPUT" = true ]; then
    generate_json_report
else
    show_summary

    # Log dosyası bilgisi
    if [ -n "$LOG_FILE" ]; then
        echo -e "${CYAN}Detaylı log kaydedildi: $LOG_FILE${NC}"
    fi

    # Exit code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
fi
