# Telas
- Link: sem Figma; as telas são feitas direto no Godot (arquivos nesta pasta)
- tela-carregamento.png (extra): Marte 3D girando, a nave branca e dourada é a barra de progresso e deixa um rastro de constelação dourado
- tela-inicial.png: título, o Mike correndo com o rastro de constelação, o horizonte de Marte e o botão Play
- hud-barras.png: a base 3D no meio; EM CIMA o "Sol 12 · Gale Crater" e as 4 ações (Explore, Build, Album, Photo); EMBAIXO as 3 barras (Energy dourada, Oxygen creme, Shield terracota) e o botão Greenhouse. Separado assim para a criança não ver tudo junto. Ícones do passo 07.
- album.png: "8/40 cards" e a grade de cartas com borda na cor da raridade; as que faltam ficam apagadas com "?"; o resto rola para baixo
- carta.png: "New card!", foto da NASA, etiqueta Rare, MOXIE, "This is real:" e o fato, com o rastro em volta da carta
- aviso-tempestade.png: sol, "Solar storm coming!", a data real do DONKI (20/05/2024) e 2 botões grandes: escudo ou ficar dentro
- tubo-revelacao.png: o tubo de amostra tremendo e brilhando em azul (raro), "Tap to open!" e "Rare"
- cartao-postal.png: foto da base com moldura creme e dourada, selo e "Sol 47 · Gale Crater"

## Como as telas foram feitas
- Todas foram montadas no Godot com o código da pasta [telas-godot](telas-godot/) ([telas.gd](telas-godot/telas.gd)), com as 5 cores do cores.csv, as cores de raridade do design/04 e a fonte Rubik. O Dev pode copiar dali tamanhos, cores e posições.
- Ícones da Kenney (Game Icons): wrench (Build), target (Explore), menuGrid (Album), home (Mike stays inside). Raio, oxigênio, escudo, câmera e sol não existem nos pacotes: foram desenhados simples no código; a escolha final é do passo 07.

## Para o Dev: a tela de carregamento (pasta [carregamento](carregamento/))
- [tela_carregamento.tscn](carregamento/tela_carregamento.tscn) + [tela_carregamento.gd](carregamento/tela_carregamento.gd): a tela pronta. Mude `progress` (0.0 a 1.0) enquanto o jogo carrega e desligue `demo`. O caminho no `.tscn` supõe a pasta copiada para `res://design/05-telas/carregamento/`; ajuste se mover.
- [marte.gdshader](carregamento/marte.gdshader): Marte feito por código com as cores da paleta (não usa imagem).
- [constelacao_rastro.gd](carregamento/constelacao_rastro.gd): **o efeito de constelação do jogo** (efeito original do time). Coloque como filho de qualquer `Node2D` que se mexe e ele deixa estrelinhas douradas ligadas por linhas. Ajustes: `size_scale`, `lifetime`, `step`, `spread`, `colors` (o código agora está em inglês). A Design quer esse efeito em tudo o que é do Mike (nave, Mike andando etc.); a versão 3D para o Mike vem depois.
- [nave.png](carregamento/nave.png): `craft_speederA` do Space Kit, branca e dourada, sem logo da NASA.
- [rubik.ttf](carregamento/rubik.ttf): a fonte do jogo (OFL, licença em [rubik-ofl.txt](carregamento/rubik-ofl.txt)).
