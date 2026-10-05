#!/usr/bin/env bash
# Confere o repositório e a instalação, sem alterar nada:
# scripts, temas, máquinas, links, rofi e config do Hyprland.
# Sai com código 1 se encontrar algum problema.

# Carrega os mapas de links e as mensagens compartilhadas
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
# Aqui um teste que falha não pode encerrar o script
set +e

PROBLEMAS=0

# passou <texto> / falhou <texto>
# Mostra o resultado de uma conferência; falhou também conta o problema
passou() { echo -e "  ${VERDE}✓${NC} $*"; }
falhou() { echo -e "  ${VERMELHO}✗${NC} $*"; PROBLEMAS=$((PROBLEMAS + 1)); }

# nomes_faltando <arquivo> <padrão com NOME> <nomes...>
# Imprime os nomes que não aparecem no arquivo; NOME no padrão é trocado
# por cada nome antes do grep
nomes_faltando() {
    local arquivo="$1" padrao="$2" nome
    shift 2
    for nome in "$@"; do
        grep -qE "${padrao//NOME/$nome}" "$arquivo" || echo "$nome"
    done
}

# conferir_link <destino>
# O destino tem que ser um link para dentro do repositório, e o alvo existir
conferir_link() {
    local dest="$1" alvo
    local nome="${dest/#"$HOME"/\~}"
    if [[ ! -L "$dest" ]]; then
        falhou "$nome não é link"
    elif [[ ! -e "$dest" ]]; then
        falhou "$nome é link quebrado"
    else
        alvo="$(readlink -f "$dest")"
        if [[ "$alvo" == "$DOTFILES_DIR/"* || "$alvo" == "$GERADOS_DIR/"* ]]; then
            passou "$nome"
        else
            falhou "$nome aponta para fora do repositório ($alvo)"
        fi
    fi
}

cd "$DOTFILES_DIR" || exit 1

# --- 1. SCRIPTS ---
titulo "Scripts"
while read -r script; do
    if ! saida="$(bash -n "$script" 2>&1)"; then
        falhou "$script: erro de sintaxe\n$saida"
    elif [[ "$script" != "scripts/lib.sh" && "$script" != bashrc.d/* && ! -x "$script" ]]; then
        # lib.sh e bashrc.d/ são carregados com source, não precisam ser executáveis
        falhou "$script: sem permissão de execução (chmod +x)"
    else
        passou "$script"
    fi
done < <(git ls-files '*.sh')

if command -v shellcheck &> /dev/null; then
    if saida="$(git ls-files -z '*.sh' | xargs -0 shellcheck -S warning 2>&1)"; then
        passou "shellcheck"
    else
        falhou "shellcheck encontrou avisos:\n$saida"
    fi
else
    aviso "shellcheck não instalado, pulando"
fi

# --- 2. TEMAS (contrato em docs/temas.md) ---
titulo "Temas"
CORES_WAYBAR=(fundo fundo_modulo fundo_hover borda texto texto_ativo texto_mudo destaque alerta)
CORES_ROFI=(background background-window background-alt foreground selected border-color)
CORES_KITTY=(background foreground color{0..15})

for dir in themes/*/; do
    tema="$(basename "$dir")"
    ok=1

    # arquivos obrigatórios; o _modelo não tem imagens de propósito
    obrigatorios=(hypr.conf palette/waybar.css palette/rofi.rasi palette/kitty.conf)
    [[ "$tema" == _* ]] || obrigatorios+=(imagens/wallpapers/wall.png imagens/thumb.png)
    for arq in "${obrigatorios[@]}"; do
        [[ -e "$dir$arq" ]] || { falhou "$tema: falta $arq"; ok=0; }
    done

    # nomes de cor que o layout base espera de cada paleta
    if [[ -f "${dir}palette/waybar.css" ]]; then
        faltando="$(nomes_faltando "${dir}palette/waybar.css" '@define-color[[:space:]]+NOME[[:space:]]' "${CORES_WAYBAR[@]}")"
        [[ -z "$faltando" ]] || { falhou "$tema: waybar.css sem" $faltando; ok=0; }
    fi
    if [[ -f "${dir}palette/rofi.rasi" ]]; then
        faltando="$(nomes_faltando "${dir}palette/rofi.rasi" '^[[:space:]]*NOME[[:space:]]*:' "${CORES_ROFI[@]}")"
        [[ -z "$faltando" ]] || { falhou "$tema: rofi.rasi sem" $faltando; ok=0; }
    fi
    if [[ -f "${dir}palette/kitty.conf" ]]; then
        faltando="$(nomes_faltando "${dir}palette/kitty.conf" '^[[:space:]]*NOME[[:space:]]' "${CORES_KITTY[@]}")"
        [[ -z "$faltando" ]] || { falhou "$tema: kitty.conf sem" $faltando; ok=0; }
    fi

    (( ok )) && passou "$tema"
done

# --- 3. MÁQUINAS ---
titulo "Máquinas"
for dir in hypr/maquinas/*/; do
    maq="$(basename "$dir")"
    ok=1
    for arq in hardware.conf monitors.conf; do
        [[ -f "$dir$arq" ]] || { falhou "$maq: falta $arq"; ok=0; }
    done
    (( ok )) && passou "$maq"
done
if [[ -L "$MAQUINA_LINK" && -d "$MAQUINA_LINK" ]]; then
    passou "${MAQUINA_LINK/#"$HOME"/\~} -> $(basename "$(readlink -f "$MAQUINA_LINK")")"
else
    falhou "${MAQUINA_LINK/#"$HOME"/\~} não existe ou está quebrado (rode scripts/switch-theme.sh <tema>)"
fi

# --- 4. LINKS ---
titulo "Links"
conferir_link "$THEME_LINK"
for src in "${!STATIC_MAP[@]}"; do
    conferir_link "${STATIC_MAP[$src]}"
done
for comp in "${!OVERRIDABLE[@]}"; do
    # componente que não existe no tema nem na base não tem link
    [[ -e "$THEME_LINK/$comp" || -e "base/$comp" ]] || continue
    conferir_link "${OVERRIDABLE[$comp]}"
done

# --- 5. ROFI ---
titulo "Rofi"
if command -v rofi &> /dev/null; then
    # layouts (shared/ só tem pedaços importados pelos layouts)
    while read -r rasi; do
        if saida="$(rofi -theme "$DOTFILES_DIR/$rasi" -dump-theme 2>&1 > /dev/null)" && [[ -z "$saida" ]]; then
            passou "$rasi"
        else
            falhou "$rasi:\n$(sed '/^[[:space:]]*$/d' <<< "$saida")"
        fi
    done < <(git ls-files 'base/rofi/*.rasi' 'themes/*/rofi/*.rasi' | grep -v -e '/shared/' -e '^base/rofi/config.rasi$')
else
    aviso "rofi não instalado, pulando"
fi

# --- 6. MODO ESTUDO (cópias instaladas pelo instalar-modo-estudo.sh) ---
titulo "Modo estudo"
if [[ -e /usr/local/libexec/modo-estudo ]]; then
    # instalado tem que bater com o repositório (a regra do polkit não dá
    # para ler sem root, fica de fora)
    declare -A INSTALADOS=(
        [sistema/modo-estudo/modo-estudo.sh]=/usr/local/libexec/modo-estudo
        [sistema/modo-estudo/modo-estudo@.service]=/etc/systemd/system/modo-estudo@.service
        [sistema/modo-estudo/apps]=/etc/modo-estudo/apps
        [sistema/modo-estudo/sites]=/etc/modo-estudo/sites
    )
    for src in "${!INSTALADOS[@]}"; do
        if cmp -s "$src" "${INSTALADOS[$src]}"; then
            passou "${INSTALADOS[$src]}"
        else
            falhou "${INSTALADOS[$src]} diferente de $src (rode sudo scripts/instalar-modo-estudo.sh)"
        fi
    done
else
    aviso "não instalado (sudo scripts/instalar-modo-estudo.sh), pulando"
fi

# --- 7. HYPRLAND (só dentro de uma sessão) ---
titulo "Hyprland"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload > /dev/null
    erros="$(hyprctl configerrors | sed '/^[[:space:]]*$/d')"
    if [[ -z "$erros" ]]; then
        passou "hyprctl configerrors"
    else
        falhou "hyprctl configerrors:\n$erros"
    fi
else
    aviso "fora de uma sessão Hyprland, pulando"
fi

# --- RESUMO ---
if (( PROBLEMAS == 0 )); then
    echo -e "\n${VERDE}### Tudo certo ###${NC}"
else
    echo -e "\n${VERMELHO}### $PROBLEMAS problema(s) ###${NC}"
    exit 1
fi
