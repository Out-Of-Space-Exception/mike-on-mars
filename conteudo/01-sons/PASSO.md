# Conteúdo · 01 · Os sons

> **Em 1 frase:** achar, renomear e dar crédito aos sons do jogo listados no `sons.csv`.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** nada
- **Quem usa depois:** [dev/06-receber-entregas](../../dev/06-receber-entregas/PASSO.md), [conteudo/08-cenas-e-creditos](../../conteudo/08-cenas-e-creditos/PASSO.md)

## Por que importa
Som faz o jogo parecer pronto: o "ding" da carta nova é metade da graça. Mas som sem licença ou sem crédito não entra, e o Space Apps pede a lista de todos os recursos usados.

## Leia antes
- [CONTEXTO.md, seção 3](../../CONTEXTO.md#3-como-o-jogo-funciona): quando cada som toca no jogo.
- [CONTEXTO.md, seção 7](../../CONTEXTO.md#7-regras-do-space-apps-resumo): regras do Space Apps.
- [sons.csv](sons.csv): os 24 sons. Os 14 `1 essencial` vêm primeiro.
- [creditos.csv](../../creditos.csv) e a regra 6 do [AGENTS.md](../../AGENTS.md#3-as-regras).

## Passo a passo
1. Abra o [sons.csv](sons.csv). Faça primeiro as 14 linhas `1 essencial`. As `2 se der tempo` ficam para o fim.
2. Baixe os pacotes da Kenney (todos CC0) e ouça os sons:
   - Sci-Fi Sounds: https://kenney.nl/assets/sci-fi-sounds
   - Interface Sounds: https://kenney.nl/assets/interface-sounds
   - Impact Sounds, Digital Audio e Music Jingles: busque o nome em https://kenney.nl/assets
3. Para cada linha, escolha o som que mais combina com a coluna `como_soa`.
4. Copie o som para uma pasta `sons` no seu computador e **renomeie exatamente** como na coluna `arquivo` (ex.: `toque-botao.ogg`).
5. Não achou na Kenney? Procure em:
   - https://freesound.org: filtre a licença por **Creative Commons 0** ou **Attribution**. Precisa de conta para baixar.
   - https://opengameart.org: filtre por **CC0**, **CC-BY 3.0** ou **CC-BY 4.0**.
   - Anote **na hora** o link da página, o autor e a licença.
6. Som em `.wav` ou `.mp3`? Converta para `.ogg` (ex.: abra no Audacity, que é grátis, e exporte como OGG). Não deu? Suba o `.wav` com o mesmo nome e avise a dupla de Dev.
7. Suba os sons: no GitHub, abra `conteudo/01-sons/` → **Add file → Upload files** → arraste a **pasta `sons` inteira** → **Commit changes**. Para mandar mais depois, abra `conteudo/01-sons/sons/` e repita.
8. Preencha a coluna `fonte_e_licenca` do `sons.csv` no formato `pacote ou link · autor · licença`, sem vírgula. Ex.: `Kenney Interface Sounds · Kenney · CC0`.
9. Ponha no [creditos.csv](../../creditos.csv) uma linha por pacote da Kenney ou por som avulso. Ex.:
   `som,Kenney Interface Sounds,toque-botao.ogg; colher.ogg,Kenney,CC0,https://kenney.nl/assets/interface-sounds,Conteúdo`
10. Usou IA? Ponha também uma linha com o tipo `ia` no `creditos.csv`.
11. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

**Como editar um `.csv`:**
- **No GitHub:** abra o arquivo → lápis ✏️ → edite → **Commit changes**.
- **No Google Sheets:** Arquivo → Importar → Fazer upload (desmarque "Converter texto em números, datas e fórmulas"). Depois: Arquivo → Fazer download → Valores separados por vírgula (.csv). Renomeie para o mesmo nome (`sons.csv`) e suba com **Add file → Upload files → Commit changes**.
- **Uma pessoa por arquivo de cada vez.** Avise no grupo quando pegar e quando soltar o arquivo.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `sons/` | um arquivo por linha do `sons.csv`, com o nome **exato** da coluna `arquivo` | `.ogg` |
| `sons.csv` | coluna `fonte_e_licenca` preenchida em toda linha que já tem som | `.csv` |
| [`creditos.csv`](../../creditos.csv) (na raiz) | 1 linha por pacote ou som de fora | `.csv` |

## Pronto quando
- [ ] Os 14 sons `1 essencial` estão em `conteudo/01-sons/sons/`.
- [ ] Cada nome é igual ao da coluna `arquivo` (minúsculas, hífen, `.ogg`).
- [ ] Toda linha com som tem `fonte_e_licenca` preenchida.
- [ ] Todo pacote ou som de fora tem linha no `creditos.csv`.
- [ ] Todas as licenças são CC0 ou CC-BY.
- [ ] Ouvi todos: nenhum assusta, nenhum é alto demais.

## Não pode
- Licença CC-BY-NC, CC-BY-SA, GPL, "grátis para uso pessoal" ou sem licença.
- Música ou som de jogo, filme ou desenho famoso.
- Voz de pessoa menor de 18. Na dúvida, escolha som sem voz.
- Mudar o cabeçalho ou a coluna `arquivo` do `sons.csv`.
- Nome diferente: `Toque Botao.ogg`, `toque_botao.ogg`, `toque-botão.ogg`.
- Alarme que dá medo: o `alerta.ogg` avisa sem assustar.
- Duas pessoas editando o mesmo `.csv` ao mesmo tempo.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/01-sons (o PASSO.md está junto).
Vou colar o sons.csv e, para cada som que escolhi: o nome do arquivo, de onde veio (pacote da Kenney ou link do freesound/opengameart), o autor e a licença que aparecem na página.
Faça só isto:
1. Devolva o sons.csv inteiro, com o mesmo cabeçalho e as mesmas linhas, mudando só a coluna fonte_e_licenca, no formato "pacote ou link · autor · licença", sem vírgula.
2. Devolva só as linhas novas do creditos.csv (colunas tipo,o_que,arquivo_ou_uso,autor,licenca,link,dupla), com tipo "som" e dupla "Conteúdo". Uma linha por pacote da Kenney ou por som avulso. Separe vários arquivos com "; ".
3. Diga quais sons não são CC0 nem CC-BY.
4. Para os sons que ainda faltam, sugira 3 termos de busca em inglês para o freesound.org.
Não invente autor, link nem licença: se faltar, escreva CONFERIR.
Saída: 2 blocos de código (sons.csv e creditos.csv) e uma lista curta para os itens 3 e 4.
[cole aqui o sons.csv e as suas anotações]
```
