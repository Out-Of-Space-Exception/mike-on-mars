# Design · 07 · Ícones dos botões

> **Em 1 frase:** escolher, nos pacotes da Kenney, o ícone de cada um dos 8 botões do jogo.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada
- **Quem usa depois:** [dev/07-acabamento-e-congelamento](../../dev/07-acabamento-e-congelamento/PASSO.md)

## Por que importa
Todo botão do jogo é ícone + 1 palavra, e uma criança de 7 anos entende pelo ícone antes de ler. Usando os pacotes da Kenney, os ícones ficam no mesmo estilo do resto do jogo.

## Leia antes
- [CONTEXTO, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): as 3 barras, construir, plantar, explorar, álbum e cartão-postal
- [CONTEXTO, seção 5](../../CONTEXTO.md#5-tom-dos-textos): botões com ícone + 1 palavra
- [textos.csv](../../conteudo/03-textos/textos.csv): a palavra que vai ao lado de cada ícone

## Passo a passo
1. Baixe os 2 pacotes (botão **Download**; doar é opcional): [Game Icons](https://kenney.nl/assets/game-icons) e [UI Pack Sci-Fi](https://kenney.nl/assets/ui-pack-sci-fi).
2. Descompacte cada `.zip` (botão direito → **Extrair tudo**). **Não suba os pacotes no GitHub.**
3. Ligue as extensões no Windows: Explorador → **Exibir → Mostrar → Extensões de nomes de arquivos**.
4. Olhe as imagens de prévia e, para cada botão da tabela, escolha o ícone que uma criança entende sem ler. Teste: mostre só o ícone para alguém do time e pergunte "o que esse botão faz?".
5. Prefira ícones do mesmo estilo (todos cheios ou todos de contorno, mesma grossura de linha).
6. Ache o arquivo `.png` de cada ícone e copie o nome **letra por letra**, com a extensão. Se o mesmo ícone vier em mais de uma versão (tamanho ou cor), anote com a pasta: `pasta/arquivo.png`.
   - Para a IA ajudar: abra a pasta, aperte `Ctrl+A` e depois `Ctrl+Shift+C` (copia os nomes) e cole no pedido do fim desta página.
7. Não achou nada bom? Escreva `NAO-TEM` na coluna `arquivo` e avise no grupo.
8. Crie o `icones.csv`: na pasta `design/07-icones-dos-botoes` do GitHub, **Add file → Create new file**, cole o modelo preenchido e clique em **Commit changes**.
9. Abra o [creditos.csv](../../creditos.csv), clique no lápis e coloque 1 linha por pacote usado (modelo abaixo).
10. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e avise o Dev no grupo.

| `botao` | O que o botão faz | Palavra ao lado |
|---|---|---|
| `energia` | barra de energia | Energy |
| `oxigenio` | barra de oxigênio | Oxygen |
| `escudo` | barra do escudo (proteção contra a radiação do Sol) | Shield |
| `estufa` | abre a estufa para plantar | Greenhouse |
| `explorar` | o Mike sai para explorar | Explore |
| `construir` | a oficina: construir na base | Build |
| `album` | o álbum das cartas | Album |
| `foto` | o cartão-postal da base | Photo |

Modelo do `icones.csv` e linha do `creditos.csv`:
```text
botao,pacote,arquivo
energia,Game Icons,<arquivo.png>
oxigenio,<pacote>,<arquivo.png>
escudo,<pacote>,<arquivo.png>
estufa,<pacote>,<arquivo.png>
explorar,<pacote>,<arquivo.png>
construir,<pacote>,<arquivo.png>
album,<pacote>,<arquivo.png>
foto,<pacote>,<arquivo.png>

icone,Game Icons (pacote de ícones),ícones dos botões,Kenney,CC0,https://kenney.nl/assets/game-icons,Design
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `icones.csv` | colunas `botao,pacote,arquivo` e 1 linha por botão (os 8 da tabela) | `.csv` |

## Pronto quando
- [ ] A 1ª linha é exatamente `botao,pacote,arquivo`.
- [ ] Tem as 8 linhas, com o `botao` escrito igual à tabela.
- [ ] Todo `arquivo` foi copiado do pacote, ou é `NAO-TEM`.
- [ ] Os 8 ícones, lado a lado, parecem da mesma família.
- [ ] Os pacotes usados estão no `creditos.csv`.

## Não pode
- Ícone de outro site (as licenças mudam) ou emoji.
- Mudar a grafia da coluna `botao`: o Dev procura por esse nome.
- Ícone com logo da NASA.
- Salvar o CSV no Excel; subir os pacotes no repositório.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo.
Tarefa: Design · 07 · Ícones dos botões. Abaixo está a lista de nomes de arquivos dos pacotes Kenney Game Icons e UI Pack Sci-Fi (copiei da pasta).
[cole aqui a lista]
Para cada botão (energia, oxigenio, escudo, estufa, explorar, construir, album, foto), sugira os 2 melhores arquivos da lista para uma criança de 7 a 12 anos entender sem ler. Use só nomes que estão na lista, sem mudar nenhuma letra.
Depois que eu escolher, responda só com o icones.csv: 1ª linha exatamente botao,pacote,arquivo e as 8 linhas nesta ordem. Onde não tiver opção boa, escreva NAO-TEM.
```
