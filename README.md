# dotfiles

Configuração do meu ambiente **[Hyprland](https://hyprland.org/)** (compositor Wayland) rodando sobre **KDE Plasma 6** no **Fedora 43**, usada em duas máquinas (desktop AMD e notebook NVIDIA). O repositório funciona como *single source of truth*: todo o sistema é configurado através de links simbólicos (`ln -sfn`) apontando para cá, aplicados pelo `install.sh`.

## ⚙️ Como funciona o `install.sh`

O script é idempotente (pode ser rodado várias vezes sem quebrar nada) e separa duas decisões independentes:

1. **Perfil de hardware** (`amd` ou `nvidia`) — necessário porque as duas máquinas têm drivers/configurações de GPU diferentes.
2. **Tema visual** (uma das pastas dentro de `themes/`) — a aparência de todo o ambiente.

Depois de escolhidas as duas opções, o script:
- Valida se o tema selecionado tem o arquivo mínimo obrigatório (`hypr/colors.conf`) antes de prosseguir.
- Cria os links de hardware (`hardware_profile.conf`) e tema (`theme_profile.conf`, além de atualizar o symlink `themes/current_theme`).
- Cria os **links fixos**, que não mudam com o tema: `hyprland.conf`, `hypr/configs`, `hypr/rules`, `swappy/config`.
- Cria os **links do tema ativo**: `kitty`, `waybar`, `rofi`, `swaync`, `qt6ct` e `kvantum`, pulando com aviso qualquer um que não exista naquele tema específico.
- Aplica o **esquema de cores do KDE** (Dolphin e apps Qt), copiando para `~/.local/share/color-schemes` e aplicando via `plasma-apply-colorscheme`, se disponível.
- Aplica o **wallpaper** do tema via `swww`, se o daemon já estiver rodando.
- Faz **backup automático** (`.bak`) de qualquer configuração real que já exista antes de sobrescrevê-la com o symlink.

```bash
git clone https://github.com/Fefeeu/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## 📁 Estrutura do repositório

```
dotfiles/
├── hypr/
│   ├── hyprland.conf         # arquivo principal, importa os demais via `source`
│   ├── hardware/             # amd.conf, nvidia.conf
│   ├── configs/               # settings, animations e execs (autostart)
│   └── rules/                 # binds.conf e windowrules.conf
├── swappy/
│   └── config                 # editor de anotações pós-screenshot
├── themes/
│   ├── current_theme          # symlink para o tema ativo no momento
│   ├── black_and_white/
│   ├── gruvbox_light/
│   ├── primeiro_theme/
│   └── tokyo_night/
├── contexto.md                 # anotações de arquitetura e histórico de problemas resolvidos
├── pakgs.md                    # lista completa de pacotes do ambiente, comentados por categoria
├── install.sh
└── README.md
```

## 🎨 Estrutura de um tema

Cada pasta dentro de `themes/` reúne as configurações visuais de todos os programas do ambiente, para que trocar de tema troque a aparência do sistema inteiro de uma vez. Nem toda pasta de tema precisa ter todos os itens — o `install.sh` pula silenciosamente o que não existir. Abaixo, o que é cada subpasta/arquivo (com base no tema `black_and_white`, o mais completo):

| Pasta/arquivo | O que é |
|---|---|
| `hypr/` | Configuração de tema do **Hyprland**, o compositor de janelas (window manager) que roda todo o ambiente gráfico — **obrigatória**, é o único item validado pelo `install.sh` antes de aplicar o tema |
| `kde/` | Esquema de cores do **KDE Plasma**, usado pelo Dolphin (gerenciador de arquivos) e outros aplicativos baseados em Qt |
| `kitty/` | Configuração do **Kitty**, o emulador de terminal usado no dia a dia |
| `kvantum/` | Tema para o **Kvantum**, motor que desenha a aparência (bordas, botões, sombras) dos aplicativos Qt |
| `qt6ct/` | Configuração do **Qt6ct**, ferramenta que define qual tema/ícones os aplicativos Qt6 devem usar |
| `rofi/` | Configuração do **Rofi**, o launcher usado para abrir programas, trocar janelas e mostrar menus rápidos (power menu, volume, etc.) |
| `swaync/` | Configuração do **SwayNotificationCenter**, o daemon que exibe as notificações do sistema e o painel lateral de notificações |
| `waybar/` | Configuração da **Waybar**, a barra de status no topo da tela (relógio, bateria, workspaces, ícones de sistema) |
| `wallpapers/` | Papéis de parede do tema, aplicados automaticamente via `swww` (daemon de wallpaper com transições) |
| `vscode_cores.py` | Script que aplica a paleta de cores do tema no **VS Code** *(presente apenas no `black_and_white`)* |

O tema **`black_and_white`** é atualmente o mais completo, com todos os itens acima presentes — os demais (`gruvbox_light`, `primeiro_theme`, `tokyo_night`) ainda estão sendo migrados para essa mesma estrutura.

## 📄 Outros arquivos de referência

- **`contexto.md`** — resumo da arquitetura do repositório e histórico de problemas já resolvidos (ex.: links circulares no Kitty, submódulos indevidos criados a partir de temas do Rofi baixados prontos).
- **`pakgs.md`** — lista comentada de todos os pacotes usados no ambiente (Fedora 43), organizada por categoria: compositor/Wayland, barra e notificações, terminal, launcher, wallpaper, screenshots, gerenciador de arquivos, temas Qt/KDE, áudio, bluetooth, rede, fontes e mais.

## ⚠️ Aviso

Este repositório reflete configurações pessoais, ajustadas para hardware e preferências específicas. Use como referência, mas revise antes de aplicar em outra máquina.
