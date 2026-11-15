extends Control
## Mike on Mars loading screen (Design concept, step 05).
## Mars spins in the middle; the ship is the progress bar and leaves the constellation trail.
## The Dev only needs to change `progress` (0.0 to 1.0) while the game loads.

const WINE := Color("73242a")
const WINE_DARK := Color("3a1418")
const TERRACOTTA := Color("d96941")
const CREAM := Color("f2d091")
const GOLD := Color("e8b23a")

@export_range(0.0, 1.0) var progress := 0.0
@export var demo := true  ## true = the bar fills by itself (for testing)

var _planet: MeshInstance3D
var _track: Panel
var _fill: TextureRect
var _ship: TextureRect
var _tip: Marker2D
var _pct: Label
var _sky: Node2D
var _time := 0.0
var _photo := ""
var _photo_at := 0.62
var _folder: String = (get_script() as Script).resource_path.get_base_dir()  ## loads the files from this same folder


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--foto="): _photo = a.trim_prefix("--foto=")
		if a.begins_with("--em="): _photo_at = float(a.trim_prefix("--em="))
	_build()


func _build() -> void:
	var background := TextureRect.new()
	var g := GradientTexture2D.new(); g.fill_from = Vector2(0.5, 0); g.fill_to = Vector2(0.5, 1)
	g.gradient = Gradient.new(); g.gradient.set_color(0, WINE_DARK); g.gradient.set_color(1, WINE)
	background.texture = g; background.set_anchors_preset(PRESET_FULL_RECT); background.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(background)
	_sky = Node2D.new(); _sky.set_script(_sky_script()); add_child(_sky)

	var font := FontVariation.new(); font.base_font = load(_folder + "/rubik.ttf"); font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
	var title := Label.new(); title.text = "Mike on Mars"
	title.add_theme_font_override("font", font); title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", CREAM)
	title.add_theme_color_override("font_outline_color", WINE_DARK); title.add_theme_constant_override("outline_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 150); title.size = Vector2(720, 100); add_child(title)
	var line := ColorRect.new(); line.color = GOLD; line.position = Vector2(260, 250); line.size = Vector2(200, 4); add_child(line)

	# 3D Mars in a transparent SubViewport
	var box := SubViewportContainer.new(); box.stretch = true; box.position = Vector2(60, 300); box.size = Vector2(600, 600); add_child(box)
	var vp := SubViewport.new(); vp.transparent_bg = true; vp.size = Vector2i(600, 600); vp.own_world_3d = true; box.add_child(vp)
	var cam := Camera3D.new(); cam.position = Vector3(0, 0, 2.55); cam.fov = 40; vp.add_child(cam)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-20, -45, 0); sun.light_energy = 1.3; vp.add_child(sun)
	var amb := WorldEnvironment.new(); var env := Environment.new(); env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color = Color(1, 0.85, 0.75); env.ambient_light_energy = 0.35
	amb.environment = env; vp.add_child(amb)
	_planet = MeshInstance3D.new(); var sphere := SphereMesh.new(); sphere.radial_segments = 96; sphere.rings = 48; _planet.mesh = sphere
	var mat := ShaderMaterial.new(); mat.shader = load(_folder + "/marte.gdshader")
	mat.set_shader_parameter("noise1", _noise(2.0, 11)); mat.set_shader_parameter("noise2", _noise(5.0, 27))
	_planet.material_override = mat; _planet.rotation_degrees = Vector3(18, 0, -12); vp.add_child(_planet)

	# Loading bar: track + fill + ship
	_track = Panel.new(); _track.position = Vector2(100, 1010); _track.size = Vector2(520, 30)
	var st := StyleBoxFlat.new(); st.bg_color = WINE_DARK; st.border_color = GOLD; st.set_border_width_all(3); st.set_corner_radius_all(15)
	_track.add_theme_stylebox_override("panel", st); add_child(_track)
	_fill = TextureRect.new(); var gf := GradientTexture2D.new(); gf.gradient = Gradient.new()
	gf.gradient.set_color(0, TERRACOTTA); gf.gradient.set_color(1, GOLD); _fill.texture = gf
	_fill.stretch_mode = TextureRect.STRETCH_SCALE; _fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fill.position = Vector2(6, 6); _fill.size = Vector2(0, 18); _track.add_child(_fill)
	_ship = TextureRect.new(); _ship.texture = load(_folder + "/nave.png"); _ship.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ship.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; _ship.size = Vector2(150, 150); add_child(_ship)
	_tip = Marker2D.new(); add_child(_tip)
	var trail := ConstellationTrail.new(); trail.target = _tip; trail.size_scale = 1.6; trail.lifetime = 2.2; trail.step = 16.0; trail.spread = 24.0; add_child(trail)
	_pct = Label.new(); _pct.add_theme_font_override("font", font); _pct.add_theme_font_size_override("font_size", 34)
	_pct.add_theme_color_override("font_color", CREAM); _pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pct.position = Vector2(0, 1060); _pct.size = Vector2(720, 50); add_child(_pct)


func _noise(freq: float, seed_value: int) -> NoiseTexture2D:
	var n := FastNoiseLite.new(); n.seed = seed_value; n.frequency = 0.006 * freq; n.fractal_octaves = 3; n.fractal_gain = 0.45
	var t := NoiseTexture2D.new(); t.noise = n; t.seamless = true; t.width = 512; t.height = 256; return t


func _process(dt: float) -> void:
	_time += dt
	if demo:
		progress = clampf(_time / 5.0, 0.0, 1.0)
		if _time > 6.5: _time = 0.0
	_planet.rotate_y(dt * 0.35)
	var width := (_track.size.x - 12.0) * progress
	_fill.size.x = width
	var head := _track.position + Vector2(6.0 + width, 15.0)
	_ship.position = head - Vector2(55, 88) + Vector2(0, sin(_time * 5.0) * 3.0)
	_tip.global_position = head + Vector2(-34, -12)
	_pct.text = "%d%%" % int(round(progress * 100.0))
	if _photo != "" and progress >= _photo_at:
		var f := _photo; _photo = ""
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(f); get_tree().quit()


func _sky_script() -> GDScript:
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
