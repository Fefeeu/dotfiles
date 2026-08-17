#!/bin/bash
# --- CONFIGURAÇÕES ---
DOTFILES_DIR="$HOME/dotfiles"
THEMES=($(ls -d $DOTFILES_DIR/themes/*/ | xargs -n 1 basename | grep -v "current_theme"))
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
echo -e "${BLUE}--- Hyprland Setup (Provisionamento) ---${NC}"
# 1. SELEÇÃO DE HARDWARE
echo -e "\n${YELLOW}>> Perfil de Hardware:${NC}"
select HW in "amd" "nvidia"; do
    [[ -n $HW ]] && break || echo "Opção inválida"
done
# 2. SELEÇÃO DE TEMA
echo -e "\n${YELLOW}>> Tema Inicial:${NC}"
select TEMA in "${THEMES[@]}"; do
    [[ -n $TEMA ]] && break || echo "Opção inválida"
done
# --- VALIDAÇÃO ---
if [ ! -f "$DOTFILES_DIR/themes/$TEMA/hypr/colors.conf" ]; then
    echo -e "${RED}ERRO: $TEMA/hypr/colors.conf não encontrado. O tema está incompleto.${NC}"
    exit 1
fi
# --- LINKS DE HARDWARE E TEMA ---
mkdir -p "$HOME/.config/hypr"
ln -sfn "$DOTFILES_DIR/hypr/hardware/$HW.conf" "$HOME/.config/hypr/hardware_profile.conf"
echo -e "${GREEN}Linkado:${NC} hardware_profile.conf -> $HW.conf"
ln -sfn "$DOTFILES_DIR/themes/$TEMA" "$DOTFILES_DIR/themes/current_theme"
echo -e "${GREEN}Linkado:${NC} current_theme -> $TEMA"
ln -sfn "$DOTFILES_DIR/themes/$TEMA/hypr/colors.conf" "$HOME/.config/hypr/theme_profile.conf"
echo -e "${GREEN}Linkado:${NC} theme_profile.conf -> $TEMA/hypr/colors.conf"
# --- LINKS FIXOS (independentes de tema) ---
declare -A STATIC_MAP=(
    ["hypr/hyprland.conf"]="$HOME/.config/hypr/hyprland.conf"
    ["hypr/configs"]="$HOME/.config/hypr/configs"
    ["hypr/rules"]="$HOME/.config/hypr/rules"
    ["swappy/config"]="$HOME/.config/swappy/config"
)
echo -e "\n${YELLOW}>> Links fixos:${NC}"
for src in "${!STATIC_MAP[@]}"; do
    DEST="${STATIC_MAP[$src]}"
    mkdir -p "$(dirname "$DEST")"
    [[ -e "$DEST" && ! -L "$DEST" ]] && mv "$DEST" "$DEST.bak" && echo -e "${YELLOW}Backup criado:${NC} $DEST.bak"
    ln -sfn "$DOTFILES_DIR/$src" "$DEST"
    echo -e "${GREEN}Linkado:${NC} $src"
done
# --- LINKS DO TEMA ATIVO ---
declare -A THEME_MAP=(
    ["kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["waybar"]="$HOME/.config/waybar"
    ["rofi"]="$HOME/.config/rofi"
    ["swaync"]="$HOME/.config/swaync"
    ["qt6ct/qt6ct.conf"]="$HOME/.config/qt6ct/qt6ct.conf"
    ["kvantum"]="$HOME/.config/Kvantum"
)
echo -e "\n${YELLOW}>> Links do tema ($TEMA):${NC}"
for src in "${!THEME_MAP[@]}"; do
    DEST="${THEME_MAP[$src]}"
    FULL_SRC="$DOTFILES_DIR/themes/$TEMA/$src"
    if [ ! -e "$FULL_SRC" ]; then
        echo -e "${YELLOW}Aviso:${NC} $TEMA/$src não existe, pulando..."
        continue
    fi
    mkdir -p "$(dirname "$DEST")"
    [[ -e "$DEST" && ! -L "$DEST" ]] && mv "$DEST" "$DEST.bak" && echo -e "${YELLOW}Backup criado:${NC} $DEST.bak"
    ln -sfn "$FULL_SRC" "$DEST"
    echo -e "${GREEN}Linkado (tema):${NC} $src"
done
# --- ESQUEMA DE CORES KDE (Dolphin e apps Qt) ---
COLORS_DIR="$HOME/.local/share/color-schemes"
COLORS_SRC="$DOTFILES_DIR/themes/$TEMA/kde/${TEMA}.colors"
if [ -f "$COLORS_SRC" ]; then
    echo -e "\n${YELLOW}>> Esquema de cores KDE:${NC}"
    mkdir -p "$COLORS_DIR"
    ln -sfn "$COLORS_SRC" "$COLORS_DIR/${TEMA}.colors"
    echo -e "${GREEN}Linkado:${NC} ${TEMA}.colors -> color-schemes/"
    if command -v plasma-apply-colorscheme &> /dev/null; then
        plasma-apply-colorscheme "$TEMA"
        echo -e "${GREEN}Aplicado:${NC} esquema KDE '$TEMA'"
    else
        echo -e "${YELLOW}Aviso:${NC} plasma-apply-colorscheme não encontrado, pulando aplicação automática."
    fi
else
    echo -e "${YELLOW}Aviso:${NC} $TEMA/kde/${TEMA}.colors não existe, pulando esquema KDE..."
fi
# --- WALLPAPER ---
WALLPAPER="$DOTFILES_DIR/themes/$TEMA/wallpapers/wall.png"
if [ -f "$WALLPAPER" ] && pgrep -x "swww-daemon" > /dev/null; then
    echo -e "\n${BLUE}Aplicando wallpaper do tema $TEMA...${NC}"
    swww img "$WALLPAPER" --transition-type grow
fi
echo -e "\n${GREEN}### Sistema pronto! Edite os arquivos em ~/dotfiles e use 'hyprctl reload' ###${NC}"
