extends Node3D
## A base em 3D: chão, grade, itens (modelos do design/03 e 04), plantas, Mike, Ingenuity e câmera.
## Só desenha o que está no State. Quem decide o que um toque faz é o HUD (recebe cell_tapped).

signal cell_tapped(cell: Vector2i)

const CELL := 2.0
const OUTSIDE := Vector2i(-1, -1)
const ITEMS_DIR := "res://models/items/"
const MIKE_SCENE := "res://models/mike/mike.glb"
const MIKE_MODEL_HEIGHT := 4.0   # altura do mike.glb em unidades do arquivo
const MIKE_HEIGHT := 1.5         # altura do Mike no jogo (a câmera chega perto no começo)
const DESIGN_MIKE := 2.2         # o tamanhos.csv do Design mede tudo com o Mike = 2,2
const INGENUITY := "res://models/nasa/ingenuity.glb"
const INGENUITY_WIDTH := 1.3
const CAM_MIN := 10.0            # câmera mais perto (base pequena)
const CAM_MAX := 19.5            # câmera mais longe (a grade inteira)
const EXPEDITION_CELL := Vector2i(-4, -4)   # fora da grade, no fundo da tela
# Cores do Ingenuity (design/04): corpo branco, faixas azul e vermelha, detalhes dourados
const INGENUITY_COLORS := {
	"aluminum": Palette.SUIT, "grey_brushed": Palette.SUIT, "chopper_sp": Palette.SUIT, "foil_silver": Palette.SUIT,
	"binoculars": Palette.SUIT, "gunmetal": Palette.SUIT_STRIPE, "gunmetal_dark": Color("2e2a33"),
	"carbon fiber": Palette.ALERT, "blades": Palette.TEXT, "gold": Palette.GOLD,
}

var camera: Camera3D
var mike: Node3D
var _mike_anim: AnimationPlayer
var _mike_tween: Tween
var _walking_out := false
var _env: Environment
var _sun: DirectionalLight3D
var _dome: MeshInstance3D
var _tiles := {}    # "x,y" -> MeshInstance3D
var _nodes := {}    # "x,y" -> Node3D do item
var _tile_mat: StandardMaterial3D
var _tile_hi_mat: StandardMaterial3D
var _scenes := {}   # cache de PackedScene
var _pet: Node3D
var _rotors: Array[Node3D] = []
var _rotor_axes: Array[Vector3] = []
var _time := 0.0
var _type_scale := {}       # escala de cada construção com níveis (a mesma em todos os níveis)
var whole_grid := false     # o HUD liga ao construir ou mover: a câmera mostra a grade inteira
var _cam_goal := Vector3(INF, INF, INF)
var _cam_tween: Tween


func _ready() -> void:
	_build_world()
	_build_grid()
	_build_mike()
	_build_dome()
	State.changed.connect(_sync_items)
	State.changed.connect(_sync_mood)
	State.storm_started.connect(func(_e: Dictionary) -> void: _sync_mood())
	State.event_started.connect(func(_t: String) -> void: _sync_mood())
	State.explore_started.connect(_walk_out)
	State.explore_returned.connect(_walk_back)
	_sync_items()
	_sync_mood()


func _process(delta: float) -> void:
	_time += delta
	if _pet == null:
		return
	# O Ingenuity voa atrás do Mike, balançando, com as hélices girando em sentidos opostos.
	var target := mike.position + Vector3(1.1, 2.6 + sin(_time * 2.0) * 0.15, 0.7)
	_pet.position = _pet.position.lerp(target, 1.0 - exp(-delta * 1.8))
	for i in _rotors.size():
		_rotors[i].rotate_object_local(_rotor_axes[i], delta * (28.0 if i == 0 else -28.0))


func cell_center(c: Vector2i) -> Vector3:
	var x0 := -State.GRID_W * CELL / 2.0
	var z0 := -State.GRID_H * CELL / 2.0
	return Vector3(x0 + (c.x + 0.5) * CELL, 0.0, z0 + (c.y + 0.5) * CELL)


func highlight(cells: Array) -> void:
	for k in _tiles:
		_tiles[k].material_override = _tile_mat
	for c in cells:
		_tiles[State.key(c)].material_override = _tile_hi_mat
	whole_grid = not cells.is_empty()
	_frame_camera()


## A câmera enquadra a base: perto quando ela é pequena, a grade inteira ao construir ou mover.
func _frame_camera() -> void:
	var lo := Vector2i(0, 0)
	var hi := Vector2i(State.GRID_W - 1, State.GRID_H - 1)
	if not whole_grid:
		lo = Vector2i(State.GRID_W, State.GRID_H)
		hi = Vector2i(-1, -1)
		for k in State.items:
			for c in State.cells_of(State.parse_key(k), State.items[k].type, int(State.items[k].level)):
				lo = lo.min(c)
				hi = hi.max(c)
		lo = (lo - Vector2i(1, 1)).clamp(Vector2i.ZERO, Vector2i(State.GRID_W - 1, State.GRID_H - 1))
		hi = (hi + Vector2i(1, 1)).clamp(Vector2i.ZERO, Vector2i(State.GRID_W - 1, State.GRID_H - 1))
	var a := cell_center(lo) - Vector3(CELL / 2.0, 0.0, CELL / 2.0)
	var b := cell_center(hi) + Vector3(CELL / 2.0, 0.0, CELL / 2.0)
	var center := (a + b) / 2.0
	var size := clampf(((b.x - a.x) + (b.z - a.z)) / sqrt(2.0) * 1.08, CAM_MIN, CAM_MAX)
	var goal := Vector3(center.x, center.z, size)
	if goal.is_equal_approx(_cam_goal):
		return
	_cam_goal = goal
	# A barra de cima é maior que a de baixo: sobe um pouco a câmera para a base ficar no meio do que sobra.
	var pos := center + camera.transform.basis.z * 40.0 + camera.transform.basis.y * size * 0.08
	if _cam_tween:
		_cam_tween.kill()
	_cam_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_cam_tween.tween_property(camera, "position", pos, 0.6)
	_cam_tween.tween_property(camera, "size", size, 0.6)


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


# ───────────── Clima: tempestade, frio e poeira mudam a luz ─────────────
func _sync_mood() -> void:
	var storm: bool = State.storm_active() or State.pending_event == "storm"
	var cold: bool = State.cold_left > 0 or State.pending_event == "cold"
	var dust: bool = State.dust_left > 0
	var light := Color.WHITE
	var ambient := Color(1.0, 0.88, 0.78)
	if storm:
		light = Palette.STORM_SKY.lightened(0.4)
		ambient = Palette.STORM_SKY
	elif cold:
		light = Color(0.75, 0.85, 1.0)
		ambient = Color(0.55, 0.65, 0.9)
	elif dust:
		light = Color(0.9, 0.75, 0.6)
		ambient = Color(0.75, 0.55, 0.4)
	_sun.light_color = light
	_env.ambient_light_color = ambient
	_dome.visible = State.storm_active() and State.storm_shielded
	mike.visible = _walking_out or not (State.mike_inside() or State.exploring())


# ───────────── Expedição ─────────────
## O Mike sai andando para longe (lá para o fundo, rumo ao Monte Sharp) e some.
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
		_sync_mood())


## Volta da expedição: aparece lá no fundo e anda até a frente da casa, com o tubo.
func _walk_back(_card_id: int) -> void:
	mike.position = cell_center(EXPEDITION_CELL)
	_sync_mood()
	for k in State.items:
		if State.items[k].type == "habitat":
			walk_to(State.parse_key(k))
			return


# ───────────── Montagem do mundo ─────────────
func _build_world() -> void:
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	_env.background_color = Palette.SKY
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color(1.0, 0.88, 0.78)
	_env.ambient_light_energy = 0.6
	var world := WorldEnvironment.new()
	world.environment = _env
	add_child(world)

	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-55.0, -35.0, 0.0)
	_sun.light_energy = 1.1
	_sun.shadow_enabled = true
	add_child(_sun)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 19.0
	camera.rotation_degrees = Vector3(-35.264, 45.0, 0.0)
	add_child(camera)
	camera.position = camera.transform.basis.z * 40.0
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


# ───────────── Mike ─────────────
## O Mike do design/01 (mike.glb, com as animações idle, run e jump dentro).
func _build_mike() -> void:
	mike = Node3D.new()
	add_child(mike)
	mike.position = cell_center(Vector2i(2, 4)) + Vector3(0.0, 0.0, CELL * 0.62)
	if not ResourceLoader.exists(MIKE_SCENE):
		var body := MeshInstance3D.new()
		var cap := CapsuleMesh.new()
		cap.radius = 0.32
		cap.height = 1.2
		body.mesh = cap
		body.material_override = _mat(Palette.SUIT)
		body.position.y = 0.6
		mike.add_child(body)
		return
	var model: Node3D = load(MIKE_SCENE).instantiate()
	model.scale = Vector3.ONE * (MIKE_HEIGHT / MIKE_MODEL_HEIGHT)
	mike.add_child(model)
	var player := _find_child_of_type(model, "AnimationPlayer") as AnimationPlayer
	if player and player.has_animation("idle"):
		_mike_anim = player
		for loop_anim in ["idle", "run"]:
			if player.has_animation(loop_anim):
				player.get_animation(loop_anim).loop_mode = Animation.LOOP_LINEAR
		player.play("idle")


func _play_mike(anim_name: String) -> void:
	if _mike_anim and _mike_anim.has_animation(anim_name):
		_mike_anim.play(anim_name, 0.15)


# ───────────── Itens da base ─────────────
func _sync_items() -> void:
	for k in _nodes.keys():
		var gone: bool = not State.items.has(k)
		if not gone and (_nodes[k].get_meta("type") != State.items[k].type or _nodes[k].get_meta("level") != int(State.items[k].level)):
			gone = true
		if gone:
			_nodes[k].queue_free()
			_nodes.erase(k)
	for k in State.items:
		var it: Dictionary = State.items[k]
		var level := int(it.level)
		if not _nodes.has(k):
			var n := _make_item(it.type, level)
			add_child(n)
			_nodes[k] = n
		var node: Node3D = _nodes[k]
		var w := State.width_of(it.type, level)
		node.position = cell_center(State.parse_key(k)) + Vector3((w - 1) * CELL / 2.0, 0.0, 0.0)
		# Quem tem modelo por nível já cresce no modelo; os outros crescem um pouco a cada nível.
		var s := 1.0 if State.FOOTPRINT.has(it.type) else 1.0 + 0.15 * (level - 1)
		node.scale = Vector3(s, s, s)
		var label: Label3D = node.get_node("Label")
		label.text = tr(State.item_name(it))
		_update_plant(node, it)
	_sync_pet()
	_frame_camera()


func _make_item(type: String, level: int) -> Node3D:
	var root := Node3D.new()
	root.set_meta("type", type)
	root.set_meta("level", level)
	var h: float = State.ITEMS[type].height
	var model_name: String = State.ITEMS[type].get("model", "")
	var model := _load_model(State.model_file(model_name, level), CELL * 0.9, CELL * 1.3)
	if model:
		if State.FOOTPRINT.has(type):
			# Mesma escala em todos os níveis: o nível 1 cabe numa casa; os outros crescem para o lado.
			if not _type_scale.has(type):
				var first := _load_model(State.model_file(model_name, 1), 1.0, 1.0)
				first.scale = Vector3.ONE
				var size1 := _merged_aabb(first).size
				_type_scale[type] = CELL * 0.95 / maxf(size1.x, 0.001)
				first.free()
			_scale_model(model, _type_scale[type])
		elif State.model_height(type) > 0.0:
			_fit(model, CELL * 0.95, State.model_height(type) * MIKE_HEIGHT / DESIGN_MIKE)
		root.add_child(model)
		h = _merged_aabb(model).end.y * model.scale.y + model.position.y
	else:
		root.add_child(_placeholder(type, h))
	if type == "rtg" and level >= State.MAX_LEVEL:
		root.add_child(_kilopower_radiator(h))
		h += 0.5
	var label := Label3D.new()
	label.name = "Label"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 44
	label.outline_size = 14
	label.pixel_size = 0.012
	label.modulate = Palette.TEXT
	label.outline_modulate = Palette.BG
	label.position.y = maxf(h, 0.5) + 0.55
	root.add_child(label)
	if type == "greenhouse":
		var plant := Node3D.new()
		plant.name = "Plant"
		plant.position.y = 0.3
		root.add_child(plant)
		var ready_mark := Label3D.new()
		ready_mark.name = "Ready"
		ready_mark.text = "!"
		ready_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		ready_mark.no_depth_test = true
		ready_mark.font_size = 96
		ready_mark.outline_size = 18
		ready_mark.pixel_size = 0.012
		ready_mark.modulate = Palette.GOLD
		ready_mark.outline_modulate = Palette.BG
		ready_mark.position.y = maxf(h, 0.5) + 1.3
		root.add_child(ready_mark)
	return root


## Formas provisórias para o que ainda não tem modelo (casa, estufa, pista do Ingenuity).
func _placeholder(type: String, h: float) -> Node3D:
	var holder := Node3D.new()
	match type:
		"habitat":
			var body := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.75
			cyl.bottom_radius = 0.75
			cyl.height = 0.9
			body.mesh = cyl
			body.material_override = _mat(Palette.SUIT)
			body.position.y = 0.45
			holder.add_child(body)
			var roof := MeshInstance3D.new()
			var dome := SphereMesh.new()
			dome.is_hemisphere = true
			dome.radius = 0.75
			dome.height = 0.6
			roof.mesh = dome
			roof.material_override = _mat(Palette.SUIT)
			roof.position.y = 0.9
			holder.add_child(roof)
			var stripe := MeshInstance3D.new()
			var ring := CylinderMesh.new()
			ring.top_radius = 0.77
			ring.bottom_radius = 0.77
			ring.height = 0.12
			stripe.mesh = ring
			stripe.material_override = _mat(Palette.SUIT_STRIPE)
			stripe.position.y = 0.6
			holder.add_child(stripe)
		"greenhouse":
			var soil := MeshInstance3D.new()
			var base := BoxMesh.new()
			base.size = Vector3(CELL * 0.75, 0.3, CELL * 0.75)
			soil.mesh = base
			soil.material_override = _mat(Color("5a3a2a"))
			soil.position.y = 0.15
			holder.add_child(soil)
			var glass := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(CELL * 0.75, 1.0, CELL * 0.75)
			glass.mesh = box
			var gm := StandardMaterial3D.new()
			gm.albedo_color = Color(0.75, 0.95, 1.0, 0.28)
			gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			gm.roughness = 0.1
			glass.material_override = gm
			glass.position.y = 0.8
			holder.add_child(glass)
		"pad":
			var disc := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.8
			cyl.bottom_radius = 0.8
			cyl.height = 0.1
			disc.mesh = cyl
			disc.material_override = _mat(Color("4a4550"))
			disc.position.y = 0.05
			holder.add_child(disc)
			var mark := MeshInstance3D.new()
			var ring := TorusMesh.new()
			ring.inner_radius = 0.45
			ring.outer_radius = 0.55
			mark.mesh = ring
			mark.material_override = _mat(Palette.GOLD)
			mark.position.y = 0.11
			holder.add_child(mark)
		_:
			var m := MeshInstance3D.new()
			var cube := BoxMesh.new()
			cube.size = Vector3(CELL * 0.7, h, CELL * 0.7)
			m.mesh = cube
			m.material_override = _mat(Palette.BUTTON)
			m.position.y = h / 2.0
			holder.add_child(m)
	return holder


func _update_plant(node: Node3D, it: Dictionary) -> void:
	if not node.has_node("Plant"):
		return
	var holder: Node3D = node.get_node("Plant")
	var ready_mark: Label3D = node.get_node("Ready")
	if holder.get_meta("plant", "") != it.plant:
		for c in holder.get_children():
			c.queue_free()
		holder.set_meta("plant", it.plant)
		if it.plant != "":
			var plant_h := State.model_height(it.plant) * MIKE_HEIGHT / DESIGN_MIKE
			var model := _load_model(State.model_file(State.PLANTS[it.plant].model), CELL * 0.5, plant_h if plant_h > 0.0 else 0.6)
			if model:
				holder.add_child(model)
	var p := 0.0
	if it.plant != "":
		p = clampf(it.growth / float(State.PLANTS[it.plant].sols), 0.0, 1.0)
	holder.scale = Vector3.ONE * lerpf(0.25, 1.0, p)
	ready_mark.visible = it.plant != "" and p >= 1.0


## Carrega um .glb de jogo/models/items/ e ajusta ao tamanho da casa da grade (fica em pé no chão).
func _load_model(file: String, max_width: float, max_height: float) -> Node3D:
	var path := ITEMS_DIR + file
	if file == "" or not ResourceLoader.exists(path):
		return null
	if not _scenes.has(path):
		_scenes[path] = load(path)
	var inst: Node3D = _scenes[path].instantiate()
	var holder := Node3D.new()
	holder.add_child(inst)
	_fit(holder, max_width, max_height)
	return holder


## Aplica uma escala fixa e deixa o modelo em pé no chão, centralizado.
func _scale_model(holder: Node3D, s: float) -> void:
	holder.scale = Vector3.ONE
	holder.position = Vector3.ZERO
	var box := _merged_aabb(holder)
	holder.scale = Vector3.ONE * s
	holder.position = Vector3(-box.get_center().x * s, -box.position.y * s, -box.get_center().z * s)


## Kilopower (RTG no nível 3): um radiador dourado em forma de guarda-chuva, como o reator de verdade.
func _kilopower_radiator(top: float) -> Node3D:
	var holder := Node3D.new()
	var mast := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.06
	cyl.bottom_radius = 0.06
	cyl.height = 0.4
	mast.mesh = cyl
	mast.material_override = _mat(Palette.SUIT)
	mast.position.y = top + 0.2
	holder.add_child(mast)
	var umbrella := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.75
	cone.bottom_radius = 0.08
	cone.height = 0.35
	umbrella.mesh = cone
	umbrella.material_override = _mat(Palette.GOLD)
	umbrella.position.y = top + 0.5
	holder.add_child(umbrella)
	return holder


func _fit(holder: Node3D, max_width: float, max_height: float) -> void:
	var box := _merged_aabb(holder)
	if box.size.length() < 0.0001:
		return
	var s := minf(max_width / maxf(box.size.x, box.size.z), max_height / maxf(box.size.y, 0.001))
	holder.scale = Vector3.ONE * s
	holder.position = Vector3(-box.get_center().x * s, -box.position.y * s, -box.get_center().z * s)


func _merged_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	var stack: Array = [[root, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var pair: Array = stack.pop_back()
		var n: Node = pair[0]
		var t: Transform3D = pair[1]
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var a: AABB = t * (n as MeshInstance3D).mesh.get_aabb()
			out = a if first else out.merge(a)
			first = false
		for c in n.get_children():
			if c is Node3D:
				stack.append([c, t * (c as Node3D).transform])
	return out


# ───────────── Ingenuity (o pet) ─────────────
## Aparece quando a criança constrói a pista do Ingenuity.
func _sync_pet() -> void:
	var want := State.count_items("pad") > 0
	if want and _pet == null and ResourceLoader.exists(INGENUITY):
		_spawn_pet()
	elif not want and _pet:
		_pet.queue_free()
		_pet = null
		_rotors.clear()
		_rotor_axes.clear()


func _spawn_pet() -> void:
	var inst: Node3D = load(INGENUITY).instantiate()
	# Recolore no estilo das máquinas da Kenney (cores chapadas do design/04).
	for mi in inst.find_children("*", "MeshInstance3D", true, false):
		var mesh := (mi as MeshInstance3D).mesh
		for i in mesh.get_surface_count():
			var mat := mesh.surface_get_material(i)
			var color: Color = INGENUITY_COLORS.get(mat.resource_name if mat else "", Palette.SUIT)
			(mi as MeshInstance3D).set_surface_override_material(i, _mat(color))
	var tilt := Node3D.new()
	tilt.add_child(inst)
	for rotor_name in ["rotors_01", "rotors_02"]:
		var r := inst.find_child(rotor_name, true, false) as Node3D
		if r:
			_rotors.append(r)
			_rotor_axes.append(_thin_axis(r))
	# Deixa o eixo das hélices apontando para cima (o modelo pode vir deitado).
	if not _rotors.is_empty():
		var up := (_rotors[0].global_transform.basis if _rotors[0].is_inside_tree() else _local_basis_to(inst, _rotors[0])) * _rotor_axes[0]
		if up.length() > 0.001 and absf(up.normalized().dot(Vector3.UP)) < 0.999:
			tilt.basis = Basis(Quaternion(up.normalized(), Vector3.UP))
		elif up.normalized().dot(Vector3.UP) < 0.0:
			tilt.basis = Basis(Vector3.RIGHT, PI)
	_pet = Node3D.new()
	_pet.add_child(tilt)
	_fit(tilt, INGENUITY_WIDTH, INGENUITY_WIDTH)
	tilt.position.y = 0.0
	add_child(_pet)
	_pet.position = mike.position + Vector3(1.1, 2.6, 0.7)


## O eixo mais fino do desenho das hélices é o eixo em que elas giram.
func _thin_axis(rotor: Node3D) -> Vector3:
	var box := _merged_aabb(rotor)
	var s := box.size
	if s.x <= s.y and s.x <= s.z:
		return Vector3.RIGHT
	if s.y <= s.x and s.y <= s.z:
		return Vector3.UP
	return Vector3.BACK


func _local_basis_to(root: Node3D, node: Node3D) -> Basis:
	var b := Basis()
	var n: Node = node
	while n and n != root:
		if n is Node3D:
			b = (n as Node3D).transform.basis * b
		n = n.get_parent()
	return b


# ───────────── Utilidades ─────────────
func _find_child_of_type(node: Node, type: String) -> Node:
	if node.is_class(type):
		return node
	for c in node.get_children():
		var found := _find_child_of_type(c, type)
		if found:
			return found
	return null


func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m
