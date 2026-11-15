"""Check Content's handoff without editing the game or its generated files."""
from pathlib import Path
import collections
import csv
import io
import re
import subprocess

root=Path(__file__).resolve().parents[2]
relative='conteudo/03-textos/textos.csv'
current=(root/relative).read_text(encoding='utf-8-sig')
baseline=subprocess.run(['git','show',f'HEAD:{relative}'],cwd=root,check=True,capture_output=True).stdout.decode('utf-8-sig')
old=list(csv.DictReader(io.StringIO(baseline)))
rows=list(csv.DictReader(io.StringIO(current)))
assert current.splitlines()[0]==baseline.splitlines()[0]
assert [r['keys'] for r in rows]==[r['keys'] for r in old]
assert len({r['keys'] for r in rows})==len(rows)==187
markers=lambda text: collections.Counter(re.findall(r'\{[^{}]+\}',text))
for row,before in zip(rows,old):
    for lang in ['pt_BR','en','es','fr']:
        assert row[lang].strip(),(row['keys'],lang,'empty')
        assert '\ufffd' not in row[lang],(row['keys'],lang,'encoding')
        assert markers(row[lang])==markers(before[lang])==markers(row['en']),(row['keys'],lang,'markers')
        if row['keys'].startswith('BTN_'):
            assert len(row[lang].split())==1,(row['keys'],lang,'button length')
cards_path=root/'conteudo/02-cartas/cartas.csv'
with cards_path.open(encoding='utf-8-sig',newline='') as handle:
    cards=list(csv.DictReader(handle))
assert len(cards)==41 and len({r['id'] for r in cards})==41
for card in cards:
    for lang in ['pt','en','es','fr']:
        for field in ['nome','fato']:
            assert card[f'{field}_{lang}'].strip(),(card['id'],lang,field)
    for name in ['MOXIE','Ingenuity','Curiosity','Perseverance','Opportunity','InSight']:
        if name in card['fato_en']:
            assert all(name in card[f'fato_{lang}'] for lang in ['pt','es','fr']),(card['id'],name)
credits=list(csv.DictReader((root/'creditos.csv').open(encoding='utf-8-sig',newline='')))
page=(root/'conteudo/06-pagina-do-projeto/pagina.md').read_text(encoding='utf-8')
ai_section=page.split('## Use of AI\n')[1].split('## References\n')[0]
reference_section=page.split('## References\n')[1]
assert len(re.findall(r'^- Credit \d+:',reference_section,re.M))==len(credits)
assert len(re.findall(r'^- Credit \d+:',ai_section,re.M))==sum(r['tipo']=='ia' for r in credits)
for i,row in enumerate(credits):
    assert f'Credit {i+1:03d}:' in reference_section
    assert row['link'] in reference_section
    if row['tipo']=='ia': assert f'Credit {i+1:03d}:' in ai_section
sections=re.findall(r'^## (.+)$',page,re.M)
assert sections==['High-level project summary','Detailed project description','NASA data','Space Agency Partner and other data','Use of AI','References']
print(f'OK: 187 keys, four complete languages, unchanged placeholders, one-word BTN labels, 41 translated card rows, {len(credits)} references and all AI disclosures.')
