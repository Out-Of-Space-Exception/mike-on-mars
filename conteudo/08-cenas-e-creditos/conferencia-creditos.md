# Conferencia dos creditos - 15/11/2026

## Resultado

- Conferencia inicial: 109 registros no creditos.csv, nenhum campo vazio.
- As 40 fotos entregues em conteudo/02-cartas/fotos/ tem registro por nome de arquivo; a montagem 37 tem duas fontes. As 23 faixas entregues em conteudo/01-sons/sons/ tambem tem registro. Isto verifica cobertura documental, nao comprova por si so a procedencia de cada arquivo.
- Foram consultados 75 links distintos: 58 responderam ao verificador HTTP; 17 tiveram bloqueio, timeout ou erro de certificado no ambiente. Detalhe em [links-conferidos.csv](links-conferidos.csv). Nao classificar essas falhas como link quebrado sem conferir no navegador. Os links JPL ja foram consultados no [relatorio das fotos](../02-cartas/revisao-fontes.md).
- Foram acrescentadas nesta etapa as ferramentas dos exemplos de video (Pillow, imageio-ffmpeg, FFmpeg e edge-tts) e a declaracao de IA desta conferencia. Os numeros acima descrevem a consulta inicial, antes dessas inclusoes.

## Fontes e licencas conferidas

| Recurso | Resultado | Evidencia |
|---|---|---|
| Assets Kenney | CC0 confirmado nas paginas e nos arquivos License.txt dos dois pacotes de som. Os 21 efeitos entregues correspondem aos originais. | [Suporte Kenney](https://kenney.nl/support); [Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds); [Interface Sounds](https://kenney.nl/assets/interface-sounds); [comparacao por arquivo](audios-conferidos.csv) |
| Magic Space | Autor CodeManu e licenca CC0 confirmados na pagina. | [Pagina do recurso](https://opengameart.org/content/magic-space) |
| Happy Lullaby (song17) | Autor cynicmusic e licenca CC0 confirmados na pagina consultada diretamente. O leitor web retornou 403, mas a consulta HTTP local retornou o conteudo com esses campos. | [Pagina do recurso](https://opengameart.org/content/happy-lullaby-song17) |
| Fotos NASA | Creditos e correspondencia visual documentados nas etapas anteriores; nao substituir por um credito generico quando houver parceiros identificados. | [Conferencia das fotos](../02-cartas/conferencia.md); [fontes por carta](../02-cartas/revisao-fontes.md) |
| Rubik | Registro existente OFL e pagina do Google Fonts acessivel; manter autores completos do creditos.csv. | [Rubik](https://fonts.google.com/specimen/Rubik) |
| Junegull | Licenca fora de CC0/CC-BY/OFL; o registro existente documenta excecao ja aprovada pelo Design e uso apenas no logo. Nao pedir nova aprovacao nem reclassificar como CC0. | Linha Junegull no [registro unico](../../creditos.csv) |
| Ferramentas de producao | Godot/MIT, Blender/GPL e Audacity/GPL ja estavam registrados. Pillow/MIT-CMU e imageio-ffmpeg/BSD-2-Clause confirmados nos metadados instalados; o FFmpeg usado informa GPL-3.0-or-later em -L. Sao ferramentas, nao licencas das fotos ou dos audios de saida. | [Pillow](https://github.com/python-pillow/Pillow); [imageio-ffmpeg](https://github.com/imageio/imageio-ffmpeg); [FFmpeg](https://ffmpeg.org/legal.html) |
| edge-tts | Codigo da ferramenta sob LGPLv3; isso nao confirma as condicoes de uso das vozes Microsoft do servico acessado. | [Licenca do codigo](https://github.com/rany2/edge-tts/blob/master/LICENSE) |

## Comparacao dos audios

Os 23 WAVs foram comparados com os arquivos originais baixados em 15/11/2026. Ha 22 correspondencias integrais de sinal, com similaridade de pelo menos 0.9999 apos decodificacao mono a 44100 Hz. Isso inclui musica-base.wav e o original [song17.mp3](https://opengameart.org/sites/default/files/song17.mp3).

aurora.wav tem atualmente 4 s: e um recorte de [magic space.mp3](https://opengameart.org/sites/default/files/magic%20space.mp3) a partir de 37.95 s. A metade central corresponde ao original; as bordas editadas nao foram verificadas pelo comparador. O relatorio antigo da etapa 01 dizia 54.91 s, duracao do original completo, e nao descreve o arquivo atual.

O [CSV da comparacao](audios-conferidos.csv) guarda o nome original, similaridade, metodo e SHA-256 dos arquivos. O [script](conferir-audios.py) reproduz a comparacao sem alterar assets. Os pacotes Kenney foram obtidos pelo botao oficial das paginas acima, que agora fornece links temporarios; nao usar como fonte os antigos enderecos diretos ZIP, que retornaram HTML.

## Revisao das falhas HTTP

- DONKI: referencia atualizada para https://ccmc.gsfc.nasa.gov/DONKI/. A NASA anunciou a migracao em 30/09/2026; a pagina atual abriu. [Anuncio oficial](https://ccmc.gsfc.nasa.gov/news/major-updates/). Esta etapa atualiza referencias, sem alterar a integracao do jogo.
- JPL: os 13 erros de certificado do verificador local nao comprovam indisponibilidade. A conferencia visual e das fontes permanece no [relatorio anterior](../02-cartas/revisao-fontes.md); certificados nao foram desabilitados.
- Blender: a [pagina oficial de licenca](https://www.blender.org/about/license/) foi localizada no indice web, confirmando GPL; o acesso automatizado direto continua retornando 403.
- Codex: a [pagina oficial](https://openai.com/codex/?site_locale=en) abriu no leitor web; o 403 local e uma limitacao da consulta.
- Claude: a [pagina oficial do produto](https://www.anthropic.com/claude) abriu e aponta para claude.ai como acesso ao produto. O dominio de login continua com bloqueio automatizado; nao foi removido dos creditos.

O CSV de links preserva o resultado bruto da consulta inicial; esta revisao contextualiza as falhas sem transforma-las artificialmente em respostas HTTP 200.

## Entrega do passo e producao posterior

- [x] Lista de cinco blocos de captacao cobrindo o roteiro 2 e seus 29 segundos.
- [x] Formato horizontal 16:9 confirmado pelo time.
- [x] Conferencia documental de cobertura de fotos e sons, campos e links registrada.
- [x] Referencias e declaracao de IA da pagina do projeto atualizadas para os trabalhos desta sessao e recursos faltantes identificados.
- [x] Voz **Microsoft en-US-AndrewMultilingualNeural** escolhida pelo time em 15/11/2026, apos avaliar a amostra do roteiro 2. Sincronizacao fica para a montagem.
- [x] Procedencia dos 23 audios comparada com os originais e registrada por arquivo.
- [x] Falhas HTTP revisadas com fontes oficiais e evidencias anteriores; DONKI atualizado.
- [ ] Conferir se os recursos visuais usados no video final estao com seus creditos e eventuais marcas de IA legiveis. As capturas ainda serao gravadas pela Dev.

Entrega de planejamento do passo 08 concluida. Captacao, montagem e revisao do video exportado sao trabalho posterior; nao afirmar que o video final ja existe. Voz e servico registrados; confirmar as condicoes de uso antes da publicacao. Nenhuma mensagem foi enviada a outra dupla por ferramenta nesta etapa.

## Atualizacao recebida na sincronizacao

A sincronizacao com main trouxe o commit 5bac0be, que substituiu tubo-abrir.wav por Magic Spell SFX, magical_3.ogg, de JaggedStone (CC0). A comparacao de 23 audios acima e o SHA-256 desse arquivo no CSV descrevem a versao anterior, da Kenney. Nao usar essa correspondencia antiga para atestar o arquivo substituido. A nova origem foi registrada pelo Design no creditos.csv; a comparacao binaria da nova entrega com o original permanece para a proxima conferencia de sons. Os demais registros e as novas declaracoes de IA do Design foram preservados.
