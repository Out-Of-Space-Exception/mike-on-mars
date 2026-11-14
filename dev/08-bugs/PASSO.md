# Dev · 08 · Bugs

> **Em 1 frase:** consertar tudo o que as duplas anotaram nos testes, do mais grave para o mais leve.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [design/08-teste-no-celular](../../design/08-teste-no-celular/PASSO.md), [conteudo/09-teste-no-celular](../../conteudo/09-teste-no-celular/PASSO.md), [dev/07-acabamento-e-congelamento](../07-acabamento-e-congelamento/PASSO.md)
- **Quem usa depois:** [dev/09-video-e-pagina](../09-video-e-pagina/PASSO.md)

## Por que importa
Um jogo que trava na frente do jurado perde mais ponto do que um jogo com uma função a menos.

## Leia antes
- `bugs.md` em [design/08-teste-no-celular](../../design/08-teste-no-celular/)
- `bugs.md` em [conteudo/09-teste-no-celular](../../conteudo/09-teste-no-celular/)

## Passo a passo
1. Juntar os bugs dos 2 arquivos e dar uma prioridade a cada um:
   - **1 trava:** o jogo para, não abre ou perde o save;
   - **2 errado:** faz a coisa errada ou mostra um fato ou texto errado;
   - **3 feio:** visual ou som estranho.
2. Consertar na ordem 1 → 2 → 3. Um commit por conserto: `Corrige: <o que foi>`.
3. Marcar `✅ corrigido` no item do `bugs.md` de origem.
4. Publicar e testar no celular mais fraco.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `bugs-prioridade.md` | a lista única, com a prioridade e o status de cada bug | `.md` |

## Pronto quando
- [ ] nenhum bug de prioridade 1 aberto
- [ ] os de prioridade 2 corrigidos, ou anotados como "fica assim"
- [ ] versão publicada e testada no celular

## Não pode
- "Consertar" com função nova: o jogo está congelado.
- Juntar vários bugs num commit só.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o padrão do código do dev/03-esqueleto/PASSO.md. Este é o bug: [o que fiz / o que esperava /
o que aconteceu]. Ache a causa no jogo/ e proponha o menor conserto possível, sem função nova.
```
