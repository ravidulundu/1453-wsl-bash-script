#!/bin/bash

# 1453.AI WSL Kurulum Betiği Yükleyici
# Bu betik modüler WSL kurulum betiğini indirir ve kurar

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

# Renkli çıktı için tanımlamalar
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

# Calculate responsive margin
calculate_margin() {
    local margin=2
    if [ -n "${TUI_WIDTH:-}" ] && [ "$TUI_WIDTH" -gt 100 ]; then
        margin=$((($TUI_WIDTH - 80) / 2))
        [ "$margin" -lt 2 ] && margin=2
        [ "$margin" -gt 10 ] && margin=10
    fi
    echo "$margin"
}

# Gum style wrapper with responsive padding
gum_print() {
    if has_gum; then
        local margin=$(calculate_margin)
        gum style --margin "0 $margin" "$@"
    else
        echo -e "  ${CYAN}${!#}${NC}"
    fi
}

# ASCII Art Banner
show_banner() {
    clear

    # Re-detect terminal width (in case terminal was resized)
    TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)

    if has_gum; then
        # Check terminal width for responsiveness (100 chars threshold)
        if [ -n "${TUI_WIDTH:-}" ] && [ "$TUI_WIDTH" -lt 100 ]; then
            # Terminal too narrow - show compact banner
            gum style \
                --foreground 212 --bold --align center \
                "1453.AI WSL Setup"
            echo ""
            gum style --foreground 51 --align center "🚀 Hızlı Yükleyici"
            echo ""
        else
            # Wide terminal - use margin for centering
            local margin=$(calculate_margin)

            # Modern Gum banner - ASCII art (centered with margin)
            gum style \
                --foreground 51 --bold \
                --align left --margin "0 $margin" \
                '   /$$ /$$   /$$ /$$$$$$$   /$$$$$$ ' \
                ' /$$$$| $$  | $$| $$____/  /$$__  $$' \
                '|_  $$| $$  | $$| $$      |__/  \ $$' \
                '  | $$| $$$$$$$$| $$$$$$$    /$$$$$$/' \
                '  | $$|_____  $$|_____  $$  |___  $$' \
                '  | $$      | $$ /$$  \ $$ /$$  \ $$' \
                ' /$$$$$$    | $$|  $$$$$$/|  $$$$$$/' \
                '|______/    |__/ \______/  \______/ '

            echo ""

            # Title (centered with margin)
            gum style \
                --foreground 212 --border rounded --align center \
                --width 70 --margin "0 $margin" --padding "1 2" \
                "🚀 1453.AI WSL Kurulum Betiği - Hızlı Yükleyici"

            echo ""
        fi
    else
        # Traditional ASCII banner (fallback with padding)
        echo ""
        echo -e "  ${CYAN}🚀 1453.AI WSL Kurulum Betiği - Hızlı Yükleyici${NC}"
        echo ""
    fi
}

# Dosya indirme fonksiyonu (sessiz mod için)
download_file_silent() {
    local url="$1"
    local dest="$2"
    curl -fsSL "$url" -o "$dest" 2>/dev/null
}

# Dosya indirme fonksiyonu (verbose mod)
download_file() {
    local url="$1"
    local dest="$2"
    local desc="$3"

    if has_gum; then
        if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
            return 0
        else
            gum_print --foreground 196 "[✗] İndirilemedi: $desc"
            return 1
        fi
    else
        echo -ne "  ${YELLOW}[İNDİRİLİYOR]${NC} $desc\r"
        if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
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
            curl -fsSL https://repo.charm.sh/apt/gpg.key 2>/dev/null | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
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

    if has_gum; then
        gum_print --foreground 51 "[BİLGİ] 1453.AI WSL Kurulum Betiği Yüklemesi Başlatılıyor..."
        gum_print --foreground 51 "[BİLGİ] Kurulum dizini: ${INSTALL_DIR}"
        echo ""
    else
        echo -e "  ${CYAN}[BİLGİ]${NC} 1453.AI WSL Kurulum Betiği Yüklemesi Başlatılıyor..."
        echo -e "  ${CYAN}[BİLGİ]${NC} Kurulum dizini: ${INSTALL_DIR}"
        echo ""
    fi

    # curl kontrolü
    if ! command -v curl &> /dev/null; then
        if has_gum; then
            gum_print --foreground 196 "[HATA] curl gerekli ama kurulu değil."
            gum_print --foreground 226 "[İPUCU] curl'ü kurmak için: sudo apt install curl"
        else
            echo -e "  ${RED}[HATA]${NC} curl gerekli ama kurulu değil."
            echo -e "  ${YELLOW}[İPUCU]${NC} curl'ü kurmak için: sudo apt install curl"
        fi
        exit 1
    fi

    # Kurulum dizin yapısını oluştur
    if has_gum; then
        gum_print --foreground 226 "[KURULUM] Dizin yapısı oluşturuluyor..."
        mkdir -p "${INSTALL_DIR}/src"/{lib,config,modules}
        gum_print --foreground 82 "[✓] Dizin yapısı oluşturuldu"
        echo ""
    else
        echo -e "  ${YELLOW}[KURULUM]${NC} Dizin yapısı oluşturuluyor..."
        mkdir -p "${INSTALL_DIR}/src"/{lib,config,modules}
        echo -e "  ${GREEN}[✓]${NC} Dizin yapısı oluşturuldu"
        echo ""
    fi

    # İndirilecek dosyaların listesi
    declare -a files=(
        "src/linux-ai-setup-script.sh:Ana betik"
        "src/lib/init.sh:Başlatma modülü"
        "src/lib/common.sh:Ortak araçlar"
        "src/lib/package-manager.sh:Paket yöneticisi tespiti"
        "src/lib/installation-tracker.sh:Kurulum takip sistemi"
        "src/lib/tui.sh:TUI sistem modülü"
        "src/config/colors.sh:Renk tanımlamaları"
        "src/config/constants.sh:Global sabitler (CRITICAL)"
        "src/config/tool-versions.sh:Araç versiyonları"
        "src/config/php-versions.sh:PHP yapılandırması"
        "src/config/banner.sh:Banner gösterimi"
        "src/modules/python.sh:Python ekosistemi"
        "src/modules/javascript.sh:JavaScript ekosistemi"
        "src/modules/php.sh:PHP ekosistemi"
        "src/modules/go.sh:Go kurulum modülü"
        "src/modules/docker.sh:Docker kurulum modülü"
        "src/modules/modern-tools.sh:Modern CLI araçları"
        "src/modules/shell-setup.sh:Shell ortamı yapılandırma"
        "src/modules/ai-cli.sh:AI CLI araçları"
        "src/modules/ai-frameworks.sh:AI framework'leri"
        "src/modules/quickstart.sh:Quick Start modu"
        "src/modules/cleanup.sh:Temizleme ve sıfırlama"
        "src/modules/menus.sh:Menü sistemi"
        "templates/starship.toml:Starship TOML config"
    )

    # Tüm dosyaları indir
    local total_files=${#files[@]}
    local failed=0
    local failed_files=()

    # Download all files with single-line progress
    local count=0

    if has_gum; then
        gum_print --foreground 51 "📦 Modüler bileşenler indiriliyor ($total_files dosya)..."
    else
        echo -e "  ${CYAN}[BİLGİ]${NC} Modüler bileşenler indiriliyor ($total_files dosya)..."
    fi

    # Temporarily disable strict error handling for download loop
    set +e

    for file_info in "${files[@]}"; do
        IFS=':' read -r file_path description <<< "$file_info"

        # Safety check for parsed values
        if [ -z "${file_path:-}" ] || [ -z "${description:-}" ]; then
            continue
        fi

        local url="${BASE_URL}/${file_path}"
        local dest="${INSTALL_DIR}/${file_path}"
        count=$((count + 1))

        # Calculate progress percentage
        local percent=$((count * 100 / total_files))

        # Show progress on same line (overwrite)
        printf "\r  [$count/$total_files - %%${percent}] %-50s" "$description"

        # Download file silently
        if ! curl -fsSL "$url" -o "$dest" 2>/dev/null; then
            failed=$((failed + 1))
            failed_files+=("$description")
        fi
    done

    # Re-enable strict error handling
    set -e

    # Clear the progress line
    printf "\r%*s\r" 120 ""
    echo ""

    # Show summary
    if [ $failed -eq 0 ]; then
        if has_gum; then
            gum_print --foreground 82 "✅ Tüm dosyalar başarıyla indirildi ($total_files/$total_files)"
        else
            echo -e "  ${GREEN}[✓]${NC} Tüm dosyalar başarıyla indirildi ($total_files/$total_files)"
        fi
        echo ""
    fi

    if [ $failed -gt 0 ]; then
        if has_gum; then
            gum_print --foreground 196 "❌ $failed/$total_files dosya indirilemedi"
            echo ""
            gum_print --foreground 226 "Başarısız dosyalar:"
            for failed_file in "${failed_files[@]}"; do
                gum_print --foreground 196 "  • $failed_file"
            done
            echo ""
            gum_print --foreground 226 "[İPUCU] Tekrar deneyebilir veya depoyu doğrudan klonlayabilirsiniz:"
            gum_print --foreground 51 "  git clone https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
        else
            echo -e "  ${RED}[HATA]${NC} $failed/$total_files dosya indirilemedi"
            echo ""
            echo -e "  ${YELLOW}Başarısız dosyalar:${NC}"
            for failed_file in "${failed_files[@]}"; do
                echo -e "    ${RED}•${NC} $failed_file"
            done
            echo ""
            echo -e "  ${YELLOW}[İPUCU]${NC} Tekrar deneyebilir veya depoyu doğrudan klonlayabilirsiniz:"
            echo -e "        git clone https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
        fi
        exit 1
    fi

    # Ana betiği çalıştırılabilir yap
    chmod +x "${INSTALL_DIR}/src/linux-ai-setup-script.sh"

    # Kullanışlı bir başlatıcı betiği oluştur
    if has_gum; then
        gum_print --foreground 226 "[KURULUM] Başlatıcı betiği oluşturuluyor..."
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
        gum_print --foreground 82 "[✓] Başlatıcı betiği oluşturuldu"
        echo ""
    else
        echo -e "  ${GREEN}[✓]${NC} Başlatıcı betiği oluşturuldu"
        echo ""
    fi

    # Install Gum for modern TUI (critical dependency)
    install_gum_minimal

    # Kurulum başarılı mesajı (with Gum if available)
    echo ""
    if has_gum; then
        # Re-detect terminal width (in case terminal was resized)
        TUI_WIDTH=$(tput cols 2>/dev/null || echo 80)

        # Calculate responsive width - aggressive limiting for narrow terminals
        local box_width=60
        if [ -n "${TUI_WIDTH:-}" ] && [ "$TUI_WIDTH" -gt 80 ]; then
            box_width=$((TUI_WIDTH - 20))
        fi
        # Ensure box never exceeds 70 chars (fits in most terminals)
        [ "$box_width" -gt 70 ] && box_width=70
        # Ensure box never exceeds terminal width
        [ "$box_width" -gt $((TUI_WIDTH - 10)) ] && box_width=$((TUI_WIDTH - 10))

        # Modern Gum success message (responsive)
        gum style \
            --foreground 82 --border double --align center \
            --width "$box_width" --margin "1 2" --padding "1 2" \
            "✅ Kurulum Tamamlandı!" \
            "" \
            "1453.AI WSL Setup yüklendi"

        echo ""
        gum_print --foreground 226 "📌 Çalıştırma:"
        echo ""
        gum_print "  ${INSTALL_DIR}/1453-setup"
        echo ""
        gum_print --foreground 51 "💡 Güncellemek için installer'ı tekrar çalıştırın"
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
            gum_print --foreground 82 "🚀 Kurulum betiği başlatılıyor..."
            sleep 1
            bash "${INSTALL_DIR}/1453-setup" </dev/tty
        else
            echo ""
            gum_print --foreground 51 "👉 Daha sonra çalıştırmak için: ${INSTALL_DIR}/1453-setup"
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