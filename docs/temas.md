# Temas

Um tema fica em `themes/<nome>/`. O layout padrão fica em `base/`, e cada tema pode trazer só cores ou substituir componentes inteiros.

## Como o tema é aplicado
`scripts/switch-theme.sh <nome>`:
1. cria o link `~/.config/theme` → `themes/<nome>`;
2. para cada componente (`waybar`, `rofi`, `kitty/kitty.conf`, `swaync`), usa `themes/<nome>/<comp>` se existir, senão `base/<comp>`;
3. linka as partes opcionais do tema (`kvantum/`, `kde.colors`) e gera o `qt6ct.conf` a partir do template do tema;
4. recarrega Hyprland, Waybar e kitty, e troca o wallpaper.

Também dá para trocar pelo seletor (**SUPER+T**, `hypr/scripts/seletor-tema.sh`): ele lista os temas com a miniatura `imagens/thumb.png` e o nome. O layout do seletor é `base/rofi/temas/seletor.rasi`, e um tema que sobrescreve o `rofi/` pode ter o próprio `temas/seletor.rasi`.

O layout, seja da base ou de um override, sempre encontra as cores pelo mesmo caminho: `~/.config/theme/palette/...`.

## Estrutura
```
themes/<nome>/
├── hypr.conf            # obrigatório: bordas, gaps e cores (pode ter decoration/animations)
├── palette/             # obrigatório: só cores
│   ├── waybar.css
│   ├── rofi.rasi
│   └── kitty.conf
├── imagens/
│   ├── wallpapers/wall.png  # obrigatório: wallpaper padrão (outros wallpapers ficam aqui)
│   ├── thumb.png            # obrigatório: miniatura no seletor de temas
│   └── me.png ...           # opcionais: outras imagens (o hyprlock usa me.png)
├── kde.colors           # opcional: esquema de cores do KDE (Dolphin, apps Qt)
├── qt6ct.conf           # opcional: template, `@HOME@` e `@TEMA@` são trocados ao aplicar
├── kvantum/             # opcional
└── waybar/ rofi/ kitty/ swaync/   # opcional: override total do componente
```

Pastas que começam com `_` (ex.: `_modelo`) não aparecem no `install.sh`.

## Nomes de cores (contrato com o layout base)
Cada paleta pode ter as cores cruas com os nomes que quiser, mas precisa definir estes nomes:

| Componente | Nomes |
|---|---|
| waybar (`@define-color`) | `fundo`, `fundo_modulo`, `fundo_hover`, `borda`, `texto`, `texto_ativo`, `texto_mudo`, `destaque`, `alerta` |
| rofi | `background`, `background-alt`, `foreground`, `selected`, `border-color` |
| kitty | `background`, `foreground`, `color0` … `color15` |

## Criar um tema
```bash
cp -r themes/_modelo themes/<nome>
# edite hypr.conf e palette/*, e coloque imagens/wallpapers/wall.png e imagens/thumb.png
scripts/switch-theme.sh <nome>
```

## Tema com layout próprio (ex.: menu estilo Persona 3 Reload)
Crie a pasta do componente dentro do tema, por exemplo `themes/<nome>/rofi/`. Ela substitui `base/rofi` inteira. Para reaproveitar as cores, importe a paleta pelo caminho fixo:
- rofi: `@import "~/.config/theme/palette/rofi.rasi"`
- waybar: `@import url("../theme/palette/waybar.css");`
- kitty: `include ~/.config/theme/palette/kitty.conf`

Scripts do override devem usar caminhos em `~/.config/<comp>/...`, nunca `~/dotfiles/themes/...`.
