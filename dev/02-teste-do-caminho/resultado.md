# Resultado do teste do caminho (14/11)

- **Funcionou:** Godot 4.7.2 → export Web single-thread → GitHub Pages → celular.
- **FPS (cubo de teste):** 70 em média, até 90 nos celulares do time. Travado em **60** (`application/run/max_fps=60`) para poupar bateria e não esquentar.
- **Toque:** chega como clique (emulação de mouse, ligada por padrão). Usar `InputEventMouseButton`.
- **Peso:** `index.wasm` = 39,5 MB cru, **9,7 MB com gzip**. O GitHub Pages comprime sozinho. A 1ª abertura demora alguns segundos; depois o navegador guarda.
- **Pegadinha:** `vram_texture_compression/for_mobile=true` → export falha com "configuration errors" sem detalhe. Deixar `false`.
- **Comandos:**
  - publicar: `bash ferramentas/publicar.sh`
  - testar no Wi-Fi local: `node ferramentas/servir.mjs` (mostra o endereço para o celular)
