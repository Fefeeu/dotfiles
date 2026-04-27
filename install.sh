#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

DOTFILES_DIR="$HOME/dotfiles"

echo -e "${BLUE}--- Iniciando instalação dos Dotfiles ---${NC}"

# 1. Primeiro, mapeamos as pastas principais que precisam ser criadas FISICAMENTE
# antes de criarmos os links internos.
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/swappy"

# --- Pergunta sobre o Hardware ---
echo -e "${YELLOW}Qual o perfil de hardware desta máquina?${NC}"
echo "1) AMD (Frieren Desktop)"
echo "2) NVIDIA (Notebook)"
read -p "Escolha uma opção [1-2]: " hw_choice

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
# Note que separamos os componentes do Hyprland para evitar recursão de links
declare -A CONFIG_MAP=(
    ["hypr/hyprland.conf"]="$HOME/.config/hypr/hyprland.conf"
    ["hypr/configs"]="$HOME/.config/hypr/configs"
    ["hypr/rules"]="$HOME/.config/hypr/rules"
    ["hypr/hardware"]="$HOME/.config/hypr/hardware"
    ["swappy/config"]="$HOME/.config/swappy/config"
    ["kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["rofi"]="$HOME/.config/rofi"
    ["waybar"]="$HOME/.config/waybar"
    ["swaync"]="$HOME/.config/swaync"
)

for src in "${!CONFIG_MAP[@]}"; do
    DEST="${CONFIG_MAP[$src]}"
    SOURCE="$DOTFILES_DIR/$src"
    
    # Cria o diretório pai (ex: .config/) caso não exista
    mkdir -p "$(dirname "$DEST")"
    
    # Se já existir algo no destino que não seja um link simbólico, faz backup (.bak)
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        echo -e "${YELLOW}Backup realizado:${NC} $DEST -> $DEST.bak"
        mv "$DEST" "$DEST.bak"
    fi
    
    # Cria o link simbólico
    # -s: simbólico, -f: força, -n: trata link para diretório como arquivo (evita recursão)
    ln -sfn "$SOURCE" "$DEST"
    echo -e "${GREEN}Linkado:${NC} $src -> $DEST"
done

# Força o Hyprland a ler as mudanças imediatamente
if pgrep -x "Hyprland" > /dev/null; then
    hyprctl reload
fi

echo -e "${BLUE}--- Setup concluído com sucesso! ---${NC}"
