#!/bin/bash
# Module: Dotfiles Manager
# PRD FR-2.2: Fuzzy search for dotfiles/config file selection
# Description: Interactive dotfiles backup and restore with gum filter

# Backup user dotfiles with fuzzy search selection
# PRD FR-2.2: gum filter kullanımı
backup_dotfiles() {
    echo ""
    gum_header "DOTFILES YEDEKLEME" "Yapılandırma dosyalarınızı yedekleyin"
    echo ""

    gum_info "Bilgi" "Home dizininizden yedeklenecek dosyaları seçin"
    echo ""

    # Get list of dotfiles in home directory
    local dotfiles_list=$(find ~ -maxdepth 1 -name ".*" -type f 2>/dev/null | sort)

    if [ -z "$dotfiles_list" ]; then
        gum_alert "Hata" "Home dizininde dotfile bulunamadı"
        return 1
    fi

    # Show count
    local total_count=$(echo "$dotfiles_list" | wc -l)
    echo "  📁 Toplam $total_count dotfile bulundu"
    echo ""

    # PRD FR-2.2: Fuzzy search with gum filter
    gum_style --foreground "$COLOR_GOLD_FG" "🔍 Arama yaparak dosya seçin (ESC = İptal)"
    echo ""

    local selected_files=$(echo "$dotfiles_list" | gum_filter_enhanced "Dosya ara (örn: bashrc, vimrc)...")

    if [ -z "$selected_files" ]; then
        gum_warning "İptal" "Dosya seçilmedi"
        return 0
    fi

    # Create backup directory
    local backup_dir="$HOME/.1453-dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    echo ""
    gum_info "Yedekleme" "Dosyalar kopyalanıyor: $backup_dir"
    echo ""

    local count=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            cp "$file" "$backup_dir/"
            echo "  ✅ $filename"
            ((count++))
        fi
    done <<< "$selected_files"

    echo ""
    gum_success "Tamamlandı" "$count dosya yedeklendi"
    echo ""
    echo "  📦 Yedek konumu: $backup_dir"
    echo ""

    # Offer to create archive
    if gum_confirm "Yedekleri .tar.gz arşivi olarak sıkıştırmak ister misiniz?"; then
        local archive_name="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar -czf "$archive_name" -C "$backup_dir" .
        gum_success "Arşiv Oluşturuldu" "$archive_name"
        echo ""
        echo "  💾 Arşiv: $archive_name"
        echo "  📂 Ham yedek: $backup_dir"
        echo ""
    fi

    return 0
}

# Restore dotfiles from backup with fuzzy search
# PRD FR-2.2: gum filter ile yedek seçimi
restore_dotfiles() {
    echo ""
    gum_header "DOTFILES GERİ YÜKLEME" "Yedekten dosyaları geri yükleyin"
    echo ""

    # Find backup directories
    local backup_dirs=$(find ~ -maxdepth 1 -type d -name ".1453-dotfiles-backup-*" 2>/dev/null | sort -r)

    if [ -z "$backup_dirs" ]; then
        gum_alert "Yedek Bulunamadı" "Hiç dotfiles yedeği bulunamadı"
        echo ""
        echo "  Önce 'backup_dotfiles' fonksiyonunu kullanın"
        echo ""
        return 1
    fi

    # Count backups
    local backup_count=$(echo "$backup_dirs" | wc -l)
    echo "  📦 $backup_count yedek bulundu"
    echo ""

    # PRD FR-2.2: Fuzzy search backup directories
    gum_style --foreground "$COLOR_GOLD_FG" "🔍 Geri yüklenecek yedeği seçin"
    echo ""

    local selected_backup=$(echo "$backup_dirs" | gum_filter_enhanced "Yedek ara (tarih ile filtreyin)...")

    if [ -z "$selected_backup" ]; then
        gum_warning "İptal" "Yedek seçilmedi"
        return 0
    fi

    # List files in selected backup
    local backup_files=$(find "$selected_backup" -type f 2>/dev/null)

    if [ -z "$backup_files" ]; then
        gum_alert "Hata" "Yedekte dosya bulunamadı"
        return 1
    fi

    echo ""
    gum_info "Seçilen Yedek" "$(basename "$selected_backup")"
    echo ""

    # PRD FR-2.2: Select files to restore
    gum_style --foreground "$COLOR_GOLD_FG" "🔍 Geri yüklenecek dosyaları seçin"
    echo ""

    local files_to_restore=$(echo "$backup_files" | gum_filter_enhanced "Dosya ara...")

    if [ -z "$files_to_restore" ]; then
        gum_warning "İptal" "Dosya seçilmedi"
        return 0
    fi

    # Restore files
    echo ""
    gum_warning "Dikkat" "Mevcut dosyaların üzerine yazılacak!"
    echo ""

    if ! gum_confirm "Devam etmek istediğinize emin misiniz?"; then
        gum_info "İptal" "Geri yükleme iptal edildi"
        return 0
    fi

    echo ""
    gum_info "Geri Yükleme" "Dosyalar kopyalanıyor..."
    echo ""

    local count=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            cp "$file" "$HOME/.$filename"
            echo "  ✅ .$filename"
            ((count++))
        fi
    done <<< "$files_to_restore"

    echo ""
    gum_success "Tamamlandı" "$count dosya geri yüklendi"
    echo ""

    return 0
}

# Browse and manage dotfiles interactively
# PRD FR-2.2: İnteraktif dotfiles yönetimi
manage_dotfiles_menu() {
    while true; do
        echo ""
        gum_header "DOTFILES YÖNETİCİSİ" "Yapılandırma dosyalarınızı yönetin"
        echo ""

        local selection
        selection=$(gum_choose_enhanced "Bir işlem seçin:" \
            "$ICON_PACKAGE Yedekleme (Fuzzy Search)" \
            "$ICON_TOOLS Geri Yükleme (Fuzzy Search)" \
            "$ICON_SEARCH Dotfiles Listele" \
            "$ICON_BACK Geri Dön")

        case "$selection" in
            *"Yedekleme"*)
                backup_dotfiles
                ;;
            *"Geri Yükleme"*)
                restore_dotfiles
                ;;
            *"Listele"*)
                echo ""
                gum_info "Dotfiles" "Home dizinindeki tüm gizli dosyalar:"
                echo ""
                find ~ -maxdepth 1 -name ".*" -type f 2>/dev/null | while read -r file; do
                    local size=$(du -h "$file" 2>/dev/null | cut -f1)
                    echo "  📄 $(basename "$file") ($size)"
                done
                echo ""
                echo "Devam etmek için Enter'a basın..."
                read -r
                ;;
            *"Geri Dön"*)
                return 0
                ;;
        esac
    done
}

# Export functions
export -f backup_dotfiles
export -f restore_dotfiles
export -f manage_dotfiles_menu
