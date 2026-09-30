# =====================================================================
# Apps pessoais — lista para instalação automática
#
# O que vai ser este arquivo:
#   Uma lista dos aplicativos do dia a dia (ex.: Steam, Discord, VS Code,
#   navegador, Spotify), no mesmo espírito do docs/pacotes-dotfiles.md,
#   para um script instalar tudo de uma vez numa máquina nova.
#
# Diferença para o pacotes-dotfiles.md:
#   - pacotes-dotfiles.md: o que o Hyprland e o dotfiles precisam para
#     funcionar (sem isso a sessão fica quebrada);
#   - apps.md: programas de uso pessoal, que não fazem parte da
#     configuração; a sessão funciona sem eles.
#
# Como deve funcionar (a definir quando o script for criado):
#   - um app por linha, com um comentário dizendo o que é;
#   - cada app diz de onde vem, porque nem todos estão no dnf do Fedora
#     (alguns precisam de repositório próprio, RPM Fusion ou Flatpak);
#   - seções por máquina, como no pacotes-dotfiles.md, para apps que só
#     fazem sentido numa delas;
#   - o script de instalação lê este arquivo e pula o que já existe.
#
# Ainda sem nenhum app: a lista e o script entram na etapa
# "Migração para LUA" do CLAUDE.md.
# =====================================================================
