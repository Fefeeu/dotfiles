-- Atalhos de teclado e mouse
-- Os programas (terminal, gerenciador de arquivos, menu) vêm do settings.lua

local programas = require("configs.settings")
local mainMod = "SUPER"

-- tecla(combinação): "SUPER + <combinação>"
local function tecla(combinacao)
    return mainMod .. " + " .. combinacao
end

-- --- PRINCIPAIS ---
hl.bind(tecla("Return"), hl.dsp.exec_cmd(programas.terminal))
hl.bind(tecla("C"),      hl.dsp.window.close())
hl.bind(tecla("M"),      hl.dsp.exit())
hl.bind(tecla("E"),      hl.dsp.exec_cmd(programas.fileManager))
hl.bind(tecla("F"),      hl.dsp.window.float({ action = "toggle" }))
-- tela cheia (a janela ocupa o monitor todo, sem barra)
hl.bind("F11",           hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
-- abre o launcher, ou fecha se já estiver aberto
hl.bind(tecla("D"),      hl.dsp.exec_cmd("pkill -x rofi || " .. programas.menu))
hl.bind(tecla("P"),      hl.dsp.window.pseudo())
hl.bind(tecla("J"),      hl.dsp.layout("togglesplit"))
hl.bind(tecla("R"),      hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
-- seletor de temas
hl.bind(tecla("T"),      hl.dsp.exec_cmd("~/.config/hypr/scripts/seletor-tema.sh"))
-- modo estudo
hl.bind(tecla("B"),      hl.dsp.exec_cmd("~/.config/hypr/scripts/modo-estudo.sh iniciar < /dev/null"))
hl.bind(tecla("L"),      hl.dsp.exec_cmd("hyprlock"))

-- --- PRINT ---
-- seleciona uma área e abre no swappy para editar
hl.bind("Print", hl.dsp.exec_cmd("bash -c 'grimblast save area - | swappy -f -'"))

-- --- TECLADO ---
-- troca o layout do teclado (br/us)
hl.bind(tecla("Space"), hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- --- FOCO E JANELAS ---
-- setas: SUPER muda o foco, SUPER+SHIFT move a janela
for _, direcao in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(tecla(direcao),              hl.dsp.focus({ direction = direcao }))
    hl.bind(tecla("SHIFT + " .. direcao), hl.dsp.window.move({ direction = direcao }))
end

-- --- ÁREAS DE TRABALHO ---
-- SUPER+1..0 vai para a área 1..10; SUPER+SHIFT+1..0 leva a janela junto
for i = 1, 10 do
    local numero = i % 10 -- a área 10 fica na tecla 0
    hl.bind(tecla(numero),              hl.dsp.focus({ workspace = i }))
    hl.bind(tecla("SHIFT + " .. numero), hl.dsp.window.move({ workspace = i }))
end

-- --- MOUSE ---
-- SUPER + botão esquerdo arrasta, botão direito redimensiona
hl.bind(tecla("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(tecla("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- --- ÁREA DE TRANSFERÊNCIA ---
hl.bind(tecla("V"), hl.dsp.exec_cmd("~/.config/rofi/clipboard/clipboard.sh"))

-- --- MULTIMÍDIA ---
-- funcionam com a tela bloqueada e repetem enquanto a tecla está apertada
local multimidia = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), multimidia)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      multimidia)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     multimidia)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                          multimidia)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                          multimidia)
