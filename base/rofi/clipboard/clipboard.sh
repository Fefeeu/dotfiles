#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Clipboard Manager Corrigido

dir="$HOME/.config/rofi/clipboard"
theme='style-1'

# Injeta os blocos visuais que o dmenu ignora por padrão
cliphist list | rofi \
    -dmenu \
    -p "Clipboard" \
    -theme "${dir}/${theme}.rasi" \
    -theme-str '
        configuration {
            modi: "dmenu";
        }
        window {
            display: "Applications";
        }
        listview {
            lines: 10;
            columns: 1;
            cycle: true;
            dynamic: true;
            layout: vertical;
        }
        element {
            orientation: horizontal;
            children: [ "element-icon", "element-text" ];
            spacing: 10px;
        }
        element-icon {
            size: 0px;
        }
    ' | cliphist decode | wl-copy
