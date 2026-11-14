# Bugs e ajustes (teste no celular)

## As 2 perguntas
- Parece coisa de bebê? Não. O visual low-poly com as cores de Marte e o dourado tem cara de jogo de verdade.
- Dá para entender o que fazer em 60 segundos? Sim. O único ponto que atrapalha é a tela com muita informação junta (problema 3).

## Problemas

### 1. Itens grandes demais na base (vaso e outros)
- O que eu fiz: construí itens na base (ex.: o vaso de decoração) e olhei perto do Mike.
- O que eu esperava: cada item no tamanho de verdade (o vaso na altura do joelho do Mike).
- O que aconteceu: todos os itens ficam do mesmo tamanho (o vaso fica do tamanho do painel solar), porque o jogo estica cada modelo para encher a casa da grade. Solução proposta: alturas no [tamanhos.csv](../03-itens-do-jogo/tamanhos.csv).
- Celular usado: Samsung Galaxy A55, Galaxy S23 Ultra, Galaxy A56 e Galaxy M13, todos no Chrome

### 2. Couve igual à alface
- O que eu fiz: plantei alface e couve na estufa.
- O que eu esperava: duas plantas diferentes.
- O que aconteceu: as duas usam o mesmo modelo (o repolho da Kenney). Já tem modelo novo para cada uma em design/03-itens-do-jogo (alface.glb e couve.glb); falta o jogo usar.
- Celular usado: Samsung Galaxy A55, Galaxy S23 Ultra, Galaxy A56 e Galaxy M13, todos no Chrome

### 3. Muita informação junta na tela
- O que eu fiz: abri a base e olhei os botões e as barras.
- O que eu esperava: entender rápido o que fazer.
- O que aconteceu: as barras e os botões ficam todos juntos, e fica muita coisa para uma criança ler de uma vez. Proposta: ações em cima (Explore, Build, Album, Photo) e barras + Greenhouse embaixo, como no [hud-barras.png](../05-telas/hud-barras.png).
- Celular usado: Samsung Galaxy A55, Galaxy S23 Ultra, Galaxy A56 e Galaxy M13, todos no Chrome
