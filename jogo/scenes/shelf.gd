extends Control
## Display shelf (idea, model and first version: Design team, design/05-telas/estante/).
## Built like any other item (only 1, with Mike's House at level 2). Tapping it opens the usual
## item panel with one extra button: "View shelf". It moves the camera to the front of the shelf
## (with the game sky behind it) and opens the slots at the bottom. Tapping a slot lets the kid pick
## what to show, only from what is already in the album (harvested plants and rocks found exploring).
## Mike's House at level 2: 3 slots. At the last level (State.MAX_LEVEL): all 6 slots.
## What is on display lives in State.items[key].display (6 strings) and is saved with the base.

const SLOTS := 6
const SLOT_SIZE := 0.17          # size of each item on display, in estante.glb units
const SCREEN_HEIGHT := 0.42      # the shelf fills this fraction of the screen height when zoomed in
const SCREEN_CENTER := 0.30      # and its middle sits at this height (0 = top), above the panel
const TILT := -12.0              # zoomed in, the camera looks almost straight at it, like the preview
const BACKDROP_DISTANCE := 1.2   # the game sky becomes a "photo backdrop" right behind the shelf (meters)
const GAME_TILT := -35.264       # the normal game camera tilt (base.gd)
const MAX_WIDTH := 680.0         # on a computer the panel stays in the middle, like the rest of the UI
const PANEL_TOP := 0.56          # the panel starts at this screen height (the shelf stays above it)

## Rocks with a 3D model, and the album card that unlocks each one (found while exploring).
## A rock whose card is not in the game is left out (the shelf only shows what the album can have).
## "id" and "model" are asset names from the Design team (design/03-itens-do-jogo/descobertas/).
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

var hud: Node                   # the HUD (the base reaches it after _ready)
var base: Node3D:
	get:
		return hud.base if hud else null
var red_x: Callable             # the HUD's red X button, the same everywhere in the game
var _key := ""
var _slot := -1
var _cam := {}
var _backdrop: MeshInstance3D
var _panel: PanelContainer
var _slots_grid: GridContainer
var _list: GridContainer
var _scroll: ScrollContainer
var _title: Label
var _hint: Label
var _photos := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP   # while open, the shelf takes the taps (the base stays still)
	visible = false
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", Palette.paper())
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	_panel.add_child(col)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	col.add_child(top)
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_font_override("font", Palette.font(800))
	_title.add_theme_color_override("font_color", Palette.BG)
	_title.add_theme_font_size_override("font_size", 38)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top.add_child(_title)
	if red_x.is_valid():
		top.add_child(red_x.call(_back))
	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.add_theme_color_override("font_color", Palette.INK)
	_hint.add_theme_font_size_override("font_size", 22)
	col.add_child(_hint)
	_slots_grid = GridContainer.new()
	_slots_grid.columns = 2            # same as the shelf: 2 columns x 3 rows
	_slots_grid.add_theme_constant_override("h_separation", 16)
	_slots_grid.add_theme_constant_override("v_separation", 16)
	_slots_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_slots_grid)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(_scroll)
	_list = GridContainer.new()
	_list.columns = 3
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("h_separation", 16)
	_list.add_theme_constant_override("v_separation", 16)
	_scroll.add_child(_list)


## Tapping outside the panel goes back one step (from the list to the slots; from the slots, it closes).
func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_back()


## How many slots Mike's House unlocks now: 0 (before level 2), 3 or 6 (last level).
static func open_slots() -> int:
	var level := State.house_level()
	if level >= State.MAX_LEVEL:
		return 6
	if level >= 2:
		return 3
	return 0


## Opens the shelf at this key (its anchor cell in State.items), with the camera in front of it.
func open(key: String) -> void:
	_key = key
	_slot = -1
	var node: Node3D = base._nodes.get(key)
	_cam = {"pos": base._pos_goal, "size": base._size_goal, "yaw": base._yaw_goal, "manual": base._manual_cam}
	_tilt(TILT)
	_add_backdrop()
	base._take_camera()
	if node:
		var box: AABB = node.global_transform * base._merged_aabb(node)
		var model: Node3D = node.get_node_or_null("Model")
		var front: Vector3 = (model if model else node).global_transform.basis.z
		var yaw := atan2(front.x, front.z)
		var screen := get_viewport().get_visible_rect().size
		var aspect := screen.y / maxf(screen.x, 1.0)
		var visible_height := box.size.y / SCREEN_HEIGHT
		var up := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, deg_to_rad(TILT)) * Vector3.UP
		base._yaw_goal = yaw
		base._size_goal = visible_height / aspect        # the camera measures by width (KEEP_WIDTH)
		base._pos_goal = box.get_center() - up * (0.5 - SCREEN_CENTER) * visible_height
	visible = true
	_show_slots()
	_layout()
	_panel.scale = Vector2(0.9, 0.9)
	_panel.pivot_offset = _panel.size / 2.0
	create_tween().tween_property(_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	visible = false
	if _cam.is_empty():
		return
	Sfx.play("toque-botao")
	_tilt(GAME_TILT)
	if _backdrop:
		_backdrop.queue_free()
		_backdrop = null
	base._pos_goal = _cam.pos
	base._size_goal = _cam.size
	base._yaw_goal = _cam.yaw
	base._manual_cam = _cam.manual
	_cam = {}


## The panel sits at the bottom, in the middle of the screen, at most MAX_WIDTH wide.
func _layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	var w := minf(screen.x - 64.0, MAX_WIDTH)
	_panel.position = Vector2((screen.x - w) / 2.0, screen.y * PANEL_TOP)
	_panel.size = Vector2(w, screen.y * (1.0 - PANEL_TOP) - 32.0)
	_list.columns = 3 if w >= 600.0 else 2


## Puts the chosen models on the shelf's 3D slots. Only rebuilds when what is on display changes.
static func dress(base_node: Node3D, node: Node3D, it: Dictionary) -> void:
	var display: Array = it.get("display", [])
	var open_count := open_slots()
	var sig := "%s|%d" % [str(display), open_count]
	if str(node.get_meta("display_sig", "")) == sig:
		return
	node.set_meta("display_sig", sig)
	for i in SLOTS:
		# "vaga-1" to "vaga-6" are the empty nodes inside estante.glb (Design's model), one per pedestal.
		var slot := node.find_child("vaga-%d" % (i + 1), true, false)
		if slot == null:
			continue
		var old := slot.get_node_or_null("Display")
		if old:
			old.free()
		var item: String = display[i] if i < display.size() and i < open_count else ""
		var m := _model_3d(base_node, item, SLOT_SIZE)
		if m == null:
			continue
		var holder := Node3D.new()
		holder.name = "Display"
		holder.add_child(m)
		slot.add_child(holder)


## The 3D model of a shelf item, standing up and fitting in a cube of "fit_size" (or null).
static func _model_3d(base_node: Node3D, item: String, fit_size: float) -> Node3D:
	if item == "plant:potato":
		var holder := Node3D.new()
		holder.add_child(base_node.potato_model())   # the potato is built in code (no .glb)
		base_node._fit(holder, fit_size, fit_size)
		return holder
	var model_name := _model_name(item)
	if model_name == "":
		return null
	return base_node._load_model(State.model_file(model_name), fit_size, fit_size)


## A 3D picture of each item, for the slots and the list (made only once).
func _photo(item: String) -> Texture2D:
	if _photos.has(item):
		return _photos[item]
	var m := _model_3d(base, item, 1.0)
	if m == null:
		return null
	var center := Node3D.new()
	center.add_child(m)
	m.position.y -= base._merged_aabb(m).size.y * m.scale.y / 2.0
	_photos[item] = Icons3D.render(self, center, 160, 1.25, false, Vector3(1.0, 0.85, 1.7))
	return _photos[item]


## The same sky as the game (base.gd's material), just right behind the shelf: it hides the
## little planet's ground behind it when the camera looks straight ahead. Removed when the shelf closes.
func _add_backdrop() -> void:
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
	if visible:
		_layout()


## Tilts the camera up or down slowly (it sits 40 m from its rig, like in base.gd).
func _tilt(degrees: float) -> void:
	var cam: Camera3D = base.camera
	create_tween().tween_method(func(a: float) -> void:
		cam.rotation_degrees.x = a
		cam.position = cam.transform.basis.z * 40.0, cam.rotation_degrees.x, degrees, 0.45).set_trans(Tween.TRANS_SINE)


static func _rock(id: String) -> Dictionary:
	for r in ROCKS:
		if r.id == id:
			return r
	return {}


static func _model_name(item: String) -> String:
	if item.begins_with("plant:"):
		return State.PLANTS.get(item.substr(6), {}).get("model", "")
	if item.begins_with("rock:"):
		return _rock(item.substr(5)).get("model", "")
	return ""


static func _item_name(item: String) -> String:
	if item.begins_with("plant:"):
		return TranslationServer.translate(State.PLANTS[item.substr(6)].name)
	if item.begins_with("rock:"):
		return TranslationServer.translate("SHELF_" + item.substr(5).to_upper().replace("-", "_"))
	return TranslationServer.translate("SHELF_EMPTY")


## The album card that unlocks the item (plant: its own card; rock: the card found while exploring).
static func _card(item: String) -> int:
	if item.begins_with("plant:"):
		return int(State.PLANTS.get(item.substr(6), {}).get("card", 0))
	return int(_rock(item.substr(5)).get("card", 0))


## Is it in the album yet? Only what the kid has already won can go on the shelf.
static func _owned(item: String) -> bool:
	return State.cards.has(str(_card(item)))


## Everything that can go on the shelf: plants and rocks with a 3D model and a card in the album.
static func _all_items() -> Array:
	var out := []
	for p in State.PLANTS:
		out.append("plant:" + p)
	for r in ROCKS:
		out.append("rock:" + r.id)
	return out.filter(func(item: String) -> bool: return not State.card_info(_card(item)).is_empty())


func _display() -> Array:
	var it: Dictionary = State.items[_key]
	var display: Array = it.get("display", [])
	while display.size() < SLOTS:
		display.append("")
	it["display"] = display
	return display


func _show_slots() -> void:
	_slot = -1
	_title.text = tr("SHELF_TITLE")
	_slots_grid.visible = true
	_scroll.visible = false
	var open_count := open_slots()
	_hint.text = tr("SHELF_MORE") if open_count < SLOTS else ""
	_hint.visible = _hint.text != ""
	for c in _slots_grid.get_children():
		c.queue_free()
	var display := _display()
	for i in SLOTS:
		var b: Button
		if i >= open_count:
			b = _slot_button(tr("SHELF_SLOT_LOCKED"), Palette.OFF)
			b.disabled = true
		elif display[i] == "":
			b = _slot_button("+  " + tr("SHELF_ADD"), Palette.BUTTON)
		else:
			b = _slot_button(_item_name(display[i]), Palette.BUTTON)
			b.icon = _photo(display[i])
		b.custom_minimum_size = Vector2(0, 88)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(_pick.bind(i))
		_slots_grid.add_child(b)


func _pick(i: int) -> void:
	Sfx.play("toque-botao")
	_slot = i
	_title.text = tr("SHELF_PICK").format({"n": i + 1})
	_hint.text = tr("SHELF_HINT")
	_hint.visible = true
	_slots_grid.visible = false
	_scroll.visible = true
	_scroll.scroll_vertical = 0
	for c in _list.get_children():
		c.queue_free()
	var display := _display()
	if display[i] != "":
		var empty := _tile(tr("SHELF_EMPTY"), null, Palette.BUTTON)
		empty.pressed.connect(_place.bind(""))
		_list.add_child(empty)
	for item in _all_items():
		var b: Button
		if not _owned(item):
			b = _tile("???", null, Palette.OFF)        # not found yet: a mystery, like in the album
			b.disabled = true
		else:
			b = _tile(_item_name(item), _photo(item), Palette.GOLD if item == display[i] else Palette.BUTTON)
			b.pressed.connect(_place.bind(item))
		_list.add_child(b)


## Puts the item in the slot. If it was already in another slot, it moves (each item shows up only once).
func _place(item: String) -> void:
	var display := _display()
	if item != "":
		var before := display.find(item)
		if before >= 0:
			display[before] = ""
	display[_slot] = item
	State.save_game()
	var node: Node3D = base._nodes.get(_key)
	if node:
		dress(base, node, State.items[_key])
	Sfx.play("construir")
	_show_slots()


## X (or a tap outside): from the list, back to the slots; from the slots, close the shelf.
func _back() -> void:
	if _slot >= 0:
		Sfx.play("toque-botao")
		_show_slots()
	else:
		close()


## Slot: a wide key with the picture on the left.
func _slot_button(text: String, color: Color) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", Palette.font(700))
	b.add_theme_font_size_override("font_size", 20)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # a long name wraps to 2 lines (no cut-off)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 64)
	b.add_theme_constant_override("h_separation", 12)
	_paint(b, color)
	return b


## List item: picture on top, name below.
func _tile(text: String, picture: Texture2D, color: Color) -> Button:
	var b := Button.new()
	b.text = text
	b.icon = picture
	b.custom_minimum_size = Vector2(0, 152 if picture else 96)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", Palette.font(700))
	b.add_theme_font_size_override("font_size", 19)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.expand_icon = true
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_constant_override("icon_max_width", 80)
	_paint(b, color)
	return b


func _paint(b: Button, color: Color) -> void:
	for s in ["normal", "hover", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, Palette.key(color))
	b.add_theme_stylebox_override("pressed", Palette.key(color, true))
	var ink := Palette.TEXT if color == Palette.OFF else (Palette.INK if color == Palette.GOLD else Palette.INK_DEEP)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		b.add_theme_color_override(c, ink)
