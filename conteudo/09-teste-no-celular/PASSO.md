# Conteúdo · 09 · Teste no celular

> **Em 1 frase:** jogar no celular, achar os bugs e anotar cada um de um jeito que a dupla de Dev consiga consertar.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** o jogo publicado no link ([dev/05-jogo-completo](../../dev/05-jogo-completo/PASSO.md), ou qualquer versão que já esteja no ar)
- **Quem usa depois:** [dev/08-bugs](../../dev/08-bugs/PASSO.md)

## Por que importa
Jurados e crianças vão abrir o jogo no celular. Bug que só aparece no celular a dupla de Dev não vê no computador. Bug bem anotado é bug consertado rápido.

## Leia antes
- [CONTEXTO.md, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): o que o jogo tem que fazer.
- [textos.csv](../../conteudo/03-textos/textos.csv) e [cartas.csv](../../conteudo/02-cartas/cartas.csv): o que tem que aparecer na tela.
- O jogo: https://out-of-space-exception.github.io/mike-on-mars/ (ou o QR code do [README.md](../../README.md)).

## Passo a passo
1. Abra o link no celular. Se der, teste em mais de um: um Android e um iPhone, em navegadores diferentes.
2. Jogue seguindo esta lista e anote tudo o que der errado:
   - [ ] O jogo abre e carrega.
   - [ ] Construir: toca no item, toca no chão. Depois mover, melhorar e remover.
   - [ ] Plantar e colher na estufa.
   - [ ] Explorar: o tubo treme, abre e mostra a carta.
   - [ ] Álbum: a carta nova aparece e a conta `n/25` sobe.
   - [ ] Eventos (tempestade solar, poeira, noite congelante, sem sinal): aparecem e dá para escolher.
   - [ ] Barra baixa só trava ou desacelera a ação, sem game over.
   - [ ] Fechar e abrir de novo: a base continua salva e aparece o aviso "enquanto você estava fora".
   - [ ] Trocar o idioma: testar os 4.
   - [ ] Som liga e desliga. Foto (cartão-postal) funciona.
   - [ ] Girar o celular não quebra a tela.
3. Confira os textos e os fatos:
   - [ ] Nenhum texto cortado ou saindo da tela.
   - [ ] Nenhum código no lugar do texto (ex.: `BTN_PLAY`) e nenhum `{n}` aparecendo.
   - [ ] Nome, fato e foto de cada carta que você ganhou iguais ao `cartas.csv`.
   - [ ] Acentos certos (ã, é, ç, ñ, è).
4. Texto errado? Corrija no `textos.csv` ou no `cartas.csv` **e** anote no `bugs.md`, para a Dev puxar de novo.
5. Crie o arquivo no GitHub: abra `conteudo/09-teste-no-celular/` → **Add file → Create new file** → nome `bugs.md` → cole o modelo → **Commit changes**.
6. Um item por problema, no formato do modelo. Os que travam o jogo vão primeiro.
7. Tem print? Suba nesta pasta (**Add file → Upload files → Commit changes**) como `bug-01.png`, `bug-02.png`... e cite no item.
8. Para pôr mais bugs depois: abra o `bugs.md` → lápis ✏️ → edite → **Commit changes**. **Uma pessoa por arquivo de cada vez.**
9. Avise a dupla de Dev no grupo e marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

Modelo do `bugs.md`:
```markdown
# Bugs · teste no celular

### Bug 1 · O botão Explorar não responde (EXEMPLO: apague e use como modelo)
- **O que eu fiz:** toquei em Explore com a barra de oxigênio cheia.
- **O que eu esperava:** o Mike sair para explorar.
- **O que aconteceu:** nada; o botão não mudou e não tocou som.
- **Celular usado:** Samsung Galaxy A15, Chrome
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `bugs.md` | um item por problema: o que eu fiz / o que eu esperava / o que aconteceu / celular usado | `.md` |

## Pronto quando
- [ ] Joguei a lista toda em pelo menos 1 celular.
- [ ] Conferi os textos e as cartas que consegui ganhar.
- [ ] Todo bug tem os 4 campos preenchidos.
- [ ] Cada item fala de um problema só.
- [ ] A dupla de Dev foi avisada no grupo.

## Não pode
- Juntar vários problemas num item só.
- Escrever só "não funciona", sem dizer o que fez.
- Mexer no jogo ou no código (é da dupla de Dev).
- Filmar ou fotografar criança jogando.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/09-teste-no-celular (o PASSO.md está junto).
Vou colar minhas anotações soltas do teste no celular. Organize em itens para o bugs.md, um item por problema, exatamente neste formato:
### Bug N · resumo curto
- **O que eu fiz:**
- **O que eu esperava:**
- **O que aconteceu:**
- **Celular usado:**
Ponha primeiro os que travam o jogo. Não invente bug nem detalhe: se faltar informação, escreva CONFERIR.
Saída: só o Markdown dos itens.
[cole aqui suas anotações]
```
