# Moldura das cartas

Feita pelo time do zero, por código: [moldura-carta.gd](moldura-carta.gd) (Godot). Não usa nenhum modelo de fora.

4 molduras, uma por raridade. Mudam o símbolo do medalhão no topo e a cor da borda e dos enfeites, com as cores de raridade do [cores-das-coisas.csv](../04-cores-das-coisas/cores-das-coisas.csv):

| Raridade (`cartas.csv`) | Arquivo | Símbolo | Cor da borda |
|---|---|---|---|
| comum | [moldura-carta-comum.png](moldura-carta-comum.png) | foguete | `#9AA0A8` cinza |
| raro | [moldura-carta-raro.png](moldura-carta-raro.png) | estrela de 5 pontas | `#3B82D6` azul |
| épico | [moldura-carta-epico.png](moldura-carta-epico.png) | estrela de 6 pontas trabalhada | `#8E4FD8` roxo |
| lendário | [moldura-carta-lendario.png](moldura-carta-lendario.png) | coroa | `#E8B23A` dourado |

Prévia: [exemplo-cartas.png](exemplo-cartas.png).

## Onde vai cada coisa (em px, na imagem de 1066 × 1280, canto de cima à esquerda = 0,0)

| Campo | Retângulo (x1, y1, x2, y2) | Conteúdo |
|---|---|---|
| Título | 107, 92, 962, 200 | `nome_en` em MAIÚSCULAS, Rubik Bold, cor `#73242A`, centralizado |
| Foto | 60, 236, 1004, 850 | foto real da NASA (`foto_nasa`), **por baixo** da moldura: a janela é transparente e a faixa vermelha com o selo fica por cima. Use a foto cortada para preencher (cover) |
| Descrição | 84, 866, 990, 1134 | `fato_en`, Rubik Medium, cor `#3A261C`, centralizado, até 3 linhas |

- Fundo fora da carta e janela da foto: transparentes (PNG).
- Ordem no Godot: 1) foto, 2) moldura, 3) título e descrição.
- Fonte: Rubik, a do [fonte.md](../02-cores-e-fonte/fonte.md).
