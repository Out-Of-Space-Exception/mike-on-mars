# Revisão dos textos

Revisão editorial de 15/11/2026: 187 chaves em português do Brasil, inglês, espanhol e francês. O cabeçalho, as chaves, a ordem e todos os marcadores foram preservados. Os fatos das cartas continuam na [revisão científica](../02-cartas/revisao-das-cartas.md); esta etapa não altera fatos ou IDs.

- Botões `BTN_*`: uma palavra nos quatro idiomas; o acesso aos dados usa `NASA`.
- Energia zero: a dica começa por esperar a recuperação da barra, antes de propor uma construção.
- Eventos: a interface identifica a data arquivada e o aviso como parte do jogo, sem sugerir previsão da NASA ao vivo.
- Francês: removida a ideia de sobreviver às tempestades; o jogo não tem game over.
- Tutorial: cuidar das barras não exige mantê-las sempre cheias.
- Mensagens sem contexto de gênero, como item já construído, usam redação neutra.
- A carta de aurora continua lendária. A dica inglesa diz que é difícil de encontrar, evitando confundir a chance com a raridade azul `Rare`.

Alterações por célula: [alteracoes-textos.csv](alteracoes-textos.csv). Validação estrutural: [validar-traducoes.py](../05-traducoes/validar-traducoes.py).

## Fontes das correções científicas de interface

- [NASA CCMC: DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/): contém observações, análises e saídas de modelos. O recorte local inclui 139 datas de chegadas modeladas, mais a entrada medida de 20/05/2024. Contagem conferida em `jogo/data/donki.json` e seleção em `ferramentas/baixar-donki.mjs`.
- [NASA: conjunção solar](https://www.nasa.gov/solar-system/whats-mars-solar-conjunction-and-why-does-it-matter/): interferência pode corromper mensagens; a redação evita dizer que toda comunicação é simplesmente bloqueada pelo Sol.
- [NASA/JPL: evento de maio de 2024](https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/): o evento medido pelo Curiosity é distinto das datas provenientes de simulações.

## Integração

Não foram editados scripts ou dados gerados do jogo nesta etapa. Dev deve sincronizar o conteúdo antes da próxima exportação. A conferência visual dos textos no Redmi Note 11S/Firefox continua no teste do aparelho; revisão editorial e estrutural não comprovam ausência de cortes de texto em tela.
