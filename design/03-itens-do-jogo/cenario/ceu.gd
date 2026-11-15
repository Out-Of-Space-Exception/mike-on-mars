extends SceneTree
## Panoramic Mars sky (2048x1024, equirectangular): caramel gradient, dust, Sun, Phobos, Deimos and little stars.
const LW := 4096; const LH := 2048
func dir_px(az_deg: float, el_deg: float) -> Vector2:
	return Vector2(fposmod(az_deg, 360.0) / 360.0 * LW, (0.5 - el_deg / 180.0) * LH)
func _init():
	var img := Image.create(LW, LH, false, Image.FORMAT_RGBA8)
	var f := FastNoiseLite.new(); f.seed = 9; f.frequency = 0.002; f.fractal_octaves = 4
	var nuv := f.get_seamless_image(LW, LH)
	var top_col := Color("c9845a"); var mid_col := Color("e0a46e"); var horizon_col := Color("f2c58e"); var ground_col := Color("b4532a")
	for y in LH:
		var el := (0.5 - float(y) / LH) * 180.0
		var c: Color
		if el >= 0.0:
			var t := el / 90.0
			c = horizon_col.lerp(mid_col, smoothstep(0.0, 0.25, t)).lerp(top_col, smoothstep(0.25, 1.0, t))
		else:
			c = horizon_col.darkened(0.08)
		for x in LW:
			var cc := c
			if el > 2.0 and el < 60.0:   # dust bands
				var n := nuv.get_pixel(x, y).r
				var band := smoothstep(0.55, 0.75, n) * (1.0 - smoothstep(25.0, 60.0, el)) * 0.45
				cc = cc.lerp(Color("f6dcb4"), band)
			img.set_pixel(x, y, cc)
	# Small Sun with glow
	_disc(img, dir_px(76, 15), 70.0, Color(1, 0.97, 0.88), 0.0, true)
	_disc(img, dir_px(76, 15), 9.0, Color(1, 0.99, 0.95), 1.0, false)
	# Phobos (larger, irregular) and Deimos (small)
	_moon(img, dir_px(103, 12), 11.0, 1.25, 3)
	_moon(img, dir_px(92, 18), 5.0, 1.0, 1)
	# little golden stars up high
	var rng := RandomNumberGenerator.new(); rng.seed = 21
	for i in 260:
		var p := dir_px(rng.randf() * 360.0, rng.randf_range(9.0, 85.0)); var s := rng.randf_range(1.2, 2.6)
		_sparkle(img, p, s, Color("fff4d6") if i % 3 else Color("e8b23a"))
	img.save_png(OS.get_cmdline_user_args()[0]); print("ok"); quit()
func _disc(img: Image, c: Vector2, r: float, col: Color, hard: float, halo: bool) -> void:
	for dy in range(-int(r), int(r) + 1):
		for dx in range(-int(r), int(r) + 1):
			var d := Vector2(dx, dy).length(); if d > r: continue
			var x := posmod(int(c.x) + dx, LW); var y := clampi(int(c.y) + dy, 0, LH - 1)
			var a := (1.0 - d / r); a = a * a * 0.8 if halo else 1.0
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(col, clampf(a, 0, 1)))
func _moon(img: Image, c: Vector2, r: float, stretch: float, craters: int) -> void:
	var base_col := Color("8a7f78"); var light_col := Color("b8ada4")
	for dy in range(-int(r) - 1, int(r) + 2):
		for dx in range(-int(r * stretch) - 1, int(r * stretch) + 2):
			var d := Vector2(dx / stretch, dy).length(); if d > r: continue
			var x := posmod(int(c.x) + dx, LW); var y := int(c.y) + dy
			var t := clampf((Vector2(dx / stretch, dy) + Vector2(r, r) * 0.4).length() / (r * 1.4), 0, 1)
			img.set_pixel(x, y, light_col.lerp(base_col, t))
	var rng := RandomNumberGenerator.new(); rng.seed = int(c.x)
	for i in craters:
		var p := c + Vector2(rng.randf_range(-r * 0.5, r * 0.5) * stretch, rng.randf_range(-r * 0.4, r * 0.4)); var cr := r * rng.randf_range(0.15, 0.3)
		for dy in range(-int(cr), int(cr) + 1):
			for dx in range(-int(cr), int(cr) + 1):
				if Vector2(dx, dy).length() <= cr: var x := posmod(int(p.x) + dx, LW); img.set_pixel(x, int(p.y) + dy, img.get_pixel(x, int(p.y) + dy).darkened(0.25))
func _sparkle(img: Image, c: Vector2, s: float, col: Color) -> void:
	for k in range(-int(s * 2.5), int(s * 2.5) + 1):
		var a := 1.0 - absf(k) / (s * 2.5)
		for p in [Vector2(c.x + k, c.y), Vector2(c.x, c.y + k)]:
			var x := posmod(int(p.x), LW); var y := clampi(int(p.y), 0, LH - 1)
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(col, a * 0.9))
	_disc(img, c, s, col, 1.0, false)
