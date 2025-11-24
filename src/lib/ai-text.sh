#!/bin/bash
# 1453 WSL Architect - AI-like Text Effects & Messages
# Description: Provides streaming text effects and contextual AI messages
# Dependencies: src/config/theme.sh

# ==============================================================================
# TYPEWRITER EFFECT (Streaming Text Simulation)
# ==============================================================================

# Daktilo efekti - metni karakterlere bölerek akıcı gösterir
# Usage: typewriter_effect "Mesaj metni" [delay_in_seconds]
# PRD Requirement: FR-2.3 - Streaming Text
typewriter_effect() {
    local text="$1"
    local delay="${2:-0.03}"  # Default: 30ms per character
    
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# Gum ile renkli typewriter effect
# Usage: typewriter_gum "Mesaj" [color_fg] [delay]
typewriter_gum() {
    local text="$1"
    local color="${2:-$COLOR_TEXT_FG}"
    local delay="${3:-0.03}"
    
    for ((i=0; i<${#text}; i++)); do
        gum style --foreground "$color" "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# ==============================================================================
# AI CONTEXTUAL MESSAGES
# ==============================================================================
# PRD Requirement: FR-2.4 - Thinking State with contextual messages

# AI mesaj kütüphanesi - sistem çalışırken gösterilecek mesajlar
declare -A AI_MESSAGES=(
    # Initialization Phase
    [init]="🏗️  Ortam hazırlanıyor..."
    [welcome]="🎯  1453 WSL Architect başlatılıyor..."
    
    # Analysis Phase
    [analyzing]="🔍  Sistem mimarisi analiz ediliyor..."
    [scanning]="📊  Mevcut konfigürasyon taranıyor..."
    [detecting]="🎯  Bağımlılıklar tespit ediliyor..."
    
    # Planning Phase
    [thinking]="🤔  En iyi strateji belirleniyor..."
    [optimizing]="⚡  Kurulum planı optimize ediliyor..."
    [calculating]="🧮  Kaynak gereksinimleri hesaplanıyor..."
    
    # Execution Phase
    [building]="⚙️   Bileşenler inşa ediliyor..."
    [installing]="📦  Paketler yükleniyor..."
    [configuring]="🔧  Yapılandırma ayarlanıyor..."
    [compiling]="🔨  Derleme işlemleri yapılıyor..."
    
    # Verification Phase
    [verifying]="✓   Doğrulama yapılıyor..."
    [testing]="🧪  Entegrasyon testleri çalıştırılıyor..."
    [validating]="✅  Kurulum doğrulanıyor..."
    
    # Finalization Phase
    [finalizing]="🎯  Son rötuşlar yapılıyor..."
    [cleanup]="🧹  Geçici dosyalar temizleniyor..."
    [complete]="🎉  İşlem tamamlandı!"
)

# AI mesajını export et
get_ai_message() {
    local context="$1"
    echo "${AI_MESSAGES[$context]:-⏳ İşlem devam ediyor...}"
}

# ==============================================================================
# AI THINKING ANIMATION
# ==============================================================================
# PRD Requirement: FR-2.4 - User should never see blank cursor

# AI-like düşünme animasyonu göster
# Usage: show_ai_thinking "context_key" [duration_seconds]
show_ai_thinking() {
    local context="$1"
    local duration="${2:-2}"
    local message=$(get_ai_message "$context")
    
    if command -v gum &>/dev/null; then
        gum spin --spinner dot --title "$message" -- sleep "$duration"
    else
        # Fallback: Simple spinner
        echo -n "$message "
        for ((i=0; i<duration; i++)); do
            echo -n "."
            sleep 1
        done
        echo " ✓"
    fi
}

# AI düşünme durumu ile komut çalıştır
# Usage: run_with_ai_context "analyzing" "apt update"
run_with_ai_context() {
    local context="$1"
    local command="$2"
    local message=$(get_ai_message "$context")
    
    if command -v gum &>/dev/null; then
        gum spin --spinner dot --title "$message" -- bash -c "$command"
    else
        echo "$message"
        eval "$command"
    fi
}

# ==============================================================================
# PROGRESS INDICATORS
# ==============================================================================

# Aşama göstergesi - hangi aşamada olduğumuzu göster
# Usage: show_phase "Faz 1: Başlatma" "2/5"
show_phase() {
    local phase_name="$1"
    local progress="${2:-}"
    
    if command -v gum &>/dev/null; then
        local display_text="$phase_name"
        if [ -n "$progress" ]; then
            display_text="[$progress] $phase_name"
        fi
        
        gum style \
            --foreground "$COLOR_CRIMSON_FG" \
            --border "$STYLE_BORDER_ROUNDED" \
            --border-foreground "$COLOR_GOLD_FG" \
            --padding "0 2" \
            --margin "1 0" \
            --bold \
            "$display_text"
    else
        echo "==> $phase_name ${progress:+[$progress]}"
    fi
}

# Adım göstergesi - her bir işlem adımını göster
# Usage: show_step "Git kurulumu" "completed|pending|failed"
show_step() {
    local step_name="$1"
    local status="${2:-pending}"
    
    local icon=""
    local color="$COLOR_TEXT_FG"
    
    case "$status" in
        completed|success)
            icon="✅"
            color="$COLOR_SUCCESS_FG"
            ;;
        pending|running)
            icon="⏳"
            color="$COLOR_INFO_FG"
            ;;
        failed|error)
            icon="❌"
            color="$COLOR_ERROR_FG"
            ;;
        skipped)
            icon="⏭️"
            color="$COLOR_WARNING_FG"
            ;;
        *)
            icon="◉"
            ;;
    esac
    
    if command -v gum &>/dev/null; then
        gum style --foreground "$color" "$icon $step_name"
    else
        echo "$icon $step_name"
    fi
}

# ==============================================================================
# STREAMING OUTPUT
# ==============================================================================

# Komut çıktısını satır satır akışlı göster
# Usage: stream_output "command to run"
stream_output() {
    local command="$1"
    
    eval "$command" | while IFS= read -r line; do
        echo "$line"
        sleep 0.05  # Hafif gecikme ile akış hissi
    done
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

export -f typewriter_effect
export -f typewriter_gum
export -f get_ai_message
export -f show_ai_thinking
export -f run_with_ai_context
export -f show_phase
export -f show_step
export -f stream_output

# Export AI messages array
export AI_MESSAGES
