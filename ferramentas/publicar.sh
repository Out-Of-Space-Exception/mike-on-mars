#!/usr/bin/env bash
# Exporta o jogo para a web e publica no GitHub Pages (branch gh-pages).
# Uso (Git Bash, na raiz do repositório): bash ferramentas/publicar.sh
set -e
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
REMOTO="$(git -C "$RAIZ" remote get-url origin)"
bash "$RAIZ/ferramentas/exportar.sh"
cd "$RAIZ/build"
git init -q -b gh-pages
git add -A
git commit -qm "Publica versão web $(date '+%d/%m %H:%M')"
git push -qf "$REMOTO" gh-pages
echo "Publicado: https://out-of-space-exception.github.io/mike-on-mars/ (leva ~1 min para atualizar)"
