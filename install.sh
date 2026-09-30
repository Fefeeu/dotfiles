#!/usr/bin/env bash
# Provisionamento: perfil de hardware, links fixos e tema inicial.
# Para só trocar de tema depois, use scripts/switch-theme.sh <tema>.

source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

info "--- Hyprland Setup (Provisionamento) ---"

# --- 1. HARDWARE ---
titulo "Perfil de Hardware:"
select HW in amd nvidia; do
    [[ -n "$HW" ]] && break || echo "Opção inválida"
done

# --- 2. TEMA ---
titulo "Tema Inicial:"
mapfile -t TEMAS < <(listar_temas)
select TEMA in "${TEMAS[@]}"; do
    [[ -n "$TEMA" ]] && break || echo "Opção inválida"
done

# --- LINKS FIXOS (independentes de tema) ---
titulo "Links fixos:"
link_com_backup "$DOTFILES_DIR/hypr/hardware/$HW.conf" "$CONFIG_DIR/hypr/hardware_profile.conf"
for src in "${!STATIC_MAP[@]}"; do
    link_com_backup "$DOTFILES_DIR/$src" "${STATIC_MAP[$src]}"
done

# --- TEMA ---
"$DOTFILES_DIR/scripts/switch-theme.sh" "$TEMA"

echo -e "\n${VERDE}### Sistema pronto! Edite os arquivos em ~/dotfiles e use 'hyprctl reload' ###${NC}"
