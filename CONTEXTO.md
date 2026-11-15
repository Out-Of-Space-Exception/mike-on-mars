# CONTEXTO — Mike on Mars (NASA Space Apps 2026)

> **No repositório?** Comece pelo [AGENTS.md](AGENTS.md).
>
> **Como usar:** cole este arquivo inteiro no começo da conversa com qualquer IA e escreva: *"Use este contexto em tudo o que você fizer comigo. Se algo não estiver aqui, pergunte antes de inventar."* Depois, peça a sua tarefa.
>
> **Regra do Space Apps:** sempre que usar IA, avise no grupo **o que** foi feito com IA. A gente precisa declarar isso na entrega.

---

## 1. Instruções para a IA (leia antes de tudo)

Você está ajudando o time **Out of Space Exception** (Brasil) no NASA Space Apps Challenge 2026. Siga estas regras em todas as respostas:

1. **Nunca invente fatos, números, datas ou missões.** Use só os fatos da seção 6 ou uma fonte oficial da NASA (nasa.gov, science.nasa.gov, jpl.nasa.gov), sempre com o link. Se não tiver certeza, diga "não sei" e sugira onde procurar.
2. **Público:** crianças de 7 a 12 anos. Linguagem simples, mas que **não pareça coisa de bebê** para quem tem 12.
3. **Idioma:** tudo o que o jurado ou o jogador lê sai em **inglês simples**, a menos que eu peça outro. O jogo também terá português (Brasil), espanhol e francês.
4. **Nada de logo, bandeira ou marca da NASA** em imagens, textos ou ícones gerados.
5. **Imagem ou vídeo gerado por IA** precisa de marca d'água visível ("Made with AI").
6. **Só sugira assets com licença CC0 ou CC-BY** (fontes: também OFL), sempre com link, autor e licença.
7. **Respostas curtas e diretas.** Sem enrolação.

---

## 2. O projeto em 1 minuto

- **Desafio:** *Build a Junior Astronaut Mission Trainer*. Um jogo em que crianças de 7 a 12 anos cuidam de uma base em Marte e sentem as escolhas difíceis de uma missão real, usando **dados reais da NASA**.
- **Nome:** **Mike on Mars** (PT: Mike em Marte · ES: Mike en Marte · FR: Mike sur Mars).
- **Mascote:** **Mike**, um astronauta (personagem do pacote Kenney Mini Characters, com cor de traje e acessório próprios).
- **Estilo de jogo:** "coleciona e cresce", inspirado em Grow a Garden e Steal a Brainrot (os jogos de Roblox que passaram de 20 milhões de jogadores ao mesmo tempo).
- **Onde roda:** no navegador, pensado primeiro para o celular. Sem login, sem download, sem guardar dado de criança.
- **Local:** **cratera Gale**, onde o rover Curiosity trabalha.

---

## 3. Como o jogo funciona

- **3 barras, só 3:** ⚡ **Energia**, 🫁 **Oxigênio** e 🛡️ **Escudo** (a proteção do Mike contra a radiação do Sol).
- **Construir:** toca no item, toca no chão (sem arrastar). Dá para **mover, girar, remover sem perder nada e melhorar** (o painel cresce, a estufa aumenta). O álbum destrava **decorações**.
- **A Casa do Mike manda na base:** o nível dela abre área nova para construir (4 x 4 casas no nível 1, 6 x 6 no 2, 6 x 8 no 3) e é o nível máximo das outras construções. O planetinha cresce junto.
- **Plantar:** na estufa. A luz da estufa gasta energia. As plantas crescem num tempo proporcional ao real (alface ≈ 1 min 20 s; pimenta ≈ 5 min).
- **Explorar:** gasta oxigênio. O Mike volta com um **tubo de amostra** (igual aos que o rover Perseverance lacra em Marte), que treme, brilha na cor da raridade e revela uma **carta**.
- **Cartas:** **35** no jogo (as 5 de Meridiani e Jezero ficaram fora, para o jogo sair fechadinho), em 4 raridades com cor fixa: comum (cinza), raro (azul), épico (roxo) e lendário (dourado). As mesmas cores que as crianças já conhecem de outros jogos. Cada uma tem **foto real da NASA**, nome de verdade e **1 linha de fato**, que aparece como **prêmio** depois que a criança ganha (nunca como lição).
- **A base fica salva** no aparelho e **cresce até com o jogo fechado** ("enquanto você estava fora, 3 alfaces ficaram prontas!").
- **Sem game over:** barra baixa só **trava ou desacelera** uma ação até recuperar (sem oxigênio, o Mike não sai; sem energia, a estufa desacelera).
- **Escolha de verdade:** painel solar dá muita energia, mas sofre com a poeira. Bateria nuclear (RTG) dá pouca, mas nunca para.
- **Pet:** o helicóptero **Ingenuity** voa atrás do Mike.
- **Cartão-postal:** print da base ("Sol 47 · Gale") para mostrar aos amigos.
- **O jogo pausa** quando a criança precisa escolher. Nada de cronômetro.

### Eventos (sorteados; todo evento tem lado ruim e lado bom)

| Evento | Lado ruim | Lado bom |
|---|---|---|
| Tempestade solar | Levantar o escudo gasta energia; não levantar deixa o Mike preso na base | Aguentou com o escudo? Chance da carta lendária "Aurora em Marte" |
| Redemoinho de poeira | Nenhum | Limpa os painéis e a energia volta |
| Tempestade de poeira | Painéis solares sujos, energia cai | Quem tem bateria nuclear (RTG) nem sente |
| Noite congelante | Aquecer a estufa gasta energia; senão, as plantas desaceleram | De manhã, chance da carta rara "Geada em Marte" |
| Sem sinal da Terra | Alguns sóis sem poder mexer: o piloto automático segue o plano escolhido antes | Quando o sinal volta, chega um pacote com sementes novas |

---

## 4. Estilo visual

- **3D low-poly**, todo no mesmo estilo dos pacotes **Kenney (CC0)**: Mini Characters, Space Kit, Space Station Kit, Modular Space Kit, Food Kit, Nature Kit, Skyboxes, Planets, Game Icons e UI Pack Sci-Fi (todos em kenney.nl/assets).
- **Ingenuity:** modelo 3D oficial da NASA ([link](https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/)), recolorido no estilo das máquinas da Kenney: cinza vira branco, com faixas azul e vermelho. Crédito: NASA/JPL-Caltech.
- **Céu de Marte de dia:** cor de caramelo (é a cor real).
- **MOXIE:** máquina pequena do Space Kit pintada de dourado (o MOXIE de verdade é dourado).
- **Paleta da interface:** [cores.csv](design/02-cores-e-fonte/cores.csv)
- **Fonte:** [Rubik](design/02-cores-e-fonte/fonte.md)
- **Clima:** divertido e "de verdade", nunca infantil demais.

---

## 5. Tom dos textos

- **Inglês simples:** frases curtas, palavras do dia a dia.
- **Nomes reais sempre** (MOXIE, Ingenuity, Curiosity, olivina) + 1 linha que explica para criança. Ex.: *"MOXIE: the machine that turns Mars air into oxygen."*
- **Botões:** ícone + 1 palavra.
- **Humor leve:** o Mike pula quando colhe, treme no frio, come a pimenta e o capacete embaça de vermelho.
- **Mensagens sempre positivas.** Nunca culpar a criança.

---

## 6. Fatos que podem ser usados (todos reais)

| Fato | Fonte |
|---|---|
| A alface "Outredgeous" cresceu 33 dias na Estação Espacial; os astronautas comeram em 10/08/2015 | [NASA](https://www.nasa.gov/mission_pages/station/research/news/veggie) |
| A zínia foi a 1ª flor a florescer no espaço (16/01/2016), salva de um fungo pelo astronauta Scott Kelly | [NASA](https://www.nasa.gov/image-article/first-flower-grown-space-stations-veggie-facility/) |
| A pimenta Hatch cresceu ~4 meses na Estação e virou noite do taco (29/10/2021) | [NASA](https://www.nasa.gov/image-article/fresh-chiles-spice-up-taco-night/) |
| O rabanete cresceu em 27 dias na Estação (2020) | [Space.com](https://space.com/nasa-astronaut-harvests-radishes-space-station) |
| O Curiosity achou cristais amarelos de enxofre puro ao quebrar uma pedra (30/05/2024) | [Space.com](https://www.space.com/nasa-mars-curiosity-sulfur-rocks) |
| "Blueberries" de hematita (rover Opportunity) são pista de água antiga | [JPL](https://www.jpl.nasa.gov/news/opportunity-rover-finds-strong-evidence-meridiani-planum-was-wet/) |
| "Manchas de leopardo" na rocha Cheyava Falls (Perseverance) são um possível sinal de vida | [NASA](https://www.nasa.gov/news-release/nasa-says-mars-rover-discovered-potential-biosignature-last-year/) |
| O MOXIE fez 122 g de oxigênio em Marte, o que um cachorro pequeno respira em 10 h | [NASA](https://www.nasa.gov/missions/mars-2020-perseverance/perseverance-rover/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/) |
| Marte recebe no máximo 45% da luz do Sol que chega na Terra | [NASA (PDF)](https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf) |
| A poeira derrubou a energia do InSight de ~5.000 para ~500 Wh por sol | [NASA](https://science.nasa.gov/resource/insights-power-generation-after-landing-and-spring-2022/) |
| O Opportunity parou de responder numa tempestade de poeira (junho/2018) | [JPL](https://www.jpl.nasa.gov/news/opportunity-hunkers-down-during-dust-storm/) |
| Na superfície de Marte, a radiação é ~0,67 mSv por dia | [SwRI](https://www.swri.org/press-release/swri-scientists-publish-first-radiation-measurements-surface-mars) |
| Tempestade solar de 20/05/2024: o Curiosity mediu o equivalente a 30 raios-X de tórax | [NASA](https://www.nasa.gov/solar-system/planets/mars/nasa-watches-mars-light-up-during-epic-solar-storm) |
| Na cratera Gale, a máxima fica perto de 0 °C e a mínima perto de −70 °C | [NASA](https://science.nasa.gov/resource/steady-temperatures-at-mars-gale-crater) |
| 1 sol (dia de Marte) dura 24 h 39 min | [NASA (PDF)](https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf) |
| O Ingenuity fez 72 voos em Marte (último em 18/01/2024) | [NBC News](https://www.nbcnews.com/science/space/nasas-little-helicopter-mars-logged-last-flight-rcna135757) |

**A conferir antes de usar** (achar a fonte oficial e colocar o link): aurora vista pelo Perseverance em 2024 · geada fotografada pela sonda Viking 2 · Curiosity usa bateria nuclear (RTG) · a NASA fica ~2 semanas sem falar com os rovers a cada ~2 anos (conjunção solar) · redemoinhos limparam os painéis do Spirit e do Opportunity.

**Dado da NASA usado no jogo:** DONKI (banco de dados de clima espacial da NASA), com as tempestades solares reais.

---

## 7. Regras do Space Apps (resumo)

- Página do projeto, slides e legendas **em inglês**. O vídeo pode ser falado em português, **com legenda em inglês**.
- Demo: **vídeo de até 30 s** ou **até 7 slides**.
- Usar **pelo menos 1 dado da NASA** (o nosso é o DONKI).
- **Listar todos os recursos** usados (modelos, sons, fontes, imagens, código), mesmo os gratuitos.
- IA é permitida, mas precisa ser **declarada**. Imagem e vídeo de IA levam **marca d'água**.
- **Nenhuma** foto, vídeo ou voz de menores de 18 anos.
- Dentro do jogo, mostrar de onde vêm os dados da NASA e deixar claro que são **arquivados**, não ao vivo (o desafio pede isso).
- O envio fecha **domingo, 15/11, às 23h59**. Antes, clicar em **Submit for Judging**: projeto só salvo não é julgado.
- Regras completas e campos do formulário, em português: [Space Apps 2026 Kit](https://github.com/angelinopires/space-apps-2026-kit/blob/main/docs/pt-br/regras-e-julgamento.md).

---

## 8. O que NÃO fazer

- Não inventar fato, número, data ou missão.
- Não trocar nome, mascote, local ou as 3 barras sem falar com o time.
- Não criar game over nem punição forte.
- Não colocar texto longo na tela do jogo.
- Não usar asset sem licença CC0 ou CC-BY, nem personagem de outro jogo ou filme.
- Não usar logo da NASA.
- Não pedir nome, foto ou qualquer dado da criança.

---

## 9. Pedidos prontos (copie e adapte)

- **Design:** *"Seguindo o contexto, sugira 3 paletas de 5 cores (em hex) para a interface do Mike on Mars, combinando com o céu caramelo e o estilo low-poly da Kenney. Para cada uma, diga por que não parece infantil."*
- **Cartas:** *"Seguindo o contexto, escreva a carta de [ITEM] em inglês simples: nome, raridade (comum, raro, épico ou lendário), 1 linha de fato com o link oficial da NASA e 1 linha de 'saiba mais'. Use só fatos da seção 6 ou de fonte oficial."*
- **Traduções:** *"Traduza estes textos do jogo para português do Brasil, espanhol e francês, mantendo frases curtas e o mesmo tom divertido."*
- **Pitch:** *"Seguindo o contexto, escreva o roteiro de um vídeo de 30 s em inglês, cena por cena (o que aparece na tela + legenda), mostrando o primeiro minuto do jogo."*
