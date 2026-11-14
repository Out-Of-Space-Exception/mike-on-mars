# Conteúdo · 02 · As cartas

> **Em 1 frase:** conferir o fato, a fonte da NASA e a foto real de cada uma das 25 cartas.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada
- **Quem usa depois:** [conteudo/03-textos](../../conteudo/03-textos/PASSO.md), [conteudo/05-traducoes](../../conteudo/05-traducoes/PASSO.md), [dev/06-receber-entregas](../../dev/06-receber-entregas/PASSO.md)

## Por que importa
As cartas são o prêmio do jogo e o lugar onde os dados da NASA aparecem. Um fato errado tira ponto com os jurados. Foto real com crédito mostra que é "de verdade".

## Leia antes
- [CONTEXTO.md, seção 6](../../CONTEXTO.md#6-fatos-que-podem-ser-usados-todos-reais): fatos com fonte e a lista "A conferir antes de usar". A [seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona) mostra como a carta aparece no jogo.
- [cartas.csv](cartas.csv): `id,categoria,nome_pt,nome_en,nome_es,nome_fr,raridade,como_ganha,onde,fato_pt,fato_en,fato_es,fato_fr,numero_real,fonte,foto_nasa,status`.
- [textos.csv](../../conteudo/03-textos/textos.csv): nomes em inglês que o jogo já usa (ex.: `P_LETTUCE` = `Lettuce`).

## Passo a passo
1. Dividam a pesquisa (ex.: uma pessoa faz 1 a 13, a outra 14 a 25). **Só uma pessoa edita o `cartas.csv` de cada vez.**
2. Para cada carta, abra o link da coluna `fonte` e ache na página o fato e o número de `numero_real`. Não bateu? Corrija `numero_real` e `fato_pt` com o que a página diz e avise no grupo (o `fato_en` muda no passo 03).
3. Resolva a coluna `status`:
   - `trocar a fonte por uma da NASA` (ou fonte fora de nasa.gov, science.nasa.gov, jpl.nasa.gov): ache o mesmo fato num site da NASA e troque o link.
   - `achar a fonte da NASA`: ache a página da NASA e cole em `fonte`.
   - `conferir` e `conferir a parte dos tubos`: leia a página e confirme cada parte do fato.
   - Não achou? Escreva `CONFERIR: falta fonte` e avise no grupo. Sem fonte, a carta não entra.
4. Para achar a fonte, busque no Google com `site:nasa.gov` ou `site:jpl.nasa.gov` + estes termos:

   | id | Buscar | id | Buscar |
   |---|---|---|---|
   | 2 | `radishes space station` | 18 | `Perseverance sample tubes` |
   | 9 | `Curiosity sulfur crystals` | 22 | `dust devil cleaned solar panels` |
   | 12 | `Curiosity MMRTG` | 24 | `Viking 2 frost` |
   | 15 | `Ingenuity 72 flights` | 25 | `Perseverance aurora` |

5. Ache a foto em https://images.nasa.gov (ou science.nasa.gov / jpl.nasa.gov): busque em inglês (ex.: `MOXIE`, `zinnia`), abra a foto e copie o link da página para `foto_nasa`. Prefira foto real; desenho ("artist's concept") só se não existir foto.
6. Baixe em tamanho médio (não precisa da original gigante) e renomeie com o nome desta lista (aqui é `.jpg` mesmo):
   ```
   01-alface.jpg         02-rabanete.jpg     03-couve.jpg        04-batata.jpg        05-zinia.jpg
   06-pimenta-hatch.jpg  07-hematita.jpg     08-jarosita.jpg     09-enxofre.jpg       10-manchas-de-leopardo.jpg
   11-painel-solar.jpg   12-rtg.jpg          13-moxie.jpg        14-kilopower.jpg     15-ingenuity.jpg
   16-curiosity.jpg      17-opportunity.jpg  18-perseverance.jpg 19-sol.jpg           20-frio-da-gale.jpg
   21-tempestade-de-poeira.jpg  22-redemoinho-de-poeira.jpg  23-tempestade-solar.jpg  24-geada.jpg  25-aurora.jpg
   ```
7. Anote o crédito escrito na página da foto (ex.: `NASA/JPL-Caltech`). O crédito não tem "NASA"? Escolha outra foto.
8. Preencha `nome_en`. Se o nome já está no `textos.csv`, use igual (ex.: `Hatch chile`). Nome real não muda: MOXIE, Curiosity, Ingenuity.
9. Tudo conferido (fato, número, fonte da NASA, foto e crédito)? Escreva `ok` em `status`.
10. Suba as fotos: abra `conteudo/02-cartas/` → **Add file → Upload files** → arraste a **pasta `fotos` inteira** → **Commit changes**.
11. Ponha 1 linha por foto no [creditos.csv](../../creditos.csv). Ex.:
    `foto,Foto da carta Enxofre,09-enxofre.jpg,CRÉDITO DA PÁGINA,imagem pública da NASA (com crédito),LINK DA PÁGINA DA FOTO,Conteúdo`
12. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

**Como editar o `.csv`:** no GitHub, abra o arquivo → lápis ✏️ → edite → **Commit changes**. No Google Sheets: Arquivo → Importar → Fazer upload (desmarque "Converter texto em números, datas e fórmulas", senão as datas mudam). Depois Arquivo → Fazer download → Valores separados por vírgula (.csv), renomeie para `cartas.csv` e suba com **Add file → Upload files → Commit changes**.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `cartas.csv` | `nome_en`, `foto_nasa`, `fonte` e `status` preenchidos nas 25 linhas | `.csv` |
| `fotos/` | 25 fotos com os nomes da lista do item 6 | `.jpg` |
| [`creditos.csv`](../../creditos.csv) (na raiz) | 1 linha por foto, com o crédito da página | `.csv` |

## Pronto quando
- [ ] As 25 linhas têm `status` = `ok`.
- [ ] Toda `fonte` é de nasa.gov, science.nasa.gov ou jpl.nasa.gov.
- [ ] Todo `numero_real` aparece escrito na página da fonte.
- [ ] As 25 fotos estão em `fotos/`, com o nome da lista.
- [ ] Toda foto tem `foto_nasa` preenchido e linha no `creditos.csv`.

## Não pode
- Fato ou número "de cabeça", que não está na página.
- Fonte de jornal ou blog (space.com, NBC) no lugar da NASA.
- Foto sem crédito da NASA, imagem feita por IA, foto com o logo da NASA em destaque ou com pessoa menor de 18.
- Mudar o cabeçalho ou a coluna `id`.
- Mexer em `fato_en`, `nome_es`, `nome_fr`, `fato_es`, `fato_fr` (são dos passos 03 e 05).

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/02-cartas (o PASSO.md está junto).
Vou colar linhas do cartas.csv e, para cada carta, o texto da página da fonte da NASA e o crédito da foto que eu achei.
Para cada carta:
1. Diga se o fato_pt e o numero_real batem com o texto da página (sim ou não + o trecho que prova).
2. Se a fonte não for da NASA, diga o que buscar em nasa.gov, science.nasa.gov ou jpl.nasa.gov. Não invente link.
3. Sugira o nome_en, curto e igual ao do textos.csv quando já existir.
Depois devolva:
- as linhas do cartas.csv com o mesmo cabeçalho, mudando só nome_en, fonte, foto_nasa e status (ok ou "CONFERIR: o que falta");
- as linhas novas do creditos.csv (tipo,o_que,arquivo_ou_uso,autor,licenca,link,dupla): tipo "foto", arquivo NN-nome.jpg, autor = crédito da página, dupla "Conteúdo".
Não invente fato, número, link nem crédito: se faltar, escreva CONFERIR.
Saída: a lista curta e depois 2 blocos de código (cartas.csv e creditos.csv).
[cole aqui as linhas e os textos das páginas]
```
