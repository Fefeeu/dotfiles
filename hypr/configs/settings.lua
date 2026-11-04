-- Opções gerais do Hyprland, iguais para todas as máquinas e temas
-- (bordas, gaps e cores vêm do tema; mouse e GPU, da máquina)

-- Programas usados nos binds: devolvidos no fim do arquivo, para o
-- rules/binds.lua pegar com require("configs.settings")
-- (no .conf eram as variáveis $terminal, $fileManager e $menu)
local programas = {
    terminal    = "kitty",
    fileManager = "dolphin",
    menu        = "~/.config/rofi/launchers/type-3/launcher.sh",
}

hl.config({
    general = {
        -- bordas, gaps e cores vêm do tema (~/.config/theme/hypr.lua)
        resize_on_border = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    input = {
        kb_layout    = "br,us",
        follow_mouse = 1,
        -- sensibilidade e aceleração do mouse ficam em hypr/maquinas/<Nome>/hardware.lua
        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.25,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})

-- Três dedos na horizontal trocam de área de trabalho
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

return programas
