# =====================================================================
# Pacotes do dotfiles — Fedora 43 KDE Plasma + Hyprland
#
# Tudo que falta num Fedora KDE recém-instalado para o Hyprland funcionar
# como está configurado neste repositório. Pacotes que o KDE já traz
# (dolphin, polkit-kde, plasma-workspace, wireplumber...) também estão
# listados quando o dotfiles depende deles: o dnf pula o que já existe.
#
# Formato (feito para um instalador ler linha por linha):
#   [seção]            todas | FERN | Frieren | extras
#                      "todas" vale sempre; FERN e Frieren só na máquina
#                      com esse nome (pasta de hypr/maquinas/); extras é
#                      opcional
#   repo: <repo>       repositório a ativar antes dos pacotes da seção:
#                      copr <usuário/projeto> ou rpmfusion
#   <pacote>  # motivo um pacote do dnf por linha
#   <pacote> = <versão-release>  # motivo
#                      instala essa versão exata e trava com o dnf
#                      versionlock (o "dnf upgrade" não passa dela);
#                      apagar a versão e rodar "sudo dnf versionlock
#                      delete <pacote>" para destravar
#   # ...              comentário (ignorado)
#
# Nerd Fonts e temas de ícones não ficam aqui: vêm do GitHub para a pasta
# do usuário, sem sudo, pelos scripts/install/install-fonts.sh e
# install-icons.sh (a lista fica dentro de cada script).
# =====================================================================

[todas]

# ----- REPOSITÓRIOS --------------------------------------------------
repo: copr nett00n/hyprland      # hyprland, hyprlock, xdg-desktop-portal-hyprland, cliphist
repo: copr alebastr/sway-extras  # awww (o swww mudou de nome e não está no Fedora)

# ----- COMPOSITOR ----------------------------------------------------
# Só o Hyprland fica travado (na 0.57.1, correção da 0.57, a primeira
# que só lê Lua), para um "dnf upgrade" não trocar de versão sem querer.
# O resto atualiza normalmente: o pacote do Hyprland pede as bibliotecas
# pela versão (libaquamarine.so.15, libhyprgraphics.so.5...), então o dnf
# não atualiza uma biblioteca que o quebraria. Para subir de versão:
# trocar a versão aqui e rodar o scripts/install/install-pacotes.sh
hyprland = 0.57.1-1.fc43      # compositor (sessão "Hyprland" no SDDM)
xdg-desktop-portal-hyprland   # portal: compartilhar tela e screenshots pelos apps
hyprlock                      # tela de bloqueio (SUPER+L, hypr/hyprlock.conf)

# ----- BARRA, NOTIFICAÇÕES E BANDEJA ---------------------------------
waybar                        # barra (base/waybar)
SwayNotificationCenter        # notificações e painel (swaync-client no waybar)
libnotify                     # notify-send (bateria, seletor de temas, clipboard)
network-manager-applet        # nm-applet na bandeja (execs.lua)
NetworkManager-tui            # nmtui, aberto ao clicar na rede no waybar
blueman                       # blueman-manager, aberto ao clicar no bluetooth do waybar
bluez                         # bluetoothctl (módulo bluetooth do waybar e hyprlock)
pavucontrol                   # controle de volume, aberto ao clicar no áudio do waybar

# ----- LAUNCHER, CLIPBOARD E TERMINAL --------------------------------
rofi                          # launcher (SUPER+D), clipboard (SUPER+V) e seletor de temas (SUPER+T)
cliphist                      # histórico do clipboard (execs.lua, clipboard.sh)
wl-clipboard                  # wl-copy/wl-paste (cliphist e clipboard.sh)
kitty                         # terminal (SUPER+Return)

# ----- WALLPAPER E SCREENSHOTS ---------------------------------------
awww                          # wallpaper com transição (execs.lua, switch-theme.sh); antigo swww
grim                          # captura da screenshot (tecla Print)
slurp                         # seleção de área da screenshot (tecla Print)
swappy                        # editor da screenshot (swappy/config)

# ----- HARDWARE E SISTEMA --------------------------------------------
wireplumber                   # wpctl: teclas de volume (binds.lua)
brightnessctl                 # teclas de brilho (binds.lua)
playerctl                     # música atual no hyprlock
iw                            # nome do wi-fi no hyprlock
hostname                      # nome da máquina no hyprlock
procps-ng                     # pkill/pgrep (scripts)
polkit-kde                    # agente de senha (execs.lua: hostnamectl, apps de admin)
polkit                        # regra que deixa ligar o modo estudo sem senha (sistema/modo-estudo)
util-linux                    # flock e runuser (serviço do modo estudo)

# ----- APARÊNCIA (apps Qt e KDE) -------------------------------------
dolphin                       # gerenciador de arquivos (SUPER+E)
plasma-workspace              # plasma-apply-colorscheme (kde.colors dos temas)
qt6ct                         # aparência dos apps Qt no Hyprland (QT_QPA_PLATFORMTHEME)

# ----- FONTES --------------------------------------------------------
adwaita-sans-fonts            # fonte do waybar e do qt6ct

# ----- DOTFILES ------------------------------------------------------
git-core                      # clonar e atualizar este repositório


[FERN]
# Notebook NVIDIA (hypr/maquinas/FERN/hardware.lua)
repo: rpmfusion               # driver da NVIDIA
akmod-nvidia                  # driver da NVIDIA (compila o módulo a cada kernel)
xorg-x11-drv-nvidia-cuda-libs # bibliotecas da NVIDIA (CUDA/NVENC)
libva-nvidia-driver           # aceleração de vídeo (LIBVA_DRIVER_NAME=nvidia)


[Frieren]
# Desktop AMD (hypr/maquinas/Frieren/hardware.lua): o driver radeonsi já
# vem no mesa do Fedora, nada a instalar


[extras]
# nitch: fetch de sistema ao abrir o terminal, com a personalização de
# extras/nitch. O nim não está no dnf do Fedora: vem do choosenim, que
# instala em ~/.nimble/bin (precisa estar no PATH). Depois dos pacotes:
#   curl https://nim-lang.org/choosenim/init.sh -sSf | sh
#   git clone https://github.com/unxsh/nitch.git ~/.config/nitch
#   git -C ~/.config/nitch apply ~/dotfiles/extras/nitch/drawing.patch
#   cd ~/.config/nitch && nimble build
gcc                           # compilador C usado pelo nim (choosenim e nimble build)
