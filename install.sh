#!/usr/bin/env bash
# Instalação completa: chama cada passo em scripts/install/, um por vez.
# Cada passo roda num bash próprio, então o set -e e o exit dos scripts não
# fecham o terminal, seja qual for o jeito de rodar (./, bash ou source).
# Sem set -e aqui de propósito: este arquivo pode rodar dentro do terminal.

# Pasta dos passos (scripts/install/ ao lado deste arquivo)
PASSOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/install"

# Nerd Fonts e temas de ícones (pasta do usuário, sem sudo)
bash "$PASSOS_DIR/install-fonts.sh"
bash "$PASSOS_DIR/install-icons.sh"

# máquina, links fixos e tema inicial
bash "$PASSOS_DIR/instalador-inicial.sh" "$@"
