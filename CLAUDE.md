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

## Pendências conhecidas (análise de 2026-09-25)
Detalhes em `~/.claude/plans/voc-lida-bem-com-zippy-russell.md`.
- **Clipboard (SUPER+V)**: o `base/rofi/clipboard/style-1.rasi` usa imagem de fundo `paper.png` (não existe), texto preto e a fonte "Grape Nuts" (não instalada). Precisa ser refeito com a paleta.
- **Waybar `style.css`**: usa `@purple`, `@red`, `@bg0`, `@blue` e `@black_absoluto`, que não estão definidas na paleta.
- **Rofi**: `foreground`, `background-alt` e `selected` não estão definidos em `palette/rofi.rasi`.
- **Waybar inicia duas vezes**: `execs.conf` roda `waybar` e também `launch.sh`.
- **SUPER+D**: `$menu || pkill rofi` deveria ser `pkill rofi || $menu`.
- **`qt6ct.conf`**: tem o caminho fixo `/home/felipe/...`.
- **Valores fixos de uma máquina**:
  - `monitor=` no `settings.conf` (o `monitors.conf` existe, será usado no futuro, mas ainda não é carregado);
  - no Waybar, `intel_backlight`, `wlp2s0` e `HDMI-A-1`.
- **battery-notify.sh**: no desktop, que não tem `BAT0`, gera erro a cada 150 s.
