# Pesquisa: dados reais da NASA + nome (13/11/2026)

> Fatos para o time DECIDIR amanhã. Regra do Space Apps: a IA não pode criar a ideia da solução.

## 1. Coisas reais que dá pra colecionar/cultivar
**Plantas que a NASA cultivou no espaço** (Veggie / Plant Habitat, na ISS)
- Alface "Outredgeous": 33 dias; os astronautas comeram pela 1ª vez em 10/08/2015 — https://www.nasa.gov/mission_pages/station/research/news/veggie
- Couve + alface Dragoon: ciclo de 28 dias, colhidas pro Thanksgiving em 2018 — https://www.nasa.gov/blogs/stationreport/2018/10/25/iss-daily-summary-report-10-25-2018/
- Rabanete: 27 dias (Kate Rubins colheu 20, em 2020) — https://space.com/nasa-astronaut-harvests-radishes-space-station
- Pimenta Hatch: ~4 meses → noite do taco, 29/10/2021 — https://www.nasa.gov/image-article/fresh-chiles-spice-up-taco-night/
- Zínia: um fungo atacou, Scott Kelly salvou as sobreviventes, e ela virou a 1ª flor a florescer no espaço (16/01/2016) — https://www.nasa.gov/image-article/first-flower-grown-space-stations-veggie-facility/
- Batata em solo que imita o de Marte — https://blogs.nasa.gov/kennedy/2016/08/18/growing-potatoes-in-martian-gardens/
- OSDR: OSD-267/268/269 (alface), OSD-412/413/414 (folhas), OSD-177 (fungo da zínia), OSD-766/767 (tomate), OSD-772 (pimenta) — https://osdr.nasa.gov/bio/repo/data/studies/OSD-267

**Minerais de Marte**
- "Blueberries" de hematita e jarosita (pistas de água, rover Opportunity) — https://www.jpl.nasa.gov/news/opportunity-rover-finds-strong-evidence-meridiani-planum-was-wet/
- Cristais de enxofre puro, amarelos (Curiosity, 30/05/2024) — https://www.space.com/nasa-mars-curiosity-sulfur-rocks
- "Manchas de leopardo" na rocha Cheyava Falls, possível sinal de vida (Nature, set/2025) — https://www.nasa.gov/news-release/nasa-says-mars-rover-discovered-potential-biosignature-last-year/

**Veículos e tecnologia**: Sojourner, Spirit, Opportunity, Curiosity, Perseverance, Ingenuity (72 voos, último em 18/01/2024), MOXIE, Kilopower.

## 2. Números reais para os 3 recursos
- **Energia**: Marte recebe no máximo 45% da luz do Sol que chega na Terra — https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf · A poeira derrubou o InSight de ~5.000 para ~500 Wh/sol, e ~275 durante uma tempestade — https://science.nasa.gov/resource/insights-power-generation-after-landing-and-spring-2022/ · O Opportunity parou de responder numa tempestade de poeira (jun/2018) — https://www.jpl.nasa.gov/news/opportunity-hunkers-down-during-dust-storm/ · Kilopower: 1–10 kWe — https://www.nasa.gov/directorates/spacetech/kilopower
- **Oxigênio**: o MOXIE fez 122 g de O₂ no total, o que um cachorro pequeno respira em 10 h; pico de 12 g/h, pureza 98%+ — https://www.nasa.gov/missions/mars-2020-perseverance/perseverance-rover/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/
- **Escudo**: na superfície, 0,67 mSv/dia (a viagem até Marte dá 1,8) — https://www.swri.org/press-release/swri-scientists-publish-first-radiation-measurements-surface-mars · Em 20/05/2024, uma tempestade solar deu 8.100 µGy = 30 raios-X de tórax; penhascos e cavernas de lava protegem — https://www.nasa.gov/solar-system/planets/mars/nasa-watches-mars-light-up-during-epic-solar-storm
- **Clima**: 1 sol = 24h39min · Cratera Gale: máxima de ~0 °C, mínima de ~−70 °C — https://science.nasa.gov/resource/steady-temperatures-at-mars-gale-crater

## 3. APIs (testadas em 13/11/2026)
| API | Status |
|---|---|
| DONKI CME / SEP / GST (api.nasa.gov) | ✅ funciona no navegador (CORS ok). Maio/2024: Kp 9 em 11/05 |
| DONKI FLR (explosões solares) | ❌ 404 hoje |
| Halloween 2003 | ❌ não está no DONKI → colocar no código |
| Mars Rover Photos API | ❌ morta (arquivada em out/2025) |
| Feed de imagens cruas do Perseverance | ✅ https://mars.nasa.gov/rss/api/?feed=raw_images&category=mars2020&feedtype=json (não oficial) |
| Feed de clima do Curiosity (REMS) | ✅ https://mars.nasa.gov/rss/api/?feed=weather&category=msl&feedtype=json (não oficial) |
| OSDR | ⚠️ o navegador bloqueia (CORS) → baixar o JSON e embutir no jogo |
| Mars Trek tiles | ✅ https://trek.nasa.gov/tiles/apidoc/trekAPI.html?body=mars |
| DEMO_KEY | ⚠️ limite minúsculo → pedir chave grátis em api.nasa.gov + guardar respostas em cache |

## 4. Nome "Mike"
- Contra: "Mike the Planet Miner" (iOS, 2024), um robô que minera no espaço e tem conceito colado no nosso — https://apps.apple.com/app/id912321344 · Mike Wazowski segue vivo nos memes (mascote verde ou de 1 olho = cópia) — https://knowyourmeme.com/memes/do-you-know-mike-wazowski-prank · Ninguém acha na busca · Não lembra Marte.
- A favor: 1 sílaba, global, não é infantil, e "Mike" = letra M no alfabeto da OTAN (M de Marte).
- Opções sem conflito encontrado: Mikrob/Mik, Marslings, Fobo & Dimo, Base Mike. Evitar: Rovo, "Mars Base", Moxie (robô infantil que faliu em 2024), Capi (mercado lotado).
- Para nomes globais: evitar P/V (o árabe não tem) e começo com Sp/St (vira "esp" em PT/ES) — https://sll.ku.edu/sites/sll/files/images/ml.17014.alj.pdf
