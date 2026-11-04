-- Tema Catppuccin (Mocha, destaque rosa-mauve) — temporário para a Frieren
hl.config({
    general = {
        col = {
            -- rosa-mauve → pink → blue, em 45° — janela em foco
            active_border   = { colors = { "rgba(e0b4efff)", "rgba(f5c2e7ff)", "rgba(89b4faff)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)",   -- surface1 com transparência — inativas
        },
        border_size = 2,
        gaps_in     = 5,
        gaps_out    = 10,
    },
})
