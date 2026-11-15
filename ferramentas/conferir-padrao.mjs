// Checks whether the repository follows the AGENTS.md standard.
// Usage (from the repository root): node ferramentas/conferir-padrao.mjs
import {readFileSync, readdirSync, statSync, existsSync} from 'node:fs';
import {join, dirname, resolve, relative} from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const AREAS = {design: 'Design', conteudo: 'Conteúdo', dev: 'Dev'};
const SECTIONS = ['## Por que importa', '## Leia antes', '## Passo a passo', '## O que entregar (nesta pasta)', '## Pronto quando', '## Não pode', '## Pedido pronto para a IA'];
const errors = [];
const error = (file, msg) => errors.push(`${relative(ROOT, file).replace(/\\/g, '/')}: ${msg}`);

// 1. Each step folder has a PASSO.md in the template.
for (const [area, name] of Object.entries(AREAS)) {
  for (const folder of readdirSync(join(ROOT, area)).sort()) {
    const dir = join(ROOT, area, folder);
    if (!statSync(dir).isDirectory()) continue;
    if (!/^\d{2}-[a-z0-9-]+$/.test(folder)) error(dir, 'folder name does not follow the NN-name standard');
    const file = join(dir, 'PASSO.md');
    if (!existsSync(file)) { error(dir, 'PASSO.md is missing'); continue; }
    const txt = readFileSync(file, 'utf8');
    if (!new RegExp(`^# ${name} · ${folder.slice(0, 2)} · `).test(txt)) error(file, `title must start with "# ${name} · ${folder.slice(0, 2)} · "`);
    for (const line of ['> **Em 1 frase:**', '- **Dupla:**', '- **Prazo e status:**', '- **Precisa antes:**', '- **Quem usa depois:**'])
      if (!txt.includes(line)) error(file, `missing the line "${line}"`);
    let last = -1;
    for (const s of SECTIONS) {
      const i = txt.indexOf(`\n${s}\n`);
      if (i < 0) error(file, `missing the section "${s}"`);
      else if (i < last) error(file, `section out of order: "${s}"`);
      else last = i;
    }
  }
}

// 2. Relative links in every .md point to something that exists.
const mds = [];
const walk = d => { for (const n of readdirSync(d)) { if (n.startsWith('.') || n === 'node_modules' || n === 'build') continue;
  const p = join(d, n); if (statSync(p).isDirectory()) walk(p); else if (n.endsWith('.md')) mds.push(p); } };
walk(ROOT);
// A delivery file that does not exist yet (inside a step folder) is not an error: just "to be delivered".
const toDeliver = new Set();
const DELIVERY = /^(design|conteudo|dev)\/\d{2}-[^/]+\/(?!PASSO\.md$).+/;
for (const file of mds) {
  const txt = readFileSync(file, 'utf8').replace(/```[\s\S]*?```/g, '').replace(/`[^`\n]*`/g, '');
  for (const [, target] of txt.matchAll(/\]\(([^)\s]+)\)/g)) {
    if (/^(https?:|mailto:|#)/.test(target)) continue;
    const fullPath = resolve(dirname(file), decodeURIComponent(target.split('#')[0]));
    if (existsSync(fullPath)) continue;
    const rel = relative(ROOT, fullPath).replace(/\\/g, '/');
    if (DELIVERY.test(rel)) toDeliver.add(rel); else error(file, `broken link: ${target}`);
  }
}

// 3. File names in the step folders: lowercase, no accents, no spaces.
for (const area of Object.keys(AREAS)) {
  const walkNames = d => { for (const n of readdirSync(d)) { const p = join(d, n);
    if (n !== 'PASSO.md' && !/^[a-z0-9][a-z0-9._-]*$/.test(n)) error(p, 'name does not follow the standard (lowercase, no accents, no spaces)');
    if (statSync(p).isDirectory()) walkNames(p); } };
  walkNames(join(ROOT, area));
}

if (toDeliver.size) console.log(`📦 ${toDeliver.size} file(s) still to be delivered:\n- ` + [...toDeliver].sort().join('\n- '));
if (errors.length) { console.log(`❌ ${errors.length} problem(s):\n- ` + errors.join('\n- ')); process.exit(1); }
console.log('✅ Everything follows the standard.');
