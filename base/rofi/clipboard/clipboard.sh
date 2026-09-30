#!/usr/bin/env bash
# Clipboard (SUPER+V): histórico do cliphist em grade no rofi.
#   Enter        copia o item escolhido
#   Shift+Delete apaga o item do histórico e reabre a grade na mesma posição
# Imagens aparecem como miniatura; texto aparece nas primeiras linhas.

ESTILO="$HOME/.config/rofi/clipboard/style-1.rasi"
# Miniaturas das imagens do histórico, extraídas uma vez por item
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-miniaturas"
# Largura de uma linha de texto no quadrado (em caracteres) e máximo de linhas
COLUNAS_TEXTO=22
LINHAS_TEXTO=3
# Separador de itens do rofi: os itens podem ter várias linhas, então não dá
# para usar \n (\x1e é o "record separator" do ASCII, não aparece em texto)
SEP=$'\x1e'

# Fecha o clipboard se já estiver aberto (SUPER+V de novo)
pkill -f 'rofi .*clipboard/style-1\.rasi' && exit 0

mkdir -p "$CACHE"

# quebrar_texto <texto>
# Quebra o texto em até LINHAS_TEXTO linhas de COLUNAS_TEXTO caracteres;
# se sobrar texto, a última linha termina com …
quebrar_texto() {
    local texto="$1" saida="" i
    for (( i = 0; i < LINHAS_TEXTO; i++ )); do
        [[ -z "$texto" ]] && break
        (( i > 0 )) && saida+=$'\n'
        if (( i == LINHAS_TEXTO - 1 && ${#texto} > COLUNAS_TEXTO )); then
            saida+="${texto:0:COLUNAS_TEXTO-1}…"
        else
            saida+="${texto:0:COLUNAS_TEXTO}"
        fi
        texto="${texto:COLUNAS_TEXTO}"
    done
    printf '%s' "$saida"
}

# montar_entradas
# Imprime um item do rofi por linha do cliphist, com a miniatura (imagem) ou
# o ícone de texto, e apaga do cache as miniaturas de itens que já saíram
montar_entradas() {
    local linha id texto arquivo
    local -A vivos=()
    for linha in "${itens[@]}"; do
        # cada linha do cliphist é "<id>\t<prévia>"
        id="${linha%%$'\t'*}"
        texto="${linha#*$'\t'}"
        if [[ "$texto" =~ ^\[\[\ binary\ data\ .*\ ([a-z]+)\ ([0-9]+x[0-9]+)\ \]\]$ ]]; then
            # imagem: extrai para o cache se ainda não estiver lá
            arquivo="$CACHE/$id.${BASH_REMATCH[1]}"
            vivos["$arquivo"]=1
            [[ -s "$arquivo" ]] || printf '%s\n' "$linha" | cliphist decode > "$arquivo"
            printf '%s\0icon\x1f%s%s' "${BASH_REMATCH[2]}" "$arquivo" "$SEP"
        else
            printf '%s\0icon\x1ftext-x-generic%s' "$(quebrar_texto "$texto")" "$SEP"
        fi
    done
    # limpeza do cache
    for arquivo in "$CACHE"/*; do
        [[ -e "$arquivo" && -z "${vivos[$arquivo]:-}" ]] && rm -f "$arquivo"
    done
}

linha_atual=0
while true; do
    mapfile -t itens < <(cliphist list)
    [[ ${#itens[@]} -eq 0 ]] && { notify-send "Clipboard" "Histórico vazio"; exit 0; }

    # -format i devolve o índice escolhido. O Shift+Delete deixa de ser o
    # delete-entry padrão e vira o atalho custom-1 (código de saída 10)
    indice="$(montar_entradas | rofi -dmenu -i \
        -p "Clipboard" -mesg "Enter copia · Shift+Delete apaga" \
        -sep "$SEP" -eh "$LINHAS_TEXTO" \
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
        10) # Shift+Delete: apaga e volta para a grade
            printf '%s\n' "${itens[$indice]}" | cliphist delete
            linha_atual=$indice ;;
        *)  exit 0 ;;
    esac
done
