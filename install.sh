#!/bin/bash

# Criar os links simbólicos
ln -sf ~/dotfiles/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln -sf ~/dotfiles/rofi/ ~/.config/
ln -sf ~/dotfiles/kitty/ ~/.config/

echo "Dotfiles instalados com sucesso!"
