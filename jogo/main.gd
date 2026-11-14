extends Node3D
# Tela provisória: só para testar o caminho Godot -> GitHub Pages -> celular. Vai ser trocada pelo jogo.

var cube: MeshInstance3D
var mat: StandardMaterial3D
var label: Label
var taps := 0


func _ready() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("d08a55")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1.0, 0.9, 0.8)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)

	var cam := Camera3D.new()
	cam.position = Vector3(3.2, 3.2, 3.2)
	add_child(cam)
	cam.look_at(Vector3.ZERO)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	add_child(sun)

	cube = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.4, 1.4, 1.4)
	cube.mesh = box
	mat = StandardMaterial3D.new()
	mat.albedo_color = Color("ff8a3d")
	cube.material_override = mat
	add_child(cube)

	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(6, 6)
	ground.mesh = plane
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color("b9582f")
	ground.material_override = gm
	ground.position.y = -1.0
	add_child(ground)

	var ui := CanvasLayer.new()
	add_child(ui)
	label = Label.new()
	label.position = Vector2(24, 24)
	label.add_theme_font_size_override("font_size", 34)
	ui.add_child(label)


func _process(delta: float) -> void:
	cube.rotate_y(delta * 1.2)
	label.text = "Godot %s · Mike on Mars (teste)\nRenderer: %s\nFPS: %d\nToques: %d (toque na tela)" % [
		Engine.get_version_info().string,
		RenderingServer.get_current_rendering_method(),
		Engine.get_frames_per_second(),
		taps,
	]


func _unhandled_input(event: InputEvent) -> void:
	# No celular o toque chega como clique (emulação de mouse ligada por padrão).
	if event is InputEventMouseButton and event.pressed:
		taps += 1
		mat.albedo_color = Color.from_hsv(randf(), 0.7, 1.0)
