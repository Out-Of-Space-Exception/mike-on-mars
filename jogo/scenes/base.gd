extends Node3D
## A base em 3D: chão, grade, itens, Mike e câmera. Só desenha o que está no State.
## Quem decide o que um toque faz é o HUD (recebe o sinal cell_tapped).
## Itens são caixas provisórias até os modelos da Kenney chegarem (design/03).

signal cell_tapped(cell: Vector2i)

const CELL := 2.0
const OUTSIDE := Vector2i(-1, -1)
const ITEM_COLORS := {
	"habitat": Palette.SUIT, "greenhouse": Color("9fd4a3"), "solar": Palette.BUTTON,
	"rtg": Palette.ALERT, "moxie": Palette.GOLD,
}

const MIKE_SCENE := "res://models/mike/mike.glb"
const MIKE_MODEL_HEIGHT := 4.0   # altura do mike.glb em unidades do arquivo
const MIKE_HEIGHT := 2.2         # altura do Mike no jogo (grande de propósito, para a criança ver)
const MIKE_ANIMS := {"idle": "res://models/mike/idle.fbx", "run": "res://models/mike/run.fbx", "jump": "res://models/mike/jump.fbx"}

var camera: Camera3D
var mike: Node3D
var _mike_anim: AnimationPlayer
var _env: Environment
var _sun: DirectionalLight3D
var _dome: MeshInstance3D
var _walking_out := false

const EXPEDITION_CELL := Vector2i(-4, -4)   # fora da grade, no fundo da tela
var _tiles := {}    # "x,y" -> MeshInstance3D
var _nodes := {}    # "x,y" -> Node3D do item
var _tile_mat: StandardMaterial3D
var _tile_hi_mat: StandardMaterial3D
var _mike_tween: Tween


func _ready() -> void:
	_build_world()
	_build_grid()
	_build_mike()
	_build_dome()
	State.changed.connect(_sync_items)
	State.changed.connect(_sync_storm)
	State.storm_started.connect(func(_e: Dictionary) -> void: _sync_storm())
	State.explore_started.connect(_walk_out)
	State.explore_returned.connect(_walk_back)
	_sync_items()
	_sync_storm()


## Expedição: o Mike sai andando para longe (lá para o fundo, rumo ao Monte Sharp) e some.
func _walk_out() -> void:
	_walking_out = true
	var far := cell_center(EXPEDITION_CELL)
	mike.rotation.y = atan2(far.x - mike.position.x, far.z - mike.position.z)
	if _mike_tween:
		_mike_tween.kill()
	_play_mike("run")
	_mike_tween = create_tween()
	_mike_tween.tween_property(mike, "position", far, 1.8)
	_mike_tween.tween_callback(func() -> void:
		_walking_out = false
		_play_mike("idle")
		_sync_storm())


## Volta da expedição: aparece lá no fundo e anda até a frente da casa, com o tubo.
func _walk_back(_card_id: int) -> void:
	mike.position = cell_center(EXPEDITION_CELL)
	_sync_storm()
	for k in State.items:
		if State.items[k].type == "habitat":
			walk_to(State.parse_key(k))
			return


## Tempestade: céu e luz arroxeados; com escudo, uma cúpula protege a base; sem escudo, o Mike some dentro de casa.
func _sync_storm() -> void:
	var storm: bool = State.storm_active() or State.paused
	_sun.light_color = Palette.STORM_SKY.lightened(0.4) if storm else Color.WHITE
	_env.ambient_light_color = Palette.STORM_SKY if storm else Color(1.0, 0.88, 0.78)
	_dome.visible = State.storm_active() and State.storm_shielded
	mike.visible = _walking_out or not (State.mike_inside() or State.exploring())


func _build_dome() -> void:
	_dome = MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.is_hemisphere = true
	sph.radius = 9.5
	sph.height = 6.0
	_dome.mesh = sph
	var m := StandardMaterial3D.new()
	m.albedo_color = Palette.DOME
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_dome.material_override = m
	_dome.visible = false
	add_child(_dome)


func cell_center(c: Vector2i) -> Vector3:
	var x0 := -State.GRID_W * CELL / 2.0
	var z0 := -State.GRID_H * CELL / 2.0
	return Vector3(x0 + (c.x + 0.5) * CELL, 0.0, z0 + (c.y + 0.5) * CELL)


func highlight(cells: Array) -> void:
	for k in _tiles:
		_tiles[k].material_override = _tile_mat
	for c in cells:
		_tiles[State.key(c)].material_override = _tile_hi_mat


## O Mike anda até a frente da casa tocada.
func walk_to(c: Vector2i) -> void:
	var target := cell_center(c) + Vector3(0.0, 0.0, CELL * 0.62)
	var dir := target - mike.position
	if dir.length() < 0.05:
		return
	mike.rotation.y = atan2(dir.x, dir.z)
	if _mike_tween:
		_mike_tween.kill()
	_mike_tween = create_tween()
	_play_mike("run")
	_mike_tween.tween_property(mike, "position", target, clampf(dir.length() / 5.0, 0.25, 1.4))
	_mike_tween.tween_callback(_play_mike.bind("idle"))


## O Mike pula de alegria (quando colhe, por exemplo).
func jump() -> void:
	if _mike_anim and _mike_anim.has_animation("jump"):
		_play_mike("jump")
		_mike_anim.queue("idle")
		return
	var t := create_tween()
	t.tween_property(mike, "position:y", 0.9, 0.18).set_ease(Tween.EASE_OUT)
	t.tween_property(mike, "position:y", 0.0, 0.22).set_ease(Tween.EASE_IN)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cell_tapped.emit(_cell_from_screen(event.position))


func _cell_from_screen(p: Vector2) -> Vector2i:
	var o := camera.project_ray_origin(p)
	var d := camera.project_ray_normal(p)
	if absf(d.y) < 0.0001:
		return OUTSIDE
	var hit := o + d * (-o.y / d.y)
	var c := Vector2i(floori((hit.x + State.GRID_W * CELL / 2.0) / CELL), floori((hit.z + State.GRID_H * CELL / 2.0) / CELL))
	return c if State.in_grid(c) else OUTSIDE


# ───────────── Montagem ─────────────
func _build_world() -> void:
	var env := Environment.new()
	_env = env
	env.background_mode = Environment.BG_COLOR
	env.background_color = Palette.SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.88, 0.78)
	env.ambient_light_energy = 0.6
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	_sun = sun
	sun.rotation_degrees = Vector3(-55.0, -35.0, 0.0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 19.0
	camera.rotation_degrees = Vector3(-35.264, 45.0, 0.0)
	add_child(camera)
	camera.position = camera.transform.basis.z * 40.0 + Vector3(0.0, 0.0, 0.0)
	camera.current = true

	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(160.0, 160.0)
	ground.mesh = plane
	ground.material_override = _mat(Palette.GROUND)
	ground.position.y = -0.02
	add_child(ground)


func _build_grid() -> void:
	_tile_mat = _mat(Palette.TILE)
	_tile_hi_mat = _mat(Palette.TILE_HI)
	var tile := PlaneMesh.new()
	tile.size = Vector2(CELL * 0.92, CELL * 0.92)
	for x in State.GRID_W:
		for y in State.GRID_H:
			var c := Vector2i(x, y)
			var m := MeshInstance3D.new()
			m.mesh = tile
			m.material_override = _tile_mat
			m.position = cell_center(c) + Vector3(0.0, 0.01, 0.0)
			add_child(m)
			_tiles[State.key(c)] = m


## O Mike do design/01 (mike.glb). As animações idle/run/jump entram sozinhas quando os .fbx
## chegarem em design/01-mike/ (o sincronizar.mjs copia). Sem elas, o Mike fica de braços abaixados.
func _build_mike() -> void:
	mike = Node3D.new()
	add_child(mike)
	mike.position = cell_center(Vector2i(2, 4)) + Vector3(0.0, 0.0, CELL * 0.62)
	if not ResourceLoader.exists(MIKE_SCENE):
		_build_mike_placeholder()
		return
	var model: Node3D = load(MIKE_SCENE).instantiate()
	model.scale = Vector3.ONE * (MIKE_HEIGHT / MIKE_MODEL_HEIGHT)
	mike.add_child(model)
	var skel := _find_child_of_type(model, "Skeleton3D") as Skeleton3D
	if skel == null:
		return
	_mike_anim = AnimationPlayer.new()
	model.add_child(_mike_anim)
	var lib := AnimationLibrary.new()
	for anim_name in MIKE_ANIMS:
		var path: String = MIKE_ANIMS[anim_name]
		if not ResourceLoader.exists(path):
			continue
		var src: Node = load(path).instantiate()
		var src_player := _find_child_of_type(src, "AnimationPlayer") as AnimationPlayer
		if src_player and not src_player.get_animation_list().is_empty():
			var a: Animation = src_player.get_animation(src_player.get_animation_list()[0]).duplicate()
			# Aponta cada trilha para o esqueleto do Mike (os ossos têm o mesmo nome).
			for t in range(a.get_track_count() - 1, -1, -1):
				var bone := a.track_get_path(t).get_concatenated_subnames()
				if bone == "" or skel.find_bone(bone) < 0:
					a.remove_track(t)
				else:
					a.track_set_path(t, NodePath("%s:%s" % [model.get_path_to(skel), bone]))
			a.loop_mode = Animation.LOOP_NONE if anim_name == "jump" else Animation.LOOP_LINEAR
			lib.add_animation(anim_name, a)
		src.free()
	_mike_anim.add_animation_library("", lib)
	if lib.has_animation("idle"):
		_mike_anim.play("idle")
	else:
		_lower_arms(skel)


func _play_mike(anim_name: String) -> void:
	if _mike_anim and _mike_anim.has_animation(anim_name):
		_mike_anim.play(anim_name, 0.15)


## Tira o Mike da pose em T: gira cada braço em direção ao chão.
func _lower_arms(skel: Skeleton3D) -> void:
	for side in ["Left", "Right"]:
		var arm := skel.find_bone(side + "Arm")
		var fore := skel.find_bone(side + "ForeArm")
		if arm < 0 or fore < 0:
			continue
		var g_arm := skel.get_bone_global_rest(arm)
		var dir := (skel.get_bone_global_rest(fore).origin - g_arm.origin).normalized()
		var axis := dir.cross(Vector3.DOWN)
		if axis.length() < 0.001:
			continue
		var turn := Basis(axis.normalized(), dir.angle_to(Vector3.DOWN) * 0.88)
		var parent := skel.get_bone_parent(arm)
		var g_parent := skel.get_bone_global_rest(parent).basis if parent >= 0 else Basis()
		var local := g_parent.inverse() * turn * g_arm.basis
		skel.set_bone_pose_rotation(arm, local.get_rotation_quaternion())


func _find_child_of_type(node: Node, type: String) -> Node:
	if node.is_class(type):
		return node
	for c in node.get_children():
		var found := _find_child_of_type(c, type)
		if found:
			return found
	return null


func _build_mike_placeholder() -> void:
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.32
	cap.height = 1.2
	body.mesh = cap
	body.material_override = _mat(Palette.SUIT)
	body.position.y = 0.6
	mike.add_child(body)
	var visor := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.2
	sph.height = 0.32
	visor.mesh = sph
	visor.material_override = _mat(Palette.SUIT_STRIPE)
	visor.position = Vector3(0.0, 0.92, 0.2)
	mike.add_child(visor)


func _sync_items() -> void:
	for k in _nodes.keys():
		if not State.items.has(k) or _nodes[k].get_meta("type") != State.items[k].type:
			_nodes[k].queue_free()
			_nodes.erase(k)
	for k in State.items:
		var it: Dictionary = State.items[k]
		if not _nodes.has(k):
			var n := _make_item(it.type)
			add_child(n)
			_nodes[k] = n
		var node: Node3D = _nodes[k]
		node.position = cell_center(State.parse_key(k))
		var s := 1.0 + 0.2 * (int(it.level) - 1)
		node.scale = Vector3(s, s, s)
		var label: Label3D = node.get_node("Label")
		label.text = tr(State.ITEMS[it.type].name)
		_update_plant(node, it)


func _make_item(type: String) -> Node3D:
	var root := Node3D.new()
	root.set_meta("type", type)
	var h: float = State.ITEMS[type].height
	var box := BoxMesh.new()
	box.size = Vector3(CELL * 0.72, h, CELL * 0.72)
	var m := MeshInstance3D.new()
	m.mesh = box
	m.material_override = _mat(ITEM_COLORS[type])
	m.position.y = h / 2.0
	root.add_child(m)

	var label := Label3D.new()
	label.name = "Label"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 44
	label.outline_size = 14
	label.pixel_size = 0.012
	label.modulate = Palette.TEXT
	label.outline_modulate = Palette.BG
	label.position.y = h + 0.55
	root.add_child(label)

	if type == "greenhouse":
		var plant := MeshInstance3D.new()
		plant.name = "Plant"
		var sph := SphereMesh.new()
		sph.radius = 0.35
		sph.height = 0.5
		plant.mesh = sph
		plant.material_override = _mat(Palette.PLANT)
		plant.position.y = h + 0.1
		root.add_child(plant)
	return root


func _update_plant(node: Node3D, it: Dictionary) -> void:
	if not node.has_node("Plant"):
		return
	var plant: MeshInstance3D = node.get_node("Plant")
	plant.visible = it.plant != ""
	if not plant.visible:
		return
	var total: float = State.PLANTS[it.plant].sols
	var p := clampf(it.growth / total, 0.0, 1.0)
	plant.scale = Vector3.ONE * lerpf(0.25, 1.0, p)
	var ready := p >= 1.0
	(plant.material_override as StandardMaterial3D).albedo_color = Palette.GOLD if ready else Palette.PLANT


func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m
