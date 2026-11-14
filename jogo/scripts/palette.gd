class_name Palette
## Cores do jogo. Vêm de design/02-cores-e-fonte/cores.csv e de design/04-cores-das-coisas.
## Nenhuma cor fica solta no código: use sempre estas constantes.

# design/02 (cores.csv)
const BG := Color("73242a")       # vinho: fundo
const BUTTON := Color("d96941")   # terracota: botão principal
const TEXT := Color("f2d091")     # creme: texto
const GOLD := Color("e8b23a")     # ouro: destaque e raro
const ALERT := Color("bf2a2a")    # vermelho: alerta

# design/01 (mike.md)
const SUIT := Color("f4f4f8")
const SUIT_STRIPE := Color("3fa7c9")

# Provisórias até o design/04 chegar (céu caramelo, chão de Marte)
const SKY := Color("d9a066")
const GROUND := Color("b4532a")
const TILE := Color("c46a3c")
const TILE_HI := Color("f4d39b")
const PLANT := Color("6cc04a")

# Raridade: cores fixas que as crianças já conhecem (cinza, azul, roxo, dourado). Tom final: design/04.
const RARITY := {"comum": Color("9aa3ad"), "raro": Color("3b82f6"), "épico": Color("9b5de5"), "lendário": GOLD}
const RARITY_KEY := {"comum": "RARITY_COMMON", "raro": "RARITY_RARE", "épico": "RARITY_EPIC", "lendário": "RARITY_LEGEND"}

# Tempestade solar
const STORM_SKY := Color("8a5a8c")
const DOME := Color(0.45, 0.75, 1.0, 0.18)

# Barras
const BAR := {"energy": GOLD, "oxygen": Color("7cc6e0"), "shield": SUIT_STRIPE}


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 28
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", TEXT)
	t.set_color("font_pressed_color", "Button", TEXT)
	t.set_color("font_disabled_color", "Button", Color(TEXT, 0.45))
	t.set_stylebox("normal", "Button", _box(BUTTON, 18))
	t.set_stylebox("hover", "Button", _box(BUTTON.lightened(0.1), 18))
	t.set_stylebox("pressed", "Button", _box(BUTTON.darkened(0.2), 18))
	t.set_stylebox("disabled", "Button", _box(BUTTON.darkened(0.45), 18))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_stylebox("panel", "PanelContainer", _box(Color(BG, 0.9), 24))
	t.set_stylebox("background", "ProgressBar", _box(Color(BG.lightened(0.15), 1.0), 10))
	return t


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
