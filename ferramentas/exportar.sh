#!/usr/bin/env bash
# Builds the web version into build/ (without publishing). Usage: bash ferramentas/exportar.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-/c/Users/Flaflum/Tools/godot/Godot_v4.7.2-stable_win64_console.exe}"
NODE="$(command -v node || echo "/c/Program Files/nodejs/node.exe")"
"$NODE" "$ROOT/ferramentas/sincronizar.mjs"
rm -rf "$ROOT/build" && mkdir -p "$ROOT/build"
"$GODOT" --headless --path "$ROOT/jogo" --import > /dev/null 2>&1 || true
"$GODOT" --headless --path "$ROOT/jogo" --export-release "Web" "$ROOT/build/index.html"
cp "$ROOT/jogo/web/nave.png" "$ROOT/jogo/web/rubik.ttf" "$ROOT/jogo/web/share.png" "$ROOT/build/"
# New name for the game package on every version: the browser does not use the old cached one.
H="$(md5sum "$ROOT/build/index.pck" | cut -c1-8)"
mv "$ROOT/build/index.pck" "$ROOT/build/index-$H.pck"
sed -i "s|\"executable\":\"index\"|\"executable\":\"index\",\"mainPack\":\"index-$H.pck\"|; s|\"index.pck\":|\"index-$H.pck\":|" "$ROOT/build/index.html"
touch "$ROOT/build/.nojekyll"
echo "Web version ready in build/"
