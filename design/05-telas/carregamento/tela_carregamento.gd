extends Control
## Tela de carregamento do Mike on Mars (conceito do Design, passo 05).
## Marte gira no meio; a nave é a barra de progresso e deixa o rastro de constelação.
## O Dev só precisa mudar `progresso` (0.0 a 1.0) enquanto o jogo carrega.

const VINHO := Color("73242a")
const VINHO_ESCURO := Color("3a1418")
const TERRACOTA := Color("d96941")
const CREME := Color("f2d091")
const OURO := Color("e8b23a")

@export_range(0.0, 1.0) var progresso := 0.0
@export var demo := true  ## true = a barra enche sozinha (para testar)

var _planeta: MeshInstance3D
var _trilho: Panel
var _enchimento: TextureRect
var _nave: TextureRect
var _ponta: Marker2D
var _pct: Label
var _ceu: Node2D
var _tempo := 0.0
var _foto := ""
var _foto_em := 0.62
var _pasta: String = (get_script() as Script).resource_path.get_base_dir()  ## carrega os arquivos desta mesma pasta


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--foto="): _foto = a.trim_prefix("--foto=")
		if a.begins_with("--em="): _foto_em = float(a.trim_prefix("--em="))
	_montar()


func _montar() -> void:
	var fundo := TextureRect.new()
	var g := GradientTexture2D.new(); g.fill_from = Vector2(0.5, 0); g.fill_to = Vector2(0.5, 1)
	g.gradient = Gradient.new(); g.gradient.set_color(0, VINHO_ESCURO); g.gradient.set_color(1, VINHO)
	fundo.texture = g; fundo.set_anchors_preset(PRESET_FULL_RECT); fundo.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(fundo)
	_ceu = Node2D.new(); _ceu.set_script(_script_ceu()); add_child(_ceu)

	var fonte := FontVariation.new(); fonte.base_font = load(_pasta + "/rubik.ttf"); fonte.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
	var titulo := Label.new(); titulo.text = "Mike on Mars"
	titulo.add_theme_font_override("font", fonte); titulo.add_theme_font_size_override("font_size", 72)
	titulo.add_theme_color_override("font_color", CREME)
	titulo.add_theme_color_override("font_outline_color", VINHO_ESCURO); titulo.add_theme_constant_override("outline_size", 10)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(0, 150); titulo.size = Vector2(720, 100); add_child(titulo)
	var linha := ColorRect.new(); linha.color = OURO; linha.position = Vector2(260, 250); linha.size = Vector2(200, 4); add_child(linha)

	# Marte 3D num SubViewport transparente
	var caixa := SubViewportContainer.new(); caixa.stretch = true; caixa.position = Vector2(60, 300); caixa.size = Vector2(600, 600); add_child(caixa)
	var vp := SubViewport.new(); vp.transparent_bg = true; vp.size = Vector2i(600, 600); vp.own_world_3d = true; caixa.add_child(vp)
	var cam := Camera3D.new(); cam.position = Vector3(0, 0, 2.55); cam.fov = 40; vp.add_child(cam)
	var sol := DirectionalLight3D.new(); sol.rotation_degrees = Vector3(-20, -45, 0); sol.light_energy = 1.3; vp.add_child(sol)
	var amb := WorldEnvironment.new(); var env := Environment.new(); env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color = Color(1, 0.85, 0.75); env.ambient_light_energy = 0.35
	amb.environment = env; vp.add_child(amb)
	_planeta = MeshInstance3D.new(); var esfera := SphereMesh.new(); esfera.radial_segments = 96; esfera.rings = 48; _planeta.mesh = esfera
	var mat := ShaderMaterial.new(); mat.shader = load(_pasta + "/marte.gdshader")
	mat.set_shader_parameter("ruido1", _ruido(2.0, 11)); mat.set_shader_parameter("ruido2", _ruido(5.0, 27))
	_planeta.material_override = mat; _planeta.rotation_degrees = Vector3(18, 0, -12); vp.add_child(_planeta)

	# Barra de carregamento: trilho + enchimento + nave
	_trilho = Panel.new(); _trilho.position = Vector2(100, 1010); _trilho.size = Vector2(520, 30)
	var st := StyleBoxFlat.new(); st.bg_color = VINHO_ESCURO; st.border_color = OURO; st.set_border_width_all(3); st.set_corner_radius_all(15)
	_trilho.add_theme_stylebox_override("panel", st); add_child(_trilho)
	_enchimento = TextureRect.new(); var gf := GradientTexture2D.new(); gf.gradient = Gradient.new()
	gf.gradient.set_color(0, TERRACOTA); gf.gradient.set_color(1, OURO); _enchimento.texture = gf
	_enchimento.stretch_mode = TextureRect.STRETCH_SCALE; _enchimento.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_enchimento.position = Vector2(6, 6); _enchimento.size = Vector2(0, 18); _trilho.add_child(_enchimento)
	_nave = TextureRect.new(); _nave.texture = load(_pasta + "/nave.png"); _nave.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_nave.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; _nave.size = Vector2(150, 150); add_child(_nave)
	_ponta = Marker2D.new(); add_child(_ponta)
	var rastro := ConstelacaoRastro.new(); rastro.alvo = _ponta; rastro.tamanho = 1.6; rastro.vida = 2.2; rastro.passo = 16.0; rastro.espalhar = 24.0; add_child(rastro)
	_pct = Label.new(); _pct.add_theme_font_override("font", fonte); _pct.add_theme_font_size_override("font_size", 34)
	_pct.add_theme_color_override("font_color", CREME); _pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pct.position = Vector2(0, 1060); _pct.size = Vector2(720, 50); add_child(_pct)


func _ruido(freq: float, semente: int) -> NoiseTexture2D:
	var n := FastNoiseLite.new(); n.seed = semente; n.frequency = 0.006 * freq; n.fractal_octaves = 3; n.fractal_gain = 0.45
	var t := NoiseTexture2D.new(); t.noise = n; t.seamless = true; t.width = 512; t.height = 256; return t


func _process(dt: float) -> void:
	_tempo += dt
	if demo:
		progresso = clampf(_tempo / 5.0, 0.0, 1.0)
		if _tempo > 6.5: _tempo = 0.0
	_planeta.rotate_y(dt * 0.35)
	var largura := (_trilho.size.x - 12.0) * progresso
	_enchimento.size.x = largura
	var cabeca := _trilho.position + Vector2(6.0 + largura, 15.0)
	_nave.position = cabeca - Vector2(55, 88) + Vector2(0, sin(_tempo * 5.0) * 3.0)
	_ponta.global_position = cabeca + Vector2(-34, -12)
	_pct.text = "%d%%" % int(round(progresso * 100.0))
	if _foto != "" and progresso >= _foto_em:
		var f := _foto; _foto = ""
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(f); get_tree().quit()


func _script_ceu() -> GDScript:
	var s := GDScript.new()
	s.source_code = """extends Node2D
var e := []
func _ready():
	var r := RandomNumberGenerator.new(); r.seed = 7
	for i in 90: e.append([Vector2(r.randf()*720.0, r.randf()*1280.0), r.randf_range(0.6, 2.2), r.randf()*TAU])
func _process(_d): queue_redraw()
func _draw():
	var t := Time.get_ticks_msec() / 1000.0
	for s in e:
		var a: float = 0.35 + 0.35 * sin(t * 2.0 + s[2])
		draw_circle(s[0], s[1], Color(0.95, 0.82, 0.57, a))
"""
	s.reload(); return s
