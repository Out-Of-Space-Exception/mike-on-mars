#!/usr/bin/env bash
# Gera a versão web em build/ (sem publicar). Uso: bash ferramentas/exportar.sh
set -e
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-/c/Users/Flaflum/Tools/godot/Godot_v4.7.2-stable_win64_console.exe}"
NODE="$(command -v node || echo "/c/Program Files/nodejs/node.exe")"
"$NODE" "$RAIZ/ferramentas/sincronizar.mjs"
rm -rf "$RAIZ/build" && mkdir -p "$RAIZ/build"
"$GODOT" --headless --path "$RAIZ/jogo" --import > /dev/null 2>&1 || true
"$GODOT" --headless --path "$RAIZ/jogo" --export-release "Web" "$RAIZ/build/index.html"
cp "$RAIZ/jogo/web/nave.png" "$RAIZ/jogo/web/rubik.ttf" "$RAIZ/jogo/web/share.png" "$RAIZ/build/"
# Nome novo para o pacote do jogo a cada versão: o navegador não usa a versão velha guardada.
H="$(md5sum "$RAIZ/build/index.pck" | cut -c1-8)"
mv "$RAIZ/build/index.pck" "$RAIZ/build/index-$H.pck"
sed -i "s|\"executable\":\"index\"|\"executable\":\"index\",\"mainPack\":\"index-$H.pck\"|; s|\"index.pck\":|\"index-$H.pck\":|" "$RAIZ/build/index.html"
touch "$RAIZ/build/.nojekyll"
echo "Versão web pronta em build/"
