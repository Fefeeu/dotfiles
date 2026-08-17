# dotfiles

Configuração do meu ambiente **[Hyprland](https://hyprland.org/)** (compositor Wayland), incluindo terminal, launcher de aplicativos e temas visuais. Este repositório centraliza esses arquivos de configuração e os conecta ao sistema por meio de links simbólicos, via `install.sh`.

## 🖥️ O ambiente

- **Hyprland** como compositor de janelas, com layout `dwindle`, bordas arredondadas, blur e animações configuradas em `hypr/configs/`.
- **Kitty** como terminal e **Dolphin** como gerenciador de arquivos padrão.
- **Rofi** como launcher de aplicativos, com applets prontos para bateria, brilho, volume, power menu e screenshot.
- **Waybar** como barra de status, **swaync** para notificações, **swww** para gerenciar o wallpaper e **nm-applet** para a conexão de rede — todos iniciados automaticamente em `hypr/configs/execs.conf`.
- Suporte a dois perfis de hardware (`amd` e `nvidia`), escolhidos na instalação e carregados como `hardware_profile.conf`.
- **Temas** (`themes/gruvbox`, `themes/tokyo_night`) que agrupam wallpaper e configuração de terminal, incluindo um utilitário de fetch de sistema (estilo `neofetch`) para o Tokyo Night.

## 📁 Estrutura do repositório

```
dotfiles/
├── hypr/
│   ├── hyprland.conf       # arquivo principal, importa os demais via `source`
│   ├── configs/            # settings, animations e execs (autostart)
│   ├── hardware/           # amd.conf, nvidia.conf
│   └── rules/               # binds.conf e windowrules.conf
├── rofi/                    # temas, cores, launchers e applets do Rofi
├── kitty/
│   └── kitty.conf
├── themes/
│   ├── gruvbox/
│   └── tokyo_night/         # inclui utilitário de fetch de sistema para terminal
└── install.sh                # script de instalação/provisionamento
```

## ⚙️ O que o `install.sh` faz

1. Pergunta qual **perfil de hardware** usar (`amd` ou `nvidia`) e cria o link `~/.config/hypr/hardware_profile.conf` apontando para o perfil escolhido.
2. Pergunta qual **tema inicial** aplicar, listando as pastas dentro de `themes/`, e cria o link `themes/current_theme`.
3. Cria **links simbólicos** de `hypr/hyprland.conf`, `hypr/configs`, `hypr/rules`, `rofi`, `kitty/kitty.conf`, `waybar` e `swaync` para os respectivos locais em `~/.config`, fazendo backup (`.bak`) de qualquer configuração real já existente antes de sobrescrever.

### Como usar

```bash
git clone https://github.com/Fefeeu/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## ⚠️ Aviso

Este repositório reflete configurações pessoais, ajustadas para hardware e preferências específicas. Use como referência, mas revise antes de aplicar em outra máquina.
