#!/usr/bin/env bash
# Launcher de apps (SUPER+D): rofi no modo drun com o layout type-3/style-1.
# Layout original do adi1090x/rofi (Aditya Shakya, github.com/adi1090x);
# os outros estilos do repositório original (style-2 a style-10) não vieram.

# Pasta do layout e estilo usado
dir="$HOME/.config/rofi/launchers/type-3"
estilo='style-1'

# Abre a lista de apps
rofi \
    -show drun \
    -theme "${dir}/${estilo}.rasi"
