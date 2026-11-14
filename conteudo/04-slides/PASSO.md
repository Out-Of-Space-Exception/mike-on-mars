# Conteúdo · 04 · Slides

> **Em 1 frase:** fazer 7 slides em inglês que contam o projeto para a banca.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [conteudo/02-cartas](../../conteudo/02-cartas/PASSO.md) (fotos e fatos)
- **Quem usa depois:** [conteudo/06-pagina-do-projeto](../../conteudo/06-pagina-do-projeto/PASSO.md), [dev/10-envio](../../dev/10-envio/PASSO.md)

## Por que importa
A banca do evento vê estes slides. E, se o vídeo der problema, o Space Apps aceita até 7 slides no lugar dele: é a nossa reserva.

## Leia antes
- [CONTEXTO.md, seções 2](../../CONTEXTO.md#2-o-projeto-em-1-minuto) e [3](../../CONTEXTO.md#3-como-o-jogo-funciona) (o jogo), [4](../../CONTEXTO.md#4-estilo-visual) (cores e fonte) e [7](../../CONTEXTO.md#7-regras-do-space-apps-resumo) (regras do Space Apps).
- [cartas.csv](../../conteudo/02-cartas/cartas.csv) e a pasta `conteudo/02-cartas/fotos/`: fatos, fontes e fotos.
- QR code do jogo: `ferramentas/qr-code.png`.

## Passo a passo
1. Crie a apresentação no Google Slides ou no Canva. Use as cores e a fonte do [CONTEXTO.md, seção 4](../../CONTEXTO.md#4-estilo-visual). Letra grande.
2. Faça os 7 slides, nesta ordem:

   | # | Título | O que vai |
   |---|---|---|
   | 1 | Title | "Mike on Mars", 1 frase do que é, nome do time, nome do desafio, QR code do jogo |
   | 2 | Problem | o desafio em palavras simples: crianças de 7 a 12 anos sentirem as escolhas difíceis de uma missão real |
   | 3 | Solution | o jogo: cuidar de uma base em Marte, no navegador do celular, sem login e sem download |
   | 4 | How it works | 3 barras, construir, plantar, explorar, eventos com lado bom e lado ruim, sem game over + 1 print do jogo |
   | 5 | NASA data | DONKI (tempestades solares reais) + 25 cartas com fato e foto da NASA, com as fontes |
   | 6 | Impact | o que a criança aprende, grátis, 4 idiomas, nenhum dado da criança |
   | 7 | Team | nome do time e de cada pessoa, com a função |

3. No máximo 3 tópicos curtos por slide. Imagem grande, texto pequeno.
4. Imagens que podem: print do jogo, fotos das cartas (com o crédito embaixo, ex.: `Photo: NASA/JPL-Caltech`) e o QR code.
5. Imagem feita com IA? Marca d'água "Made with AI" visível e uma linha com o tipo `ia` no [creditos.csv](../../creditos.csv).
6. Número só se estiver no `cartas.csv` ou no CONTEXTO.md, com fonte.
7. Compartilhe como "Qualquer pessoa com o link pode ver" e copie o link.
8. Baixe o PDF e renomeie para `slides.pdf`:
   - Google Slides: Arquivo → Fazer download → Documento PDF.
   - Canva: Compartilhar → Baixar → PDF Padrão.
9. No GitHub, abra `conteudo/04-slides/`. Crie o `slides.md` (**Add file → Create new file**, modelo abaixo) e suba o PDF (**Add file → Upload files**). Sempre termine com **Commit changes**.
10. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

Modelo do `slides.md` (repita o bloco do slide até o 7):
```markdown
# Slides · Mike on Mars
Link: COLE AQUI O LINK DO GOOGLE SLIDES OU DO CANVA

## 1. Title
(o texto do slide, igual ao que está nele)
Imagem: (o que aparece e o crédito)
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `slides.pdf` | os 7 slides | `.pdf` |
| `slides.md` | link do Google Slides ou do Canva + o texto de cada slide | `.md` |

## Pronto quando
- [ ] São 7 slides, em inglês, na ordem da tabela.
- [ ] O slide 5 cita o DONKI e as fontes da NASA.
- [ ] Toda foto da NASA tem crédito no slide.
- [ ] O link abre numa aba anônima, sem login.
- [ ] `slides.pdf` abre e o `slides.md` tem o link e o texto dos 7 slides.

## Não pode
- Mais de 7 slides.
- Logo, bandeira ou marca da NASA (nem no slide de título).
- Foto ou vídeo de pessoa menor de 18. No slide do time, foto só de quem tem 18 anos ou mais; na dúvida, sem foto.
- Figuras e fotos do próprio Canva ou de banco de imagens: use só print do jogo, fotos da NASA e arte da Kenney.
- Número ou fato sem fonte, ou parágrafo longo.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/04-slides (o PASSO.md está junto).
Escreva o texto de 7 slides em inglês simples para os jurados do NASA Space Apps, nesta ordem: Title, Problem, Solution, How it works, NASA data, Impact, Team.
Regras: no máximo 3 tópicos curtos por slide; use só fatos do CONTEXTO.md e do cartas.csv, sempre com a fonte; não invente números; nada de logo da NASA; nenhuma foto de menor de 18.
Para cada slide, sugira 1 imagem: print do jogo, foto de carta da NASA (com crédito) ou o QR code.
Saída: só o slides.md, exatamente neste formato:
# Slides · Mike on Mars
Link: (deixe em branco)
## 1. Title
(texto)
Imagem: (sugestão)
... até o "## 7. Team".
[cole aqui o cartas.csv e os nomes e funções do time]
```
