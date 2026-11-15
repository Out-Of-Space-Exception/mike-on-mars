class_name Palette
## Game colors. They come from design/02-cores-e-fonte/cores.csv and design/04-cores-das-coisas.
## No color is left loose in the code: always use these constants.

# design/02 (cores.csv)
const BG := Color("73242a")       # wine: background
const BUTTON := Color("d96941")   # terracotta: main button
const TEXT := Color("f2d091")     # cream: text
const GOLD := Color("e8b23a")     # gold: highlight and rare
const ALERT := Color("bf2a2a")    # red: alert

const FONT := "res://ui/fonts/rubik.ttf"   # design/02 (Rubik, OFL)

# design/01 (mike.md)
const SUIT := Color("f4f4f8")
const SUIT_STRIPE := Color("3fa7c9")

# Provisional until design/04 arrives (caramel sky, Mars ground)
const SKY := Color("d9a066")
const GROUND := Color("b4532a")
const TILE := Color("c46a3c")
const TILE_HI := Color("f4d39b")
const PLANT := Color("6cc04a")

# Rarity (design/04, cores-das-coisas.csv): gray, blue, purple, gold.
const RARITY := {"common": Color("9aa0a8"), "rare": Color("3b82d6"), "epic": Color("8e4fd8"), "legendary": Color("e8b23a")}
const RARITY_KEY := {"common": "RARITY_COMMON", "rare": "RARITY_RARE", "epic": "RARITY_EPIC", "legendary": "RARITY_LEGEND"}

# Solar storm
const STORM_SKY := Color("8a5a8c")
const DOME := Color(0.45, 0.75, 1.0, 0.18)

# Bars
const BAR := {"energy": GOLD, "oxygen": Color("7cc6e0"), "shield": SUIT_STRIPE}


# Interface pieces (pesquisa/anti-ai-slop.md): each type has its own shape.
#  - key: a button that "sinks" (thick border at the bottom), it is what the child taps;
#  - plate: metal panel of the base, with screws (scripts/plate.gd);
#  - paper: the card and the short notice, cream color, like real paper.
const PLATE := Color("3b1a1e")
const PLATE_EDGE := Color("5c2d31")
const RIVET := Color("8a5a4e")
const PAPER := Color("f2e3c2")
const INK := Color("3b1a1e")
const INK_DEEP := Color("2a1215")   # dark text on terracotta (5:1, INK is at the limit)
const OFF := Color("5c2d31")        # button that cannot be used yet (instead of leaving it transparent)
const UP := Color("9be27a")         # "+3/sol"
const DOWN := Color("ff9a8a")       # "-1/sol"
static var _fonts := {}


## Rubik is a variable font: without setting the weight, it comes out thin (300). Text 400, buttons 700, titles 800.
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


## Key: slightly rounded corners and a thick, darker border at the bottom; when pressed, it "sinks".
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


## Metal plate: almost square corners, thin lighter border (the screws come from plate.gd).
static func plate(stripe := false) -> StyleBoxFlat:
	var b := _box(PLATE, 8)
	b.set_border_width_all(3)
	b.border_color = PLATE_EDGE
	b.content_margin_left = 32
	b.content_margin_right = 32
	b.content_margin_top = 32 + (STRIPE_H if stripe else 0.0)
	b.content_margin_bottom = 32
	return b


## Paper: cream, small corner and a hard offset shadow (like a card resting on a table).
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
