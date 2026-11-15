#!/usr/bin/env bash
# Exports the game to the web and publishes it on GitHub Pages (gh-pages branch).
# Usage (Git Bash, from the repository root): bash ferramentas/publicar.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REMOTE="$(git -C "$ROOT" remote get-url origin)"
bash "$ROOT/ferramentas/exportar.sh"
cd "$ROOT/build"
git init -q -b gh-pages
git add -A
git commit -qm "Publish web version $(date '+%d/%m %H:%M')"
git push -qf "$REMOTE" gh-pages
echo "Published: https://out-of-space-exception.github.io/mike-on-mars/ (takes ~1 min to update)"
