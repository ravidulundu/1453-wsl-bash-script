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
        gum_info "Geri Sayım" "Sistem 10 saniye içinde yeniden başlatılacak..."
        
        # Countdown with gum spinner
        local countdown=10
        while [ $countdown -gt 0 ]; do
            echo -ne "\r  Yeniden başlatma: $countdown saniye... "
            sleep 1
            ((countdown--))
        done
        echo ""
        
        gum_success "Başlatma" "Sistem yeniden başlatılıyor..."
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
