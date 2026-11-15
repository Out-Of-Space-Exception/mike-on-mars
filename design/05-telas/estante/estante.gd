extends Control
## Display shelf (idea and model: Design pair, design/03-itens-do-jogo/estante/).
## Built like any item. Tapping it opens the normal item panel, with one extra button:
## "See shelf". It moves the camera in front of the shelf (with the game sky behind) and opens
## the slots below. Tapping a slot: pick a plant or rock the child has already earned.
## Mike's house at level 2: 3 slots. House at the last level (State.MAX_LEVEL): all 6 slots.
## What is on display lives in State.items[key].expo (6 strings) and is saved along with the base.

const SLOTS := 6
const SLOT_SIZE := 0.17          # size of each slot, in estante.glb units
const SCREEN_HEIGHT_FRACTION := 0.42    # the shelf takes up this fraction of the screen height when zoomed
const SCREEN_CENTER := 0.30    # and its middle sits at this height (0 = top), above the panel
const TILT := -12.0      # when zoomed the camera looks almost straight on, as in the preview
const BACKDROP_DISTANCE := 1.2        # the game sky becomes a "photo backdrop" right behind the shelf (in meters)
const GAME_TILT := -35.264 # the game's own (base.gd)

## Everything that can go on the shelf. "card": the card that unlocks it (found by exploring, in the sample tube).
## If the card does not exist in the game, the rock starts unlocked.
const ROCKS := [
	{"id": "hematita", "model": "hematita", "card": 7},
	{"id": "enxofre", "model": "enxofre", "card": 9},
	{"id": "leopardo", "model": "leopardo", "card": 10},
	{"id": "veios-brancos", "model": "veios-brancos", "card": 26},
	{"id": "rocknest-3", "model": "rocknest-3", "card": 41},
	{"id": "oxido-de-manganes", "model": "oxido-de-manganes", "card": 32},
	{"id": "john-klein-a", "model": "john-klein-a", "card": 34},
	{"id": "john-klein-b", "model": "john-klein-b", "card": 34},
	{"id": "john-klein-c", "model": "john-klein-c", "card": 34},
	{"id": "meteorito-lebanon", "model": "meteorito-lebanon", "card": 35},
]

var base: Node3D                # the base scene (if nobody passes one, it takes the main scene's)
var _key := ""
var _slot := -1
var _cam := {}
var _backdrop: MeshInstance3D
var _grid: GridContainer
var _list: GridContainer
var _scroll: ScrollContainer
var _title: Label
var _notice: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Palette.paper(Palette.GOLD))
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.58
	panel.anchor_bottom = 1.0
	panel.offset_left = 16
	panel.offset_right = -16
	panel.offset_bottom = -16
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	var top_row := HBoxContainer.new()
	col.add_child(top_row)
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_color_override("font_color", Palette.BG)
	_title.add_theme_font_size_override("font_size", 34)
	top_row.add_child(_title)
	var x := _button("X", Palette.GOLD)
	x.custom_minimum_size = Vector2(72, 64)
	x.pressed.connect(_back)
	top_row.add_child(x)
	_notice = Label.new()
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.add_theme_color_override("font_color", Palette.INK)
	_notice.add_theme_font_size_override("font_size", 22)
	col.add_child(_notice)
	_grid = GridContainer.new()
	_grid.columns = 2            # same as the shelf: 2 columns x 3 levels
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_grid)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(_scroll)
	_list = GridContainer.new()
	_list.columns = 2
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("h_separation", 10)
	_list.add_theme_constant_override("v_separation", 10)
	_scroll.add_child(_list)


## How many slots Mike's house unlocks now: 0 (before level 2), 3 or 6 (last level).
static func unlocked_slots() -> int:
	var level := State.house_level()
	if level >= State.MAX_LEVEL:
		return 6
	if level >= 2:
		return 3
	return 0


## Opens the shelf for the key (the anchor house in State.items): camera facing it, as in the preview.
func open(key: String) -> void:
	if base == null:
		base = get_tree().current_scene.get("base")
	_key = key
	_slot = -1
	var node: Node3D = base._nodes.get(key)
	_cam = {"pos": base._pos_goal, "size": base._size_goal, "yaw": base._yaw_goal, "manual": base._manual_cam}
	_tilt(TILT)
	_put_backdrop()
	base._take_camera()
	if node:
		var box: AABB = node.global_transform * base._merged_aabb(node)
		var model: Node3D = node.get_node_or_null("Model")
		var front: Vector3 = (model if model else node).global_transform.basis.z
		var yaw := atan2(front.x, front.z)
		var screen := get_viewport().get_visible_rect().size
		var ratio := screen.y / maxf(screen.x, 1.0)
		var visible_height := box.size.y / SCREEN_HEIGHT_FRACTION
		var up := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, deg_to_rad(TILT)) * Vector3.UP
		base._yaw_goal = yaw
		base._size_goal = visible_height / ratio        # the camera measures by width (KEEP_WIDTH)
		base._pos_goal = box.get_center() - up * (0.5 - SCREEN_CENTER) * visible_height
	visible = true
	_show_slots()


func close() -> void:
	visible = false
	if _cam.is_empty():
		return
	_tilt(GAME_TILT)
	if _backdrop:
		_backdrop.queue_free()
		_backdrop = null
	base._pos_goal = _cam.pos
	base._size_goal = _cam.size
	base._yaw_goal = _cam.yaw
	base._manual_cam = _cam.manual
	_cam = {}


## Puts the displayed models in the slots of the 3D model (call when creating the shelf and when it changes).
static func dress(base_node: Node3D, node: Node3D, it: Dictionary) -> void:
	var shown: Array = it.get("expo", [])
	var free_slots := unlocked_slots()
	for i in SLOTS:
		var slot := node.find_child("vaga-%d" % (i + 1), true, false)
		if slot == null:
			continue
		var old := slot.get_node_or_null("Expo")
		if old:
			old.free()
		var item: String = shown[i] if i < shown.size() and i < free_slots else ""
		var model := _model_of(item)
		if model == "":
			continue
		var m: Node3D = base_node._load_model(State.model_file(model), 1.0, 1.0)
		if m == null:
			continue
		var holder := Node3D.new()
		holder.add_child(m)
		base_node._fit(holder, SLOT_SIZE, SLOT_SIZE)
		var display_node := Node3D.new()
		display_node.name = "Expo"
		display_node.add_child(holder)
		slot.add_child(display_node)


## The same sky as the game (the base.gd material), just right behind the shelf: it covers the ground of the
## little planet that would be behind it when the camera looks straight on. Goes away when the shelf closes.
func _put_backdrop() -> void:
	if base.get("_sky") == null or _backdrop:
		return
	_backdrop = MeshInstance3D.new()
	_backdrop.mesh = QuadMesh.new()
	_backdrop.material_override = base._sky_mat
	_backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	base.camera.add_child(_backdrop)
	_backdrop.position = Vector3(0.0, 0.0, -(40.0 + BACKDROP_DISTANCE))


func _process(_delta: float) -> void:
	if _backdrop:
		_backdrop.scale = base._sky.scale   # follows the zoom, like the game sky


## Slowly tilts the camera up/down (it sits 40 m from the tripod, as in base.gd).
func _tilt(degrees: float) -> void:
	var cam: Camera3D = base.camera
	create_tween().tween_method(func(a: float) -> void:
		cam.rotation_degrees.x = a
		cam.position = cam.transform.basis.z * 40.0, cam.rotation_degrees.x, degrees, 0.45).set_trans(Tween.TRANS_SINE)


static func _rock(id: String) -> Dictionary:
	for p in ROCKS:
		if p.id == id:
			return p
	return {}


static func _model_of(item: String) -> String:
	if item.begins_with("plant:"):
		return State.PLANTS.get(item.substr(6), {}).get("model", "")
	if item.begins_with("rock:"):
		return _rock(item.substr(5)).get("model", "")
	return ""


static func _name_of(item: String) -> String:
	if item.begins_with("plant:"):
		return TranslationServer.translate(State.PLANTS[item.substr(6)].name)
	if item.begins_with("rock:"):
		return TranslationServer.translate("SHELF_" + item.substr(5).to_upper().replace("-", "_"))
	return TranslationServer.translate("SHELF_EMPTY")


## Has the child earned it? Plant: harvested at least 1. Rock: won the card (by exploring).
static func _has(item: String) -> bool:
	if item.begins_with("plant:"):
		return int(State.inventory.get(item.substr(6), 0)) > 0
	var card := int(_rock(item.substr(5)).get("card", 0))
	if card == 0 or State.card_info(card).is_empty():
		return true
	return State.cards.has(str(card))


## Everything that can go on the shelf (plants and rocks with a 3D model).
static func _all_items() -> Array:
	var out := []
	for p in State.PLANTS:
		out.append("plant:" + p)
	for p in ROCKS:
		out.append("rock:" + p.id)
	return out


func _shown() -> Array:
	var it: Dictionary = State.items[_key]
	var shown: Array = it.get("expo", [])
	while shown.size() < SLOTS:
		shown.append("")
	it["expo"] = shown
	return shown


func _show_slots() -> void:
	_slot = -1
	_title.text = tr("SHELF_TITLE")
	_grid.visible = true
	_scroll.visible = false
	var free_slots := unlocked_slots()
	_notice.text = tr("SHELF_MORE") if free_slots < SLOTS else ""
	_notice.visible = _notice.text != ""
	for c in _grid.get_children():
		c.queue_free()
	var shown := _shown()
	for i in SLOTS:
		var label_text := "%d · %s" % [i + 1, _name_of(shown[i]) if shown[i] != "" else "+"]
		if i >= free_slots:
			label_text = "%d · %s" % [i + 1, tr("SHELF_SLOT_LOCKED")]
		var b := _button(label_text, Palette.BG.lightened(0.85))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = i >= free_slots
		b.pressed.connect(_choose.bind(i))
		_grid.add_child(b)


func _choose(i: int) -> void:
	_slot = i
	_title.text = tr("SHELF_PICK").format({"n": i + 1})
	_notice.text = tr("SHELF_HINT")
	_notice.visible = true
	_grid.visible = false
	_scroll.visible = true
	for c in _list.get_children():
		c.queue_free()
	var shown := _shown()
	var empty := _button(tr("SHELF_EMPTY"), Palette.BG.lightened(0.85))
	empty.pressed.connect(_place.bind(""))
	_list.add_child(empty)
	for item in _all_items():
		var b: Button
		if not _has(item):
			b = _button("???", Palette.OFF)        # not found yet: mystery, as in an album
			b.disabled = true
		elif item in shown and shown[i] != item:
			b = _button(_name_of(item), Palette.BG.lightened(0.7))
			b.disabled = true               # each thing appears only once
		else:
			b = _button(_name_of(item), Palette.BG.lightened(0.85))
			b.pressed.connect(_place.bind(item))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.add_child(b)


func _place(item: String) -> void:
	var shown := _shown()
	shown[_slot] = item
	State.save_game()
	var node: Node3D = base._nodes.get(_key)
	if node:
		dress(base, node, State.items[_key])
	Sfx.play("construir")
	_show_slots()


## X: from the list goes back to the slots; from the slots closes the shelf.
func _back() -> void:
	if _slot >= 0:
		_show_slots()
	else:
		close()


func _button(label_text: String, col: Color) -> Button:
	var b := Button.new()
	b.text = label_text
	b.custom_minimum_size = Vector2(0, 64)
	b.add_theme_font_size_override("font_size", 24)
	b.clip_text = true
	for s in ["normal", "hover", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, Palette.key(col))
	b.add_theme_stylebox_override("pressed", Palette.key(col, true))
	var ink := Palette.INK if col.get_luminance() > 0.4 else Palette.TEXT
	b.add_theme_color_override("font_color", ink)
	b.add_theme_color_override("font_disabled_color", ink.lerp(col, 0.45))
	return b
