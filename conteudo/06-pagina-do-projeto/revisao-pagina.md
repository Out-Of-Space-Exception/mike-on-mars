# Revisão da página do projeto

O [texto em inglês](pagina.md) está preparado nas seis seções solicitadas pelo passo. Inclui as 36 cartas ativas com fontes de fatos e fotografias, o recorte de clima espacial e todas as linhas do registro de créditos e de IA.

- Referências e declarações: uma entrada por linha do `creditos.csv`, com numeração para rastrear a cobertura. A numeração se refere à posição atual, sem criar IDs no CSV original.
- Dados locais: 139 datas de simulações com chegada prevista a Marte, mais o evento medido de 20/05/2024; 140 entradas no total.
- Dois links principais: jogo e repositório responderam HTTP 200 em 15/11/2026. Isso verifica acesso HTTP, não gameplay nem o formulário autenticado.
- Licenças e autores: preservados conforme o registro das duplas, sem transformar crédito NASA em licença CC-BY ou a licença do edge-tts em autorização sobre vozes.
- Usos antigos: fotos das cinco cartas de reserva e testes de narração estão identificados como históricos, sem prometer que estão na versão jogável.

## Handoff para Dev

O texto está concluído; colar no formulário, ajustar aos limites reais dos campos, publicar a demo e clicar em Submit for Judging continuam com Dev. Não foi acessado o formulário autenticado nem realizada submissão.

A narração Andrew foi escolhida pelo time, mas o registro de créditos ainda pede conferir as condições de uso da voz. A página declara isso; esta revisão documental não resolve essa pendência da produção do vídeo.

`finalizar-pagina.py` gera a lista inglesa completa a partir das entradas atuais. Se os créditos mudarem, o script interrompe para exigir revisão dos novos rótulos. A validação de cobertura fica em [validar-traducoes.py](../05-traducoes/validar-traducoes.py).
