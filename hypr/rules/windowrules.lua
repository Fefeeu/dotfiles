-- Regras de janela: cada regra tem um match (quais janelas) e os efeitos
-- (o Hyprland confere os nomes dos dois no --verify-config)

-- --- GERAL ---
-- Nenhum app se maximiza sozinho
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
-- Em tela cheia, cantos retos
hl.window_rule({ match = { fullscreen = true }, rounding = 0 })

-- --- JOGOS (Steam) ---
hl.window_rule({
    match = { class = "^(steam_app_.*)$" },
    -- menos atraso na imagem (tearing, se o hardware permitir)
    immediate = true,
    -- a tela não apaga nem bloqueia durante o jogo
    idle_inhibit = "always",
    -- deixa o jogo escolher qualquer tamanho de janela
    min_size = "1 1",
    -- sem efeitos: blur, transparência, borda e cantos arredondados
    no_blur = true,
    opaque = true,
    border_size = 0,
    rounding = 0,
})

-- --- XWAYLAND ---
-- Janelas-fantasma de apps X11 (sem classe nem título) não roubam o foco
hl.window_rule({
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
-- Vivaldi: fixa o estado de tela cheia (interno 3 = maximizado + tela cheia;
-- o que o app recebe: 2 = tela cheia)
hl.window_rule({ match = { class = "^(vivaldi-stable)$" }, fullscreen_state = "3 2" })

-- --- POP-UP DO WI-FI (nmtui aberto pelo waybar) ---
hl.window_rule({
    match = { class = "^(kitty-nmtui)$" },
    float = true,
    size = "600 400",
    center = true,
})
