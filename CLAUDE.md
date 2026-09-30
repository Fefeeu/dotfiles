# CLAUDE.md

Contexto para o Claude Code trabalhar neste repositório. Responda em português.

## Ambiente
- Fedora 43 com Hyprland 0.51 (minimalista) sobre KDE Plasma 6. Rofi 2.0, Waybar, swaync, swww, kitty, Dolphin.
- Duas máquinas com o mesmo repositório:
  - **Frieren**: desktop AMD, perfil `amd`
  - **FERN**: notebook NVIDIA, perfil `nvidia`, usuário `FERN`, com `intel_backlight` e `wlp2s0`
- O nome de usuário pode ser diferente entre as máquinas. Nunca escreva `/home/<usuário>` fixo; use `$HOME` ou `~`.

## Arquitetura
- `~/dotfiles` é a fonte da verdade. Os links são criados com `ln -sfn` e caminhos absolutos. Se já existe uma config real no destino, ela vira `.bak`.
- Modelo **base + override**:
  - `base/` tem o layout padrão (`waybar`, `rofi`, `kitty/kitty.conf`);
  - `themes/<tema>/` tem `hypr.conf`, `palette/`, `imagens/wallpapers/wall.png` e `imagens/thumb.png` (miniatura do seletor); outras imagens, como `me.png`, ficam soltas em `imagens/`;
  - o tema pode trazer a própria pasta de um componente, que substitui a da base inteira.
  - Contrato completo em `docs/temas.md`.
- Estado da máquina (fora do git):
  - `~/.config/theme` → tema ativo;
  - `~/.config/hypr/hardware_profile.conf` → `hypr/hardware/{amd,nvidia}.conf`.
- O layout acha as cores sempre por `~/.config/theme/palette/...`:
  - waybar: `@import url("../theme/palette/waybar.css")`, relativo a `~/.config/waybar`;
  - rofi: `@import "~/.config/theme/palette/rofi.rasi"`;
  - kitty: `include ~/.config/theme/palette/kitty.conf`.
- Scripts:
  - `scripts/lib.sh`: `STATIC_MAP`, `OVERRIDABLE`, `THEME_ONLY`, `link_com_backup` e `listar_temas`;
  - `install.sh`: pergunta o hardware e o tema, cria os links fixos e chama o switch;
  - `scripts/switch-theme.sh <tema>`: refaz os links do tema e recarrega a sessão;
  - `hypr/scripts/seletor-tema.sh` (SUPER+T): lista de temas no rofi com miniatura e nome, layout em `base/rofi/temas/seletor.rasi`.
- `hypr/hyprland.conf` só faz `source`, nesta ordem: hardware → settings → animations → execs → `~/.config/theme/hypr.conf` → windowrules → binds. Bordas, gaps e cores ficam só no tema.
- Tema ativo: `Black_and_White`. `Teste_Colorido` é um tema neon só para testar os scripts.
  - A paleta usa nomes em português (`preto_absoluto`, `branco_puro`, `cinza_*`) mapeados para nomes semânticos (`fundo`, `texto`, `borda`...).
  - Os temas de rofi vêm do adi1090x/rofi (launcher `type-3/style-1`).
  - `themes/_modelo` é o esqueleto de tema novo (pastas com `_` não aparecem no install).
  - Planejado: um tema com layout próprio inspirado no menu de Persona 3 Reload.

## Convenções
- Comentários e commits em português, curtos (ex.: "adicionando brilho de tela ao waybar").
- Arquivo novo de configuração:
  - igual para todos os temas: entra em `hypr/` ou na raiz, com entrada no `STATIC_MAP`;
  - layout que um tema pode trocar: entra em `base/`, com entrada no `OVERRIDABLE`;
  - só de tema: entra no `THEME_ONLY`.
- O layout base só usa nomes semânticos de cor, nunca cores cruas.
- Scripts referenciam `~/.config/<comp>/...` ou `~/.config/theme/...`, nunca `~/dotfiles/themes/...`.
- Valores específicos de uma máquina (monitor, variáveis de GPU) ficam em `hypr/hardware/*.conf`, não em `settings.conf` nem nos temas.
- Temas baixados de terceiros: remova a pasta `.git` interna antes do commit, porque ela vira submodule ("modified content").
- Pacotes necessários ficam em `docs/pacotes.md` (formato `pacote # motivo`). Ideias futuras ficam em `docs/ideias.md`.
- Depois de editar: `hyprctl reload && hyprctl configerrors` e `~/.config/waybar/scripts/launch.sh`.

## Problemas já resolvidos
- "Too many levels of symbolic links" no kitty: eram links apontando para si mesmos. Foram recriados com caminho absoluto.
- "Modified content" em submodule: era uma pasta `.git` que sobrou de um tema do rofi. Foi removida.
- Reorganização de 2026-09-30:
  - temas incompletos, `nitch/`, `.github/`, `.gitingnore`, `.beckup_rofi` e `current_theme` foram removidos do repositório;
  - `hyprlock.conf` e `battery-notify.sh` foram trazidos para o repositório;
  - o README foi reescrito.

## Roteiro de mudanças (levantamento de 2026-09-30)
Como trabalhar neste roteiro:
- Uma mudança por vez, na ordem.
- Antes de cada uma, explicar ao usuário o que muda, por quê e em quais arquivos, e **esperar aprovação**.
- Depois de aplicar: verificar, fazer commit curto em português e marcar `[x]` aqui.
- Não juntar itens sem pedido.

1. [ ] **Fontes**:
   - padronizar JetBrainsMono Nerd Font em waybar, hyprlock e rofi, e JetBrains Mono no kitty;
   - hoje nenhuma JetBrains/Iosevka está instalada, então tudo usa fonte substituta;
   - arquivos: `base/kitty/kitty.conf`, `base/waybar/style.css`, `hypr/hyprlock.conf`, `base/rofi/**/*.rasi`;
   - instalar as fontes fica com o usuário.
2. [ ] **Waybar inicia duas vezes**: tirar `exec-once = waybar` e deixar só o `launch.sh`. No `launch.sh`, trocar `killall -9` por `pkill -x`.
   - arquivos: `hypr/configs/execs.conf`, `base/waybar/scripts/launch.sh`.
3. [ ] **SUPER+D não fecha o rofi**: `$menu || pkill rofi` → `pkill rofi || $menu`.
   - arquivo: `hypr/rules/binds.conf`.
4. [ ] **Chaves duplicadas**: `on-scroll-up/down` aparecem duas vezes em `clock.actions`.
   - arquivo: `base/waybar/config.jsonc`.
5. [ ] **battery-notify.sh**: sair se `BAT0` não existir (no desktop dá erro a cada 150 s).
   - arquivo: `hypr/scripts/battery-notify.sh`.
6. [ ] **Seletor de temas**: `pkill -x rofi` fecha qualquer rofi; deve fechar só o seletor.
   - arquivo: `hypr/scripts/seletor-tema.sh`.
7. [ ] **Cores indefinidas no waybar**:
   - `@purple`, `@red`, `@bg0`, `@blue` e `@black_absoluto` viram nomes semânticos novos (`destaque`, `alerta`);
   - arquivos: `base/waybar/style.css`, `palette/waybar.css` dos temas, `_modelo`, `docs/temas.md`.
8. [ ] **Rofi Black_and_White**: definir `foreground`, `background-alt` e `selected`.
   - arquivo: `themes/Black_and_White/palette/rofi.rasi`.
9. [ ] **Links velhos ao trocar de tema**:
   - se o tema não tem `kvantum/`, `qt6ct.conf`, `kde.colors` ou `swaync`, remover o link que ainda aponta para `themes/`;
   - limpar o link quebrado `black_and_white.colors`;
   - arquivos: `scripts/switch-theme.sh`, `scripts/lib.sh`.
10. [ ] **qt6ct**: `color_scheme_path` tem `/home/felipe` e o nome antigo do tema. Gerar o caminho com `$HOME` a partir de um template.
    - arquivos: `themes/*/qt6ct.conf`, `scripts/switch-theme.sh`.
11. [ ] **Portabilidade**:
    - `monitor=` sai do `settings.conf` e vai para o `monitors.conf`, carregado pelo `hyprland.conf`;
    - tirar `device: intel_backlight`, `interface: wlp2s0` e `HDMI-A-1` do waybar;
    - avaliar o bloco `device { compx-kysona-m600 }`.
12. [ ] **Estrutura do rofi**:
    - `config.rasi` enxuto para rofi 2.0 (sem `wmctrl`, terminal kitty);
    - um só `shared/` (cores + fontes + ícone Papirus) para launcher, clipboard e seletor.
13. [ ] **Clipboard SUPER+V**:
    - refazer `style-1.rasi` com a paleta;
    - apagar `launcher.sh`, `style_teste.rasi` e `AINDA NÃO FUNCIONA`.
14. [ ] **windowrules**: unificar tudo em `windowrulev2`.
15. [ ] **Ambiente**: `env = QT_QPA_PLATFORMTHEME` sai do `hyprland.conf` e vai para `hypr/configs/env.conf`.
16. [ ] **`scripts/check.sh`**: `bash -n` nos scripts, `hyprctl configerrors` e validação do contrato de cada tema.
17. [ ] **Teste_Colorido**: decidir se entra no git.

Fora do roteiro por enquanto:
- `docs/pacotes.md` será reestruturado no futuro. Faltam nele `cliphist`, `libnotify`, `psmisc`, `nim`, `ImageMagick` e as fontes.
- Resíduos locais fora do repositório: `~/.config/hypr/{colors.conf,battery-notify.sh,*.bak}`.
