# Conteúdo · 06 · Texto da página do projeto

> **Em 1 frase:** escrever, em inglês, o texto que os jurados leem na página do projeto no site do Space Apps.

- **Dupla:** Conteúdo e pitch (Carolina e Davi)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [conteudo/01-sons](../../conteudo/01-sons/PASSO.md) e [conteudo/02-cartas](../../conteudo/02-cartas/PASSO.md) (créditos), [conteudo/04-slides](../../conteudo/04-slides/PASSO.md) (mesma história)
- **Quem usa depois:** [dev/09-video-e-pagina](../../dev/09-video-e-pagina/PASSO.md) (cola o texto no site)

## Por que importa
É ali que os jurados leem sobre o projeto. O Space Apps exige usar dado da NASA, listar todos os recursos e declarar o uso de IA. Se faltar algo aqui, perdemos ponto.

## Leia antes
- [CONTEXTO.md, seções 2 e 3](../../CONTEXTO.md#2-o-projeto-em-1-minuto): o que é e como funciona.
- [CONTEXTO.md, seção 6](../../CONTEXTO.md#6-fatos-que-podem-ser-usados-todos-reais): fatos e o DONKI.
- [CONTEXTO.md, seção 7](../../CONTEXTO.md#7-regras-do-space-apps-resumo): regras do Space Apps.
- [creditos.csv](../../creditos.csv): referências, ferramentas e uso de IA.
- [cartas.csv](../../conteudo/02-cartas/cartas.csv): as fontes da NASA de cada carta.
- [slides.md](../../conteudo/04-slides/slides.md): a mesma história, em slides.

## Passo a passo
1. Crie o arquivo no GitHub: abra `conteudo/06-pagina-do-projeto/` → **Add file → Create new file** → nome `pagina.md`.
2. Cole o modelo abaixo e preencha cada seção em inglês simples e claro.
3. **Summary:** 2 ou 3 frases: o que é, para quem e o que tem de diferente.
4. **How it works:** tópicos curtos: 3 barras, construir, plantar, explorar, tubo de amostra e cartas, eventos com lado bom e lado ruim, sem game over.
5. **Benefits:** o que a criança aprende (as escolhas de uma missão real), grátis, roda no celular, 4 idiomas, sem login, nenhum dado da criança.
6. **NASA data:** primeiro o DONKI, com o link do `creditos.csv` e como o jogo usa as tempestades solares reais (confirme com a dupla de Dev). Depois os fatos e as fotos das 25 cartas, com as fontes do `cartas.csv`, e o modelo 3D do Ingenuity (NASA/JPL-Caltech).
7. **Tools:** as ferramentas do `creditos.csv` (ex.: Godot Engine) e onde o jogo está publicado (GitHub Pages).
8. **Use of AI:** uma linha para cada linha com o tipo `ia` do `creditos.csv`: o que foi feito e com qual IA. Diga que imagem e vídeo feitos com IA têm marca d'água.
9. **References:** uma linha para cada linha do `creditos.csv`: o que é, autor, licença e link. Inclui os recursos grátis (Kenney, sons, fontes).
10. Número só se estiver no `cartas.csv` ou no CONTEXTO.md, com fonte.
11. O site do Space Apps tem limite de caracteres em algum campo? Corte o texto ali e avise a dupla de Dev.
12. Clique em **Commit changes**, avise a dupla de Dev no grupo e marque `[x]` no [TAREFAS.md](../../TAREFAS.md).

Modelo do `pagina.md`:
```markdown
# Mike on Mars

- **Play:** https://out-of-space-exception.github.io/mike-on-mars/
- **Code:** https://github.com/Out-Of-Space-Exception/mike-on-mars
- **Team:** Out of Space Exception (Brazil)
- **Challenge:** Build a Junior Astronaut Mission Trainer

## Summary
## How it works
## Benefits
## NASA data
## Tools
## Use of AI
## References
```

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `pagina.md` | texto em inglês com os 2 links e as 7 seções: Summary, How it works, Benefits, NASA data, Tools, Use of AI, References | `.md` |

## Pronto quando
- [ ] As 7 seções estão preenchidas, em inglês.
- [ ] Os 2 links (jogo e repositório) abrem.
- [ ] O DONKI aparece em "NASA data", com o link.
- [ ] Toda linha do `creditos.csv` aparece em "References".
- [ ] Toda linha `ia` do `creditos.csv` aparece em "Use of AI".
- [ ] Nenhum número sem fonte.

## Não pode
- Texto em português na página.
- Prometer o que o jogo não faz (ex.: dizer que Meridiani e Jezero já dá para jogar: estão "em breve").
- Esquecer recurso grátis: tudo o que veio de fora vai em "References".
- Esconder ou diminuir o uso de IA.
- Logo da NASA ou número inventado.

## Pedido pronto para a IA
Antes, dê o contexto à IA como diz o [AGENTS.md, seção 6](../../AGENTS.md#6-como-dar-este-contexto-para-a-sua-ia). Depois cole:

```text
Siga o AGENTS.md e o CONTEXTO.md do projeto Mike on Mars. Minha tarefa é conteudo/06-pagina-do-projeto (o PASSO.md está junto).
Escreva o texto da página do projeto no NASA Space Apps, em inglês simples e claro, para jurados.
Use exatamente o modelo do PASSO.md, com estas seções e nesta ordem: Summary, How it works, Benefits, NASA data, Tools, Use of AI, References.
- NASA data: comece pelo DONKI (tempestades solares reais); depois os fatos e fotos das cartas, cada um com o link da coluna fonte do cartas.csv.
- Use of AI: uma linha para cada linha com tipo "ia" do creditos.csv.
- References: uma linha para cada linha do creditos.csv (o que é, autor, licença, link).
- Não invente números, recursos nem links. Se faltar algo, escreva CONFERIR.
Saída: só o pagina.md em Markdown, começando por "# Mike on Mars", com os links do jogo e do repositório no topo.
[cole aqui o creditos.csv, o cartas.csv e o slides.md]
```
