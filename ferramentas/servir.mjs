// Servidor local para testar o export web no PC e no celular (mesmo Wi-Fi).
// Uso: node ferramentas/servir.mjs   → abre em http://localhost:8060 e mostra o endereço para o celular.
import {createServer} from 'node:http';
import {readFile, stat} from 'node:fs/promises';
import {networkInterfaces} from 'node:os';
import {extname, join, normalize} from 'node:path';
import {fileURLToPath} from 'node:url';
import {gzipSync} from 'node:zlib';

const cache = new Map(); // arquivo -> versão gzip (como o GitHub Pages faz)

const ROOT = join(fileURLToPath(new URL('..', import.meta.url)), 'build');
const PORT = 8060;
const TYPES = {'.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.wasm': 'application/wasm', '.pck': 'application/octet-stream', '.png': 'image/png', '.ico': 'image/x-icon', '.json': 'application/json', '.svg': 'image/svg+xml'};

createServer(async (req, res) => {
  const path = decodeURIComponent((req.url || '/').split('?')[0]);
  const file = normalize(join(ROOT, path === '/' ? 'index.html' : path));
  if (!file.startsWith(ROOT)) { res.writeHead(403).end(); return; }
  try {
    let data = await readFile(file);
    const headers = {'Content-Type': TYPES[extname(file)] || 'application/octet-stream', 'Cache-Control': 'no-store'};
    if (/gzip/.test(req.headers['accept-encoding'] || '') && ['.wasm', '.js', '.pck', '.html'].includes(extname(file))) {
      const chave = `${file}:${(await stat(file)).mtimeMs}`;  // exportou de novo? a chave muda
      if (!cache.has(chave)) cache.set(chave, gzipSync(data, {level: 9}));
      data = cache.get(chave);
      headers['Content-Encoding'] = 'gzip';
    }
    res.writeHead(200, headers);
    res.end(data);
  } catch {
    res.writeHead(404).end('nao encontrado');
  }
}).listen(PORT, '0.0.0.0', () => {
  console.log(`PC:      http://localhost:${PORT}`);
  for (const nets of Object.values(networkInterfaces())) {
    for (const n of nets || []) if (n.family === 'IPv4' && !n.internal) console.log(`Celular: http://${n.address}:${PORT}`);
  }
});
