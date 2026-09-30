# Temas

Um tema fica em `themes/<nome>/`. O layout padrão fica em `base/`, e cada tema pode trazer só cores ou substituir componentes inteiros.

## Como o tema é aplicado
`scripts/switch-theme.sh <nome>`:
1. cria o link `~/.config/theme` → `themes/<nome>`;
2. para cada componente (`waybar`, `rofi`, `kitty/kitty.conf`, `swaync`), usa `themes/<nome>/<comp>` se existir, senão `base/<comp>`;
3. linka as partes opcionais do tema (`qt6ct.conf`, `kvantum/`, `kde.colors`);
4. recarrega Hyprland, Waybar e kitty, e troca o wallpaper.

O layout, seja da base ou de um override, sempre encontra as cores pelo mesmo caminho: `~/.config/theme/palette/...`.

## Estrutura
```
themes/<nome>/
├── hypr.conf            # obrigatório: bordas, gaps e cores (pode ter decoration/animations)
├── palette/             # obrigatório: só cores
│   ├── waybar.css
│   ├── rofi.rasi
│   └── kitty.conf
├── wallpapers/wall.png  # obrigatório (hyprlock também usa me.png, se existir)
├── kde.colors           # opcional: esquema de cores do KDE (Dolphin, apps Qt)
├── qt6ct.conf           # opcional
├── kvantum/             # opcional
└── waybar/ rofi/ kitty/ swaync/   # opcional: override total do componente
```

Pastas que começam com `_` (ex.: `_modelo`) não aparecem no `install.sh`.

## Nomes de cores (contrato com o layout base)
Cada paleta pode ter as cores cruas com os nomes que quiser, mas precisa definir estes nomes:

| Componente | Nomes |
|---|---|
| waybar (`@define-color`) | `fundo`, `fundo_modulo`, `fundo_hover`, `borda`, `texto`, `texto_ativo`, `texto_mudo` |
| rofi | `background`, `background-alt`, `foreground`, `selected`, `border-color` |
| kitty | `background`, `foreground`, `color0` … `color15` |

## Criar um tema
```bash
cp -r themes/_modelo themes/<nome>
# edite hypr.conf e palette/*, e coloque wallpapers/wall.png
scripts/switch-theme.sh <nome>
```

## Tema com layout próprio (ex.: menu estilo Persona 3 Reload)
Crie a pasta do componente dentro do tema, por exemplo `themes/<nome>/rofi/`. Ela substitui `base/rofi` inteira. Para reaproveitar as cores, importe a paleta pelo caminho fixo:
- rofi: `@import "~/.config/theme/palette/rofi.rasi"`
- waybar: `@import url("../theme/palette/waybar.css");`
- kitty: `include ~/.config/theme/palette/kitty.conf`

Scripts do override devem usar caminhos em `~/.config/<comp>/...`, nunca `~/dotfiles/themes/...`.
