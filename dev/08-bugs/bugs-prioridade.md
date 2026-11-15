# Bugs: lista única com prioridade

Junta o [bugs.md do Design](../../design/08-teste-no-celular/bugs.md), o [bugs.md do Conteúdo](../../conteudo/09-teste-no-celular/bugs.md) e os pedidos do Filipe (15/11, noite).

Prioridade: **1 trava** (para, não abre ou perde o save) · **2 errado** (faz a coisa errada ou mostra texto errado) · **3 feio** (visual ou som estranho).

| # | Bug | De onde | Prioridade | Status |
|---|---|---|---|---|
| 1 | Câmera presa embaixo do planeta depois da casa nível 2 | Conteúdo, bug 1 | 1 | Não reproduzido no PC. CONFERIR no celular depois de publicar (mandar print se acontecer). |
| 2 | Lentidão ao explorar | Conteúdo, bug 2 | 2 | Melhorado: a vitrine 3D do painel de construção só é desenhada com o painel aberto. CONFERIR no Redmi. |
| 3 | Lentidão ao abrir o tubo | Conteúdo, bug 3 | 2 | Melhorado (o mesmo conserto do 2). CONFERIR no Redmi. |
| 4 | Álbum não rola no celular | Conteúdo, bug 4 | 2 | ✅ corrigido no código (`5bac0be`), depois da versão testada. CONFERIR no celular. |
| 5 | Itens todos do mesmo tamanho | Design, problema 1 | 2 | ✅ corrigido (`7af514f`, alturas do `tamanhos.csv`) |
| 6 | Couve igual à alface | Design, problema 2 | 2 | ✅ corrigido (`c776c16`) |
| 7 | Em inglês aparecia "1 more sols" | teste do jogo | 2 | ✅ corrigido |
| 8 | Custo escrito ("gasta 20 de energia") em vez de ícone, nos eventos e nos botões Melhorar e Consertar | Filipe | 2 | ✅ corrigido: "-20" e o ícone da energia no canto, igual ao botão Construir |
| 9 | Estufa mostra a planta crescendo só numa linha de texto | Filipe | 3 | ✅ corrigido: ícone da planta num anel que enche, no painel e flutuando em cima da estufa |
| 10 | "Sol N na Cratera Gale" fora do centro das barras | Filipe | 3 | ✅ corrigido |
| 11 | Muita informação junta na tela | Design, problema 3 | 3 | Fica assim: barras em cima e botões embaixo, separados |

## Falta
- Publicar (`bash ferramentas/publicar.sh`) e testar no celular mais fraco (Redmi Note 11S, Firefox): itens 1 a 4.
