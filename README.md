# dotfiles

Configuração do meu ambiente **[Hyprland](https://hyprland.org/)** (compositor Wayland), rodando sobre o **KDE Plasma 6** no **Fedora 43**. Uso em duas máquinas: um desktop AMD e um notebook NVIDIA. O repositório funciona como *single source of truth*: todo o sistema é configurado por links simbólicos (`ln -sfn`) que apontam para cá, criados pelo `install.sh`.

## 🖥️ O ambiente
- **Hyprland**: layout `dwindle`, blur e animações em `hypr/configs/`.
- **Waybar** como barra, **Rofi** como launcher e clipboard, **swaync** para notificações e **swww** para o wallpaper.
- **Kitty** como terminal e **Dolphin** como gerenciador de arquivos.
- **Hyprlock** como tela de bloqueio, com aviso de bateria baixa em `hypr/scripts/`.
- **Uma pasta por máquina** em `hypr/maquinas/` (GPU, teclados e monitores): `Frieren` (desktop AMD) e `FERN` (notebook NVIDIA), escolhida pelo hostname.
- **Temas**: cada tema pode mudar só as cores ou substituir componentes inteiros. Veja [docs/temas.md](docs/temas.md).

## ⚙️ Como usar
```bash
git clone https://github.com/Fefeeu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh                         # escolhe o tema e detecta a máquina
scripts/switch-theme.sh <tema>       # troca só o tema depois (ou SUPER+T)
```

O `install.sh` é **idempotente**: pode ser rodado várias vezes sem quebrar nada. Ele pergunta o **tema visual** (uma das pastas dentro de `themes/`), cria os **links fixos** (hypr, hyprlock, swappy) e chama o `scripts/switch-theme.sh`. O `switch-theme.sh`:
- valida se o tema tem os arquivos obrigatórios;
- liga `~/.config/theme` ao tema;
- liga `~/.config/hypr/maquina` à pasta de `hypr/maquinas/` com o nome do hostname (sem diferenciar maiúsculas); se não houver, pergunta qual usar (no terminal ou pelo rofi, no SUPER+T). Para definir o nome: `hostnamectl set-hostname <Nome>`;
- para cada componente (waybar, rofi, kitty, swaync), usa a versão do tema, se existir, ou a da `base/`;
- aplica o **esquema de cores do KDE** (Dolphin e apps Qt) com `plasma-apply-colorscheme`, além do qt6ct e do Kvantum, quando o tema tem esses arquivos;
- recarrega Hyprland, Waybar e kitty e aplica o **wallpaper** com `swww`.

Se já existir uma configuração real no destino, ela é movida para `.bak` antes de criar o link.

## 📁 Estrutura
```
dotfiles/
├── install.sh              # provisionamento: links fixos + tema
├── scripts/
│   ├── lib.sh              # funções e listas de links compartilhadas
│   └── switch-theme.sh     # troca o tema ativo
├── hypr/                   # núcleo do Hyprland (igual para todos os temas)
│   ├── hyprland.conf       # só faz source dos demais
│   ├── configs/            # settings, animations, execs
│   ├── rules/              # binds e windowrules
│   ├── maquinas/           # Frieren/, FERN/: hardware.conf e monitors.conf
│   ├── scripts/            # battery-notify.sh, seletor-tema.sh
│   └── hyprlock.conf
├── swappy/config           # editor de anotações pós-screenshot
├── base/                   # layout padrão: waybar, rofi, kitty
├── themes/
│   ├── _modelo/            # ponto de partida para um tema novo
│   ├── Black_and_White/    # tema principal
│   └── Teste_Colorido/     # tema neon, só para testar os scripts
├── extras/nitch/           # personalização do nitch (patch)
└── docs/
    ├── temas.md            # como os temas funcionam
    ├── pacotes.md          # pacotes necessários
    └── ideias.md           # ideias futuras
```

## 🎨 O que cada peça configura
| Pasta ou arquivo | Programa | O que é |
|---|---|---|
| `hypr/`, `themes/<tema>/hypr.conf` | **Hyprland** | compositor de janelas (window manager) que roda todo o ambiente gráfico |
| `hypr/hyprlock.conf` | **Hyprlock** | tela de bloqueio |
| `base/waybar/` | **Waybar** | barra de status no topo (relógio, bateria, workspaces, ícones de sistema) |
| `base/rofi/` | **Rofi** | launcher de programas, clipboard e seletor de temas |
| `base/kitty/` | **Kitty** | emulador de terminal |
| `swaync/` (no tema) | **SwayNotificationCenter** | notificações e painel lateral de notificações |
| `themes/<tema>/kde.colors` | **KDE Plasma** | esquema de cores do Dolphin e dos outros apps Qt |
| `themes/<tema>/kvantum/` | **Kvantum** | motor que desenha a aparência (bordas, botões, sombras) dos apps Qt |
| `themes/<tema>/qt6ct.conf` | **qt6ct** | define qual tema e quais ícones os apps Qt6 usam |
| `themes/<tema>/imagens/` | **swww** | wallpapers com transições, miniatura do seletor e imagens do hyprlock |
| `swappy/config` | **Swappy** | editor de anotações depois do screenshot |

## ⚠️ Aviso
Este repositório reflete configurações pessoais, ajustadas para hardware e preferências específicas. Use como referência, mas revise antes de aplicar em outra máquina.
