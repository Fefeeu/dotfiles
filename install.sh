#!/bin/bash

# --- CONFIGURAÇÕES ---
DOTFILES_DIR="$HOME/dotfiles"
# Pega as pastas dentro de themes/ para o menu
THEMES=($(ls -d $DOTFILES_DIR/themes/*/ | xargs -n 1 basename | grep -v "current_theme"))

# Cores
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}--- Hyprland Setup (Provisionamento) ---${NC}"

# 1. SELEÇÃO DE HARDWARE
echo -e "\n${YELLOW}>> Perfil de Hardware:${NC}"
select HW in "amd" "nvidia"; do
    [[ -n $HW ]] && break || echo "Opção inválida"
done

# 2. SELEÇÃO DE TEMA (Para o primeiro boot)
echo -e "\n${YELLOW}>> Tema Inicial:${NC}"
select TEMA in "${THEMES[@]}"; do
    [[ -n $TEMA ]] && break || echo "Opção inválida"
done

# --- CRIAÇÃO DOS LINKS ---

# Pasta de hardware_profile (essencial para o boot)
mkdir -p "$HOME/.config/hypr"
ln -sfn "$DOTFILES_DIR/hypr/hardware/$HW.conf" "$HOME/.config/hypr/hardware_profile.conf"

# Link da pasta do tema (para seu futuro script de troca de tema saber o que está ativo)
ln -sfn "$DOTFILES_DIR/themes/$TEMA" "$DOTFILES_DIR/themes/current_theme"

# Mapeamento de links comuns
declare -A CONFIG_MAP=(
    ["hypr/hyprland.conf"]="$HOME/.config/hypr/hyprland.conf"
    ["hypr/configs"]="$HOME/.config/hypr/configs"
    ["hypr/rules"]="$HOME/.config/hypr/rules"
    ["rofi"]="$HOME/.config/rofi"
    ["kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["waybar"]="$HOME/.config/waybar"
    ["swaync"]="$HOME/.config/swaync"
)

for src in "${!CONFIG_MAP[@]}"; do
    DEST="${CONFIG_MAP[$src]}"
    mkdir -p "$(dirname "$DEST")"
    
    # Backup se for pasta/arquivo real
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        mv "$DEST" "$DEST.bak"
    fi
    
    ln -sfn "$DOTFILES_DIR/$src" "$DEST"
    echo -e "${GREEN}Linkado:${NC} $src"
done

# --- APLICAÇÃO DO WALLPAPER PADRÃO (Apenas uma vez) ---
if pgrep -x "swww-daemon" > /dev/null; then
    echo -e "${BLUE}Aplicando wallpaper padrão do tema $TEMA...${NC}"
    swww img "$DOTFILES_DIR/themes/$TEMA/wallpapers/wall.png" --transition-type grow
fi

echo -e "\n${GREEN}### Sistema pronto! Edite os arquivos em ~/dotfiles e use 'hyprctl reload' ###${NC}"
