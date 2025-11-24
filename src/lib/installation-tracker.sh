#!/bin/bash
# Installation Tracking System
# Tracks successful, failed, and skipped installations

# Global arrays to track installations
declare -a SUCCESSFUL_INSTALLATIONS=()
declare -a FAILED_INSTALLATIONS=()
declare -a SKIPPED_INSTALLATIONS=()

# Track successful installation
# Usage: track_success "Tool Name" "version"
track_success() {
    local tool_name="$1"
    local version="${2:-}"

    if [ -n "$version" ]; then
        SUCCESSFUL_INSTALLATIONS+=("$tool_name ($version)")
    else
        SUCCESSFUL_INSTALLATIONS+=("$tool_name")
    fi
}

# Track failed installation
# Usage: track_failure "Tool Name" "reason"
track_failure() {
    local tool_name="$1"
    local reason="${2:-Kurulum başarısız}"

    FAILED_INSTALLATIONS+=("$tool_name - $reason")
}

# Track skipped installation
# Usage: track_skip "Tool Name" "reason"
track_skip() {
    local tool_name="$1"
    local reason="${2:-Zaten kurulu}"

    SKIPPED_INSTALLATIONS+=("$tool_name - $reason")
}

# Show installation summary (PRD FR-4.1: Markdown Report)
show_installation_summary() {
    # Count totals
    local success_count=${#SUCCESSFUL_INSTALLATIONS[@]}
    local failed_count=${#FAILED_INSTALLATIONS[@]}
    local skipped_count=${#SKIPPED_INSTALLATIONS[@]}
    local total_count=$((success_count + failed_count + skipped_count))

    if [ $total_count -eq 0 ]; then
        gum_info "Rapor" "Hiçbir kurulum işlemi yapılmadı"
        return 0
    fi

    # Create Markdown report
    local report_file=$(mktemp)
    cat > "$report_file" << EOF
# 🎯 1453 WSL Architect - Kurulum Raporu

**Tarih:** $(date '+%d/%m/%Y %H:%M:%S')  
**Toplam İşlem:** $total_count

---

## 📊 Özet

| Kategori | Sayı |
|----------|------|
| ✅ Başarılı | **$success_count** |
| ⏭️  Atlandı | $skipped_count |
| ❌ Başarısız | $failed_count |

---

EOF

    # Add successful installations
    if [ $success_count -gt 0 ]; then
        cat >> "$report_file" << EOF
## ✅ Başarılı Kurulumlar ($success_count)

EOF
        for item in "${SUCCESSFUL_INSTALLATIONS[@]}"; do
            echo "- **$item**" >> "$report_file"
        done
        echo "" >> "$report_file"
        echo "---" >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add skipped installations
    if [ $skipped_count -gt 0 ]; then
        cat >> "$report_file" << EOF
## ⏭️  Atlanan Kurulumlar ($skipped_count)

EOF
        for item in "${SKIPPED_INSTALLATIONS[@]}"; do
            echo "- $item" >> "$report_file"
        done
        echo "" >> "$report_file"
        echo "---" >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add failed installations
    if [ $failed_count -gt 0 ]; then
        cat >> "$report_file" << EOF
## ❌ Başarısız Kurulumlar ($failed_count)

EOF
        for item in "${FAILED_INSTALLATIONS[@]}"; do
            echo "- **$item**" >> "$report_file"
        done
        echo "" >> "$report_file"
        cat >> "$report_file" << EOF
> ⚠️ **Manuel kurulum gerekebilir!**  
> Hata mesajlarını yukarıda kontrol edin.

---

EOF
    fi

    # Add post-installation instructions
    if [ $success_count -gt 0 ]; then
        cat >> "$report_file" << EOF
## 🚀 Sonraki Adımlar

### 1️⃣ Shell Ortamını Yenile

\`\`\`bash
source ~/.bashrc
\`\`\`

veya terminali yeniden başlat.

### 2️⃣ Kurulumları Doğrula

\`\`\`bash
python3 --version
node --version
docker --version
\`\`\`

### 3️⃣ Yeni Araçları Keşfet

- \`bat --help\` - Modern \`cat\` alternatifi
- \`eza --help\` - Modern \`ls\` alternatifi  
- \`lazygit\` - Git Terminal UI
- \`lazydocker\` - Docker Terminal UI

---

## 💡 İpuçları

- **Starship Prompt:** Terminalde modern bir görünüm için zaten aktif
- **Gum UI:** Gelişmiş terminal UI bileşenleri kullanılabilir
- **GitHub CLI:** \`gh\` komutu ile GitHub işlemleri

---

## 🤖 AI-Powered Öneriler

EOF
        # AI-like personalized suggestions based on what was installed
        if [[ " ${SUCCESSFUL_INSTALLATIONS[*]} " =~ " Python " ]]; then
            echo "- **Python Geliştirme:** \`uv\` ile ultra-hızlı paket yönetimi deneyin" >> "$report_file"
            echo "- **Virtual Environment:** Her proje için \`python3 -m venv venv\` kullanın" >> "$report_file"
        fi
        
        if [[ " ${SUCCESSFUL_INSTALLATIONS[*]} " =~ " Node" ]] || [[ " ${SUCCESSFUL_INSTALLATIONS[*]} " =~ " NVM" ]]; then
            echo "- **Node.js Versiyonları:** \`nvm ls\` ile kurulu sürümleri görün" >> "$report_file"
            echo "- **Paket Yöneticisi:** \`bun\` Node.js'ten 20x daha hızlı!" >> "$report_file"
        fi
        
        if [[ " ${SUCCESSFUL_INSTALLATIONS[*]} " =~ " Docker" ]]; then
            echo "- **Docker UI:** \`lazydocker\` ile container yönetimi kolaylaştı" >> "$report_file"
            echo "- **Compose:** \`docker compose\` komutu artık hazır" >> "$report_file"
        fi
        
        cat >> "$report_file" << EOF

---

## 📈 Performans Bilgisi

**Kurulum Süresi:** Yaklaşık $(( $(date +%s) - ${INSTALL_START_TIME:-$(date +%s)} )) saniye  
**Sistem:** $(uname -s) $(uname -m)  
**WSL Sürümü:** $(grep -oP '(?<=WSL_DISTRO_NAME=).*' /proc/sys/kernel/osrelease 2>/dev/null || echo "N/A")

---

**🎉 Kurulum tamamlandı! Mutlu kodlamalar!**

EOF
    fi

    # Render Markdown with gum format
    echo ""
    if command -v gum &> /dev/null; then
        gum format < "$report_file"
    else
        # Fallback: plain cat if gum not available
        cat "$report_file"
    fi
    echo ""

    # Clean up
    rm -f "$report_file"

    # Return non-zero if there are failures
    if [ $failed_count -gt 0 ]; then
        return 1
    fi
    return 0
}

# Reset tracking arrays (for fresh start)
reset_tracking() {
    SUCCESSFUL_INSTALLATIONS=()
    FAILED_INSTALLATIONS=()
    SKIPPED_INSTALLATIONS=()
}

# Export functions
export -f track_success
export -f track_failure
export -f track_skip
export -f show_installation_summary
export -f reset_tracking
