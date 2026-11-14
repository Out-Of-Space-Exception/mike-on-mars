# Conteúdo · 03 · Textos das cartas e dos avisos

> **Em 1 frase:** deixar os textos do jogo e os fatos das cartas curtos e fáceis, em português e em inglês.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [conteudo/02-cartas](../../conteudo/02-cartas/PASSO.md) (fatos conferidos)
- **Quem usa depois:** [conteudo/05-traducoes](../../conteudo/05-traducoes/PASSO.md), [dev/06-receber-entregas](../../dev/06-receber-entregas/PASSO.md)

## Por que importa
É o que a criança lê. Se ela não entende o botão, ela para de jogar. Os jurados olham se o jogo serve mesmo para quem tem de 7 a 12 anos.

## Leia antes
- [CONTEXTO.md, seção 5](../../CONTEXTO.md#5-tom-dos-textos): o tom dos textos.
- [textos.csv](textos.csv): textos do jogo (`keys,pt_BR,en,es,fr`).
- [cartas.csv](../../conteudo/02-cartas/cartas.csv): colunas `nome_en` e `fato_en` (o `fato_en` já tem rascunho).
- [AGENTS.md, seção 4](../../AGENTS.md#4-regras-extras-para-ias): inglês simples, sem parecer coisa de bebê.

## Passo a passo
1. Dividam: uma pessoa no `textos.csv`, a outra no `cartas.csv`. **Uma pessoa por arquivo de cada vez.**
2. Use estas regras em todo texto:

   | Regra | Exemplo |
   |---|---|
   | Botão = 1 palavra | `Play`, `Build`, `Album` |
   | 1 ideia por frase | `Plants grow here. The lights use energy.` |
   | Palavra que uma criança de 7 anos entende | `makes` em vez de `produces` |
   | Sem cara de bebê: nada de "yay", "little buddy" | `Lots of energy, but dust gets in the way.` |
   | Nome real + 1 explicação | `MOXIE: the machine that turns Mars air into oxygen.` |
   | Sempre positivo, nunca culpar | `Low oxygen. Mike waits inside.` |

3. No `textos.csv`, reescreva `en` e `pt_BR` linha por linha. Leia em voz alta e pergunte: "uma criança de 7 anos entende?" e "uma de 12 acha bobo?".
4. Botões (`BTN_*`) ficam com 1 palavra. Escolhas (`EV_SOLAR_A`, `EV_SOLAR_B`) ficam bem curtas.
5. **Nunca** mude a coluna `keys`. `{n}` e `{date}` ficam igualzinhos, no texto novo também.
6. Texto com vírgula fica entre aspas: `"Lots of energy, but dust gets in the way."`.
7. No `cartas.csv`, revise `fato_en` e `nome_en`. Muda só o jeito de falar; o fato e o número continuam os mesmos do `fato_pt`. Ex.:
   - Antes: `MOXIE produced 122 grams of oxygen using the carbon dioxide in the Martian atmosphere.`
   - Depois: `MOXIE made 122 g of oxygen from Mars air: enough for a small dog for 10 hours.`
8. Achou um fato que parece errado? Não mude: avise quem fez o passo 02.
9. Deixe as colunas `es` e `fr` como estão (são do passo 05).
10. Usou IA? Ponha uma linha com o tipo `ia` no [creditos.csv](../../creditos.csv).
11. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

**Como editar o `.csv`:** no GitHub, abra o arquivo → lápis ✏️ → edite → **Commit changes**. No Google Sheets: Arquivo → Importar → Fazer upload (desmarque "Converter texto em números, datas e fórmulas"). Depois Arquivo → Fazer download → Valores separados por vírgula (.csv), renomeie com o mesmo nome e suba na mesma pasta com **Add file → Upload files → Commit changes**.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `textos.csv` | colunas `pt_BR` e `en` revisadas | `.csv` |
| [`cartas.csv`](../../conteudo/02-cartas/cartas.csv) (continua na pasta `02-cartas`) | colunas `fato_en` e `nome_en` revisadas | `.csv` |

## Pronto quando
- [ ] Todo `BTN_*` tem 1 palavra em `en` e em `pt_BR`.
- [ ] Nenhuma `keys` mudou e o número de linhas é o mesmo.
- [ ] Todo `{n}` e `{date}` continua no lugar, em `en` e em `pt_BR`.
- [ ] Os 40 `fato_en` são 1 frase curta, com o mesmo número do `fato_pt`.
- [ ] Li tudo em voz alta e nada ficou difícil nem bobo.

## Não pode
- Mudar `keys`, `id` ou o cabeçalho.
- Apagar, traduzir ou mudar `{n}` e `{date}`.
- Mudar número, data ou fato (isso é do passo 02).
- Traduzir nome real (MOXIE, Curiosity, Ingenuity).
- Termo técnico sem explicação (ex.: mSv, Wh).
- Texto que culpa a criança ("You failed", "Wrong").
- Mexer nas colunas `es` e `fr`.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md (seção 5, tom dos textos) do projeto Mike on Mars. Minha tarefa é conteudo/03-textos (o PASSO.md está junto).
Reescreva os textos abaixo para crianças de 7 a 12 anos: frases curtas, palavras que uma criança de 7 anos entende, sem parecer coisa de bebê para quem tem 12. Botão = 1 palavra. Mensagens sempre positivas.
Regras fixas:
- Não mude o cabeçalho, a coluna keys, a coluna id nem a ordem das linhas.
- Mantenha {n} e {date} exatamente como estão.
- Não mude números, datas nem fatos. Não traduza MOXIE, Curiosity, Ingenuity.
- Texto com vírgula vai entre aspas.
Saída:
1. O textos.csv inteiro, mesmo cabeçalho (keys,pt_BR,en,es,fr), mudando só pt_BR e en. Deixe es e fr como estão.
2. O cartas.csv inteiro, mesmo cabeçalho, mudando só nome_en e fato_en.
3. Uma lista curta das linhas que você mudou e por quê.
[cole aqui o textos.csv e o cartas.csv]
```
