class_name Plate
extends PanelContainer
## Panel that looks like a part of the base: a metal plate with 4 screws in the corners.
## With `stripe`, it gets the striped hazard band on top (used only in event notices).
## (pesquisa/anti-ai-slop.md, item 4: a shape with a purpose, not the same rectangle everywhere)

@export var stripe := false


func _ready() -> void:
	add_theme_stylebox_override("panel", Palette.plate(stripe))
	resized.connect(queue_redraw)


func _draw() -> void:
	var r := 7.0
	var inset := 16.0
	var top := inset + (Palette.STRIPE_H if stripe else 0.0)
	for p in [Vector2(inset, top), Vector2(size.x - inset, top), Vector2(inset, size.y - inset), Vector2(size.x - inset, size.y - inset)]:
		draw_circle(p, r, Palette.RIVET)
		draw_circle(p + Vector2(-1.5, -1.5), r * 0.45, Palette.RIVET.lightened(0.35))
	if stripe:
		# Hazard band: diagonal yellow and dark stripes.
		var w := 26.0
		var x := -Palette.STRIPE_H
		while x < size.x:
			var poly := PackedVector2Array([Vector2(x, 0), Vector2(x + w, 0), Vector2(x + w + Palette.STRIPE_H, Palette.STRIPE_H), Vector2(x + Palette.STRIPE_H, Palette.STRIPE_H)])
			draw_colored_polygon(_clip(poly), Palette.GOLD)
			x += w * 2.0
		draw_rect(Rect2(0, Palette.STRIPE_H - 3, size.x, 3), Palette.BG.darkened(0.5))


func _clip(poly: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(Vector2(clampf(p.x, 0.0, size.x), p.y))
	return out
