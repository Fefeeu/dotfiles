#!/bin/bash

# Cores para o terminal (estilo Rice!)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' 

DOTFILES_DIR="$HOME/dotfiles"

# Lista de mapeamentos: "pasta_no_dotfiles" "caminho_no_config"
# Isso facilita adicionar novos configs no futuro
declare -A CONFIG_MAP=(
    ["hypr/hyprland.conf"]="$HOME/.config/hypr/hyprland.conf"
    ["swappy/config"]="$HOME/.config/swappy/config"
    ["kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["rofi"]="$HOME/.config/rofi"
    ["waybar"]="$HOME/.config/waybar"
    ["swaync"]="$HOME/.config/swaync"
)

echo -e "${BLUE}--- Iniciando instalação dos Dotfiles na Frieren ---${NC}"

for src in "${!CONFIG_MAP[@]}"; do
    DEST="${CONFIG_MAP[$src]}"
    SOURCE="$DOTFILES_DIR/$src"
    
    # Cria o diretório pai caso não exista
    mkdir -p "$(dirname "$DEST")"
    
    # Se já existir algo no destino que não seja um link, faz backup
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        echo -e "${BLUE}Fazendo backup de $DEST para $DEST.bak${NC}"
        mv "$DEST" "$DEST.bak"
    fi
    
    # Cria/Sobrescreve o link simbólico
    ln -sfn "$SOURCE" "$DEST"
    echo -e "${GREEN}Linkado:${NC} $src -> $DEST"
done

echo -e "${BLUE}--- Setup concluído! ---${NC}"
