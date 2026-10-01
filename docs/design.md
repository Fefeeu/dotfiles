# Design

Decisões de visual ainda em aberto e referências para escolher. Quando uma
decisão for tomada, ela sai daqui e vira item no roteiro do CLAUDE.md.

## Decisões para ir atrás
- **Tema de ícones** (qt6ct, rofi, Dolphin): hoje o qt6ct usa `Papirus-Light`, que tem
  ícones escuros feitos para fundo claro, num tema escuro. O rofi usa `Papirus`.
  Escolher um tema escuro (lista abaixo) e usar o mesmo nos dois lugares.
- **Ícone por tema ou fixo**: decidir se o tema de ícones muda com o tema visual (uma
  linha em `themes/<tema>/qt6ct.conf` e na paleta do rofi) ou se é um só para todos.
- **Notificações (swaync)**: hoje usam o visual padrão. Criar o layout em `base/swaync/`
  com os nomes de cor da paleta, como o waybar.
- **Tray do waybar**: o `#tray` não tem a cápsula com borda dos outros módulos.
- **Calendário do waybar**: as cores do `config.jsonc` são fixas (`#99ffdd`, `#ffcc66`),
  não seguem o tema. Mantido assim por enquanto.
- **Hyprlock**: cores fixas, fora do tema (ver a migração para Lua no CLAUDE.md).
- **Cursor**: escolher um tema de cursor que combine (ver `docs/ideias.md`).
- **Abertura da sessão**: o logo e o wallpaper padrão do Hyprland aparecem antes do swww
  carregar (`misc` em `hypr/configs/settings.conf`).
- **Tema com layout próprio**: o menu no estilo Persona 3 Reload (ver `docs/temas.md`).

## Temas de ícones escuros recomendados
Pensando no Black_and_White (preto, branco e cinza). "dnf" quer dizer que está nos
repositórios do Fedora; o resto se instala pelo script do próprio GitHub, em
`~/.local/share/icons`, sem sudo.

| Tema | De onde vem | Por que combina |
|---|---|---|
| **Papirus-Dark** | dnf (`papirus-icon-theme-dark`, já instalado) | troca mais simples: mesmo estilo do Papirus que o rofi já usa. Com o script `papirus-folders` dá para deixar as pastas `black` ou `grey` |
| **Breeze Dark** | já vem com o KDE | igual ao Plasma; traço fino e discreto |
| **Colloid** (variante `grey`, escura) | GitHub vinceliuice/Colloid-icon-theme | ícones arredondados com pastas cinza; bem monocromático |
| **Tela** (variantes `black` ou `grey`, escura) | GitHub vinceliuice/Tela-icon-theme | pastas pretas ou cinza, ícones de app coloridos e limpos |
| **Fluent** (variante `grey`, escura) | GitHub vinceliuice/Fluent-icon-theme | estilo Windows 11, com pastas cinza |
| **Qogir Dark** | GitHub vinceliuice/Qogir-icon-theme | plano e neutro, com pastas escuras |

Sugestão para começar: **Papirus-Dark** com pastas `black` (já está instalado e o rofi
continua no mesmo estilo). Se quiser algo mais "mangá", testar o **Colloid grey**.

Como testar sem mexer no repositório: `qt6ct` → aba *Icon Theme* → escolher → abrir o
Dolphin. Para o rofi: `rofi -show drun -icon-theme <Nome>`.
