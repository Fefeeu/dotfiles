#!/bin/bash

BATTERY=/sys/class/power_supply/BAT0

while true; do
    LEVEL=$(cat $BATTERY/capacity)
    STATUS=$(cat $BATTERY/status)

    if [ "$STATUS" = "Discharging" ]; then
        if [ "$LEVEL" -le 5 ]; then
            notify-send -u critical "Bateria Crítica" "Bateria em ${LEVEL}%! Conecte o carregador!" -i battery-empty
        elif [ "$LEVEL" -le 20 ]; then
            notify-send -u normal "Bateria Baixa" "Bateria em ${LEVEL}%" -i battery-low
        fi
    fi

    sleep 150
done
