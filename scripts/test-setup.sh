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

# FIX BUG-002: Add safety flags for robust error handling
# Note: -e not used because tests should continue even if checks fail
# SECURITY FIX: Added -u flag to catch undefined variable usage
# Tests use explicit error handling (if ! command; then ...) instead of -e
set -uo pipefail

# FIX BUG-013: Ensure running with bash, not sh
if [ -z "${BASH_VERSION:-}" ]; then
    echo "Hata: Bu betik sh ile değil, bash ile çalıştırılmalıdır."
    echo "Kullanım: bash test-setup.sh"
    exit 1
fi

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
SNAPSHOT_MODE=false
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
    --snapshot, -s      Snapshot/Röntgen modu (sistem durumunun tam raporu)
    --help, -h          Bu yardım mesajını göster

${BOLD}Örnekler:${NC}
    ./test-setup.sh                          # Standart test
    ./test-setup.sh --verbose                # Detaylı test
    ./test-setup.sh --json > report.json     # JSON rapor
    ./test-setup.sh --log test-results.log   # Log dosyasına kaydet
    ./test-setup.sh --snapshot               # WSL sistem röntgeni
    ./test-setup.sh --snapshot --log wsl-snapshot.log  # Snapshot raporunu log dosyasına kaydet
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

    # Initialize category counters if not exists (fix for set -u)
    if [ -z "${CATEGORY_TOTAL[$category]:-}" ]; then
        CATEGORY_TOTAL[$category]=0
        CATEGORY_PASSED[$category]=0
        CATEGORY_FAILED[$category]=0
        CATEGORY_WARNING[$category]=0
    fi

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
    local description="${3:-$cmd}"

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

    if [ -n "${!var:-}" ]; then
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
            record_test "$category" "PASS" "GitHub CLI kimlik doğrulaması başarılı"
        else
            record_test "$category" "WARNING" "GitHub CLI kurulu ama kimlik doğrulaması yapılmamış"
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

    check_command "docker" "$category" "Docker"   # Docker Service Check

    if command -v docker &> /dev/null; then
        # Docker daemon kontrolü
        if docker info &>/dev/null; then
            record_test "$category" "PASS" "Docker Daemon çalışıyor"
        else
            record_test "$category" "WARNING" "Docker kurulu ama Daemon çalışmıyor (sudo service docker start gerekebilir)"
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

# 13. Alias Kontrolü
test_aliases() {
    local category="Bash Aliases"
    show_category "$category"

    # .bash_aliases dosyası kontrolü
    if [ -f "$HOME/.bash_aliases" ]; then
        local alias_count=$(grep -c "^alias" "$HOME/.bash_aliases" 2>/dev/null || echo "0")
        record_test "$category" "PASS" ".bash_aliases dosyası mevcut ($alias_count alias tanımlı)"

        # Alias bağımlılıklarını kontrol et
        check_alias_dependency "cat" "batcat" "$category" "cat='batcat' alias"
        check_alias_dependency "grep" "rg" "$category" "grep='rg' alias"
        check_alias_dependency "find" "fdfind" "$category" "find='fdfind' alias"
        check_alias_dependency "ls" "eza" "$category" "ls='eza' alias"
        check_alias_dependency "ll" "eza" "$category" "ll='eza' alias"
        check_alias_dependency "la" "eza" "$category" "la='eza' alias"
        check_alias_dependency "lg" "lazygit" "$category" "lg='lazygit' alias"
        check_alias_dependency "ld" "lazydocker" "$category" "ld='lazydocker' alias"

        # Bashrc'de alias sourcing kontrolü
        if grep -q "\.bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
            record_test "$category" "PASS" ".bashrc .bash_aliases'ı source ediyor"
        else
            record_test "$category" "FAIL" ".bashrc .bash_aliases'ı source etmiyor"
        fi
    else
        record_test "$category" "FAIL" ".bash_aliases dosyası bulunamadı"
    fi
}

# Alias bağımlılık kontrolü
check_alias_dependency() {
    local alias_name="$1"
    local command="$2"
    local category="$3"
    local description="$4"

    if grep -q "alias $alias_name=" "$HOME/.bash_aliases" 2>/dev/null; then
        if command -v "$command" &> /dev/null; then
            record_test "$category" "PASS" "$description → $command mevcut ✓"
        else
            record_test "$category" "FAIL" "$description → $command EKSIK! Alias çalışmayacak"
        fi
    fi
}

# 14. Eksik Yüklemeler - Detaylı Analiz
test_missing_installations() {
    local category="Eksik Yüklemeler Analizi"
    show_category "$category"

    local missing=()
    local optional_missing=()

    # Temel araçlar (kritik)
    command -v git &> /dev/null || missing+=("git")
    command -v curl &> /dev/null || missing+=("curl")
    command -v wget &> /dev/null || missing+=("wget")

    # Python ekosistemi
    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi
    if ! command -v pip3 &> /dev/null; then
        missing+=("pip3")
    fi
    if ! command -v pipx &> /dev/null; then
        optional_missing+=("pipx")
    fi
    if ! command -v uv &> /dev/null; then
        optional_missing+=("uv (UV package manager)")
    fi

    # JavaScript ekosistemi
    if [ ! -d "$HOME/.nvm" ]; then
        optional_missing+=("NVM")
    fi
    if ! command -v node &> /dev/null; then
        optional_missing+=("Node.js")
    fi
    if ! command -v bun &> /dev/null; then
        optional_missing+=("Bun.js")
    fi

    # Modern CLI tools
    if ! command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        optional_missing+=("bat/batcat")
    fi
    if ! command -v eza &> /dev/null; then
        optional_missing+=("eza")
    fi
    if ! command -v starship &> /dev/null; then
        optional_missing+=("starship")
    fi
    if ! command -v zoxide &> /dev/null; then
        optional_missing+=("zoxide")
    fi
    if ! command -v fzf &> /dev/null; then
        optional_missing+=("fzf")
    fi
    if ! command -v rg &> /dev/null; then
        optional_missing+=("ripgrep (rg)")
    fi
    if ! command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        optional_missing+=("fd-find")
    fi
    if ! command -v lazygit &> /dev/null; then
        optional_missing+=("lazygit")
    fi
    if ! command -v lazydocker &> /dev/null; then
        optional_missing+=("lazydocker")
    fi

    # Sonuçlar
    if [ ${#missing[@]} -eq 0 ]; then
        record_test "$category" "PASS" "Tüm kritik araçlar kurulu ✓"
    else
        for item in "${missing[@]}"; do
            record_test "$category" "FAIL" "KRİTİK: $item eksik!"
        done
    fi

    if [ ${#optional_missing[@]} -eq 0 ]; then
        record_test "$category" "PASS" "Tüm opsiyonel araçlar kurulu ✓"
    else
        for item in "${optional_missing[@]}"; do
            record_test "$category" "WARNING" "Opsiyonel: $item kurulu değil"
        done
    fi
}

# 15. Functional Tests - Gerçek Kullanım Testleri
test_functional() {
    local category="Fonksiyonel Testler"
    show_category "$category"

    # Test dizini oluştur
    local test_dir="/tmp/1453-test-$$"
    local orig_dir="$PWD"

    mkdir -p "$test_dir" || {
        record_test "$category" "FAIL" "Test dizini oluşturulamadı"
        return
    }

    cd "$test_dir" || {
        cd "$orig_dir" 2>/dev/null || cd "$HOME"
        rm -rf "$test_dir"
        record_test "$category" "FAIL" "Test dizinine geçilemedi"
        return
    }

    # 1. Modern ls (eza/ll) testi
    if [ -f "$HOME/.bash_aliases" ] && grep -q "alias ll=" "$HOME/.bash_aliases" 2>/dev/null; then
        if command -v eza &> /dev/null; then
            # Test dosyası oluştur
            touch test-file.txt
            # ll alias'ını simüle et (eza komutu direkt çalıştır)
            if eza -lah test-file.txt &> /dev/null; then
                record_test "$category" "PASS" "ll (eza) komutu çalışıyor ✓"
            else
                record_test "$category" "FAIL" "ll alias tanımlı ama eza ÇALIŞMIYOR"
            fi
        else
            record_test "$category" "FAIL" "ll alias var ama eza kurulu değil"
        fi
    else
        record_test "$category" "WARNING" "ll alias tanımlı değil"
    fi

    # 2. Modern cat (batcat) testi
    if [ -f "$HOME/.bash_aliases" ] && grep -q "alias cat=" "$HOME/.bash_aliases" 2>/dev/null; then
        if command -v batcat &> /dev/null; then
            echo "test content" > test-cat.txt
            if batcat test-cat.txt &> /dev/null; then
                record_test "$category" "PASS" "cat (batcat) komutu çalışıyor ✓"
            else
                record_test "$category" "FAIL" "cat alias tanımlı ama batcat ÇALIŞMIYOR"
            fi
        else
            record_test "$category" "FAIL" "cat alias var ama batcat kurulu değil"
        fi
    else
        record_test "$category" "WARNING" "cat alias tanımlı değil"
    fi

    # 3. Starship prompt testi
    if command -v starship &> /dev/null; then
        if grep -q "starship init" "$HOME/.bashrc" 2>/dev/null; then
            # Starship config testi
            if starship prompt &> /dev/null; then
                record_test "$category" "PASS" "Starship prompt çalışıyor ✓"
            else
                record_test "$category" "WARNING" "Starship kurulu ama prompt oluşturulamıyor"
            fi
        else
            record_test "$category" "FAIL" "Starship kurulu ama .bashrc'de init edilmemiş"
        fi
    else
        record_test "$category" "WARNING" "Starship kurulu değil"
    fi

    # 4. Zoxide testi
    if command -v zoxide &> /dev/null; then
        if grep -q "zoxide init" "$HOME/.bashrc" 2>/dev/null; then
            # Zoxide query testi
            if zoxide query --help &> /dev/null; then
                record_test "$category" "PASS" "Zoxide çalışıyor ✓"
            else
                record_test "$category" "WARNING" "Zoxide kurulu ama query çalışmıyor"
            fi
        else
            record_test "$category" "FAIL" "Zoxide kurulu ama .bashrc'de init edilmemiş"
        fi
    else
        record_test "$category" "WARNING" "Zoxide kurulu değil"
    fi

    # 5. FZF testi
    if command -v fzf &> /dev/null; then
        # FZF key bindings kontrolü
        if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
            if grep -q "key-bindings.bash" "$HOME/.bashrc" 2>/dev/null; then
                record_test "$category" "PASS" "FZF key bindings yapılandırılmış ✓"
            else
                record_test "$category" "WARNING" "FZF kurulu ama key bindings yok"
            fi
        fi

        # FZF temel çalışma testi
        echo -e "option1\noption2\noption3" | fzf --filter="opt" &> /dev/null
        if [ $? -eq 0 ] || [ $? -eq 1 ]; then
            record_test "$category" "PASS" "FZF filter çalışıyor ✓"
        else
            record_test "$category" "FAIL" "FZF kurulu ama ÇALIŞMIYOR"
        fi
    else
        record_test "$category" "WARNING" "FZF kurulu değil"
    fi

    # 6. ripgrep (rg) testi
    if command -v rg &> /dev/null; then
        echo "test pattern" > test-rg.txt
        if rg "pattern" test-rg.txt &> /dev/null; then
            record_test "$category" "PASS" "ripgrep (rg) çalışıyor ✓"
        else
            record_test "$category" "FAIL" "rg kurulu ama ÇALIŞMIYOR"
        fi
    else
        record_test "$category" "WARNING" "ripgrep kurulu değil"
    fi

    # 7. fd-find testi
    if command -v fdfind &> /dev/null || command -v fd &> /dev/null; then
        local fd_cmd="fdfind"
        command -v fd &> /dev/null && fd_cmd="fd"

        touch test-fd-file.txt
        if $fd_cmd "test-fd" . &> /dev/null; then
            record_test "$category" "PASS" "fd-find çalışıyor ✓"
        else
            record_test "$category" "FAIL" "fd kurulu ama ÇALIŞMIYOR"
        fi
    else
        record_test "$category" "WARNING" "fd-find kurulu değil"
    fi

    # 8. Custom functions testi (mcd)
    if grep -qE "^[[:space:]]*(function[[:space:]]+mcd|mcd)[[:space:]]*\(\)" "$HOME/.bashrc" 2>/dev/null; then
        record_test "$category" "PASS" "Custom function 'mcd' tanımlı ✓"

        # mcd fonksiyonunu test et (source etmeden, sadece tanımlı mı kontrolü)
        if declare -f mcd &> /dev/null; then
            record_test "$category" "PASS" "mcd fonksiyonu aktif ✓"
        else
            record_test "$category" "WARNING" "mcd tanımlı ama bu shell'de yüklü değil"
        fi
    else
        record_test "$category" "WARNING" "Custom function 'mcd' tanımlı değil"
    fi

    # 9. Git alias testi
    if [ -f "$HOME/.bash_aliases" ]; then
        local git_aliases=$(grep -c "^alias g" "$HOME/.bash_aliases" 2>/dev/null || echo "0")
        if [ "$git_aliases" -gt 0 ]; then
            record_test "$category" "PASS" "Git aliasları tanımlı ($git_aliases adet) ✓"
        else
            record_test "$category" "WARNING" "Git aliasları bulunamadı"
        fi
    fi

    # 10. Vivid (LS_COLORS) testi
    if command -v vivid &> /dev/null; then
        if vivid generate catppuccin-mocha &> /dev/null; then
            record_test "$category" "PASS" "vivid (LS_COLORS) çalışıyor ✓"
        else
            record_test "$category" "WARNING" "vivid kurulu ama theme oluşturulamıyor"
        fi

        if grep -q "vivid generate" "$HOME/.bashrc" 2>/dev/null; then
            record_test "$category" "PASS" "vivid .bashrc'de yapılandırılmış ✓"
        else
            record_test "$category" "WARNING" "vivid kurulu ama .bashrc'de yapılandırılmamış"
        fi
    else
        record_test "$category" "WARNING" "vivid kurulu değil"
    fi

    # 11. Bash history settings testi
    if grep -q "HISTSIZE=100000" "$HOME/.bashrc" 2>/dev/null; then
        record_test "$category" "PASS" "Bash history ayarları yapılandırılmış ✓"
    else
        record_test "$category" "WARNING" "Bash history ayarları eksik"
    fi

    # 12. PATH kontrolü (~/.local/bin)
    if echo "$PATH" | grep -q "$HOME/.local/bin"; then
        record_test "$category" "PASS" "~/.local/bin PATH'e eklenmiş ✓"
    else
        record_test "$category" "WARNING" "~/.local/bin PATH'de yok"
    fi

    # 13. Fastfetch testi
    if command -v fastfetch &> /dev/null; then
        if fastfetch --version &> /dev/null; then
            record_test "$category" "PASS" "fastfetch çalışıyor ✓"
        else
            record_test "$category" "FAIL" "fastfetch kurulu ama ÇALIŞMIYOR"
        fi
    else
        record_test "$category" "WARNING" "fastfetch kurulu değil"
    fi

    # 14. Navigasyon aliasları test (.. , ..., home)
    if [ -f "$HOME/.bash_aliases" ]; then
        local nav_count=0
        grep -q "alias \.\.=" "$HOME/.bash_aliases" 2>/dev/null && ((nav_count++))
        grep -q "alias \.\.\.=" "$HOME/.bash_aliases" 2>/dev/null && ((nav_count++))
        grep -q "alias home=" "$HOME/.bash_aliases" 2>/dev/null && ((nav_count++))

        if [ "$nav_count" -ge 2 ]; then
            record_test "$category" "PASS" "Navigasyon aliasları tanımlı ($nav_count adet) ✓"
        else
            record_test "$category" "WARNING" "Navigasyon aliasları eksik"
        fi
    fi

    # 15. Safety aliasları (cp -i, mv -i, rm -i)
    if [ -f "$HOME/.bash_aliases" ]; then
        local safety_count=0
        grep -q "alias cp='cp -i'" "$HOME/.bash_aliases" 2>/dev/null && ((safety_count++))
        grep -q "alias mv='mv -i'" "$HOME/.bash_aliases" 2>/dev/null && ((safety_count++))
        grep -q "alias rm='rm -i'" "$HOME/.bash_aliases" 2>/dev/null && ((safety_count++))

        if [ "$safety_count" -eq 3 ]; then
            record_test "$category" "PASS" "Safety aliasları (cp/mv/rm -i) tanımlı ✓"
        else
            record_test "$category" "WARNING" "Safety aliasları eksik ($safety_count/3)"
        fi
    fi

    # 16. Docker aliasları
    if [ -f "$HOME/.bash_aliases" ]; then
        local docker_alias_count=$(grep -c "^alias d" "$HOME/.bash_aliases" 2>/dev/null || echo "0")
        if [ "$docker_alias_count" -gt 0 ]; then
            record_test "$category" "PASS" "Docker aliasları tanımlı ($docker_alias_count adet) ✓"
        fi
    fi

    # 17. NPM aliasları
    if [ -f "$HOME/.bash_aliases" ]; then
        local npm_alias_count=$(grep -c "^alias n" "$HOME/.bash_aliases" 2>/dev/null || echo "0")
        if [ "$npm_alias_count" -gt 0 ]; then
            record_test "$category" "PASS" "NPM aliasları tanımlı ($npm_alias_count adet) ✓"
        fi
    fi

    # 18. Python aliasları
    if [ -f "$HOME/.bash_aliases" ]; then
        local py_alias_count=0
        grep -q "alias py=" "$HOME/.bash_aliases" 2>/dev/null && ((py_alias_count++))
        grep -q "alias venv=" "$HOME/.bash_aliases" 2>/dev/null && ((py_alias_count++))
        grep -q "alias activate=" "$HOME/.bash_aliases" 2>/dev/null && ((py_alias_count++))

        if [ "$py_alias_count" -ge 2 ]; then
            record_test "$category" "PASS" "Python aliasları tanımlı ($py_alias_count adet) ✓"
        fi
    fi

    # 19. System info aliasları (cpuinfo, meminfo, disk, ports, myip)
    if [ -f "$HOME/.bash_aliases" ]; then
        local sysinfo_count=0
        grep -q "alias cpuinfo=" "$HOME/.bash_aliases" 2>/dev/null && ((sysinfo_count++))
        grep -q "alias meminfo=" "$HOME/.bash_aliases" 2>/dev/null && ((sysinfo_count++))
        grep -q "alias disk=" "$HOME/.bash_aliases" 2>/dev/null && ((sysinfo_count++))
        grep -q "alias ports=" "$HOME/.bash_aliases" 2>/dev/null && ((sysinfo_count++))

        if [ "$sysinfo_count" -ge 3 ]; then
            record_test "$category" "PASS" "System info aliasları tanımlı ($sysinfo_count adet) ✓"
        fi
    fi

    # 20. Clear aliasları (c, cl, cls)
    if [ -f "$HOME/.bash_aliases" ]; then
        local clear_count=0
        grep -q "alias c='clear'" "$HOME/.bash_aliases" 2>/dev/null && ((clear_count++))
        grep -q "alias cl='clear'" "$HOME/.bash_aliases" 2>/dev/null && ((clear_count++))
        grep -q "alias cls='clear'" "$HOME/.bash_aliases" 2>/dev/null && ((clear_count++))

        if [ "$clear_count" -ge 2 ]; then
            record_test "$category" "PASS" "Clear aliasları tanımlı ($clear_count adet) ✓"
        fi
    fi

    # Cleanup
    cd "$orig_dir" 2>/dev/null || cd "$HOME"
    rm -rf "$test_dir"
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
        if [ $TOTAL_TESTS -eq 0 ]; then
            local success_rate=0
        else
            local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        fi
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

    # Calculate success rate safely (integer percentage)
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi

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
      "success_rate": $success_rate
    },
    "categories": {
EOF

    # Note: Empty categories/arrays are valid JSON - {} and [] are both valid
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

# Snapshot/Röntgen Fonksiyonu
generate_snapshot() {
    echo -e "${CYAN}${BOLD}"
    echo "════════════════════════════════════════════════════════════════"
    echo "   WSL SİSTEM RÖNTGEN RAPORU - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "════════════════════════════════════════════════════════════════"
    echo -e "${NC}"

    echo -e "${BOLD}[SİSTEM BİLGİLERİ]${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    [ -f /etc/os-release ] && source /etc/os-release && echo "İşletim Sistemi: $PRETTY_NAME"
    echo "Kernel: $(uname -r)"
    echo "Hostname: $(hostname)"
    echo "Kullanıcı: $USER"
    echo "Home: $HOME"
    grep -qi microsoft /proc/version 2>/dev/null && echo "WSL: Tespit edildi ✓" || echo "WSL: Tespit edilemedi"
    echo ""

    echo -e "${BOLD}[DONANIM BİLGİLERİ]${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "CPU: $(lscpu | grep "Model name" | cut -d ':' -f2 | xargs)"
    echo "CPU Çekirdek: $(nproc)"
    echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Disk Kullanımı:"
    df -h / | tail -n1 | awk '{print "  Toplam: "$2" | Kullanılan: "$3" | Boş: "$4" | Kullanım: "$5}'
    echo ""

    echo -e "${BOLD}[KURULU ARAÇLAR - VERSIYONLAR]${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo -e "${CYAN}Temel Araçlar:${NC}"
    command -v git &>/dev/null && echo "  git: $(git --version | awk '{print $3}')" || echo "  git: KURULU DEĞİL"
    command -v curl &>/dev/null && echo "  curl: $(curl --version | head -n1 | awk '{print $2}')" || echo "  curl: KURULU DEĞİL"
    command -v wget &>/dev/null && echo "  wget: $(wget --version | head -n1 | awk '{print $3}')" || echo "  wget: KURULU DEĞİL"
    command -v jq &>/dev/null && echo "  jq: $(jq --version)" || echo "  jq: KURULU DEĞİL"
    echo ""

    echo -e "${CYAN}Python Ekosistemi:${NC}"
    command -v python3 &>/dev/null && echo "  Python: $(python3 --version | awk '{print $2}')" || echo "  Python: KURULU DEĞİL"
    command -v pip3 &>/dev/null && echo "  pip: $(pip3 --version | awk '{print $2}')" || echo "  pip: KURULU DEĞİL"
    command -v pipx &>/dev/null && echo "  pipx: $(pipx --version)" || echo "  pipx: KURULU DEĞİL"
    command -v uv &>/dev/null && echo "  uv: $(uv --version | awk '{print $2}')" || echo "  uv: KURULU DEĞİL"
    echo ""

    echo -e "${CYAN}JavaScript Ekosistemi:${NC}"
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        command -v nvm &>/dev/null && echo "  NVM: $(nvm --version)" || echo "  NVM: Kurulu ama yüklenemedi"
    else
        echo "  NVM: KURULU DEĞİL"
    fi
    command -v node &>/dev/null && echo "  Node.js: $(node --version)" || echo "  Node.js: KURULU DEĞİL"
    command -v npm &>/dev/null && echo "  npm: $(npm --version)" || echo "  npm: KURULU DEĞİL"
    command -v bun &>/dev/null && echo "  Bun: $(bun --version)" || echo "  Bun: KURULU DEĞİL"
    echo ""

    echo -e "${CYAN}PHP Ekosistemi:${NC}"
    command -v php &>/dev/null && echo "  PHP: $(php --version | head -n1 | awk '{print $2}')" || echo "  PHP: KURULU DEĞİL"
    command -v composer &>/dev/null && echo "  Composer: $(composer --version 2>/dev/null | awk '{print $3}')" || echo "  Composer: KURULU DEĞİL"
    local php_count=0
    if command -v update-alternatives &>/dev/null && command -v php &>/dev/null; then
        php_count=$(update-alternatives --list php 2>/dev/null | wc -l)
        [ "$php_count" -gt 0 ] && echo "  PHP Versiyonları: $php_count adet"
    fi
    echo ""

    echo -e "${CYAN}Go Language:${NC}"
    command -v go &>/dev/null && echo "  Go: $(go version | awk '{print $3}' | sed 's/go//')" || echo "  Go: KURULU DEĞİL"
    [ -n "$GOPATH" ] && echo "  GOPATH: $GOPATH"
    [ -n "$GOROOT" ] && echo "  GOROOT: $GOROOT"
    echo ""

    echo -e "${CYAN}Modern CLI Araçları:${NC}"
    command -v batcat &>/dev/null && echo "  bat: $(batcat --version | awk '{print $2}')" || echo "  bat: KURULU DEĞİL"
    command -v eza &>/dev/null && echo "  eza: $(eza --version | head -n1 | awk '{print $2}')" || echo "  eza: KURULU DEĞİL"
    command -v rg &>/dev/null && echo "  ripgrep: $(rg --version | head -n1 | awk '{print $2}')" || echo "  ripgrep: KURULU DEĞİL"
    command -v fdfind &>/dev/null && echo "  fd: $(fdfind --version | awk '{print $2}')" || echo "  fd: KURULU DEĞİL"
    command -v starship &>/dev/null && echo "  starship: $(starship --version | awk '{print $2}')" || echo "  starship: KURULU DEĞİL"
    command -v zoxide &>/dev/null && echo "  zoxide: $(zoxide --version | awk '{print $2}')" || echo "  zoxide: KURULU DEĞİL"
    command -v fzf &>/dev/null && echo "  fzf: $(fzf --version | awk '{print $1}')" || echo "  fzf: KURULU DEĞİL"
    command -v lazygit &>/dev/null && echo "  lazygit: $(lazygit --version | grep version | awk '{print $6}' | tr -d ',')" || echo "  lazygit: KURULU DEĞİL"
    command -v lazydocker &>/dev/null && echo "  lazydocker: $(lazydocker --version | grep Version | awk '{print $2}')" || echo "  lazydocker: KURULU DEĞİL"
    echo ""

    echo -e "${CYAN}AI CLI Araçları:${NC}"
    command -v claude &>/dev/null && echo "  Claude Code: KURULU ✓" || echo "  Claude Code: KURULU DEĞİL"
    command -v gh &>/dev/null && echo "  GitHub CLI: $(gh --version | head -n1 | awk '{print $3}')" || echo "  GitHub CLI: KURULU DEĞİL"
    command -v gemini-cli &>/dev/null && echo "  Gemini CLI: KURULU ✓" || echo "  Gemini CLI: KURULU DEĞİL"
    echo ""

    echo -e "${CYAN}AI Frameworks:${NC}"
    [ -d "$HOME/SuperGemini" ] && echo "  SuperGemini: KURULU ✓" || echo "  SuperGemini: KURULU DEĞİL"
    [ -d "$HOME/SuperQwen" ] && echo "  SuperQwen: KURULU ✓" || echo "  SuperQwen: KURULU DEĞİL"
    [ -d "$HOME/SuperClaude" ] && echo "  SuperClaude: KURULU ✓" || echo "  SuperClaude: KURULU DEĞİL"
    echo ""

    echo -e "${CYAN}Docker:${NC}"
    command -v docker &>/dev/null && echo "  Docker: $(docker --version | awk '{print $3}' | tr -d ',')" || echo "  Docker: KURULU DEĞİL"
    if command -v docker &>/dev/null; then
        docker ps &>/dev/null && echo "  Docker Daemon: ÇALIŞIYOR ✓" || echo "  Docker Daemon: DURDURULMUŞ"
        groups | grep -q docker && echo "  Docker Group: KULLANICI EKLENMIŞ ✓" || echo "  Docker Group: KULLANICI EKLENMEMİŞ"
    fi
    echo ""

    echo -e "${BOLD}[SHELL ORTAMI]${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Shell: $SHELL"
    [ -f "$HOME/.bash_aliases" ] && echo ".bash_aliases: MEVCUT ($(grep -c '^alias' "$HOME/.bash_aliases") alias)" || echo ".bash_aliases: BULUNAMADI"
    [ -f "$HOME/.bashrc" ] && echo ".bashrc: MEVCUT" || echo ".bashrc: BULUNAMADI"
    grep -q "1453" "$HOME/.bashrc" 2>/dev/null && echo "1453 WSL Setup Config: AKTIF ✓" || echo "1453 WSL Setup Config: BULUNAMADI"
    grep -q "starship" "$HOME/.bashrc" 2>/dev/null && echo "Starship Prompt: AKTIF ✓" || echo "Starship Prompt: PASIF"
    grep -q "zoxide" "$HOME/.bashrc" 2>/dev/null && echo "Zoxide: AKTIF ✓" || echo "Zoxide: PASIF"
    grep -q "FZF" "$HOME/.bashrc" 2>/dev/null && echo "FZF Integration: AKTIF ✓" || echo "FZF Integration: PASIF"
    echo ""

    echo -e "${BOLD}[DİZİNLER]${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    [ -d "$HOME/.1453-wsl-setup" ] && echo "1453 Setup: $HOME/.1453-wsl-setup ✓" || echo "1453 Setup: BULUNAMADI"
    [ -d "$HOME/.nvm" ] && echo "NVM: $HOME/.nvm ✓" || echo "NVM: BULUNAMADI"
    [ -d "$HOME/.config" ] && echo "Config: $HOME/.config ✓" || echo "Config: BULUNAMADI"
    [ -d "$HOME/go" ] && echo "Go Workspace: $HOME/go ✓" || echo "Go Workspace: BULUNAMADI"
    echo ""

    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Snapshot raporu tamamlandı!${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
}

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
            if [ $# -lt 2 ] || [[ "${2:-}" == -* ]]; then
                echo -e "${RED}Error: --log requires a filename${NC}"
                show_usage
                exit 1
            fi
            LOG_FILE="$2"
            shift 2
            ;;
        -s|--snapshot)
            SNAPSHOT_MODE=true
            shift
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

# Snapshot modu kontrolü
if [ "$SNAPSHOT_MODE" = true ]; then
    # Snapshot modunda sadece röntgen raporu göster
    if [ -n "$LOG_FILE" ]; then
        generate_snapshot | tee -a "$LOG_FILE"
    else
        generate_snapshot
    fi
    exit 0
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
test_aliases
test_missing_installations
test_functional

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
