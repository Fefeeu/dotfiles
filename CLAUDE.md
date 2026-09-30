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
  - `~/.config/hypr/maquina` → `hypr/maquinas/<Nome>/` (`hardware.conf` + `monitors.conf`), escolhida pelo hostname (Frieren, FERN).
- O layout acha as cores sempre por `~/.config/theme/palette/...`:
  - waybar: `@import url("../theme/palette/waybar.css")`, relativo a `~/.config/waybar`;
  - rofi: `@import "~/.config/theme/palette/rofi.rasi"`;
  - kitty: `include ~/.config/theme/palette/kitty.conf`.
- Scripts:
  - `scripts/lib.sh`: `STATIC_MAP`, `OVERRIDABLE`, `THEME_ONLY`, `link_com_backup`, `listar_temas` e `aplicar_maquina` (detecta ou pergunta a máquina);
  - `install.sh`: confere a máquina, pergunta o tema, cria os links fixos e chama o switch;
  - `scripts/switch-theme.sh <tema>`: confere o link da máquina, refaz os links do tema e recarrega a sessão;
  - máquina sem pasta com o nome do hostname: pergunta qual usar e oferece trocar o hostname para o nome da pasta (terminal com `select`/`read`; fora dele, rofi). O Hyprland repassa o TTY do login aos programas, por isso o teste de terminal é `-t 0 && -t 2` e o seletor chama o switch com `< /dev/null`;
  - `hypr/scripts/seletor-tema.sh` (SUPER+T): lista de temas no rofi com miniatura e nome, layout em `base/rofi/temas/seletor.rasi`.
- Rofi: `base/rofi/config.rasi` (geral), `shared/` (cores e fonte, importados por todo layout), `launchers/type-3/`, `clipboard/`, `temas/` (seletor e pergunta).
- `hypr/hyprland.conf` só faz `source`, nesta ordem: máquina (hardware, monitors) → settings → animations → execs → `~/.config/theme/hypr.conf` → windowrules → binds. Bordas, gaps e cores ficam só no tema.
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
- Valores específicos de uma máquina (monitor, variáveis de GPU, teclados) ficam em `hypr/maquinas/<Nome>/`, não em `settings.conf` nem nos temas.
- Temas baixados de terceiros: remova a pasta `.git` interna antes do commit, porque ela vira submodule ("modified content").
- Pacotes necessários ficam em `docs/pacotes.md` (formato `pacote # motivo`). Ideias futuras ficam em `docs/ideias.md`.
- Depois de editar: `hyprctl reload && hyprctl configerrors` e `~/.config/waybar/scripts/launch.sh`.

## Pendências na Frieren
Coisas para rodar no desktop quando voltar a ele (apagar cada uma depois de feita):
- `git pull` e logo em seguida `./install.sh` (ou `scripts/switch-theme.sh <tema>`): o `hyprland.conf` agora lê `~/.config/hypr/maquina/`, que só existe depois disso. Na pergunta, escolher `Frieren` e aceitar trocar o hostname.
- `hypr/maquinas/Frieren/monitors.conf` está com a resolução de teste `980x720@72` (usada para testar a troca de máquina no notebook): trocar pela resolução real do monitor (era `1920x1080@72`).
- Conferir depois: `hyprctl configerrors`, monitor a 72 Hz e teclado compx-kysona-m600 em `us`.
- Conferir no waybar: módulo de brilho some (desktop não tem backlight) e rede mostra a interface ativa (cabo).
- Conferir se o tema de ícones Papirus está instalado (`ls /usr/share/icons | grep Papirus`), agora usado pelo launcher.
- Instalar a JetBrainsMono Nerd Font em `~/.local/share/fonts/JetBrainsMonoNerd` (nerd-fonts do GitHub), como no notebook.

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

1. [x] **Fontes**:
   - tudo usa JetBrainsMono Nerd Font (rofi, kitty, qt6ct fixed; waybar e hyprlock já usavam);
   - fonte instalada em `~/.local/share/fonts/JetBrainsMonoNerd` (nerd-fonts do GitHub, sem sudo);
   - arquivos: `base/kitty/kitty.conf`, `base/waybar/style.css`, `hypr/hyprlock.conf`, `base/rofi/**/*.rasi`;
   - em outra máquina, instalar a fonte do mesmo jeito.
2. [x] **Waybar inicia duas vezes**: `execs.conf` só roda o `launch.sh`, que usa `pkill -x` e espera o waybar antigo sair antes de abrir outro.
   - arquivos: `hypr/configs/execs.conf`, `base/waybar/scripts/launch.sh`.
3. [x] **SUPER+D não fecha o rofi**: `$menu || pkill rofi` → `pkill rofi || $menu`.
   - arquivo: `hypr/rules/binds.conf`.
4. [x] **Chaves duplicadas**: `on-scroll-up/down` aparecem duas vezes em `clock.actions`.
   - arquivo: `base/waybar/config.jsonc`.
5. [x] **battery-notify.sh**: sair se `BAT0` não existir (no desktop dá erro a cada 150 s).
   - arquivo: `hypr/scripts/battery-notify.sh`.
6. [x] **Seletor de temas**: `pkill -x rofi` fecha qualquer rofi; deve fechar só o seletor.
   - arquivo: `hypr/scripts/seletor-tema.sh`.
7. [x] **Cores indefinidas no waybar**:
   - `@purple`, `@red`, `@bg0`, `@blue` e `@black_absoluto` viram nomes semânticos novos (`destaque`, `alerta`);
   - arquivos: `base/waybar/style.css`, `palette/waybar.css` dos temas, `_modelo`, `docs/temas.md`.
8. [x] **Rofi Black_and_White**: definir `foreground`, `background-alt` e `selected`.
   - arquivo: `themes/Black_and_White/palette/rofi.rasi`.
9. [x] **Links velhos ao trocar de tema**:
   - se o tema não tem `kvantum/`, `qt6ct.conf`, `kde.colors` ou `swaync`, remover o link que ainda aponta para `themes/`;
   - limpar o link quebrado `black_and_white.colors`;
   - arquivos: `scripts/switch-theme.sh`, `scripts/lib.sh`.
10. [x] **qt6ct**: `color_scheme_path` tem `/home/felipe` e o nome antigo do tema. Gerar o caminho com `$HOME` a partir de um template.
    - arquivos: `themes/*/qt6ct.conf`, `scripts/switch-theme.sh`.
11. **Portabilidade** (dividido em dois):
    - [x] **11a** Hyprland por máquina: `hypr/maquinas/{Frieren,FERN}/` com `hardware.conf` (GPU; teclado compx-kysona-m600 só na Frieren) e `monitors.conf` (Frieren 72 Hz, FERN 120 Hz); link escolhido pelo hostname, com pergunta sempre que não houver pasta com o nome;
    - [x] **11b** Waybar: tirados `device: intel_backlight`, `interface: wlp2s0` e `HDMI-A-1` (o waybar escolhe sozinho).
12. [x] **Estrutura do rofi**:
    - `config.rasi` enxuto para rofi 2.0 (sem `wmctrl`, terminal kitty, ícones Papirus, fonte reserva);
    - um só `base/rofi/shared/` (`colors.rasi` + `fonts.rasi`) para launcher e seletor;
    - `temas/pergunta.rasi` (herda do seletor, só texto + `-mesg`) usado nas perguntas de máquina/hostname do `lib.sh`.
13. [x] **Clipboard SUPER+V**:
    - `style-1.rasi` refeito com a paleta e o `shared/`: grade 4x3, imagem em miniatura (cache em `~/.cache/cliphist-miniaturas`, limpo a cada abertura) e texto em até 3 linhas (`-sep $'\x1e' -eh 3`);
    - histórico limitado a 30 itens (`cliphist -max-items 30 store` no `execs.conf`);
    - `clipboard.sh`: mostra só a prévia (o id fica no índice `-format i`), fecha com SUPER+V de novo, Shift+Delete apaga o item (`cliphist delete`, atalho custom-1 = saída 10);
    - apagados `launcher.sh`, `style_teste.rasi`, `AINDA NÃO FUNCIONA` e o bind antigo comentado.
14. [x] **windowrules**: unificado em `windowrule` (no Hyprland 0.51 ele já usa a sintaxe com campos e `windowrulev2` é só alias), uma regra por linha, comentadas.
15. [ ] **Ambiente**: `env = QT_QPA_PLATFORMTHEME` sai do `hyprland.conf` e vai para `hypr/configs/env.conf`.
16. [ ] **`scripts/check.sh`**: `bash -n` nos scripts, `hyprctl configerrors` e validação do contrato de cada tema.
17. [x] **Teste_Colorido**: entrou no git como tema de teste dos scripts.

Fora do roteiro por enquanto:
- `docs/pacotes.md` será reestruturado no futuro. Faltam nele `cliphist`, `libnotify`, `psmisc`, `nim`, `ImageMagick`, `polkit-kde` (agente de senha) e as fontes.
- Resíduos locais fora do repositório: `~/.config/hypr/{colors.conf,battery-notify.sh,*.bak}`.

## Migração para LUA
Próxima etapa, depois de terminar o roteiro de mudanças acima (as versões novas do Hyprland usam configuração em Lua). Mesmo jeito de trabalhar: um item por vez, com aprovação antes.
- [ ] Atualizar Hyprland
