// Confere se o repositório segue o padrão do AGENTS.md.
// Uso (na raiz do repositório): node ferramentas/conferir-padrao.mjs
import {readFileSync, readdirSync, statSync, existsSync} from 'node:fs';
import {join, dirname, resolve, relative} from 'node:path';
import {fileURLToPath} from 'node:url';

const RAIZ = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const AREAS = {design: 'Design', conteudo: 'Conteúdo', dev: 'Dev'};
const SECOES = ['## Por que importa', '## Leia antes', '## Passo a passo', '## O que entregar (nesta pasta)', '## Pronto quando', '## Não pode', '## Pedido pronto para a IA'];
const erros = [];
const erro = (arq, msg) => erros.push(`${relative(RAIZ, arq).replace(/\\/g, '/')}: ${msg}`);

// 1. Cada pasta de passo tem um PASSO.md no modelo.
for (const [area, nome] of Object.entries(AREAS)) {
  for (const pasta of readdirSync(join(RAIZ, area)).sort()) {
    const dir = join(RAIZ, area, pasta);
    if (!statSync(dir).isDirectory()) continue;
    if (!/^\d{2}-[a-z0-9-]+$/.test(pasta)) erro(dir, 'nome da pasta fora do padrão NN-nome');
    const arq = join(dir, 'PASSO.md');
    if (!existsSync(arq)) { erro(dir, 'falta o PASSO.md'); continue; }
    const txt = readFileSync(arq, 'utf8');
    if (!new RegExp(`^# ${nome} · ${pasta.slice(0, 2)} · `).test(txt)) erro(arq, `título deve começar com "# ${nome} · ${pasta.slice(0, 2)} · "`);
    for (const linha of ['> **Em 1 frase:**', '- **Dupla:**', '- **Prazo e status:**', '- **Precisa antes:**', '- **Quem usa depois:**'])
      if (!txt.includes(linha)) erro(arq, `falta a linha "${linha}"`);
    let ultimo = -1;
    for (const s of SECOES) {
      const i = txt.indexOf(`\n${s}\n`);
      if (i < 0) erro(arq, `falta a seção "${s}"`);
      else if (i < ultimo) erro(arq, `seção fora de ordem: "${s}"`);
      else ultimo = i;
    }
  }
}

// 2. Links relativos de todos os .md apontam para algo que existe.
const mds = [];
const andar = d => { for (const n of readdirSync(d)) { if (n.startsWith('.') || n === 'node_modules' || n === 'build') continue;
  const p = join(d, n); if (statSync(p).isDirectory()) andar(p); else if (n.endsWith('.md')) mds.push(p); } };
andar(RAIZ);
// Arquivo de entrega que ainda não existe (dentro da pasta de um passo) não é erro: só "a entregar".
const aEntregar = new Set();
const ENTREGA = /^(design|conteudo|dev)\/\d{2}-[^/]+\/(?!PASSO\.md$).+/;
for (const arq of mds) {
  const txt = readFileSync(arq, 'utf8').replace(/```[\s\S]*?```/g, '').replace(/`[^`\n]*`/g, '');
  for (const [, alvo] of txt.matchAll(/\]\(([^)\s]+)\)/g)) {
    if (/^(https?:|mailto:|#)/.test(alvo)) continue;
    const caminho = resolve(dirname(arq), decodeURIComponent(alvo.split('#')[0]));
    if (existsSync(caminho)) continue;
    const rel = relative(RAIZ, caminho).replace(/\\/g, '/');
    if (ENTREGA.test(rel)) aEntregar.add(rel); else erro(arq, `link quebrado: ${alvo}`);
  }
}

// 3. Nomes de arquivo nas pastas dos passos: minúsculas, sem acento, sem espaço.
for (const area of Object.keys(AREAS)) {
  const andarNomes = d => { for (const n of readdirSync(d)) { const p = join(d, n);
    if (n !== 'PASSO.md' && !/^[a-z0-9][a-z0-9._-]*$/.test(n)) erro(p, 'nome fora do padrão (minúsculas, sem acento, sem espaço)');
    if (statSync(p).isDirectory()) andarNomes(p); } };
  andarNomes(join(RAIZ, area));
}

if (aEntregar.size) console.log(`📦 ${aEntregar.size} arquivo(s) ainda a entregar:\n- ` + [...aEntregar].sort().join('\n- '));
if (erros.length) { console.log(`❌ ${erros.length} problema(s):\n- ` + erros.join('\n- ')); process.exit(1); }
console.log('✅ Tudo no padrão.');
