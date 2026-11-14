# Dev · 02 · Teste do caminho

> **Em 1 frase:** provar cedo que Godot → navegador → celular funciona, com uma cena vazia.

- **Dupla:** Dev (Filipe e João)
- **Prazo e status:** no [TAREFAS.md](../../TAREFAS.md)
- **Precisa antes:** [dev/01-destravar-o-time](../01-destravar-o-time/PASSO.md)
- **Quem usa depois:** [dev/03-esqueleto](../03-esqueleto/PASSO.md) e todos os testes no celular

## Por que importa
Problema técnico descoberto às 11h tem conserto. Descoberto às 4h da manhã, derruba o envio. Ainda não é o jogo: é só o caminho.

## Leia antes
- [CONTEXTO.md](../../CONTEXTO.md), seção 2 (roda no navegador, celular primeiro)
- [resultado.md](resultado.md): o que já descobrimos

## Passo a passo
1. Criar o projeto Godot 4.7 em `jogo/` com o renderer **Compatibility** (WebGL2), tela retrato 720 × 1280.
2. Exportar para a Web em **single-thread** (sem precisar de headers especiais no servidor).
3. Publicar no GitHub Pages: `bash ferramentas/publicar.sh` (refaz a branch `gh-pages` do zero).
4. Abrir no celular pelo QR do README e anotar FPS, toque e tempo de carregamento.
5. Anotar o resultado em `resultado.md`.

## O que entregar (nesta pasta)
| Arquivo | O que tem | Formato |
|---|---|---|
| `resultado.md` | o que funcionou, números e pegadinhas | `.md` |

## Pronto quando
- [x] o link https://out-of-space-exception.github.io/mike-on-mars/ abre no celular
- [x] o toque funciona e o FPS fica estável (limitado a 60)
- [x] as pegadinhas estão anotadas em `resultado.md`

## Não pode
- Ligar `vram_texture_compression/for_mobile=true` no export sem configurar o import ETC2/ASTC: dá "configuration errors" sem explicação.
- Hospedar num lugar que não comprime arquivos (ex.: itch.io): o jogo fica 4 vezes mais pesado.

## Pedido pronto para a IA
```text
Siga o AGENTS.md. O projeto Godot está em jogo/ (Godot 4.7, Compatibility, export Web single-thread).
Leia dev/02-teste-do-caminho/resultado.md antes de mudar qualquer configuração de export.
```
