# Dev · 05 · Jogo completo

> **Em 1 frase:** tudo o que falta do jogo: os outros eventos, melhorias e decorações, o crescimento com o jogo fechado, o cartão-postal, o Ingenuity e os 4 idiomas.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [dev/04-tubo-e-tempestades](../04-tubo-e-tempestades/PASSO.md)
- **Quem usa depois:** [dev/07-acabamento-e-congelamento](../07-acabamento-e-congelamento/PASSO.md) e os testes das duplas

## Por que importa
É o que faz a criança **voltar** amanhã (a base cresceu enquanto ela estava fora) e **mostrar** para os amigos (o cartão-postal). É também o que transforma a ideia em produto completo para os jurados.

## Leia antes
- [CONTEXTO.md](../../CONTEXTO.md), seção 3 inteira (incluindo a tabela de eventos) e seção 5 (tom)
- [dev/03-esqueleto](../03-esqueleto/PASSO.md), seção "Padrão do código"

## Passo a passo
1. **Eventos.** São sorteados, todo evento tem um lado bom e o jogo pausa nas escolhas.
   - **Tempestade de poeira:** os painéis ficam sujos (painel ×0,3). O RTG não sente.
   - **Redemoinho:** limpa os painéis.
   - **Noite congelante:** a criança escolhe aquecer a estufa (−20 de energia) ou deixar as plantas desacelerarem. De manhã, há chance da carta "Geada em Marte".
   - **Sem sinal da Terra:** a criança escolhe um plano (ex.: "economizar energia" ou "plantar") e não dá para mexer por 10 sóis. Quando o sinal volta, chega um pacote com sementes novas.
2. **Cartas:** a 1ª colheita de cada planta, a 1ª construção de cada tecnologia e o 1º evento de cada tipo dão a carta da linha certa do `cartas.csv`.
3. **Melhorias:** o nível 1 → 2 → 3 aparece na tela (o painel cresce, a estufa aumenta).
4. **Decorações:** destravam com o álbum. A cada 5 cartas, a criança ganha 1 decoração do `design/03`.
5. **Enquanto você estava fora:** ao abrir, o jogo avança o tempo desde `saved_at` (no máximo 8 h) e mostra `AWAY_TITLE` + `AWAY_PLANTS`.
6. **Álbum:** as 25 cartas. As de Meridiani e Jezero ficam trancadas ("em breve"). Contador `ALBUM_COUNT`.
7. **Mapa:** Gale aberta; Meridiani e Jezero com `MAP_SOON`.
8. **Cartão-postal:** o botão Foto tira um print da base com "Sol N · Gale Crater" e baixa o PNG no aparelho (no navegador, via `JavaScriptBridge`).
9. **Ingenuity:** modelo 3D oficial da NASA (crédito NASA/JPL-Caltech no `creditos.csv`), recolorido com o `design/04`.
   - As hélices `rotors_01` e `rotors_02` giram em sentidos opostos, por código.
   - Decola e pousa com tween e segue o Mike.
10. **Idiomas:** o botão Idioma troca entre EN, PT, ES e FR (`TranslationServer`). O jogo começa no idioma do aparelho; se não for nenhum dos 4, começa em EN.
11. **Reações do Mike:** usar as animações do `animacoes.md` (passo 03). Se faltar alguma, fazer com tween (pulo, tremida).
12. Publicar e avisar no grupo.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| o jogo em [jogo/](../../jogo/) | o jogo completo | projeto Godot |
| `pendencias.md` | o que ficou para depois (se ficou algo) | `.md` |

## Pronto quando
- [ ] os 5 eventos aparecem, cada um com lado ruim e lado bom
- [ ] fechar o jogo e abrir depois mostra "Enquanto você estava fora…"
- [ ] dá para completar o álbum jogando (menos as cartas trancadas)
- [ ] o cartão-postal baixa um PNG no celular
- [ ] o Ingenuity voa com as hélices girando
- [ ] os 4 idiomas trocam todos os textos

## Não pode
- Game over, perder itens ou culpar a criança.
- Cronômetro na hora de escolher.
- Texto longo na tela: no máximo 1 frase por aviso.

## Pedido pronto para a IA
```text
Siga o AGENTS.md, o CONTEXTO.md e o padrão do código do dev/03-esqueleto/PASSO.md.
Implemente o item [número] do dev/05-jogo-completo/PASSO.md. Textos só com tr();
números no bloco BALANCEAMENTO do state.gd. Mostre só os arquivos que mudaram.
```
