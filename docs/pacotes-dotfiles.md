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
#   nerdfont: <nome>   fonte do GitHub (ryanoasis/nerd-fonts), instalada em
#                      ~/.local/share/fonts/<nome>Nerd
#   <pacote>  # motivo um pacote do dnf por linha
#   # ...              comentário (ignorado)
# =====================================================================

[todas]

# ----- REPOSITÓRIOS --------------------------------------------------
repo: copr solopasha/hyprland   # hyprland, hyprlock, swww, grimblast, cliphist

# ----- COMPOSITOR ----------------------------------------------------
hyprland                      # compositor (sessão "Hyprland" no SDDM); traz hyprutils, aquamarine etc.
xdg-desktop-portal-hyprland   # portal: compartilhar tela e screenshots pelos apps
hyprlock                      # tela de bloqueio (SUPER+L, hypr/hyprlock.conf)

# ----- BARRA, NOTIFICAÇÕES E BANDEJA ---------------------------------
waybar                        # barra (base/waybar)
SwayNotificationCenter        # notificações e painel (swaync-client no waybar)
libnotify                     # notify-send (bateria, seletor de temas, clipboard)
network-manager-applet        # nm-applet na bandeja (execs.conf)
NetworkManager-tui            # nmtui, aberto ao clicar na rede no waybar
blueman                       # blueman-manager, aberto ao clicar no bluetooth do waybar
bluez                         # bluetoothctl (módulo bluetooth do waybar e hyprlock)
pavucontrol                   # controle de volume, aberto ao clicar no áudio do waybar

# ----- LAUNCHER, CLIPBOARD E TERMINAL --------------------------------
rofi                          # launcher (SUPER+D), clipboard (SUPER+V) e seletor de temas (SUPER+T)
cliphist                      # histórico do clipboard (execs.conf, clipboard.sh)
wl-clipboard                  # wl-copy/wl-paste (cliphist e clipboard.sh)
kitty                         # terminal (SUPER+Return)

# ----- WALLPAPER E SCREENSHOTS ---------------------------------------
swww                          # wallpaper com transição (switch-theme.sh)
grimblast                     # screenshot de área (tecla Print)
grim                          # captura usada pelo grimblast
slurp                         # seleção de área usada pelo grimblast
jq                            # usado pelo grimblast
swappy                        # editor da screenshot (swappy/config)

# ----- HARDWARE E SISTEMA --------------------------------------------
wireplumber                   # wpctl: teclas de volume (binds.conf)
brightnessctl                 # teclas de brilho (binds.conf)
playerctl                     # música atual no hyprlock
iw                            # nome do wi-fi no hyprlock
procps-ng                     # pkill/pgrep (scripts)
polkit-kde                    # agente de senha (execs.conf: hostnamectl, apps de admin)

# ----- APARÊNCIA (apps Qt e KDE) -------------------------------------
dolphin                       # gerenciador de arquivos (SUPER+E)
plasma-workspace              # plasma-apply-colorscheme (kde.colors dos temas)
qt6ct                         # aparência dos apps Qt no Hyprland (QT_QPA_PLATFORMTHEME)
papirus-icon-theme            # ícones Papirus (rofi) e Papirus-Light (qt6ct)
papirus-icon-theme-light      # variante Papirus-Light usada no qt6ct

# ----- FONTES --------------------------------------------------------
adwaita-sans-fonts            # fonte do waybar e do qt6ct
nerdfont: JetBrainsMono       # JetBrainsMono Nerd Font: kitty, rofi, waybar, hyprlock

# ----- DOTFILES ------------------------------------------------------
git-core                      # clonar e atualizar este repositório


[FERN]
# Notebook NVIDIA (hypr/maquinas/FERN/hardware.conf)
repo: rpmfusion               # driver da NVIDIA
akmod-nvidia                  # driver da NVIDIA (compila o módulo a cada kernel)
xorg-x11-drv-nvidia-cuda-libs # bibliotecas da NVIDIA (CUDA/NVENC)
libva-nvidia-driver           # aceleração de vídeo (LIBVA_DRIVER_NAME=nvidia)


[Frieren]
# Desktop AMD (hypr/maquinas/Frieren/hardware.conf): o driver radeonsi já
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
