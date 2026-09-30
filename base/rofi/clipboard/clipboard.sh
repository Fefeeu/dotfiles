#!/usr/bin/env bash
# Clipboard (SUPER+V): lista o histórico do cliphist no rofi.
#   Enter        copia o item escolhido
#   Shift+Delete apaga o item do histórico e reabre a lista na mesma posição

ESTILO="$HOME/.config/rofi/clipboard/style-1.rasi"

# Fecha o clipboard se já estiver aberto (SUPER+V de novo)
pkill -f 'rofi .*clipboard/style-1\.rasi' && exit 0

linha_atual=0
while true; do
    # Cada linha do cliphist é "<id>\t<texto>"; o id é necessário para
    # decode/delete, mas só o texto aparece (-display-columns 2)
    mapfile -t itens < <(cliphist list)
    [[ ${#itens[@]} -eq 0 ]] && { notify-send "Clipboard" "Histórico vazio"; exit 0; }

    # -format i devolve o índice escolhido. O Shift+Delete deixa de ser o
    # delete-entry padrão e vira o atalho custom-1 (código de saída 10)
    indice="$(printf '%s\n' "${itens[@]}" | rofi -dmenu -i \
        -p "Clipboard" -mesg "Enter copia · Shift+Delete apaga" \
        -display-columns 2 -display-column-separator $'\t' \
        -format i -selected-row "$linha_atual" \
        -kb-delete-entry "" -kb-custom-1 "Shift+Delete" \
        -theme "$ESTILO")"
    codigo=$?

    # Esc ou clique fora: nada escolhido
    [[ -z "$indice" ]] && exit 0

    case $codigo in
        0)  # Enter: copia o conteúdo original (texto ou imagem)
            printf '%s\n' "${itens[$indice]}" | cliphist decode | wl-copy
            exit 0 ;;
        10) # Shift+Delete: apaga e volta para a lista
            printf '%s\n' "${itens[$indice]}" | cliphist delete
            linha_atual=$indice ;;
        *)  exit 0 ;;
    esac
done
