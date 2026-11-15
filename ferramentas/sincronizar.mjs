// Copies the teams' content into the game. Never edit jogo/data/ by hand: run this script.
// Usage (from the repository root): node ferramentas/sincronizar.mjs
//  - conteudo/03-textos/textos.csv  → jogo/data/textos.csv (empty language = uses English)
//    + each card's name and fact become the keys CARD_<id>_NAME and CARD_<id>_FACT
//  - conteudo/02-cartas/cartas.csv  → jogo/data/cartas.json (the rest of the card data)
//  - conteudo/01-sons/sons/*         → jogo/sounds/
//  - conteudo/02-cartas/fotos/*      → jogo/ui/cards/
import {readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, copyFileSync} from 'node:fs';
import {join, dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const LANGS = ['pt_BR', 'en', 'es', 'fr'];
const parse = t => { const rows = []; let r = [], f = '', q = false;
  for (let i = 0; i < t.length; i++) { const c = t[i];
    if (q) { if (c === '"') { if (t[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += c; }
    else if (c === '"') q = true; else if (c === ',') { r.push(f); f = ''; }
    else if (c === '\n') { r.push(f); rows.push(r); r = []; f = ''; } else if (c !== '\r') f += c; }
  if (f || r.length) { r.push(f); rows.push(r); } return rows.filter(x => x.some(v => v !== '')); };
const esc = v => /[",\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
const toObjects = rows => rows.slice(1).map(r => Object.fromEntries(rows[0].map((h, i) => [h, r[i] ?? ''])));

// 1. Texts (+ the card texts)
const texts = toObjects(parse(readFileSync(join(ROOT, 'conteudo/03-textos/textos.csv'), 'utf8')));
const cardRows = toObjects(parse(readFileSync(join(ROOT, 'conteudo/02-cartas/cartas.csv'), 'utf8')));
const lines = [['keys', ...LANGS].join(',')];
const add = (key, byLang) => {
  const en = byLang.en || byLang.pt_BR || key;
  lines.push([key, ...LANGS.map(l => byLang[l] || en)].map(esc).join(','));
};
for (const t of texts) add(t.keys, t);
// Texts that come with a Design screen (e.g. the building info panel)
for (const screen of ['info-construcao', 'estante']) {
  const designTexts = join(ROOT, 'design/05-telas', screen, 'textos.csv');
  if (existsSync(designTexts)) for (const t of toObjects(parse(readFileSync(designTexts, 'utf8')))) add(t.keys, t);
}
for (const c of cardRows) {
  add(`CARD_${c.id}_NAME`, {pt_BR: c.nome_pt, en: c.nome_en, es: c.nome_es, fr: c.nome_fr});
  add(`CARD_${c.id}_FACT`, {pt_BR: c.fato_pt, en: c.fato_en, es: c.fato_es, fr: c.fato_fr});
}
mkdirSync(join(ROOT, 'jogo/data'), {recursive: true});
writeFileSync(join(ROOT, 'jogo/data/textos.csv'), lines.join('\n') + '\n');

// 2. Card data (without the texts, which are already in textos.csv). Cards from "coming soon" places stay out of the game.
// The game reads English ids; the Content team's sheet stays in Portuguese.
const CATEGORY = {'Plantas': 'plants', 'Minerais': 'minerals', 'Tecnologias': 'tech', 'Robôs': 'robots', 'Céu e clima': 'sky', 'Descobertas': 'discoveries'};
const RARITY = {'comum': 'common', 'raro': 'rare', 'épico': 'epic', 'lendário': 'legendary'};
const HOW = {'colher na estufa': 'harvest', 'tubo de amostra': 'tube', 'construir': 'build', 'explorar': 'explore', 'aguentar o evento': 'event'};
const cards = cardRows.filter(c => !/em breve/i.test(c.onde)).map(c => ({
  id: Number(c.id), category: CATEGORY[c.categoria] ?? c.categoria, rarity: RARITY[c.raridade] ?? c.raridade, how: HOW[c.como_ganha] ?? c.como_ganha, place: c.onde,
  number: c.numero_real, source: c.fonte, photo: c.foto_nasa,
}));
writeFileSync(join(ROOT, 'jogo/data/cartas.json'), JSON.stringify(cards, null, 1) + '\n');

// 3. Sounds and photos (only if the folder already exists)
const copyFiles = (from, to) => {
  const source = join(ROOT, from);
  if (!existsSync(source)) return 0;
  mkdirSync(join(ROOT, to), {recursive: true});
  let n = 0;
  for (const f of readdirSync(source)) if (/\.(ogg|wav|jpg|png)$/i.test(f)) { copyFileSync(join(source, f), join(ROOT, to, f)); n++; }
  return n;
};
const sounds = copyFiles('conteudo/01-sons/sons', 'jogo/sounds');
// Photos: only those of the cards that are in the game
const ids = new Set(cards.map(d => String(d.id).padStart(2, '0')));
let photos = 0;
if (existsSync(join(ROOT, 'conteudo/02-cartas/fotos'))) {
  mkdirSync(join(ROOT, 'jogo/ui/cards'), {recursive: true});
  for (const f of readdirSync(join(ROOT, 'conteudo/02-cartas/fotos'))) {
    if (/\.(jpg|png)$/i.test(f) && ids.has(f.slice(0, 2))) { copyFileSync(join(ROOT, 'conteudo/02-cartas/fotos', f), join(ROOT, 'jogo/ui/cards', f)); photos++; }
  }
}

// 4. Mike from design/01 (mike.glb already comes with the idle, run and jump animations)
mkdirSync(join(ROOT, 'jogo/models/mike'), {recursive: true});
let mike = 0;
for (const f of ['mike.glb', 'mike-astronauta.glb']) {
  const src = join(ROOT, 'design/01-mike', f);
  if (existsSync(src)) { copyFileSync(src, join(ROOT, 'jogo/models/mike', f)); mike++; }
}

// 5. The photo file name of each card (NN-name.jpg), if it already exists
const photosInGame = existsSync(join(ROOT, 'jogo/ui/cards')) ? readdirSync(join(ROOT, 'jogo/ui/cards')) : [];
for (const d of cards) d.photo_file = photosInGame.find(f => f.startsWith(String(d.id).padStart(2, '0') + '-')) || '';
writeFileSync(join(ROOT, 'jogo/data/cartas.json'), JSON.stringify(cards, null, 1) + '\n');
console.log(`texts: ${texts.length} + ${cardRows.length * 2} from cards · cards: ${cards.length} · sounds: ${sounds} · photos: ${photos} · mike: ${mike} file(s)`);

// 6. Loading screen and font from design/05 (the web page uses the ship and the font; the game uses the font)
const loading = join(ROOT, 'design/05-telas/carregamento');
mkdirSync(join(ROOT, 'jogo/web'), {recursive: true});
mkdirSync(join(ROOT, 'jogo/ui/fonts'), {recursive: true});
for (const f of ['nave.png', 'rubik.ttf']) if (existsSync(join(loading, f))) copyFileSync(join(loading, f), join(ROOT, 'jogo/web', f));
if (existsSync(join(loading, 'rubik.ttf'))) copyFileSync(join(loading, 'rubik.ttf'), join(ROOT, 'jogo/ui/fonts/rubik.ttf'));

// 7. Item models (design/03 and design/04), from Design's itens.csv → jogo/models/items/ + data/itens.json
const itemsCsv = join(ROOT, 'design/03-itens-do-jogo/itens.csv');
const items = {};
if (existsSync(itemsCsv)) {
  mkdirSync(join(ROOT, 'jogo/models/items'), {recursive: true});
  for (const it of toObjects(parse(readFileSync(itemsCsv, 'utf8')))) {
    const cited = (it.observacao.match(/design\/[\w\-/]+\.(glb|png)/) || [])[0];
    const kebab = it.arquivo_do_modelo.replace(/_/g, '-').replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
    const level1 = (it.observacao.match(/niveis\/[\w-]+-n1\.glb/) || [])[0];
    const candidates = [level1 && `design/03-itens-do-jogo/${level1}`, `design/03-itens-do-jogo/${it.arquivo_do_modelo}`, cited, `design/03-itens-do-jogo/kenney/${kebab}`].filter(Boolean);
    const found = candidates.find(c => existsSync(join(ROOT, c)));
    if (!found) continue;
    const name = found.split('/').pop();
    copyFileSync(join(ROOT, found), join(ROOT, 'jogo/models/items', name));
    items[it.item_do_jogo] = name;
  }
}
// The 3 levels (niveis/<item>-n1.glb, -n2, -n3) and each item's height (tamanhos.csv, with Mike = 2.2)
const levels = join(ROOT, 'design/03-itens-do-jogo/niveis');
if (existsSync(levels)) for (const f of readdirSync(levels)) if (f.endsWith('.glb')) copyFileSync(join(levels, f), join(ROOT, 'jogo/models/items', f));
// The display shelf and the discovery rocks (design/03: estante/ and descobertas/)
for (const [folder, which] of [['estante', /^estante\.glb$/], ['descobertas', /\.glb$/]]) {
  const dir = join(ROOT, 'design/03-itens-do-jogo', folder);
  if (!existsSync(dir)) continue;
  for (const f of readdirSync(dir)) if (which.test(f)) {
    copyFileSync(join(dir, f), join(ROOT, 'jogo/models/items', f));
    items[f.replace(/\.glb$/, '')] = f;
  }
}
const heights = {shelf: 1.8};
const sizesCsv = join(ROOT, 'design/03-itens-do-jogo/tamanhos.csv');
if (existsSync(sizesCsv)) {
  for (const t of toObjects(parse(readFileSync(sizesCsv, 'utf8')))) {
    if (t.chave_no_jogo && t.chave_no_jogo !== '-') heights[t.chave_no_jogo] = Number(t.altura);
  }
}
writeFileSync(join(ROOT, 'jogo/data/itens.json'), JSON.stringify({files: items, heights}, null, 1) + '\n');

// 7b. Card frames and the building info panel images (design/05)
mkdirSync(join(ROOT, 'jogo/ui/frames'), {recursive: true});
for (const f of readdirSync(join(ROOT, 'design/05-telas'))) if (/^moldura-carta-.*\.png$/.test(f)) copyFileSync(join(ROOT, 'design/05-telas', f), join(ROOT, 'jogo/ui/frames', f));
const info = join(ROOT, 'design/05-telas/info-construcao');
if (existsSync(info)) {
  mkdirSync(join(ROOT, 'jogo/ui/info-construcao'), {recursive: true});
  for (const f of readdirSync(info)) if (/^(item-.*|placa-titulo|ornamento-luas|ic-carta)\.png$/.test(f)) copyFileSync(join(info, f), join(ROOT, 'jogo/ui/info-construcao', f));
}

// 7c. Logo from design/06 (start screen)
if (existsSync(join(ROOT, 'design/06-logo-e-icone/logo.png'))) copyFileSync(join(ROOT, 'design/06-logo-e-icone/logo.png'), join(ROOT, 'jogo/ui/logo.png'));

// 8. Icons from design/05
const icons = join(ROOT, 'design/05-telas/telas-godot');
mkdirSync(join(ROOT, 'jogo/ui/icons'), {recursive: true});
if (existsSync(icons)) for (const f of readdirSync(icons)) if (/^ic-.*\.png$/.test(f) || f === 'mike.png') copyFileSync(join(icons, f), join(ROOT, 'jogo/ui/icons', f));
console.log(`item models: ${Object.keys(items).length} (${Object.keys(items).join(', ')})`);
