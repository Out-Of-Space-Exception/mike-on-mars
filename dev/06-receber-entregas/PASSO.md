# Dev · 06 · Receber as entregas

> **Em 1 frase:** conferir que chegou tudo das outras duplas antes de o pessoal ir embora.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [design/09-entrega](../../design/09-entrega/PASSO.md) e todos os passos de [conteudo](../../conteudo/)
- **Quem usa depois:** [dev/07-acabamento-e-congelamento](../07-acabamento-e-congelamento/PASSO.md)

## Por que importa
Depois das 20h, as outras duplas vão embora. O que faltar e não for pedido agora vira problema de madrugada, sem ninguém para resolver.

## Leia antes
- [TAREFAS.md](../../TAREFAS.md): quais caixinhas estão marcadas
- [design/09-entrega](../../design/09-entrega/PASSO.md): a lista de tudo o que o Design entrega
- [creditos.csv](../../creditos.csv)

## Passo a passo
1. Abrir o TAREFAS.md e ver o que **não** está marcado.
2. Conferir os arquivos de cada pasta de Design e de Conteúdo: nome certo, formato certo, no lugar certo.
3. Rodar `node ferramentas/sincronizar.mjs` e abrir o jogo para ver se os textos e as cartas novas aparecem.
4. Conferir o `creditos.csv`: todo asset e todo uso de IA tem uma linha.
5. Pedir na hora, pessoalmente, o que faltar. Combinar quem resolve no domingo (até 22h).
6. Anotar em `recebido.md` o que chegou e o que ficou pendente.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `recebido.md` | o que chegou, o que falta e quem resolve | `.md` |

## Pronto quando
- [ ] todos os arquivos esperados estão no repositório ou anotados como pendentes, com o nome de quem resolve
- [ ] o `sincronizar.mjs` roda sem erro
- [ ] o `creditos.csv` está completo

## Não pode
- Deixar o pessoal ir embora sem conferir.
- Aceitar asset sem licença ou fato sem fonte.

## Pedido pronto para a IA
```text
Siga o AGENTS.md. Compare o que existe nas pastas design/ e conteudo/ com o "O que entregar"
de cada PASSO.md e liste o que falta, arquivo por arquivo, no formato de dev/06-receber-entregas/recebido.md.
```
