# Dev · 01 · Destravar o time

> **Em 1 frase:** deixar tudo pronto para as outras duplas começarem sem esperar a gente.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada
- **Quem usa depois:** [conteudo/01-sons](../../conteudo/01-sons/PASSO.md), [conteudo/02-cartas](../../conteudo/02-cartas/PASSO.md), [conteudo/03-textos](../../conteudo/03-textos/PASSO.md) e todos os passos de [design](../../design/)

## Por que importa
Se as outras duplas ficam esperando, o dia acaba e o jogo fica sem som, sem cartas e sem cara. Este passo entrega o lugar de trabalho (o repositório) e os rascunhos que destravam o Conteúdo.

## Leia antes
- [AGENTS.md](../../AGENTS.md): o padrão do repositório
- [CONTEXTO.md](../../CONTEXTO.md), seções 3 (como o jogo funciona) e 6 (fatos)

## Passo a passo
1. Criar o repositório `mike-on-mars` na organização `Out-Of-Space-Exception`. Ele é **público** para o GitHub Pages ser grátis e os jurados verem.
2. Criar uma pasta por dupla (`design/`, `conteudo/`, `dev/`) e uma pasta por passo, cada uma com um `PASSO.md` no modelo do AGENTS.md.
3. Criar o `creditos.csv` na raiz (no lugar da antiga planilha de créditos).
4. Gerar os rascunhos e deixar cada um na pasta do passo que vai terminá-lo (exceção combinada: este passo cria, o Conteúdo termina).
5. Mandar no grupo o link do repositório e o link do jogo.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| [creditos.csv](../../creditos.csv) | tudo o que veio de fora + uso de IA | `.csv` |
| [sons.csv](../../conteudo/01-sons/sons.csv) | 25 sons (15 essenciais) | `.csv` |
| [cartas.csv](../../conteudo/02-cartas/cartas.csv) | 40 cartas com fato e fonte (4 raridades) | `.csv` |
| [textos.csv](../../conteudo/03-textos/textos.csv) | todos os textos do jogo em PT e EN | `.csv` no formato de tradução da Godot |

## Pronto quando
- [x] o repositório está público, com README, AGENTS.md, CONTEXTO.md e TAREFAS.md
- [x] as 3 listas e o `creditos.csv` estão no repositório
- [x] o link foi mandado no grupo

## Não pode
- Colocar link privado (como o do doc antigo de tarefas), senha ou chave de API no repositório: ele é público.
- Escrever fato sem fonte nos rascunhos.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md deste repositório. Gere o rascunho de [lista] no formato exato
do arquivo [caminho], sem mudar o cabeçalho. Use só fatos com link da seção 6 do CONTEXTO.md.
O que não tiver fonte, marque CONFERIR na coluna status.
```
