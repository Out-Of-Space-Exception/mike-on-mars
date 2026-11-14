# Design · 06 · Logo e ícone

> **Em 1 frase:** fazer o logo "Mike on Mars" em PNG com fundo transparente e o ícone quadrado do jogo.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [01-mike](../01-mike/PASSO.md) e [02-cores-e-fonte](../02-cores-e-fonte/PASSO.md)
- **Quem usa depois:** [dev/07-acabamento-e-congelamento](../../dev/07-acabamento-e-congelamento/PASSO.md), [conteudo/04-slides](../../conteudo/04-slides/PASSO.md), [conteudo/06-pagina-do-projeto](../../conteudo/06-pagina-do-projeto/PASSO.md)

## Por que importa
O logo é a primeira coisa que o jurado vê: na página do projeto, nos slides e no vídeo. O ícone aparece na aba do navegador e na tela do celular. Os dois juntos dizem "isto é um jogo de verdade".

## Leia antes
- [CONTEXTO, seção 1](../../CONTEXTO.md#1-instruções-para-a-ia-leia-antes-de-tudo): regras 4 e 5 (nada da NASA; IA leva marca d'água)
- [CONTEXTO, seção 4](../../CONTEXTO.md#4-estilo-visual) e [seção 7](../../CONTEXTO.md#7-regras-do-space-apps-resumo)
- [fonte.md](../02-cores-e-fonte/fonte.md), [cores.csv](../02-cores-e-fonte/cores.csv) e [mike.png](../01-mike/mike.png)

## Passo a passo
1. Rabisque 2 ou 3 ideias no papel (ex.: "Mike on Mars" com a fonte do jogo + o capacete do Mike + um planeta).
2. Escolha a melhor e faça **à mão** no Figma, com a fonte do `fonte.md` e as cores do `cores.csv`. Pode usar a prévia do Mike ou um planeta do pacote Planets, da Kenney (em kenney.nl/assets).
3. Logo: frame com pelo menos 1024 px de largura (ex.: 1024 × 512).
4. Deixe o fundo transparente: selecione o frame e apague o preenchimento (em **Fill**, clique no `−`). No Canva grátis o fundo transparente pode não estar liberado; prefira o Figma.
5. Ícone: frame quadrado de 512 × 512, com fundo de uma cor do `cores.csv` e um desenho simples (ex.: o capacete do Mike). Teste em tamanho bem pequeno: ainda dá para reconhecer?
6. Vai usar IA para gerar imagem? A regra do Space Apps pede marca d'água visível ("Made with AI"). Antes, tentem fazer à mão ou perguntem aos mentores do evento se dá para usar IA no logo sem a marca d'água.
7. Exporte em PNG: selecione o frame → **Export** → PNG → **Export**. Nomes: `logo.png` e `icone.png`.
8. Suba os 2 arquivos: na pasta `design/06-logo-e-icone`, **Add file → Upload files** → arraste → **Commit changes**.
9. Usou pacote da Kenney ou IA? Abra o [creditos.csv](../../creditos.csv), clique no lápis e coloque 1 linha para cada (IA com o tipo `ia`: o que foi feito e com qual IA).
10. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e mande o logo no grupo (Conteúdo usa nos slides e na página).

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `logo.png` | logo "Mike on Mars", fundo transparente, pelo menos 1024 px de largura | `.png` |
| `icone.png` | ícone quadrado do jogo, 512 × 512 | `.png` |

## Pronto quando
- [ ] O `logo.png` tem fundo transparente (no Figma ou no navegador aparece xadrez ou a cor de trás).
- [ ] O `logo.png` tem 1024 px de largura ou mais (botão direito → **Propriedades → Detalhes**).
- [ ] O `icone.png` tem exatamente 512 × 512.
- [ ] Dá para ler "Mike on Mars" pequeno, e o ícone é reconhecível bem pequeno.
- [ ] Se usou IA: tem marca d'água (ou o "pode" dos mentores) e a linha `ia` no `creditos.csv`.

## Não pode
- Logo, bandeira ou marca da NASA (nem algo parecido com o logo da NASA).
- Imagem de IA sem marca d'água.
- Logo em português: o nome no logo é "Mike on Mars".
- Copiar o estilo do logo de outro jogo ou filme.
- Ícone com texto pequeno (some no celular).

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo, junto com o cores.csv, o fonte.md e o mike.md.
Tarefa: Design · 06 · Logo e ícone. Não gere imagem: quero fazer à mão no Figma.
Me dê 3 ideias de logo "Mike on Mars" (fundo transparente, pelo menos 1024 px de largura) e 3 ideias de ícone (512 x 512), usando só a nossa fonte e as cores do cores.csv. Nada de logo ou marca da NASA, nada parecido com outro jogo ou filme, nada com cara de bebê.
Responda em lista curta: para cada ideia, as formas, as cores em hex e os passos no Figma (no máximo 5 passos).
```
