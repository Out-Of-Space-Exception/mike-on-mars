# Pesquisa: o que prende crianças de 7–12 anos num jogo (nov/2026)

## 1. O gênero vencedor: "coleciona e cresce" (simulador/idle)
| Jogo (Roblox) | Pico simultâneo | Gênero |
|---|---|---|
| Steal a Brainrot | 25,4 mi (out/2025) | coleciona + rouba (idle/tycoon) |
| Grow a Garden | 22,3 mi (ago/2025) | planta + pets (idle) |
| Steal an Egg | 14,3 mi (set/2026) | coleciona ovos |
| 99 Nights in the Forest | 14,2 mi | sobrevivência (assusta demais pra 7 anos) |

- Simulação = ~32% de quem está jogando Roblox agora (maior gênero). https://rowatcher.com/news/a-third-of-roblox-plays-a-single-genre
- Picos: https://en.wikipedia.org/wiki/List_of_Roblox_games
- Brasil: Roblox 68% da Geração Alfa, Minecraft 57% (Grupo Alexandria, dez/2024) https://gamingera.biz/criancas-adolescentes-71-geracao-alfa-games-roblox/
- Brasil é o 2º maior mercado do Roblox (Bloomberg Línea, out/2026) https://www.bloomberglinea.com.br/tech/por-que-o-brasil-se-tornou-a-prioridade-global-da-roblox-depois-dos-estados-unidos/
- Reino Unido: 58% das crianças de 8–14 usam Roblox; as de 8–9 jogam ~40 min/dia (Ofcom, out/2026) https://www.advanced-television.com/2026/10/13/ofcom-55-of-children-play-online-games-with-strangers/
- Austrália 6–13 anos: Dress To Impress 7%, Adopt Me 5%, Grow a Garden 5%; aventura é o gênero nº 1 (43%) https://www.roymorgan.com/findings/10136-yas-roblox-for-young-australians-survey-december-2025

## 2. Por que prende (mecânicas, da mais comprovada para a menos)
1. Objetivo claro + tudo reage ao toque ("juice": som, partícula, tremida) — SDT, NN/g https://www.nngroup.com/articles/childrens-websites-usability-issues/
2. Controle só de toque, com botões grandes (≥2 cm) https://www.nngroup.com/articles/children-ux-physical-development/
3. Dificuldade que sobe aos poucos, retry sem punição (Malone; SDT)
4. Álbum/coleção já com 1–2 itens preenchidos (efeito do progresso inicial) https://www.coglode.com/nuggets/endowed-progress-effect
5. Personalizar (minha base, meu bicho) https://arxiv.org/pdf/2502.18705
6. Recompensa surpresa grátis (raridade) — evidência moderada
7. Pet/companheiro que reage
8. Mostrar pros amigos (print, placar local)
9. Criar/decorar (versão pequena)
10. Humor absurdo (estilo "brainrot") — evidência fraca, mas é tendência forte em 2025–26 https://www.rte.ie/culture/2025/0920/1534148-what-is-italian-brainrot-and-should-parents-be-wary-of-it

Padrão dos hits: ciclo simples (planta/choca → ganha → melhora), raridades, progresso que continua, sessão curta.

## 3. Os primeiros 60 segundos
- Botão "JOGAR" gigante (também libera o som no navegador)
- Zero texto: mostrar o objetivo com animação, ensinar 1 ação por vez
- Primeira recompensa em ~15 s (heurística, sem fonte)
- Sem login, formulário ou configuração
- Caso Budge Studios: tiraram o passo difícil e a conclusão do 1º ciclo foi de 25% para 74% https://android-developers.googleblog.com/2017/04/app-onboarding-for-kids-how-budge.html

## 4. Diferenças por idade
- 7–9: ainda leem mal (ícone + voz + imagem), clique simples, mais "fazer certo" que competir
- 10–12: competem e se exibem; odeiam coisa "de bebê" → visual um pouco mais velho
- Gênero neutro: aventura, exploração, personalização (moda divide meninas 45% / meninos 6%; luta 45% / 10%)

## 5. Navegador e celular
- Sessão web ≈ 11–20 min para 2–3 jogos → ~5–7 min por jogo (Poki 2026) https://poki.com/blog/state-of-web-gaming-report-2026
- 46% já largaram um jogo porque demorou pra carregar
- Brasil: 63% (9–10 anos) e 75% (11–12) acessam a internet SÓ pelo celular (TIC Kids Online 2025) https://cetic.br/en/tics/kidsonline/2025/criancas/A1E/

## 6. Evitar (padrões escuros)
Loot box paga, FOMO/tempo limitado, sequência diária, culpa ("seu pet tá triste"), anúncio, pay-to-win.
https://pmc.ncbi.nlm.nih.gov/articles/PMC9206186/

## 7. Técnico: Godot → navegador
- Godot 4.7.x estável (conferir em godotengine.org); Web = só o renderizador **Compatibility** (WebGL 2)
- Exportar **single-threaded** (padrão desde a 4.3): roda no itch.io/GitHub Pages sem cabeçalho especial, funciona no iPhone https://godotengine.org/article/progress-report-web-export-in-4-3/
- **GDScript** (C# não exporta pra web no Godot 4) https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_web.html
- MCP: Coding-Solo/godot-mcp (roda o jogo e lê erros; não "vê") · Erodenn/godot-mcp-runtime (print + simula clique; não testado)
- Assets CC0: Kenney Mini Characters, Space Kit, Space Station Kit (glTF). Quaternius Ultimate Space Kit: licença conflitante (CC0 vs CC-BY) → conferir.
