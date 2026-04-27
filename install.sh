# --- Pergunta sobre o Hardware ---
echo -e "${YELLOW}Qual o perfil de hardware desta máquina?${NC}"
echo "1) AMD (Frieren Desktop)"
echo "2) NVIDIA (Notebook)"
read -p "Escolha uma opção [1-2]: " hw_choice

# Criar a pasta de hardware no .config
mkdir -p "$HOME/.config/hypr/hardware"

case $hw_choice in
    1)
        echo -e "${GREEN}Configurando perfil AMD...${NC}"
        ln -sfn "$DOTFILES_DIR/hypr/hardware/amd.conf" "$HOME/.config/hypr/hardware_profile.conf"
        ;;
    2)
        echo -e "${GREEN}Configurando perfil NVIDIA...${NC}"
        ln -sfn "$DOTFILES_DIR/hypr/hardware/nvidia.conf" "$HOME/.config/hypr/hardware_profile.conf"
        ;;
    *)
        echo -e "${YELLOW}Opção inválida. Pulando configuração de hardware.${NC}"
        ;;
esac

# --- Restante da instalação (Links comuns) ---
declare -A CONFIG_MAP=(
    ["hypr/hyprland.conf"]="$HOME/.config/hypr/hyprland.conf"
    ["swappy/config"]="$HOME/.config/swappy/config"
    ["kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["rofi"]="$HOME/.config/rofi"
    ["waybar"]="$HOME/.config/waybar"
    ["swaync"]="$HOME/.config/swaync"
)

for src in "${!CONFIG_MAP[@]}"; do
    DEST="${CONFIG_MAP[$src]}"
    SOURCE="$DOTFILES_DIR/$src"
    mkdir -p "$(dirname "$DEST")"
    
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        mv "$DEST" "$DEST.bak"
    fi
    
    ln -sfn "$SOURCE" "$DEST"
    echo -e "${GREEN}Linkado:${NC} $src -> $DEST"
done

echo -e "${BLUE}--- Setup concluído! ---${NC}"
