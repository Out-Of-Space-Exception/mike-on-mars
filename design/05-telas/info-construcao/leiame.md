# Painel de informação da construção

> **Já está no jogo:** [jogo/scenes/build_info.gd](../../../jogo/scenes/build_info.gd). O passo a passo abaixo é o histórico da entrega; no código os nomes agora estão em inglês (o sinal `construir` virou `build_pressed`, `abrir` virou `open`).

Ao tocar num botão da barra de construção, abre um painel por cima da tela. Ele mostra o que o item faz, com os ícones da barra de cima e números `+` verde ou `-` vermelho. A barra de construção continua aberta por baixo.

- **Fechar:** fecha o painel e volta para a barra.
- **Construir -N ⚡:** segue para a construção, como já acontece hoje.

Prévia dos 6 painéis: [previa.png](previa.png). Telas cheias: [tela-estufa.png](tela-estufa.png), [tela-solar.png](tela-solar.png), [tela-rtg.png](tela-rtg.png), [tela-moxie.png](tela-moxie.png), [tela-antena.png](tela-antena.png), [tela-pista.png](tela-pista.png).

Abrem o painel: estufa, painel solar, RTG, MOXIE, antena e pista do Ingenuity. Luzinhas, bandeira e vaso vão direto para a construção, como hoje.

## Para a Dev: como implementar (cerca de 15 min)

1. **Imagens:** copie para `jogo/ui/info-construcao/` os arquivos `item-*.png`, `placa-titulo.png`, `ornamento-luas.png` e `ic-carta.png`.
2. **Script:** copie o [info_construcao.gd](info_construcao.gd) para `jogo/scenes/` (ou onde preferirem).
3. **Textos:** acrescente as linhas de [textos.csv](textos.csv) ao `jogo/data/textos.csv`. As chaves `INFO_*` já estão em pt_BR, en, es e fr, e a dupla de Conteúdo pode revisar.
4. **Ligar no `hud.gd`:**
   - Em `_ready()`:
     ```gdscript
     _info_construcao = preload("res://scenes/info_construcao.gd").new()
     add_child(_info_construcao)
     _info_construcao.construir.connect(_on_build_item)
     ```
   - Em `_refresh_build_menu()`, troque a linha `b.pressed.connect(_on_build_item.bind(type))` por:
     ```gdscript
     if type in _info_construcao.COM_INFO:
         b.pressed.connect(_info_construcao.abrir.bind(type))
     else:
         b.pressed.connect(_on_build_item.bind(type))
     ```
5. **Testar:** toque em "Painel solar". O painel deve mostrar ⚡ +3, o texto da poeira e o botão "Construir -10 ⚡". "Fechar" volta para a barra.

## De onde vêm os números (`jogo/autoload/state.gd`)

O script lê tudo do `State.ITEMS`. Se um número mudar no jogo, o painel muda junto. Os textos que citam números (30%, 15 sóis, +4, 122 g) precisam ser revisados se essas regras mudarem.

| Item | Efeitos | Texto | De onde vem |
|---|---|---|---|
| Estufa | ⚡ -1 ao plantar · 🫁 + cada planta | As plantas crescem aqui. A luz gasta energia. Sem energia, elas crescem pela metade. | `energy_when_planted`, `PLANT_OXYGEN`, `SLOW_GROWTH` |
| Painel solar | ⚡ +3 por sol | Na tempestade de poeira, a poeira cobre o painel e tapa a luz do Sol: ele faz só 30% por 15 sóis. | `energy`, `DUST_FACTOR`, `DUST_SOLS` |
| Bateria nuclear (RTG) | ⚡ +1 por sol | Pouca energia, mas não para nunca: nem de noite, nem na poeira. No nível 3 vira Kilopower: +4. | `energy`, `KILOPOWER_ENERGY` |
| MOXIE | ⚡ -1 · 🫁 +2 por sol | Tira oxigênio do ar de Marte. O MOXIE fez 122 g de oxigênio em Marte. | `energy`, `oxygen`; fato: CONTEXTO, seção 6 |
| Antena | — | Fala com a Terra: a cada 150 sóis chega um pacote com 3 sementes. A NASA avisa antes da tempestade solar, e o escudo sai mais barato. Às vezes você ganha a carta "Terra vista de Marte". | `PACKAGE_EVERY`, `PACKAGE_SEEDS`, `STORM_SHIELD_COST_WARNED`, `EARTH_SEEN_CHANCE` (2% por sol) |
| Pista do Ingenuity | 🃏 +1 carta | O helicóptero Ingenuity pousa aqui. Só dá para ter 1. | `card`, `max` |

## Estilo

- **Fundo e botões:** os mesmos da barra de construção, `Palette.plate()` com botões terracota.
- **Detalhes da carta:** a placa creme do título e o ornamento das luas.
- **Ícones:** os mesmos da barra de cima, nas cores de `Palette.BAR`. O ícone da carta vem do design/07.
- **Imagens:** os modelos 3D do jogo, renderizados no Blender.
