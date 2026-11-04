-- Programas abertos uma vez, no login (no .conf eram os exec-once).
-- O evento "hyprland.start" só acontece ao abrir a sessão, não no reload

hl.on("hyprland.start", function()
    -- Wallpaper: abre o daemon do awww e, quando ele responder, põe o
    -- wallpaper do tema ativo (sem depender do cache do último wallpaper)
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("bash -c 'until awww query > /dev/null 2>&1; do sleep 0.2; done; awww img ~/.config/theme/imagens/wallpapers/wall.png'")

    -- Agente do polkit (janela de senha para hostnamectl e apps de admin)
    hl.exec_cmd("/usr/libexec/kf6/polkit-kde-authentication-agent-1")

    -- Waybar
    hl.exec_cmd("~/.config/waybar/scripts/launch.sh")

    -- Wi-Fi
    hl.exec_cmd("nm-applet")

    -- Notificação de bateria baixa
    hl.exec_cmd("~/.config/hypr/scripts/battery-notify.sh")

    -- Modo estudo: pergunta se continua a sessão pausada antes de desligar
    hl.exec_cmd("~/.config/hypr/scripts/modo-estudo.sh login")

    -- Histórico da área de transferência (texto e imagem, até 30 itens)
    hl.exec_cmd("wl-paste --type text --watch cliphist -max-items 30 store")
    hl.exec_cmd("wl-paste --type image --watch cliphist -max-items 30 store")
end)
