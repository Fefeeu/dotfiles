#!/usr/bin/env bash
# Modo estudo, parte do usuário. O bloqueio em si é o serviço de sistema
# modo-estudo@.service (sistema/modo-estudo/, instalado com
# sudo scripts/instalar-modo-estudo.sh); aqui só se escolhe o tempo e se lê a contagem.
#
#   modo-estudo.sh iniciar [tempo]  SUPER+B ou "estudar" no terminal; tempo como
#                                   30m, 60, 1h30, 2h (sem tempo, pergunta)
#   modo-estudo.sh login            no login: pergunta se continua a sessão pausada
#   modo-estudo.sh waybar           JSON do módulo custom/estudo

# Arquivos escritos pelo serviço (só leitura para o usuário)
ESTADO=/var/lib/modo-estudo/restante   # sessão guardada (pausada ou ativa)
AO_VIVO=/run/modo-estudo/restante      # só existe com o modo rodando
SERVICO=/usr/local/libexec/modo-estudo

# Frase que precisa ser digitada para desistir de uma sessão pausada
FRASE="eu desisto de estudar agora"

# Opções de tempo do menu
TEMPOS=(30m 60m 1h30 2h "Outro (digite um tempo)")

# Layout das perguntas no rofi (o mesmo das perguntas do lib.sh)
ESTILO="$HOME/.config/rofi/temas/pergunta.rasi"

# --- FUNÇÕES ---
# tem_terminal
# Verdadeiro só com um terminal de verdade na frente (o atalho do Hyprland
# herda o TTY do login, por isso o bind manda a entrada de /dev/null)
tem_terminal() {
    [[ -t 0 && -t 2 ]]
}

# avisar <texto>
# Mostra a mensagem no terminal ou, fora dele, como notificação
avisar() {
    if tem_terminal; then
        echo "$1" >&2
    else
        notify-send -a "Modo estudo" -i accessories-dictionary "Modo estudo" "$1"
    fi
}

# formatar <segundos>
# Imprime H:MM:SS ou MM:SS
formatar() {
    local s="$1"
    if (( s >= 3600 )); then
        printf '%d:%02d:%02d' $((s / 3600)) $((s % 3600 / 60)) $((s % 60))
    else
        printf '%02d:%02d' $((s / 60)) $((s % 60))
    fi
}

# escolher <título> <mensagem> <opções...>
# Menu (select no terminal, rofi fora dele); imprime a escolha ou o texto
# digitado no rofi. Nada se cancelar
escolher() {
    local titulo="$1" msg="$2" op=""
    shift 2
    if tem_terminal; then
        echo "$msg" >&2
        PS3="$titulo: "
        select op in "$@"; do
            [[ -n "$op" ]] && break || echo "Opção inválida" >&2
        done
    else
        op="$(printf '%s\n' "$@" | rofi -dmenu -i -p "$titulo" -mesg "$msg" -theme "$ESTILO")" || true
    fi
    echo "$op"
}

# digitar <título> <mensagem>
# Pede um texto livre (read no terminal, rofi sem opções fora dele)
digitar() {
    local texto=""
    if tem_terminal; then
        read -rp "$2: " texto
    else
        texto="$(rofi -dmenu -p "$1" -mesg "$2" -theme "$ESTILO" < /dev/null)" || true
    fi
    echo "$texto"
}

# minutos_de <tempo>
# Converte 30, 30m, 2h, 1h30 ou 1h30m em minutos; falha se não entender
minutos_de() {
    local t="${1,,}"
    t="${t// /}"
    if [[ "$t" =~ ^([0-9]+)m?$ ]]; then
        echo $((10#${BASH_REMATCH[1]}))
    elif [[ "$t" =~ ^([0-9]+)h([0-9]+)?m?$ ]]; then
        echo $((10#${BASH_REMATCH[1]} * 60 + 10#${BASH_REMATCH[2]:-0}))
    else
        return 1
    fi
}

# iniciar_servico <instância>
# Liga modo-estudo@<instância>.service (o polkit libera o start sem senha)
iniciar_servico() {
    if [[ ! -x "$SERVICO" ]]; then
        avisar "Serviço não instalado: rode sudo ~/dotfiles/scripts/instalar-modo-estudo.sh"
        return 1
    fi
    systemctl start "modo-estudo@$1.service"
}

# perguntar_pausada
# Há uma sessão guardada e o modo não está rodando (o PC foi desligado):
# continua, ou descarta se a frase for digitada certinho. Cancelar continua
perguntar_pausada() {
    local resto escolha frase
    resto="$(< "$ESTADO")"
    escolha="$(escolher "Modo estudo" "Sessão pausada: faltam $(formatar "$resto")" \
        "Continuar" "Parar")"
    if [[ "$escolha" == "Parar" ]]; then
        frase="$(digitar "Parar" "Para desistir, digite: $FRASE")"
        if [[ "$frase" == "$FRASE" ]]; then
            iniciar_servico parar
            return
        fi
        avisar "Frase diferente, a sessão continua"
    fi
    iniciar_servico retomar && avisar "Modo estudo retomado: faltam $(formatar "$resto")"
}

# --- COMANDOS ---
case "${1:-}" in
    iniciar)
        # SUPER+B com o menu aberto: fecha o menu
        if ! tem_terminal && pkill -f 'rofi -dmenu .*-p Modo estudo'; then
            exit 0
        fi
        if [[ -e "$AO_VIVO" ]]; then
            avisar "Modo estudo já está ativo: faltam $(formatar "$(< "$AO_VIVO")")"
            exit 0
        fi
        if [[ -s "$ESTADO" ]]; then
            perguntar_pausada
            exit 0
        fi

        # tempo pelo argumento ou pelo menu; "Outro" pede para digitar
        tempo="${2:-}"
        if [[ -z "$tempo" ]]; then
            tempo="$(escolher "Modo estudo" "Por quanto tempo? (ex.: 45m, 1h15)" "${TEMPOS[@]}")"
            [[ "$tempo" == Outro* ]] && tempo="$(digitar "Tempo" "Digite o tempo (ex.: 45m, 1h15, 3h)")"
            [[ -z "$tempo" ]] && exit 0
        fi
        if ! minutos="$(minutos_de "$tempo")" || (( minutos < 1 || minutos > 720 )); then
            avisar "Tempo inválido: '$tempo' (use 30m, 1h30, 2h...; até 12h)"
            exit 1
        fi

        iniciar_servico "$minutos" && tem_terminal && echo "Modo estudo ativado: $(formatar $((minutos * 60)))"
        ;;
    login)
        # espera a sessão subir (waybar, notificações) antes de perguntar
        sleep 3
        [[ -s "$ESTADO" && ! -e "$AO_VIVO" ]] && perguntar_pausada
        ;;
    waybar)
        # rodando: contagem; pausado: contagem parada; desligado: texto vazio esconde o módulo
        if [[ -e "$AO_VIVO" ]]; then
            resto="$(formatar "$(< "$AO_VIVO")")"
            printf '{"text": "󰑴 %s", "tooltip": "Modo estudo: faltam %s", "class": "ativo"}\n' "$resto" "$resto"
        elif [[ -s "$ESTADO" ]]; then
            resto="$(formatar "$(< "$ESTADO")")"
            printf '{"text": "󰏤 %s", "tooltip": "Modo estudo pausado (SUPER+B para continuar)", "class": "pausado"}\n' "$resto"
        else
            echo '{"text": ""}'
        fi
        ;;
    *)
        echo "uso: $(basename "$0") iniciar [tempo] | login | waybar" >&2
        exit 2
        ;;
esac
