# dotfiles

Configuração do meu ambiente **[Hyprland](https://hyprland.org/)** no Fedora 43, sobre o KDE Plasma 6. O repositório é a fonte da verdade: o `install.sh` liga tudo em `~/.config` com links simbólicos.

## 🖥️ O ambiente
- **Hyprland**: layout `dwindle`, blur e animações em `hypr/configs/`.
- **Waybar** como barra, **Rofi** como launcher e clipboard, **swaync** para notificações e **swww** para o wallpaper.
- **Kitty** como terminal e **Dolphin** como gerenciador de arquivos.
- **Hyprlock** como tela de bloqueio, com aviso de bateria baixa em `hypr/scripts/`.
- **Dois perfis de hardware**: `amd` (desktop Frieren) e `nvidia` (notebook FERN).
- **Temas**: cada tema pode mudar só as cores ou substituir componentes inteiros. Veja [docs/temas.md](docs/temas.md).

## 📁 Estrutura
```
dotfiles/
├── install.sh              # provisionamento: hardware + links fixos + tema
├── scripts/
│   ├── lib.sh              # funções e listas de links compartilhadas
│   └── switch-theme.sh     # troca o tema ativo
├── hypr/                   # núcleo do Hyprland (igual para todos os temas)
│   ├── hyprland.conf       # só faz source dos demais
│   ├── configs/            # settings, animations, execs, monitors
│   ├── rules/              # binds e windowrules
│   ├── hardware/           # amd.conf, nvidia.conf
│   ├── scripts/            # battery-notify.sh
│   └── hyprlock.conf
├── swappy/config
├── base/                   # layout padrão: waybar, rofi, kitty
├── themes/
│   ├── _modelo/            # ponto de partida para um tema novo
│   └── black_and_white/    # hypr.conf, palette/, wallpapers/, KDE/Qt
├── extras/nitch/           # personalização do nitch (patch)
└── docs/
    ├── temas.md            # como os temas funcionam
    ├── pacotes.md          # pacotes necessários
    └── ideias.md           # ideias futuras
```

## ⚙️ Como usar
```bash
git clone https://github.com/Fefeeu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh                         # escolhe hardware e tema
scripts/switch-theme.sh <tema>       # troca só o tema depois
```

O `install.sh`:
1. liga `~/.config/hypr/hardware_profile.conf` ao perfil escolhido;
2. cria os links fixos (hypr, swappy);
3. chama o `switch-theme.sh`, que liga `~/.config/theme` ao tema e escolhe, para cada componente, a versão do tema ou a da base.

Se já existir uma configuração real no destino, ela é movida para `.bak` antes de criar o link.

## ⚠️ Aviso
Este repositório reflete configurações pessoais, ajustadas para hardware e preferências específicas. Use como referência, mas revise antes de aplicar em outra máquina.
