// Copia o conteúdo das duplas para dentro do jogo. Nunca edite jogo/data/ à mão: rode este script.
// Uso (na raiz do repositório): node ferramentas/sincronizar.mjs
//  - conteudo/03-textos/textos.csv  → jogo/data/textos.csv (idioma vazio = usa o inglês)
//    + o nome e o fato de cada carta viram as chaves CARD_<id>_NAME e CARD_<id>_FACT
//  - conteudo/02-cartas/cartas.csv  → jogo/data/cartas.json (o resto dos dados das cartas)
//  - conteudo/01-sons/sons/*         → jogo/sounds/
//  - conteudo/02-cartas/fotos/*      → jogo/ui/cards/
import {readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, copyFileSync} from 'node:fs';
import {join, dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const RAIZ = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const LANGS = ['pt_BR', 'en', 'es', 'fr'];
const parse = t => { const rows = []; let r = [], f = '', q = false;
  for (let i = 0; i < t.length; i++) { const c = t[i];
    if (q) { if (c === '"') { if (t[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += c; }
    else if (c === '"') q = true; else if (c === ',') { r.push(f); f = ''; }
    else if (c === '\n') { r.push(f); rows.push(r); r = []; f = ''; } else if (c !== '\r') f += c; }
  if (f || r.length) { r.push(f); rows.push(r); } return rows.filter(x => x.some(v => v !== '')); };
const esc = v => /[",\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
const objetos = rows => rows.slice(1).map(r => Object.fromEntries(rows[0].map((h, i) => [h, r[i] ?? ''])));

// 1. Textos (+ textos das cartas)
const textos = objetos(parse(readFileSync(join(RAIZ, 'conteudo/03-textos/textos.csv'), 'utf8')));
const cartas = objetos(parse(readFileSync(join(RAIZ, 'conteudo/02-cartas/cartas.csv'), 'utf8')));
const linhas = [['keys', ...LANGS].join(',')];
const add = (key, porIdioma) => {
  const en = porIdioma.en || porIdioma.pt_BR || key;
  linhas.push([key, ...LANGS.map(l => porIdioma[l] || en)].map(esc).join(','));
};
for (const t of textos) add(t.keys, t);
for (const c of cartas) {
  add(`CARD_${c.id}_NAME`, {pt_BR: c.nome_pt, en: c.nome_en, es: c.nome_es, fr: c.nome_fr});
  add(`CARD_${c.id}_FACT`, {pt_BR: c.fato_pt, en: c.fato_en, es: c.fato_es, fr: c.fato_fr});
}
mkdirSync(join(RAIZ, 'jogo/data'), {recursive: true});
writeFileSync(join(RAIZ, 'jogo/data/textos.csv'), linhas.join('\n') + '\n');

// 2. Dados das cartas (sem os textos, que já estão no textos.csv)
const dados = cartas.map(c => ({
  id: Number(c.id), category: c.categoria, rarity: c.raridade, how: c.como_ganha, place: c.onde,
  number: c.numero_real, source: c.fonte, photo: c.foto_nasa,
  locked: /em breve/i.test(c.onde),
}));
writeFileSync(join(RAIZ, 'jogo/data/cartas.json'), JSON.stringify(dados, null, 1) + '\n');

// 3. Sons e fotos (só se a pasta já existir)
const copiar = (de, para) => {
  const origem = join(RAIZ, de);
  if (!existsSync(origem)) return 0;
  mkdirSync(join(RAIZ, para), {recursive: true});
  let n = 0;
  for (const f of readdirSync(origem)) if (/\.(ogg|wav|jpg|png)$/i.test(f)) { copyFileSync(join(origem, f), join(RAIZ, para, f)); n++; }
  return n;
};
const sons = copiar('conteudo/01-sons/sons', 'jogo/sounds');
const fotos = copiar('conteudo/02-cartas/fotos', 'jogo/ui/cards');

// 4. O Mike do design/01 (o mike.glb já traz as animações idle, run e jump)
mkdirSync(join(RAIZ, 'jogo/models/mike'), {recursive: true});
let mike = 0;
for (const f of ['mike.glb']) {
  const de = join(RAIZ, 'design/01-mike', f);
  if (existsSync(de)) { copyFileSync(de, join(RAIZ, 'jogo/models/mike', f)); mike++; }
}

// 5. O nome da foto de cada carta (NN-nome.jpg), se já existir
const fotosNoJogo = existsSync(join(RAIZ, 'jogo/ui/cards')) ? readdirSync(join(RAIZ, 'jogo/ui/cards')) : [];
for (const d of dados) d.photo_file = fotosNoJogo.find(f => f.startsWith(String(d.id).padStart(2, '0') + '-')) || '';
writeFileSync(join(RAIZ, 'jogo/data/cartas.json'), JSON.stringify(dados, null, 1) + '\n');
console.log(`textos: ${textos.length} + ${cartas.length * 2} das cartas · cartas: ${dados.length} · sons: ${sons} · fotos: ${fotos} · mike: ${mike} arquivo(s)`);

// 6. Tela de carregamento e fonte do design/05 (a página web usa a nave e a fonte; o jogo usa a fonte)
const carregamento = join(RAIZ, 'design/05-telas/carregamento');
mkdirSync(join(RAIZ, 'jogo/web'), {recursive: true});
mkdirSync(join(RAIZ, 'jogo/ui/fonts'), {recursive: true});
for (const f of ['nave.png', 'rubik.ttf']) if (existsSync(join(carregamento, f))) copyFileSync(join(carregamento, f), join(RAIZ, 'jogo/web', f));
if (existsSync(join(carregamento, 'rubik.ttf'))) copyFileSync(join(carregamento, 'rubik.ttf'), join(RAIZ, 'jogo/ui/fonts/rubik.ttf'));
