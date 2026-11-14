# Telas
- Link: sem Figma; as telas são feitas direto no Godot (arquivos nesta pasta)
- tela-carregamento.png (extra): Marte 3D girando, a nave branca e dourada é a barra de progresso e deixa um rastro de constelação dourado
- tela-inicial.png: a fazer
- hud-barras.png: a fazer
- album.png: a fazer
- carta.png: a fazer
- aviso-tempestade.png: a fazer
- tubo-revelacao.png: a fazer
- cartao-postal.png: a fazer

## Para o Dev: a tela de carregamento (pasta [carregamento](carregamento/))
- [tela_carregamento.tscn](carregamento/tela_carregamento.tscn) + [tela_carregamento.gd](carregamento/tela_carregamento.gd): a tela pronta. Mude `progresso` (0.0 a 1.0) enquanto o jogo carrega e desligue `demo`. O caminho no `.tscn` supõe a pasta copiada para `res://design/05-telas/carregamento/`; ajuste se mover.
- [marte.gdshader](carregamento/marte.gdshader): Marte feito por código com as cores da paleta (não usa imagem).
- [constelacao_rastro.gd](carregamento/constelacao_rastro.gd): **o efeito de constelação do jogo** (efeito original do time). Coloque como filho de qualquer `Node2D` que se mexe e ele deixa estrelinhas douradas ligadas por linhas. Ajustes: `tamanho`, `vida`, `passo`, `espalhar`, `cores`. A Design quer esse efeito em tudo o que é do Mike (nave, Mike andando etc.); a versão 3D para o Mike vem depois.
- [nave.png](carregamento/nave.png): `craft_speederA` do Space Kit, branca e dourada, sem logo da NASA.
- [rubik.ttf](carregamento/rubik.ttf): a fonte do jogo (OFL, licença em [rubik-ofl.txt](carregamento/rubik-ofl.txt)).
