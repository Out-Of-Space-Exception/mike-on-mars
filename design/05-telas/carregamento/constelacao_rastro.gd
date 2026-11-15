class_name ConstellationTrail
extends Node2D
## Mike on Mars constellation trail (original team effect).
## Whatever moves leaves little gold and cream stars, joined by thin lines, that blink and fade.
## Usage: add as a child of any Node2D that moves (the ship, Mike on screen, a button).

@export var target: Node2D          ## what leaves the trail; empty = the parent
@export var step := 22.0         ## distance (px) between one star and the next
@export var lifetime := 1.6           ## seconds until the star fades
@export var spread := 14.0      ## how far the stars stray from the straight line
@export var size_scale := 1.0       ## multiplies the size of the stars and lines
@export var colors: Array[Color] = [Color("e8b23a"), Color("f2d091"), Color("fff4d6")]

var _pts: Array = []
var _last := Vector2.INF


func _ready() -> void:
	top_level = true


func _process(dt: float) -> void:
	global_position = Vector2.ZERO
	var a: Node2D = target
	if a == null:
		a = get_parent() as Node2D
	if a != null:
		var p: Vector2 = a.global_position
		if _last == Vector2.INF:
			_last = p
		while p.distance_to(_last) >= step:
			_last = _last.move_toward(p, step)
			_add_point(_last)
	for q in _pts:
		q["t"] += dt
	_pts = _pts.filter(func(q): return q["t"] < lifetime)
	queue_redraw()


func _add_point(p: Vector2) -> void:
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * spread
	_pts.append({"pos": p + off, "t": 0.0, "size": randf_range(2.5, 5.5) * size_scale,
		"col": colors.pick_random(), "glint": randf() < 0.35, "phase": randf() * TAU})


func _draw() -> void:
	for i in range(1, _pts.size()):
		var a: Dictionary = _pts[i - 1]
		var b: Dictionary = _pts[i]
		var k: float = 1.0 - maxf(a["t"], b["t"]) / lifetime
		draw_line(a["pos"], b["pos"], Color(b["col"], 0.7 * k), 1.6 * size_scale, true)
		if i >= 2 and i % 3 == 0:
			var c: Dictionary = _pts[i - 2]
			draw_line(c["pos"], b["pos"], Color(b["col"], 0.35 * k), 1.0 * size_scale, true)
	for q in _pts:
		var k: float = 1.0 - q["t"] / lifetime
		var blink: float = 0.75 + 0.25 * sin(q["t"] * 12.0 + q["phase"])
		var s: float = q["size"] * (0.6 + 0.4 * k) * blink
		draw_circle(q["pos"], s * 2.6, Color(q["col"], 0.22 * k))
		draw_circle(q["pos"], s * 0.7, Color(q["col"], k))
		if q["glint"]:
			var c2 := Color(q["col"], 0.9 * k)
			draw_line(q["pos"] - Vector2(s * 2.4, 0), q["pos"] + Vector2(s * 2.4, 0), c2, 1.5 * size_scale, true)
			draw_line(q["pos"] - Vector2(0, s * 2.4), q["pos"] + Vector2(0, s * 2.4), c2, 1.5 * size_scale, true)
