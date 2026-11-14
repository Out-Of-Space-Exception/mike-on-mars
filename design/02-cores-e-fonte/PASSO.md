# Design · 02 · Cores e fonte

> **Em 1 frase:** escolher as 5 cores da interface (em hex) e 1 fonte do Google Fonts.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada (se o [01-mike](../01-mike/PASSO.md) já tiver a cor do traje, combine com ela)
- **Quem usa depois:** [05-telas](../05-telas/PASSO.md), [06-logo-e-icone](../06-logo-e-icone/PASSO.md), [dev/07-acabamento-e-congelamento](../../dev/07-acabamento-e-congelamento/PASSO.md)

## Por que importa
Essas cores e essa fonte aparecem em todo botão, barra e tela. Uma paleta bem escolhida faz o jogo parecer profissional e "de verdade", e é a primeira coisa que o jurado nota.

## Leia antes
- [CONTEXTO, seção 4](../../CONTEXTO.md#4-estilo-visual): céu caramelo, low-poly da Kenney, "nunca infantil demais"
- [CONTEXTO, seção 5](../../CONTEXTO.md#5-tom-dos-textos): botões com ícone + 1 palavra
- [AGENTS, seção 3](../../AGENTS.md#3-as-regras): cor sempre em hex; tudo o que vem de fora vai no `creditos.csv`
- Para sentir o estilo: prévias do [Space Kit](https://kenney.nl/assets/space-kit) e do [UI Pack Sci-Fi](https://kenney.nl/assets/ui-pack-sci-fi)

## Passo a passo
1. Abra o Figma ou o Canva e pinte um retângulo grande de caramelo (o céu de Marte).
2. Escolha 5 cores, uma para cada uso: `fundo`, `botao-principal`, `texto`, `destaque-raro`, `alerta`. Teste cada uma por cima do caramelo.
3. Confira se o texto lê bem: ponha a cor do texto e a do fundo em https://webaim.org/resources/contrastchecker/ e veja se aparece "Pass". Faça o mesmo com texto × botão.
4. Copie o hex de cada cor (com `#` e 6 letras/números).
5. Abra https://fonts.google.com, escreva `Mike on Mars` e `Energy` na caixa de prévia e compare. Escolha 1 fonte fácil de ler, com cara de jogo e que não pareça de bebê.
6. Na página da fonte, anote: nome, link, quem fez e a licença que aparece lá (quase sempre "Open Font License", a OFL).
7. Crie o `cores.csv` e o `fonte.md`: na pasta `design/02-cores-e-fonte` do GitHub, **Add file → Create new file**, cole o modelo abaixo preenchido e clique em **Commit changes** (um arquivo de cada vez).
8. Abra o [creditos.csv](../../creditos.csv), clique no lápis, cole a linha da fonte no fim e clique em **Commit changes**.
9. Exceção combinada: no [CONTEXTO.md](../../CONTEXTO.md), seção 4, troque só o texto em itálico das linhas "Paleta da interface" e "Fonte" por `[cores.csv](design/02-cores-e-fonte/cores.csv)` e `[<Nome da fonte>](design/02-cores-e-fonte/fonte.md)`.
10. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e avise no grupo.

Modelo do `cores.csv`:
```text
nome,hex,uso
<nome curto>,#RRGGBB,fundo
<nome curto>,#RRGGBB,botao-principal
<nome curto>,#RRGGBB,texto
<nome curto>,#RRGGBB,destaque-raro
<nome curto>,#RRGGBB,alerta
```

Modelo do `fonte.md` e linha do `creditos.csv`:
```text
# Fonte
- Nome: <Nome da fonte>
- Link: https://fonts.google.com/specimen/<Nome+da+Fonte>
- Licença: <como aparece na página>
- Autor: <quem fez>
- Pesos usados: <ex.: Regular e Bold>

fonte,<Nome da fonte>,interface do jogo,<autor>,<licença>,<link do Google Fonts>,Design
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `cores.csv` | colunas `nome,hex,uso` e exatamente 5 linhas | `.csv` |
| `fonte.md` | nome da fonte, link do Google Fonts e licença | `.md` |

## Pronto quando
- [ ] A 1ª linha do `cores.csv` é `nome,hex,uso`, com exatamente 5 linhas embaixo.
- [ ] Todo hex tem `#` e 6 letras/números.
- [ ] O texto lê bem no fundo e no botão (testado no celular).
- [ ] O `fonte.md` tem nome, link e licença, e a fonte está no `creditos.csv`.
- [ ] A seção 4 do CONTEXTO.md tem os 2 links.

## Não pode
- Mais ou menos que 5 cores, ou cor sem `#`.
- Fonte de fora do Google Fonts, ou sem anotar a licença.
- Fonte cursiva, toda enfeitada ou com cara de bebê.
- Salvar o CSV no Excel: no Brasil ele troca a vírgula por ponto e vírgula. Crie direto no GitHub.
- Mexer em outra parte do CONTEXTO.md além dessas 2 linhas.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo.
Tarefa: Design · 02 · Cores e fonte.
1) Sugira 3 paletas de 5 cores em hex, uma cor para cada uso: fundo, botao-principal, texto, destaque-raro, alerta. Elas precisam combinar com o céu caramelo de Marte e com o low-poly da Kenney, e o texto precisa ler bem no fundo e no botão. Para cada paleta, diga em 1 frase por que não parece infantil.
2) Sugira 3 fontes do Google Fonts fáceis de ler, com cara de jogo e sem cara de bebê.
Depois que eu escolher, responda só com os 2 arquivos prontos:
- cores.csv: 1ª linha exatamente nome,hex,uso e 5 linhas embaixo.
- fonte.md: linhas Nome, Link, Licença, Autor e Pesos usados.
Se não tiver certeza da licença ou do autor da fonte, escreva CONFERIR.
```
