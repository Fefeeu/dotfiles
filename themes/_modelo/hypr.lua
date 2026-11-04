-- Tema <nome> — carregado depois do settings.lua, então sobrescreve o que definir aqui.
-- Obrigatório: bordas e gaps. Pode ter também decoration, animations etc.
-- Borda em degradê: active_border = { colors = { "rgba(...)", "rgba(...)" }, angle = 45 }
hl.config({
    general = {
        col = {
            active_border   = "rgba(ffffffff)",
            inactive_border = "rgba(2e2e2e55)",
        },
        border_size = 2,
        gaps_in     = 5,
        gaps_out    = 10,
    },
})
