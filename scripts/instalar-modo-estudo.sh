#!/usr/bin/env bash
# Instala a parte de sistema do modo estudo (precisa de root):
#   sudo ~/dotfiles/scripts/instalar-modo-estudo.sh
# Copia de sistema/modo-estudo/ o serviço, a unit do systemd, as listas de
# apps e sites e a regra do polkit. Rode de novo depois de mudar qualquer um.
# A parte do usuário (atalho, waybar, comando estudar) vem pelos links normais.

# Carrega as mensagens compartilhadas e o caminho do repositório
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ORIGEM="$DOTFILES_DIR/sistema/modo-estudo"

# --- CONFERÊNCIAS ---
[[ $EUID -eq 0 ]] || erro "rode com sudo: sudo $0"
# o dono da sessão é quem chamou o sudo (é ele quem pode ligar o modo sem senha)
USUARIO="${SUDO_USER:-}"
[[ -n "$USUARIO" && "$USUARIO" != root ]] || erro "rode com sudo a partir do seu usuário"
# trocar as listas no meio de uma sessão seria um jeito de burlar
[[ -e /run/modo-estudo/restante ]] && erro "o modo estudo está ativo; espere acabar"

# --- CÓPIAS ---
titulo "Modo estudo (usuário: $USUARIO)"

# serviço, só o root pode editar
install -D -m 755 -o root -g root "$ORIGEM/modo-estudo.sh" /usr/local/libexec/modo-estudo
info "serviço -> /usr/local/libexec/modo-estudo"

# listas e o usuário que recebe as notificações
install -d -m 755 /etc/modo-estudo
install -m 644 "$ORIGEM/apps" "$ORIGEM/sites" /etc/modo-estudo/
printf '%s\n' "$USUARIO" > /etc/modo-estudo/usuario
info "listas -> /etc/modo-estudo/"

# unit do systemd
install -m 644 "$ORIGEM/modo-estudo@.service" /etc/systemd/system/
systemctl daemon-reload
info "unit -> /etc/systemd/system/modo-estudo@.service"

# regra do polkit com o nome do usuário (o polkit relê a pasta sozinho)
sed "s/USUARIO/$USUARIO/g" "$ORIGEM/50-modo-estudo.rules" > /etc/polkit-1/rules.d/50-modo-estudo.rules
chmod 644 /etc/polkit-1/rules.d/50-modo-estudo.rules
info "polkit -> /etc/polkit-1/rules.d/50-modo-estudo.rules"

echo -e "\n${VERDE}Pronto.${NC} Teste com: estudar 1"
