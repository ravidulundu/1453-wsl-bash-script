#!/bin/bash

# 1453.AI WSL Kurulum Betiği Yükleyici
# Bu betik modüler WSL kurulum betiğini indirir ve kurar
#
# USAGE:
#   Basic (rate limit: 60 req/hour):
#     bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
#
#   With GitHub token (rate limit: 5000 req/hour):
#     export GITHUB_TOKEN="ghp_xxxxx"
#     bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
#
#   Get token: https://github.com/settings/tokens (select 'repo' scope)

# FIX BUG-002: Add safety flags for robust error handling
set -euo pipefail

# FIX BUG-013: Ensure running with bash, not sh
if [ -z "${BASH_VERSION:-}" ]; then
    echo "Error: This script must be run with bash, not sh"
    echo "Usage: bash install.sh"
    exit 1
fi

# CRITICAL FIX: Don't use exec for stdin redirection
# exec causes the installer to hang when piped (e.g., bash <(curl ...))
# All interactive prompts use explicit /dev/tty redirection instead
# This line is commented out to prevent hanging
# if [ -e /dev/tty ]; then
#     exec 0</dev/tty 2>/dev/null || true
# fi

# ==============================================================================
# PRD: THEME CONFIGURATION (Crimson & Gold)
# Based on: docs/reports/dev-kurulun-cli-prd.md Section 2.1
# ==============================================================================

# 24-bit TrueColor Support (PRD Requirement)
COLOR_CRIMSON="#DC143C"      # Primary brand color
COLOR_GOLD="#FFD700"         # Secondary borders/icons
COLOR_TEXT="#F5F5F5"         # Off-white text
COLOR_ERROR="#FF0000"        # Errors
COLOR_SUCCESS="#008080"      # Teal - completed operations
COLOR_WARNING="#FFA500"      # Orange - warnings
COLOR_INFO="#1E90FF"         # Blue - information

# ANSI Fallback Colors (8-bit terminals)
COLOR_CRIMSON_FG="212"       # Approximate crimson
COLOR_GOLD_FG="220"          # Approximate gold
COLOR_TEXT_FG="255"          # White
COLOR_ERROR_FG="196"         # Red
COLOR_SUCCESS_FG="30"        # Teal
COLOR_WARNING_FG="214"       # Orange
COLOR_INFO_FG="33"           # Blue

# Legacy color codes (backward compatibility)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Renk Yok

# GitHub depo bilgileri
REPO_OWNER="ravidulundu"
REPO_NAME="1453-wsl-bash-script"
BRANCH="master"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# GitHub Token Support (Optional - prevents rate limiting)
# Rate Limit: Without token = 60 requests/hour
#             With token    = 5000 requests/hour
# Usage: export GITHUB_TOKEN="ghp_xxxxx" before running this script
# Get token: https://github.com/settings/tokens (repo scope needed)
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Kurulum dizini
INSTALL_DIR="$HOME/.1453-wsl-setup"

# SECURITY FIX K-4: Validate critical path variables
if [ -z "${HOME:-}" ]; then
    echo "FATAL ERROR: HOME variable is not set!"
    exit 1
fi

if [ -z "${INSTALL_DIR:-}" ]; then
    echo "FATAL ERROR: INSTALL_DIR variable is not set!"
    exit 1
fi

# Ensure INSTALL_DIR is not root or system directory
case "$INSTALL_DIR" in
    /|/bin|/sbin|/usr|/usr/bin|/usr/sbin|/etc|/var|/tmp|/boot)
        echo "FATAL ERROR: INSTALL_DIR points to system directory: $INSTALL_DIR"
        echo "This is a security risk. Installation aborted."
        exit 1
        ;;
esac

# Detect terminal width
TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)

# Track if banner has been shown (prevents flicker)
BANNER_SHOWN=0

# ASCII Art Banner
show_banner() {
    # ONLY clear screen on first call (prevents flicker)
    if [ "$BANNER_SHOWN" -eq 0 ]; then
        clear
        BANNER_SHOWN=1
    fi

    # Re-detect terminal width (in case terminal was resized)
    TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)

    if has_gum; then
        # Calculate responsive widths and margins for centering
        local content_width=80
        if [ "$TUI_WIDTH" -lt 100 ]; then
            content_width=60  # Narrow terminals
        fi

        # Calculate left margin to center content
        local left_margin=$(( (TUI_WIDTH - content_width) / 2 ))
        [ $left_margin -lt 0 ] && left_margin=0

        # Check terminal width for responsiveness (100 chars threshold)
        if [ -n "${TUI_WIDTH:-}" ] && [ "$TUI_WIDTH" -lt 100 ]; then
            # Terminal too narrow - show compact banner (CENTERED with margin)
            gum style \
                --foreground 212 --bold --align center \
                --width "$content_width" --margin "0 $left_margin" \
                "1453.AI WSL Setup"
            echo ""
            gum style \
                --foreground 51 --align center \
                --width "$content_width" --margin "0 $left_margin" \
                "🚀 Hızlı Yükleyici"
            echo ""
        else
            # Wide terminal - ASCII art (CENTERED with margin)
            # ASCII art width is 45 chars
            local ascii_width=50
            local ascii_margin=$(( (TUI_WIDTH - ascii_width) / 2 ))
            [ $ascii_margin -lt 0 ] && ascii_margin=0

            gum style \
                --foreground 51 --bold \
                --align center \
                --width "$ascii_width" --margin "0 $ascii_margin" \
                '   /$$ /$$   /$$ /$$$$$$$   /$$$$$$ ' \
                ' /$$$$| $$  | $$| $$____/  /$$__  $$' \
                '|_  $$| $$  | $$| $$      |__/  \ $$' \
                '  | $$| $$$$$$$$| $$$$$$$    /$$$$$$/' \
                '  | $$|_____  $$|_____  $$  |___  $$' \
                '  | $$      | $$ /$$  \ $$ /$$  \ $$' \
                ' /$$$$$$    | $$|  $$$$$$/|  $$$$$$/' \
                '|______/    |__/ \______/  \______/ '

            echo ""

            # Title (CENTERED with margin) - PRD FR-1.2: Double border, Gold
            local title_width=70
            if [ "$TUI_WIDTH" -lt 90 ]; then
                title_width=60
            fi
            local title_margin=$(( (TUI_WIDTH - title_width) / 2 ))
            [ $title_margin -lt 0 ] && title_margin=0

            # PRD FR-1.2: "1453 WSL Architect" başlığı, double border, gold renk
            gum style \
                --foreground "$COLOR_CRIMSON_FG" \
                --border double \
                --border-foreground "$COLOR_GOLD_FG" \
                --align center \
                --width "$title_width" --margin "0 $title_margin" --padding "1 2" \
                --bold \
                "1453 WSL ARCHITECT" "" "Hızlı Yükleyici v2.5"

            echo ""
        fi
    else
        # Traditional ASCII banner (fallback with padding)
        echo ""
        echo -e "  ${CYAN}🚀 1453 WSL ARCHITECT - Hızlı Yükleyici${NC}"
        echo ""
    fi
}

# Helper function to prepare curl options with retry logic
# Returns curl options as array via nameref
prepare_curl_opts() {
    local -n opts_ref=$1
    opts_ref=(
        -fsSL
        --connect-timeout 10
        --max-time 30
        --retry 3
        --retry-delay 2
        --retry-max-time 60
    )
    if [ -n "$GITHUB_TOKEN" ]; then
        opts_ref+=(-H "Authorization: token $GITHUB_TOKEN")
    fi
}

# Dosya indirme fonksiyonu (verbose mod)
download_file() {
    local url="$1"
    local dest="$2"
    local desc="$3"

    # Prepare curl command with optional GitHub token
    local curl_cmd="curl -fsSL"
    if [ -n "$GITHUB_TOKEN" ]; then
        curl_cmd="curl -fsSL -H \"Authorization: token $GITHUB_TOKEN\""
    fi

    if has_gum; then
        if eval "$curl_cmd \"$url\" -o \"$dest\"" 2>/dev/null; then
            return 0
        else
            gum style --foreground 196 "[✗] İndirilemedi: $desc"
            return 1
        fi
    else
        echo -ne "  ${YELLOW}[İNDİRİLİYOR]${NC} $desc\r"
        if eval "$curl_cmd \"$url\" -o \"$dest\"" 2>/dev/null; then
            echo -e "  ${GREEN}[✓]${NC} $desc        "
            return 0
        else
            echo -e "  ${RED}[✗]${NC} İndirilemedi: $desc"
            return 1
        fi
    fi
}

# Check if Gum is available
has_gum() {
    command -v gum &>/dev/null
}

# ==============================================================================
# PRD: GUM WRAPPER FUNCTIONS (Section 4.3)
# Inline minimal versions for install.sh
# ==============================================================================

# Info Box (Blue/Crimson Info Box)
gum_info() {
    local title="$1"
    local message="$2"

    if has_gum; then
        gum style \
            --foreground "$COLOR_INFO_FG" \
            --border rounded \
            --border-foreground "$COLOR_INFO_FG" \
            --padding "1 2" \
            --margin "1 0" \
            --align center \
            "ℹ️  $title" "" "$message"
    else
        echo -e "${BLUE}[ℹ️  $title]${NC} $message"
    fi
}

# Success Box (Teal Success Box)
gum_success() {
    local title="$1"
    local message="$2"

    if has_gum; then
        gum style \
            --foreground "$COLOR_SUCCESS_FG" \
            --border rounded \
            --border-foreground "$COLOR_SUCCESS_FG" \
            --padding "1 2" \
            --margin "1 0" \
            --align center \
            "✅ $title" "" "$message"
    else
        echo -e "${GREEN}[✅ $title]${NC} $message"
    fi
}

# Alert Box (Red Error Box)
gum_alert() {
    local title="$1"
    local message="$2"

    if has_gum; then
        gum style \
            --foreground "$COLOR_ERROR_FG" \
            --border rounded \
            --border-foreground "$COLOR_ERROR_FG" \
            --padding "1 2" \
            --margin "1 0" \
            --align center \
            "❌ $title" "" "$message"
    else
        echo -e "${RED}[❌ $title]${NC} $message"
    fi
}

# Warning Box (Orange Warning Box)
gum_warning() {
    local title="$1"
    local message="$2"

    if has_gum; then
        gum style \
            --foreground "$COLOR_WARNING_FG" \
            --border rounded \
            --border-foreground "$COLOR_WARNING_FG" \
            --padding "1 2" \
            --margin "1 0" \
            --align center \
            "⚠️  $title" "" "$message"
    else
        echo -e "${YELLOW}[⚠️  $title]${NC} $message"
    fi
}

# AI Thinking State (PRD Section 2.2)
show_ai_thinking() {
    local context="$1"
    local duration="${2:-2}"

    # AI Contextual Messages (PRD FR-2.4)
    local message="⏳ İşlem devam ediyor..."
    case "$context" in
        init) message="🏗️  Ortam hazırlanıyor..." ;;
        downloading) message="📦 Dosyalar indiriliyor..." ;;
        installing) message="⚙️  Bileşenler yükleniyor..." ;;
        verifying) message="✓  Doğrulama yapılıyor..." ;;
        complete) message="🎉 İşlem tamamlandı!" ;;
    esac

    if has_gum; then
        gum spin --spinner dot --title "$message" -- sleep "$duration"
    else
        echo -n "$message "
        for ((i=0; i<duration; i++)); do
            echo -n "."
            sleep 1
        done
        echo " ✓"
    fi
}

# Install Gum for modern TUI
install_gum_minimal() {
    echo ""
    echo -e "  ${CYAN}[BİLGİ]${NC} Modern TUI (Gum) kuruluyor..."

    if has_gum; then
        echo -e "  ${GREEN}[✓]${NC} Gum zaten kurulu"
        return 0
    fi

    # Detect package manager
    local pkg_mgr=""
    if command -v apt &>/dev/null; then
        pkg_mgr="apt"
    elif command -v dnf &>/dev/null; then
        pkg_mgr="dnf"
    elif command -v yum &>/dev/null; then
        pkg_mgr="yum"
    elif command -v pacman &>/dev/null; then
        pkg_mgr="pacman"
    else
        echo -e "  ${YELLOW}[!]${NC} Paket yöneticisi bulunamadı, Gum kurulumu atlanıyor"
        return 1
    fi

    # Install Gum silently
    case $pkg_mgr in
        apt)
            sudo mkdir -p /etc/apt/keyrings 2>/dev/null
            # FIX BUG-033: Download key to temp file first to avoid pipe+sudo issues
            local temp_keyring
            temp_keyring=$(mktemp)
            if curl -fsSL https://repo.charm.sh/apt/gpg.key -o "$temp_keyring" 2>/dev/null; then
                sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg < "$temp_keyring" 2>/dev/null
                rm -f "$temp_keyring"
            else
                rm -f "$temp_keyring"
                # Fallback to pipe if temp file fails (unlikely but safe fallback)
                curl -fsSL https://repo.charm.sh/apt/gpg.key 2>/dev/null | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
            fi
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
            sudo apt update -qq 2>/dev/null
            sudo apt install -y gum >/dev/null 2>&1
            ;;
        dnf|yum)
            echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo >/dev/null
            sudo ${pkg_mgr} install -y gum >/dev/null 2>&1
            ;;
        pacman)
            sudo pacman -S --noconfirm gum >/dev/null 2>&1
            ;;
    esac

    if has_gum; then
        echo -e "  ${GREEN}[✓]${NC} Gum kuruldu!"
        return 0
    else
        echo -e "  ${YELLOW}[!]${NC} Gum kurulamadı, klasik TUI kullanılacak"
        return 1
    fi
}

# Ana kurulum fonksiyonu
main() {
    show_banner

    # FIX: Install Gum FIRST before using any gum functions
    # This ensures modern UI works from the start
    install_gum_minimal

    # PRD: Use AI thinking state for initialization (FR-2.4)
    show_ai_thinking "init" 1

    # PRD: Use gum_info wrapper (Gum is now installed)
    echo ""
    
    # PRD FR-1.3: System Analysis
    if has_gum; then
        # Analyze system
        local wsl_version="WSL 2" # Default assumption
        if [ -n "${WSL_DISTRO_NAME:-}" ]; then
            # Try to detect version if possible, otherwise stick to default
            if grep -qi "WSL2" /proc/version 2>/dev/null; then
                wsl_version="WSL 2"
            fi
        fi
        
        local distro_name="${WSL_DISTRO_NAME:-Linux}"
        if [ "$distro_name" = "Linux" ] && [ -f /etc/os-release ]; then
            distro_name=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
        fi

        # Show analysis spinner
        gum spin --spinner dot --title "Sistem analiz ediliyor..." -- sleep 1.5
        
        # Show system info card
        gum style \
            --foreground "$COLOR_INFO_FG" \
            --border rounded \
            --border-foreground "$COLOR_GOLD_FG" \
            --padding "0 1" \
            --margin "1 0" \
            --align center \
            "💻 Sistem: $distro_name" "🚀 Ortam: $wsl_version"
            
        echo ""
    fi

    # PRD Section 2.2: Streaming Text (Typewriter Effect)
    local welcome_msg="1453.AI WSL Kurulum Betiği yükleniyor..."
    if has_gum; then
        # Simulate typing effect
        for (( i=0; i<${#welcome_msg}; i++ )); do
            echo -n "${welcome_msg:$i:1}"
            sleep 0.03
        done
        echo ""
    else
        gum_info "Başlatma" "$welcome_msg"
    fi
    echo ""

    if has_gum; then
        gum style \
            --foreground "$COLOR_TEXT_FG" \
            --align center \
            "Kurulum Dizini: ${INSTALL_DIR}"
    else
        echo -e "  Kurulum Dizini: ${INSTALL_DIR}"
    fi
    echo ""

    # curl kontrolü
    if ! command -v curl &> /dev/null; then
        gum_alert "Eksik Bağımlılık" "curl gerekli ama kurulu değil"
        echo ""
        gum_warning "İpucu" "curl'ü kurmak için: sudo apt install curl"
        exit 1
    fi

    # Kurulum dizin yapısını oluştur
    # PRD: Use AI thinking while performing operation
    if has_gum; then
        gum spin --spinner dot --title "🏗️  Dizin yapısı oluşturuluyor..." -- \
            mkdir -p "${INSTALL_DIR}/src"/{lib,config,modules} "${INSTALL_DIR}/templates"
    else
        echo "🏗️  Dizin yapısı oluşturuluyor..."
        mkdir -p "${INSTALL_DIR}/src"/{lib,config,modules} "${INSTALL_DIR}/templates"
    fi

    # PRD: Use gum_success wrapper
    echo ""
    gum_success "Hazırlık Tamamlandı" "Dizin yapısı oluşturuldu"
    echo ""

    # ==============================================================================
    # ZIP DOWNLOAD STRATEGY (Rate Limit Bypass)
    # ==============================================================================
    
    # Ensure unzip is installed
    if ! command -v unzip &>/dev/null; then
        local install_cmd=""
        if command -v apt &>/dev/null; then
            install_cmd="sudo apt update -qq >/dev/null 2>&1 && sudo apt install -y unzip >/dev/null 2>&1"
        elif command -v dnf &>/dev/null; then
            install_cmd="sudo dnf install -y unzip >/dev/null 2>&1"
        elif command -v pacman &>/dev/null; then
            install_cmd="sudo pacman -S --noconfirm unzip >/dev/null 2>&1"
        fi

        if [ -n "$install_cmd" ]; then
            if has_gum; then
                gum spin --spinner dot --title "Arşiv açıcı (unzip) kuruluyor..." -- bash -c "$install_cmd"
            else
                gum_info "Hazırlık" "Arşiv açıcı (unzip) kuruluyor..."
                eval "$install_cmd"
            fi
        fi
    fi

    # PRD: Use AI contextual message (FR-2.4)
    echo ""
    gum_info "İndirme Başlıyor" "Tüm proje tek paket olarak indiriliyor..."
    echo ""

    # Download ZIP archive
    local zip_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/${BRANCH}.zip"
    local temp_zip="/tmp/1453-wsl.zip"
    local temp_dir="/tmp/1453-wsl-extracted"

    # Clean previous temp files
    rm -rf "$temp_zip" "$temp_dir"

    # PRD: Show AI thinking state while downloading
    if has_gum; then
        gum spin --spinner dot --title "📦 Proje arşivi indiriliyor..." -- \
            curl -fsSL "$zip_url" -o "$temp_zip"
    else
        echo "📦 Proje arşivi indiriliyor..."
        curl -fsSL "$zip_url" -o "$temp_zip"
    fi

    if [ ! -f "$temp_zip" ]; then
        gum_alert "İndirme Hatası" "Proje arşivi indirilemedi. İnternet bağlantınızı kontrol edin."
        exit 1
    fi

    # Extract ZIP
    if has_gum; then
        gum spin --spinner dot --title "📂 Arşiv açılıyor ve yerleştiriliyor..." -- \
            unzip -q "$temp_zip" -d "$temp_dir"
    else
        echo "📂 Arşiv açılıyor ve yerleştiriliyor..."
        unzip -q "$temp_zip" -d "$temp_dir"
    fi

    # Move files to INSTALL_DIR
    # The zip extracts to a folder named REPO-BRANCH (e.g., 1453-wsl-bash-script-master)
    # We need to find it dynamically
    local extracted_root
    extracted_root=$(find "$temp_dir" -maxdepth 1 -type d -name "${REPO_NAME}-*" | head -n 1)

    if [ -d "$extracted_root" ]; then
        # Copy src, templates, and docs
        cp -r "${extracted_root}/src" "${INSTALL_DIR}/"
        cp -r "${extracted_root}/templates" "${INSTALL_DIR}/"
        
        # Cleanup
        rm -rf "$temp_zip" "$temp_dir"
        
        # PRD: Show AI completion state
        show_ai_thinking "complete" 1
        echo ""
        gum_success "İndirme Tamamlandı" "Tüm dosyalar başarıyla kuruldu"
        echo ""
    else
        gum_alert "Kurulum Hatası" "Arşiv içeriği hatalı veya boş."
        exit 1
    fi

    # Skip the old file loop logic since we downloaded everything
    failed=0

    # Ana betiği çalıştırılabilir yap
    chmod +x "${INSTALL_DIR}/src/linux-ai-setup-script.sh"

    # Kullanışlı bir başlatıcı betiği oluştur
    if has_gum; then
        # Calculate margin for centering
        local msg_width=60
        local msg_margin=$(( (TUI_WIDTH - msg_width) / 2 ))
        [ $msg_margin -lt 0 ] && msg_margin=0

        gum style \
            --foreground 226 \
            --width "$msg_width" --margin "0 $msg_margin" \
            "[KURULUM] Başlatıcı betiği oluşturuluyor..."
    else
        echo -e "  ${YELLOW}[KURULUM]${NC} Başlatıcı betiği oluşturuluyor..."
    fi
    # FIX BUG-017: Use unique heredoc delimiter to prevent conflicts
    cat > "${INSTALL_DIR}/1453-setup" << 'END_OF_LAUNCHER_SCRIPT'
#!/bin/bash
# 1453.AI WSL Kurulum Başlatıcı

# CRITICAL FIX: Don't use exec for stdin redirection
# exec causes the script to hang when stdin is already redirected
# The main script handles all input redirection internally

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Simply run the main script
bash "${SCRIPT_DIR}/src/linux-ai-setup-script.sh" "$@"
END_OF_LAUNCHER_SCRIPT

    chmod +x "${INSTALL_DIR}/1453-setup"
    if has_gum; then
        # Calculate margin for centering
        local msg_width=60
        local msg_margin=$(( (TUI_WIDTH - msg_width) / 2 ))
        [ $msg_margin -lt 0 ] && msg_margin=0

        gum style \
            --foreground 82 \
            --width "$msg_width" --margin "0 $msg_margin" \
            "[✓] Başlatıcı betiği oluşturuldu"
        echo ""
    else
        echo -e "  ${GREEN}[✓]${NC} Başlatıcı betiği oluşturuldu"
        echo ""
    fi

    # Install Gum for modern TUI (Already installed at start, check again just in case)
    # install_gum_minimal

    # PRD FR-3.3: Windows Interop - Nerd Font Check
    # Since we cannot easily check Windows fonts from WSL, we perform a visual test
    if grep -q "Microsoft" /proc/version 2>/dev/null && has_gum; then
        echo ""
        gum_info "Font Kontrolü" "İkonların düzgün görünmesi için Nerd Font gereklidir"
        
        # Display test icons
        echo ""
        gum style \
            --border rounded \
            --border-foreground "$COLOR_GOLD_FG" \
            --align center \
            --margin "0 2" \
            --padding "1 2" \
            "        🚀  📦" \
            "" \
            "Yukarıdaki ikonları görebiliyor musunuz?"
            
        if ! gum confirm "İkonlar düzgün görünüyor mu?"; then
            echo ""
            gum_warning "Eksik Font Tespit Edildi" "Görünüşe göre Nerd Font yüklü değil veya terminal ayarlı değil."
            
            echo ""
            gum style \
                --foreground "$COLOR_INFO_FG" \
                --align center \
                "Windows Terminal (PowerShell) üzerinde şu komutu çalıştırarak yükleyebilirsiniz:"
            
            echo ""
            gum style \
                --border normal \
                --border-foreground "$COLOR_CRIMSON_FG" \
                --padding "1 2" \
                --align center \
                "winget install -e --id RyanLlamas.MesloLGM_NF"
                
            echo ""
            gum style --foreground "$COLOR_MUTED_FG" "Not: Yüklemeden sonra Windows Terminal ayarlarından fontu seçmeyi unutmayın."
            
            echo ""
            gum input --placeholder "Okudum, devam etmek için Enter'a basın..." --password >/dev/null
        else
            echo ""
            gum_success "Font Doğrulandı" "Terminal ortamınız kullanıma hazır"
        fi
    fi

    # Kurulum başarılı mesajı (with Gum if available)
    echo ""
    if has_gum; then
        # Re-detect terminal width (in case terminal was resized)
        TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)

        # Calculate responsive width and margin for centering
        local box_width=60
        if [ "$TUI_WIDTH" -gt 90 ]; then
            box_width=70
        fi
        # Ensure box never exceeds terminal width - 10
        [ "$box_width" -gt $((TUI_WIDTH - 10)) ] && box_width=$((TUI_WIDTH - 10))

        # Compact success message (spinner style - doesn't push terminal down)
        echo ""
        gum style --foreground 82 "✅ Kurulum Tamamlandı! 1453.AI WSL Setup yüklendi"
        echo ""

        # Calculate margin for other messages
        local msg_width=60
        local msg_margin=$(( (TUI_WIDTH - msg_width) / 2 ))
        [ $msg_margin -lt 0 ] && msg_margin=0

        gum style \
            --foreground 226 \
            --width "$msg_width" --margin "0 $msg_margin" \
            "📌 Çalıştırma:"
        echo ""
        gum style \
            --width "$msg_width" --margin "0 $msg_margin" \
            "  ${INSTALL_DIR}/1453-setup"
        echo ""
        gum style \
            --foreground 51 \
            --width "$msg_width" --margin "0 $msg_margin" \
            "💡 Güncellemek için installer'ı tekrar çalıştırın"
    else
        # Fallback: Traditional message with padding
        echo -e "  ${CYAN}[BİLGİ]${NC} Kurulum başarıyla tamamlandı!"
        echo ""
        echo -e "  ${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "  ${GREEN}                    Kurulum Tamamlandı!                        ${NC}"
        echo -e "  ${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "  ${YELLOW}Kurulum betiğini çalıştırmak için şu yöntemlerden birini kullanın:${NC}"
        echo ""
        echo -e "    1. Doğrudan çalıştırma:"
        echo -e "       ${GREEN}${INSTALL_DIR}/1453-setup${NC}"
        echo ""
        echo -e "    2. PATH'e ekleyerek kolay erişim (isteğe bağlı):"
        echo -e "       ${GREEN}echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.bashrc${NC}"
        echo -e "       ${GREEN}source ~/.bashrc${NC}"
        echo -e "       ${GREEN}1453-setup${NC}"
        echo ""
        echo -e "    3. Takma ad (alias) oluşturma (isteğe bağlı):"
        echo -e "       ${GREEN}echo 'alias 1453=\"${INSTALL_DIR}/1453-setup\"' >> ~/.bashrc${NC}"
        echo -e "       ${GREEN}source ~/.bashrc${NC}"
        echo -e "       ${GREEN}1453${NC}"
        echo ""
        echo -e "  ${CYAN}[İPUCU]${NC} Betik şu dizinde kurulu: ${INSTALL_DIR}"
        echo -e "  ${CYAN}[İPUCU]${NC} Güncellemek için bu yükleyiciyi tekrar çalıştırın"
    fi

    echo ""

    # Kullanıcıya kurulum betiğini şimdi çalıştırmak isteyip istemediğini sor
    # SECURITY FIX Y-3: Check if /dev/tty is available before using it
    if [ ! -c /dev/tty ]; then
        echo -e "  ${YELLOW}[!]${NC} Non-interactive mode detected (/dev/tty not available)"
        echo -e "  ${CYAN}[BİLGİ]${NC} Kurulum betiğini daha sonra çalıştırabilirsiniz:"
        echo -e "  ${GREEN}${INSTALL_DIR}/1453-setup${NC}"
        return 0
    fi

    if has_gum; then
        # Modern Gum confirm
        if gum confirm "Kurulum betiğini şimdi çalıştırmak ister misiniz?"; then
            echo ""

            # Calculate margin for centering
            local msg_width=60
            local msg_margin=$(( (TUI_WIDTH - msg_width) / 2 ))
            [ $msg_margin -lt 0 ] && msg_margin=0

            gum style \
                --foreground 82 \
                --width "$msg_width" --margin "0 $msg_margin" \
                "🚀 Kurulum betiği başlatılıyor..."
            sleep 1
            bash "${INSTALL_DIR}/1453-setup" </dev/tty
        else
            echo ""

            # Calculate margin for centering
            local msg_width=60
            local msg_margin=$(( (TUI_WIDTH - msg_width) / 2 ))
            [ $msg_margin -lt 0 ] && msg_margin=0

            gum style \
                --foreground 51 \
                --width "$msg_width" --margin "0 $msg_margin" \
                "👉 Daha sonra çalıştırmak için: ${INSTALL_DIR}/1453-setup"
        fi
    else
        # Fallback: Traditional prompt with padding
        echo -e "  ${YELLOW}════════════════════════════════════════════════════════════════${NC}"
        echo -ne "  ${YELLOW}Kurulum betiğini şimdi çalıştırmak ister misiniz? (e/E=Evet, Enter=Hayır): ${NC}"

        # stdin'i terminal'e yönlendir (pipe'dan okuma sorunu için)
        if [ -t 0 ]; then
            read -r response
        else
            read -r response </dev/tty
        fi

        if [[ "$response" =~ ^[eE]$ ]]; then
            echo ""
            echo -e "  ${GREEN}[BİLGİ]${NC} Kurulum betiği başlatılıyor..."
            # Run with stdin explicitly from /dev/tty
            bash "${INSTALL_DIR}/1453-setup" </dev/tty
        else
            echo ""
            echo -e "  ${CYAN}[BİLGİ]${NC} Kurulum betiğini daha sonra çalıştırabilirsiniz:"
            echo -e "  ${GREEN}${INSTALL_DIR}/1453-setup${NC}"
            echo ""
        fi
    fi
}

# Yükleyiciyi çalıştır
main "$@"
