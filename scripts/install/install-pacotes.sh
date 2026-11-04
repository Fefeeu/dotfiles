#!/usr/bin/env bash
# Instala os pacotes do dnf que o dotfiles usa, lidos do
# docs/pacotes-dotfiles.md: seção [todas], a seção da máquina e, se o
# usuário quiser, [extras]. Ativa antes os repositórios das linhas "repo:"
# e trava com o versionlock os pacotes com versão fixa ("pacote = versão").
# O que já está instalado fica como está, então pode rodar várias vezes.
#
# Uso: install-pacotes.sh           instala (pede o sudo uma vez)
#      install-pacotes.sh --lista   só mostra o que seria instalado

# Chamado com "source": roda num bash próprio, senão o set -e e o exit do
# lib.sh ficam valendo no shell do terminal e o fecham no primeiro erro
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    bash "${BASH_SOURCE[0]}" "$@"
    return
fi

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

LISTA_PACOTES="$DOTFILES_DIR/docs/pacotes-dotfiles.md"

# --- ARGUMENTOS ---
SO_LISTAR=0
case "${1:-}" in
    --lista) SO_LISTAR=1 ;;
    "") ;;
    *) erro "opção desconhecida: $1 (use --lista ou nada)" ;;
esac

# --- CONFERÊNCIAS ---
# Precisa do dnf (Fedora) e da lista; para instalar, também de um terminal
# (o sudo e o dnf fazem perguntas; fora dele o confirmar abriria o rofi)
command -v dnf &> /dev/null || erro "dnf não encontrado: este script é para o Fedora"
[[ -f "$LISTA_PACOTES" ]] || erro "lista não encontrada: $LISTA_PACOTES"
(( SO_LISTAR )) || tem_terminal || erro "rode num terminal (o sudo e o dnf fazem perguntas)"

# maquina_atual
# Imprime o nome da máquina: o do link ~/.config/hypr/maquina, se já
# existir; senão a pasta com o nome do hostname; senão pergunta (só na
# instalação; o --lista não pergunta nada)
maquina_atual() {
    local link="$CONFIG_DIR/hypr/maquina" maq=""
    if [[ -L "$link" ]]; then
        maq="$(basename "$(readlink "$link")")"
    fi
    [[ -n "$maq" ]] || maq="$(detectar_maquina)"
    if [[ -z "$maq" ]] && (( ! SO_LISTAR )); then
        maq="$(perguntar_maquina)"
    fi
    echo "$maq"
}

# --- SEÇÕES ---
# [todas] sempre, a da máquina se houver e [extras] só com um sim
# (o --lista mostra [extras] sem perguntar)
MAQUINA="$(maquina_atual)"
SECOES=(todas)
if [[ -n "$MAQUINA" ]]; then
    SECOES+=("$MAQUINA")
else
    aviso "nenhuma máquina escolhida: só a seção [todas]"
fi
if (( SO_LISTAR )) || confirmar "Instalar também os pacotes de [extras]?"; then
    SECOES+=(extras)
fi

# secao_ativa <nome>
# Verdadeiro se a seção estiver na lista escolhida acima
secao_ativa() {
    local s
    for s in "${SECOES[@]}"; do
        [[ "$s" == "$1" ]] && return 0
    done
    return 1
}

# --- LEITURA DA LISTA ---
# Linha a linha: tira o comentário e os espaços; "[nome]" troca de seção,
# "repo: ..." é um repositório, "pacote = versão" é um pacote com versão
# fixa e o resto é o nome de um pacote.
# NOMES tem só o nome; PACOTES tem o que vai para o dnf e o rpm
# (nome ou nome-versão); TRAVAR tem os nome-versão a travar
REPOS=()
NOMES=()
PACOTES=()
TRAVAR=()
secao=""
while IFS= read -r linha || [[ -n "$linha" ]]; do
    linha="${linha%%#*}"
    linha="$(echo "$linha" | xargs)"
    [[ -z "$linha" ]] && continue
    if [[ "$linha" =~ ^\[(.+)\]$ ]]; then
        secao="${BASH_REMATCH[1]}"
        continue
    fi
    secao_ativa "$secao" || continue
    if [[ "$linha" == repo:* ]]; then
        REPOS+=("$(echo "${linha#repo:}" | xargs)")
    elif [[ "$linha" =~ ^([^[:space:]=]+)[[:space:]]*=[[:space:]]*([^[:space:]]+)$ ]]; then
        NOMES+=("${BASH_REMATCH[1]}")
        PACOTES+=("${BASH_REMATCH[1]}-${BASH_REMATCH[2]}")
        TRAVAR+=("${BASH_REMATCH[1]}-${BASH_REMATCH[2]}")
    else
        NOMES+=("${linha%% *}")
        PACOTES+=("${linha%% *}")
    fi
done < "$LISTA_PACOTES"

titulo "Pacotes (${SECOES[*]}):"
info "${#REPOS[@]} repositório(s) e ${#PACOTES[@]} pacote(s) (${#TRAVAR[@]} com versão fixa) em ${LISTA_PACOTES/#"$HOME"/\~}"

# --- SÓ LISTAR ---
# Mostra os repositórios e os pacotes, marcando os já instalados (na
# versão fixa, quando há uma), e sai sem sudo e sem mudar nada
if (( SO_LISTAR )); then
    for repo in "${REPOS[@]}"; do
        echo "  repo: $repo"
    done
    for pacote in "${PACOTES[@]}"; do
        if rpm -q "$pacote" &> /dev/null; then
            echo -e "  ${VERDE}✓${NC} $pacote"
        else
            echo "  · $pacote"
        fi
    done
    exit 0
fi

# Senha do sudo uma vez só, antes de qualquer mudança
sudo -v || erro "sem sudo, nada foi instalado"

# --- REPOSITÓRIOS ---
# copr <usuário/projeto>: ativa o COPR, se ainda não estiver ativo
# rpmfusion: instala os pacotes que ativam o RPM Fusion free e nonfree
titulo "Repositórios:"
for repo in "${REPOS[@]}"; do
    tipo="${repo%% *}"
    nome="$(echo "${repo#"$tipo"}" | xargs)"
    case "$tipo" in
        copr)
            # na lista do dnf aparece copr.fedorainfracloud.org/<usuário/projeto>,
            # com "(disabled)" no fim quando está desativado
            if dnf copr list 2> /dev/null | grep -v disabled | grep -F "/$nome" > /dev/null; then
                info "COPR $nome já ativo"
            else
                sudo dnf copr enable -y "$nome" || aviso "não deu para ativar o COPR $nome"
            fi
            ;;
        rpmfusion)
            if rpm -q rpmfusion-free-release rpmfusion-nonfree-release &> /dev/null; then
                info "RPM Fusion já ativo"
            else
                versao="$(rpm -E %fedora)"
                sudo dnf install -y \
                    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$versao.noarch.rpm" \
                    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$versao.noarch.rpm" \
                    || aviso "não deu para ativar o RPM Fusion"
            fi
            ;;
        *)
            aviso "repositório desconhecido, pulado: repo: $repo"
            ;;
    esac
done

# --- VERSÕES FIXAS ---
# Trava antes de instalar, para o dnf respeitar a versão também quando
# escolhe as dependências. Trava de outra versão (lista mudou) é trocada;
# a que já está certa fica como está.
# "dnf versionlock list" mostra "Package name: <nome>" e "evr = <versão>"
if (( ${#TRAVAR[@]} )); then
    titulo "Versões fixas:"
    TRAVAS="$(dnf versionlock list 2> /dev/null \
        | awk '/^Package name:/ {n=$3} /^evr = / {print n "-" $3}')"
    for spec in "${TRAVAR[@]}"; do
        nome="${spec%-*-*}"
        if grep -Fx -- "$spec" <<< "$TRAVAS" > /dev/null; then
            info "$spec já travado"
            continue
        fi
        if grep "^$nome-[0-9]" <<< "$TRAVAS" > /dev/null; then
            sudo dnf versionlock delete "$nome" > /dev/null || true
        fi
        sudo dnf versionlock add "$spec" > /dev/null \
            && echo -e "${VERDE}Travado:${NC} $spec" \
            || aviso "não deu para travar $spec"
    done
fi

# --- PACOTES DISPONÍVEIS ---
# Com os repositórios ativos, separa o que existe neles do que não existe
# (o repoquery só olha os repositórios, não o que já está instalado)
mapfile -t EXISTEM < <(dnf repoquery -q --qf '%{name}\n' "${PACOTES[@]}" 2> /dev/null | sort -u)
# sem resposta nenhuma, o problema é o dnf (rede, repositório), não a lista
(( ${#EXISTEM[@]} )) || erro "o dnf não respondeu (sem internet?): nada foi instalado"

# --- O QUE FALTA ---
# Já instalado fica como está: o "dnf install" tentaria atualizar, e
# atualizar só uma parte dos pacotes do Hyprland mistura versões que não
# funcionam juntas (atualizar é com o "dnf upgrade", que leva tudo junto).
# Do que falta, separa o que os repositórios têm do que não têm
INSTALADOS=()
INSTALAR=()
FALTAM=()
for i in "${!PACOTES[@]}"; do
    pacote="${PACOTES[$i]}"
    if printf '%s\n' "${EXISTEM[@]}" | grep -Fx -- "${NOMES[$i]}" > /dev/null; then
        if rpm -q "$pacote" &> /dev/null; then
            INSTALADOS+=("$pacote")
        else
            INSTALAR+=("$pacote")
        fi
    else
        FALTAM+=("$pacote")
    fi
done

# --- INSTALAÇÃO ---
# Tudo numa transação só; o dnf mostra o que vai mudar e pede confirmação
titulo "Instalação:"
info "${#INSTALADOS[@]} pacote(s) já instalado(s), ${#INSTALAR[@]} para instalar"
if (( ${#INSTALAR[@]} )); then
    sudo dnf install "${INSTALAR[@]}" || aviso "o dnf não terminou a instalação"
else
    info "Nada para instalar"
fi

# --- RESUMO ---
# Pacotes que nenhum repositório ativo tem: avisa se já estão instalados
# (vindos de um repositório antigo) ou se faltam de verdade
if (( ${#FALTAM[@]} )); then
    titulo "Não encontrados nos repositórios:"
    for pacote in "${FALTAM[@]}"; do
        if rpm -q "$pacote" &> /dev/null; then
            aviso "$pacote (instalado, mas de um repositório que não está na lista)"
        else
            aviso "$pacote (não instalado)"
        fi
    done
else
    info "Todos os pacotes foram encontrados"
fi
