# Conteúdo · 07 · Roteiro do vídeo

> **Em 1 frase:** escrever, cena por cena, o vídeo de até 30 segundos para os jurados.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** o jogo com cara de pronto ([dev/05-jogo-completo](../../dev/05-jogo-completo/PASSO.md))
- **Quem usa depois:** [conteudo/08-cenas-e-creditos](../../conteudo/08-cenas-e-creditos/PASSO.md), [dev/09-video-e-pagina](../../dev/09-video-e-pagina/PASSO.md)

## Por que importa
O vídeo é a primeira coisa que muitos jurados veem. São só 30 segundos: cada segundo precisa mostrar o jogo de verdade e os dados da NASA.

## Leia antes
- [CONTEXTO.md, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): o que dá para mostrar.
- [CONTEXTO.md, seção 7](../../CONTEXTO.md#7-regras-do-space-apps-resumo): regras do vídeo (até 30 s, legenda em inglês).
- [slides.md](../../conteudo/04-slides/slides.md): a mesma história, em slides.
- O jogo: https://out-of-space-exception.github.io/mike-on-mars/

## Passo a passo
1. Faça este passo quando o jogo já estiver com cara de pronto. Jogue antes pelo link e anote o que já funciona.
2. Escreva a história em 1 frase. Ex.: "Mike cuida da base, explora, ganha uma carta real da NASA e aguenta uma tempestade solar de verdade."
3. Divida em 5 ou 6 cenas, de 3 a 7 segundos cada. A soma tem que dar **até 30 s**.
4. Para cada cena, escreva o que aparece na tela e a legenda em inglês.
5. Legenda curta: até umas 7 palavras por cena, para dar tempo de ler.
6. Mostre os dados da NASA: uma carta com foto e fato real e a tempestade solar com a data real (DONKI).
7. Termine com o nome do jogo e o link (ou o QR code).
8. Vai ter fala? Pode ser em português, desde que tenha a legenda em inglês. Voz só de adulto (18+).
9. Algum pedaço feito com IA? Marca d'água "Made with AI" visível e uma linha com o tipo `ia` no [creditos.csv](../../creditos.csv).
10. Crie o arquivo no GitHub: abra `conteudo/07-roteiro-do-video/` → **Add file → Create new file** → nome `roteiro.md` → cole a tabela → **Commit changes**.
11. Avise a dupla de Dev, siga para o [passo 08](../../conteudo/08-cenas-e-creditos/PASSO.md) e marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

Modelo do `roteiro.md` (exemplo: troque pelo que o jogo faz de verdade):
```markdown
# Roteiro do vídeo · Mike on Mars

| tempo | o que aparece na tela | legenda (EN) |
|---|---|---|
| 0–4 s | Mike na cratera Gale, céu caramelo | Meet Mike. He lives on Mars. |
| 4–10 s | toca no painel solar, toca no chão; estufa com alface crescendo | Build your base. Grow space food. |
| 10–17 s | Mike explora, volta com o tubo, o tubo treme e abre uma carta | Find real NASA discoveries. |
| 17–24 s | alerta de tempestade solar com a data real; o escudo sobe | Real solar storms, from NASA data. |
| 24–30 s | base crescendo + nome do jogo + link | Mike on Mars. Play on your phone. |

Total: 30 s
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `roteiro.md` | tabela `tempo \| o que aparece na tela \| legenda (EN)`, somando até 30 s | `.md` |

## Pronto quando
- [ ] A soma dos tempos dá 30 s ou menos.
- [ ] Toda cena tem o que aparece na tela e a legenda em inglês.
- [ ] Aparece pelo menos 1 dado da NASA (carta ou tempestade solar).
- [ ] O vídeo termina com o nome do jogo e o link.
- [ ] Nenhum rosto nem voz de menor de 18.

## Não pode
- Passar de 30 s (nem 31).
- Legenda em português ou cena sem legenda.
- Mostrar o que o jogo ainda não faz.
- Rosto ou voz de pessoa menor de 18.
- Música que não está no `creditos.csv`.
- Logo da NASA.
- Imagem ou vídeo de IA sem marca d'água.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/07-roteiro-do-video (o PASSO.md está junto).
Escreva o roteiro de um vídeo de no máximo 30 segundos para os jurados do NASA Space Apps, mostrando o jogo de verdade.
Use só o que o jogo já faz (lista abaixo). Mostre pelo menos 1 dado da NASA (carta com fato real ou tempestade solar do DONKI) e termine com o nome do jogo e o link.
Legendas em inglês simples, até 7 palavras por cena. Sem rosto nem voz de menor de 18.
Saída: só a tabela em Markdown, com o cabeçalho exato "| tempo | o que aparece na tela | legenda (EN) |", somando até 30 s, e embaixo a linha "Total: N s".
O que o jogo já faz: [liste aqui]
```
