#!/usr/bin/env bash
# Provisionamento: links fixos e tema inicial.
# A pasta da máquina (hypr/maquinas/) é escolhida pelo switch-theme.sh.
# Para só trocar de tema depois, use scripts/switch-theme.sh <tema>.

source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

info "--- Hyprland Setup (Provisionamento) ---"

# --- TEMA ---
titulo "Tema Inicial:"
mapfile -t TEMAS < <(listar_temas)
select TEMA in "${TEMAS[@]}"; do
    [[ -n "$TEMA" ]] && break || echo "Opção inválida"
done

# --- LINKS FIXOS (independentes de tema) ---
titulo "Links fixos:"
for src in "${!STATIC_MAP[@]}"; do
    link_com_backup "$DOTFILES_DIR/$src" "${STATIC_MAP[$src]}"
done

# --- TEMA ---
"$DOTFILES_DIR/scripts/switch-theme.sh" "$TEMA"

echo -e "\n${VERDE}### Sistema pronto! Edite os arquivos em ~/dotfiles e use 'hyprctl reload' ###${NC}"
