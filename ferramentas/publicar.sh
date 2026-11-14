#!/usr/bin/env bash
# Exporta o jogo para a web e publica no GitHub Pages (branch gh-pages).
# Uso (Git Bash, na raiz do repositório): bash ferramentas/publicar.sh
set -e
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-/c/Users/Flaflum/Tools/godot/Godot_v4.7.2-stable_win64_console.exe}"
REMOTO="$(git -C "$RAIZ" remote get-url origin)"
rm -rf "$RAIZ/build" && mkdir -p "$RAIZ/build"
"$GODOT" --headless --path "$RAIZ/jogo" --import
"$GODOT" --headless --path "$RAIZ/jogo" --export-release "Web" "$RAIZ/build/index.html"
touch "$RAIZ/build/.nojekyll"
cd "$RAIZ/build"
git init -q -b gh-pages
git add -A
git commit -qm "Publica versão web $(date '+%d/%m %H:%M')"
git push -qf "$REMOTO" gh-pages
echo "Publicado: https://out-of-space-exception.github.io/mike-on-mars/ (leva ~1 min para atualizar)"
