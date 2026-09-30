#!/usr/bin/env bash
# Troca o tema ativo: ./scripts/switch-theme.sh <tema>
# Para cada componente usa themes/<tema>/<comp> se existir, senão base/<comp>.

# Carrega os mapas de links e as funções compartilhadas
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Nome do tema vem do primeiro argumento; sem ele, mostra o uso e os temas
TEMA="${1:-}"
[[ -n "$TEMA" ]] || erro "uso: $(basename "$0") <tema>  (disponíveis: $(listar_temas | tr '\n' ' '))"

TEMA_DIR="$DOTFILES_DIR/themes/$TEMA"
[[ -d "$TEMA_DIR" ]] || erro "tema '$TEMA' não existe em themes/"

# --- VALIDAÇÃO (contrato em docs/temas.md) ---
# Sem estes arquivos o tema não é aplicado
for obrigatorio in hypr.conf palette imagens/wallpapers/wall.png imagens/thumb.png; do
    [[ -e "$TEMA_DIR/$obrigatorio" ]] || erro "$TEMA/$obrigatorio não encontrado. O tema está incompleto."
done

# --- LINK DO TEMA ATIVO ---
# ~/.config/theme passa a apontar para o tema; é por ele que os layouts acham a paleta
titulo "Tema: $TEMA"
link_com_backup "$TEMA_DIR" "$THEME_LINK"

# Links da estrutura antiga, que não são mais usados
[[ -L "$CONFIG_DIR/hypr/theme_profile.conf" ]] && rm "$CONFIG_DIR/hypr/theme_profile.conf"

# --- COMPONENTES (tema sobrescreve a base) ---
# Usa a pasta do tema se existir, senão a da base
titulo "Componentes:"
for comp in "${!OVERRIDABLE[@]}"; do
    if [[ -e "$TEMA_DIR/$comp" ]]; then
        src="$TEMA_DIR/$comp"
    elif [[ -e "$DOTFILES_DIR/base/$comp" ]]; then
        src="$DOTFILES_DIR/base/$comp"
    else
        # não há o que linkar: tira o link que o tema anterior deixou
        aviso "$comp não existe no tema nem na base, pulando..."
        remover_link_do_tema "${OVERRIDABLE[$comp]}"
        continue
    fi
    link_com_backup "$src" "${OVERRIDABLE[$comp]}"
done

# --- PARTES SÓ DO TEMA ---
# Linka a parte se o tema tiver; se não tiver, remove o link do tema anterior
for parte in "${!THEME_ONLY[@]}"; do
    if [[ -e "$TEMA_DIR/$parte" ]]; then
        link_com_backup "$TEMA_DIR/$parte" "${THEME_ONLY[$parte]}"
    else
        remover_link_do_tema "${THEME_ONLY[$parte]}"
    fi
done

# --- QT6CT (aparência dos apps Qt6 no Hyprland) ---
# O qt6ct.conf do tema é um template: @HOME@ e @TEMA@ viram a pasta do
# usuário e o nome do tema, porque o qt6ct só aceita caminho absoluto em
# color_scheme_path. A cópia pronta fica em GERADOS_DIR e é ela que é linkada.
QT6CT_DEST="$CONFIG_DIR/qt6ct/qt6ct.conf"
if [[ -f "$TEMA_DIR/qt6ct.conf" ]]; then
    mkdir -p "$GERADOS_DIR"
    sed -e "s|@HOME@|$HOME|g" -e "s|@TEMA@|$TEMA|g" "$TEMA_DIR/qt6ct.conf" > "$GERADOS_DIR/qt6ct.conf"
    link_com_backup "$GERADOS_DIR/qt6ct.conf" "$QT6CT_DEST"
else
    remover_link_do_tema "$QT6CT_DEST"
fi

# --- ESQUEMA DE CORES KDE (Dolphin e apps Qt) ---
ESQUEMAS_DIR="$HOME/.local/share/color-schemes"

# Remove os esquemas de outros temas (e links quebrados de nomes antigos);
# o do tema atual fica, se ele tiver kde.colors
for esquema in "$ESQUEMAS_DIR"/*.colors; do
    [[ "$(basename "$esquema")" == "$TEMA.colors" && -f "$TEMA_DIR/kde.colors" ]] && continue
    remover_link_do_tema "$esquema"
done

# Linka o esquema do tema e pede ao Plasma para aplicar
if [[ -f "$TEMA_DIR/kde.colors" ]]; then
    titulo "Esquema de cores KDE:"
    link_com_backup "$TEMA_DIR/kde.colors" "$ESQUEMAS_DIR/$TEMA.colors"
    if command -v plasma-apply-colorscheme &> /dev/null; then
        plasma-apply-colorscheme "$TEMA" || aviso "plasma-apply-colorscheme falhou"
    else
        aviso "plasma-apply-colorscheme não encontrado, pulando aplicação automática."
    fi
fi

# --- RECARREGAR (só dentro de uma sessão Hyprland) ---
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    titulo "Recarregando:"
    # bordas, gaps e cores do hypr.conf do tema
    hyprctl reload > /dev/null && info "hyprland"
    # reinicia a barra com o layout e a paleta novos
    "$CONFIG_DIR/waybar/scripts/launch.sh" > /dev/null 2>&1 && info "waybar"
    # SIGUSR1 faz o kitty reler a config sem fechar as janelas
    pkill -USR1 -x kitty && info "kitty" || true
    # troca o wallpaper só se o daemon do swww estiver rodando
    if pgrep -x swww-daemon > /dev/null; then
        swww img "$TEMA_DIR/imagens/wallpapers/wall.png" --transition-type grow && info "wallpaper"
    fi
fi

echo -e "\n${VERDE}### Tema '$TEMA' aplicado ###${NC}"
