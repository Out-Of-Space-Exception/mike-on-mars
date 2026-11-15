class_name PlantRing
extends Control
## The plant icon inside a ring that fills up as it grows. Used in the greenhouse panel and
## floating above the greenhouse, so the child sees what is growing without reading.
## Green while it grows; full and golden when it is ready to harvest.

var icon: Texture2D:
	set(v):
		icon = v
		queue_redraw()
var progress := 0.0:
	set(v):
		progress = clampf(v, 0.0, 1.0)
		queue_redraw()


func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) / 2.0
	var w := r * 0.2                  # ring thickness
	var ring_r := r - 3.0 - w / 2.0
	draw_circle(c, r, Palette.INK, true, -1.0, true)          # dark edge
	draw_circle(c, r - 3.0, Palette.BG, true, -1.0, true)     # wine disc
	draw_arc(c, ring_r, 0.0, TAU, 64, Palette.INK, w, true)   # empty groove
	if progress > 0.0:
		var color := Palette.GOLD if progress >= 1.0 else Palette.PLANT
		var a0 := -PI / 2.0           # starts at the top and goes clockwise
		var a1 := a0 + TAU * progress
		draw_arc(c, ring_r, a0, a1, maxi(8, int(64 * progress)), color, w, true)
		draw_circle(c + Vector2.from_angle(a0) * ring_r, w / 2.0, color, true, -1.0, true)   # round ends
		draw_circle(c + Vector2.from_angle(a1) * ring_r, w / 2.0, color, true, -1.0, true)
	if icon:
		var s := (ring_r - w / 2.0) * 2.0 * 0.92
		draw_texture_rect(icon, Rect2(c - Vector2(s, s) / 2.0, Vector2(s, s)), false)
