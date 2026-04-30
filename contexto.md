## Contexto do projeto: dotfiles

**Usuário:** Felipe Ferreira — Graduando em Engenharia de Software.

**Ambiente:**
- OS: Fedora 43 com Hyprland (minimalista) sobre KDE Plasma 6
- Desktop AMD (hostname: Frieren) e Notebook NVIDIA (hostname: FERN)

**Arquitetura dos dotfiles:**
- Repositório em `~/dotfiles` — Single Source of Truth via symlinks (`ln -sfn`)
- `install.sh`: script idempotente que separa lógica de hardware (perfis AMD/NVIDIA) e temas (ex: Gruvbox), com menus interativos na primeira execução
- `~/dotfiles/themes/current_theme`: symlink dinâmico que aponta para o pool de wallpapers do tema ativo; a estrutura de temas é extensível sem alterar o core do script

**Problemas já resolvidos:**
1. Links circulares no Kitty ("Too many levels of symbolic links") — causado por symlinks apontando para si mesmos; corrigido recriando os links com caminho absoluto
2. "Modified content" em submodules do Git — causado por pasta `.git` residual de temas baixados (Rofi); corrigido removendo o `.git` interno antes do commit
