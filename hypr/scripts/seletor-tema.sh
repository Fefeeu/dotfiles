#!/usr/bin/env bash
# Seletor de temas (SUPER+T): lista os temas com a miniatura imagens/thumb.png
# e aplica o escolhido com scripts/switch-theme.sh.

# O repositório é achado pelo link do tema ativo (~/.config/theme -> dotfiles/themes/<tema>)
DOTFILES_DIR="$(dirname "$(dirname "$(readlink -f "$HOME/.config/theme")")")"
TEMA_ATUAL="$(basename "$(readlink -f "$HOME/.config/theme")")"

# Layout do seletor: o do componente rofi ativo (pode vir do tema) ou o da base
ESTILO="$HOME/.config/rofi/temas/seletor.rasi"
[[ -f "$ESTILO" ]] || ESTILO="$DOTFILES_DIR/base/rofi/temas/seletor.rasi"

# Fecha o seletor se já estiver aberto
pkill -f 'rofi .*-theme .*seletor\.rasi' && exit 0

temas=()
linha_atual=0
for dir in "$DOTFILES_DIR"/themes/*/; do
    tema="$(basename "$dir")"
    [[ "$tema" == _* ]] && continue
    [[ "$tema" == "$TEMA_ATUAL" ]] && linha_atual=${#temas[@]}
    temas+=("$tema")
done

escolha="$(
    for tema in "${temas[@]}"; do
        printf '%s\0icon\x1f%s\n' "$tema" "$DOTFILES_DIR/themes/$tema/imagens/thumb.png"
    done | rofi -dmenu -i -show-icons -p "Tema" -a "$linha_atual" -selected-row "$linha_atual" -theme "$ESTILO"
)"

[[ -z "$escolha" || "$escolha" == "$TEMA_ATUAL" ]] && exit 0

if "$DOTFILES_DIR/scripts/switch-theme.sh" "$escolha" > /dev/null 2>&1; then
    notify-send -i "$DOTFILES_DIR/themes/$escolha/imagens/thumb.png" "Tema aplicado" "$escolha"
else
    notify-send -u critical "Erro ao trocar de tema" "Rode: scripts/switch-theme.sh $escolha"
fi
