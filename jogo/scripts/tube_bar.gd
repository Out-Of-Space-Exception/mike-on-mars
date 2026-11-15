class_name TubeBar
extends Control
## Barra em forma de tubo de vidro (parece 3D): vidro escuro transparente, líquido colorido com
## sombra embaixo e brilho em cima, e um reflexo no vidro. O líquido desliza até o valor novo.

var value := 0.0:          # 0 a 100
	set(v):
		value = clampf(v, 0.0, 100.0)
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
	# Vidro: escuro e transparente, com borda clara.
	var glass := _cap(Color(0.12, 0.03, 0.05, 0.62))
	glass.border_color = Color(1, 1, 1, 0.35)
	glass.set_border_width_all(2)
	draw_style_box(glass, Rect2(Vector2.ZERO, size))
	# Líquido: a cor da barra, mais escura embaixo e com brilho em cima.
	var w := (size.x - 6.0) * _shown / 100.0
	if w > 2.0:
		w = maxf(w, h - 6.0)
		var fill := Rect2(Vector2(3, 3), Vector2(w, h - 6.0))
		draw_style_box(_cap(color), fill)
		var low := Rect2(fill.position + Vector2(0, fill.size.y * 0.55), Vector2(fill.size.x, fill.size.y * 0.45))
		draw_style_box(_cap(color.darkened(0.22), false, true), low)
		if fill.size.x > h:
			draw_style_box(_cap(Color(1, 1, 1, 0.38)), Rect2(fill.position + Vector2(h * 0.35, 3.0), Vector2(fill.size.x - h * 0.7, fill.size.y * 0.26)))
	# Reflexo do vidro por cima de tudo.
	draw_style_box(_cap(Color(1, 1, 1, 0.12)), Rect2(Vector2(h * 0.5, 3.0), Vector2(maxf(size.x - h, 0.0), h * 0.2)))
