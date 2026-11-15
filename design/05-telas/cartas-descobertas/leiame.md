# Cartas das descobertas

5 cartas montadas pelo Design com fotos reais da NASA e as molduras do [design/05-telas](../moldura-carta.md). Prévia: [cartas-previa.png](cartas-previa.png).

**Como a criança ganha: explorando.** Todas saem do **tubo de amostra**, quando o Mike volta da exploração. Ganhar a carta também libera a pedra para a [estante](../estante/leiame.md).

| Carta | id no `cartas.csv` | Raridade | Pedra 3D que libera na estante | Foto da NASA |
|---|---|---|---|---|
| White veins | 26 | comum | `veios-brancos` | [PIA16705](https://images.nasa.gov/details/PIA16705) |
| Rocknest 3 | 41 | comum | `rocknest-3` | [PIA16452](https://images.nasa.gov/details/PIA16452) |
| Manganese oxide | 32 | raro | `oxido-de-manganes` | [PIA20752](https://images.nasa.gov/details/PIA20752) |
| John Klein rock | 34 | épico | `john-klein-a`, `-b` e `-c` | [PIA16568](https://images.nasa.gov/details/PIA16568) |
| Lebanon meteorite | 35 | épico | `meteorito-lebanon` | [PIA18387](https://images.nasa.gov/details/PIA18387) |

- As cartas 26, 32, 34 e 35 já existem no jogo e já saem do tubo de amostra (`como_ganha` = "tubo de amostra"). As fotos daqui podem trocar as atuais delas.
- **Rocknest 3** já está no `cartas.csv` (id 41, comum, tubo de amostra). O texto saiu da legenda da NASA; o Conteúdo pode revisar.
- Os textos (`fato_en`) vêm do `cartas.csv`. O da Rocknest 3 saiu da legenda da NASA e é só provisório.
- Para montar de novo depois de mudar um texto: rode o [montar-cartas.ps1](montar-cartas.ps1).
