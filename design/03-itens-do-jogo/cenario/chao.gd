extends SceneTree
## Mars ground texture, 1024x1024, seamless (tiles with no visible edge). Palette colors.
const N := 1024
func noise_img(seed_value: int, freq: float, octaves: int) -> Image:
	var f := FastNoiseLite.new(); f.seed = seed_value; f.frequency = freq; f.fractal_octaves = octaves
	return f.get_seamless_image(N, N)
func _init():
	var base_noise := noise_img(3, 0.004, 4); var patches := noise_img(11, 0.0025, 3); var grain := noise_img(27, 0.05, 2)
	var img := Image.create(N, N, false, Image.FORMAT_RGBA8)
	var c1 := Color("c46a3c"); var c2 := Color("b4532a"); var c3 := Color("9e4426"); var c4 := Color("d9825a")
	for y in N:
		for x in N:
			var b := base_noise.get_pixel(x, y).r; var m := patches.get_pixel(x, y).r; var g := grain.get_pixel(x, y).r
			var c := c2.lerp(c1, smoothstep(0.35, 0.7, b))
			c = c.lerp(c3, smoothstep(0.55, 0.8, m) * 0.55)
			c = c.lerp(c4, smoothstep(0.72, 0.9, b) * 0.35)
			c = c.darkened((g - 0.5) * 0.10)
			img.set_pixel(x, y, c)
	var rng := RandomNumberGenerator.new(); rng.seed = 5
	var shape := noise_img(41, 0.08, 2)
	for i in 150:   # irregular matte pebbles (wrapping at the edge, to avoid creating a seam)
		var p := Vector2(rng.randf() * N, rng.randf() * N); var r := rng.randf_range(3.0, 8.0) if i % 7 else rng.randf_range(10.0, 15.0)
		var top_col := Color("8e3a24").lerp(Color("6e2c22"), rng.randf()); var edge_col := top_col.darkened(0.3)
		for dy in range(-int(r) - 3, int(r) + 4):
			for dx in range(-int(r) - 3, int(r) + 4):
				var px := posmod(int(p.x) + dx, N); var py := posmod(int(p.y) + dy, N)
				var rr := r * (0.75 + 0.5 * shape.get_pixel(px, py).r)
				var d := Vector2(dx, dy * 1.25).length()
				var col := img.get_pixel(px, py)
				if d <= rr - 1.5: col = top_col.lightened(0.12 if dy < -rr * 0.3 else 0.0)
				elif d <= rr: col = edge_col
				elif d <= rr + 2.0 and dy > 0: col = col.darkened(0.18)
				else: continue
				img.set_pixel(px, py, col)
	for i in 9000:  # sand grains
		var px := rng.randi() % N; var py := rng.randi() % N
		img.set_pixel(px, py, img.get_pixel(px, py).lightened(rng.randf_range(0.08, 0.2)) if i % 2 else img.get_pixel(px, py).darkened(0.2))
	img.save_png(OS.get_cmdline_user_args()[0])
	var t := Image.create(N * 2, N * 2, false, Image.FORMAT_RGBA8)   # 2x2 to check for seams
	for k in 4: t.blit_rect(img, Rect2i(0, 0, N, N), Vector2i((k % 2) * N, int(k / 2) * N))
	t.resize(1024, 1024); t.save_png(OS.get_cmdline_user_args()[1]); print("ok"); quit()
