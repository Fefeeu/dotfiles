#!/bin/bash
# Avisa por notificação quando a bateria do notebook está baixa.
# Iniciado pelo execs.conf; no desktop (sem bateria) sai na hora.

# Acha a bateria do notebook (BAT0, BAT1, CMB0...): a primeira do tipo
# Battery que não seja de periférico (mouse e fone têm scope=Device)
BATTERY=""
for dir in /sys/class/power_supply/*; do
    [ "$(cat "$dir/type" 2>/dev/null)" = "Battery" ] || continue
    [ "$(cat "$dir/scope" 2>/dev/null)" = "Device" ] && continue
    BATTERY="$dir"
    break
done

# sem bateria (desktop), não há o que monitorar
[ -n "$BATTERY" ] || exit 0

# Confere a bateria a cada 150 s
while true; do
    # carga em % e estado (Charging, Discharging, Full...)
    LEVEL=$(cat $BATTERY/capacity)
    STATUS=$(cat $BATTERY/status)

    # só avisa descarregando: até 5% é crítico, até 20% é aviso normal
    if [ "$STATUS" = "Discharging" ]; then
        if [ "$LEVEL" -le 5 ]; then
            notify-send -u critical "Bateria Crítica" "Bateria em ${LEVEL}%! Conecte o carregador!" -i battery-empty
        elif [ "$LEVEL" -le 20 ]; then
            notify-send -u normal "Bateria Baixa" "Bateria em ${LEVEL}%" -i battery-low
        fi
    fi

    sleep 150
done
