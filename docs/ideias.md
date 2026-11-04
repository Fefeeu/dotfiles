# Adições Para o Futuro
 
### Icones de Área de Trabalho
 Criar uma forma que cada área de trabalho tenha um icone, de preferencia de uma forma com que possa-se escolher os icones na hora ou não, opção de icones padrões e uma forma de personalizar os icones em tempo real de maneira simples.

### Manipulação Por Controle
Configurar uma forma de controlar o sistema operacional com um controle, onde possa:
- mover de foco entre janelas
- mover janelas
- ativar e desativar um ponteiro controlado pelos analogicos do Controle

### Bloqueio e Suspensão Automáticos (hypridle)
Usar o hypridle para, depois de um tempo parado:
- diminuir o brilho da tela
- bloquear com o hyprlock
- desligar a tela e suspender (no notebook, também ao fechar a tampa)

Hoje o bloqueio é só manual (SUPER+L).

### Tema de Cursor
Escolher um tema de cursor que combine com os temas (ex.: Bibata, Phinger) e definir no `hypr/configs/env.conf` (`XCURSOR_THEME`/`XCURSOR_SIZE`, ou `HYPRCURSOR_THEME` se for um tema hyprcursor), para o cursor ser o mesmo no Hyprland e nos apps.

### Aplicativos Padrão (mimeapps.list)
Levar o `~/.config/mimeapps.list` para o dotfiles, para os mesmos apps abrirem os mesmos tipos de arquivo em todos os computadores (Dolphin, `xdg-open`, KDE e Hyprland usam esse arquivo).
- montar uma lista limpa só com o que é comum (navegador, pastas, imagens, vídeo, PDF, texto...), sem entradas de uma máquina só (ex.: `userapp-Thunderbird-...`, Packet Tracer);
- entrar no `STATIC_MAP` (igual para todos os temas);
- cuidado: o KDE reescreve o arquivo ao mudar uma associação pela interface, e a mudança vai direto para o repositório; decidir se aceita isso ou se o install copia/junta o arquivo em vez de linkar;
- os apps da lista precisam estar no `docs/pacotes-dotfiles.md` ou no `docs/apps.md`.
