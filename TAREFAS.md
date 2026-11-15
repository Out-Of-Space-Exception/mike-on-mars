# Tarefas do time

> - **Horário = limite.**
> - **Terminou?** Troque `[ ]` por `[x]`: lápis ✏️ → **Commit changes**.
> - **Clique no nome** do passo para ver como fazer.
> - **Precisa de algo de outra dupla?** Escreva em **Pedidos entre duplas**, no fim desta página.
> - **Faltou algo às 7h de domingo?** O time resolve no domingo, até 22h. O envio fecha domingo, às 23h59.

## 🎨 Design · Maria Fernanda e Thais · até 20h

- [x] 11h · [O Mike](design/01-mike/PASSO.md)
- [x] 11h30 · [Cores e fonte](design/02-cores-e-fonte/PASSO.md)
- [x] 12h30 · [Os itens do jogo](design/03-itens-do-jogo/PASSO.md)
- [x] 14h30 · [As cores das coisas](design/04-cores-das-coisas/PASSO.md)
- [x] 17h · [As telas](design/05-telas/PASSO.md)
- [x] 18h · [Logo e ícone](design/06-logo-e-icone/PASSO.md)
- [x] 19h · [Ícones dos botões](design/07-icones-dos-botoes/PASSO.md)
- [x] 19h30 · [Teste no celular](design/08-teste-no-celular/PASSO.md)
- [ ] 20h · [Entrega](design/09-entrega/PASSO.md)

## ✍️ Conteúdo e pitch · Carolina e Davi · até 20h

- [ ] 12h30 · [Os sons](conteudo/01-sons/PASSO.md)
- [ ] 15h · [As cartas](conteudo/02-cartas/PASSO.md)
- [ ] 16h · [Textos das cartas e dos avisos](conteudo/03-textos/PASSO.md)
- [ ] 17h · [Slides](conteudo/04-slides/PASSO.md)
- [ ] 17h30 · [Traduções](conteudo/05-traducoes/PASSO.md)
- [ ] 18h30 · [Texto da página do projeto](conteudo/06-pagina-do-projeto/PASSO.md)
- [x] 19h · [Roteiro do vídeo](conteudo/07-roteiro-do-video/PASSO.md)
- [ ] 19h30 · [Cenas e créditos](conteudo/08-cenas-e-creditos/PASSO.md)
- [ ] 20h · [Teste no celular](conteudo/09-teste-no-celular/PASSO.md)

## 💻 Dev · Filipe e João · até 7h de domingo

- [x] 10h30 · [Destravar o time](dev/01-destravar-o-time/PASSO.md)
- [x] 11h30 · [Teste do caminho](dev/02-teste-do-caminho/PASSO.md)
- [x] 14h30 · [Esqueleto](dev/03-esqueleto/PASSO.md)
- [x] 16h30 · [Tubo de amostra e tempestades](dev/04-tubo-e-tempestades/PASSO.md)
- [x] 19h · [Jogo completo](dev/05-jogo-completo/PASSO.md)
- [x] 20h · [Receber as entregas](dev/06-receber-entregas/PASSO.md)
- [ ] 1h · [Acabamento e congelamento](dev/07-acabamento-e-congelamento/PASSO.md)
- [ ] 4h · [Bugs](dev/08-bugs/PASSO.md)
- [ ] 6h · [Vídeo e página](dev/09-video-e-pagina/PASSO.md)
- [ ] 7h · [Envio](dev/10-envio/PASSO.md)

## 📮 Pedidos entre duplas

> Precisa de algo de outra dupla? Escreva aqui, dizendo quem pede, para quem e onde entregar. Entregou? Marque `[x]`.

- [x] **Dev → Design:** subir as 3 animações do Mike em `design/01-mike/`: `idle.fbx`, `run.fbx` e `jump.fbx`, da pasta `Animations` do pacote Animated Characters Protagonists.
- [x] **Dev → Design:** subir em `design/03-itens-do-jogo/` os modelos da Kenney que não foram repintados: `cabbage.glb` (alface), `radish.glb` (rabanete), `flower_redA.glb` (zínia), `machine_barrel.glb` (RTG), `satelliteDish.glb` (antena) e `skybox-morning.png` (céu). Se o pacote tiver a pasta `Textures`, mande o `colormap.png` junto.
- [x] **Dev → Design:** escolher e subir 2 modelos que faltam, em `design/03-itens-do-jogo/kenney/`: a **Casa do Mike** (um módulo de base) e a **Estufa**. Podem ser do Space Kit, Space Station Kit ou Modular Space Kit. Anotar no `itens.csv` (linhas `casa-do-mike` e `estufa`).
- [x] **Dev → Design (se der tempo):** um modelo para o **Kilopower** (o RTG no nível 3 vira uma mini usina nuclear: na vida real ele tem um radiador em forma de guarda-chuva). Hoje o jogo põe um radiador dourado simples em cima do RTG. Entregar em `design/03-itens-do-jogo/` e anotar no `itens.csv` (linha `kilopower`).
- [x] **Design → Dev:** implementar o painel de informação da construção (Fechar / Construir -N ⚡), passo a passo em [design/05-telas/info-construcao/leiame.md](design/05-telas/info-construcao/LEIAME.md).
- [x] **Dev → Design:** se o `mike.glb` ou o `mike-astronauta.glb` forem exportados de novo, conferir os braços: as animações `idle`, `run` e `jump` vieram com os braços abertos (pose de T). Hoje o jogo abaixa os braços por código (só `construir` e `colocar` vieram certas). **Design:** os braços em T ficam como estão; os modelos não mudam.
- [ ] **Dev → Conteúdo:** faltam 2 sons do `sons.csv` em `conteudo/01-sons/sons/`: `passos` e `vento-poeira` (os outros já chegaram).
- [ ] **Dev → Conteúdo:** o jogo agora tem **35 cartas** (as 5 "em breve" de Meridiani e Jezero saíram: ids 7, 8, 10, 17 e 18). Trocar "40 cards" por "35 cards" no [slides.md](conteudo/04-slides/slides.md) e no [pagina.md](conteudo/06-pagina-do-projeto/pagina.md).
- [x] **Dev → Conteúdo:** subir as fotos das cartas em `conteudo/02-cartas/fotos/` com os nomes do item 6 do [PASSO das cartas](conteudo/02-cartas/PASSO.md) (as de 7, 8, 10, 17 e 18 não precisam mais). As molduras do Design já estão prontas e entram no jogo junto com as fotos.
- [x] **Design → Dev:** colocar no jogo a **estante de exposição**. Ela é construída como o painel solar, tem o botão "Ver estante" no painel do item (zoom de frente, com o céu do jogo atrás) e a criança escolhe o que expor. Só libera com a **Casa do Mike no nível 2, com 3 vagas**; no **último nível, 6 vagas**. Passo a passo testado numa cópia do jogo: [design/05-telas/estante/leiame.md](design/05-telas/estante/leiame.md).
- [ ] **Dev → Conteúdo:** revisar os textos novos do jogo. Os textos do [textos.csv](conteudo/03-textos/textos.csv) foram reescritos mais simples (sem "de verdade" e sem "·" ou "•" no meio), e as 40 cartas do [cartas.csv](conteudo/02-cartas/cartas.csv) ganharam **nome e fato em espanhol e francês** (antes apareciam em inglês). Os números e as datas são os mesmos de antes, com as mesmas fontes.
- [x] **Dev → Design:** o texto do MOXIE no painel de informação ([textos.csv](design/05-telas/info-construcao/textos.csv), `INFO_MOXIE`) ainda diz "O MOXIE de verdade fez 122 g...". Se quiserem, troquem por "O MOXIE fez 122 g de oxigênio em Marte." (o resto do jogo não usa mais "de verdade"). **Design:** trocado.
- [ ] **Dev → todos:** o código agora é todo em inglês (nomes e comentários), inclusive os scripts do Design e as ferramentas. Os nomes de arquivos de modelos, sons e pastas continuam iguais.
- [ ] **Design → Conteúdo:** criar a carta **41 · Rocknest 3** (comum, tubo de amostra, Gale) no `cartas.csv`, com um fato de fonte oficial. A foto e a carta pronta estão em [design/05-telas/cartas-descobertas/](design/05-telas/cartas-descobertas/leiame.md). As cartas 26, 32, 34 e 35 ganharam fotos novas lá também, se quiserem trocar.
