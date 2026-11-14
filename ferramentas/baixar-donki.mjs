// Baixa do DONKI (banco de clima espacial da NASA) as tempestades solares de 2024 que chegaram a Marte
// e salva em jogo/data/donki.json. Os dados são ARQUIVADOS (não ao vivo): rode até completar os 12 meses.
// Uso (na raiz do repositório): node ferramentas/baixar-donki.mjs [SUA_CHAVE]   (sem chave usa DEMO_KEY)
// - A chave NUNCA vai para o repositório nem para o jogo. Chave grátis em https://api.nasa.gov
// - Cada mês baixado fica guardado em ferramentas/.donki-cache/ (fora do Git). Se bater no limite
//   da DEMO_KEY (~30 pedidos por hora), rode de novo mais tarde: ele só baixa os meses que faltam.
import {writeFileSync, readFileSync, mkdirSync, existsSync} from 'node:fs';
import {join, dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const RAIZ = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const KEY = process.argv[2] || 'DEMO_KEY';
const BASE = 'https://api.nasa.gov/DONKI/WSAEnlilSimulations';
const CACHE = join(RAIZ, 'ferramentas/.donki-cache');
mkdirSync(CACHE, {recursive: true});

// O DONKI aceita no máximo 60 dias por pedido: baixa 2024 mês a mês.
const meses = Array.from({length: 12}, (_, m) => {
  const fimDoMes = new Date(Date.UTC(2024, m + 1, 0)).getUTCDate();
  const mm = String(m + 1).padStart(2, '0');
  return [`2024-${mm}-01`, `2024-${mm}-${fimDoMes}`, mm];
});
const faltando = [];
const eventos = new Map();
for (const [ini, fim, mm] of meses) {
  const arquivo = join(CACHE, `2024-${mm}.json`);
  if (!existsSync(arquivo)) {
    const res = await fetch(`${BASE}?startDate=${ini}&endDate=${fim}&api_key=${KEY}`);
    if (!res.ok) { faltando.push(`${mm} (erro ${res.status})`); continue; }
    writeFileSync(arquivo, await res.text());
  }
  for (const sim of JSON.parse(readFileSync(arquivo, 'utf8'))) {
    for (const imp of sim.impactList || []) {
      if (imp.location !== 'Mars' || !imp.arrivalTime) continue;
      const date = imp.arrivalTime.slice(0, 10);
      if (eventos.has(date)) continue;
      const cme = (sim.cmeInputs || [])[0] || {};
      eventos.set(date, {
        date, kind: 'CME', speed_kms: Math.round(cme.speed || 0), glancing: !!imp.isGlancingBlow,
        source: 'NASA DONKI (WSA-ENLIL)', link: sim.link || '',
      });
    }
  }
}
// A tempestade de 20/05/2024, medida pelo Curiosity na cratera Gale (fato da seção 6 do CONTEXTO.md).
eventos.set('2024-05-20', {
  date: '2024-05-20', kind: 'SEP', curiosity: true, source: 'NASA',
  link: 'https://www.nasa.gov/solar-system/planets/mars/nasa-watches-mars-light-up-during-epic-solar-storm',
});
const lista = [...eventos.values()].sort((a, b) => a.date.localeCompare(b.date));
writeFileSync(join(RAIZ, 'jogo/data/donki.json'), JSON.stringify({
  downloaded: new Date().toISOString().slice(0, 10),
  note: 'Dados arquivados de 2024, não ao vivo.',
  months_missing: faltando,
  events: lista,
}, null, 1) + '\n');
console.log(`${lista.length} tempestades que chegaram a Marte em 2024 → jogo/data/donki.json`);
if (faltando.length) console.log(`⚠️ Faltam os meses: ${faltando.join(', ')}. Rode de novo mais tarde (ou com uma chave grátis).`);
