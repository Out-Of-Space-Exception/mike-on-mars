# Design · 05 · As telas

> **Em 1 frase:** desenhar no Figma ou no Canva como cada uma das 7 telas do jogo vai ficar.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [01-mike](../01-mike/PASSO.md) e [02-cores-e-fonte](../02-cores-e-fonte/PASSO.md)
- **Quem usa depois:** [dev/07-acabamento-e-congelamento](../../dev/07-acabamento-e-congelamento/PASSO.md)

## Por que importa
É isso que faz o jogo parecer profissional. As telas são conceitos: o Dev copia o visual no projeto final. Quanto mais claro o desenho, mais perto disso o jogo fica.

## Leia antes
- [CONTEXTO, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): as 3 barras, o tubo, as cartas e o cartão-postal
- [CONTEXTO, eventos](../../CONTEXTO.md#eventos-sorteados-todo-evento-tem-lado-ruim-e-lado-bom): a tempestade solar e a escolha
- [CONTEXTO, seção 5](../../CONTEXTO.md#5-tom-dos-textos): ícone + 1 palavra, mensagens sempre positivas
- [textos.csv](../../conteudo/03-textos/textos.csv): os textos do jogo (use a coluna `en`)
- [cores.csv](../02-cores-e-fonte/cores.csv), [fonte.md](../02-cores-e-fonte/fonte.md) e [mike.png](../01-mike/mike.png)

## Passo a passo
1. Crie a tela no tamanho do jogo, **retrato, 720 × 1280**:
   - Figma: ferramenta **Frame** (tecla `F`) e, no painel da direita, W `720` e H `1280`.
   - Canva: **Criar um design → Tamanho personalizado → 720 × 1280 px**.
2. Faça 1 frame (ou página) para cada tela da tabela abaixo.
3. Use só as 5 cores do `cores.csv` e a fonte do `fonte.md`.
4. Para mostrar a base e o Mike, use prints das prévias da Kenney. No lugar da foto da NASA da carta, um retângulo escrito `NASA photo` já serve.
5. Botões grandes para dedo de criança (pelo menos 96 × 96 px), com ícone + 1 palavra. Ícones: [Game Icons](https://kenney.nl/assets/game-icons) ou [UI Pack Sci-Fi](https://kenney.nl/assets/ui-pack-sci-fi).
6. Deixe uma margem livre nas bordas: o celular tem câmera e barras em cima e embaixo.
7. Copie os textos da coluna `en` do `textos.csv`. Nada de texto longo.
8. Exporte cada tela em PNG com o nome da tabela:
   - Figma: selecione o frame → **Export** (painel da direita) → PNG → **Export**.
   - Canva: **Compartilhar → Baixar → PNG** e escolha a página.
9. Libere o link para quem tiver o link poder ver (Figma: **Share**; Canva: **Compartilhar**).
10. Crie o `telas.md` (modelo abaixo) e suba os 7 PNG: na pasta `design/05-telas`, **Add file → Upload files** → arraste → **Commit changes**.
11. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e avise o Dev no grupo.

| Arquivo | O que aparece | Textos (do `textos.csv`) |
|---|---|---|
| `tela-inicial.png` | logo, Mike e botão de jogar | Mike on Mars · Play |
| `hud-barras.png` | a base, as 3 barras em cima e os botões embaixo | Energy · Oxygen · Shield · Sol 12 · Gale Crater · Build · Explore · Album · Photo |
| `album.png` | as 40 cartas em grade; as que faltam ficam apagadas; a borda de cada carta tem a cor da raridade | 8/40 cards |
| `carta.png` | foto real da NASA + nome + 1 linha de fato | New card! · This is real: · MOXIE · Turns Mars air into oxygen. |
| `aviso-tempestade.png` | aviso de tempestade solar com 2 escolhas | Solar storm coming! · Raise the shield? · Shield (uses energy) · Mike stays inside |
| `tubo-revelacao.png` | o tubo de amostra tremendo e brilhando na cor da raridade | Tap to open! · Rare |
| `cartao-postal.png` | print da base com moldura de cartão-postal | Sol 47 · Gale Crater |

Modelo do `telas.md`:
```text
# Telas
- Link: <link do Figma ou do Canva>
- tela-inicial.png: <1 linha sobre a tela>
- (1 linha para cada uma das outras 6 telas)
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `tela-inicial.png`, `hud-barras.png`, `album.png`, `carta.png`, `aviso-tempestade.png`, `tubo-revelacao.png`, `cartao-postal.png` | 1 tela cada, retrato, 720 × 1280 | `.png` |
| `telas.md` | link do Figma/Canva e 1 linha sobre cada tela | `.md` |

## Pronto quando
- [ ] Os 7 PNG estão aqui, com os nomes da tabela, em 720 × 1280 (botão direito → **Propriedades → Detalhes**).
- [ ] O link do `telas.md` abre sem pedir permissão.
- [ ] Todo texto nas telas está em inglês e veio do `textos.csv`.
- [ ] Todo botão tem ícone + 1 palavra e é grande para o dedo.
- [ ] Só aparecem as 5 cores e a fonte escolhidas.

## Não pode
- Tela deitada (paisagem) ou de outro tamanho.
- Texto em português ou texto longo na tela.
- Mensagem que culpa a criança ou "game over".
- Logo da NASA, foto de criança ou imagem de IA sem marca d'água.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo, junto com o textos.csv, o cores.csv e o fonte.md.
Tarefa: Design · 05 · As telas. A tela é retrato, 720 x 1280.
Para cada tela (tela inicial, 3 barras sobre a base, álbum das 40 cartas, carta, aviso de tempestade solar com a escolha, revelação do tubo de amostra, cartão-postal "Sol 47 · Gale Crater"), liste de cima para baixo o que aparece, qual cor do cores.csv usar e quais textos da coluna en do textos.csv entram. Botões com ícone + 1 palavra, de pelo menos 96 x 96 px. Não invente texto novo: se faltar, escreva CONFERIR.
Depois, responda com o telas.md pronto: 1ª linha "# Telas", uma linha "- Link: <link>" e 1 linha por tela no formato "- nome-do-arquivo.png: descrição".
```
