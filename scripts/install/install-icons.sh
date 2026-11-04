#!/usr/bin/env bash
# Instala os temas de ícones usados pelo dotfiles em ~/.local/share/icons,
# sem sudo, direto do GitHub de cada tema. Tema que já existe (no sistema
# ou na pasta do usuário) é pulado, então pode rodar várias vezes.

# Chamado com "source": roda num bash próprio, senão o set -e e o exit do
# lib.sh ficam valendo no shell do terminal e o fecham no primeiro erro
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    bash "${BASH_SOURCE[0]}" "$@"
    return
fi

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

ICONES_DIR="$HOME/.local/share/icons"

# tem_icone <nome>
# Verdadeiro se o tema de ícones já existe no sistema ou no usuário
tem_icone() {
    [[ -d "/usr/share/icons/$1" || -d "$ICONES_DIR/$1" || -d "$HOME/.icons/$1" ]]
}

# instalar_do_github <repositório> <ramo> <tema>...
# Baixa o repositório e copia as pastas dos temas pedidos. Se faltar um,
# copia todos: as variantes costumam ter links para a pasta principal
instalar_do_github() {
    local repo="$1" ramo="$2" tema falta=""
    shift 2
    for tema in "$@"; do
        tem_icone "$tema" || falta=1
    done
    if [[ -z "$falta" ]]; then
        info "$* já instalados"
        return 0
    fi
    mkdir -p "$ICONES_DIR"
    # o tarball tem a pasta <projeto>-<ramo>/ na raiz; tira esse nível
    curl -fL --progress-bar "https://github.com/$repo/archive/refs/heads/$ramo.tar.gz" \
        | tar -xz -C "$ICONES_DIR" --strip-components=1 "${@/#/"${repo#*/}-$ramo/"}" \
        || erro "não consegui baixar $repo"
    for tema in "$@"; do
        echo -e "${VERDE}Instalado:${NC} $tema -> ${ICONES_DIR/#"$HOME"/\~}/$tema"
    done
}

titulo "Ícones:"
# Papirus: rofi (Papirus) e qt6ct dos temas (Papirus-Dark, Papirus-Light)
instalar_do_github PapirusDevelopmentTeam/papirus-icon-theme master Papirus Papirus-Dark Papirus-Light
