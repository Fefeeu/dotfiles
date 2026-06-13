# =====================================================
# Lista de Packages — Rice / Setup Hyprland
# Fedora 43 — Felipe Ferreira
# Formato: package # descrição / motivo
# =====================================================

gnome-keyring         # gerenciador de senhas

# ----- COMPOSITOR E WAYLAND -----------------------

hyprland              # compositor Wayland — window manager principal

hyprland-uwsm         # session manager para Hyprland

xdg-desktop-portal-hyprland # integração de portais (screenshots, screenshare, etc.)

xdg-desktop-portal    # portal base do freedesktop

xdg-desktop-portal-gtk # fallback GTK para portais

aquamarine            # backend de renderização do Hyprland

hyprpicker            # color picker para Wayland

hyprcursor            # suporte a cursores customizados no Hyprland

hyprlang              # linguagem de configuração do Hyprland

hyprutils             # utilitários do ecossistema Hypr

uwsm                  # universal wayland session manager

hyprlock              # tela de bloqueio

# ----- BARRA E NOTIFICAÇÕES -----------------------

waybar                # barra de status customizável

SwayNotificationCenter # daemon de notificações com painel lateral (swaync)

# ----- TERMINAL ------------------------------------

kitty                 # emulador de terminal principal

kitty-kitten          # plugins do kitty (icat, diff, etc.)

kitty-shell-integration # integração com shells

alacritty             # emulador de terminal alternativo

# ----- LAUNCHER ------------------------------------

rofi                  # launcher de aplicativos

rofi-themes           # temas para o rofi

wofi                  # launcher alternativo para Wayland

# ----- WALLPAPER -----------------------------------

swww                  # daemon de wallpaper com transições para Wayland

# ----- SCREENSHOTS ---------------------------------

grim                  # ferramenta de screenshot para Wayland

grimblast             # wrapper do grim com suporte a áreas/janelas

swappy                # editor de anotações pós-screenshot

slurp                 # seleção de área na tela (usado com grim)

# ----- GERENCIADOR DE ARQUIVOS --------------------

dolphin               # gerenciador de arquivos KDE

dolphin-libs          # bibliotecas do dolphin

dolphin-plugins       # plugins extras do dolphin

ffmpegthumbs          # thumbnails de vídeo no dolphin

# ----- TEMAS QT / KDE -----------------------------

kvantum               # engine de temas SVG para apps Qt6

kvantum-qt5           # engine de temas SVG para apps Qt5

kvantum-data          # temas padrão do kvantum

qt6ct                 # configuração de aparência para apps Qt6


papirus-icon-theme    # tema de ícones base

papirus-icon-theme-dark  # variante dark do Papirus

papirus-icon-theme-light # variante light do Papirus (pastas mais visíveis)

breeze-icon-theme     # tema de ícones padrão KDE

breeze-gtk-common     # tema GTK Breeze

breeze-gtk-gtk3       # tema GTK3 Breeze

breeze-gtk-gtk4       # tema GTK4 Breeze

breeze-cursor-theme   # tema de cursor Breeze

# ----- PLASMA (necessário para temas KDE) ---------

plasma-workspace      # provê plasma-apply-colorscheme e infraestrutura KDE

kde-gtk-config        # integração de temas GTK no KDE/Hyprland

plasma-breeze         # tema Breeze do Plasma

# ----- ÁUDIO --------------------------------------

pipewire              # servidor de áudio moderno

pipewire-alsa         # compatibilidade ALSA

pipewire-pulseaudio   # compatibilidade PulseAudio

pipewire-jack-audio-connection-kit # compatibilidade JACK

wireplumber           # session manager do PipeWire

pavucontrol           # controle de volume GUI

playerctl             # controle de players de mídia (mpris/waybar)

playerctl-libs        # bibliotecas do playerctl

# ----- BLUETOOTH ----------------------------------

bluez                 # stack Bluetooth do Linux

bluez-obexd           # transferência de arquivos via Bluetooth

blueman               # GUI completa de Bluetooth com systray

NetworkManager-bluetooth # integração Bluetooth no NetworkManager

# ----- REDE ----------------------------------------

NetworkManager        # gerenciador de rede

network-manager-applet # applet de rede para systray

nm-connection-editor  # editor de conexões de rede

NetworkManager-tui    # interface de texto (TUI) para gerenciar redes, conexões Wi-Fi e VPN via terminal

# ----- FONTES (usadas em rices) -------------------

adwaita-sans-fonts    # fonte Adwaita Sans (usada no qt6ct)

google-noto-sans-fonts # fonte Noto Sans (fallback universal)

google-noto-color-emoji-fonts # emojis coloridos

fontawesome-6-free-fonts # ícones FontAwesome (usados no Waybar/Rofi)

fontawesome-6-brands-fonts # ícones de marcas (FontAwesome)

# ----- FETCH / TERMINAL UTILS ---------------------

fastfetch             # fetch moderno com paleta de cores completa

neovim                # editor de texto no terminal

ripgrep               # busca rápida no terminal (rg)

bat                   # cat com syntax highlighting (se instalado)

tmux                  # multiplexador de terminal

tree                  # visualização de árvore de diretórios

wl-clipboard          # copiar/colar no Wayland (wl-copy/wl-paste)

# ----- CURSOR E INPUT -----------------------------

brightnessctl         # controle de brilho via terminal

slitherer             # utilitário de input Wayland

# ----- EXTRAS WAYLAND -----------------------------

wayland-utils         # utilitários de diagnóstico Wayland

xorg-x11-server-Xwayland # compatibilidade XWayland para apps X11

xwaylandvideobridge   # bridge para compartilhamento de tela XWayland

layer-shell-qt        # suporte a layer shell para apps Qt (Waybar, etc.)

gtk-layer-shell       # suporte a layer shell para apps GTK

gtk4-layer-shell      # suporte a layer shell para apps GTK4

wlr-randr             # configuração de monitores no Wayland

xdg-user-dirs         # diretórios padrão do usuário

# ----- PORTAL / INTEGRAÇÃO ------------------------

xdg-desktop-portal-kde # portal KDE (seletor de arquivos, etc.)

kio-extras            # protocolos extras para o KDE (sftp, smb, etc.)

kio-fuse              # montagem de KIO via FUSE

# ----- MÍDIA / CODECS (para rices com mpris) ------

vlc                   # player de mídia completo

gstreamer1            # framework de mídia

gstreamer1-plugins-base # plugins base do GStreamer

gstreamer1-plugins-good # plugins bons do GStreamer

gstreamer1-plugin-libav # suporte ffmpeg no GStreamer

ffmpeg-libs           # bibliotecas FFmpeg

# ----- GAMING (relevante para o setup) ------------
gamemode              # otimizações de performance para jogos
