# Design · 08 · Teste no celular

> **Em 1 frase:** jogar no celular e anotar tudo o que precisa mudar.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada (o jogo já está no link)
- **Quem usa depois:** [dev/08-bugs](../../dev/08-bugs/PASSO.md)

## Por que importa
Os jurados e as crianças vão jogar no celular. Um problema no primeiro minuto derruba a nota. Vocês enxergam o que o Dev não vê: letra difícil de ler, botão pequeno, tela com cara de bebê.

## Leia antes
- [CONTEXTO, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): como o jogo deveria funcionar
- [CONTEXTO, seção 5](../../CONTEXTO.md#5-tom-dos-textos) e [seção 8](../../CONTEXTO.md#8-o-que-não-fazer): o tom e o que não pode
- [Telas do passo 05](../05-telas/telas.md): para comparar com o que vocês desenharam

## Passo a passo
1. No celular, abra https://out-of-space-exception.github.io/mike-on-mars/ (ou aponte a câmera para o QR do README).
2. Jogue sem ninguém explicar nada. Conte os primeiros 60 segundos: deu para entender o que fazer?
3. Enquanto joga, pergunte a si mesma: isto parece coisa de bebê?
4. Anote cada problema na hora (no bloco de notas do celular): o que você fez, o que esperava e o que aconteceu.
5. Teste também: girar o celular, tocar com o polegar, ler com o celular longe do rosto, som ligado e desligado.
6. Se der, teste em 2 celulares diferentes (ex.: um Android e um iPhone).
7. Tire print quando der. Se subir, use os nomes `bug-01.png`, `bug-02.png`... e cite no item.
8. Crie o `bugs.md` com o modelo abaixo: na pasta `design/08-teste-no-celular` do GitHub, **Add file → Create new file** → cole → **Commit changes**.
9. Avise o Dev no grupo e marque `[x]` no [TAREFAS.md](../../TAREFAS.md).
10. Saiu versão nova do jogo? Jogue de novo e acrescente no mesmo `bugs.md`.

Modelo do `bugs.md` (o item 1 é só exemplo: apague depois de escrever os seus):
```text
# Bugs e ajustes (teste no celular)

## As 2 perguntas
- Parece coisa de bebê? <sim ou não + por quê, em 1 linha>
- Dá para entender o que fazer em 60 segundos? <sim ou não + onde travou>

## Problemas

### 1. (EXEMPLO) Botão Explore difícil de tocar
- O que eu fiz: toquei em Explore com o polegar.
- O que eu esperava: o Mike sair para explorar.
- O que aconteceu: precisei tocar 3 vezes; o dedo cobria o botão.
- Celular usado: Samsung Galaxy A14, Chrome
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `bugs.md` | 1 item por problema (o que eu fiz / o que eu esperava / o que aconteceu / celular usado) e as respostas às 2 perguntas | `.md` |

## Pronto quando
- [ ] As 2 perguntas estão respondidas.
- [ ] Cada problema tem as 4 partes, inclusive o celular usado.
- [ ] O exemplo foi apagado.
- [ ] O Dev foi avisado no grupo.

## Não pode
- Escrever só "não funciona", sem dizer o que fez.
- Juntar vários problemas num item só.
- Testar só no computador.
- Pedir para alguém explicar o jogo antes (estraga o teste dos 60 segundos).
- Foto, vídeo ou voz de criança, mesmo se uma criança testar junto.
- Mexer no jogo: só anotar.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo.
Tarefa: Design · 08 · Teste no celular. Abaixo estão minhas anotações soltas do teste e o celular que usei.
[cole aqui suas anotações]
Organize tudo no bugs.md, neste formato: título "# Bugs e ajustes (teste no celular)", a seção "## As 2 perguntas" (parece coisa de bebê? / dá para entender o que fazer em 60 segundos?) e a seção "## Problemas" com 1 item por problema, cada um com: O que eu fiz / O que eu esperava / O que aconteceu / Celular usado.
Não invente problema nem resposta. Se faltar uma das partes, escreva CONFERIR. Responda só com o conteúdo do bugs.md.
```
