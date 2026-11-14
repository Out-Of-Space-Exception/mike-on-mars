# Design · 03 · Os itens do jogo

> **Em 1 frase:** baixar 4 pacotes da Kenney e anotar o nome do arquivo de cada item do jogo, inclusive as decorações da base.

- **Dupla:** Design (Maria Fernanda e Thais)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada
- **Quem usa depois:** [04-cores-das-coisas](../04-cores-das-coisas/PASSO.md), [dev/03-esqueleto](../../dev/03-esqueleto/PASSO.md), [dev/07-acabamento-e-congelamento](../../dev/07-acabamento-e-congelamento/PASSO.md)

## Por que importa
Cada pacote tem dezenas de modelos. Com a lista pronta, o Dev pega a pasta inteira e usa só o que vocês escolheram, sem perder tempo procurando. E tudo fica no mesmo estilo.

## Leia antes
- [CONTEXTO, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): o que o jogador planta, constrói e acha
- [CONTEXTO, seção 4](../../CONTEXTO.md#4-estilo-visual): os pacotes da Kenney
- [cartas.csv](../../conteudo/02-cartas/cartas.csv): as plantas, os minerais e as máquinas

## Passo a passo
1. Baixe os 4 pacotes (botão **Download**; doar é opcional): [Food Kit](https://kenney.nl/assets/food-kit), [Nature Kit](https://kenney.nl/assets/nature-kit), [Space Kit](https://kenney.nl/assets/space-kit) e [Skyboxes](https://kenney.nl/assets/skyboxes).
2. Descompacte cada `.zip` no seu computador (botão direito → **Extrair tudo**). **Não suba os pacotes no GitHub.**
3. Ligue as extensões no Windows: Explorador → **Exibir → Mostrar → Extensões de nomes de arquivos**.
4. Para cada item da tabela abaixo, ache o modelo pelas imagens de prévia e copie o nome do arquivo 3D **letra por letra**, com a extensão (de preferência `.glb`).
5. Procure também rabanete, couve e batata (são cartas novas). Não achou? Escreva `NAO-TEM`.
6. Escolha pelo menos 3 decorações para a base: bandeira, luzinhas e vaso. Quer mais? Use o nome `decoracao-<coisa>`.
7. Crie o `itens.csv`: na pasta `design/03-itens-do-jogo` do GitHub, **Add file → Create new file**, cole o modelo preenchido e clique em **Commit changes**.
8. Abra o [creditos.csv](../../creditos.csv), clique no lápis e cole 1 linha por pacote usado (modelo abaixo). Clique em **Commit changes**.
9. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md) e avise o Dev no grupo.

| `item_do_jogo` | Pacote | O que procurar |
|---|---|---|
| `alface`, `pimenta` | Food Kit | alface e pimenta |
| `rabanete`, `couve`, `batata` | Food Kit (olhe também o Nature Kit) | se não tiver, `NAO-TEM` |
| `zinia` | Nature Kit | uma flor |
| `hematita`, `enxofre`, `leopardo` | Nature Kit | 3 pedras diferentes (dica: a hematita de verdade são bolinhas) |
| `painel-solar` | Space Kit | painel solar |
| `moxie`, `rtg` | Space Kit | 2 máquinas pequenas diferentes (o MOXIE e a bateria nuclear) |
| `ceu` | Skyboxes | 1 céu (pode vir como imagem: anote o nome que vier) |
| `decoracao-bandeira`, `decoracao-luzinhas`, `decoracao-vaso` | qualquer um dos 4 | as decorações |

Modelo do `itens.csv` (as 2 linhas de exemplo mostram o jeito; ponha todas):
```text
item_do_jogo,pacote,arquivo_do_modelo,observacao
alface,Food Kit,<nome-do-arquivo.glb>,
rabanete,Food Kit,NAO-TEM,não achei no Food Kit nem no Nature Kit
```

Linha do `creditos.csv` (troque o nome e o link para cada pacote):
```text
modelo,Food Kit (pacote 3D),itens do jogo,Kenney,CC0,https://kenney.nl/assets/food-kit,Design
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `itens.csv` | colunas `item_do_jogo,pacote,arquivo_do_modelo,observacao` e 1 linha por item, inclusive as decorações | `.csv` |

## Pronto quando
- [ ] A 1ª linha é exatamente `item_do_jogo,pacote,arquivo_do_modelo,observacao`.
- [ ] Tem 1 linha para cada item da tabela (16 no mínimo), com o `item_do_jogo` escrito igual.
- [ ] Todo `arquivo_do_modelo` foi copiado do pacote, ou é `NAO-TEM`.
- [ ] O GitHub mostra o `itens.csv` como tabela (se der erro, falta ou sobra vírgula).
- [ ] Os 4 pacotes estão no `creditos.csv`.
- [ ] Nenhum `.zip` ou modelo 3D foi subido.

## Não pode
- Subir os pacotes ou os modelos no repositório: só os nomes.
- Adivinhar nome de arquivo.
- Vírgula dentro da observação (quebra o CSV); salvar o CSV no Excel.
- Montar os módulos da base (Modular Space Kit) ou procurar o Ingenuity: isso é do Dev.
- Bandeira ou logo da NASA nas decorações.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o CONTEXTO.md do repositório https://github.com/Out-Of-Space-Exception/mike-on-mars. Se você não consegue abrir links, eu colo os arquivos abaixo.
Tarefa: Design · 03 · Os itens do jogo. Abaixo está o que escolhemos: item do jogo, pacote e nome do arquivo.
[cole aqui suas anotações]
Monte o itens.csv com a 1ª linha exatamente item_do_jogo,pacote,arquivo_do_modelo,observacao e 1 linha por item, nesta ordem: alface, pimenta, rabanete, couve, batata, zinia, hematita, enxofre, leopardo, painel-solar, moxie, rtg, ceu, decoracao-bandeira, decoracao-luzinhas, decoracao-vaso (e as outras decoracao-... que eu listar).
Use só os nomes de arquivo que eu colei, sem mudar nenhuma letra. Onde eu não achei, escreva NAO-TEM. Sem vírgula dentro da observação.
Responda só com o conteúdo do itens.csv.
```
