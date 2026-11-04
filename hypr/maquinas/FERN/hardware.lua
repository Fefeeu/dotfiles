-- Notebook FERN (NVIDIA): variáveis da GPU, tearing e mouse

-- Variáveis para NVIDIA
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.config({
    -- Correções visuais para NVIDIA
    cursor = {
        no_hardware_cursors = true,
    },

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
