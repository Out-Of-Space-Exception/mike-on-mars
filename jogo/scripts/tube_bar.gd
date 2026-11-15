class_name TubeBar
extends Control
## Bar shaped like a glass tube (looks 3D): transparent dark glass, colored liquid with
## shadow at the bottom and shine on top, and a reflection on the glass. The liquid slides to the new value.

var value := 0.0:          # 0 to 100
	set(v):
		value = clampf(v, 0.0, 100.0)
var cap := 100.0:          # above the cap, the tube is locked (striped)
	set(c):
		if not is_equal_approx(c, cap):
			cap = clampf(c, 0.0, 100.0)
			queue_redraw()
var color := Color.WHITE:
	set(c):
		color = c
		queue_redraw()
var _shown := -1.0


func _process(delta: float) -> void:
	var goal := value
	if _shown < 0.0:
		_shown = goal
	if absf(_shown - goal) > 0.05:
		_shown = lerpf(_shown, goal, 1.0 - exp(-delta * 8.0))
		queue_redraw()


func _cap(c: Color, top := true, bottom := true) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = c
	var r := int(size.y / 2.0)
	b.corner_radius_top_left = r if top else 0
	b.corner_radius_top_right = r if top else 0
	b.corner_radius_bottom_left = r if bottom else 0
	b.corner_radius_bottom_right = r if bottom else 0
	b.corner_detail = 8
	b.anti_aliasing = true
	return b


func _draw() -> void:
	var h := size.y
	# Glass: dark and transparent, with a light border.
	var glass := _cap(Color(0.12, 0.03, 0.05, 0.62))
	glass.border_color = Color(1, 1, 1, 0.35)
	glass.set_border_width_all(2)
	draw_style_box(glass, Rect2(Vector2.ZERO, size))
	# Liquid: the bar color, darker at the bottom and shiny on top.
	var w := (size.x - 6.0) * _shown / 100.0
	if w > 2.0:
		w = maxf(w, h - 6.0)
		var fill := Rect2(Vector2(3, 3), Vector2(w, h - 6.0))
		draw_style_box(_cap(color), fill)
		var low := Rect2(fill.position + Vector2(0, fill.size.y * 0.55), Vector2(fill.size.x, fill.size.y * 0.45))
		draw_style_box(_cap(color.darkened(0.22), false, true), low)
		if fill.size.x > h:
			draw_style_box(_cap(Color(1, 1, 1, 0.38)), Rect2(fill.position + Vector2(h * 0.35, 3.0), Vector2(fill.size.x - h * 0.7, fill.size.y * 0.26)))
	# Above the cap (Mike's House is still small): the tube is locked, dark and striped.
	if cap < 99.5:
		var x0 := 3.0 + (size.x - 6.0) * cap / 100.0
		var lock := Rect2(Vector2(x0, 3.0), Vector2(size.x - 3.0 - x0, h - 6.0))
		draw_style_box(_cap(Color(0.05, 0.0, 0.02, 0.72), false, false), Rect2(lock.position, lock.size - Vector2(h * 0.5, 0.0)))
		draw_style_box(_cap(Color(0.05, 0.0, 0.02, 0.72)), Rect2(lock.end - Vector2(h - 6.0, h - 6.0), Vector2(h - 6.0, h - 6.0)))
		var step := 12.0
		var x := x0 + 4.0
		while x < size.x - h * 0.5:
			draw_line(Vector2(x, h - 5.0), Vector2(minf(x + h * 0.5, size.x - h * 0.5), 5.0), Color(1, 1, 1, 0.16), 3.0, true)
			x += step
		draw_line(Vector2(x0, 2.0), Vector2(x0, h - 2.0), Color(1, 1, 1, 0.75), 3.0)
	# Glass reflection on top of everything.
	draw_style_box(_cap(Color(1, 1, 1, 0.12)), Rect2(Vector2(h * 0.5, 3.0), Vector2(maxf(size.x - h, 0.0), h * 0.2)))
