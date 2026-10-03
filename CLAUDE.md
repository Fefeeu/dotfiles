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
  - `scripts/check.sh`: confere scripts, temas, máquinas, links, rofi e Hyprland;
  - `hypr/scripts/seletor-tema.sh` (SUPER+T): lista de temas no rofi com miniatura e nome, layout em `base/rofi/temas/seletor.rasi`.
- Rofi: `base/rofi/config.rasi` (geral), `shared/` (cores e fonte, importados por todo layout), `launchers/type-3/`, `clipboard/`, `temas/` (seletor e pergunta).
- `hypr/hyprland.conf` só faz `source`, nesta ordem: env → máquina (hardware, monitors) → settings → animations → execs → `~/.config/theme/hypr.conf` → windowrules → binds. Bordas, gaps e cores ficam só no tema.
- Tema ativo: `Black_and_White`. `Tema_Teste` é um tema neon só para testar os scripts.
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
- Valores específicos de uma máquina (monitor, variáveis de GPU, teclados, mouse) ficam em `hypr/maquinas/<Nome>/`, não em `settings.conf` nem nos temas. Variáveis de ambiente comuns ficam em `hypr/configs/env.conf`.
- Temas baixados de terceiros: remova a pasta `.git` interna antes do commit, porque ela vira submodule ("modified content").
- Pacotes necessários ficam em `docs/pacotes-dotfiles.md` (seções `[todas]`/`[FERN]`/`[Frieren]`/`[extras]`, `repo:`, `nerdfont:` e `pacote # motivo`; feito para um instalador ler). Programa novo usado pelo dotfiles entra lá. Apps de uso pessoal (Steam, Discord...) ficam em `docs/apps.md`, ainda só com a explicação. Ideias futuras ficam em `docs/ideias.md`; decisões de visual em aberto, em `docs/design.md`.
- Depois de editar: `scripts/check.sh` (inclui `hyprctl reload` + `configerrors`) e `~/.config/waybar/scripts/launch.sh`.

## Pendências na Frieren
Coisas para rodar no desktop quando voltar a ele (apagar cada uma depois de feita):
- `git pull` e logo em seguida `./install.sh` (ou `scripts/switch-theme.sh <tema>`): o `hyprland.conf` agora lê `~/.config/hypr/maquina/`, que só existe depois disso. Na pergunta, escolher `Frieren` e aceitar trocar o hostname.
- `hypr/maquinas/Frieren/monitors.conf` está com a resolução de teste `980x720@72` (usada para testar a troca de máquina no notebook): trocar pela resolução real do monitor (era `1920x1080@72`).
- Conferir depois: `scripts/check.sh` (tudo ✓), monitor a 72 Hz e teclado compx-kysona-m600 em `us`.
- Conferir no waybar: módulo de brilho some (desktop não tem backlight) e rede mostra a interface ativa (cabo).
- Conferir se o tema de ícones Papirus está instalado (`ls /usr/share/icons | grep Papirus`), agora usado pelo launcher.
- Instalar a JetBrainsMono Nerd Font em `~/.local/share/fonts/JetBrainsMonoNerd` (nerd-fonts do GitHub), como no notebook.
- Pastas do usuário em inglês, como no notebook (feito na FERN em 2026-10-01). Com os apps fechados:
  - `mv` de `Área de trabalho`→`Desktop`, `Documentos`→`Documents`, `Imagens`→`Pictures`, `Modelos`→`Templates`, `Músicas`→`Music`, `Público`→`Public`, `Vídeos`→`Videos` (se já existir `~/Pictures`, juntar o conteúdo antes);
  - trocar os caminhos em `~/.config/user-dirs.dirs` e conferir com `xdg-user-dir PICTURES`;
  - procurar os caminhos antigos com `grep -rIl /home/$USER/Imagens ~/.config ~/.local/share` (e os outros nomes, também na forma de URL, ex.: `V%C3%ADdeos`) e trocar nas configs, sem mexer em logs e listas de recentes.

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
   - se o tema não tem `qt6ct.conf`, `kde.colors` ou `swaync`, remover o link que ainda aponta para `themes/`;
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
15. [x] **Ambiente**: `hypr/configs/env.conf` com as variáveis comuns (`QT_QPA_PLATFORMTHEME`, saído do `hyprland.conf`, e `XDG_SESSION_TYPE`, antes repetido nos `hardware.conf`).
16. [x] **`scripts/check.sh`**: confere sem alterar nada — `bash -n` e permissão dos scripts (shellcheck se instalado), contrato dos temas (arquivos e nomes de cor), pastas de máquina e link, links do `STATIC_MAP`/`OVERRIDABLE`, `.rasi` de layout (`rofi -dump-theme`) e `hyprctl reload` + `configerrors`. Sai com 1 se houver problema. O `config.jsonc` do waybar fica de fora (comentários).
17. [x] **Teste_Colorido** (hoje `Tema_Teste`): entrou no git como tema de teste dos scripts.

Fora do roteiro por enquanto:
- Resíduos locais fora do repositório: `~/.config/hypr/{colors.conf,battery-notify.sh,*.bak}`.
- Planejado (ainda não fazer): passar o sistema todo para nomes em inglês (pastas, arquivos, funções, variáveis e cores).

## Roteiro da revisão de 2026-10-01
Aprovado pelo usuário item a item; um commit por item.
1. [x] **Kvantum**: removido de vez (pasta do tema, `THEME_ONLY`, pacote e docs).
2. [x] **`docs/design.md`**: decisões de design para ir atrás e temas de ícones escuros recomendados.
3. [x] **Launcher com nomes de cor**: `base/rofi/launchers/type-3/style-1.rasi` sem cores cruas.
4. [x] **battery-notify.sh**: acha a bateria sozinho (`BAT0`, `BAT1`...), em vez de `BAT0` fixo.
5. [x] **Tela cheia**: F11 em `hypr/rules/binds.conf`.
6. [x] **Mouse por máquina**: `sensitivity` e `accel_profile` saem do `settings.conf` para `hypr/maquinas/*/hardware.conf`.
7. [x] **Tearing**: `allow_tearing` nas duas máquinas (a regra `immediate` dos jogos vale nas duas).
8. [x] **Comentários**: blocos de `battery-notify.sh` e `launcher.sh`.
9. [x] **Docs**: passo da máquina em `docs/temas.md`, `hostname` no `pacotes-dotfiles.md`, `themes/current_theme` sai do `.gitignore`.
10. [x] **Tema_Teste**: `Teste_Colorido` renomeado (continua como tema de testes, visível no seletor).
11. [x] **Ideias**: hypridle e tema de cursor em `docs/ideias.md`.
12. [x] **Launcher 90% opaco**: nome de cor novo `background-window` (hex com transparência) nas paletas do rofi.
13. [x] **Tema_Teste**: `Temas_Teste` volta para o singular.

Em aberto (explicados, sem decisão ainda):
- battery-notify repete o aviso a cada 150 s abaixo de 20% (poderia avisar uma vez por faixa);
- Frieren: `GBM_BACKEND,drm` sem efeito útil no AMD (apagar a linha);
- `link_com_backup` sobrescreve um `.bak` antigo (numerar os backups);
- `swaync` está no `OVERRIDABLE`, mas nenhum tema nem a base tem a pasta;
- contrato do waybar exige `fundo_modulo`, `fundo_hover` e `texto_mudo`, que o `style.css` não usa; `#tray` sem estilo; resto de `format-icons` e `background-size`;
- binds de mídia (`playerctl`), mute com `bindl`, logo/wallpaper padrão do Hyprland antes do swww;
- `check.sh` não confere o link do qt6ct;
- qt6ct usa `Papirus-Light` (ícones escuros) num tema escuro: escolher pelo `docs/design.md`;
- calendário do waybar com cores fixas: mantido assim por enquanto.

## Migração para LUA
Próxima etapa, depois de terminar o roteiro de mudanças acima (as versões novas do Hyprland usam configuração em Lua). Mesmo jeito de trabalhar: um item por vez, com aprovação antes.
- [ ] Atualizar Hyprland (plano anotado em 2026-10-03, ainda não aplicado):
  - o COPR `solopasha/hyprland` foi abandonado e parou na 0.51.1; o fork `sdegler/hyprland` tem a 0.56.2 para Fedora 43 (Lua desde a 0.55);
  - sem `hyprland.lua`, a versão nova continua lendo o `hyprland.conf` (não precisa de dois Hyprland lado a lado);
  - passos (sudo, o usuário roda com `!`):
    - `sudo dnf copr disable solopasha/hyprland && sudo dnf copr enable sdegler/hyprland`;
    - `sudo dnf upgrade --refresh 'hypr*' aquamarine xdg-desktop-portal-hyprland uwsm`;
    - sair e entrar de novo na sessão;
    - `scripts/check.sh`: corrigir o que o `configerrors` apontar no `.conf` (commit separado);
  - voltar atrás: Plasma na tela de login, reativar o COPR antigo e `sudo dnf downgrade` dos pacotes;
  - depois: mesma troca de COPR nas pendências da Frieren.
- [ ] Atualizar `docs/pacotes-dotfiles.md` para a versão nova do Hyprland (nomes de pacotes, repositórios e dependências que mudarem)
- [ ] Criar o script de instalação de todos os pacotes de `docs/pacotes-dotfiles.md` (seções, `repo:`, `nerdfont:` e pacotes)
- [ ] Criação do script do `docs/apps.md`: definir o formato, preencher a lista de apps pessoais (Steam, Discord, VS Code...) e criar o script que instala tudo
- [ ] Estudar e personalizar mais o hyprlock: cores do tema (hoje são fixas), `me.png` opcional e cartão de bateria que funcione no desktop
