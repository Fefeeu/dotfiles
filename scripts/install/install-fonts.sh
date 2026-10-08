#!/usr/bin/env bash
# Instala as Nerd Fonts usadas pelo dotfiles em ~/.local/share/fonts, sem sudo.
# Vêm do GitHub (ryanoasis/nerd-fonts), porque não estão no dnf.
# Fonte que o sistema já conhece é pulada, então pode rodar várias vezes.

# Chamado com "source": roda num bash próprio, senão o set -e e o exit do
# lib.sh ficam valendo no shell do terminal e o fecham no primeiro erro
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    bash "${BASH_SOURCE[0]}" "$@"
    return
fi

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

# Nome do arquivo da fonte nos releases do nerd-fonts (<nome>.tar.xz)
FONTES=(
    JetBrainsMono   # kitty, rofi, waybar, hyprlock
)

FONTES_DIR="$HOME/.local/share/fonts"
URL_BASE="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

titulo "Fontes:"
instalou=""
for fonte in "${FONTES[@]}"; do
    # já instalada (em qualquer pasta que o fontconfig leia); sem grep -q,
    # que fecha o pipe cedo e faz o pipefail contar como falha
    if fc-list : family | grep -i "^$fonte Nerd Font" > /dev/null; then
        info "$fonte Nerd Font já instalada"
        continue
    fi
    destino="$FONTES_DIR/${fonte}Nerd"
    mkdir -p "$destino"
    curl -fL --progress-bar "$URL_BASE/$fonte.tar.xz" | tar -xJ -C "$destino" \
        || erro "não consegui baixar $fonte.tar.xz"
    echo -e "${VERDE}Instalado:${NC} $fonte Nerd Font -> ${destino/#"$HOME"/\~}"
    instalou=1
done

# atualiza o cache para os programas acharem as fontes novas
[[ -n "$instalou" ]] && fc-cache -f "$FONTES_DIR"
exit 0
