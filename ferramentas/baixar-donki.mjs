// Downloads from DONKI (NASA's space weather database) the 2024 solar storms that reached Mars
// and saves them to jogo/data/donki.json. The data is ARCHIVED (not live): run it until all 12 months are done.
// Usage (from the repository root): node ferramentas/baixar-donki.mjs [YOUR_KEY]   (without a key it uses DEMO_KEY)
// - The key NEVER goes into the repository or the game. Free key at https://api.nasa.gov
// - Each downloaded month is kept in ferramentas/.donki-cache/ (outside Git). If you hit the DEMO_KEY
//   limit (~30 requests per hour), run it again later: it only downloads the missing months.
import {writeFileSync, readFileSync, mkdirSync, existsSync} from 'node:fs';
import {join, dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const KEY = process.argv[2] || 'DEMO_KEY';
const BASE = 'https://api.nasa.gov/DONKI/WSAEnlilSimulations';
const CACHE = join(ROOT, 'ferramentas/.donki-cache');
mkdirSync(CACHE, {recursive: true});

// DONKI accepts at most 60 days per request: downloads 2024 month by month.
const months = Array.from({length: 12}, (_, m) => {
  const monthEnd = new Date(Date.UTC(2024, m + 1, 0)).getUTCDate();
  const mm = String(m + 1).padStart(2, '0');
  return [`2024-${mm}-01`, `2024-${mm}-${monthEnd}`, mm];
});
const missing = [];
const events = new Map();
for (const [start, end, mm] of months) {
  const file = join(CACHE, `2024-${mm}.json`);
  if (!existsSync(file)) {
    const res = await fetch(`${BASE}?startDate=${start}&endDate=${end}&api_key=${KEY}`);
    if (!res.ok) { missing.push(`${mm} (error ${res.status})`); continue; }
    writeFileSync(file, await res.text());
  }
  for (const sim of JSON.parse(readFileSync(file, 'utf8'))) {
    for (const imp of sim.impactList || []) {
      if (imp.location !== 'Mars' || !imp.arrivalTime) continue;
      const date = imp.arrivalTime.slice(0, 10);
      if (events.has(date)) continue;
      const cme = (sim.cmeInputs || [])[0] || {};
      events.set(date, {
        date, kind: 'CME', speed_kms: Math.round(cme.speed || 0), glancing: !!imp.isGlancingBlow,
        source: 'NASA DONKI (WSA-ENLIL)', link: sim.link || '',
      });
    }
  }
}
// The 05/20/2024 storm, measured by Curiosity in Gale crater (fact from section 6 of CONTEXTO.md).
events.set('2024-05-20', {
  date: '2024-05-20', kind: 'SEP', curiosity: true, source: 'NASA',
  link: 'https://www.nasa.gov/solar-system/planets/mars/nasa-watches-mars-light-up-during-epic-solar-storm',
});
const list = [...events.values()].sort((a, b) => a.date.localeCompare(b.date));
writeFileSync(join(ROOT, 'jogo/data/donki.json'), JSON.stringify({
  downloaded: new Date().toISOString().slice(0, 10),
  note: 'Archived 2024 data, not live.',
  months_missing: missing,
  events: list,
}, null, 1) + '\n');
console.log(`${list.length} storms that reached Mars in 2024 → jogo/data/donki.json`);
if (missing.length) console.log(`⚠️ Missing months: ${missing.join(', ')}. Run it again later (or with a free key).`);
