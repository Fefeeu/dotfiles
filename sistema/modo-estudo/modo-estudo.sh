#!/usr/bin/env bash
# Serviço do modo estudo: roda como root pelo systemd (modo-estudo@<arg>.service)
# e, enquanto houver tempo, mata os apps da lista e bloqueia os sites.
# Instalado em /usr/local/libexec/modo-estudo por scripts/instalar-modo-estudo.sh
# (cópia, não link: assim não dá para desligar o bloqueio editando o repositório).
#
# Argumento (a instância do serviço):
#   <minutos>  começa uma sessão (ou continua a pausada, se houver)
#   retomar    continua a sessão pausada
#   parar      descarta a sessão pausada (recusa se o modo estiver rodando)
#
# Códigos de saída: 0 ok, 2 argumento inválido, 3 recusado (já ativo ou
# nada a retomar). O serviço não reinicia com 2 e 3; com qualquer outra
# falha (ex.: kill -9) o systemd sobe ele de novo e a contagem continua.

set -uo pipefail

# --- CAMINHOS ---
CONF=/etc/modo-estudo                  # apps, sites e usuario (copiados do repo)
ESTADO=/var/lib/modo-estudo/restante   # segundos que faltam; sobrevive ao reinício
AO_VIVO=/run/modo-estudo/restante      # contagem a cada segundo, lida pelo waybar
TRAVA=/run/modo-estudo.lock            # uma sessão por vez
MARCA_INI="# modo-estudo: início"
MARCA_FIM="# modo-estudo: fim"

# Pastas de políticas dos navegadores Chromium: só entra a de quem está instalado
declare -A POLITICAS=(
    [/opt/vivaldi]=/etc/vivaldi/policies/managed
    [/opt/google/chrome]=/etc/opt/chrome/policies/managed
    [/opt/microsoft/msedge]=/etc/opt/edge/policies/managed
)

# Maior sessão aceita, em minutos (12 h)
MAX_MINUTOS=720

# --- FUNÇÕES ---
# ler_lista <arquivo>
# Imprime as linhas do arquivo sem comentários e sem linhas vazias
ler_lista() {
    sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$1" 2> /dev/null
}

# notificar <título> <texto>
# Manda uma notificação para a sessão do usuário (o root não tem sessão própria)
notificar() {
    local usuario uid
    usuario="$(< "$CONF/usuario")" || return 0
    uid="$(id -u "$usuario")" || return 0
    runuser -u "$usuario" -- env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        notify-send -a "Modo estudo" -i accessories-dictionary "$1" "$2" &> /dev/null || true
}

# escrever_hosts <conteúdo>
# Reescreve o /etc/hosts sem trocar o arquivo (mantém dono e contexto do SELinux)
escrever_hosts() {
    printf '%s\n' "$1" > /etc/hosts
}

# liberar_sites
# Tira o bloco do modo estudo do /etc/hosts e as políticas dos navegadores
liberar_sites() {
    local dir
    if grep -qF "$MARCA_INI" /etc/hosts; then
        escrever_hosts "$(sed "/^$MARCA_INI/,/^$MARCA_FIM/d" /etc/hosts)"
    fi
    for dir in "${POLITICAS[@]}"; do
        rm -f "$dir/modo-estudo.json"
    done
}

# bloquear_sites
# Aponta os sites para lugar nenhum no /etc/hosts (vale para qualquer
# navegador sem DNS seguro) e põe uma URLBlocklist nos navegadores Chromium
# (vale mesmo com DNS seguro e em abas já abertas)
bloquear_sites() {
    local sites site bloco json prog
    mapfile -t sites < <(ler_lista "$CONF/sites")
    (( ${#sites[@]} )) || return 0
    liberar_sites

    bloco="$MARCA_INI"
    for site in "${sites[@]}"; do
        bloco+=$'\n'"0.0.0.0 $site"$'\n'":: $site"
    done
    bloco+=$'\n'"$MARCA_FIM"
    escrever_hosts "$(< /etc/hosts)"$'\n'"$bloco"

    json="$(printf '"%s",' "${sites[@]}")"
    for prog in "${!POLITICAS[@]}"; do
        [[ -d "$prog" ]] || continue
        mkdir -p "${POLITICAS[$prog]}"
        printf '{ "URLBlocklist": [%s] }\n' "${json%,}" > "${POLITICAS[$prog]}/modo-estudo.json"
    done
}

# matar_apps
# Mata os processos da lista (nome exato do processo); avisa quando matou algum
matar_apps() {
    local app
    for app in "${APPS[@]}"; do
        if pkill -KILL -x -- "$app"; then
            notificar "$app bloqueado" "Faltam $((restante / 60)) min de estudo"
        fi
    done
}

# pausar
# Chamado ao parar o serviço (desligar o PC ou systemctl stop): guarda o
# tempo que falta e desfaz o bloqueio; no próximo login vem a pergunta
pausar() {
    (( restante > 0 )) && printf '%s\n' "$restante" > "$ESTADO"
    liberar_sites
    rm -f "$AO_VIVO"
    exit 0
}

# terminar
# O tempo acabou: apaga a sessão, desfaz o bloqueio e avisa
terminar() {
    rm -f "$ESTADO" "$AO_VIVO"
    liberar_sites
    notificar "Modo estudo terminado" "Apps e sites liberados"
    exit 0
}

# --- ARGUMENTO ---
mkdir -p "$(dirname "$ESTADO")" "$(dirname "$AO_VIVO")"
chmod 755 "$(dirname "$ESTADO")" "$(dirname "$AO_VIVO")"

# a trava fica com o processo até ele sair; outra instância não consegue pegar
exec 9> "$TRAVA"
if ! flock -n 9; then
    echo "modo estudo já está ativo" >&2
    exit 3
fi

case "${1:-}" in
    parar)
        # só descarta uma sessão pausada (com o modo rodando, a trava acima já recusou)
        rm -f "$ESTADO" "$AO_VIVO"
        liberar_sites
        notificar "Modo estudo descartado" "A sessão pausada foi apagada"
        exit 0
        ;;
    retomar)
        [[ -s "$ESTADO" ]] || { echo "nenhuma sessão pausada" >&2; exit 3; }
        ;;
    *)
        if [[ ! "${1:-}" =~ ^[0-9]+$ ]] || (( 10#$1 < 1 || 10#$1 > MAX_MINUTOS )); then
            echo "uso: modo-estudo <minutos 1-$MAX_MINUTOS> | retomar | parar" >&2
            exit 2
        fi
        ;;
esac

# Sessão pausada (reinício ou o serviço caiu) tem prioridade sobre o tempo pedido
if [[ -s "$ESTADO" ]]; then
    restante="$(< "$ESTADO")"
    [[ "$restante" =~ ^[0-9]+$ ]] || restante=60
else
    restante=$(( 10#$1 * 60 ))
    printf '%s\n' "$restante" > "$ESTADO"
    notificar "Modo estudo ativado" "$(( restante / 60 )) min sem distrações"
fi

# --- SESSÃO ---
mapfile -t APPS < <(ler_lista "$CONF/apps")
trap pausar TERM INT HUP
bloquear_sites

# A cada segundo: mata os apps, atualiza a contagem e desconta o tempo
# passado. Um salto maior que 5 s é suspensão, que não conta como estudo
printf -v ultimo '%(%s)T' -1
volta=0
while (( restante > 0 )); do
    matar_apps
    printf '%s\n' "$restante" > "$AO_VIVO"
    # grava no disco a cada 30 s (se a energia cair, perde no máximo isso)
    (( volta++ % 30 == 0 )) && printf '%s\n' "$restante" > "$ESTADO"

    # sleep em segundo plano + wait: o trap roda na hora ao parar o serviço
    # (9>&- para o sleep não segurar a trava depois que o script sair)
    sleep 1 9>&- &
    wait $!

    printf -v agora '%(%s)T' -1
    passo=$(( agora - ultimo ))
    ultimo=$agora
    (( passo < 0 || passo > 5 )) && passo=1
    restante=$(( restante - passo ))
done

terminar
