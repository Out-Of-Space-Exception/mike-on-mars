# Design · 01 · O Mike

> **Em 1 frase:** escolher o boneco do Mike no pacote Mini Characters, da Kenney, a cor do traje e um acessório (ou detalhe) que seja só dele.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada
- **Quem usa depois:** [dev/03-esqueleto](../../dev/03-esqueleto/PASSO.md)

## Por que importa
O Mike é a cara do jogo: aparece na base, no logo, nas telas e no vídeo. Usando um boneco da Kenney, ele fica no mesmo estilo de todos os outros modelos 3D, e o jogo parece muito mais profissional.

## Leia antes
- [CONTEXTO, seção 2](../../CONTEXTO.md#2-o-projeto-em-1-minuto): quem é o Mike
- [CONTEXTO, seção 4](../../CONTEXTO.md#4-estilo-visual): o estilo visual
- [CONTEXTO, seção 5](../../CONTEXTO.md#5-tom-dos-textos): o humor do Mike (pula, treme, come pimenta)
- O pacote: [Mini Characters, da Kenney](https://kenney.nl/assets/mini-characters)

## Passo a passo
1. Abra https://kenney.nl/assets/mini-characters e clique em **Download** (doar é opcional).
2. Descompacte o `.zip`: botão direito → **Extrair tudo**.
3. Olhe as imagens de prévia do pacote e escolha 1 boneco para ser o Mike.
4. Ache o arquivo 3D desse boneco (de preferência o que termina em `.glb`) e copie o nome **letra por letra**, com a extensão.
   - Não aparece a extensão? No Explorador do Windows: **Exibir → Mostrar → Extensões de nomes de arquivos**.
5. Escolha a cor do traje. No Figma ou no Canva, clique na cor e copie o código hex (ex.: `#FF6B35`).
6. Escolha 1 acessório ou detalhe só dele (ex.: mochila, antena no capacete, luvas de outra cor). Se vier de outro pacote da Kenney, anote o pacote e o nome do arquivo.
7. Escreva 1 frase sobre o jeito do Mike.
8. Monte o `mike.png` no Canva ou no Figma: a prévia do boneco + um quadrado com a cor do traje + o acessório. Exporte em PNG.
9. Crie o `mike.md`: na pasta `design/01-mike` do GitHub, **Add file → Create new file**, cole o modelo abaixo preenchido e clique em **Commit changes**.
10. Suba o `mike.png`: na mesma pasta, **Add file → Upload files** → arraste o arquivo → **Commit changes**.
11. Abra o [creditos.csv](../../creditos.csv), clique no lápis, cole a linha abaixo no fim e clique em **Commit changes**. Se o acessório vier de outro pacote, coloque mais uma linha para ele.
12. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e avise o Dev no grupo.

Modelo do `mike.md`:
```text
# Mike
- Modelo: <nome-do-arquivo.glb> (Kenney Mini Characters)
- Cor do traje: #RRGGBB
- Acessório ou detalhe: <o que é> (<pacote> / <arquivo>, ou "só cor")
- Personalidade: <1 frase>
```

Linha do `creditos.csv`:
```text
modelo,Mini Characters (pacote 3D),Mike,Kenney,CC0,https://kenney.nl/assets/mini-characters,Design
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `mike.md` | nome do arquivo do modelo, cor do traje em hex, acessório ou detalhe (e de qual pacote/arquivo vem) e 1 frase de personalidade | `.md` |
| `mike.png` | print ou prévia do boneco escolhido, com a cor e o acessório ao lado | `.png` |

## Pronto quando
- [ ] O nome do modelo no `mike.md` é igual ao do pacote, letra por letra.
- [ ] A cor do traje tem `#` e 6 letras/números.
- [ ] O `mike.png` mostra o boneco, a cor do traje e o acessório.
- [ ] O pacote (e o do acessório, se tiver) está no `creditos.csv`.
- [ ] A caixinha está marcada no TAREFAS.md.

## Não pode
- Mascote verde ou de 1 olho: lembra o Mike Wazowski. Por isso, nada de traje verde.
- Copiar personagem de filme ou jogo (nem "parecido de propósito").
- Boneco que não seja do Mini Characters: quebra o estilo.
- Logo ou bandeira da NASA no traje.
- Imagem feita por IA sem marca d'água.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo.
Tarefa: Design · 01 · O Mike. Escolhemos o boneco <NOME-DO-ARQUIVO> do pacote Kenney Mini Characters.
Sugira 3 opções, cada uma com: cor do traje em hex, 1 acessório ou detalhe só dele e 1 frase de personalidade.
Regras: nada verde, nada de 1 olho, nada parecido com personagem de filme ou jogo, combinar com o céu caramelo de Marte e não parecer coisa de bebê.
Depois que eu escolher, responda só com o mike.md pronto, neste formato:
# Mike
- Modelo: <nome-do-arquivo.glb> (Kenney Mini Characters)
- Cor do traje: #RRGGBB
- Acessório ou detalhe: <o que é> (<pacote> / <arquivo>, ou "só cor")
- Personalidade: <1 frase>
Não invente nome de arquivo da Kenney: se não souber, escreva CONFERIR.
```
