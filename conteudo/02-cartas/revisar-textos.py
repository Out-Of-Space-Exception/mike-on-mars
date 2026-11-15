"""Apply the documented card review, preserving CSV schema, IDs and order."""
from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parent
if (ROOT / 'alteracoes-revisao.csv').exists():
    raise FileExistsError('Revisao ja registrada; nao sobrescrever o historico antes/depois.')
path = ROOT / 'cartas.csv'
with path.open(encoding='utf-8', newline='') as f:
    reader = csv.DictReader(f)
    fields = reader.fieldnames
    rows = list(reader)
before = [r.copy() for r in rows]

# Each tuple is PT, EN, ES, FR. Scientific corrections are synchronized.
facts = {
3: ('Astronautas já cultivaram e colheram couve no Veggie, a horta da Estação Espacial.',
    'Astronauts have grown and harvested kale in Veggie, the Space Station garden.',
    'Los astronautas han cultivado y cosechado col rizada en Veggie, el huerto de la Estación Espacial.',
    "Des astronautes ont cultivé et récolté du chou kale dans Veggie, le potager de la Station spatiale."),
4: ('Com a mesma luz, a batata pode dar o dobro de comida de algumas culturas de sementes, segundo um cientista da NASA.',
    'With the same light, potatoes could yield twice as much food as some seed crops, says a NASA scientist.',
    'Con la misma luz, la papa podría dar el doble de alimento que algunos cultivos de semillas, según un científico de la NASA.',
    "Avec la même lumière, la pomme de terre pourrait donner deux fois plus de nourriture que certaines cultures à graines, selon un scientifique de la NASA."),
10: ('As manchas da rocha Cheyava Falls podem ser pistas de vida antiga, mas isso ainda não foi confirmado.',
     'The spots in Cheyava Falls may be clues to ancient life, but this has not been confirmed.',
     'Las manchas de Cheyava Falls podrían ser pistas de vida antigua, pero eso aún no está confirmado.',
     "Les taches de Cheyava Falls pourraient être des indices de vie ancienne, mais cela n'est pas encore confirmé."),
11: ('Na superfície de Marte, a luz solar chega a no máximo 45% do valor típico na Terra, segundo um estudo da NASA.',
     'At the surface of Mars, sunlight reaches at most 45% of typical Earth levels, according to a NASA study.',
     'En la superficie de Marte, la luz solar alcanza como máximo el 45% del valor típico en la Tierra, según un estudio de la NASA.',
     "À la surface de Mars, la lumière solaire atteint au plus 45 % du niveau habituel sur Terre, selon une étude de la NASA."),
19: ('Um dia em Marte se chama sol e dura cerca de 24 horas e 39 minutos.',
     'A day on Mars is called a sol and lasts about 24 hours and 39 minutes.',
     'Un día en Marte se llama sol y dura unas 24 horas y 39 minutos.',
     "Un jour sur Mars s'appelle un sol et dure environ 24 heures et 39 minutes."),
20: ('O Curiosity mediu em Gale cerca de 0 °C de dia e −70 °C à noite.',
     'Curiosity measured about 0 °C by day and −70 °C at night in Gale.',
     'Curiosity midió en Gale unos 0 °C de día y −70 °C de noche.',
     'Curiosity a mesuré à Gale environ 0 °C le jour et −70 °C la nuit.'),
21: ('Com o acúmulo de poeira, a energia diária do InSight caiu de cerca de 5.000 para 500 Wh por sol.',
     "As dust built up, InSight's daily energy fell from about 5,000 to 500 Wh per sol.",
     'Al acumularse polvo, la energía diaria de InSight bajó de unos 5000 a 500 Wh por sol.',
     "Avec la poussière accumulée, l'énergie quotidienne d'InSight est passée d'environ 5 000 à 500 Wh par sol."),
23: ('Na tempestade de 20/05/2024, o Curiosity mediu uma dose de radiação equivalente a 30 radiografias de tórax.',
     'During the storm on May 20, 2024, Curiosity measured a radiation dose equal to 30 chest X-rays.',
     'En la tormenta del 20/05/2024, Curiosity midió una dosis de radiación equivalente a 30 radiografías de tórax.',
     'Pendant la tempête du 20/05/2024, Curiosity a mesuré une dose de rayonnement équivalente à 30 radiographies du thorax.'),
27: ('O solo de Gale contém olivina e tem minerais parecidos com os de solos vulcânicos do Havaí.',
     "Gale's soil contains olivine and has minerals like those in volcanic soils in Hawaii.",
     'El suelo de Gale contiene olivino y tiene minerales parecidos a los de suelos volcánicos de Hawái.',
     "Le sol de Gale contient de l'olivine et des minéraux semblables à ceux des sols volcaniques d'Hawaï."),
30: ('Rios e lagos existiram em Gale em alguma época entre cerca de 3,8 e 3,3 bilhões de anos atrás.',
     'Rivers and lakes existed in Gale sometime between about 3.8 and 3.3 billion years ago.',
     'En Gale hubo ríos y lagos en algún momento entre hace unos 3800 y 3300 millones de años.',
     "Des rivières et des lacs existaient à Gale à une époque située entre environ 3,8 et 3,3 milliards d'années."),
32: ('Óxidos de manganês são uma pista de que Marte pode ter tido mais oxigênio no ar.',
     'Manganese oxides are a clue that Mars may once have had more oxygen in its air.',
     'Los óxidos de manganeso son una pista de que Marte pudo tener más oxígeno en el aire.',
     "Les oxydes de manganèse sont un indice que Mars a pu avoir plus d'oxygène dans son air."),
34: ('Em 2013, uma amostra de John Klein revelou que Gale já teve condições para abrigar micróbios.',
     'In 2013, a sample from John Klein showed that Gale once had conditions that could support microbes.',
     'En 2013, una muestra de John Klein reveló que Gale tuvo condiciones para albergar microbios.',
     'En 2013, un échantillon de John Klein a révélé que Gale avait eu des conditions permettant la vie de microbes.'),
36: ('Em 2025, cientistas anunciaram moléculas com 10 a 12 átomos de carbono numa amostra de Cumberland, coletada pelo Curiosity.',
     'In 2025, scientists reported molecules with 10 to 12 carbon atoms in a Cumberland sample collected by Curiosity.',
     'En 2025, científicos anunciaron moléculas con 10 a 12 átomos de carbono en una muestra de Cumberland recogida por Curiosity.',
     'En 2025, des scientifiques ont annoncé des molécules de 10 à 12 atomes de carbone dans un échantillon de Cumberland prélevé par Curiosity.'),
37: ('Marte tem duas luas, e Fobos dá cerca de três voltas no planeta por dia.',
     'Mars has two moons, and Phobos goes around the planet about three times a day.',
     'Marte tiene dos lunas, y Fobos da unas tres vueltas al planeta por día.',
     'Mars a deux lunes, et Phobos fait environ trois fois le tour de la planète par jour.'),
39: ('O Curiosity fotografou a Terra e a Lua como pequenos pontos brilhantes no céu de Marte.',
     'Curiosity photographed Earth and the Moon as tiny bright points in the sky of Mars.',
     'Curiosity fotografió la Tierra y la Luna como pequeños puntos brillantes en el cielo de Marte.',
     'Curiosity a photographié la Terre et la Lune comme de petits points brillants dans le ciel de Mars.'),
40: ('No experimento VEG-05 na Estação Espacial, 12 tomates amadureceram, mas os astronautas não puderam prová-los.',
     'In the VEG-05 experiment on the Space Station, 12 tomatoes ripened, but astronauts could not taste them.',
     'En el experimento VEG-05 en la Estación Espacial, maduraron 12 tomates, pero los astronautas no pudieron probarlos.',
     "Dans l'expérience VEG-05 à la Station spatiale, 12 tomates ont mûri, mais les astronautes n'ont pas pu les goûter."),
41: ('Uma rocha de cerca de 40 cm de comprimento, ao lado da areia que o Curiosity coletou para estudar.',
     'A rock about 40 cm long, beside the sand Curiosity scooped up to study.',
     'Una roca de unos 40 cm de largo, junto a la arena que Curiosity recogió para estudiar.',
     "Une roche d'environ 40 cm de long, à côté du sable que Curiosity a prélevé pour l'étudier."),
}
sources = {
1: 'https://www.nasa.gov/wp-content/uploads/2019/04/veggie_fact_sheet_508.pdf',
5: 'https://www.nasa.gov/humans-in-space/zinnias-from-space-nasa-studies-the-multiple-benefits-of-gardening/',
7: 'https://www.jpl.nasa.gov/images/pia19113-martian-concretions-near-fram-crater/',
16: 'https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/',
20: 'https://science.nasa.gov/photojournal/steady-temperatures-at-mars-gale-crater/',
23: 'https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/',
28: 'https://science.nasa.gov/resource/high-dune-is-first-martian-dune-studied-up-close-2/',
40: 'https://www.nasa.gov/missions/station/nasa-teams-persevere-through-plant-challenges-in-space/',
}
pending = {
21: 'foto atual de Melas nao mostra o InSight; substituir pela PIA25286 e atualizar credito',
22: 'foto atual nao mostra a limpeza do Spirit em 2009; escolher registro PIA11798/PIA11799 ou identificar foto ilustrativa',
29: 'rever ceu extrapolado identificado na conferencia anterior; usar somente pixels da foto oficial',
32: 'recorte corta parte do detalhe de Windjana; reenquadrar preservando o material analisado',
39: 'Terra e Lua pouco legiveis no enquadramento atual; alternativa 39 permanece opcional',
}
reserve = {7, 8, 10, 17, 18}
for row in rows:
    i = int(row['id'])
    if i in facts:
        for language, value in zip(('pt', 'en', 'es', 'fr'), facts[i]):
            row[f'fato_{language}'] = value
    if i in sources:
        row['fonte'] = sources[i]
    if i == 3:
        row['numero_real'] = 'cultivo e colheita de couve no Veggie; sem data no fato'
    if i == 11:
        row['numero_real'] = 'ate 45% do fluxo solar tipico terrestre na superficie; varia com local e estacao'
    if i == 20:
        row['numero_real'] = 'cerca de 0 °C de dia e −70 °C a noite; medidas de agosto/2012 a fevereiro/2013'
    if i == 33:
        row['numero_real'] = 'menos de 0,1% de boro no veio Catabola; nao cerca de 0,1% da rocha toda'
    if i == 36:
        row['numero_real'] = '10, 11 e 12 atomos de carbono; anuncio de 24/03/2025; amostra coletada em 2013'
    row['status'] = ('RESERVA: fora das 36 cartas do jogo; revisao visual necessaria antes de reativar' if i in reserve
                     else 'CONFERIR: ' + pending[i] if i in pending else 'ok')

assert fields == list(rows[0])
assert [r['id'] for r in before] == [r['id'] for r in rows]
assert len(rows) == 41
with path.open('w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    writer.writerows(rows)
with (ROOT / 'alteracoes-revisao.csv').open('w', encoding='utf-8', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'campo', 'antes', 'depois'])
    for old, new in zip(before, rows):
        for key in fields:
            if old[key] != new[key]:
                w.writerow([new['id'], key, old[key], new[key]])
print(f'{len(facts)} textos revisados nos quatro idiomas; {sum(r["status"] == "ok" for r in rows)} cartas ok; {len(pending)} fotos pendentes; {len(reserve)} reservas.')
