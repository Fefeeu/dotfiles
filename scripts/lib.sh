#!/usr/bin/env bash
# Funções e listas compartilhadas pelo install.sh e pelo switch-theme.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
THEME_LINK="$CONFIG_DIR/theme"

# --- LOG ---
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
NC='\033[0m'

titulo() { echo -e "\n${AMARELO}>> $*${NC}"; }
info()   { echo -e "${AZUL}$*${NC}"; }
ok()     { echo -e "${VERDE}Linkado:${NC} $*"; }
aviso()  { echo -e "${AMARELO}Aviso:${NC} $*"; }
erro()   { echo -e "${VERMELHO}ERRO:${NC} $*" >&2; exit 1; }

# --- MAPAS ---
# Links fixos, iguais para todos os temas (origem no repo -> destino)
declare -A STATIC_MAP=(
    ["hypr/hyprland.conf"]="$CONFIG_DIR/hypr/hyprland.conf"
    ["hypr/configs"]="$CONFIG_DIR/hypr/configs"
    ["hypr/rules"]="$CONFIG_DIR/hypr/rules"
    ["hypr/scripts"]="$CONFIG_DIR/hypr/scripts"
    ["hypr/hyprlock.conf"]="$CONFIG_DIR/hypr/hyprlock.conf"
    ["swappy/config"]="$CONFIG_DIR/swappy/config"
)

# Componentes com layout em base/ que o tema pode sobrescrever inteiro
declare -A OVERRIDABLE=(
    ["waybar"]="$CONFIG_DIR/waybar"
    ["rofi"]="$CONFIG_DIR/rofi"
    ["kitty/kitty.conf"]="$CONFIG_DIR/kitty/kitty.conf"
    ["swaync"]="$CONFIG_DIR/swaync"
)

# Partes que só existem no tema (opcionais)
declare -A THEME_ONLY=(
    ["qt6ct.conf"]="$CONFIG_DIR/qt6ct/qt6ct.conf"
    ["kvantum"]="$CONFIG_DIR/Kvantum"
)

# --- FUNÇÕES ---
# Cria o link DEST -> SRC; se DEST for um arquivo real, guarda em DEST.bak
link_com_backup() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mv "$dest" "$dest.bak"
        aviso "backup criado: $dest.bak"
    fi
    ln -sfn "$src" "$dest"
    ok "${src#"$DOTFILES_DIR"/} -> ${dest/#"$HOME"/\~}"
}

# Temas disponíveis (pastas que começam com _ são modelos/testes)
listar_temas() {
    local dir
    for dir in "$DOTFILES_DIR"/themes/*/; do
        dir="$(basename "$dir")"
        [[ "$dir" == _* ]] || echo "$dir"
    done
}
