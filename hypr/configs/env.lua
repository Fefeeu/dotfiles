-- Variáveis de ambiente iguais para todas as máquinas
-- (as da GPU ficam em hypr/maquinas/<Nome>/hardware.lua)

-- Avisa aos apps que a sessão é Wayland
hl.env("XDG_SESSION_TYPE", "wayland")

-- Apps Qt (Dolphin etc.) usam a aparência do qt6ct, que aplica as cores do tema
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
