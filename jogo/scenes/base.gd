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

var camera: Camera3D
var mike: Node3D
var _tiles := {}    # "x,y" -> MeshInstance3D
var _nodes := {}    # "x,y" -> Node3D do item
var _tile_mat: StandardMaterial3D
var _tile_hi_mat: StandardMaterial3D
var _mike_tween: Tween


func _ready() -> void:
	_build_world()
	_build_grid()
	_build_mike()
	State.changed.connect(_sync_items)
	_sync_items()


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
	_mike_tween.tween_property(mike, "position", target, clampf(dir.length() / 5.0, 0.25, 1.4))


## O Mike pula de alegria (quando colhe, por exemplo).
func jump() -> void:
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
	env.background_mode = Environment.BG_COLOR
	env.background_color = Palette.SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.88, 0.78)
	env.ambient_light_energy = 0.6
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
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


## Mike provisório (cápsula com o traje do design/01) até o modelo da Kenney entrar.
func _build_mike() -> void:
	mike = Node3D.new()
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
	add_child(mike)
	mike.position = cell_center(Vector2i(2, 4)) + Vector3(0.0, 0.0, CELL * 0.62)


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
