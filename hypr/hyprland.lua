-- Config do Hyprland em Lua (versão nova do hyprland.conf, que ainda vale)
-- Só carrega as partes, nesta ordem (a mesma do hyprland.conf):
-- env → máquina (hardware, monitors) → settings → animations → execs →
-- tema → windowrules → binds
--
-- O Hyprland procura os require na pasta real deste arquivo (~/dotfiles/hypr,
-- mesmo aberto pelo link de ~/.config/hypr), então:
--   require("configs.env")  → hypr/configs/env.lua, do repositório
--   carregar("~/.config/…") → arquivos de fora do repositório (máquina e tema
--                             ativo, que mudam por computador e por tema)

-- carregar(caminho)
-- Roda um arquivo Lua pelo caminho, com "~" trocado pelo $HOME; erro com o
-- caminho completo se ele não existir (link da máquina ou do tema faltando)
local function carregar(caminho)
    local arquivo = caminho:gsub("^~", os.getenv("HOME"))
    local teste = io.open(arquivo, "r")
    if not teste then
        error("arquivo não encontrado: " .. arquivo, 2)
    end
    teste:close()
    dofile(arquivo)
end

-- Variáveis de ambiente comuns a todas as máquinas
require("configs.env")                             -- passo 2

-- Máquina: GPU, teclados e monitores (link criado pelo switch-theme.sh)
carregar("~/.config/hypr/maquina/hardware.lua")     -- passo 4
carregar("~/.config/hypr/maquina/monitors.lua")     -- passo 4

-- Configurações modulares
require("configs.settings")                        -- passo 2
require("configs.animations")                      -- passo 2
require("configs.execs")                           -- passo 2

-- Tema ativo: bordas, gaps e cores
carregar("~/.config/theme/hypr.lua")               -- passo 5

-- Regras e binds
require("rules.windowrules")                       -- passo 3
require("rules.binds")                             -- passo 3
