#!/bin/bash
# System Restart Handler
# PRD FR-4.2: Yeniden Başlatma Onayı

# Check if system restart is recommended
# Usage: check_restart_needed
check_restart_needed() {
    # Check if any critical system packages were installed
    local needs_restart=false
    
    # Check for Docker installation (requires service restart)
    if command -v docker &> /dev/null; then
        if ! docker ps &> /dev/null 2>&1; then
            needs_restart=true
        fi
    fi
    
    # Check for new kernel modules
    if [ -f /var/run/reboot-required ]; then
        needs_restart=true
    fi
    
    if [ "$needs_restart" = true ]; then
        return 0  # Restart needed
    else
        return 1  # No restart needed
    fi
}

# Prompt for system restart with countdown (PRD FR-4.2)
# Usage: prompt_system_restart
prompt_system_restart() {
    echo ""
    gum_header "SİSTEM YENİDEN BAŞLATMA" "Bazı değişiklikler için gerekiyor"
    
    echo ""
    gum_info "Bilgi" "Aşağıdaki nedenlerle sistem yeniden başlatılması önerilir:"
    echo ""
    echo "  • Docker servisi aktif hale gelecek"
    echo "  • Yeni PATH değişkenleri tam yüklenecek"
    echo "  • Kernel modülleri güncellenecek"
    echo ""
    
    if gum_confirm "Şimdi yeniden başlatmak ister misiniz?"; then
        echo ""
        gum_warning "Geri Sayım Başladı" "İptal etmek için Ctrl+C'ye basın"
        echo ""

        # PRD FR-4.2: Visual countdown with AI-like streaming
        # "10...9...8..." style countdown
        local countdown=10
        while [ $countdown -gt 0 ]; do
            # Create progress bar
            local filled=$((10 - countdown))
            local empty=$countdown

            # Responsive terminal width
            local term_width=$(tput cols 2>/dev/null || echo 80)
            local box_width=$((term_width > 60 ? 60 : term_width - 4))

            # Color coding: Red (countdown > 5), Yellow (3-5), Green (1-2)
            local color_fg="$COLOR_ERROR_FG"
            local icon="🔴"
            if [ $countdown -le 5 ] && [ $countdown -gt 2 ]; then
                color_fg="$COLOR_WARNING_FG"
                icon="🟡"
            elif [ $countdown -le 2 ]; then
                color_fg="$COLOR_SUCCESS_FG"
                icon="🟢"
            fi

            # Show countdown with gum style box
            gum style \
                --foreground "$color_fg" \
                --border rounded \
                --border-foreground "$color_fg" \
                --width "$box_width" \
                --padding "1 2" \
                --align center \
                --bold \
                "$icon Yeniden Başlatma: $countdown saniye"

            sleep 1
            ((countdown--))

            # Clear previous box (move cursor up and clear)
            [ $countdown -gt 0 ] && tput cuu1 && tput cuu1 && tput cuu1 && tput cuu1 && tput cuu1
        done

        echo ""
        gum_success "Başlatılıyor" "Sistem yeniden başlatılıyor... ♻️"
        sleep 1

        # Perform restart
        sudo reboot
    else
        gum_info "İptal" "Yeniden başlatma iptal edildi"
        echo ""
        echo "  Manuel olarak yeniden başlatmak için:"
        echo "  $ sudo reboot"
        echo ""
        echo "  Veya sadece shell'i yenilemek için:"
        echo "  $ source ~/.bashrc"
        echo ""
    fi
}

# Export functions
export -f check_restart_needed
export -f prompt_system_restart
