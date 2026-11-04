# CLAUDE.md

Contexto para o Claude Code trabalhar neste repositório. Responda em português.

## Ambiente
- Fedora 43 com Hyprland 0.56 (minimalista) sobre KDE Plasma 6. Rofi 2.0, Waybar, swaync, swww, kitty, Dolphin.
  - **Hyprland travado na 0.56** (`dnf versionlock`, junto com hyprlock e as bibliotecas): a 0.57 não lê mais o `.conf`, só Lua, e a 0.56 lê os dois. Não atualizar até a config inteira estar em Lua; sem o `versionlock`, um `dnf upgrade` comum (ou o Discover) já leva para a 0.57.
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
  - `install.sh`: orquestrador, só chama os passos de `scripts/install/` com `bash` (nunca `source`), para que nada feche o terminal; sem `set -e`;
  - `scripts/install/install-pacotes.sh` (primeiro passo): lê o `docs/pacotes-dotfiles.md` (`[todas]`, a seção da máquina e, se o usuário quiser, `[extras]`), ativa os `repo:` (COPR, RPM Fusion), trava com o `versionlock` os `pacote = versão` e instala numa transação do dnf só o que ainda não está instalado (nunca atualiza: misturar versões do Hyprland quebra); no fim, lista o que nenhum repositório tem; `--lista` só mostra, sem sudo;
  - `scripts/install/install-fonts.sh` e `install-icons.sh`: Nerd Fonts e temas de ícones do GitHub para `~/.local/share/{fonts,icons}`, sem sudo; a lista fica dentro de cada script e o que já existe é pulado;
  - `scripts/install/instalador-inicial.sh`: confere a máquina, pergunta o tema, cria os links fixos e chama o switch;
  - `scripts/switch-theme.sh <tema>`: confere o link da máquina, refaz os links do tema e recarrega a sessão;
  - máquina sem pasta com o nome do hostname: pergunta qual usar e oferece trocar o hostname para o nome da pasta (terminal com `select`/`read`; fora dele, rofi). O Hyprland repassa o TTY do login aos programas, por isso o teste de terminal é `-t 0 && -t 2` e o seletor chama o switch com `< /dev/null`;
  - `scripts/check.sh`: confere scripts, temas, máquinas, links, rofi e Hyprland;
  - `hypr/scripts/seletor-tema.sh` (SUPER+T): lista de temas no rofi com miniatura e nome, layout em `base/rofi/temas/seletor.rasi`.
- Modo estudo (SUPER+B, `estudar`/`Estudar` no terminal, `estudar 45m`):
  - parte de sistema em `sistema/modo-estudo/` (serviço root `modo-estudo@<minutos|retomar|parar>.service`, listas `apps` e `sites`, regra do polkit que só libera o *start*); instalada como **cópia** por `sudo scripts/instalar-modo-estudo.sh` (rodar de novo depois de mudar algo; o `check.sh` avisa se a cópia está diferente);
  - mata os processos da lista a cada segundo, bloqueia os sites no `/etc/hosts` e na `URLBlocklist` dos navegadores Chromium; parar no meio só com `sudo systemctl stop`;
  - estado: `/var/lib/modo-estudo/restante` (sobrevive ao reinício) e `/run/modo-estudo/restante` (contagem ao vivo); desligar o PC pausa e o login pergunta se continua (desistir pede uma frase);
  - parte do usuário: `hypr/scripts/modo-estudo.sh` (menu, pergunta do login, módulo `custom/estudo` do waybar) e `bashrc.d/modo-estudo.sh` (link em `~/.bashrc.d/`).
- `.luarc.json` (raiz): autocompletar e checagem dos `.lua` do Hyprland no editor (extensão "Lua" do sumneko no VS Code). Lê a descrição da API em `/usr/share/hypr/stubs/hl.meta.lua` (no VS Code em flatpak o caminho é `/run/host/usr/share/hypr/stubs`, por isso os dois); `runtime.path` com `hypr/?.lua` para o `require("configs.env")` achar os arquivos; Lua 5.4, a mesma do Hyprland.
- Rofi: `base/rofi/config.rasi` (geral), `shared/` (cores e fonte, importados por todo layout), `launchers/type-3/`, `clipboard/`, `temas/` (seletor e pergunta).
- `hypr/hyprland.conf` só faz `source`, nesta ordem: env → máquina (hardware, monitors) → settings → animations → execs → `~/.config/theme/hypr.conf` → windowrules → binds. Bordas, gaps e cores ficam só no tema.
- Tema ativo: `Black_and_White`. `Tema_Teste` é um tema neon só para testar os scripts. `Catppuccin` (Mocha, destaque rosa-mauve `#e0b4ef`, entre mauve e pink) é o tema temporário para a Frieren, até sair o tema de jogos/anime dela.
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
- Pacotes necessários ficam em `docs/pacotes-dotfiles.md` (seções `[todas]`/`[FERN]`/`[Frieren]`/`[extras]`, `repo:` e `pacote # motivo`; lido pelo `install-pacotes.sh`). Programa novo usado pelo dotfiles entra lá; Nerd Font ou tema de ícones novo entra na lista do `install-fonts.sh`/`install-icons.sh`. Apps de uso pessoal (Steam, Discord...) ficam em `docs/apps.md`, ainda só com a explicação. Ideias futuras ficam em `docs/ideias.md`; decisões de visual em aberto, em `docs/design.md`.
- Depois de editar: `scripts/check.sh` (inclui `hyprctl reload` + `configerrors`) e `~/.config/waybar/scripts/launch.sh`.

## Pendências na Frieren
Coisas para rodar no desktop quando voltar a ele (apagar cada uma depois de feita):
- Hyprland 0.56 (antes de qualquer `dnf upgrade`, que levaria para a 0.57, sem `.conf`): `sudo dnf copr disable solopasha/hyprland`, `git pull` e `scripts/install/install-pacotes.sh` (ativa o `nett00n/hyprland`, trava e instala as versões fixas da lista); sair e entrar na sessão e conferir com `scripts/check.sh` e `dnf versionlock list`.
- Modo estudo: `sudo ~/dotfiles/scripts/instalar-modo-estudo.sh` (depois do `./install.sh`, que cria o link do `~/.bashrc.d/`).
- Conferir no waybar: módulo de brilho some (desktop não tem backlight) e rede mostra a interface ativa (cabo).
- Pastas do usuário em inglês, como no notebook (feito na FERN em 2026-10-01). Com os apps fechados:
  - `mv` de `Área de trabalho`→`Desktop`, `Documentos`→`Documents`, `Imagens`→`Pictures`, `Modelos`→`Templates`, `Músicas`→`Music`, `Público`→`Public`, `Vídeos`→`Videos` (se já existir `~/Pictures`, juntar o conteúdo antes);
  - trocar os caminhos em `~/.config/user-dirs.dirs` e conferir com `xdg-user-dir PICTURES`;
  - procurar os caminhos antigos com `grep -rIl /home/$USER/Imagens ~/.config ~/.local/share` (e os outros nomes, também na forma de URL, ex.: `V%C3%ADdeos`) e trocar nas configs, sem mexer em logs e listas de recentes.

## Problemas já resolvidos
- "Too many levels of symbolic links" no kitty: eram links apontando para si mesmos. Foram recriados com caminho absoluto.
- "Modified content" em submodule: era uma pasta `.git` que sobrou de um tema do rofi. Foi removida.
- Terminal fechando no fim do install (2026-10-08): era o `source install.sh`, que deixava o `set -euo pipefail` do `lib.sh` valendo no shell do terminal. O `install.sh` virou orquestrador (chama os passos de `scripts/install/` com `bash`) e os scripts com `lib.sh` se executam de novo com `bash` quando chamados com `source`.
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

## Modo estudo (2026-10-05)
- [x] Serviço root com bloqueio de apps (Steam, Discord) e sites (YouTube, Instagram), instalador e regra do polkit.
- [x] SUPER+B, `estudar`/`Estudar` no terminal (tempos 30m, 60m, 1h30, 2h ou digitado), pergunta no login e timer no waybar à direita das áreas de trabalho.

## Migração para LUA
Próxima etapa, depois de terminar o roteiro de mudanças acima (as versões novas do Hyprland usam configuração em Lua). Mesmo jeito de trabalhar: um item por vez, com aprovação antes.
- [x] Atualizar Hyprland (2026-11-04, FERN): 0.56.2 pelo COPR `nett00n/hyprland` (o `solopasha/hyprland` foi abandonado na 0.51.1):
  - sem `hyprland.lua`, a versão nova continua lendo o `hyprland.conf`;
  - erros corrigidos no `.conf`: `windowrule` com `match:<campo>` e efeito com valor (`no_blur on`, `border_size 0`...), `togglesplit` virou `layoutmsg, togglesplit`, `dwindle:pseudotile` saiu;
  - voltar atrás: Plasma na tela de login, reativar o COPR antigo e `sudo dnf downgrade` dos pacotes.
- [x] Criar o script de instalação de todos os pacotes de `docs/pacotes-dotfiles.md` (seções, `repo:` e pacotes), como um passo novo chamado pelo `install.sh`: `scripts/install/install-pacotes.sh`
- [ ] Reescrever a config em Lua (os `.lua` ficam ao lado dos `.conf`, com os mesmos nomes e pastas; cada parte testada com `Hyprland --verify-config -c <arquivo>.lua`, sem mexer na sessão até a virada):
  - [x] esqueleto: `hypr/hyprland.lua` com `require` na mesma ordem do `hyprland.conf` (env → máquina → settings → animations → execs → tema → windowrules → binds), cada linha comentada até o passo dela; o Hyprland procura os `require` na pasta real do arquivo (`~/dotfiles/hypr`, mesmo pelo link), então máquina e tema (em `~/.config`) entram pelo `carregar()` (`dofile` com `$HOME`); o `check.sh` roda `Hyprland --verify-config -c hypr/hyprland.lua`;
  - [x] configs: `hypr/configs/{env,settings,animations,execs}.lua`; o `settings.lua` devolve os programas (`terminal`, `fileManager`, `menu`, antes `$terminal`...) para o `binds.lua` pegar com `require`; os `exec-once` viraram `hl.exec_cmd` dentro de `hl.on("hyprland.start", ...)`; o `--verify-config` pega opção inventada, tipo errado e curva inexistente, com arquivo e linha;
  - [x] regras e binds: `hypr/rules/{windowrules,binds}.lua`; o `--verify-config` confere campos e `match` das regras, mas **não** os argumentos dos dispatchers (`hl.dsp.window.fullscreen({ inventado = 0 })` passa): os nomes vieram das mensagens de erro do próprio Hyprland, e na virada é preciso testar na mão F11, SUPER+F, SUPER(+SHIFT)+setas, SUPER(+SHIFT)+números, SUPER+J e o mouse;
  - [x] máquinas: `hypr/maquinas/*/{hardware,monitors}.lua` (carregados pelo link `~/.config/hypr/maquina`; a Frieren foi conferida com uma cópia do `hyprland.lua` apontando para a pasta dela); o `check.sh` exige os `.conf` e os `.lua` em cada máquina;
  - [ ] temas: `hypr.lua` nos temas e no `_modelo`, e o contrato no `switch-theme.sh`, `check.sh` e `docs/temas.md`;
  - [ ] virada: link `~/.config/hypr/hyprland.lua` no `STATIC_MAP`, testado na sessão real (se existir `hyprland.lua`, o Hyprland usa só ele: a troca é de uma vez; para voltar, apagar o link).
- [ ] Destravar e atualizar para a 0.57+ (último passo, com a config inteira em Lua): apagar as versões fixas do `docs/pacotes-dotfiles.md`, `sudo dnf versionlock delete hyprland xdg-desktop-portal-hyprland hyprlock hyprgraphics aquamarine hyprtoolkit hyprutils hyprlang hyprwire`, `sudo dnf upgrade` e conferir se o hyprlock novo ainda lê o `hyprlock.conf`

Depois da migração para Lua (ficam para quando a config inteira estiver em Lua):
- [ ] Atualizar `docs/pacotes-dotfiles.md` para a versão nova do Hyprland (nomes de pacotes, repositórios e dependências que mudarem):
  - [x] `repo:` trocado para `copr nett00n/hyprland`;
  - [ ] `swww` e `grimblast` não existem no COPR novo nem no Fedora (na FERN sobraram do COPR antigo): procurar outro COPR ou trocar de programa;
  - [ ] `uwsm` veio com o upgrade: conferir se é dependência do `hyprland` ou se pode sair.
- [ ] Criação do script do `docs/apps.md`: definir o formato, preencher a lista de apps pessoais (Steam, Discord, VS Code...) e criar o script que instala tudo
- [ ] Aplicativos padrão: `mimeapps.list` no dotfiles, igual em todos os computadores (detalhes em `docs/ideias.md`; decidir entre link no `STATIC_MAP` ou cópia, porque o KDE reescreve o arquivo)
- [ ] Estudar e personalizar mais o hyprlock: cores do tema (hoje são fixas), `me.png` opcional e cartão de bateria que funcione no desktop

## Migração de distro (depois da migração para Lua)
Trocar o Fedora por uma distro que acompanhe melhor o Hyprland novo. Até começar esta etapa, o resto do roteiro segue feito para o Fedora, como se a troca não existisse. Mesmo jeito de trabalhar: um item por vez, com aprovação antes.
- [ ] Estudar CachyOS e Arch: o que muda na instalação, NVIDIA no notebook (FERN), jogos no desktop (Frieren), KDE Plasma junto do Hyprland, de onde vêm os pacotes do dotfiles (repositório oficial ou AUR) e quanto trabalho dá manter

## Tema Persona com shell próprio (depois da migração para Lua)
Análise de 2026-10-21, ainda sem nada feito. Mesmo jeito de trabalhar: um item por vez, com aprovação antes.

Objetivo: uma tela inicial que funciona como menu de jogo (um workspace só para ela, de onde os apps abrem em outro workspace), com wallpaper animado. O Persona é o exemplo e o ponto de partida, não o fim. É o mesmo "tema com layout próprio inspirado no menu de Persona 3 Reload" citado em Ambiente.

Referências:
- Base: [Persona-Quickshell](https://github.com/Yujonpradhananga/Persona-Quickshell-) (QML/Quickshell, MIT segundo o README, sem arquivo LICENSE; já usa o bind em Lua `hl.bind(...)`). Post: [Hyprland PersonaShell v2](https://www.reddit.com/r/unixporn/comments/1u86dr2/hyprland_personashell_v2/) (o Reddit bloqueia acesso automático; o que importa está no GitHub).
- Inspiração visual (KDE, plasmoides em QML): [KDE with all the bells and whistles](https://www.reddit.com/r/unixporn/comments/1vkil9o/kde_with_all_the_bells_and_whistles/), com cartões inclinados em escada (título, subtítulo e ícone: FILES, TERMINAL, SETTINGS, STEAM, KRITA, ZEN), relógio com data, logo, dock lateral e wallpaper animado. É o visual do menu de apps que queremos.
- O que o projeto traz: wallpaper com vídeo e shaders (`Widgets/WallpaperEngine.qml`), busca de apps por IPC (`Layers/Searchapp.qml`, `qs ipc call searchapp toggle`), menu (`Layers/AppDrawer.qml`), relógio, calendário, cápsula, OSD de volume e brilho, informações de rede, Bluetooth, bateria e mídia.

Decidido:
- Os temas atuais não mudam; o Persona entra só trocando no SUPER+T.
- O rofi não faz esse visual (só retângulos, sem escada); a ferramenta é o Quickshell.
- Assets: usar os do Persona por padrão (mais fácil que fazer arte do zero). Ficam fora do git (65 MB, arte da Atlus): baixados do repositório original na instalação para `themes/Persona/quickshell/Assets/`, que entra no `.gitignore`, para o QML continuar achando por `../Assets/`. Mais tarde podem virar vídeos, GIFs e imagens próprios.
- Tela inicial em uma tela só (sem uma por monitor).
- Temas com menu inicial são para o desktop Frieren, não para o notebook FERN; consumo de bateria não é problema.
- O seletor mostra todos os temas nas duas máquinas; nenhum tema fica limitado por máquina (até o usuário pedir o contrário).

Como encaixar:
- Tema com pasta `quickshell/` assume a área de trabalho: `quickshell` no `THEME_ONLY`, link `~/.config/quickshell`. O contrato normal continua (`hypr`, `palette`, `wall.png` para o hyprlock, `thumb.png` para o seletor).
- `hypr/scripts/sessao.sh` (fixo): com `~/.config/theme/quickshell`, fecha waybar e swww e abre `qs -p ~/.config/theme/quickshell`; sem ela, fecha o `qs`, garante `swww-daemon` + wallpaper e abre o waybar. Chamado no `exec-once` do login e no fim do `switch-theme.sh`, no lugar do que hoje recarrega waybar e swww.
- `hypr/scripts/menu.sh` no SUPER+D: `qs ipc call searchapp toggle` se o tema tiver `quickshell/`, senão o rofi de hoje.
- SUPER+T, SUPER+V, kitty, swaync, hyprlock, qt6ct e KDE seguem iguais, também no Persona.
- Cores: o `Data/Colors.qml` dele (hex fixos do pywal) passa a usar os nomes semânticos da paleta do tema.
- Workspace inicial ("workspace 0", menu de jogo):
  - workspace com nome (`name:inicio`), com bind para ir até ele e a sessão começando nele;
  - nada fica nele: o QML escuta `openwindow` e `movewindowv2` (`Hyprland.rawEvent`) e manda a janela para `movetoworkspace empty`, sem `silent`, para acompanhar a janela; só existe com o tema ativo;
  - o menu abre os apps com `hyprctl dispatch exec "[workspace empty] <app>"`, para a janela não piscar no início;
  - o menu fica na camada de fundo e só aparece no `inicio`; pega o teclado só quando está visível (setas + Enter).

Passos:
- [ ] Testar o Persona-Quickshell como veio, fora do dotfiles, na Frieren (sem o plugin do cava): funciona no AMD? quanto pesa na GPU? (na FERN serve só para ver funcionando)
- [ ] `sessao.sh` + `execs` + `switch-theme.sh`, ainda sem tema novo (os temas atuais têm de continuar iguais)
- [ ] `menu.sh` e o bind do SUPER+D
- [ ] `themes/Persona/` com o QML dele (sem `.git`, com créditos), paleta e `Colors.qml` ligado à paleta
- [ ] Passo de instalação dos assets (chamado pelo `install.sh`) + `.gitignore`
- [ ] Menu de apps em cartões inclinados em escada, como na inspiração do KDE (o `AppDrawer.qml` dele só tem Calendar, Stats, Shaders e Power), com a lista de apps num arquivo de config
- [ ] Workspace inicial: bind, começar nele, vigia no QML e lançamento com `[workspace empty]`
- [ ] Docs (`docs/temas.md`, `docs/pacotes-dotfiles.md`: quickshell por COPR, qt6-qtmultimedia...) e `check.sh` (`qs` instalado e assets baixados quando algum tema tem `quickshell/`)

Decisões em aberto:
- Detectar o tema com shell próprio pela pasta `quickshell/` (recomendado, segue o padrão do override) ou por um arquivo declarado no tema.
- O repositório é público? (reforça manter os assets fora do git)
- `movetoworkspace empty` (primeiro vazio) ou `emptyn` (próximo depois do atual): decidir testando.
- Bind para voltar ao início (ex.: SUPER+Esc).
- Na Frieren, em qual monitor fica o início.
- Plugin do cava: compilar o [Qt6-Cava-plugin](https://github.com/Yujonpradhananga/Qt6-Cava-plugin) ou deixar de fora (começar sem ele).
- Shaders de profundidade e parallax: dependem de máscaras feitas para a arte (`makotodepth.png`, `cloudmask.png`); ao trocar a arte, fazer máscaras próprias ou tirar os shaders. Mudar `.qsb` exige o `qsb` (qt6-shadertools).
- Conferir na versão nova do Hyprland os nomes de eventos e dispatchers, e se a API em Lua tem ganchos de evento (parte do vigia poderia ir para o `hypr.lua` do tema).
- Quais apps entram no menu inicial e onde fica essa lista (arquivo no tema ou na config da máquina).
- O que fica nos workspaces normais nesse tema: só wallpaper, a cápsula dele ou algo como barra.
