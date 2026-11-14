# Mike
- Modelo: mike.glb (Kenney Animated Characters Protagonists, characterMedium + cabelo 3D nosso)
- Cor do traje: #F4F4F8
- Acessório ou detalhe: cabelo loiro #E9BE62 com franja de lado e rabinho curto preso por elástico azul #3FA7C9; broche de Marte no peito (#C1440E com borda #D4A84B)
- Personalidade: Curioso e animado, o Mike pula de alegria a cada descoberta e nunca desiste da base.

## Para o Dev
- **Use o [mike.glb](mike.glb):** já tem o corpo, o esqueleto, a textura [mike-skin.png](mike-skin.png) e o cabelo 3D (`MikeHair`), preso ao osso `Head` (mexe junto com a cabeça).
- **Mudança de pacote:** a dupla de Design escolheu o [Animated Characters Protagonists](https://kenney.nl/assets/animated-characters-protagonists) (CC0) em vez do Mini Characters.
- **Animações (já dentro do mike.glb):** `idle` (parado, 1,4 s), `run` (correr, 0,7 s) e `jump` (pular, 0,5 s), do pacote da Kenney. Use o `AnimationPlayer` do modelo; o cabelo acompanha a cabeça.
- **Editar:** a pintura em [mike-skin.svg](mike-skin.svg); o cabelo é gerado pelo script [mike-cabelo3d.py](mike-cabelo3d.py) no Blender 5.3 (`blender --background --python mike-cabelo3d.py -- <characterMedium.fbx> <mike-skin.png> <prefixo-das-fotos> <saida.glb>`).
- [mike.png](mike.png): o Mike de frente, 3/4, lado e costas no céu caramelo.
- **Mike astronauta:** [mike-astronauta.glb](mike-astronauta.glb) (mesmas animações; capacete, gola e mochila presos aos ossos `Head` e `UpperChest`), textura [mike-astronauta-skin.png](mike-astronauta-skin.png), prévia [mike-astronauta.png](mike-astronauta.png).
