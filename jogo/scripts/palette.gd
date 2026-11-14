class_name Palette
## Cores do jogo. Vêm de design/02-cores-e-fonte/cores.csv e de design/04-cores-das-coisas.
## Nenhuma cor fica solta no código: use sempre estas constantes.

# design/02 (cores.csv)
const BG := Color("1f2533")       # noite: fundo
const BUTTON := Color("1b6f91")   # azul-traje: botão principal
const TEXT := Color("f4f1ea")     # creme: texto
const GOLD := Color("d4a84b")     # ouro: destaque e raro
const ALERT := Color("c92f2f")    # vermelho-alerta

# design/01 (mike.md)
const SUIT := Color("f4f4f8")
const SUIT_STRIPE := Color("3fa7c9")

# Provisórias até o design/04 chegar (céu caramelo, chão de Marte)
const SKY := Color("d9a066")
const GROUND := Color("b4532a")
const TILE := Color("c46a3c")
const TILE_HI := Color("f4d39b")
const PLANT := Color("6cc04a")

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
