# Padrão do time (para pessoas e para IAs)

Este repositório **é o contexto do jogo**. Tudo o que alguém, ou uma IA, precisa saber para trabalhar no Mike on Mars está aqui.
Se não está aqui, não foi decidido: pergunte no grupo antes de inventar.

---

## 1. Ordem de leitura (sempre a mesma)

1. [CONTEXTO.md](CONTEXTO.md): o jogo inteiro.
2. [TAREFAS.md](TAREFAS.md): quem faz o quê, até quando e o que já foi feito.
3. O `PASSO.md` da sua tarefa: como fazer e o que entregar.

---

## 2. Onde fica cada coisa

```
mike-on-mars/
├── AGENTS.md        ← este padrão
├── CONTEXTO.md      ← o jogo (regras, fatos, estilo, tom)
├── TAREFAS.md       ← painel: horário, dupla e status de cada passo
├── creditos.csv     ← tudo o que veio de fora + onde usamos IA
├── design/          ← passos da dupla de Design
│   └── 01-mike/
│       ├── PASSO.md ← como fazer
│       └── ...      ← o que o passo produz fica aqui mesmo
├── conteudo/        ← passos da dupla de Conteúdo e pitch
├── dev/             ← passos da dupla de Dev
├── jogo/            ← o jogo em si (projeto Godot); só a dupla de Dev mexe
├── pesquisa/        ← pesquisas com as fontes
└── ferramentas/     ← scripts para testar e publicar
```

---

## 3. As regras

1. **Uma informação mora em um lugar só.**
   - **Fatos do jogo:** [CONTEXTO.md](CONTEXTO.md). Os fatos de cada carta ficam no `cartas.csv`.
   - **Horário e status:** [TAREFAS.md](TAREFAS.md).
   - **Como fazer:** `PASSO.md`.

   Não copie de um lugar para outro: coloque o link.
2. **Cada passo é uma pasta:** `area/NN-nome/`, com um `PASSO.md` dentro. Tudo o que o passo produz fica **na mesma pasta**. Se um passo seguinte precisar mexer no mesmo arquivo, ele mexe lá mesmo, sem fazer cópia.
3. **Formatos:**

   | Tipo | Formato |
   |---|---|
   | Lista | `.csv` (UTF-8, separado por vírgula, 1ª linha = nomes das colunas) |
   | Explicação | `.md` |
   | Imagem | `.png` (foto real: `.jpg`) |
   | Som | `.ogg` (ou `.wav`) |
   | Modelo 3D | `.glb` |
   | Cor | sempre em hex, com `#` e 6 letras/números: `#C1440E` |
4. **Nome de arquivo:** minúsculas, sem acento, sem espaço, com hífen. Ex.: `tela-inicial.png`, `cores.csv`.
5. **Terminou um passo?** Marque `[x]` no [TAREFAS.md](TAREFAS.md).
6. **Usou algo de fora** (modelo, som, fonte, ícone, foto)? Anote numa linha do [creditos.csv](creditos.csv). Sem crédito, não entra no jogo. Só vale licença **CC0** ou **CC-BY** (fontes: também **OFL**, a licença do Google Fonts).
7. **Usou IA?** Também vai no [creditos.csv](creditos.csv), com o tipo `ia`: o que foi feito e com qual IA. O Space Apps exige isso. Imagem ou vídeo feito com IA leva marca d'água.
8. **Fato só com fonte.** Todo número, data ou missão precisa de link, de preferência da NASA. Não tem fonte? Não entra.
9. **Não mexa no que é de outra dupla.** Quer mudar algo? Avise no grupo.
10. **Simples primeiro.** Na dúvida entre duas opções, fique com a mais simples.

---

## 4. Regras extras para IAs

- Leia na ordem da seção 1 antes de responder.
- Só crie ou edite arquivos **dentro da pasta do passo** que você está fazendo, além da sua linha no `creditos.csv` e da sua caixinha no `TAREFAS.md`.
- Não renomeie nem mova pastas ou arquivos que já existem.
- Em `.csv`, nunca mude a 1ª linha (os nomes das colunas) nem a coluna `keys` ou `id`.
- Textos que o jogador ou o jurado lê: **inglês simples**, frases curtas, sem parecer coisa de bebê.
- Não invente fato, número, data, missão, link ou licença. Se não souber, escreva `CONFERIR` e diga o que falta.
- Respostas curtas e diretas.
- Quem roda código pode conferir o padrão com `node ferramentas/conferir-padrao.mjs`.

---

## 5. Modelo de PASSO.md

Todo passo segue este modelo, com as mesmas seções e na mesma ordem:

```markdown
# Área · NN · Nome do passo

> **Em 1 frase:** o que este passo faz.

- **Dupla:** nome da dupla (pessoas)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** pasta(s) de passo(s) com link, ou "nada"
- **Quem usa depois:** pasta(s) de passo(s) com link

## Por que importa
2 ou 3 frases: o que isso muda no jogo ou na nota dos jurados.

## Leia antes
- links para as seções do CONTEXTO.md e para os arquivos que este passo usa

## Passo a passo
1. ações curtas, na ordem, cada uma com um verbo no começo

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|

## Pronto quando
- [ ] critérios que dá para conferir olhando

## Não pode
- os erros mais prováveis deste passo

## Pedido pronto para a IA
um texto para colar na IA junto com o contexto
```

---

## 6. Como dar este contexto para a sua IA

- **Se a IA lê o GitHub:** mande o link do repositório e diga "Siga o AGENTS.md".
- **Se não lê:** cole, nesta ordem, o `AGENTS.md`, o `CONTEXTO.md` e o `PASSO.md` da sua tarefa. Depois escreva o que você quer.
