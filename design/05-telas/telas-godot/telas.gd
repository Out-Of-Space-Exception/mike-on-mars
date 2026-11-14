class_name Telas
extends Control
## Conceitos das 7 telas do Mike on Mars (Design, passo 05). 720x1280, retrato.
## Cores: design/02 (5 cores) + raridades do design/04. Fonte: Rubik.

const VINHO := Color("73242a")
const VINHO_ESCURO := Color("3a1418")
const TERRACOTA := Color("d96941")
const CREME := Color("f2d091")
const OURO := Color("e8b23a")
const VERMELHO := Color("bf2a2a")
const RARIDADE := {"comum": Color("9aa0a8"), "raro": Color("3b82d6"), "epico": Color("8e4fd8"), "lendario": Color("e8b23a")}

var qual := "tela-inicial"
var _rastros: Array = []   # [Marker2D, Callable(t)->Vector2]
var _t := 0.0


func _ready() -> void:
	match qual:
		"tela-inicial": _tela_inicial()
		"hud-barras": _hud()
		"album": _album()
		"carta": _carta()
		"aviso-tempestade": _tempestade()
		"tubo-revelacao": _tubo()
		"cartao-postal": _postal()


func _process(dt: float) -> void:
	_t += dt
	for r in _rastros:
		r[0].global_position = r[1].call(_t)


# ---------------- ajudantes ----------------
func _fonte(peso := 700) -> FontVariation:
	var f := FontVariation.new(); f.base_font = load("res://rubik.ttf")
	f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): peso}
	return f


func _texto(t: String, tam: int, cor: Color, pos: Vector2, larg: float, alin := HORIZONTAL_ALIGNMENT_CENTER, peso := 700, pai: Node = self) -> Label:
	var l := Label.new(); l.text = t
	l.add_theme_font_override("font", _fonte(peso)); l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor); l.horizontal_alignment = alin
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position = pos; l.size = Vector2(larg, tam * 1.4); pai.add_child(l); return l


func _caixa(r: Rect2, fundo: Color, borda := Color(0, 0, 0, 0), raio := 24, bw := 0, pai: Node = self) -> Panel:
	var p := Panel.new(); var s := StyleBoxFlat.new(); s.bg_color = fundo; s.border_color = borda
	s.set_border_width_all(bw); s.set_corner_radius_all(raio); s.anti_aliasing = true
	p.add_theme_stylebox_override("panel", s); p.position = r.position; p.size = r.size; pai.add_child(p); return p


func _fundo(cima := VINHO_ESCURO, baixo := VINHO) -> void:
	var tr := TextureRect.new(); var g := GradientTexture2D.new(); g.fill_from = Vector2(0.5, 0); g.fill_to = Vector2(0.5, 1)
	g.gradient = Gradient.new(); g.gradient.set_color(0, cima); g.gradient.set_color(1, baixo)
	tr.texture = g; tr.stretch_mode = TextureRect.STRETCH_SCALE; tr.size = Vector2(720, 1280); add_child(tr)
	var ceu := Control.new(); ceu.size = Vector2(720, 1280); ceu.mouse_filter = MOUSE_FILTER_IGNORE; add_child(ceu)
	var rng := RandomNumberGenerator.new(); rng.seed = 7
	var pts := []
	for i in 80: pts.append([Vector2(rng.randf() * 720, rng.randf() * 1280), rng.randf_range(0.7, 2.2), rng.randf_range(0.2, 0.7)])
	ceu.draw.connect(_desenhar_ceu.bind(ceu, pts))


func _desenhar_ceu(ceu: Control, pts: Array) -> void:
	for s in pts: ceu.draw_circle(s[0], s[1], Color(CREME, s[2]))


func _imagem(arq: String, r: Rect2, pai: Node = self) -> TextureRect:
	var t := TextureRect.new(); t.texture = load(arq); t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; t.position = r.position; t.size = r.size; pai.add_child(t); return t


func _rastro(caminho: Callable, tamanho := 1.5) -> void:
	var m := Marker2D.new(); add_child(m)
	var r := ConstelacaoRastro.new(); r.alvo = m; r.tamanho = tamanho; r.vida = 2.4; r.passo = 15.0; r.espalhar = 20.0; add_child(r)
	_rastros.append([m, caminho])


## Desenha um ícone simples (para os que não existem nos pacotes da Kenney; o final sai do passo 07).
func _icone(tipo: String, centro: Vector2, tam: float, cor: Color, pai: Node = self) -> Control:
	var c := Control.new(); c.position = centro - Vector2(tam, tam) / 2; c.size = Vector2(tam, tam); c.mouse_filter = MOUSE_FILTER_IGNORE
	pai.add_child(c)
	c.draw.connect(_desenhar_icone.bind(c, tipo, tam, cor))
	return c


func _desenhar_icone(c: Control, tipo: String, s: float, cor: Color) -> void:
		match tipo:
			"raio":
				c.draw_colored_polygon(PackedVector2Array([Vector2(.58, .02), Vector2(.18, .56), Vector2(.46, .56), Vector2(.36, .98), Vector2(.82, .40), Vector2(.54, .40), Vector2(.66, .02)]) * Transform2D().scaled(Vector2(s, s)), cor)
			"oxigenio":
				c.draw_arc(Vector2(.40, .58) * s, .30 * s, 0, TAU, 32, cor, .09 * s, true)
				c.draw_circle(Vector2(.76, .24) * s, .14 * s, cor)
				c.draw_circle(Vector2(.80, .62) * s, .07 * s, cor)
			"escudo":
				c.draw_colored_polygon(PackedVector2Array([Vector2(.5, .04), Vector2(.92, .18), Vector2(.86, .58), Vector2(.5, .96), Vector2(.14, .58), Vector2(.08, .18)]) * Transform2D().scaled(Vector2(s, s)), cor)
				c.draw_colored_polygon(PackedVector2Array([Vector2(.5, .2), Vector2(.76, .29), Vector2(.72, .55), Vector2(.5, .78)]) * Transform2D().scaled(Vector2(s, s)), Color(1, 1, 1, .35))
			"camera":
				c.draw_rect(Rect2(Vector2(.06, .28) * s, Vector2(.88, .58) * s), cor)
				c.draw_rect(Rect2(Vector2(.32, .16) * s, Vector2(.30, .16) * s), cor)
				c.draw_circle(Vector2(.5, .57) * s, .19 * s, VINHO_ESCURO)
				c.draw_circle(Vector2(.5, .57) * s, .11 * s, cor)
			"play":
				c.draw_colored_polygon(PackedVector2Array([Vector2(.22, .1), Vector2(.9, .5), Vector2(.22, .9)]) * Transform2D().scaled(Vector2(s, s)), cor)
			"sol":
				c.draw_circle(Vector2(.5, .5) * s, .22 * s, cor)
				for i in 8:
					var a := i * TAU / 8; var d := Vector2(cos(a), sin(a))
					c.draw_line(Vector2(.5, .5) * s + d * .32 * s, Vector2(.5, .5) * s + d * .46 * s, cor, .08 * s, true)


func _botao(r: Rect2, icone: String, texto: String, fundo := TERRACOTA, cor_txt := VINHO_ESCURO, pai: Node = self) -> Panel:
	var p := _caixa(r, fundo, OURO, 28, 4, pai)
	var tam := minf(r.size.y * 0.42, 64.0)
	if icone.ends_with(".png"):
		var t := _imagem(icone, Rect2(Vector2(r.size.x / 2 - tam / 2, r.size.y * 0.12), Vector2(tam, tam)), p); t.modulate = cor_txt
	elif icone != "":
		_icone(icone, Vector2(r.size.x / 2, r.size.y * 0.12 + tam / 2), tam, cor_txt, p)
	_texto(texto, int(clampf(minf(r.size.y * 0.2, r.size.x / (0.62 * maxf(texto.length(), 4.0))), 20, 34)), cor_txt, Vector2(0, r.size.y * 0.6), r.size.x, HORIZONTAL_ALIGNMENT_CENTER, 700, p)
	return p


func _barra(y: float, icone: String, nome: String, valor: float, cor: Color, pai: Node) -> void:
	_icone(icone, Vector2(52, y + 20), 40, cor, pai)
	_texto(nome, 24, CREME, Vector2(84, y + 2), 160, HORIZONTAL_ALIGNMENT_LEFT, 600, pai)
	_caixa(Rect2(Vector2(220, y + 8), Vector2(400, 26)), VINHO_ESCURO, Color(cor, .6), 13, 2, pai)
	_caixa(Rect2(Vector2(224, y + 12), Vector2(392 * valor, 18)), cor, Color(0, 0, 0, 0), 9, 0, pai)


# ---------------- telas ----------------
func _tela_inicial() -> void:
	_fundo()
	var mars := Control.new(); mars.size = Vector2(720, 1280); add_child(mars)
	mars.draw.connect(_desenhar_horizonte.bind(mars))
	_texto("Mike on Mars", 84, CREME, Vector2(0, 150), 720)
	_caixa(Rect2(Vector2(250, 268), Vector2(220, 5)), OURO, Color(0, 0, 0, 0), 2)
	_imagem("res://mike.png", Rect2(Vector2(60, 300), Vector2(600, 800)))
	_rastro(func(t): return Vector2(360 + cos(t * 1.6) * 230, 720 + sin(t * 3.2) * 70), 1.6)
	_botao(Rect2(Vector2(200, 1030), Vector2(320, 140)), "play", "Play")


func _desenhar_horizonte(mars: Control) -> void:
	mars.draw_circle(Vector2(360, 1420), 560, Color("b4532a"))
	mars.draw_arc(Vector2(360, 1420), 560, PI, TAU, 96, Color(OURO, .8), 4, true)


func _hud() -> void:
	_imagem("res://base.png", Rect2(Vector2.ZERO, Vector2(720, 1280)))
	_rastro(func(t): return Vector2(395 - fmod(t * 120.0, 260.0), 760 + sin(t * 6.0) * 6.0), 1.2)
	# EM CIMA: lugar e dia + as 4 ações (Explore, Build, Album, Photo)
	var chip := _caixa(Rect2(Vector2(170, 44), Vector2(380, 50)), Color(VINHO_ESCURO, .85), Color(OURO, .7), 25, 2)
	_texto("Sol 12 · Gale Crater", 24, CREME, Vector2(0, 9), 380, HORIZONTAL_ALIGNMENT_CENTER, 600, chip)
	var b := [["res://ic2-gi-zoom.png", "Explore"], ["res://ic2-gi-wrench.png", "Build"], ["res://ic2-bg-cards-collection.png", "Album"], ["res://ic2-gi-share1.png", "Photo"]]
	for i in 4:
		_botao(Rect2(Vector2(24 + i * 172, 108), Vector2(156, 130)), b[i][0], b[i][1])
	# EMBAIXO: as 3 barras + o botão da estufa
	var baixo := _caixa(Rect2(Vector2(24, 1030), Vector2(470, 210)), Color(VINHO, .92), OURO, 28, 3)
	_barra_ic(26, "res://ic2-gi-power.png", "Energy", .72, OURO, baixo)
	_barra_ic(88, "res://ic2-ge-cloud.png", "Oxygen", .55, CREME, baixo)
	_barra_ic(150, "res://ic2-bg-shield.png", "Shield", .86, TERRACOTA, baixo)
	_botao(Rect2(Vector2(510, 1030), Vector2(186, 210)), "res://ic2-bg-resource-wheat.png", "Greenhouse")


func _barra_ic(y: float, icone: String, nome: String, valor: float, cor: Color, pai: Node) -> void:
	var t := _imagem(icone, Rect2(Vector2(22, y), Vector2(40, 40)), pai); t.modulate = cor
	_texto(nome, 24, CREME, Vector2(72, y + 4), 140, HORIZONTAL_ALIGNMENT_LEFT, 600, pai)
	_caixa(Rect2(Vector2(200, y + 8), Vector2(250, 26)), VINHO_ESCURO, Color(cor, .6), 13, 2, pai)
	_caixa(Rect2(Vector2(204, y + 12), Vector2(242 * valor, 18)), cor, Color(0, 0, 0, 0), 9, 0, pai)


func _album() -> void:
	_fundo()
	_texto("Album", 56, CREME, Vector2(0, 60), 720)
	_texto("8/40 cards", 30, OURO, Vector2(0, 140), 720, HORIZONTAL_ALIGNMENT_CENTER, 600)
	_caixa(Rect2(Vector2(160, 192), Vector2(400, 14)), VINHO_ESCURO, Color(OURO, .6), 7, 2)
	_caixa(Rect2(Vector2(163, 195), Vector2(394 * 0.2, 8)), OURO, Color(0, 0, 0, 0), 4)
	var tem := {0: "comum", 1: "raro", 3: "comum", 6: "lendario", 7: "comum", 10: "epico", 12: "raro", 16: "comum"}
	var w := 118.0; var h := 150.0
	for i in 40:
		var x := 40 + (i % 5) * (w + 12); var y := 240 + int(i / 5) * (h + 14)
		if y > 1180: break
		if tem.has(i):
			var cor: Color = RARIDADE[tem[i]]
			var c := _caixa(Rect2(Vector2(x, y), Vector2(w, h)), CREME, cor, 16, 6)
			_caixa(Rect2(Vector2(12, 12), Vector2(w - 24, h * 0.58)), VINHO, Color(0, 0, 0, 0), 8, 0, c)
			_texto("NASA photo", 14, CREME, Vector2(12, 12 + h * 0.2), w - 24, HORIZONTAL_ALIGNMENT_CENTER, 600, c)
			_caixa(Rect2(Vector2(20, h * 0.74), Vector2(w - 40, 10)), cor, Color(0, 0, 0, 0), 5, 0, c)
		else:
			var c2 := _caixa(Rect2(Vector2(x, y), Vector2(w, h)), Color(VINHO_ESCURO, .7), Color(CREME, .15), 16, 3)
			_texto("?", 52, Color(CREME, .25), Vector2(0, h / 2 - 36), w, HORIZONTAL_ALIGNMENT_CENTER, 700, c2)
	var grad := TextureRect.new(); var g := GradientTexture2D.new(); g.fill_from = Vector2(.5, 0); g.fill_to = Vector2(.5, 1)
	g.gradient = Gradient.new(); g.gradient.set_color(0, Color(VINHO, 0)); g.gradient.set_color(1, VINHO)
	grad.texture = g; grad.stretch_mode = TextureRect.STRETCH_SCALE; grad.position = Vector2(0, 1100); grad.size = Vector2(720, 180); add_child(grad)


func _carta() -> void:
	_imagem("res://base.png", Rect2(Vector2.ZERO, Vector2(720, 1280)))
	_caixa(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color(VINHO_ESCURO, .82), Color(0, 0, 0, 0), 0)
	_texto("New card!", 58, OURO, Vector2(0, 110), 720)
	_rastro(func(t): return Vector2(360, 680) + Vector2(cos(t * 1.4) * 330, sin(t * 1.4) * 470), 1.4)
	var cor: Color = RARIDADE["raro"]
	var c := _caixa(Rect2(Vector2(90, 220), Vector2(540, 860)), CREME, cor, 32, 10)
	_caixa(Rect2(Vector2(36, 36), Vector2(468, 420)), VINHO, Color(OURO, .6), 18, 3, c)
	_texto("NASA photo", 36, CREME, Vector2(36, 220), 468, HORIZONTAL_ALIGNMENT_CENTER, 600, c)
	var chip := _caixa(Rect2(Vector2(190, 430), Vector2(160, 52)), cor, CREME, 26, 3, c)
	_texto("Rare", 28, CREME, Vector2(0, 8), 160, HORIZONTAL_ALIGNMENT_CENTER, 700, chip)
	_texto("MOXIE", 64, VINHO, Vector2(0, 510), 540, HORIZONTAL_ALIGNMENT_CENTER, 800, c)
	_texto("This is real:", 28, TERRACOTA, Vector2(0, 610), 540, HORIZONTAL_ALIGNMENT_CENTER, 600, c)
	_texto("Turns Mars air into oxygen.", 36, VINHO_ESCURO, Vector2(50, 660), 440, HORIZONTAL_ALIGNMENT_CENTER, 600, c)


func _tempestade() -> void:
	_imagem("res://base.png", Rect2(Vector2.ZERO, Vector2(720, 1280)))
	_caixa(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color(.36, .16, .3, .55), Color(0, 0, 0, 0), 0)
	var p := _caixa(Rect2(Vector2(40, 250), Vector2(640, 760)), Color(VINHO, .97), VERMELHO, 32, 6)
	_icone("sol", Vector2(320, 110), 130, OURO, p)
	_texto("Solar storm coming!", 46, CREME, Vector2(20, 190), 600, HORIZONTAL_ALIGNMENT_CENTER, 800, p)
	_texto("Real: May 20, 2024 · NASA data (DONKI)", 22, OURO, Vector2(20, 262), 600, HORIZONTAL_ALIGNMENT_CENTER, 500, p)
	_texto("Raise the shield?", 38, CREME, Vector2(20, 330), 600, HORIZONTAL_ALIGNMENT_CENTER, 700, p)
	_botao(Rect2(Vector2(30, 420), Vector2(280, 300)), "escudo", "Shield (uses energy)", TERRACOTA, VINHO_ESCURO, p)
	_botao(Rect2(Vector2(330, 420), Vector2(280, 300)), "res://ic-home.png", "Mike stays inside", VINHO_ESCURO, CREME, p)


func _tubo() -> void:
	_fundo(Color("1c0a0c"), VINHO_ESCURO)
	var cor: Color = RARIDADE["raro"]
	var brilho := Control.new(); brilho.size = Vector2(720, 1280); add_child(brilho)
	brilho.draw.connect(_desenhar_brilho.bind(brilho, cor))
	_texto("Tap to open!", 50, CREME, Vector2(0, 150), 720)
	_rastro(func(t): return Vector2(360, 640) + Vector2(cos(t * 2.2) * 200, sin(t * 2.2) * 290), 1.5)
	var tubo := Control.new(); tubo.size = Vector2(720, 1280); add_child(tubo)
	tubo.rotation = deg_to_rad(-8); tubo.pivot_offset = Vector2(360, 640)
	tubo.draw.connect(_desenhar_tubo.bind(tubo, cor))
	var chip := _caixa(Rect2(Vector2(250, 1010), Vector2(220, 70)), cor, CREME, 35, 4)
	_texto("Rare", 38, CREME, Vector2(0, 10), 220, HORIZONTAL_ALIGNMENT_CENTER, 700, chip)


func _desenhar_brilho(brilho: Control, cor: Color) -> void:
	for i in 12:
		brilho.draw_circle(Vector2(360, 640), 360 - i * 26, Color(cor, 0.035 + i * 0.012))
	for i in 16:
		var a := i * TAU / 16; var d := Vector2(cos(a), sin(a))
		brilho.draw_line(Vector2(360, 640) + d * 230, Vector2(360, 640) + d * (300 + (i % 2) * 60), Color(cor, .55), 4, true)


func _desenhar_tubo(tubo: Control, cor: Color) -> void:
	tubo.draw_rect(Rect2(Vector2(300, 430), Vector2(120, 420)), Color(CREME, .92))
	tubo.draw_circle(Vector2(360, 850), 60, Color(CREME, .92))
	tubo.draw_rect(Rect2(Vector2(312, 600), Vector2(96, 250)), Color(cor, .85))
	tubo.draw_circle(Vector2(360, 850), 48, Color(cor, .85))
	tubo.draw_rect(Rect2(Vector2(290, 380), Vector2(140, 66)), OURO)
	tubo.draw_rect(Rect2(Vector2(290, 440), Vector2(140, 10)), Color("a87c2a"))
	tubo.draw_rect(Rect2(Vector2(318, 470), Vector2(14, 300)), Color(1, 1, 1, .45))
	for k in [-1, 1]:
		for j in 3:
			tubo.draw_line(Vector2(360 + k * (100 + j * 22), 560 + j * 60), Vector2(360 + k * (130 + j * 22), 540 + j * 60), Color(CREME, .8), 5, true)


func _postal() -> void:
	_fundo()
	var cart := Control.new(); cart.size = Vector2(720, 1280); cart.rotation = deg_to_rad(-3); cart.pivot_offset = Vector2(360, 640); add_child(cart)
	_caixa(Rect2(Vector2(50, 170), Vector2(620, 940)), CREME, OURO, 18, 6, cart)
	var foto := _imagem("res://base.png", Rect2(Vector2(80, 200), Vector2(560, 760)), cart)
	foto.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; foto.clip_contents = true
	var selo := _caixa(Rect2(Vector2(520, 220), Vector2(100, 120)), VINHO, OURO, 10, 4, cart)
	_icone("sol", Vector2(50, 60), 64, OURO, selo)
	_texto("Sol 47 · Gale Crater", 40, VINHO, Vector2(50, 990), 620, HORIZONTAL_ALIGNMENT_CENTER, 800, cart)
	_rastro(func(t): return Vector2(360, 640) + Vector2(cos(t * 1.3) * 320, sin(t * 1.3) * 520), 1.2)
	_botao(Rect2(Vector2(230, 1150), Vector2(260, 110)), "camera", "Photo")
