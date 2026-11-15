class_name Palette
## Cores do jogo. Vêm de design/02-cores-e-fonte/cores.csv e de design/04-cores-das-coisas.
## Nenhuma cor fica solta no código: use sempre estas constantes.

# design/02 (cores.csv)
const BG := Color("73242a")       # vinho: fundo
const BUTTON := Color("d96941")   # terracota: botão principal
const TEXT := Color("f2d091")     # creme: texto
const GOLD := Color("e8b23a")     # ouro: destaque e raro
const ALERT := Color("bf2a2a")    # vermelho: alerta

const FONT := "res://ui/fonts/rubik.ttf"   # design/02 (Rubik, OFL)

# design/01 (mike.md)
const SUIT := Color("f4f4f8")
const SUIT_STRIPE := Color("3fa7c9")

# Provisórias até o design/04 chegar (céu caramelo, chão de Marte)
const SKY := Color("d9a066")
const GROUND := Color("b4532a")
const TILE := Color("c46a3c")
const TILE_HI := Color("f4d39b")
const PLANT := Color("6cc04a")

# Raridade (design/04, cores-das-coisas.csv): cinza, azul, roxo, dourado.
const RARITY := {"comum": Color("9aa0a8"), "raro": Color("3b82d6"), "épico": Color("8e4fd8"), "lendário": Color("e8b23a")}
const RARITY_KEY := {"comum": "RARITY_COMMON", "raro": "RARITY_RARE", "épico": "RARITY_EPIC", "lendário": "RARITY_LEGEND"}

# Tempestade solar
const STORM_SKY := Color("8a5a8c")
const DOME := Color(0.45, 0.75, 1.0, 0.18)

# Barras
const BAR := {"energy": GOLD, "oxygen": Color("7cc6e0"), "shield": SUIT_STRIPE}


# Peças da interface (pesquisa/anti-ai-slop.md): cada tipo tem forma própria.
#  - tecla: botão que "afunda" (borda grossa embaixo), é o que a criança toca;
#  - chapa: painel de metal da base, com parafusos (scripts/plate.gd);
#  - papel: a carta e o aviso curto, cor creme, como papel de verdade.
const PLATE := Color("3b1a1e")
const PLATE_EDGE := Color("5c2d31")
const RIVET := Color("8a5a4e")
const PAPER := Color("f2e3c2")
const INK := Color("3b1a1e")
const INK_DEEP := Color("2a1215")   # texto escuro sobre o terracota (5:1, a INK fica no limite)
const OFF := Color("5c2d31")        # botão que ainda não dá para usar (no lugar de deixar transparente)
const UP := Color("9be27a")         # "+3/sol"
const DOWN := Color("ff9a8a")       # "-1/sol"
static var _fonts := {}


## A Rubik é uma fonte variável: sem dizer o peso, ela sai fininha (300). Texto 400, botões 700, títulos 800.
static func font(weight: int) -> Font:
	if not _fonts.has(weight) and ResourceLoader.exists(FONT):
		var f := FontVariation.new()
		f.base_font = load(FONT)
		f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
		_fonts[weight] = f
	return _fonts.get(weight)
const STRIPE_H := 22.0


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 30
	if ResourceLoader.exists(FONT):
		t.default_font = font(400)
		t.set_font("font", "Button", font(700))
	t.set_color("font_color", "Label", TEXT)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "Button", INK)
	t.set_color("font_disabled_color", "Button", Color(INK, 0.45))
	t.set_stylebox("normal", "Button", key(BUTTON))
	t.set_stylebox("hover", "Button", key(BUTTON))
	t.set_stylebox("pressed", "Button", key(BUTTON, true))
	t.set_stylebox("disabled", "Button", key(OFF))
	t.set_color("font_disabled_color", "Button", TEXT)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_stylebox("panel", "PanelContainer", plate(false))
	t.set_stylebox("background", "ProgressBar", _box(Color("2a1215"), 6))
	return t


## Tecla: cantos pouco arredondados e uma borda grossa e mais escura embaixo; apertada, ela "afunda".
static func key(color: Color, pressed := false) -> StyleBoxFlat:
	var b := _box(color, 18)
	b.border_color = INK
	b.border_width_left = 4
	b.border_width_right = 4
	b.border_width_top = 4
	b.border_width_bottom = 4 if pressed else 12
	b.content_margin_left = 24
	b.content_margin_right = 24
	b.content_margin_top = 16 if pressed else 8
	b.content_margin_bottom = 8
	return b


## Chapa de metal: cantos quase retos, borda fina mais clara (os parafusos vêm do plate.gd).
static func plate(stripe := false) -> StyleBoxFlat:
	var b := _box(PLATE, 8)
	b.set_border_width_all(3)
	b.border_color = PLATE_EDGE
	b.content_margin_left = 32
	b.content_margin_right = 32
	b.content_margin_top = 32 + (STRIPE_H if stripe else 0.0)
	b.content_margin_bottom = 32
	return b


## Papel: creme, canto pequeno e uma sombra dura deslocada (como um cartão apoiado na mesa).
static func paper(edge: Color = INK) -> StyleBoxFlat:
	var b := _box(PAPER, 8)
	b.set_border_width_all(3 if edge == INK else 5)
	b.border_color = edge
	b.shadow_color = Color(INK, 0.45)
	b.shadow_size = 0
	b.shadow_offset = Vector2(6, 8)
	b.content_margin_left = 32
	b.content_margin_right = 32
	b.content_margin_top = 32
	b.content_margin_bottom = 32
	return b


static func _box(color: Color, radius: int) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(radius)
	b.content_margin_left = 16
	b.content_margin_right = 16
	b.content_margin_top = 10
	b.content_margin_bottom = 10
	return b


static func bar_fill(color: Color) -> StyleBoxFlat:
	var b := _box(color, 10)
	b.content_margin_top = 0
	b.content_margin_bottom = 0
	return b
