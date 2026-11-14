extends Node
## Molduras das cartas do Mike on Mars, feitas do zero pelo time (código). 1066x1280, fundo e janela da foto transparentes.
## Layout igual ao design/05-telas/moldura-carta.md: título 107,92-962,200; foto 60,236-1004,850; descrição 84,866-990,1134.
## Uso: godot --path <pasta> -- <pasta-de-saida>
const W := 1066
const H := 1280
const CREME := Color("f2d091")
const PAPEL := Color("f6e6c4")
const VINHO := Color("73242a")
const VINHO_ESC := Color("3a1418")
const OURO := Color("e8b23a")
const OURO_ESC := Color("a87c2a")
const TERRA := Color("d96941")
const MARTE := Color("c2552f")
const RAR := {"comum": [Color("9aa0a8"), "foguete"], "raro": [Color("3b82d6"), "estrela5"], "epico": [Color("8e4fd8"), "estrela6"], "lendario": [Color("e8b23a"), "coroa"]}
var cor: Color
var simbolo := ""


func _ready() -> void:
	var pasta: String = OS.get_cmdline_user_args()[0]
	for r in RAR.keys():
		cor = RAR[r][0]
		simbolo = RAR[r][1]
		var vp := SubViewport.new()
		vp.size = Vector2i(W, H)
		vp.transparent_bg = true
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(vp)
		var fundo := Control.new()
		fundo.size = Vector2(W, H)
		vp.add_child(fundo)
		fundo.draw.connect(_desenhar.bind(fundo))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img := vp.get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		_recortar_janela(img, Rect2(60, 236, 944, 614), 34.0)
		fundo.queue_free()
		var frente := Control.new()
		frente.size = Vector2(W, H)
		vp.add_child(frente)
		frente.draw.connect(_desenhar_frente.bind(frente))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var top := vp.get_texture().get_image()
		top.convert(Image.FORMAT_RGBA8)
		img.blend_rect(top, Rect2i(0, 0, W, H), Vector2i.ZERO)
		img.save_png(pasta + "/moldura-carta-" + r + ".png")
		vp.queue_free()
	print("ok")
	get_tree().quit()


func _ret(c: Control, r: Rect2, col: Color, raio: float) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(int(raio))
	s.anti_aliasing = true
	c.draw_style_box(s, r)


func _ret_borda(c: Control, r: Rect2, col: Color, raio: float, larg: float) -> void:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = col
	s.set_border_width_all(int(larg))
	s.set_corner_radius_all(int(raio))
	s.anti_aliasing = true
	c.draw_style_box(s, r)


func _poligono(c: Control, centro: Vector2, raio_ext: float, raio_int: float, pontas: int, col: Color, giro := -PI / 2) -> void:
	var pts := PackedVector2Array()
	for i in pontas * 2:
		var rr := raio_ext if i % 2 == 0 else raio_int
		var a := giro + i * PI / pontas
		pts.append(centro + Vector2(cos(a), sin(a)) * rr)
	c.draw_colored_polygon(pts, col)


func _foguete(c: Control, p: Vector2, s: float, ang: float) -> void:
	c.draw_set_transform(p, ang, Vector2(s, s))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-10, 10), Vector2(-22, 26), Vector2(-8, 22)]), Color("bf2a2a"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(10, 10), Vector2(22, 26), Vector2(8, 22)]), Color("bf2a2a"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-10, -12), Vector2(10, -12), Vector2(10, 22), Vector2(-10, 22)]), Color("f4f4f8"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-10, -12), Vector2(0, -34), Vector2(10, -12)]), OURO)
	c.draw_circle(Vector2(0, 0), 5, Color("3fa7c9"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-6, 22), Vector2(6, 22), Vector2(0, 36)]), Color("f2935c"))
	c.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


func _simbolo(c: Control, p: Vector2) -> void:
	if simbolo == "foguete":
		_foguete(c, p + Vector2(0, 2), 1.3, 0.5)
	elif simbolo == "estrela5":
		_poligono(c, p, 34, 14, 5, CREME)
	elif simbolo == "estrela6":
		_poligono(c, p, 36, 18, 6, CREME)
		_poligono(c, p, 18, 8, 6, cor)
	else:
		var pts := PackedVector2Array([Vector2(-34, 20), Vector2(-34, -16), Vector2(-18, 4), Vector2(0, -26), Vector2(18, 4), Vector2(34, -16), Vector2(34, 20)])
		for i in pts.size():
			pts[i] += p
		c.draw_colored_polygon(pts, CREME)
		for q in [Vector2(-34, -18), Vector2(0, -28), Vector2(34, -18)]:
			c.draw_circle(p + q, 6, CREME)


func _desenhar(c: Control) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	# corpo da carta: borda na cor da raridade, filete dourado e papel creme
	_ret(c, Rect2(4, 30, W - 8, H - 34), cor.darkened(0.25), 56)
	_ret(c, Rect2(16, 42, W - 32, H - 58), cor, 48)
	_ret(c, Rect2(30, 56, W - 60, H - 86), OURO, 40)
	_ret(c, Rect2(38, 64, W - 76, H - 102), PAPEL, 34)
	for i in 1400:
		var p := Vector2(rng.randf_range(44, W - 44), rng.randf_range(70, H - 44))
		c.draw_circle(p, rng.randf_range(0.6, 1.8), Color(VINHO_ESC, rng.randf_range(0.03, 0.08)))
	# cantoneiras com estrelinhas
	for q in [Vector2(70, 98), Vector2(W - 70, 98), Vector2(70, H - 70), Vector2(W - 70, H - 70)]:
		_poligono(c, q, 16, 6, 4, cor, 0.0)
		c.draw_circle(q, 4, CREME)
	# faixa do título
	var tit := Rect2(107, 92, 855, 108)
	_ret(c, tit.grow(10), cor.darkened(0.15), 30)
	_ret(c, tit.grow(4), OURO, 26)
	_ret(c, tit, CREME, 22)
	for s in [-1, 1]:
		var x: float = tit.position.x - 16 if s < 0 else tit.end.x + 16
		var cy := tit.get_center().y
		c.draw_colored_polygon(PackedVector2Array([Vector2(x, cy - 30), Vector2(x + s * 34, cy), Vector2(x, cy + 30)]), cor)
	# medalhão no topo com o símbolo da raridade
	var med := Vector2(W / 2.0, 34)
	c.draw_circle(med, 58, cor.darkened(0.25))
	c.draw_circle(med, 52, OURO)
	c.draw_circle(med, 44, cor)
	_simbolo(c, med)
	# painel da descrição
	var desc := Rect2(84, 866, 906, 268)
	_ret(c, desc.grow(8), OURO, 26)
	_ret(c, desc, Color("efe0bd"), 20)
	for q in [desc.position + Vector2(18, 18), Vector2(desc.end.x - 18, desc.position.y + 18)]:
		_poligono(c, q, 9, 4, 4, cor, 0.0)
	# rodapé: Marte e as duas luas (Fobos e Deimos) com órbitas
	var fy2 := 1196.0
	var mx := W / 2.0
	c.draw_line(Vector2(120, fy2), Vector2(mx - 110, fy2), OURO_ESC, 3, true)
	c.draw_line(Vector2(mx + 110, fy2), Vector2(W - 120, fy2), OURO_ESC, 3, true)
	for x in [120.0, W - 120.0]:
		c.draw_circle(Vector2(x, fy2), 6, cor)
	c.draw_arc(Vector2(mx, fy2), 58, PI * 0.15, PI * 0.85, 24, OURO_ESC, 3, true)
	c.draw_arc(Vector2(mx, fy2), 58, PI * 1.15, PI * 1.85, 24, OURO_ESC, 3, true)
	c.draw_circle(Vector2(mx, fy2), 22, MARTE)
	c.draw_circle(Vector2(mx - 7, fy2 - 6), 6, TERRA)
	c.draw_circle(Vector2(mx - 58, fy2), 8, Color("8a7f78"))
	c.draw_circle(Vector2(mx + 58, fy2), 5, Color("8a7f78"))


## Deixa transparente a janela da foto (retângulo de cantos arredondados).
func _recortar_janela(img: Image, r: Rect2, raio: float) -> void:
	for y in range(int(r.position.y), int(r.end.y)):
		for x in range(int(r.position.x), int(r.end.x)):
			var dx := maxf(maxf(r.position.x + raio - x, x - (r.end.x - raio)), 0.0)
			var dy := maxf(maxf(r.position.y + raio - y, y - (r.end.y - raio)), 0.0)
			if dx * dx + dy * dy <= raio * raio:
				img.set_pixel(x, y, Color(0, 0, 0, 0))


## O que fica POR CIMA da foto: borda da janela, faixa vinho e selo de Marte.
func _desenhar_frente(c: Control) -> void:
	var foto := Rect2(60, 236, 944, 614)
	_ret_borda(c, foto.grow(14), cor.darkened(0.2), 44, 8)
	_ret_borda(c, foto.grow(6), OURO, 38, 8)
	# faixa vinho com o selo de Marte por cima da foto
	var fy := 836.0
	c.draw_colored_polygon(PackedVector2Array([Vector2(150, fy - 26), Vector2(916, fy - 26), Vector2(946, fy), Vector2(916, fy + 26), Vector2(150, fy + 26), Vector2(120, fy)]), VINHO)
	c.draw_line(Vector2(150, fy - 20), Vector2(916, fy - 20), OURO, 3, true)
	c.draw_line(Vector2(150, fy + 20), Vector2(916, fy + 20), OURO, 3, true)
	var selo := Vector2(W / 2.0, fy - 6)
	c.draw_circle(selo, 62, OURO)
	c.draw_circle(selo, 56, Color("1f2533"))
	c.draw_circle(selo, 40, MARTE)
	c.draw_circle(selo + Vector2(-12, -10), 9, TERRA)
	c.draw_circle(selo + Vector2(14, 12), 6, VINHO)
	c.draw_circle(selo + Vector2(10, -16), 4, VINHO)
	c.draw_arc(selo, 50, -0.4, 2.2, 32, Color(CREME, 0.8), 3, true)
	_foguete(c, selo + Vector2(22, -22), 1.0, 0.7)
