# Dev · 07 · Acabamento e congelamento

> **Em 1 frase:** colocar arte, cores, sons e os 4 idiomas, caprichar nos primeiros 60 segundos e, depois da 1h, congelar.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [dev/05-jogo-completo](../05-jogo-completo/PASSO.md), [dev/06-receber-entregas](../06-receber-entregas/PASSO.md)
- **Quem usa depois:** [dev/08-bugs](../08-bugs/PASSO.md), [dev/09-video-e-pagina](../09-video-e-pagina/PASSO.md)

## Por que importa
Os jurados decidem nos primeiros segundos. Arte, som e uma primeira jogada clara valem mais do que uma função nova. O congelamento protege o envio das 7h.

## Leia antes
- [CONTEXTO.md](../../CONTEXTO.md), seções 4 (estilo) e 5 (tom)
- tudo o que o Design entregou: [design/](../../design/)
- [conteudo/01-sons/sons.csv](../../conteudo/01-sons/sons.csv)

## Passo a passo
1. Aplicar as cores do `design/02` e do `design/04` no `ui/theme.tres` e nos modelos.
2. Trocar as caixas provisórias pelos modelos escolhidos (`design/03`) e pelo Mike final (`design/01`).
3. Montar as telas como nos desenhos do `design/05`, com a fonte do `design/02` e os ícones do `design/07`.
4. Ligar todos os sons essenciais (prioridade 1 no `sons.csv`) e a música.
5. Primeiros 60 segundos: `TUT_BUILD` e `TUT_EXPLORE` aparecem na hora certa. A criança constrói, planta e abre um tubo sem ler nada longo.
6. Conferir os 4 idiomas.
7. Publicar e criar a tag `congelado` (`git tag congelado && git push --tags`). Avisar no grupo: "a partir de agora, só conserto".

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| o jogo em [jogo/](../../jogo/) | a versão com arte, sons e idiomas | projeto Godot |
| tag `congelado` | a versão congelada no Git | tag |

## Pronto quando
- [ ] nenhuma caixa provisória aparece na tela
- [ ] os sons essenciais tocam
- [ ] uma pessoa de fora entende o que fazer em 60 segundos
- [ ] a tag `congelado` existe

## Não pode
- Depois do congelamento: função nova, troca grande de arte ou mudança de balanceamento que não seja conserto.

## Pedido pronto para a IA
```text
Siga o AGENTS.md e o padrão do código do dev/03-esqueleto/PASSO.md. Aplique [cores | telas | sons]
a partir dos arquivos de design/ e conteudo/ indicados no dev/07-acabamento-e-congelamento/PASSO.md.
Não mude regras do jogo. Mostre só os arquivos que mudaram.
```
