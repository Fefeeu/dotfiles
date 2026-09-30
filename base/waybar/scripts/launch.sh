#!/bin/bash
# (Re)inicia o waybar: fecha o que estiver aberto e abre um novo

pkill -x waybar
while pgrep -x waybar > /dev/null; do sleep 0.1; done
waybar &
