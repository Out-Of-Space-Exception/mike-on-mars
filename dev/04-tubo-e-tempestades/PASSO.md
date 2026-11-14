# Dev · 04 · Tubo de amostra e tempestades

> **Em 1 frase:** explorar devolve um tubo de amostra que revela uma carta, e chegam tempestades solares reais do DONKI.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [dev/03-esqueleto](../03-esqueleto/PASSO.md); se já tiver: [conteudo/02-cartas](../../conteudo/02-cartas/PASSO.md), [design/04-cores-das-coisas](../../design/04-cores-das-coisas/PASSO.md)
- **Quem usa depois:** [dev/05-jogo-completo](../05-jogo-completo/PASSO.md)

## Por que importa
O tubo é o momento "uau" do jogo: a revelação da raridade prende a criança. A tempestade solar é o **dado real da NASA** que os jurados pedem. Sem ela, o projeto perde em Relevância e Validade.

## Leia antes
- [CONTEXTO.md](../../CONTEXTO.md), seção 3 (explorar, cartas, tabela de eventos) e seção 6 (fatos)
- [cartas.csv](../../conteudo/02-cartas/cartas.csv): colunas `raridade`, `como_ganha`, `onde`
- [dev/03-esqueleto](../03-esqueleto/PASSO.md), seção "Padrão do código"

## Passo a passo
1. **Explorar:** o botão Explorar gasta 20 de oxigênio. Com oxigênio abaixo de 20, mostrar `LOCK_OXYGEN` e o Mike não sai.
2. O Mike sai, some por 3 s e volta segurando um tubo.
3. **Sorteio:** comum 70%, raro 25%, lendário 5%. Vale só para as cartas com `como_ganha` = `tubo de amostra` ou `explorar` e `onde` = `Gale`. Carta repetida vira "+1" no álbum.
4. **Revelação:** o tubo treme (tween) e brilha na cor da raridade (`tubo-comum`, `tubo-raro` ou `tubo-lendario`, do `design/04`). Com um toque, abre a carta: foto real, nome e fato (via `tr()`). Toca o som `revelar-*`.
5. **Dados do DONKI:** rodar uma vez, em casa, um script que baixa do DONKI (api.nasa.gov) os eventos de 2024: CME com impacto em Marte e SEP. Salvar em `jogo/data/donki.json` com `date`, `kind` e `note`. Incluir sempre o evento real de 20/05/2024. Nenhuma chave de API vai para o repositório.
6. **Tempestade solar:** a cada 30 a 50 sóis (sorteado), escolher um evento do `donki.json`. O jogo pausa e mostra `EV_SOLAR_TITLE`, `EV_SOLAR_REAL` (com a data real) e a escolha:
   - **Escudo:** gasta 30 de energia, e o Mike segue livre.
   - **Mike fica em casa:** o explorar fica travado até o escudo voltar a 50.
7. Se a criança aguentou com o escudo levantado, há 10% de chance da carta lendária "Aurora em Marte" (`EV_AURORA`).
8. Publicar e avisar no grupo.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `donki.md` | de onde vieram os dados (URL sem a chave), data do download e quantos eventos | `.md` |
| o jogo em [jogo/](../../jogo/) | o tubo e a tempestade solar | projeto Godot |

## Pronto quando
- [ ] explorar gasta oxigênio e trava quando o oxigênio está baixo
- [ ] o tubo treme, brilha na cor certa e revela a carta com foto, nome e fato
- [ ] a tempestade mostra a **data real** e as 2 escolhas, e o jogo pausa
- [ ] a "Aurora em Marte" pode sair depois de aguentar com o escudo
- [ ] o `donki.md` diz de onde veio cada dado

## Não pode
- Inventar tempestade: toda tempestade solar do jogo vem do `donki.json`.
- Fingir que o dado é ao vivo: ele é arquivado (2024), e o jogo mostra a data real. O desafio pede essa honestidade.
- Punir: nada de perder itens ou cartas.
- Deixar chave de API no repositório ou no jogo.
- Sortear carta trancada ("em breve").

## Pedido pronto para a IA
```text
Siga o AGENTS.md, o CONTEXTO.md e o padrão do código do dev/03-esqueleto/PASSO.md.
Implemente [o tubo de amostra | a tempestade solar] como descrito no dev/04-tubo-e-tempestades/PASSO.md.
Textos só com tr() e chaves do conteudo/03-textos/textos.csv. Mostre só os arquivos que mudaram.
```
