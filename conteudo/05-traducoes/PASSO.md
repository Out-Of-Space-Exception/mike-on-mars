# Conteúdo · 05 · Traduções

> **Em 1 frase:** deixar o jogo em 4 idiomas: inglês, português, espanhol e francês.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [conteudo/03-textos](../../conteudo/03-textos/PASSO.md) (inglês revisado)
- **Quem usa depois:** [dev/06-receber-entregas](../../dev/06-receber-entregas/PASSO.md)

## Por que importa
Com 4 idiomas, o jogo serve para crianças de muitos países, e isso conta como impacto para os jurados. Texto cortado ou errado na tela faz o jogo parecer quebrado.

## Leia antes
- [CONTEXTO.md, seção 2](../../CONTEXTO.md#2-o-projeto-em-1-minuto): o nome do jogo nos 4 idiomas.
- [CONTEXTO.md, seção 5](../../CONTEXTO.md#5-tom-dos-textos): o tom dos textos.
- [textos.csv](../../conteudo/03-textos/textos.csv): colunas `keys,pt_BR,en,es,fr`.
- [cartas.csv](../../conteudo/02-cartas/cartas.csv): colunas `nome_*` e `fato_*`.

## Passo a passo
1. Comece quando o inglês do passo 03 estiver pronto. Traduza **do inglês** (`en`, `nome_en`, `fato_en`), olhando o `pt_BR` para pegar o tom.
2. Dividam: uma pessoa no `textos.csv`, a outra no `cartas.csv`. **Uma pessoa por arquivo de cada vez.**
3. Revise o `pt_BR` do `textos.csv`: acentos, erros de digitação, frases curtas, botão com 1 palavra.
4. Preencha `es` e `fr` em todas as linhas do `textos.csv`. O nome do jogo já está pronto: `Mike en Marte` e `Mike sur Mars`.
5. Preencha no `cartas.csv`: `nome_es`, `nome_fr`, `fato_es` e `fato_fr`, nas 40 linhas.
6. Fica igual nos 4 idiomas: `{n}`, `{date}`, os números e os nomes reais (MOXIE, Curiosity, Ingenuity, Perseverance, Opportunity, InSight).
7. Espanhol e francês costumam ficar mais compridos. Botão passou de 1 palavra ou a frase ficou longa? Troque por uma palavra mais curta.
8. Ninguém do time sabe espanhol ou francês? Peça para alguém que saiba ou use IA. O melhor: a IA traduz e uma pessoa que fala o idioma confere.
9. Usou IA? Ponha uma linha com o tipo `ia` no [creditos.csv](../../creditos.csv). Ex.:
   `ia,Tradução para espanhol e francês,textos.csv; cartas.csv,NOME DA IA USADA,não se aplica,SITE DA IA,Conteúdo`
10. Confira: mesma quantidade de linhas e nenhuma célula vazia em `es` e `fr`.
11. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

**Como editar o `.csv`:** no GitHub, abra o arquivo → lápis ✏️ → edite → **Commit changes**. No Google Sheets: Arquivo → Importar → Fazer upload (desmarque "Converter texto em números, datas e fórmulas"). Depois Arquivo → Fazer download → Valores separados por vírgula (.csv), renomeie com o mesmo nome e suba na pasta do arquivo com **Add file → Upload files → Commit changes**. Texto com vírgula fica entre aspas.

## O que entregar (nesta pasta)
Os arquivos ficam onde já estão (regra 2 do [AGENTS.md](../../AGENTS.md#3-as-regras)). Esta pasta só tem este `PASSO.md`.

| Arquivo | O que tem | Formato |
|---|---|---|
| [`textos.csv`](../../conteudo/03-textos/textos.csv) | colunas `es` e `fr` completas e `pt_BR` revisado | `.csv` |
| [`cartas.csv`](../../conteudo/02-cartas/cartas.csv) | colunas `nome_es`, `nome_fr`, `fato_es` e `fato_fr` | `.csv` |
| [`creditos.csv`](../../creditos.csv) (na raiz) | linha `ia`, se usou IA | `.csv` |

## Pronto quando
- [ ] Nenhuma célula vazia em `es` e `fr` do `textos.csv`.
- [ ] As 40 cartas têm `nome_es`, `nome_fr`, `fato_es` e `fato_fr`.
- [ ] `{n}` e `{date}` aparecem nas mesmas linhas nos 4 idiomas.
- [ ] Botões com 1 palavra nos 4 idiomas.
- [ ] Os números dos fatos são os mesmos nos 4 idiomas.
- [ ] O uso de IA está no `creditos.csv`.

## Não pode
- Mudar `keys`, `id`, o cabeçalho ou a ordem das linhas.
- Traduzir, apagar ou mudar `{n}` e `{date}`.
- Traduzir MOXIE, Curiosity, Ingenuity e os outros nomes reais.
- Mudar o `en` (é do passo 03).
- Tradução palavra por palavra que fica estranha: frase natural, mesmo sentido.
- Usar IA sem declarar no `creditos.csv`.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/05-traducoes (o PASSO.md está junto).
Traduza do inglês (colunas en, nome_en e fato_en) para espanhol e francês, para crianças de 7 a 12 anos: frases curtas e naturais, tom divertido, sem parecer coisa de bebê. Botão = 1 palavra. Revise também o pt_BR (só erros e frases longas).
Regras fixas:
- Não mude o cabeçalho, a coluna keys, a coluna id nem a ordem das linhas.
- Mantenha {n} e {date} exatamente como estão.
- Não traduza MOXIE, Curiosity, Ingenuity, Perseverance, Opportunity, InSight.
- Não mude números nem fatos. Não mexa na coluna en.
- Texto com vírgula vai entre aspas.
Saída:
1. O textos.csv inteiro (keys,pt_BR,en,es,fr), com es e fr preenchidos e pt_BR revisado.
2. O cartas.csv inteiro, mesmo cabeçalho, preenchendo só nome_es, nome_fr, fato_es e fato_fr.
3. Uma lista das traduções de que você não tem certeza, para uma pessoa conferir.
[cole aqui o textos.csv e o cartas.csv]
```
