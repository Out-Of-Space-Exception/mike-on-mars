# Dev · 03 · Esqueleto

> **Em 1 frase:** a primeira versão jogável no celular: base salva no aparelho, construir/mover/remover com um toque, a estufa e as 3 barras.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [dev/02-teste-do-caminho](../02-teste-do-caminho/PASSO.md); se já tiver: [design/01-mike](../../design/01-mike/PASSO.md), [design/03-itens-do-jogo](../../design/03-itens-do-jogo/PASSO.md)
- **Quem usa depois:** todos os passos seguintes de Dev e os testes no celular das duplas

## Por que importa
Daqui para a frente todo mundo testa o jogo de verdade pelo QR. E a **estrutura do código definida aqui vale para todos os passos de Dev**: é o padrão do código.

## Leia antes
- [CONTEXTO.md](../../CONTEXTO.md), seção 3 (como funciona) e seção 4 (estilo)
- [dev/02-teste-do-caminho/resultado.md](../02-teste-do-caminho/resultado.md)
- [textos.csv](../../conteudo/03-textos/textos.csv): as chaves dos textos

## Padrão do código (vale para todo o `jogo/`)

```
jogo/
├── main.tscn            ← cena inicial
├── autoload/
│   ├── state.gd         ← "State": barras, itens da base, cartas, sol; salva e carrega
│   └── sfx.gd           ← "Sfx": toca um som pelo nome do arquivo
├── scenes/              ← base.tscn, hud.tscn, build_menu.tscn, card.tscn, tube.tscn ...
├── scripts/             ← scripts que não são de uma cena só
├── data/                ← textos.csv e cartas.json (cópias geradas, não editar à mão), donki.json
├── models/              ← kenney/<pacote>/*.glb (+ textura) e nasa/ingenuity.glb
├── sounds/              ← os .ogg do conteudo/01-sons (cópia)
└── ui/                  ← theme.tres, fonts/, icons/
```

| Regra | Como |
|---|---|
| Linguagem | GDScript **com tipos** (`var energy: float`). Nomes de arquivo, nó e variável em inglês; comentários em português. |
| Números do jogo | Todos no topo do `autoload/state.gd`, num bloco `# BALANCEAMENTO`. Nunca espalhados. |
| Texto na tela | Nunca escrito no código: sempre `tr("CHAVE")` com uma chave do `textos.csv`. Chave nova → adicionar no `textos.csv` (PT e EN). |
| Cores | Só do `ui/theme.tres` e da constante `PALETTE`, que vem de `design/02` e `design/04`. |
| Toque | Só toque: `InputEventMouseButton`. Nada de hover, nada de arrastar, nada de toque longo. |
| Tela | Retrato 720 × 1280. Botão com no mínimo 96 px de altura, com ícone + 1 palavra. |
| Salvar | `user://save.json` (no navegador vira IndexedDB), com `version`, `saved_at` (Unix), barras, itens, cartas e sol. Salvar a cada ação e a cada 10 s. |
| Tempo | 1 sol = 2,5 s. Alface = 33 sóis (~80 s), zínia ~60 sóis, pimenta ~120 sóis (~5 min). |
| Conteúdo | Nunca editar `jogo/data/` à mão: rodar `bash ferramentas/sincronizar.sh`, que copia o `textos.csv`, converte o `cartas.csv` em `cartas.json` e copia os sons. |
| Kenney | Baixar os pacotes **fora** do repositório e copiar para `jogo/models/kenney/<pacote>/` só os `.glb` usados (e a textura que eles usam). |

## Passo a passo
1. Criar a estrutura de pastas acima e os 2 autoloads (`State`, `Sfx`).
2. Criar `ferramentas/sincronizar.sh` (copia `textos.csv`, gera `cartas.json`, copia os sons) e rodar.
3. Montar a base: chão marciano, câmera isométrica (ortogonal, de cima, em diagonal) e uma **grade de 6 × 8 quadrados**. Céu caramelo provisório.
4. Construir: toque no item do menu → os quadrados livres acendem → toque num quadrado = constrói. Toque num item construído → menu **Mover / Melhorar / Remover**. Mover = tocar em outro quadrado. Remover devolve tudo, sem multa.
5. Itens do esqueleto: Casa do Mike (já começa construída), Estufa, Painel solar, RTG, MOXIE. Enquanto os modelos não chegam, usar caixas coloridas.
6. Barras (valores iniciais; ajustar jogando):
   - ⚡ Energia 0–100: painel +3/sol, RTG +1/sol, estufa plantando −1/sol.
   - 🫁 Oxigênio 0–100: MOXIE +2/sol.
   - 🛡️ Escudo 0–100: recarrega +2/sol se a energia estiver acima de 20.
   - Barra baixa **trava ou desacelera**. Nunca game over.
7. Estufa: plantar alface → cresce em 33 sóis → colher (o Mike pula).
8. Colocar o Mike (Mini Characters) andando até o que a criança tocar. Abrir o modelo e **anotar as animações que ele tem** em `animacoes.md`.
9. Ligar o carregamento: fechar e abrir a aba → base igual.
10. Publicar com `bash ferramentas/publicar.sh` e avisar no grupo: "recarreguem pelo QR".

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `animacoes.md` | lista das animações do Mike que vieram no pacote | `.md` |
| o jogo em [jogo/](../../jogo/) | o esqueleto, no padrão acima | projeto Godot |
| [ferramentas/sincronizar.sh](../../ferramentas/) | o script de cópia do conteúdo | `.sh` |

## Pronto quando
- [ ] abre no celular pelo QR em menos de 10 s
- [ ] constrói, move, melhora e remove só com toques
- [ ] as 3 barras se mexem e uma barra baixa trava uma ação (sem game over)
- [ ] planta e colhe uma alface
- [ ] fecha a aba, abre de novo e a base está igual
- [ ] todo texto vem do `textos.csv` (trocar o idioma muda tudo)
- [ ] FPS ≥ 50 no celular mais fraco do time

## Não pode
- Escrever texto ou número de balanceamento solto no código.
- Arrastar (criança de 7 anos erra): só toque.
- Subir pacote inteiro da Kenney no repositório.
- Mudar a configuração de export sem ler o `resultado.md` do passo 02.

## Pedido pronto para a IA
```text
Siga o AGENTS.md, o CONTEXTO.md e o dev/03-esqueleto/PASSO.md deste repositório (Godot 4.7, GDScript tipado,
web, celular primeiro). Implemente [parte do passo] respeitando a seção "Padrão do código":
textos com tr(), números no bloco BALANCEAMENTO do state.gd, só toque, tela 720x1280.
Mostre só os arquivos que mudaram.
```
