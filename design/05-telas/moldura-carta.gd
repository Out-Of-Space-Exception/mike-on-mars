extends Node
## Mike on Mars card frames, made from scratch by the team (code). 1066x1280, background and photo window transparent.
## Layout same as design/05-telas/moldura-carta.md: title 107,92-962,200; photo 60,236-1004,850; description 84,866-990,1134.
## Usage: godot --path <folder> -- <output-folder>
const W := 1066
const H := 1280
const CREAM := Color("f2d091")
const PAPER := Color("f6e6c4")
const WINE := Color("73242a")
const WINE_DARK := Color("3a1418")
const GOLD := Color("e8b23a")
const GOLD_DARK := Color("a87c2a")
const TERRACOTTA := Color("d96941")
const MARS := Color("c2552f")
const RARITY := {"comum": [Color("9aa0a8"), "rocket"], "raro": [Color("3b82d6"), "star5"], "epico": [Color("8e4fd8"), "star6"], "lendario": [Color("e8b23a"), "crown"]}
var rarity_col: Color
var symbol := ""


func _ready() -> void:
	var folder: String = OS.get_cmdline_user_args()[0]
	for r in RARITY.keys():
		rarity_col = RARITY[r][0]
		symbol = RARITY[r][1]
		var vp := SubViewport.new()
		vp.size = Vector2i(W, H)
		vp.transparent_bg = true
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(vp)
		var bg := Control.new()
		bg.size = Vector2(W, H)
		vp.add_child(bg)
		bg.draw.connect(_draw_card.bind(bg))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img := vp.get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		_cut_window(img, Rect2(60, 236, 944, 614), 34.0)
		bg.queue_free()
		var front := Control.new()
		front.size = Vector2(W, H)
		vp.add_child(front)
		front.draw.connect(_draw_front.bind(front))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var top := vp.get_texture().get_image()
		top.convert(Image.FORMAT_RGBA8)
		img.blend_rect(top, Rect2i(0, 0, W, H), Vector2i.ZERO)
		img.save_png(folder + "/moldura-carta-" + r + ".png")
		vp.queue_free()
	print("ok")
	get_tree().quit()


func _rect(c: Control, r: Rect2, col: Color, radius: float) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(int(radius))
	s.anti_aliasing = true
	c.draw_style_box(s, r)


func _rect_border(c: Control, r: Rect2, col: Color, radius: float, border_width: float) -> void:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = col
	s.set_border_width_all(int(border_width))
	s.set_corner_radius_all(int(radius))
	s.anti_aliasing = true
	c.draw_style_box(s, r)


func _polygon(c: Control, center: Vector2, outer_radius: float, inner_radius: float, points: int, col: Color, rotation_start := -PI / 2) -> void:
	var pts := PackedVector2Array()
	for i in points * 2:
		var rr := outer_radius if i % 2 == 0 else inner_radius
		var a := rotation_start + i * PI / points
		pts.append(center + Vector2(cos(a), sin(a)) * rr)
	c.draw_colored_polygon(pts, col)


func _rocket(c: Control, p: Vector2, s: float, angle: float) -> void:
	c.draw_set_transform(p, angle, Vector2(s, s))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-10, 10), Vector2(-22, 26), Vector2(-8, 22)]), Color("bf2a2a"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(10, 10), Vector2(22, 26), Vector2(8, 22)]), Color("bf2a2a"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-10, -12), Vector2(10, -12), Vector2(10, 22), Vector2(-10, 22)]), Color("f4f4f8"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-10, -12), Vector2(0, -34), Vector2(10, -12)]), GOLD)
	c.draw_circle(Vector2(0, 0), 5, Color("3fa7c9"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-6, 22), Vector2(6, 22), Vector2(0, 36)]), Color("f2935c"))
	c.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


func _symbol(c: Control, p: Vector2) -> void:
	if symbol == "rocket":
		_rocket(c, p + Vector2(0, 2), 1.3, 0.5)
	elif symbol == "star5":
		_polygon(c, p, 34, 14, 5, CREAM)
	elif symbol == "star6":
		_polygon(c, p, 36, 18, 6, CREAM)
		_polygon(c, p, 18, 8, 6, rarity_col)
	else:
		var pts := PackedVector2Array([Vector2(-34, 20), Vector2(-34, -16), Vector2(-18, 4), Vector2(0, -26), Vector2(18, 4), Vector2(34, -16), Vector2(34, 20)])
		for i in pts.size():
			pts[i] += p
		c.draw_colored_polygon(pts, CREAM)
		for q in [Vector2(-34, -18), Vector2(0, -28), Vector2(34, -18)]:
			c.draw_circle(p + q, 6, CREAM)


func _draw_card(c: Control) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	# card body: border in the rarity color, gold trim and cream paper
	_rect(c, Rect2(4, 30, W - 8, H - 34), rarity_col.darkened(0.25), 56)
	_rect(c, Rect2(16, 42, W - 32, H - 58), rarity_col, 48)
	_rect(c, Rect2(30, 56, W - 60, H - 86), GOLD, 40)
	_rect(c, Rect2(38, 64, W - 76, H - 102), PAPER, 34)
	for i in 1400:
		var p := Vector2(rng.randf_range(44, W - 44), rng.randf_range(70, H - 44))
		c.draw_circle(p, rng.randf_range(0.6, 1.8), Color(WINE_DARK, rng.randf_range(0.03, 0.08)))
	# corner pieces with little stars
	for q in [Vector2(70, 98), Vector2(W - 70, 98), Vector2(70, H - 70), Vector2(W - 70, H - 70)]:
		_polygon(c, q, 16, 6, 4, rarity_col, 0.0)
		c.draw_circle(q, 4, CREAM)
	# title banner
	var title_rect := Rect2(107, 92, 855, 108)
	_rect(c, title_rect.grow(10), rarity_col.darkened(0.15), 30)
	_rect(c, title_rect.grow(4), GOLD, 26)
	_rect(c, title_rect, CREAM, 22)
	for s in [-1, 1]:
		var x: float = title_rect.position.x - 16 if s < 0 else title_rect.end.x + 16
		var cy := title_rect.get_center().y
		c.draw_colored_polygon(PackedVector2Array([Vector2(x, cy - 30), Vector2(x + s * 34, cy), Vector2(x, cy + 30)]), rarity_col)
	# medallion at the top with the rarity symbol
	var medal := Vector2(W / 2.0, 34)
	c.draw_circle(medal, 58, rarity_col.darkened(0.25))
	c.draw_circle(medal, 52, GOLD)
	c.draw_circle(medal, 44, rarity_col)
	_symbol(c, medal)
	# description panel
	var desc := Rect2(84, 866, 906, 268)
	_rect(c, desc.grow(8), GOLD, 26)
	_rect(c, desc, Color("efe0bd"), 20)
	for q in [desc.position + Vector2(18, 18), Vector2(desc.end.x - 18, desc.position.y + 18)]:
		_polygon(c, q, 9, 4, 4, rarity_col, 0.0)
	# footer: Mars and the two moons (Phobos and Deimos) with orbits
	var fy2 := 1196.0
	var mx := W / 2.0
	c.draw_line(Vector2(120, fy2), Vector2(mx - 110, fy2), GOLD_DARK, 3, true)
	c.draw_line(Vector2(mx + 110, fy2), Vector2(W - 120, fy2), GOLD_DARK, 3, true)
	for x in [120.0, W - 120.0]:
		c.draw_circle(Vector2(x, fy2), 6, rarity_col)
	c.draw_arc(Vector2(mx, fy2), 58, PI * 0.15, PI * 0.85, 24, GOLD_DARK, 3, true)
	c.draw_arc(Vector2(mx, fy2), 58, PI * 1.15, PI * 1.85, 24, GOLD_DARK, 3, true)
	c.draw_circle(Vector2(mx, fy2), 22, MARS)
	c.draw_circle(Vector2(mx - 7, fy2 - 6), 6, TERRACOTTA)
	c.draw_circle(Vector2(mx - 58, fy2), 8, Color("8a7f78"))
	c.draw_circle(Vector2(mx + 58, fy2), 5, Color("8a7f78"))


## Makes the photo window transparent (rounded-corner rectangle).
func _cut_window(img: Image, r: Rect2, radius: float) -> void:
	for y in range(int(r.position.y), int(r.end.y)):
		for x in range(int(r.position.x), int(r.end.x)):
			var dx := maxf(maxf(r.position.x + radius - x, x - (r.end.x - radius)), 0.0)
			var dy := maxf(maxf(r.position.y + radius - y, y - (r.end.y - radius)), 0.0)
			if dx * dx + dy * dy <= radius * radius:
				img.set_pixel(x, y, Color(0, 0, 0, 0))


## What goes ON TOP of the photo: window border, wine banner and Mars seal.
func _draw_front(c: Control) -> void:
	var photo := Rect2(60, 236, 944, 614)
	_rect_border(c, photo.grow(14), rarity_col.darkened(0.2), 44, 8)
	_rect_border(c, photo.grow(6), GOLD, 38, 8)
	# wine banner with the Mars seal over the photo
	var fy := 836.0
	c.draw_colored_polygon(PackedVector2Array([Vector2(150, fy - 26), Vector2(916, fy - 26), Vector2(946, fy), Vector2(916, fy + 26), Vector2(150, fy + 26), Vector2(120, fy)]), WINE)
	c.draw_line(Vector2(150, fy - 20), Vector2(916, fy - 20), GOLD, 3, true)
	c.draw_line(Vector2(150, fy + 20), Vector2(916, fy + 20), GOLD, 3, true)
	var seal := Vector2(W / 2.0, fy - 6)
	c.draw_circle(seal, 62, GOLD)
	c.draw_circle(seal, 56, Color("1f2533"))
	c.draw_circle(seal, 40, MARS)
	c.draw_circle(seal + Vector2(-12, -10), 9, TERRACOTTA)
	c.draw_circle(seal + Vector2(14, 12), 6, WINE)
	c.draw_circle(seal + Vector2(10, -16), 4, WINE)
	c.draw_arc(seal, 50, -0.4, 2.2, 32, Color(CREAM, 0.8), 3, true)
	_rocket(c, seal + Vector2(22, -22), 1.0, 0.7)
