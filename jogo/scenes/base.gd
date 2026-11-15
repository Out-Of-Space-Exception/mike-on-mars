extends Node3D
## The 3D base: ground, grid, items (models from design/03 and 04), plants, Mike, Ingenuity and camera.
## Only draws what is in State. The HUD decides what a tap does (it receives cell_tapped).

signal cell_tapped(cell: Vector2i)
signal mike_tapped

const CELL := 2.0
const OUTSIDE := Vector2i(-1, -1)
const ITEMS_DIR := "res://models/items/"
const Shelf := preload("res://scenes/shelf.gd")
const MIKE_SCENE := "res://models/mike/mike.glb"
const MIKE_SUIT := "res://models/mike/mike-astronauta.glb"   # Mike in his suit, for the expedition
const MIKE_MODEL_HEIGHT := 4.0   # height of mike.glb in file units
const MIKE_HEIGHT := 1.5         # Mike's height in the game (the camera gets close at the start)
const DESIGN_MIKE := 2.2         # Design's tamanhos.csv measures everything with Mike = 2.2
const GROW_MARK_GAP := 0.85      # space between the top of the greenhouse and the growing-plant ring
const GROW_MARK_PX := 64.0       # ring size on screen (UI pixels), the same at any zoom (it used to grow when zooming in)
const INGENUITY := "res://models/nasa/ingenuity.glb"
const INGENUITY_WIDTH := 1.3
const CAM_MIN := 12.0            # closest camera (small base)
const CAM_START := 26.0          # on the start screen: the whole little planet, with the sky around it
const CAM_MAX := 30.0            # farthest camera (the whole 10 x 10 grid)
# Ingenuity colors (design/04): white body, blue and red stripes, golden details
const INGENUITY_COLORS := {
	"aluminum": Palette.SUIT, "grey_brushed": Palette.SUIT, "chopper_sp": Palette.SUIT, "foil_silver": Palette.SUIT,
	"binoculars": Palette.SUIT, "gunmetal": Palette.SUIT_STRIPE, "gunmetal_dark": Color("2e2a33"),
	"carbon fiber": Palette.ALERT, "blades": Palette.TEXT, "gold": Palette.GOLD,
}

var camera: Camera3D
var mike: Node3D
var _mike_anim: AnimationPlayer
var _mike_skins := {}       # "casual" / "suit" -> [model, AnimationPlayer, hammer]
var build_fx := false       # the HUD turns this on when building: the new building goes through the construction site (Mike hammering)
# Construction site from design/03 (construcao.gd, by Thais): little blocks fall and bounce, and the building sprouts from the ground.
const SITE_COLORS := [Color("D96941"), Color("F2D091"), Color("E8B23A"), Color("73242A")]
const BUILD_WORK_TIME := 1.3          # seconds of hammering after Mike arrives
const PLACE_ONLY := ["flag", "pot"]   # small things: Mike just crouches and places them
var _walking_out := false
var _env: Environment
var _sun: DirectionalLight3D
var _dome: MeshInstance3D
var _tiles := {}    # "x,y" -> MeshInstance3D
var _nodes := {}    # "x,y" -> the item's Node3D
var _tile_mat: StandardMaterial3D
var _tile_hi_mat: StandardMaterial3D
var _scenes := {}   # PackedScene cache
var _pet: Node3D
var _rotors: Array[Node3D] = []
var _rotor_axes: Array[Vector3] = []
var _time := 0.0
var _type_scale := {}       # scale of each building with levels (the same at every level)
var whole_grid := false     # the HUD turns this on when building or moving: the camera shows the whole grid
var _cam_goal := Vector3(INF, INF, INF)
# The camera never jumps: fingers change the "goal" and it glides there, damped.
const CAM_SMOOTH := 9.0
const TURN_DEADZONE := 0.09     # radians the two fingers must turn before the world turns
const ZOOM_DEADZONE := 0.05     # 5% of pinch before zooming
var _yaw_goal := deg_to_rad(45.0)
var _pos_goal := Vector3.ZERO
var _size_goal := CAM_START
var _cam_snap := true           # the first time, go straight there (no gliding)
var _multi := false             # two fingers on screen: only released when all are lifted
var _turn_sum := 0.0
var _zoom_sum := 1.0
var _turning := false
var _zooming := false
var _rig: Node3D
var orbit := true:           # the HUD turns this off when the child taps Play
	set(v):
		orbit = v
		_cam_goal = Vector3(INF, INF, INF)
		if is_inside_tree():
			_frame_camera()
var _built_once := false    # after the first build, a new building "pops" into place
var _manual_cam := false
var _touches := {}          # finger -> screen position
var _press_pos := Vector2.ZERO
var _dragging := false

const DRAG_START := 14.0    # pixels: less than this is a tap, more is a drag
const ZOOM_MIN := 6.0
const ZOOM_MAX := 50.0           # from far away you can see the whole little planet, like a ball

# Mike's path: a fine grid (4 x 4 per base cell) where buildings are walls.
const NAV_STEP := 0.5           # meters per little square
const NAV_MARGIN := 10.0        # free meters around the base so Mike can walk around
const WALK_SPEED := 4.5         # meters per second
const CORNER := 0.6             # radius of the curves: Mike never turns at a sharp corner
const CLEARANCE := 0.2          # Mike's gap to the wall when cutting corners
var _nav := AStarGrid2D.new()
var _path := PackedVector3Array()
var _path_i := 0
var _speed := WALK_SPEED
var _face := 0.0
var _look := Vector3.INF
var _arrive := Callable()
var _hi := {}               # lit cells (where you can build or move)
var _tile_lock_mat: StandardMaterial3D

# Little planet: the ground is flat where the base is and curves down after that, like a ball.
# It grows with Mike's House (the open area always fits on the flat part).
const FLAT_BY_LEVEL := {1: 6.0, 2: 10.5, 3: 14.5}   # meters from the center to where the ground is flat (the open area fits)
const PLANET := 14.0            # radius of the curve after the flat part (large: the planet looks round like a ball)
var _flat_r := 6.0
const JOIN := 0.7071            # the terrain ends where the curve reaches 45° (sin 45°)
var _terrain_src: Array = []    # [MeshInstance3D, transform, [arrays of each surface], [materials]]
const SKY_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;
uniform sampler2D sky : source_color, repeat_enable, filter_linear;
uniform float offset = 0.0;
uniform float span = 0.13;
uniform vec3 tint : source_color = vec3(1.0);
void fragment() {
	ALBEDO = texture(sky, vec2(offset + (UV.x - 0.5) * span, mix(0.03, 0.49, UV.y))).rgb * tint;
}
"""
var _sky: MeshInstance3D
var _warn_tex: Texture2D       # the yellow "broken" warning (drawn once)
var _plant_icons := {}         # plant -> texture rendered from its 3D model (greenhouse panel, seeds, inventory)
var _mark_px := 0.01           # pixel_size of the growing-plant ring right now (follows the zoom)
var _sky_mat: ShaderMaterial


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
	# On the start screen, the camera slowly circles the base.
	if orbit and not _manual_cam:
		_yaw_goal += delta * 0.08
	# On a computer: Q/E or the arrow keys turn; + and - zoom.
	var spin := float(Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT))
	if spin != 0.0:
		_turn(spin * delta * 1.6)
	var zoom_key := float(Input.is_key_pressed(KEY_MINUS)) - float(Input.is_key_pressed(KEY_EQUAL) or Input.is_key_pressed(KEY_PLUS))
	if zoom_key != 0.0:
		_zoom(1.0 + zoom_key * delta * 1.2)
	var ease_k := 1.0 - exp(-delta * CAM_SMOOTH)
	_rig.rotation.y = lerp_angle(_rig.rotation.y, _yaw_goal, ease_k)
	_rig.position = _rig.position.lerp(_pos_goal, ease_k)
	camera.size = lerpf(camera.size, _size_goal, ease_k)
	_fit_sky()
	_step_mike(delta)
	# The broken warning slowly floats up and down.
	for k in _nodes:
		var warn: Sprite3D = _nodes[k].get_node_or_null("Broken")
		if warn and warn.visible:
			warn.position.y = float(warn.get_meta("y", 2.0)) + sin(_time * 3.0) * 0.15
	# The ring keeps the same size on screen: its size in the world follows the zoom (KEEP_WIDTH camera).
	var mark := camera.size * GROW_MARK_PX / (maxf(get_viewport().get_visible_rect().size.x, 1.0) * 128.0)
	if absf(mark - _mark_px) > _mark_px * 0.01:
		_mark_px = mark
		for k in _nodes:
			_place_grow_mark(_nodes[k])
	var show_names := camera.size < 14.5
	for k in _nodes:
		var label: Label3D = _nodes[k].get_node_or_null("Label")
		if label:
			label.visible = show_names
	if _pet == null:
		return
	# Ingenuity flies behind Mike, bobbing, with the rotors spinning in opposite directions.
	var target := mike.position + Vector3(1.1, 2.6 + sin(_time * 2.0) * 0.15, 0.7)
	_pet.position = _pet.position.lerp(target, 1.0 - exp(-delta * 1.8))
	for i in _rotors.size():
		_rotors[i].rotate_object_local(_rotor_axes[i], delta * (28.0 if i == 0 else -28.0))


func cell_center(c: Vector2i) -> Vector3:
	var x0 := -State.GRID_W * CELL / 2.0
	var z0 := -State.GRID_H * CELL / 2.0
	return Vector3(x0 + (c.x + 0.5) * CELL, 0.0, z0 + (c.y + 0.5) * CELL)


func highlight(cells: Array) -> void:
	_hi.clear()
	for c in cells:
		_hi[State.key(c)] = true
	whole_grid = not cells.is_empty()
	_paint_tiles()
	_frame_camera()


## Open cells (from Mike's House) look normal; the next area appears dimmed; the rest disappears.
## When the house levels up, the new cells "sprout" from the ground.
func _paint_tiles() -> void:
	var open := State.zone()
	var next := State.zone(State.house_level() + 1)
	for k in _tiles:
		var c := State.parse_key(k)
		var t: MeshInstance3D = _tiles[k]
		var is_open := open.has_point(c)
		t.visible = next.has_point(c)
		t.position.y = _ground_y(cell_center(c)) + 0.01
		t.material_override = _tile_hi_mat if _hi.has(k) else (_tile_mat if is_open else _tile_lock_mat)
		if is_open and not t.get_meta("open", false) and _built_once:
			t.scale = Vector3.ONE * 0.1
			var tw := create_tween()
			tw.tween_interval(0.15 + Vector2(c - open.get_center()).length() * 0.06)
			tw.tween_property(t, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.set_meta("open", is_open)


## The camera frames the base: close when it is small, the whole grid when building or moving.
## After the child moves the camera with their fingers, it only adjusts itself when building or moving.
func _frame_camera() -> void:
	if _manual_cam and not whole_grid:
		return
	if orbit:
		# Start screen: the top of Mars with the base, as in the game, just a bit farther.
		var far := _zoom_max()
		_cam_goal = Vector3(0.0, 0.0, far)
		_pos_goal = Vector3.ZERO
		_size_goal = far
		if _cam_snap:
			_cam_snap = false
			_rig.position = _pos_goal
			camera.size = _size_goal
		return
	var area := State.zone()
	var lo := area.position
	var hi := area.end - Vector2i.ONE
	if not whole_grid:
		lo = Vector2i(State.GRID_W, State.GRID_H)
		hi = Vector2i(-1, -1)
		for k in State.items:
			for c in State.item_cells(k, State.items[k]):
				lo = lo.min(c)
				hi = hi.max(c)
		lo = (lo - Vector2i(1, 1)).clamp(Vector2i.ZERO, Vector2i(State.GRID_W - 1, State.GRID_H - 1))
		hi = (hi + Vector2i(1, 1)).clamp(Vector2i.ZERO, Vector2i(State.GRID_W - 1, State.GRID_H - 1))
	var a := cell_center(lo) - Vector3(CELL / 2.0, 0.0, CELL / 2.0)
	var b := cell_center(hi) + Vector3(CELL / 2.0, 0.0, CELL / 2.0)
	var center := (a + b) / 2.0
	var size := clampf(((b.x - a.x) + (b.z - a.z)) / sqrt(2.0) * 1.08, CAM_MIN, CAM_MAX)
	# The base sits a little below the middle of the screen: leaves room for the sky to show behind the planet.
	var vp := get_viewport().get_visible_rect().size
	var far := -_rig.global_transform.basis.z
	far = Vector3(far.x, 0.0, far.z).normalized()
	center += far * (size * vp.y / maxf(vp.x, 1.0) * 0.1 / sin(deg_to_rad(35.264)))
	var goal := Vector3(center.x, center.z, size)
	if goal.is_equal_approx(_cam_goal):
		return
	_cam_goal = goal
	_pos_goal = center
	_size_goal = size
	if _cam_snap:
		_cam_snap = false
		_rig.position = center
		camera.size = size


# ───────────── Fingers on screen: drag pans, pinch zooms, two fingers twisting turn the world ─────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)
	elif event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION:
		_on_mouse_button(event)
	elif event is InputEventMouseMotion and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if not _dragging and event.position.distance_to(_press_pos) > DRAG_START:
				_dragging = true
			if _dragging:
				_pan(event.position - event.relative, event.position)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			_turn(-event.relative.x * 0.008)


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
		if _touches.size() == 1:
			_press_pos = event.position
			_dragging = false
		else:
			_multi = true
			_turn_sum = 0.0
			_zoom_sum = 1.0
			_turning = false
			_zooming = false
		return
	var was_single := _touches.size() == 1
	_touches.erase(event.index)
	if was_single and not _dragging and not _multi:
		_tap(event.position)
	if _touches.is_empty():
		_dragging = false
		_multi = false


func _on_drag(event: InputEventScreenDrag) -> void:
	var before: Vector2 = _touches.get(event.index, event.position - event.relative)
	_touches[event.index] = event.position
	if _touches.size() == 1:
		# After using two fingers, the leftover finger does not drag (avoids a jolt).
		if _multi:
			return
		if not _dragging and event.position.distance_to(_press_pos) > DRAG_START:
			_dragging = true
		if _dragging:
			_pan(before, event.position)
		return
	# Two fingers: the distance between them zooms, the angle between them turns the world.
	# Each one only starts after a small deadzone, so shaky fingers do not move the screen.
	_dragging = true
	var ids := _touches.keys()
	var a: Vector2 = _touches[ids[0]]
	var b: Vector2 = _touches[ids[1]]
	var a0: Vector2 = before if ids[0] == event.index else a
	var b0: Vector2 = before if ids[1] == event.index else b
	var factor := (a0 - b0).length() / maxf((a - b).length(), 1.0)
	var angle := wrapf((b - a).angle() - (b0 - a0).angle(), -PI, PI)
	_zoom_sum *= factor
	_turn_sum += angle
	if not _zooming and absf(_zoom_sum - 1.0) > ZOOM_DEADZONE:
		_zooming = true
	if not _turning and absf(_turn_sum) > TURN_DEADZONE:
		_turning = true
	if _zooming:
		_zoom(factor)
	if _turning:
		_turn(angle)


func _on_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				_zoom(0.9)
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_zoom(1.1)
		# Sideways scrolling (laptop touchpad) turns the world.
		MOUSE_BUTTON_WHEEL_LEFT:
			if event.pressed:
				_turn(0.06 * maxf(event.factor, 1.0))
		MOUSE_BUTTON_WHEEL_RIGHT:
			if event.pressed:
				_turn(-0.06 * maxf(event.factor, 1.0))
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				_press_pos = event.position
				_dragging = false
			elif not _dragging:
				_tap(event.position)


## Quick tap: on Mike, he reacts; on a building (any part of it), opens its menu;
## on the ground, picks the grid cell. When choosing where to build or move, only the ground counts.
func _tap(p: Vector2) -> void:
	var o := camera.project_ray_origin(p)
	var d := camera.project_ray_normal(p)
	var hit := {} if whole_grid else _item_under(o, d)
	if _on_mike(p) and (hit.is_empty() or (mike.global_position - o).dot(d) < float(hit.t)):
		mike_tapped.emit()
		return
	cell_tapped.emit(hit.cell if not hit.is_empty() else _cell_from_screen(p))


## Is the finger on Mike? (his rectangle on screen, with a little margin)
func _on_mike(p: Vector2) -> bool:
	if not mike.visible:
		return false
	var feet := camera.unproject_position(mike.global_position)
	var head := camera.unproject_position(mike.global_position + Vector3(0.0, MIKE_HEIGHT, 0.0))
	var h := absf(feet.y - head.y)
	var box := Rect2(Vector2(feet.x - h * 0.25, head.y), Vector2(h * 0.5, h)).grow(12.0)
	return box.has_point(p)


## The building the finger's ray hits first: {"t": distance, "cell": its cell closest to the tap}.
func _item_under(o: Vector3, d: Vector3) -> Dictionary:
	var best := {}
	for k in _nodes:
		var node: Node3D = _nodes[k]
		var box: AABB = (node.global_transform * _merged_aabb(node)).grow(0.15)
		var warn: Sprite3D = node.get_node_or_null("Broken")
		if warn and warn.visible:
			box = box.expand(warn.global_position + Vector3(0.0, 0.6, 0.0))
		var point: Variant = box.intersects_ray(o, d)
		if point == null:
			continue
		var t: float = ((point as Vector3) - o).dot(d)
		if best.is_empty() or t < float(best.t):
			best = {"t": t, "key": k, "point": point}
	if best.is_empty() or not State.items.has(best.key):
		return {}
	var at: Vector3 = best.point
	var cell := State.parse_key(best.key)
	for c in State.item_cells(best.key, State.items[best.key]):
		if _flat(cell_center(c)).distance_to(_flat(at)) < _flat(cell_center(cell)).distance_to(_flat(at)):
			cell = c
	best.cell = cell
	return best


## Dragging: the ground "sticks" to the finger.
func _pan(from: Vector2, to: Vector2) -> void:
	var p0 := _ground_point(from)
	var p1 := _ground_point(to)
	if p0 == Vector3.INF or p1 == Vector3.INF:
		return
	_take_camera()
	var limit := Vector3(State.GRID_W * CELL / 2.0 + CELL * 2.0, 0.0, State.GRID_H * CELL / 2.0 + CELL * 2.0)
	_pos_goal = (_pos_goal + p0 - p1).clamp(-limit, limit)


func _zoom(factor: float) -> void:
	_take_camera()
	_size_goal = clampf(_size_goal * factor, ZOOM_MIN, _zoom_max())


## The farthest the camera goes: the screen shows only the top of Mars (about 40 m of screen height),
## never the whole planet. Upright (phone) this gives less width than sideways (computer).
func _zoom_max() -> float:
	var vp := get_viewport().get_visible_rect().size
	return clampf(40.0 / maxf(vp.y / maxf(vp.x, 1.0), 0.3), CAM_MAX, ZOOM_MAX)


## The world turns the same way as the fingers.
func _turn(angle: float) -> void:
	_take_camera()
	_yaw_goal += angle


func _take_camera() -> void:
	_manual_cam = true
	_cam_goal = Vector3(INF, INF, INF)


func _ground_point(p: Vector2) -> Vector3:
	var o := camera.project_ray_origin(p)
	var d := camera.project_ray_normal(p)
	if absf(d.y) < 0.0001:
		return Vector3.INF
	return o + d * (-o.y / d.y)


## Mike walks to the front of the tapped cell (the side facing the camera), going around buildings.
func walk_to(c: Vector2i, then := Callable()) -> void:
	if _walking_out or State.exploring():
		return   # Mike is on the expedition: he does not come back because of a tap on the base
	var front := _rig.global_transform.basis.z
	front = Vector3(front.x, 0.0, front.z).normalized()
	_go(cell_center(c) + front * CELL * 0.62, WALK_SPEED, then, cell_center(c))


## Walks to "target" along the free path, with rounded corners. On arrival, looks at "look" and calls "then".
func _go(target: Vector3, speed := WALK_SPEED, then := Callable(), look := Vector3.INF, beyond := false) -> void:
	_path = _round_corners(_find_path(_flat(mike.position), _flat(target), beyond))
	_path_i = 1
	_speed = speed
	_arrive = then
	_look = look
	if _path.size() < 2 or _path[0].distance_to(_path[-1]) < 0.05:
		_path_i = _path.size()
		_finish_walk()
		return
	_play_mike("run")


func _step_mike(delta: float) -> void:
	if _path_i >= _path.size():
		return
	var left := _speed * delta
	var p := _flat(mike.position)
	while left > 0.0 and _path_i < _path.size():
		var to := _path[_path_i] - p
		var dist := to.length()
		if dist > 0.001:
			_face = atan2(to.x, to.z)
		if dist <= left:
			p = _path[_path_i]
			left -= dist
			_path_i += 1
		else:
			p += to / dist * left
			left = 0.0
	mike.position = Vector3(p.x, _ground_y(p), p.z)
	mike.rotation.y = lerp_angle(mike.rotation.y, _face, 1.0 - exp(-delta * 14.0))
	if _path_i >= _path.size():
		_finish_walk()


func _finish_walk() -> void:
	if _look != Vector3.INF and _flat(_look).distance_to(_flat(mike.position)) > 0.05:
		var to := _flat(_look) - _flat(mike.position)
		var from := mike.rotation.y
		create_tween().tween_method(func(a: float) -> void: mike.rotation.y = a,
			from, from + wrapf(atan2(to.x, to.z) - from, -PI, PI), 0.2)
	_play_mike("idle")
	if not _walking_out and not State.exploring():
		_set_suit(false)
	var then := _arrive
	_arrive = Callable()
	if then.is_valid():
		then.call()


func _flat(p: Vector3) -> Vector3:
	return Vector3(p.x, 0.0, p.z)


## Free path from "from" to "to": A* on the fine grid, then cuts corners where the straight line passes without hitting.
func _find_path(from: Vector3, to: Vector3, beyond := false) -> Array[Vector3]:
	var a := _free_near(_nav_id(from))
	var b := _free_near(_nav_id(to))
	var ids := _nav.get_id_path(a, b, true)
	var pts: Array[Vector3] = [from]
	for id in ids:
		pts.append(_nav_point(id))
	if beyond or (b == _nav_id(to) and (ids.is_empty() or ids[-1] == b)):
		pts.append(to)
	var out: Array[Vector3] = [from]
	var i := 0
	while i < pts.size() - 1:
		var j := i + 1
		while j + 1 < pts.size() and _clear_line(pts[i], pts[j + 1]):
			j += 1
		out.append(pts[j])
		i = j
	return out


## Replaces each corner of the path with a Bézier curve of radius CORNER.
func _round_corners(pts: Array[Vector3]) -> PackedVector3Array:
	var out := PackedVector3Array()
	if pts.is_empty():
		return out
	out.append(pts[0])
	for i in range(1, pts.size() - 1):
		var p := pts[i]
		var a := p + (pts[i - 1] - p).limit_length(minf(CORNER, pts[i - 1].distance_to(p) / 2.0))
		var b := p + (pts[i + 1] - p).limit_length(minf(CORNER, pts[i + 1].distance_to(p) / 2.0))
		for s in 7:
			var t := s / 6.0
			out.append(a.lerp(p, t).lerp(p.lerp(b, t), t))
	out.append(pts[-1])
	return out


func _clear_line(a: Vector3, b: Vector3) -> bool:
	var n := maxi(1, ceili(a.distance_to(b) / 0.2))
	for s in n + 1:
		var p := a.lerp(b, float(s) / n)
		for o in [Vector3.ZERO, Vector3(CLEARANCE, 0, 0), Vector3(-CLEARANCE, 0, 0), Vector3(0, 0, CLEARANCE), Vector3(0, 0, -CLEARANCE)]:
			if _nav_solid(p + o):
				return false
	return true


func _nav_origin() -> Vector2:
	return Vector2(-State.GRID_W * CELL / 2.0 - NAV_MARGIN, -State.GRID_H * CELL / 2.0 - NAV_MARGIN)


func _nav_id(p: Vector3) -> Vector2i:
	var o := _nav_origin()
	return Vector2i(floori((p.x - o.x) / NAV_STEP), floori((p.z - o.y) / NAV_STEP)).clamp(Vector2i.ZERO, _nav.region.size - Vector2i.ONE)


func _nav_point(id: Vector2i) -> Vector3:
	var o := _nav_origin()
	return Vector3(o.x + (id.x + 0.5) * NAV_STEP, 0.0, o.y + (id.y + 0.5) * NAV_STEP)


func _nav_solid(p: Vector3) -> bool:
	var o := _nav_origin()
	var id := Vector2i(floori((p.x - o.x) / NAV_STEP), floori((p.z - o.y) / NAV_STEP))
	return _nav.is_in_boundsv(id) and _nav.is_point_solid(id)


## The nearest free square (if Mike or the destination ended up inside a building).
func _free_near(id: Vector2i) -> Vector2i:
	if not _nav.is_point_solid(id):
		return id
	for r in range(1, 24):
		var best := Vector2i(-1, -1)
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				var c := id + Vector2i(dx, dy)
				if maxi(absi(dx), absi(dy)) != r or not _nav.is_in_boundsv(c) or _nav.is_point_solid(c):
					continue
				if best.x < 0 or Vector2(c - id).length() < Vector2(best - id).length():
					best = c
		if best.x >= 0:
			return best
	return id


func _build_nav() -> void:
	var size := Vector2(State.GRID_W * CELL, State.GRID_H * CELL) + Vector2.ONE * NAV_MARGIN * 2.0
	_nav.region = Rect2i(Vector2i.ZERO, Vector2i(roundi(size.x / NAV_STEP), roundi(size.y / NAV_STEP)))
	_nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_nav.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_nav.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_nav.update()


## Buildings become walls. Near them the path "costs" more: Mike prefers to pass with room to spare.
func _sync_nav() -> void:
	_nav.fill_solid_region(_nav.region, false)
	_nav.fill_weight_scale_region(_nav.region, 1.0)
	var per := roundi(CELL / NAV_STEP)
	var blocks: Array[Rect2i] = []
	for k in State.items:
		for c in State.item_cells(k, State.items[k]):
			blocks.append(Rect2i(_nav_id(cell_center(c) - Vector3(CELL / 2.0 - 0.01, 0.0, CELL / 2.0 - 0.01)), Vector2i(per, per)))
	for b in blocks:
		_nav.fill_weight_scale_region(b.grow(1).intersection(_nav.region), 3.0)
	for b in blocks:
		_nav.fill_solid_region(b, true)
	# Mike walks on the flat part and the start of the planet's curve, never along the edge.
	var edge := _flat_r + PLANET * 0.45
	for x in _nav.region.size.x:
		for y in _nav.region.size.y:
			var q := _nav_point(Vector2i(x, y))
			if Vector2(q.x, q.z).length() > edge:
				_nav.set_point_solid(Vector2i(x, y), true)
	# Built on top of Mike? He steps aside.
	if _path_i >= _path.size() and mike and not _walking_out and not State.exploring() and _nav_solid(mike.position):
		_go(_nav_point(_free_near(_nav_id(mike.position))))


## Ground height of the little planet (0 at the base; drops after the flat part).
func _ground_y(p: Vector3) -> float:
	return -planet_drop(Vector2(p.x, p.z).length())


func planet_drop(d: float) -> float:
	var u := clampf(d - _flat_r, 0.0, PLANET * 0.97)
	return PLANET - sqrt(PLANET * PLANET - u * u)


## A point on the far side of the planet (behind the curve, away from the camera): where Mike disappears on the expedition.
func _far_point() -> Vector3:
	var back := -_rig.global_transform.basis.z
	return Vector3(back.x, 0.0, back.z).normalized() * (_flat_r + PLANET * (JOIN - 0.05))


## Construction site: Mike walks there and hammers; colored blocks fall and bounce; at the end they vanish and the building sprouts.
## Small things (flag, pot): Mike crouches and places them, and they pop out of the ground.
func _build_site(node: Node3D, type: String, c: Vector2i, width: int, rot: int) -> void:
	var small := type in PLACE_ONLY
	node.visible = false
	walk_to(c, func() -> void: _play_mike("colocar" if small else "construir"))
	var walk_time := 0.0
	for i in range(1, _path.size()):
		walk_time += _path[i - 1].distance_to(_path[i])
	walk_time /= _speed
	var total := walk_time + (0.45 if small else BUILD_WORK_TIME)
	var site := Node3D.new()
	add_child(site)
	site.position = node.position
	if not small:
		var block := BoxMesh.new()
		block.size = Vector3.ONE * 0.35
		var spread := Vector2(CELL * 0.6 * width, CELL * 0.6)
		if rot % 2 == 1:
			spread = Vector2(spread.y, spread.x)
		for i in 12:
			var b := MeshInstance3D.new()
			b.mesh = block
			b.material_override = _mat(SITE_COLORS[i % SITE_COLORS.size()])
			var col := i % 4
			var row := i / 4
			var rest := Vector3((col % 2 - 0.5) * spread.x * 0.5, 0.175 + row * 0.35, (col / 2 - 0.5) * spread.y * 0.5)
			b.position = rest + Vector3(0.0, 1.2, 0.0)
			b.rotation.y = randf_range(-0.3, 0.3)
			b.scale = Vector3.ZERO
			site.add_child(b)
			var t := create_tween()
			t.tween_interval(total * 0.85 * float(i) / 12.0)
			t.tween_callback(func() -> void: b.scale = Vector3.ONE)
			t.tween_property(b, "position:y", rest.y, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(total).timeout
	for b in site.get_children():
		create_tween().tween_property(b, "scale", Vector3.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if not small:
		await get_tree().create_timer(0.2).timeout
	if is_instance_valid(node):
		node.visible = true
		node.scale = Vector3(1.0, 0.01, 1.0) if not small else Vector3.ONE * 0.01
		var rise := create_tween()
		if small:
			rise.tween_property(node, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			rise.tween_property(node, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_dust_puff(site, 10 if small else 24)
	if _path_i >= _path.size():
		_play_mike("idle")
	get_tree().create_timer(1.0).timeout.connect(site.queue_free)


## Cream-colored dust rising from the ground (from Design's construcao.gd).
func _dust_puff(parent: Node3D, amount: int) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.amount = amount
	p.lifetime = 0.6
	p.explosiveness = 1.0
	p.direction = Vector3.UP
	p.spread = 80.0
	p.initial_velocity_min = 1.0
	p.initial_velocity_max = 2.5
	p.gravity = Vector3(0, -2, 0)
	p.scale_amount_min = 0.15
	p.scale_amount_max = 0.3
	var m := SphereMesh.new()
	m.radius = 0.15
	m.height = 0.3
	m.material = _mat(Color("F2D091"))
	p.mesh = m
	parent.add_child(p)
	p.emitting = true


## The screen point just above the building (so the floating menu can point to it).
func item_screen_top(c: Vector2i) -> Vector2:
	var k := State.key(State.anchor_of(c))
	if not _nodes.has(k):
		return Vector2.INF
	var node: Node3D = _nodes[k]
	var box: AABB = node.global_transform * _merged_aabb(node)
	return camera.unproject_position(Vector3(box.get_center().x, box.end.y, box.get_center().z))


## Mike jumps for joy (when he harvests, for example).
func jump() -> void:
	if _mike_anim and _mike_anim.has_animation("jump"):
		_play_mike("jump")
		_mike_anim.queue("idle")
		return
	var t := create_tween()
	t.tween_property(mike, "position:y", 0.9, 0.18).set_ease(Tween.EASE_OUT)
	t.tween_property(mike, "position:y", 0.0, 0.22).set_ease(Tween.EASE_IN)


func _cell_from_screen(p: Vector2) -> Vector2i:
	var hit := _ground_point(p)
	if hit == Vector3.INF:
		return OUTSIDE
	var c := Vector2i(floori((hit.x + State.GRID_W * CELL / 2.0) / CELL), floori((hit.z + State.GRID_H * CELL / 2.0) / CELL))
	return c if State.in_grid(c) else OUTSIDE


# ───────────── Weather: storm, cold and dust change the light ─────────────
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
	# Blackout (no energy): the base stays dim until the energy comes back.
	var blackout: bool = State.energy <= 0.0
	_sun.light_energy = 0.45 if blackout else 1.1
	if blackout:
		ambient = ambient.darkened(0.45)
	_sun.light_color = light
	_env.ambient_light_color = ambient
	if _sky_mat:
		_sky_mat.set_shader_parameter("tint", light.darkened(0.45 if blackout else 0.0))
	_dome.visible = State.storm_active() and State.storm_shielded
	mike.visible = _walking_out or not (State.mike_inside() or State.exploring())


# ───────────── Expedition ─────────────
## Mike walks far away (to the back, toward Mount Sharp) and disappears.
func _walk_out() -> void:
	_walking_out = true
	_set_suit(true)
	_go(_far_point(), WALK_SPEED * 1.4, func() -> void:
		_walking_out = false
		_sync_mood(), Vector3.INF, true)


## Return from the expedition: appears far in the back and walks to the front of the house, with the tube.
func _walk_back(_card_id: int) -> void:
	_walking_out = false
	var far := _far_point()
	mike.position = Vector3(far.x, _ground_y(far), far.z)
	_set_suit(true)
	_sync_mood()
	for k in State.items:
		if State.items[k].type == "habitat":
			walk_to(State.parse_key(k))
			return


# ───────────── Building the world ─────────────
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

	# Camera on a "tripod": the tripod sits at the point the camera looks at; turning the tripod turns the world.
	_rig = Node3D.new()
	_rig.rotation_degrees.y = 45.0
	add_child(_rig)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 19.0
	camera.rotation_degrees = Vector3(-35.264, 0.0, 0.0)
	_rig.add_child(camera)
	camera.position = camera.transform.basis.z * 40.0
	camera.current = true

	# 360° sky from design/03 (with the Sun, Phobos and Deimos) on a panel far in the back, behind the little planet.
	# When the world turns, the sky slides along (the Sun and moons appear on one side).
	var sky_file := State.model_file("ceu")
	if sky_file.ends_with(".png") and ResourceLoader.exists(ITEMS_DIR + sky_file):
		_sky_mat = ShaderMaterial.new()
		_sky_mat.shader = Shader.new()
		_sky_mat.shader.code = SKY_SHADER
		_sky_mat.set_shader_parameter("sky", load(ITEMS_DIR + sky_file))
		_sky = MeshInstance3D.new()
		_sky.mesh = QuadMesh.new()
		_sky.material_override = _sky_mat
		_sky.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		camera.add_child(_sky)
		_sky.position = Vector3(0.0, 0.0, -300.0)

	# Terrain with relief and craters from design/03 (flat center for the base). Without it, a plain ground.
	var terrain := _load_model(State.model_file("chao"), 1000.0, 1000.0)
	if terrain:
		terrain.scale = Vector3.ONE
		terrain.position = Vector3(0.0, -_center_height(terrain) - 0.03, 0.0)
		add_child(terrain)
		_bend_terrain(terrain)
	else:
		var ground := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(160.0, 160.0)
		ground.mesh = plane
		ground.material_override = _mat(Palette.GROUND)
		ground.position.y = -0.02
		add_child(ground)

	# Floating golden dust (effect from design/03).
	var dust_file := State.model_file("efeito-poeira")
	if dust_file.ends_with(".gd") and ResourceLoader.exists(ITEMS_DIR + dust_file):
		var dust: Node3D = (load(ITEMS_DIR + dust_file) as GDScript).new()
		dust.set("area", Vector3(State.GRID_W * CELL + 10.0, 5.0, State.GRID_H * CELL + 10.0))
		add_child(dust)


## The sky panel covers the whole screen, without stretching the image.
func _fit_sky() -> void:
	if _sky == null:
		return
	var vp := get_viewport().get_visible_rect().size
	var aspect := vp.y / maxf(vp.x, 1.0)
	_sky.scale = Vector3(camera.size * 1.05, camera.size * aspect * 1.05, 1.0)
	_sky_mat.set_shader_parameter("span", 0.23 / aspect)
	_sky_mat.set_shader_parameter("offset", 0.365 - _rig.rotation.y / TAU)


## Bends the terrain into a small ball: flat where the base is, dropping after that (the sky shows behind).
## Outside the little planet's radius, the ground is cut into a circle.
func _bend_terrain(terrain: Node3D) -> void:
	_terrain_floor = terrain.position.y + _center_height(terrain)
	_flat_r = FLAT_BY_LEVEL[clampi(State.house_level(), 1, State.MAX_LEVEL)]
	for node in terrain.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var surfaces: Array = []
		var mats: Array = []
		for s in mi.mesh.get_surface_count():
			surfaces.append(mi.mesh.surface_get_arrays(s))
			mats.append(mi.mesh.surface_get_material(s))
		_terrain_src.append([mi, mi.global_transform, surfaces, mats])
	_rebend()


var _terrain_floor := 0.0
var _planet_bottom: MeshInstance3D   # the bottom half of the little planet (so it is a ball, with no cut)


func _rebend() -> void:
	# The terrain only goes as far as where the curve is 45° (still smooth); from there down it is the body's smooth sphere.
	var rim := _flat_r + PLANET * JOIN
	var floor_y := _terrain_floor
	for src in _terrain_src:
		var mi: MeshInstance3D = src[0]
		var xf: Transform3D = src[1]
		var inv := xf.affine_inverse()
		var bent := ArrayMesh.new()
		for s in (src[2] as Array).size():
			var arrays: Array = (src[2][s] as Array).duplicate()
			var verts: PackedVector3Array = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).duplicate()
			var normals: PackedVector3Array = (arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array).duplicate() if arrays[Mesh.ARRAY_NORMAL] != null else PackedVector3Array()
			for i in verts.size():
				var w := xf * verts[i]
				var flat := Vector2(w.x, w.z)
				var d := flat.length()
				# The last band of points goes exactly onto the edge circle: the silhouette stays smooth, no stair-steps.
				if d > rim - 1.3:
					flat = flat / maxf(d, 0.001) * rim
					w = Vector3(flat.x, floor_y, flat.y)
					d = rim
				else:
					# Near the edge the hills fade out: the planet's edge stays smooth, with no "teeth".
					w.y = floor_y + (w.y - floor_y) * (1.0 - smoothstep(rim - 7.0, rim - 0.5, d))
				w.y -= planet_drop(d)
				verts[i] = inv * w
				if i < normals.size() and d > _flat_r:
					var u := d - _flat_r
					var tilt := atan(u / sqrt(maxf(PLANET * PLANET - u * u, 0.0001)))
					var n := (xf.basis * normals[i]).rotated(Vector3(flat.y / d, 0.0, -flat.x / d), tilt)
					normals[i] = (inv.basis * n).normalized()
			arrays[Mesh.ARRAY_VERTEX] = verts
			if normals.size() == verts.size():
				arrays[Mesh.ARRAY_NORMAL] = normals
			bent.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			bent.surface_set_material(s, src[3][s])
		mi.mesh = bent
	_build_planet_bottom(rim, floor_y - planet_drop(rim))
	if _dome:
		(_dome.mesh as SphereMesh).radius = _flat_r + 1.5
		(_dome.mesh as SphereMesh).height = (_flat_r + 1.5) * 0.63


## The planet's body: a smooth sphere (built here, in rings) that continues the terrain's curve from
## 45° down to the bottom pole, with the same texture. Seen from any side, the edge is round, with no stair-steps.
func _build_planet_bottom(join_r: float, join_y: float) -> void:
	if _planet_bottom == null:
		_planet_bottom = MeshInstance3D.new()
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.78, 0.7)
		var tex: Texture2D = null
		if not _terrain_src.is_empty():
			var m: Material = _terrain_src[0][3][0]
			if m is BaseMaterial3D:
				tex = (m as BaseMaterial3D).albedo_texture
		if tex:
			mat.albedo_texture = tex
			mat.uv1_triplanar = true
			mat.uv1_scale = Vector3.ONE * 0.1
		else:
			mat.albedo_color = Palette.GROUND
		mat.roughness = 1.0
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_planet_bottom.material_override = mat
		_planet_bottom.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_planet_bottom)
	# Sphere that passes through the terrain's edge with the same slope (45°): radius = edge / sin 45°.
	var rb := join_r / sin(PI / 4.0)
	var center := Vector3(0.0, join_y - join_r, 0.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings := 28
	var segs := 72
	for i in rings:
		var t0 := lerpf(PI / 4.0, PI, float(i) / rings)
		var t1 := lerpf(PI / 4.0, PI, float(i + 1) / rings)
		for j in segs:
			var p0 := TAU * j / segs
			var p1 := TAU * (j + 1) / segs
			var quad := [Vector2(t0, p0), Vector2(t1, p0), Vector2(t1, p1), Vector2(t0, p0), Vector2(t1, p1), Vector2(t0, p1)]
			for q in quad:
				var n := Vector3(sin(q.x) * cos(q.y), cos(q.x), sin(q.x) * sin(q.y))
				st.set_normal(n)
				st.add_vertex(center + n * rb)
	_planet_bottom.mesh = st.commit()


## Terrain height at the middle of the map (where the base is), so the grid sits flush with the ground.
func _center_height(terrain: Node3D) -> float:
	var total := 0.0
	var n := 0
	for mi in terrain.find_children("*", "MeshInstance3D", true, false):
		var mesh := (mi as MeshInstance3D).mesh
		for s in mesh.get_surface_count():
			for v in mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				if absf(v.x) < 6.0 and absf(v.z) < 6.0:
					total += v.y
					n += 1
	return total / n if n > 0 else 0.0


func _build_grid() -> void:
	_tile_mat = _mat(Palette.TILE)
	_tile_hi_mat = _mat(Palette.TILE_HI)
	_tile_lock_mat = _mat(Color(Palette.TILE.darkened(0.25), 0.35))
	_tile_lock_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_build_nav()
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
	sph.radius = _flat_r + 1.5   # the shield covers the whole base (grows with the house)
	sph.height = sph.radius * 0.63
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
## Mike from design/01 (mike.glb, with the idle, run and jump animations inside).
func _build_mike() -> void:
	mike = Node3D.new()
	add_child(mike)
	mike.position = cell_center(Vector2i(4, 5)) + Vector3(0.0, 0.0, CELL * 0.62)
	for skin in [["casual", MIKE_SCENE], ["suit", MIKE_SUIT]]:
		if not ResourceLoader.exists(skin[1]):
			continue
		var model: Node3D = load(skin[1]).instantiate()
		model.scale = Vector3.ONE * (MIKE_HEIGHT / MIKE_MODEL_HEIGHT)
		mike.add_child(model)
		var player := _find_child_of_type(model, "AnimationPlayer") as AnimationPlayer
		if player and player.has_animation("idle"):
			var skel := model.find_children("*", "Skeleton3D", true, false)
			if not skel.is_empty():
				_arms_down(player, skel[0] as Skeleton3D)
			for loop_anim in ["idle", "run"]:
				if player.has_animation(loop_anim):
					player.get_animation(loop_anim).loop_mode = Animation.LOOP_LINEAR
			player.play("idle")
		else:
			player = null
		var hammer := model.find_child("Martelo", true, false) as Node3D
		if hammer:
			hammer.visible = false
		_mike_skins[skin[0]] = [model, player, hammer]
	if _mike_skins.has("casual"):
		_set_suit(false)
		return
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.32
	cap.height = 1.2
	body.mesh = cap
	body.material_override = _mat(Palette.SUIT)
	body.position.y = 0.6
	mike.add_child(body)


## The idle/run/jump animations of mike.glb came with arms spread out (T-pose).
## Here each arm is lowered (points at the ground, slightly outward), keeping the animation's swing.
## Design's new animations (construir, colocar) already come right and are left as they are.
func _arms_down(player: AnimationPlayer, s: Skeleton3D) -> void:
	for anim_name in ["idle", "run", "jump"]:
		var a := player.get_animation(anim_name)
		if a == null or a.has_meta("arms_down"):
			continue
		a.set_meta("arms_down", true)
		for side in ["LeftArm", "RightArm"]:
			var bi := s.find_bone(side)
			if bi < 0:
				continue
			var g := s.get_bone_global_rest(bi)
			var parent := s.get_bone_parent(bi)
			var pg := s.get_bone_global_rest(parent) if parent >= 0 else Transform3D()
			var d := g.basis.orthonormalized().y
			var down := Vector3(signf(d.x) * 0.3, -1.0, 0.0).normalized()
			var turned := Basis(Quaternion(d, down)) * g.basis.orthonormalized()
			var new_local := (pg.basis.orthonormalized().inverse() * turned).get_rotation_quaternion()
			var delta := s.get_bone_rest(bi).basis.get_rotation_quaternion().inverse() * new_local
			for t in a.get_track_count():
				if a.track_get_type(t) != Animation.TYPE_ROTATION_3D or String(a.track_get_path(t).get_concatenated_subnames()) != side:
					continue
				for k in a.track_get_key_count(t):
					a.track_set_key_value(t, k, (a.track_get_key_value(t, k) as Quaternion) * delta)


## Astronaut suit on the expedition; normal clothes at the base.
func _set_suit(on: bool) -> void:
	var want := "suit" if on and _mike_skins.has("suit") else "casual"
	if not _mike_skins.has(want):
		return
	var playing := "idle"
	if _mike_anim and _mike_anim.current_animation != "":
		playing = _mike_anim.current_animation
	for k in _mike_skins:
		(_mike_skins[k][0] as Node3D).visible = k == want
	_mike_anim = _mike_skins[want][1]
	if _mike_anim and _mike_anim.has_animation(playing):
		_mike_anim.play(playing)


func _play_mike(anim_name: String) -> void:
	# The hammer only shows while Mike is building.
	for k in _mike_skins:
		var hammer: Node3D = _mike_skins[k][2]
		if hammer:
			hammer.visible = anim_name == "construir"
	if _mike_anim and _mike_anim.has_animation(anim_name):
		if anim_name == "construir":
			_mike_anim.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
		_mike_anim.play(anim_name, 0.15)


# ───────────── Base items ─────────────
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
		var run_build_fx := false
		if not _nodes.has(k):
			var n := _make_item(it.type, level)
			add_child(n)
			_nodes[k] = n
			if _built_once and build_fx:
				build_fx = false
				run_build_fx = true
			elif _built_once:
				n.scale = Vector3.ONE * 0.3
				create_tween().tween_property(n, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var node: Node3D = _nodes[k]
		var w := State.width_of(it.type, level)
		var rot := int(it.get("rot", 0))
		# The middle of the row of cells; turned sideways, the row goes forward (+Z).
		var along := Vector3((w - 1) * CELL / 2.0, 0.0, 0.0) if rot % 2 == 0 else Vector3(0.0, 0.0, (w - 1) * CELL / 2.0)
		node.position = cell_center(State.parse_key(k)) + along
		var model: Node3D = node.get_node_or_null("Model")
		if model:
			model.rotation.y = -rot * PI / 2.0
		var label: Label3D = node.get_node("Label")
		label.text = tr(State.item_name(it))
		_update_plant(node, it)
		_update_broken(node, it, label.position.y)
		if it.type == "shelf":
			Shelf.dress(self, node, it)
		if run_build_fx:
			_build_site(node, it.type, State.parse_key(k), w, rot)
	var flat: float = FLAT_BY_LEVEL[clampi(State.house_level(), 1, State.MAX_LEVEL)]
	if flat != _flat_r:
		_flat_r = flat
		_rebend()
	_sync_nav()
	_paint_tiles()
	_built_once = true
	_sync_pet()
	_frame_camera()


func _make_item(type: String, level: int) -> Node3D:
	var root := Node3D.new()
	root.set_meta("type", type)
	root.set_meta("level", level)
	var h: float = State.ITEMS[type].height
	var model_name: String = State.ITEMS[type].get("model", "")
	var file := State.model_file(model_name, level)
	var model := _load_model(file, CELL * 0.9, CELL * 1.3)
	var target_h := State.model_height(type) * MIKE_HEIGHT / DESIGN_MIKE
	if model:
		if type == "rtg" and level >= State.MAX_LEVEL and file.begins_with("kilopower"):
			# Kilopower is a separate model: a reactor bigger than the RTG, fitting in the cell.
			_fit(model, CELL * 0.95, maxf(target_h, 0.8) * 1.8)
		elif State.FOOTPRINT.has(type) or file.contains("-n%d." % level):
			# Same scale at every level (each level's model already comes bigger).
			# Those that take several cells: level 1 fits in one cell. The others: level 1 has the height from tamanhos.csv.
			if not _type_scale.has(type):
				var first := _load_model(State.model_file(model_name, 1), 1.0, 1.0)
				first.scale = Vector3.ONE
				var size1 := _merged_aabb(first).size
				if State.FOOTPRINT.has(type):
					# Measured by width (the side the levels grow along); the door step may stick out a bit.
					_type_scale[type] = CELL * 0.95 / maxf(size1.x, 0.001)
				elif target_h <= 0.0:
					_type_scale[type] = CELL * 0.95 / maxf(maxf(size1.x, size1.z), 0.001)
				else:
					_type_scale[type] = minf(target_h / maxf(size1.y, 0.001), CELL * 0.95 / maxf(maxf(size1.x, size1.z), 0.001))
				first.free()
			_scale_model(model, _type_scale[type])
		elif target_h > 0.0:
			_fit(model, CELL * 0.95, target_h)
		var holder := Node3D.new()
		holder.name = "Model"
		holder.add_child(model)
		root.add_child(holder)
		h = _merged_aabb(model).end.y * model.scale.y + model.position.y
	else:
		var holder := _placeholder(type, h)
		holder.name = "Model"
		root.add_child(holder)
	var label := Label3D.new()
	label.name = "Label"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font = Palette.font(700)
	label.font_size = 44
	label.outline_size = 12
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
		ready_mark.font = Palette.font(800)
		ready_mark.font_size = 96
		ready_mark.outline_size = 18
		ready_mark.pixel_size = 0.012
		ready_mark.modulate = Palette.GOLD
		ready_mark.outline_modulate = Palette.BG
		root.add_child(ready_mark)
		# The growing plant floats above the greenhouse: its icon inside a ring that fills up (the same
		# one as in the greenhouse panel), so the child sees what is growing without opening it.
		# Drawn once per sol (not every frame): the 2D ring goes to a texture.
		var view := SubViewport.new()
		view.name = "GrowView"
		view.size = Vector2i(128, 128)
		view.transparent_bg = true
		view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		root.add_child(view)
		var ring := PlantRing.new()
		ring.name = "Ring"
		ring.size = Vector2(128, 128)
		view.add_child(ring)
		var grow := Sprite3D.new()
		grow.name = "Growing"
		grow.texture = view.get_texture()
		grow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		grow.no_depth_test = true
		grow.visible = false
		root.add_child(grow)
		root.set_meta("top", maxf(h, 0.5))
		_place_grow_mark(root)
	return root


## Ring and "!" above the greenhouse, at the size of the moment (the "!" sits on top of the ring).
func _place_grow_mark(node: Node3D) -> void:
	var grow: Sprite3D = node.get_node_or_null("Growing")
	if grow == null:
		return
	grow.pixel_size = _mark_px
	grow.position.y = float(node.get_meta("top")) + GROW_MARK_GAP + 64.0 * _mark_px
	var ready_mark: Label3D = node.get_node("Ready")
	ready_mark.pixel_size = _mark_px * 0.92
	ready_mark.position.y = grow.position.y + (64.0 * _mark_px + 56.0 * ready_mark.pixel_size if grow.visible else 0.0)


## Placeholder shapes for what has no model yet (house, greenhouse, Ingenuity pad).
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
			if model == null and it.plant == "potato":
				model = potato_model()
				model.scale = Vector3.ONE * 0.6
			if model:
				holder.add_child(model)
	var p := 0.0
	if it.plant != "":
		p = clampf(it.growth / float(State.PLANTS[it.plant].sols), 0.0, 1.0)
	holder.scale = Vector3.ONE * lerpf(0.25, 1.0, p)
	ready_mark.visible = it.plant != "" and p >= 1.0
	var grow: Sprite3D = node.get_node("Growing")
	grow.visible = it.plant != "" and not it.get("broken", false)
	_place_grow_mark(node)
	var ring: PlantRing = node.get_node("GrowView/Ring")
	if grow.visible and (ring.icon != plant_icon(it.plant) or ring.progress != p):
		ring.icon = plant_icon(it.plant)
		ring.progress = p
		var view: SubViewport = node.get_node("GrowView")
		view.render_target_update_mode = SubViewport.UPDATE_ONCE
		# The plant icon is drawn in its own viewport: if it was not ready yet, draw the ring again in a moment.
		get_tree().create_timer(0.2).timeout.connect(func() -> void:
			if is_instance_valid(view):
				view.render_target_update_mode = SubViewport.UPDATE_ONCE)


## Broken: a yellow warning floats above the building (tapping it opens "Fix").
func _update_broken(node: Node3D, it: Dictionary, label_y: float) -> void:
	var warn: Sprite3D = node.get_node_or_null("Broken")
	var broken: bool = it.get("broken", false)
	if broken and warn == null:
		if _warn_tex == null:
			_warn_tex = Icons3D.render(self, Icons3D.warning(), 128, 1.4)
		warn = Sprite3D.new()
		warn.name = "Broken"
		warn.texture = _warn_tex
		warn.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		warn.no_depth_test = true
		warn.pixel_size = 0.009
		warn.set_meta("y", label_y + 0.9)
		node.add_child(warn)
	if warn:
		warn.visible = broken


## The plant as a small picture (rendered once from its 3D model).
func plant_icon(p: String) -> Texture2D:
	if _plant_icons.has(p):
		return _plant_icons[p]
	var file := State.model_file(State.PLANTS[p].model)
	var vp := SubViewport.new()
	vp.size = Vector2i(96, 96)
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(vp)
	var model: Node3D = _load_model(file, 1.0, 1.0)
	if model == null and p == "potato":
		model = potato_model()
		model.position.y = -0.1
	if model:
		vp.add_child(model)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.7
	vp.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	vp.add_child(light)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 1.4
	vp.add_child(cam)
	cam.position = Vector3(1.5, 1.6, 1.5)
	cam.look_at(Vector3(0.0, 0.45, 0.0))
	_plant_icons[p] = vp.get_texture()
	return _plant_icons[p]


## Potato plant (made in code, Kenney does not have one): a little mound of soil, green leaves on top
## and three potatoes showing. About 1 tall, standing on the ground.
func potato_model() -> Node3D:
	var root := Node3D.new()
	var soil := MeshInstance3D.new()
	var mound := SphereMesh.new()
	mound.radius = 0.42
	mound.height = 0.36
	soil.mesh = mound
	soil.material_override = _mat(Color("6b3f26"))
	soil.position.y = 0.06
	root.add_child(soil)
	for i in 3:
		var potato := MeshInstance3D.new()
		var tuber := SphereMesh.new()
		tuber.radius = 0.13
		tuber.height = 0.2
		potato.mesh = tuber
		potato.material_override = _mat(Color("c9955a"))
		var a := TAU * i / 3.0 + 0.4
		potato.position = Vector3(cos(a) * 0.3, 0.12, sin(a) * 0.3)
		potato.rotation = Vector3(0.4, a, 0.3)
		root.add_child(potato)
	for i in 7:
		var leaf := MeshInstance3D.new()
		var blob := SphereMesh.new()
		blob.radius = 0.16
		blob.height = 0.2
		leaf.mesh = blob
		leaf.material_override = _mat(Color("5aa83c") if i % 2 == 0 else Color("4a8f30"))
		var a := TAU * i / 7.0
		var r := 0.0 if i == 0 else 0.17
		leaf.position = Vector3(cos(a) * r, 0.45 + (0.18 if i == 0 else 0.0) + (i % 3) * 0.05, sin(a) * r)
		root.add_child(leaf)
	return root


## Loads a .glb from jogo/models/items/ and fits it to the grid cell size (stands on the ground).
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


## Applies a fixed scale and leaves the model standing on the ground, centered.
func _scale_model(holder: Node3D, s: float) -> void:
	holder.scale = Vector3.ONE
	holder.position = Vector3.ZERO
	var box := _merged_aabb(holder)
	holder.scale = Vector3.ONE * s
	holder.position = Vector3(-box.get_center().x * s, -box.position.y * s, -box.get_center().z * s)


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


# ───────────── Ingenuity (the pet) ─────────────
## Appears when the child builds the Ingenuity pad.
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
	# Recolor in the style of Kenney's machines (flat colors from design/04).
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
	# Leaves the rotor axis pointing up (the model may come lying down).
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


## The thinnest axis of the rotor shape is the axis they spin on.
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


# ───────────── Utilities ─────────────
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
