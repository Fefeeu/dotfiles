#!/usr/bin/env bash
# Funções e listas compartilhadas pelo install.sh e pelo switch-theme.sh

# Para no primeiro erro, em variável não definida ou em falha no meio de um pipe
set -euo pipefail

# Raiz do repositório (pasta acima de scripts/), pasta de configs e link do tema ativo
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
THEME_LINK="$CONFIG_DIR/theme"
# Arquivos gerados pelo switch-theme.sh a partir de templates do tema
GERADOS_DIR="$CONFIG_DIR/dotfiles-gerados"

# --- LOG ---
# Cores do terminal usadas nas mensagens
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
NC='\033[0m'

# Mensagens padronizadas: título de seção, informação, link criado, aviso
# e erro (o erro vai para o stderr e encerra o script)
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
# (o qt6ct.conf é template e tem tratamento próprio no switch-theme.sh)
declare -A THEME_ONLY=(
    ["kvantum"]="$CONFIG_DIR/Kvantum"
)

# --- FUNÇÕES ---
# link_com_backup <origem> <destino>
# Cria o link DEST -> SRC; se DEST for um arquivo real, guarda em DEST.bak
link_com_backup() {
    local src="$1" dest="$2"
    # garante que a pasta do destino existe
    mkdir -p "$(dirname "$dest")"
    # config real (não é link) no destino: guarda antes de substituir
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mv "$dest" "$dest.bak"
        aviso "backup criado: $dest.bak"
    fi
    # -n evita criar o link dentro de uma pasta que já é link
    ln -sfn "$src" "$dest"
    ok "${src#"$DOTFILES_DIR"/} -> ${dest/#"$HOME"/\~}"
}

# remover_link_do_tema <destino>
# Apaga DEST só se for um link para dentro de themes/ do repositório ou
# para a pasta de arquivos gerados. Serve para limpar o que sobrou do tema
# anterior; arquivo real ou link para outro lugar não é tocado.
remover_link_do_tema() {
    local dest="$1" alvo
    [[ -L "$dest" ]] || return 0
    alvo="$(readlink "$dest")"
    if [[ "$alvo" == "$DOTFILES_DIR/themes/"* || "$alvo" == "$GERADOS_DIR/"* ]]; then
        rm "$dest"
        info "Removido link velho: ${dest/#"$HOME"/\~}"
    fi
}

# listar_temas
# Imprime os temas disponíveis, um por linha (pastas que começam com _
# são modelos/testes e ficam de fora)
listar_temas() {
    local dir
    for dir in "$DOTFILES_DIR"/themes/*/; do
        dir="$(basename "$dir")"
        [[ "$dir" == _* ]] || echo "$dir"
    done
}
