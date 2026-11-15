# Bugs - teste no celular

Teste relatado por Davi em 15/11/2026 no Redmi Note 11S. Navegador: Firefox; versao nao informada. Teste inicial em guia anonima e reteste da navegacao da base em guia normal. Registros baseados no relato, sem reproducao independente ou medicao de desempenho.

### Bug 1 - Camera fica presa na parte de baixo do planeta apos casa nivel 2
- **O que eu fiz:** abri o jogo em uma guia normal do Firefox e melhorei a casa do Mike para o nivel 2.
- **O que eu esperava:** continuar navegando normalmente pela base apos a melhoria.
- **O que aconteceu:** a tela fica travada na parte de baixo do planeta, como se a camera estivesse presa, impedindo navegar normalmente pela base. No reteste em guia normal, o problema nao apareceu antes de a casa chegar ao nivel 2. Esta e a sequencia relatada pelo jogador, sem causa tecnica confirmada. Ao fechar e reabrir o jogo em guia normal, o jogador confirmou que a casa continuou no nivel 2 e a camera permaneceu presa. Reabrir nao resolveu o problema; a causa tecnica ainda nao foi identificada. As quatro acoes de construcao nao foram confirmadas individualmente.
- **Celular usado:** Redmi Note 11S; Firefox em guia normal; versao nao informada. Tambem houve relato inicial de navegacao ruim em guia anonima.

### Bug 2 - Lentidao ao explorar
- **O que eu fiz:** usei a exploracao.
- **O que eu esperava:** resposta fluida ao comando e durante a exploracao.
- **O que aconteceu:** explorar ficou muito lagado. CONFERIR se a lentidao ocorre no toque inicial, na animacao ou durante toda a acao; tempo e frequencia nao medidos.
- **Celular usado:** Redmi Note 11S; Firefox em guia anonima; versao nao informada.

### Bug 3 - Lentidao ao abrir o tubo
- **O que eu fiz:** abri um tubo de amostra.
- **O que eu esperava:** abertura e revelacao da carta sem lentidao acentuada.
- **O que aconteceu:** abrir o tubo ficou muito lagado. CONFERIR qual parte da abertura/revelacao apresenta a lentidao; tempo e frequencia nao medidos.
- **Celular usado:** Redmi Note 11S; Firefox em guia anonima; versao nao informada.

### Bug 4 - Album nao permite rolar a tela no celular
- **O que eu fiz:** tentei navegar pela tela do album de cartas no celular.
- **O que eu esperava:** conseguir rolar o album para acessar os itens fora da area visivel.
- **O que aconteceu:** nao consegui rolar a tela do album; o jogador descreve a funcionalidade como ausente. Registra-se a falha observada, sem concluir se a causa e implementacao ausente, gesto nao reconhecido ou versao publicada desatualizada.
- **Celular usado:** Redmi Note 11S; Firefox em guia anonima; versao nao informada.

## Observacoes a confirmar

- O teste inicial foi realizado em guia anonima. Houve depois reteste da navegacao da base em guia normal, com falha apos melhorar a casa para nivel 2. No reteste em guia normal, a casa permaneceu no nivel 2 apos fechar e reabrir, confirmando a persistencia desse progresso. O aviso de retorno ainda nao foi confirmado. Nao registrar falha de salvamento com base nesses relatos. Os problemas de navegacao e desempenho continuam registrados no ambiente em que foram observados; sua causa nao foi atribuida ao modo anonimo.

- O jogo carregou, mas demorou um pouco. Sem tempo medido, dados de conexao ou comparacao entre primeira abertura e reabertura; ainda nao classificado como defeito de carregamento.
- Teste de energia: o jogador esclareceu que desmontou tudo deliberadamente para conseguir zerar a energia; nao havia painel solar ou RTG. Construir sem energia suficiente foi bloqueado. O relato anterior foi corrigido: nao houve confirmacao de que o jogo obrigou a desmontar estruturas para recuperar a partida. O suposto Bug 5 foi retirado. Recuperacao com geracao de energia instalada nao foi testada neste cenario.
- O jogador recebeu muitas cartas. Quantidade e numero de exploracoes nao informados; nao ha evidencia suficiente para afirmar duplicacao ou recompensa indevida.
- Plantar e colher funcionaram integralmente segundo o jogador, inclusive enquanto Mike explorava. O CONTEXTO.md descreve as duas atividades, mas nao exige bloquear a estufa durante a exploracao. Registrar como comportamento observado para avaliacao de Design, sem classificar como bug confirmado.

## Estado do teste

Checklist parcial em [checklist.csv](checklist.csv). Rolagem do album reprovada segundo o relato; contador e cartas do album ainda nao conferidos. A persistencia do nivel 2 da casa foi confirmada em guia normal; aviso de retorno e demais dados salvos ainda nao conferidos. Trocar o idioma e ligar/desligar o som funcionaram segundo o jogador em guia normal. A revisao individual dos quatro idiomas e dos acentos ainda esta pendente. Tirar e salvar o cartao-postal funcionou; girar para horizontal e voltar manteve os botoes visiveis e funcionando segundo o jogador. Esse resultado nao confirma que o problema da camera presa foi resolvido. O jogador conseguiu escolher uma opcao em um evento; tipo nao informado e demais tipos ainda nao confirmados. Recurso baixo testado: construcao bloqueada sem energia suficiente, apos desmontagem deliberada de todas as estruturas para zerar a energia; nenhum defeito de recuperacao confirmado. Conferencia dos textos/cartas ainda precisa ser concluida. Rodada encerrada a pedido do time com os resultados acima e as verificacoes pendentes explicitadas. Quatro problemas relatados foram documentados para Dev. Nao houve reproducao independente nem teste exaustivo; nao considerar o jogo aprovado sem ressalvas. O encaminhamento esta registrado em Pedidos entre duplas no TAREFAS.md; nenhuma mensagem externa foi enviada por ferramenta.
