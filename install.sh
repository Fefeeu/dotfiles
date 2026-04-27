#!/bin/bash

# --- CONFIGURAÇÕES INICIAIS ---
DOTFILES_DIR="$HOME/dotfiles"
THEMES=("gruvbox" "dracula" "nord") # Adicione novos temas aqui

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${BLUE}--- Hyprland Modular Installer ---${NC}"

# 1. SELEÇÃO DE HARDWARE
echo -e "\n${YELLOW}1. Qual o perfil de hardware?${NC}"
options_hw=("AMD (Frieren Desktop)" "NVIDIA (Notebook)")
select opt_hw in "${options_hw[@]}"; do
    case $REPLY in
        1) HW="amd"; break ;;
        2) HW="nvidia"; break ;;
        *) echo "Opção inválida" ;;
    esac
done

# 2. SELEÇÃO DE TEMA
echo -e "\n${YELLOW}2. Qual tema deseja ativar?${NC}"
select TEMA in "${THEMES[@]}"; do
    if [[ -n "$TEMA" ]]; then
        echo -e "${GREEN}Tema $TEMA selecionado.${NC}"
        break
    else
        echo "Opção inválida"
    fi
done

# --- PROCESSAMENTO LOGICO ---

# Criar estrutura básica
mkdir -p "$HOME/.config/hypr"

# Link de Hardware
ln -sfn "$DOTFILES_DIR/hypr/hardware/$HW.conf" "$HOME/.config/hypr/hardware_profile.conf"

# Link do Wallpaper (O "ponteiro" universal)
# Criamos um link fixo que o Hyprland sempre vai ler, mas que aponta para o tema atual
mkdir -p "$DOTFILES_DIR/themes/current"
ln -sfn "$DOTFILES_DIR/themes/$TEMA/wall.png" "$DOTFILES_DIR/themes/current/wall.png"

# --- LINKS DE CONFIGURAÇÃO (MAP) ---
declare -A CONFIG_MAP=(
    ["hypr/hyprland.conf"]="$HOME/.config/hypr/hyprland.conf"
    ["hypr/configs"]="$HOME/.config/hypr/configs"
    ["hypr/rules"]="$HOME/.config/hypr/rules"
    ["hypr/hardware"]="$HOME/.config/hypr/hardware"
    ["rofi"]="$HOME/.config/rofi"
    ["kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
)

for src in "${!CONFIG_MAP[@]}"; do
    DEST="${CONFIG_MAP[$src]}"
    SOURCE="$DOTFILES_DIR/$src"
    mkdir -p "$(dirname "$DEST")"
    
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        mv "$DEST" "$DEST.bak"
    fi
    ln -sfn "$SOURCE" "$DEST"
done

# --- FINALIZAÇÃO E APLICAÇÃO ---

# 1. Reload Hyprland
if pgrep -x "Hyprland" > /dev/null; then
    hyprctl reload
fi

# 2. Update Wallpaper em tempo real (se swww estiver rodando)
if pgrep -x "swww-daemon" > /dev/null; then
    swww img "$DOTFILES_DIR/themes/current/wall.png" --transition-type grow --transition-step 90
fi

echo -e "\n${GREEN}### Instalação Concluída! Hardware: $HW | Tema: $TEMA ###${NC}"
