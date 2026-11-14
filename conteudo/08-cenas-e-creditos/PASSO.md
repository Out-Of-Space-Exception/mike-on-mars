# Conteúdo · 08 · Cenas e créditos

> **Em 1 frase:** dizer à dupla de Dev quais cenas gravar e deixar o `creditos.csv` completo.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [conteudo/07-roteiro-do-video](../../conteudo/07-roteiro-do-video/PASSO.md)
- **Quem usa depois:** [dev/09-video-e-pagina](../../dev/09-video-e-pagina/PASSO.md)

## Por que importa
A dupla de Dev grava a gameplay de uma vez. Cena que não está na lista não entra no vídeo. E o Space Apps pede a lista de todos os recursos: crédito faltando é regra quebrada.

## Leia antes
- [roteiro.md](../../conteudo/07-roteiro-do-video/roteiro.md): as cenas do vídeo.
- [creditos.csv](../../creditos.csv): `tipo,o_que,arquivo_ou_uso,autor,licenca,link,dupla`.
- [sons.csv](../../conteudo/01-sons/sons.csv) e [cartas.csv](../../conteudo/02-cartas/cartas.csv): os sons e as fotos usados.
- [CONTEXTO.md, seção 4](../../CONTEXTO.md#4-estilo-visual): pacotes da Kenney, modelo do Ingenuity e fonte.

## Passo a passo
**Parte 1: as cenas**
1. Abra o `roteiro.md`. Cada linha da tabela vira uma cena para gravar: 4 ou 5 cenas.
2. Para cada cena, escreva:
   - o que mostrar;
   - quanto tempo ela fica no vídeo (peça para gravar o dobro, para ter sobra);
   - o que precisa estar acontecendo no jogo (ex.: estufa com alface pronta para colher; tubo prestes a abrir; alerta de tempestade solar na tela).
3. Combine com a dupla de Dev o formato da gravação (celular em pé ou deitado).
4. Crie o arquivo no GitHub: abra `conteudo/08-cenas-e-creditos/` → **Add file → Create new file** → nome `cenas.md` → cole o modelo abaixo preenchido → **Commit changes**.

**Parte 2: os créditos**

5. Abra o [creditos.csv](../../creditos.csv) e confira se tem linha para:
   - cada pacote ou som da pasta `conteudo/01-sons/sons/`;
   - cada foto da pasta `conteudo/02-cartas/fotos/`;
   - cada pacote da Kenney usado no jogo e a fonte do Google Fonts;
   - o modelo 3D do Ingenuity (NASA/JPL-Caltech);
   - a Godot e o DONKI (já estão lá);
   - cada uso de IA, de todas as duplas (tipo `ia`).
6. Em cada linha, confira: autor, licença (CC0, CC-BY ou NASA) e link preenchidos, e o link abre.
7. Faltou linha de outra dupla? Avise no grupo. Se a dupla pedir, ponha você mesmo a linha, com o nome dela na coluna `dupla`.
8. Mudou algo nos créditos? Atualize também o "References" e o "Use of AI" do [pagina.md](../../conteudo/06-pagina-do-projeto/pagina.md).
9. Para editar o `creditos.csv`: abra no GitHub → lápis ✏️ → edite → **Commit changes**. **Uma pessoa por arquivo de cada vez.**
10. Marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

Modelo do `cenas.md`:
```markdown
# Cenas para gravar · Mike on Mars

| # | O que mostrar | Tempo no vídeo | O que precisa estar acontecendo no jogo | Linha do roteiro |
|---|---|---|---|---|
| 1 | Mike na cratera Gale | 4 s | jogo novo, céu de dia (caramelo) | 0–4 s |
| 2 | ... | ... | ... | ... |
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `cenas.md` | 4 ou 5 cenas: o que mostrar, quanto tempo e o que precisa estar acontecendo no jogo | `.md` |
| [`creditos.csv`](../../creditos.csv) (na raiz) | conferido: sem linha faltando e sem célula vazia | `.csv` |

## Pronto quando
- [ ] O `cenas.md` tem 4 ou 5 cenas, na ordem do roteiro.
- [ ] A soma dos tempos dá 30 s ou menos.
- [ ] Toda cena diz o que precisa estar acontecendo no jogo.
- [ ] Todo som, foto, modelo, fonte e uso de IA tem linha no `creditos.csv`.
- [ ] Nenhuma célula vazia; toda licença é CC0, CC-BY ou NASA.

## Não pode
- Cena do que o jogo ainda não faz.
- Cena com rosto ou voz de pessoa menor de 18.
- Apagar linha de outra dupla no `creditos.csv`.
- Mudar o cabeçalho do `creditos.csv`.
- Aceitar licença que não é CC0, CC-BY ou NASA.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/08-cenas-e-creditos (o PASSO.md está junto).
1. A partir do roteiro.md abaixo, liste 4 ou 5 cenas para a dupla de Dev gravar. Saída exatamente nesta tabela: "| # | O que mostrar | Tempo no vídeo | O que precisa estar acontecendo no jogo | Linha do roteiro |", somando até 30 s.
2. Compare o creditos.csv com o sons.csv, o cartas.csv e os pacotes da seção 4 do CONTEXTO.md. Liste o que falta, as linhas com célula vazia e as licenças que não são CC0, CC-BY ou NASA.
3. Devolva só as linhas novas do creditos.csv, com o mesmo cabeçalho (tipo,o_que,arquivo_ou_uso,autor,licenca,link,dupla).
Não invente autor, licença nem link: se faltar, escreva CONFERIR.
Saída: a tabela de cenas, a lista do item 2 e um bloco de código com as linhas do item 3.
[cole aqui o roteiro.md, o creditos.csv, o sons.csv e o cartas.csv]
```
