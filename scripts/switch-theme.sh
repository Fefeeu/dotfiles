#!/usr/bin/env bash
# Troca o tema ativo: ./scripts/switch-theme.sh <tema>
# Para cada componente usa themes/<tema>/<comp> se existir, senão base/<comp>.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

TEMA="${1:-}"
[[ -n "$TEMA" ]] || erro "uso: $(basename "$0") <tema>  (disponíveis: $(listar_temas | tr '\n' ' '))"

TEMA_DIR="$DOTFILES_DIR/themes/$TEMA"
[[ -d "$TEMA_DIR" ]] || erro "tema '$TEMA' não existe em themes/"

# --- VALIDAÇÃO (contrato em docs/temas.md) ---
for obrigatorio in hypr.conf palette imagens/wallpapers/wall.png imagens/thumb.png; do
    [[ -e "$TEMA_DIR/$obrigatorio" ]] || erro "$TEMA/$obrigatorio não encontrado. O tema está incompleto."
done

# --- LINK DO TEMA ATIVO ---
titulo "Tema: $TEMA"
link_com_backup "$TEMA_DIR" "$THEME_LINK"

# Links da estrutura antiga, que não são mais usados
[[ -L "$CONFIG_DIR/hypr/theme_profile.conf" ]] && rm "$CONFIG_DIR/hypr/theme_profile.conf"

# --- COMPONENTES (tema sobrescreve a base) ---
titulo "Componentes:"
for comp in "${!OVERRIDABLE[@]}"; do
    if [[ -e "$TEMA_DIR/$comp" ]]; then
        src="$TEMA_DIR/$comp"
    elif [[ -e "$DOTFILES_DIR/base/$comp" ]]; then
        src="$DOTFILES_DIR/base/$comp"
    else
        aviso "$comp não existe no tema nem na base, pulando..."
        continue
    fi
    link_com_backup "$src" "${OVERRIDABLE[$comp]}"
done

# --- PARTES SÓ DO TEMA ---
for parte in "${!THEME_ONLY[@]}"; do
    [[ -e "$TEMA_DIR/$parte" ]] && link_com_backup "$TEMA_DIR/$parte" "${THEME_ONLY[$parte]}"
done

# --- ESQUEMA DE CORES KDE (Dolphin e apps Qt) ---
if [[ -f "$TEMA_DIR/kde.colors" ]]; then
    titulo "Esquema de cores KDE:"
    link_com_backup "$TEMA_DIR/kde.colors" "$HOME/.local/share/color-schemes/$TEMA.colors"
    if command -v plasma-apply-colorscheme &> /dev/null; then
        plasma-apply-colorscheme "$TEMA" || aviso "plasma-apply-colorscheme falhou"
    else
        aviso "plasma-apply-colorscheme não encontrado, pulando aplicação automática."
    fi
fi

# --- RECARREGAR (só dentro de uma sessão Hyprland) ---
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    titulo "Recarregando:"
    hyprctl reload > /dev/null && info "hyprland"
    "$CONFIG_DIR/waybar/scripts/launch.sh" > /dev/null 2>&1 && info "waybar"
    pkill -USR1 -x kitty && info "kitty" || true
    if pgrep -x swww-daemon > /dev/null; then
        swww img "$TEMA_DIR/imagens/wallpapers/wall.png" --transition-type grow && info "wallpaper"
    fi
fi

echo -e "\n${VERDE}### Tema '$TEMA' aplicado ###${NC}"
