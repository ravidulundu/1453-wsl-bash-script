# 1453 WSL Architect - Refactor Planı
**Hedef**: PRD gereksinimlerini mevcut dosya yapısında uygulamak

## 📋 Mevcut Dosya Yapısı (Korunacak)
```
1453-wsl-bash-script/
├── install.sh
├── src/
│   ├── lib/           # UI ve yardımcı fonksiyonlar
│   ├── modules/       # Özellik modülleri
│   └── config/        # Yapılandırma dosyaları
```

---

## 🎯 PRD Gereksinimleri ile Eşleştirme

### PRD → Mevcut Yapı Mapping
| PRD İstediği | Mevcut Karşılığı | Durum |
|--------------|------------------|-------|
| `lib/ui.sh` | `src/lib/tui.sh` + `src/lib/gum-init.sh` | ✅ Kullanılacak |
| `lib/logic.sh` | `src/lib/common.sh` + `src/lib/package-manager.sh` | ✅ Kullanılacak |
| `lib/text.sh` | **YOK** → `src/lib/ai-text.sh` olarak eklenecek | 🆕 Oluşturulacak |
| `config/packages.csv` | `src/config/tool-versions.sh` | ✅ Mevcut (farklı format) |

---

## 🔧 REFACTOR GÖREVLERİ (Öncelik Sırasına Göre)

### ✅ **Görev 1: Tema Tutarlılığını Sağla**
**Hedef**: Crimson/Gold temasını tüm dosyalarda aktif kullan

#### Alt Görevler:
1. **`src/lib/common.sh` refactor**
   - ❌ Değiştir: `echo -e "${RED}[HATA]${NC}"`
   - ✅ Yeni: `gum_alert "HATA" "mesaj"`
   - Tüm status mesajları gum wrapper'ları ile değiştirilecek

2. **`src/modules/*.sh` dosyalarını güncelle**
   - Manuel ANSI renk kodları → Gum wrapper'ları
   - `echo` yerine `gum format` kullan

3. **`src/lib/gum-init.sh` genişlet**
   - Eksik wrapper'ları ekle: `gum_warning()`, `gum_thinking()`

---

### 🤖 **Görev 2: AI Hissi Ekle**
**Hedef**: PRD FR-2.3 ve FR-2.4 - Streaming text ve thinking states

#### Yeni Dosya: `src/lib/ai-text.sh`
```bash
#!/bin/bash
# AI-like text messages and effects

# Daktilo efekti
typewriter_effect() {
    local text="$1"
    local delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# Bağlamsal AI mesajları
declare -A AI_MESSAGES=(
    [init]="🏗️ Ortam hazırlanıyor..."
    [analyzing]="🔍 Sistem analiz ediliyor..."
    [thinking]="🤔 En iyi strateji belirleniyor..."
    [building]="⚙️ Bileşenler inşa ediliyor..."
    [installing]="📦 Paketler optimize ediliyor..."
    [configuring]="🔧 Yapılandırma ayarlanıyor..."
    [verifying]="✓ Doğrulama yapılıyor..."
    [finalizing]="🎯 Son rötuşlar yapılıyor..."
)

# AI-like spinner mesajı göster
show_ai_thinking() {
    local context="$1"  # analyzing, building, etc.
    local message="${AI_MESSAGES[$context]:-Çalışıyor...}"
    gum spin --spinner dots --title "$message" -- sleep 1
}
```

#### Kullanım Yerleri:
- `install.sh` başlangıcında: "Ortam hazırlanıyor..."
- Paket kurulumlarında: "Paketler optimize ediliyor..."
- Sistem kontrollerinde: "Sistem analiz ediliyor..."

---

### 📦 **Görev 3: Log Gizleme ve Hata Yönetimi**
**Hedef**: PRD FR-3.1 ve FR-3.2 - Terminal kirliliğini önle

#### Değiştirilecek Yerler:
1. **`src/lib/package-manager.sh`**
   - Tüm `apt-get`, `npm`, `pip` çıktıları spinner arkasına gizlenecek
   - Hata durumunda: Alert box + "Logları Göster/Yeniden Dene" seçenekleri

2. **Yeni fonksiyon ekle: `safe_install_with_logs()`**
```bash
safe_install_with_logs() {
    local package="$1"
    local command="$2"
    local log_file="/tmp/install-$(date +%s)-${package}.log"
    
    if gum spin --title "📦 ${package} kuruluyor..." -- \
       bash -c "$command > $log_file 2>&1"; then
        gum_success "Kurulum Başarılı" "$package kuruldu"
        rm -f "$log_file"
        return 0
    else
        gum_alert "Kurulum Hatası" "$package kurulamadı"
        
        # Kullanıcıya seçenek sun
        local choice=$(gum choose "Logları Göster" "Yeniden Dene" "Atla")
        case "$choice" in
            "Logları Göster")
                gum format "$(cat $log_file)"
                ;;
            "Yeniden Dene")
                safe_install_with_logs "$package" "$command"
                return $?
                ;;
        esac
        return 1
    fi
}
```

---

### 🎨 **Görev 4: Başlık ve Banner Güncellemesi**
**Hedef**: PRD FR-1.2 - Altın renkli double border başlık

#### Güncellenecek: `src/config/banner.sh`
- Zaten `gum_header` kullanıyor ✅
- Crimson/Gold renkler aktif ✅
- **Ekleme**: ASCII art ile daha görsel bir logo

```bash
show_banner_enhanced() {
    gum style \
        --foreground "$COLOR_CRIMSON_FG" \
        --border "$STYLE_BORDER_DOUBLE" \
        --border-foreground "$COLOR_GOLD_FG" \
        --padding "2 4" \
        --margin "1 0" \
        --align center \
        --bold \
        "╔══════════════════════════════════════╗" \
        "║                                      ║" \
        "║       1 4 5 3   W S L                ║" \
        "║      A R C H I T E C T               ║" \
        "║                                      ║" \
        "║  Yeni Çağın Geliştirme Ortamı        ║" \
        "║                                      ║" \
        "╚══════════════════════════════════════╝"
}
```

---

### 📊 **Görev 5: Raporlama Sistemi**
**Hedef**: PRD FR-4.1 - Markdown render edilmiş rapor

#### Güncellenecek: `src/lib/installation-tracker.sh`
- Zaten `gum format` kullanıyor ✅
- **İyileştirme**: Daha detaylı Markdown raporu

```bash
generate_final_report() {
    local report_file="/tmp/install-report-$(date +%s).md"
    
    cat > "$report_file" << EOF
# 🎉 1453 WSL Architect - Kurulum Raporu

## ✅ Başarıyla Kurulanlar
$(list_installed_packages)

## ⚠️ Atlananlar
$(list_skipped_packages)

## ❌ Başarısız Olanlar
$(list_failed_packages)

## 📝 Sonraki Adımlar
1. Terminal'i yeniden başlatın: \`exec \$SHELL\`
2. Ortamı test edin: \`which node python3 docker\`
3. Daha fazla bilgi: \`README.md\`

---
**Kurulum Zamanı**: $(date)
**Toplam Süre**: ${TOTAL_DURATION}s
EOF
    
    gum format < "$report_file"
}
```

---

## 📝 UYGULAMA SIRASI

### Faz 1: Temel Altyapı (1-2 saat)
- [x] `src/lib/ai-text.sh` oluştur
- [ ] `src/lib/gum-init.sh` → Eksik wrapper'ları ekle
- [ ] `src/lib/common.sh` → Tüm echo'ları gum'a çevir

### Faz 2: Modül Güncellemeleri (2-3 saat)
- [ ] `src/modules/quickstart.sh` → AI text + log hiding
- [ ] `src/modules/shell-setup.sh` → Gum wrapper'ları
- [ ] `src/modules/docker.sh`, `python.sh`, `javascript.sh`, etc. → Tüm modüller

### Faz 3: Ana Script (1 saat)
- [ ] `install.sh` → Streaming text ekle
- [ ] `src/config/banner.sh` → Enhanced banner

### Faz 4: Test ve Doğrulama (1 saat)
- [ ] Kabul kriterlerini test et (AC-1 ~ AC-4)
- [ ] Renk tutarlılığını kontrol et
- [ ] Hata senaryolarını test et

---

## 🎯 KRİTİK DEĞİŞİKLİKLER ÖZETİ

| Dosya | Değişiklik | Etki |
|-------|------------|------|
| `src/lib/common.sh` | ANSI → Gum wrapper | 🔴 Yüksek |
| `src/lib/ai-text.sh` | Yeni dosya | 🟢 Yeni |
| `src/lib/gum-init.sh` | Yeni wrapper'lar | 🟡 Orta |
| `src/modules/*.sh` | Echo → Gum format | 🔴 Yüksek |
| `src/config/banner.sh` | Enhanced logo | 🟡 Orta |

---

## ✅ Kabul Kriterleri Kontrol Listesi

- [ ] **AC-1**: Ham terminal çıktısı yok (spinner arkasında)
- [ ] **AC-2**: Rounded border'lı kutular kullanılıyor
- [ ] **AC-3**: Tüm girdiler Gum bileşenleri ile
- [ ] **AC-4**: Crimson/Gold tema %100 uygulanmış

---

**Hazırlayan**: AI Assistant  
**Tarih**: 2025-11-24  
**Durum**: Onay Bekliyor
