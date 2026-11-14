# Design · 04 · As cores das coisas

> **Em 1 frase:** decidir o hex de cada peça que muda de cor no jogo: pedras, MOXIE, Ingenuity, céu e tubo de amostra.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [02-cores-e-fonte](../02-cores-e-fonte/PASSO.md) e [03-itens-do-jogo](../03-itens-do-jogo/PASSO.md)
- **Quem usa depois:** [dev/07-acabamento-e-congelamento](../../dev/07-acabamento-e-congelamento/PASSO.md)

## Por que importa
As cores contam a história real: o MOXIE é dourado, o céu de Marte de dia é caramelo, o enxofre é amarelo. E a cor do tubo diz a raridade da carta antes de ela aparecer. Vocês decidem; a dupla de Dev aplica tudo no jogo depois.

## Leia antes
- [CONTEXTO, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): o tubo de amostra e as raridades
- [CONTEXTO, seção 4](../../CONTEXTO.md#4-estilo-visual): Ingenuity, céu e MOXIE
- [CONTEXTO, seção 6](../../CONTEXTO.md#6-fatos-que-podem-ser-usados-todos-reais): hematita, enxofre, manchas de leopardo e MOXIE, com os links da NASA
- [cores.csv](../02-cores-e-fonte/cores.csv) e [itens.csv](../03-itens-do-jogo/itens.csv)
- [Modelo 3D do Ingenuity, da NASA](https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/)

## Passo a passo
1. No Figma ou no Canva, crie uma tela com fundo caramelo (o céu) e, para cada linha da tabela abaixo, faça um quadrado e teste a cor por cima.
2. Para as cores "de verdade" (MOXIE, céu, pedras), ache uma foto real (por exemplo, nos links da NASA da seção 6), cole no Figma e pegue a cor com o conta-gotas (tecla `I`).
3. Ingenuity: o cinza vira branco, com uma faixa azul e uma vermelha, no estilo das máquinas da Kenney.
4. Tubo de amostra: 3 cores bem diferentes, do comum ao lendário. O raro pode usar a cor `destaque-raro` do `cores.csv`. Teste com o celular longe do rosto: dá para ver a diferença?
5. Crie o `cores-das-coisas.csv`: na pasta `design/04-cores-das-coisas` do GitHub, **Add file → Create new file**, cole o modelo, troque cada `#RRGGBB` e clique em **Commit changes**.
6. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e avise o Dev no grupo.

| `coisa` | O que é | Dica de cor |
|---|---|---|
| `hematita` | pedra de hematita | cinza-escuro |
| `enxofre` | pedra de enxofre | amarelo |
| `leopardo-base` | a rocha das manchas de leopardo | avermelhada |
| `leopardo-manchas` | as manchinhas da rocha | escuras |
| `moxie` | a máquina MOXIE | dourado, igual ao de verdade |
| `ingenuity-corpo` | o corpo do Ingenuity | branco |
| `ingenuity-faixa-azul` | uma faixa do Ingenuity | azul |
| `ingenuity-faixa-vermelha` | a outra faixa | vermelho |
| `ceu` | o céu de dia | caramelo |
| `tubo-comum` / `tubo-raro` / `tubo-lendario` | o tubo de amostra em cada raridade | do mais discreto ao mais brilhante |

Modelo do `cores-das-coisas.csv`:
```text
coisa,hex,observacao
hematita,#RRGGBB,
enxofre,#RRGGBB,
leopardo-base,#RRGGBB,
leopardo-manchas,#RRGGBB,
moxie,#RRGGBB,
ingenuity-corpo,#RRGGBB,
ingenuity-faixa-azul,#RRGGBB,
ingenuity-faixa-vermelha,#RRGGBB,
ceu,#RRGGBB,
tubo-comum,#RRGGBB,
tubo-raro,#RRGGBB,
tubo-lendario,#RRGGBB,
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `cores-das-coisas.csv` | colunas `coisa,hex,observacao` e as 12 linhas do modelo | `.csv` |

## Pronto quando
- [ ] A 1ª linha é `coisa,hex,observacao`.
- [ ] Tem as 12 linhas, nesta ordem e com esta grafia.
- [ ] Não sobrou nenhum `#RRGGBB`: todo hex tem `#` e 6 letras/números.
- [ ] As 3 cores do tubo dão para distinguir de longe, no celular, e o céu combina com o `cores.csv`.
- [ ] O GitHub mostra o arquivo como tabela.

## Não pode
- Mudar a grafia da coluna `coisa` ou tirar linha: o Dev procura por esse nome.
- MOXIE que não seja dourado, ou céu azul.
- Logo ou bandeira da NASA no Ingenuity: só as faixas.
- Vírgula dentro da observação; salvar o CSV no Excel.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo.
Tarefa: Design · 04 · As cores das coisas. Esta é a nossa paleta (cores.csv):
[cole aqui o cores.csv]
Sugira 1 hex para cada coisa abaixo, combinando com a paleta e com o céu caramelo:
hematita (cinza-escuro), enxofre (amarelo), leopardo-base (rocha avermelhada), leopardo-manchas (manchinhas escuras), moxie (dourado, como o MOXIE de verdade), ingenuity-corpo (branco), ingenuity-faixa-azul, ingenuity-faixa-vermelha, ceu (caramelo, a cor real do céu de Marte de dia), tubo-comum, tubo-raro, tubo-lendario (3 cores fáceis de distinguir de longe).
Responda só com o cores-das-coisas.csv: 1ª linha exatamente coisa,hex,observacao e as 12 linhas nesta ordem e com esta grafia. Observação curta e sem vírgula.
```
