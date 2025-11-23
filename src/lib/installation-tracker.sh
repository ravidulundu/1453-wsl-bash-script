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

# Show installation summary
show_installation_summary() {
    echo ""
    echo -e "${CYAN}KURULUM ÖZETİ${NC}"
    echo ""

    # Count totals
    local success_count=${#SUCCESSFUL_INSTALLATIONS[@]}
    local failed_count=${#FAILED_INSTALLATIONS[@]}
    local skipped_count=${#SKIPPED_INSTALLATIONS[@]}
    local total_count=$((success_count + failed_count + skipped_count))

    if [ $total_count -eq 0 ]; then
        echo -e "${YELLOW}[BİLGİ]${NC} Hiçbir kurulum yapılmadı."
        return 0
    fi

    # Show successful installations
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}✅ BAŞARILI KURULUMLAR ($success_count):${NC}"
        for item in "${SUCCESSFUL_INSTALLATIONS[@]}"; do
            echo -e "   ${GREEN}•${NC} $item"
        done
        echo ""
    fi

    # Show skipped installations
    if [ $skipped_count -gt 0 ]; then
        echo -e "${CYAN}⏭️  ATLANAN KURULUMLAR ($skipped_count):${NC}"
        for item in "${SKIPPED_INSTALLATIONS[@]}"; do
            echo -e "   ${CYAN}•${NC} $item"
        done
        echo ""
    fi

    # Show failed installations
    if [ $failed_count -gt 0 ]; then
        echo -e "${RED}❌ BAŞARISIZ KURULUMLAR ($failed_count):${NC}"
        for item in "${FAILED_INSTALLATIONS[@]}"; do
            echo -e "   ${RED}•${NC} $item"
        done
        echo ""
        echo -e "${YELLOW}[!]${NC} Başarısız kurulumlar için elle kurulum yapabilirsiniz."
        echo -e "${YELLOW}[!]${NC} Detaylar için yukarıdaki hata mesajlarına bakın."
        echo ""
    fi

    # Show summary
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Toplam: $total_count  |  ${GREEN}Başarılı: $success_count${NC}  |  ${CYAN}Atlanan: $skipped_count${NC}  |  ${RED}Başarısiz: $failed_count${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Show post-installation instructions if there were successful installations
    if [ $success_count -gt 0 ]; then
        echo -e "${YELLOW}📋 KURULUM SONRASI YAPMALISINIZ:${NC}"
        echo ""
        echo -e "${GREEN}1.${NC} Terminal ortamınızı yenileyin (aşağıdakilerden birini seçin):"
        echo -e "   ${CYAN}•${NC} ${GREEN}source ~/.bashrc${NC}  ${YELLOW}(en hızlı yöntem)${NC}"
        echo -e "   ${CYAN}•${NC} ${GREEN}exec bash${NC}  ${YELLOW}(bash kullanıyorsanız)${NC}"
        echo -e "   ${CYAN}•${NC} Terminali kapatıp yeniden açın  ${YELLOW}(en garantili)${NC}"
        echo ""
        echo -e "${GREEN}2.${NC} Kurulumları test edin:"
        echo -e "   ${CYAN}•${NC} ${GREEN}python3 --version${NC}  ${YELLOW}(Python kuruldu mu?)${NC}"
        echo -e "   ${CYAN}•${NC} ${GREEN}node --version${NC}  ${YELLOW}(Node.js kuruldu mu?)${NC}"
        echo -e "   ${CYAN}•${NC} ${GREEN}which nvm${NC}  ${YELLOW}(NVM yolu)${NC}"
        echo ""
        echo -e "${GREEN}3.${NC} Yeni araçları keşfedin:"
        echo -e "   ${CYAN}•${NC} ${GREEN}bat --help${NC}  ${YELLOW}(modern cat komutu)${NC}"
        echo -e "   ${CYAN}•${NC} ${GREEN}eza --help${NC}  ${YELLOW}(modern ls komutu)${NC}"
        echo -e "   ${CYAN}•${NC} ${GREEN}lazygit${NC}  ${YELLOW}(Git TUI)${NC}"
        echo ""
        echo -e "${YELLOW}💡 İPUCU:${NC} Shell değişiklikleri aktif olana kadar yeni kurulumlar çalışmayabilir!"
        echo -e "${YELLOW}⚠️  ÖNEMLİ:${NC} Mutlaka ${GREEN}source ~/.bashrc${NC} komutunu çalıştırın veya terminali yeniden başlatın."
        echo ""
    fi

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
