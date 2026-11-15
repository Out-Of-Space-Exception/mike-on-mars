"""Read-only credit coverage and public URL availability audit."""
from pathlib import Path
import csv,concurrent.futures,urllib.request,urllib.error,json
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
def rows(path):
 with path.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))
credits=rows(ROOT/'creditos.csv')
def check(url):
 result={'link':url,'http':'','destino':url,'resultado':''}
 for method in ['HEAD','GET']:
  try:
   req=urllib.request.Request(url,method=method,headers={'User-Agent':'Mozilla/5.0 (credit-source-check)'})
   with urllib.request.urlopen(req,timeout=12) as response:
    result.update(http=response.status,destino=response.url,resultado='acessivel')
   return result
  except urllib.error.HTTPError as e:
   result.update(http=e.code,resultado='bloqueio ou erro HTTP; revisar manualmente')
  except Exception as e:
   result['resultado']=type(e).__name__+': '+str(e)[:160]
 return result
if __name__=='__main__':
 missing_fields=[]
 for i,c in enumerate(credits,2):
  for key,value in c.items():
   if not value or not value.strip():missing_fields.append({'linha':i,'campo':key})
 coverage={}
 for kind,folder in [('som','conteudo/01-sons/sons'),('foto','conteudo/02-cartas/fotos')]:
  files=list((ROOT/folder).glob('*'))
  missing=[p.name for p in files if p.is_file() and not any(c['tipo']==kind and p.name in c['arquivo_ou_uso'] for c in credits)]
  coverage[kind]={'arquivos':len(files),'sem_credito':missing}
 urls=sorted(set(c['link'] for c in credits if c['link'].startswith('https://')))
 with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:results=list(pool.map(check,urls))
 with (OUT/'links-conferidos.csv').open('w',encoding='utf-8',newline='') as f:
  writer=csv.DictWriter(f,fieldnames=['link','http','destino','resultado']);writer.writeheader();writer.writerows(results)
 summary={'linhas_creditos':len(credits),'campos_vazios':missing_fields,'cobertura':coverage,'links':len(urls),'links_acessiveis':sum(r['resultado']=='acessivel' for r in results)}
 print(json.dumps(summary,ensure_ascii=False))
 print(json.dumps([r for r in results if r['resultado']!='acessivel'],ensure_ascii=False))
