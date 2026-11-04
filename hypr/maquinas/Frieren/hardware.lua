-- Desktop Frieren (AMD): variáveis da GPU, tearing, teclado externo e mouse

-- Variáveis para AMD
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("GBM_BACKEND", "drm")

hl.config({
    -- Tearing: deixa os jogos (regra immediate no windowrules.lua) mostrarem
    -- o quadro na hora, sem esperar a tela
    general = {
        allow_tearing = true,
    },

    -- Mouse: sensibilidade e aceleração (flat = sem aceleração)
    input = {
        sensitivity   = -0.25,
        accel_profile = "flat",
    },
})

-- Teclado externo: layout us primeiro
hl.device({
    name      = "compx-kysona-m600",
    kb_layout = "us,br",
})
