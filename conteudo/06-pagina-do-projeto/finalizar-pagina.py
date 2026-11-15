"""Render the full English disclosures from the repository credit register.

Labels below translate existing entries. Authors, URLs and license identifiers
remain those supplied by the credited team. This does not verify licenses.
"""
from pathlib import Path
import csv
import json
import re

root = Path(__file__).resolve().parents[2]
folder = Path(__file__).resolve().parent
credits_path = root/'creditos.csv'
description = 'OpenAI Codex: revisao final dos 187 textos e traducoes em quatro idiomas; pagina inglesa com referencias e usos de IA completos; verificacao de chaves e marcadores'
with credits_path.open(encoding='utf-8-sig',newline='') as handle:
    reader=csv.DictReader(handle)
    fields=reader.fieldnames
    credits=list(reader)
if not any(r['o_que']==description for r in credits):
    credits.append(dict(zip(fields,['ia',description,'conteudo/03-textos/; conteudo/05-traducoes/; conteudo/06-pagina-do-projeto/','OpenAI','nao se aplica','https://openai.com/codex','Conteudo'])))
    with credits_path.open('w',encoding='utf-8',newline='') as handle:
        writer=csv.DictWriter(handle,fields,lineterminator='\n')
        writer.writeheader()
        writer.writerows(credits)

# One label for each non-photo entry in the current register. Fail rather than
# silently omit new team disclosures. Numbering is the CSV data-row position.
labels={
0:'OpenAI Codex: organized the Redmi Note 11S reports and checklist; no independent reproduction',
1:'Godot Engine 4.7.2: game engine',
2:'DONKI: archived space weather data used for solar events',
3:'Rubik: interface font',
4:'Claude: proposed the palette and font and checked contrast',
5:'Animated Characters Protagonists: Mike model, with team modifications',
6:"Claude: repainted Mike, modeled his hair and prepared his render",
7:'Blender 5.3: 3D modeling',
8:'Food Kit: plant models',
9:'Nature Kit: plant, rock and flower-pot models',
10:'Space Kit: machines, rocks and antenna models',
11:'Skyboxes: base sky',
12:'Claude: helped choose items and modeled the solar panel, flag and string lights',
13:'Claude: repainted hematite, sulfur, MOXIE and the flower pot and made the leopard-spot texture and chile plant',
14:'Space Kit craft_speederA: loading-screen spaceship',
15:'Claude: created the loading screen, Mars shader and spaceship trail',
16:'Game Icons: wrench, target, menu and home icons',
17:'Claude: built seven screen mockups and rendered Mike and the base',
18:'Kenney Interface Sounds: interface and gameplay sound effects',
19:'Kenney Sci-Fi Sounds: construction, alert, shield and helicopter effects',
20:'Magic Space: aurora sound',
21:'Mars Ingenuity Helicopter 3D Model: companion helicopter',
22:'Happy Lullaby (song17): background music',
23:'Audacity 4.0.2: audio editing and conversion',
24:'Gemini: selected and organized CC0 sound effects and assisted text and pitch review',
25:'Game Icons Expansion: oxygen icon',
26:'Board Game Icons: shield, greenhouse and album icons',
27:'Game Icons: energy, exploration, construction and photo icons',
28:'Claude: modeled lettuce and kale',
29:'Modular Dungeon Kit: repainted terrain and walls',
30:"Claude: modeled Mike's house and repainted the walls",
31:"Claude: modeled three levels of Mike's house, greenhouse and solar panel",
32:"Claude: combined Mike's animations and helped choose button icons",
33:'Claude: made the Mars sky, ground texture, cratered terrain and dust effect',
34:'Claude: modeled three levels of MOXIE, RTG, antenna, landing pad and decorations',
35:'Junegull: logo font, used as a rendered image',
36:'Claude: revised the logo title with Junegull and removed the space background',
37:'Claude: created four card frames with code',
38:'Claude: modeled Kilopower',
39:"Claude: created Mike's astronaut helmet, collar, backpack and suit texture",
40:'Claude: checked NASA sources for twelve cards and revised unsupported facts',
41:'ChatGPT: researched sources and photos, prepared downloads and crops, composed real moon photos and made previews',
83:'Claude: drafted the seven slide texts with the team',
84:'Claude: translated the interface texts into Spanish and French',
85:'Claude: drafted the project page with the team',
86:"Claude: created Mike's construction animation and block-building effect",
87:'Claude: created the building information panels, scripts and texts',
88:'Kenney Flag Pack: language flags',
89:'Claude: created the language menu with flags',
95:'Claude: modeled discovery rocks and assembled five card layouts',
96:'Furniture Kit: modified exhibition shelf',
97:'Space Station Kit: exhibition shelf base and display',
98:'Claude: modeled the exhibition shelf, implemented its zoom and capacity and wrote four-language text; tested in a game copy',
99:'Claude: made the app icon with a Mike render and a Mars illustration',
100:'Claude: revised sulfur and oriented discovery rocks for the shelf',
101:'OpenAI Codex: checked photo sources and credits for cards 1–40 and documented isolated-material and event searches',
103:'OpenAI Codex: drafted a 29-second pitch with English captions and capture directions',
104:'OpenAI Codex: assembled a reference video from repository images and captions; no simulated interface',
106:'Microsoft pt-BR-FranciscaNeural via edge-tts: Portuguese reference voice; OpenAI Codex: script and timing',
107:'OpenAI Codex: prepared an adult human-narration guide and translated captions; no human voice recorded',
108:'OpenAI Codex: revised the English pitch; Microsoft en-US-AriaNeural via edge-tts: reference narration',
109:'OpenAI Codex: drafted pitch script 2 with team introduction, gameplay, data, choice and benefit',
110:'Magic Spell SFX: magical_3.ogg converted to WAV for opening sample tubes',
111:'Claude: converted and replaced the sample-tube sound',
112:'Claude: shortened exploration labels in four languages and implemented album scrolling',
113:'Claude: adapted event messages to available buildings and tested in a game copy',
114:'Claude: revised hematite, John Klein rock, manganese oxide and meteorite models',
115:'Pillow: reference-video image composition',
116:'imageio-ffmpeg: reference-video encoding wrapper',
117:'FFmpeg: H.264 and AAC encoding for reference videos',
118:'edge-tts: reference narration tool; its code license does not establish voice-output terms',
119:'Microsoft en-US-AndrewMultilingualNeural via edge-tts: selected English voice, tested with approved script 2',
120:'OpenAI Codex: prepared the script-2 capture plan and reviewed credits and AI disclosures',
121:'OpenAI Codex: drafted and laid out seven support slides with real captures and NASA sources; translated to Portuguese and exported PDF/PPTX',
123:'OpenAI Codex: reviewed science and wording across 41 card rows in four languages and recorded visual issues',
124:'OpenAI Codex: resolved photos 21 and 22, cropped the detail in 32, selected option 39 and clarified NASA mosaic 29; no synthesized photo pixels',
125:'OpenAI Codex: aligned cards, support slides, project page and capture plan with current seed and exploration rules',
126:'OpenAI Codex: reviewed 187 interface texts in four languages and completed this English page, references and AI disclosures',
}
cards=list(csv.DictReader((root/'conteudo/02-cartas/cartas.csv').open(encoding='utf-8-sig',newline='')))
names={int(r['id']):r['nome_en'] for r in cards}
extra_photos={82:'Deimos source for the two-moon composition',90:'White veins: Design source image',91:'Rocknest 3: Design source image',92:'Manganese oxide: Design source image',93:'John Klein rock: Design source image',94:'Lebanon meteorite: Design source image',102:'Earth seen from Mars: alternative crop, PIA17935',105:'Sulfur PIA26309: reference-video storyboard',122:'Rocknest 3: Content delivery photograph'}
def english_label(i,row):
    if i in labels:
        return labels[i]
    if i in extra_photos:
        return extra_photos[i]
    if row['tipo']=='foto':
        match=re.search(r'fotos/(\d+)-',row['arquivo_ou_uso'])
        if match:
            return names[int(match[1])]+': NASA photograph'+(' (Phobos source for the two-moon composition)' if i==78 else '')
    raise ValueError(f'Missing English disclosure for credit row {i+1}')

def license_label(value):
    if value in ['-', 'nao se aplica', 'não se aplica']:
        return 'not applicable (AI assistance)'
    if value=='dado público da NASA': return 'NASA public data'
    if value=='imagem publica da NASA (com credito)': return 'NASA public imagery, with credit'
    if value=='uso livre com crédito (diretrizes de mídia da NASA)': return 'free use with credit under NASA media guidelines'
    if value.startswith('Larabie Fonts Freeware EULA:'): return 'Larabie Fonts Freeware EULA; rendered logo only; Design approved the project-rule exception'
    if value.startswith('CONFERIR'): return 'TO CHECK: voice-output terms; tool or team approval does not establish these terms'
    if value=='GPL-3.0-or-later (build consultado por -L)': return 'GPL-3.0-or-later (encoding build used)'
    if value=='LGPLv3 (codigo da ferramenta)': return 'LGPLv3 (tool code)'
    return value

assert len(credits)==127, 'Credit register changed: review every new entry before rendering.'
items=[english_label(i,r) for i,r in enumerate(credits)]
page=folder/'pagina.md'
text=page.read_text(encoding='utf-8')
events=json.loads((root/'jogo/data/donki.json').read_text(encoding='utf-8-sig'))['events']
cme=sum(e['kind']=='CME' for e in events)
assert len(events)==140 and cme==139
text=text.replace('140 archived DONKI WSA-ENLIL records from 2024 with modeled Mars impacts, downloaded from the NASA API (https://api.nasa.gov/).',
 '139 dates from archived 2024 DONKI WSA-ENLIL simulations with predicted arrivals at Mars, downloaded from the NASA API (https://api.nasa.gov/), plus the May 20, 2024 event documented by Curiosity. The bundled list has 140 entries. The importer keeps one entry per arrival date; this is not a count of 140 independently observed storms.')
text=text.replace('solar storms use dates from the archived records.', 'later solar storms use dates from the archived records.')
text=text.replace('**1. DONKI: real solar storms**','**1. DONKI: archived space weather**')
text=text.replace('**Tools**','**Tools**')
text=text.replace('**Benefits**','**Learning goals**')
text=text.replace('**Real trade-off:**','**Resource trade-off:**')
text=text.replace('Kids practice real mission choices: power vs. dust, shield vs. energy, plants vs. oxygen.', 'Kids practice simplified resource choices: power sources, shielding and growing food. We have not measured learning outcomes in a study.')
text=text.replace('None. All the data and facts in the game come from NASA.', 'No separate partner-agency dataset was added. NASA provides the space weather records, card facts and photographs, and the Ingenuity model. Non-NASA resources include Kenney models and icons, fonts, sound effects, music and software tools, listed in References.')
# Each scientific photo can have a different credit from its fact source.
deimos=credits[82]['link']
text=text.replace('**3. Ingenuity 3D model**', f'The Phobos and Deimos card combines two real NASA photographs. The separate [Deimos source]({deimos}) is also credited; the composition is not a single observation.\n\n**3. Ingenuity 3D model**') if 'The Phobos and Deimos card combines' not in text else text
text=text.replace('## Use of AI\n', '## Use of AI\n',1)
prefix=text.split('## Use of AI\n')[0]
ai=[f'- Credit {i+1:03d}: {items[i]}. Provider: {r["autor"]}. [Tool/source]({r["link"]}).' for i,r in enumerate(credits) if r['tipo']=='ia']
refs=[f'- Credit {i+1:03d}: {items[i]}. Author/provider: {r["autor"]}. License/status: {license_label(r["licenca"])}. [Source]({r["link"]}).' for i,r in enumerate(credits)]
text=prefix+'## Use of AI\n\n'
text+='We used Claude (Anthropic), Gemini (Google), OpenAI ChatGPT/Codex and Microsoft synthetic voices as itemized below. NASA photographs are real photographs; crops and the two-moon composition are documented. AI-generated visuals carry a visible "Made with AI" label.\n\n'
text+='The team selected the Andrew English voice. Francisca and Aria appear only in reference tests. Voice-output terms and final video timing remain to be checked before final publication. No human narration was recorded. Reference videos are concept edits and do not replace the final gameplay recording.\n\n'
text+='\n'.join(ai)+'\n\n## References\n\n'
text+='The following entries correspond one by one to [creditos.csv](https://github.com/Out-Of-Space-Exception/mike-on-mars/blob/main/creditos.csv). Historical assets, five reserve cards and narration tests remain disclosed; their inclusion does not mean they appear in the current playable game. License/status labels reflect the register supplied by the team.\n\n'
text+='\n'.join(refs)+'\n'
page.write_text(text,encoding='utf-8',newline='\n')
print(f'Page complete: {len(ai)} AI disclosures and {len(refs)} reference entries; 139 modeled dates plus the measured May 20 event.')
