class_name Screens
extends Control
## Concepts for the 7 Mike on Mars screens (Design, step 05). 720x1280, portrait.
## Colors: design/02 (5 colors) + rarities from design/04. Font: Rubik.

const WINE := Color("73242a")
const WINE_DARK := Color("3a1418")
const TERRACOTTA := Color("d96941")
const CREAM := Color("f2d091")
const GOLD := Color("e8b23a")
const RED := Color("bf2a2a")
const RARITY := {"comum": Color("9aa0a8"), "raro": Color("3b82d6"), "epico": Color("8e4fd8"), "lendario": Color("e8b23a")}

var screen_name := "tela-inicial"
var _trails: Array = []   # [Marker2D, Callable(t)->Vector2]
var _t := 0.0


func _ready() -> void:
	match screen_name:
		"tela-inicial": _start_screen()
		"hud-barras": _hud()
		"album": _album()
		"carta": _card()
		"aviso-tempestade": _storm()
		"tubo-revelacao": _tube()
		"cartao-postal": _postcard()


func _process(dt: float) -> void:
	_t += dt
	for r in _trails:
		r[0].global_position = r[1].call(_t)


# ---------------- helpers ----------------
func _font(weight := 700) -> FontVariation:
	var f := FontVariation.new(); f.base_font = load("res://rubik.ttf")
	f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return f


func _text(t: String, size_px: int, col: Color, pos: Vector2, width: float, align := HORIZONTAL_ALIGNMENT_CENTER, weight := 700, parent: Node = self) -> Label:
	var l := Label.new(); l.text = t
	l.add_theme_font_override("font", _font(weight)); l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", col); l.horizontal_alignment = align
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position = pos; l.size = Vector2(width, size_px * 1.4); parent.add_child(l); return l


func _box(r: Rect2, bg: Color, border := Color(0, 0, 0, 0), radius := 24, bw := 0, parent: Node = self) -> Panel:
	var p := Panel.new(); var s := StyleBoxFlat.new(); s.bg_color = bg; s.border_color = border
	s.set_border_width_all(bw); s.set_corner_radius_all(radius); s.anti_aliasing = true
	p.add_theme_stylebox_override("panel", s); p.position = r.position; p.size = r.size; parent.add_child(p); return p


func _background(top_col := WINE_DARK, bottom_col := WINE) -> void:
	var tr := TextureRect.new(); var g := GradientTexture2D.new(); g.fill_from = Vector2(0.5, 0); g.fill_to = Vector2(0.5, 1)
	g.gradient = Gradient.new(); g.gradient.set_color(0, top_col); g.gradient.set_color(1, bottom_col)
	tr.texture = g; tr.stretch_mode = TextureRect.STRETCH_SCALE; tr.size = Vector2(720, 1280); add_child(tr)
	var sky := Control.new(); sky.size = Vector2(720, 1280); sky.mouse_filter = MOUSE_FILTER_IGNORE; add_child(sky)
	var rng := RandomNumberGenerator.new(); rng.seed = 7
	var pts := []
	for i in 80: pts.append([Vector2(rng.randf() * 720, rng.randf() * 1280), rng.randf_range(0.7, 2.2), rng.randf_range(0.2, 0.7)])
	sky.draw.connect(_draw_sky.bind(sky, pts))


func _draw_sky(sky: Control, pts: Array) -> void:
	for s in pts: sky.draw_circle(s[0], s[1], Color(CREAM, s[2]))


func _image(file: String, r: Rect2, parent: Node = self) -> TextureRect:
	var t := TextureRect.new(); t.texture = load(file); t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; t.position = r.position; t.size = r.size; parent.add_child(t); return t


func _trail(path_fn: Callable, trail_size := 1.5) -> void:
	var m := Marker2D.new(); add_child(m)
	var r := ConstellationTrail.new(); r.target = m; r.size_scale = trail_size; r.lifetime = 2.4; r.step = 15.0; r.spread = 20.0; add_child(r)
	_trails.append([m, path_fn])


## Draws a simple icon (for the ones that do not exist in the Kenney packs; the final one comes from step 07).
func _icon(kind: String, center: Vector2, size_px: float, col: Color, parent: Node = self) -> Control:
	var c := Control.new(); c.position = center - Vector2(size_px, size_px) / 2; c.size = Vector2(size_px, size_px); c.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(c)
	c.draw.connect(_draw_icon.bind(c, kind, size_px, col))
	return c


func _draw_icon(c: Control, kind: String, s: float, col: Color) -> void:
		match kind:
			"bolt":
				c.draw_colored_polygon(PackedVector2Array([Vector2(.58, .02), Vector2(.18, .56), Vector2(.46, .56), Vector2(.36, .98), Vector2(.82, .40), Vector2(.54, .40), Vector2(.66, .02)]) * Transform2D().scaled(Vector2(s, s)), col)
			"oxygen":
				c.draw_arc(Vector2(.40, .58) * s, .30 * s, 0, TAU, 32, col, .09 * s, true)
				c.draw_circle(Vector2(.76, .24) * s, .14 * s, col)
				c.draw_circle(Vector2(.80, .62) * s, .07 * s, col)
			"shield":
				c.draw_colored_polygon(PackedVector2Array([Vector2(.5, .04), Vector2(.92, .18), Vector2(.86, .58), Vector2(.5, .96), Vector2(.14, .58), Vector2(.08, .18)]) * Transform2D().scaled(Vector2(s, s)), col)
				c.draw_colored_polygon(PackedVector2Array([Vector2(.5, .2), Vector2(.76, .29), Vector2(.72, .55), Vector2(.5, .78)]) * Transform2D().scaled(Vector2(s, s)), Color(1, 1, 1, .35))
			"camera":
				c.draw_rect(Rect2(Vector2(.06, .28) * s, Vector2(.88, .58) * s), col)
				c.draw_rect(Rect2(Vector2(.32, .16) * s, Vector2(.30, .16) * s), col)
				c.draw_circle(Vector2(.5, .57) * s, .19 * s, WINE_DARK)
				c.draw_circle(Vector2(.5, .57) * s, .11 * s, col)
			"play":
				c.draw_colored_polygon(PackedVector2Array([Vector2(.22, .1), Vector2(.9, .5), Vector2(.22, .9)]) * Transform2D().scaled(Vector2(s, s)), col)
			"sun":
				c.draw_circle(Vector2(.5, .5) * s, .22 * s, col)
				for i in 8:
					var a := i * TAU / 8; var d := Vector2(cos(a), sin(a))
					c.draw_line(Vector2(.5, .5) * s + d * .32 * s, Vector2(.5, .5) * s + d * .46 * s, col, .08 * s, true)


func _button(r: Rect2, icon: String, label_text: String, bg := TERRACOTTA, text_col := WINE_DARK, parent: Node = self) -> Panel:
	var p := _box(r, bg, GOLD, 28, 4, parent)
	var size_px := minf(r.size.y * 0.42, 64.0)
	if icon.ends_with(".png"):
		var t := _image(icon, Rect2(Vector2(r.size.x / 2 - size_px / 2, r.size.y * 0.12), Vector2(size_px, size_px)), p); t.modulate = text_col
	elif icon != "":
		_icon(icon, Vector2(r.size.x / 2, r.size.y * 0.12 + size_px / 2), size_px, text_col, p)
	_text(label_text, int(clampf(minf(r.size.y * 0.2, r.size.x / (0.62 * maxf(label_text.length(), 4.0))), 20, 34)), text_col, Vector2(0, r.size.y * 0.6), r.size.x, HORIZONTAL_ALIGNMENT_CENTER, 700, p)
	return p


func _bar(y: float, icon: String, bar_label: String, value: float, col: Color, parent: Node) -> void:
	_icon(icon, Vector2(52, y + 20), 40, col, parent)
	_text(bar_label, 24, CREAM, Vector2(84, y + 2), 160, HORIZONTAL_ALIGNMENT_LEFT, 600, parent)
	_box(Rect2(Vector2(220, y + 8), Vector2(400, 26)), WINE_DARK, Color(col, .6), 13, 2, parent)
	_box(Rect2(Vector2(224, y + 12), Vector2(392 * value, 18)), col, Color(0, 0, 0, 0), 9, 0, parent)


# ---------------- screens ----------------
func _start_screen() -> void:
	_background()
	var mars := Control.new(); mars.size = Vector2(720, 1280); add_child(mars)
	mars.draw.connect(_draw_horizon.bind(mars))
	_text("Mike on Mars", 84, CREAM, Vector2(0, 150), 720)
	_box(Rect2(Vector2(250, 268), Vector2(220, 5)), GOLD, Color(0, 0, 0, 0), 2)
	_image("res://mike.png", Rect2(Vector2(60, 300), Vector2(600, 800)))
	_trail(func(t): return Vector2(360 + cos(t * 1.6) * 230, 720 + sin(t * 3.2) * 70), 1.6)
	_button(Rect2(Vector2(200, 1030), Vector2(320, 140)), "play", "Play")


func _draw_horizon(mars: Control) -> void:
	mars.draw_circle(Vector2(360, 1420), 560, Color("b4532a"))
	mars.draw_arc(Vector2(360, 1420), 560, PI, TAU, 96, Color(GOLD, .8), 4, true)


func _hud() -> void:
	_image("res://base.png", Rect2(Vector2.ZERO, Vector2(720, 1280)))
	_trail(func(t): return Vector2(395 - fmod(t * 120.0, 260.0), 760 + sin(t * 6.0) * 6.0), 1.2)
	# TOP: place and day + the 4 actions (Explore, Build, Album, Photo)
	var chip := _box(Rect2(Vector2(170, 44), Vector2(380, 50)), Color(WINE_DARK, .85), Color(GOLD, .7), 25, 2)
	_text("Sol 12 · Gale Crater", 24, CREAM, Vector2(0, 9), 380, HORIZONTAL_ALIGNMENT_CENTER, 600, chip)
	var b := [["res://ic2-gi-zoom.png", "Explore"], ["res://ic2-gi-wrench.png", "Build"], ["res://ic2-bg-cards-collection.png", "Album"], ["res://ic2-gi-share1.png", "Photo"]]
	for i in 4:
		_button(Rect2(Vector2(24 + i * 172, 108), Vector2(156, 130)), b[i][0], b[i][1])
	# BOTTOM: the 3 bars + the greenhouse button
	var bottom_col := _box(Rect2(Vector2(24, 1030), Vector2(470, 210)), Color(WINE, .92), GOLD, 28, 3)
	_bar_img(26, "res://ic2-gi-power.png", "Energy", .72, GOLD, bottom_col)
	_bar_img(88, "res://ic2-ge-cloud.png", "Oxygen", .55, CREAM, bottom_col)
	_bar_img(150, "res://ic2-bg-shield.png", "Shield", .86, TERRACOTTA, bottom_col)
	_button(Rect2(Vector2(510, 1030), Vector2(186, 210)), "res://ic2-bg-resource-wheat.png", "Greenhouse")


func _bar_img(y: float, icon: String, bar_label: String, value: float, col: Color, parent: Node) -> void:
	var t := _image(icon, Rect2(Vector2(22, y), Vector2(40, 40)), parent); t.modulate = col
	_text(bar_label, 24, CREAM, Vector2(72, y + 4), 140, HORIZONTAL_ALIGNMENT_LEFT, 600, parent)
	_box(Rect2(Vector2(200, y + 8), Vector2(250, 26)), WINE_DARK, Color(col, .6), 13, 2, parent)
	_box(Rect2(Vector2(204, y + 12), Vector2(242 * value, 18)), col, Color(0, 0, 0, 0), 9, 0, parent)


func _album() -> void:
	_background()
	_text("Album", 56, CREAM, Vector2(0, 60), 720)
	_text("8/40 cards", 30, GOLD, Vector2(0, 140), 720, HORIZONTAL_ALIGNMENT_CENTER, 600)
	_box(Rect2(Vector2(160, 192), Vector2(400, 14)), WINE_DARK, Color(GOLD, .6), 7, 2)
	_box(Rect2(Vector2(163, 195), Vector2(394 * 0.2, 8)), GOLD, Color(0, 0, 0, 0), 4)
	var owned := {0: "comum", 1: "raro", 3: "comum", 6: "lendario", 7: "comum", 10: "epico", 12: "raro", 16: "comum"}
	var w := 118.0; var h := 150.0
	for i in 40:
		var x := 40 + (i % 5) * (w + 12); var y := 240 + int(i / 5) * (h + 14)
		if y > 1180: break
		if owned.has(i):
			var col: Color = RARITY[owned[i]]
			var c := _box(Rect2(Vector2(x, y), Vector2(w, h)), CREAM, col, 16, 6)
			_box(Rect2(Vector2(12, 12), Vector2(w - 24, h * 0.58)), WINE, Color(0, 0, 0, 0), 8, 0, c)
			_text("NASA photo", 14, CREAM, Vector2(12, 12 + h * 0.2), w - 24, HORIZONTAL_ALIGNMENT_CENTER, 600, c)
			_box(Rect2(Vector2(20, h * 0.74), Vector2(w - 40, 10)), col, Color(0, 0, 0, 0), 5, 0, c)
		else:
			var c2 := _box(Rect2(Vector2(x, y), Vector2(w, h)), Color(WINE_DARK, .7), Color(CREAM, .15), 16, 3)
			_text("?", 52, Color(CREAM, .25), Vector2(0, h / 2 - 36), w, HORIZONTAL_ALIGNMENT_CENTER, 700, c2)
	var grad := TextureRect.new(); var g := GradientTexture2D.new(); g.fill_from = Vector2(.5, 0); g.fill_to = Vector2(.5, 1)
	g.gradient = Gradient.new(); g.gradient.set_color(0, Color(WINE, 0)); g.gradient.set_color(1, WINE)
	grad.texture = g; grad.stretch_mode = TextureRect.STRETCH_SCALE; grad.position = Vector2(0, 1100); grad.size = Vector2(720, 180); add_child(grad)


func _card() -> void:
	_image("res://base.png", Rect2(Vector2.ZERO, Vector2(720, 1280)))
	_box(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color(WINE_DARK, .82), Color(0, 0, 0, 0), 0)
	_text("New card!", 58, GOLD, Vector2(0, 110), 720)
	_trail(func(t): return Vector2(360, 680) + Vector2(cos(t * 1.4) * 330, sin(t * 1.4) * 470), 1.4)
	var col: Color = RARITY["raro"]
	var c := _box(Rect2(Vector2(90, 220), Vector2(540, 860)), CREAM, col, 32, 10)
	_box(Rect2(Vector2(36, 36), Vector2(468, 420)), WINE, Color(GOLD, .6), 18, 3, c)
	_text("NASA photo", 36, CREAM, Vector2(36, 220), 468, HORIZONTAL_ALIGNMENT_CENTER, 600, c)
	var chip := _box(Rect2(Vector2(190, 430), Vector2(160, 52)), col, CREAM, 26, 3, c)
	_text("Rare", 28, CREAM, Vector2(0, 8), 160, HORIZONTAL_ALIGNMENT_CENTER, 700, chip)
	_text("MOXIE", 64, WINE, Vector2(0, 510), 540, HORIZONTAL_ALIGNMENT_CENTER, 800, c)
	_text("This is real:", 28, TERRACOTTA, Vector2(0, 610), 540, HORIZONTAL_ALIGNMENT_CENTER, 600, c)
	_text("Turns Mars air into oxygen.", 36, WINE_DARK, Vector2(50, 660), 440, HORIZONTAL_ALIGNMENT_CENTER, 600, c)


func _storm() -> void:
	_image("res://base.png", Rect2(Vector2.ZERO, Vector2(720, 1280)))
	_box(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color(.36, .16, .3, .55), Color(0, 0, 0, 0), 0)
	var p := _box(Rect2(Vector2(40, 250), Vector2(640, 760)), Color(WINE, .97), RED, 32, 6)
	_icon("sun", Vector2(320, 110), 130, GOLD, p)
	_text("Solar storm coming!", 46, CREAM, Vector2(20, 190), 600, HORIZONTAL_ALIGNMENT_CENTER, 800, p)
	_text("Real: May 20, 2024 · NASA data (DONKI)", 22, GOLD, Vector2(20, 262), 600, HORIZONTAL_ALIGNMENT_CENTER, 500, p)
	_text("Raise the shield?", 38, CREAM, Vector2(20, 330), 600, HORIZONTAL_ALIGNMENT_CENTER, 700, p)
	_button(Rect2(Vector2(30, 420), Vector2(280, 300)), "shield", "Shield (uses energy)", TERRACOTTA, WINE_DARK, p)
	_button(Rect2(Vector2(330, 420), Vector2(280, 300)), "res://ic-home.png", "Mike stays inside", WINE_DARK, CREAM, p)


func _tube() -> void:
	_background(Color("1c0a0c"), WINE_DARK)
	var col: Color = RARITY["raro"]
	var glow := Control.new(); glow.size = Vector2(720, 1280); add_child(glow)
	glow.draw.connect(_draw_glow.bind(glow, col))
	_text("Tap to open!", 50, CREAM, Vector2(0, 150), 720)
	_trail(func(t): return Vector2(360, 640) + Vector2(cos(t * 2.2) * 200, sin(t * 2.2) * 290), 1.5)
	var tube := Control.new(); tube.size = Vector2(720, 1280); add_child(tube)
	tube.rotation = deg_to_rad(-8); tube.pivot_offset = Vector2(360, 640)
	tube.draw.connect(_draw_tube.bind(tube, col))
	var chip := _box(Rect2(Vector2(250, 1010), Vector2(220, 70)), col, CREAM, 35, 4)
	_text("Rare", 38, CREAM, Vector2(0, 10), 220, HORIZONTAL_ALIGNMENT_CENTER, 700, chip)


func _draw_glow(glow: Control, col: Color) -> void:
	for i in 12:
		glow.draw_circle(Vector2(360, 640), 360 - i * 26, Color(col, 0.035 + i * 0.012))
	for i in 16:
		var a := i * TAU / 16; var d := Vector2(cos(a), sin(a))
		glow.draw_line(Vector2(360, 640) + d * 230, Vector2(360, 640) + d * (300 + (i % 2) * 60), Color(col, .55), 4, true)


func _draw_tube(tube: Control, col: Color) -> void:
	tube.draw_rect(Rect2(Vector2(300, 430), Vector2(120, 420)), Color(CREAM, .92))
	tube.draw_circle(Vector2(360, 850), 60, Color(CREAM, .92))
	tube.draw_rect(Rect2(Vector2(312, 600), Vector2(96, 250)), Color(col, .85))
	tube.draw_circle(Vector2(360, 850), 48, Color(col, .85))
	tube.draw_rect(Rect2(Vector2(290, 380), Vector2(140, 66)), GOLD)
	tube.draw_rect(Rect2(Vector2(290, 440), Vector2(140, 10)), Color("a87c2a"))
	tube.draw_rect(Rect2(Vector2(318, 470), Vector2(14, 300)), Color(1, 1, 1, .45))
	for k in [-1, 1]:
		for j in 3:
			tube.draw_line(Vector2(360 + k * (100 + j * 22), 560 + j * 60), Vector2(360 + k * (130 + j * 22), 540 + j * 60), Color(CREAM, .8), 5, true)


func _postcard() -> void:
	_background()
	var cart := Control.new(); cart.size = Vector2(720, 1280); cart.rotation = deg_to_rad(-3); cart.pivot_offset = Vector2(360, 640); add_child(cart)
	_box(Rect2(Vector2(50, 170), Vector2(620, 940)), CREAM, GOLD, 18, 6, cart)
	var photo := _image("res://base.png", Rect2(Vector2(80, 200), Vector2(560, 760)), cart)
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; photo.clip_contents = true
	var seal := _box(Rect2(Vector2(520, 220), Vector2(100, 120)), WINE, GOLD, 10, 4, cart)
	_icon("sun", Vector2(50, 60), 64, GOLD, seal)
	_text("Sol 47 · Gale Crater", 40, WINE, Vector2(50, 990), 620, HORIZONTAL_ALIGNMENT_CENTER, 800, cart)
	_trail(func(t): return Vector2(360, 640) + Vector2(cos(t * 1.3) * 320, sin(t * 1.3) * 520), 1.2)
	_button(Rect2(Vector2(230, 1150), Vector2(260, 110)), "camera", "Photo")
