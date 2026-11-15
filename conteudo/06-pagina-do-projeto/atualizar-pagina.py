"""Align the submission draft with the current repository sources."""
from pathlib import Path
import csv
import re
import json

root = Path(__file__).resolve().parents[2]
page = Path(__file__).with_name('pagina.md')
text = page.read_text(encoding='utf-8')
text = re.sub(r'(?<=## High-level project summary\n).*?(?=\n## Detailed)',
    "Mike on Mars is a free browser game where kids aged 7 to 12 practice running a Mars base. Players manage energy, oxygen and shielding, grow crops and collect discoveries with NASA photographs and sourced facts. Archived NASA DONKI records inspire solar storms that turn resource management into a mission choice.\n", text, flags=re.S)
text = text.replace('The greenhouse lights use energy.', 'Planting uses seeds, and the greenhouse lights use energy. Players start with lettuce seeds. Harvesting returns seeds; Earth packages bring more when an antenna is built.')
text = text.replace('Mike uses oxygen to explore and comes back with a sample tube.', 'Mike needs enough shielding and spends 30 oxygen to explore. Some searches return empty; others bring back a sample tube.')
text = text.replace('**Events** always have a bad side and a good side.', '**Events** change resources and can bring discoveries.')
text = text.replace('There is no timer.', 'Choices have no countdown.')
text = text.replace('Kids learn real mission names', 'Kids discover real mission names')
text = text.replace('They show on the map as "coming soon" and are not playable yet.', 'These are future ideas, outside the current playable Gale release.')
events = json.loads((root/'jogo/data/donki.json').read_text(encoding='utf-8-sig'))['events']
text = text.replace('140 solar storm events (WSA-ENLIL simulations) from 2024 that reached Mars', f'{len(events)} archived DONKI WSA-ENLIL records from 2024 with modeled Mars impacts')
text = text.replace('each solar storm in the game is a real 2024 event and shows its real date.', 'solar storms use dates from the archived records. Simulation outputs are not direct measurements of conditions at the base; resource costs and shielding are simplified game rules.')
cards = list(csv.DictReader((root/'conteudo/02-cartas/cartas.csv').open(encoding='utf-8-sig', newline='')))
active = [c for c in cards if 'em breve' not in c['onde'].lower()]
assert len(active)==36
sources = '\n'.join(f"  - {c['nome_en']}: [fact]({c['fonte']}); [photo]({c['foto_nasa']})." for c in active)
text = re.sub(r'(?<=- Sources, card by card:\n).*?(?=\n\*\*3\. Ingenuity)', sources+'\n',text,flags=re.S)
text = text.replace('NASA sources of the 40 card facts', 'NASA sources of the 36 active card facts and photographs')
text = text.replace('## Use of AI\n', '## Use of AI\n- OpenAI Codex: reviewed card science and translations, resolved photo sources, updated this draft and the Portuguese support slides to match the current seed and exploration rules. Gameplay captures are real screenshots, not generated scenes.\n') if 'reviewed card science and translations' not in text else text
page.write_text(text,encoding='utf-8',newline='\n')
slides = root/'conteudo/04-slides/slides.md'
text = slides.read_text(encoding='utf-8')
text = text.replace('ou na apresentação ao vivo', 'no arquivo editável')
text = text.replace('Construa uma base. Cultive. Explore e faça descobertas.', 'Cultive com sementes. Explore e faça descobertas.')
text = text.replace('Jogue no celular. Sem login. Sem baixar.', 'Receba sementes da Terra. Os pacotes precisam de antena.')
text = text.replace('Salve sua base e volte para continuar jogando.', 'Jogue no celular, sem login. A base fica salva no aparelho.')
text = text.replace('Construa, plante e explore para ampliar sua coleção.', 'Construa, plante e explore. Nem toda busca traz amostra.')
text = re.sub(r'Quantidade atual:.*?(?=\n)', 'Quantidade atual: 36 cartas ativas; cinco reservas fora do jogo. Fontes na revisão das cartas e no cartas.csv.',text)
text = text.replace('Imagem: captura-estufa-en.jpg, captura real', 'Imagem: captura-estufa-en.jpg, carta de tempestade sobre o painel da estufa; captura real')
slides.write_text(text,encoding='utf-8',newline='\n')
credits = root/'creditos.csv'
with credits.open(encoding='utf-8',newline='') as handle:
    rows=list(csv.reader(handle))
description='OpenAI Codex: compatibilidade das cartas e materiais de conteudo com sementes e exploracao atuais; revisao dos slides PT-BR e pagina inglesa; capturas reais do jogo'
if not any(len(r)>1 and r[1]==description for r in rows):
    rows.append(['ia',description,'conteudo/02-cartas/; conteudo/04-slides/; conteudo/06-pagina-do-projeto/; conteudo/08-cenas-e-creditos/','OpenAI','nao se aplica','https://openai.com/codex','Conteudo'])
    with credits.open('w',encoding='utf-8',newline='') as handle:
        csv.writer(handle,lineterminator='\n').writerows(rows)
print(f'Updated page with {len(active)} active cards and {len(events)} DONKI records; aligned slide text and AI disclosure.')
