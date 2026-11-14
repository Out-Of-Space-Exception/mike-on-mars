extends SceneTree
## Textura de chão de Marte, 1024x1024, sem emenda (repete sem aparecer borda). Cores da paleta.
const N := 1024
func ruido(semente: int, freq: float, oitavas: int) -> Image:
	var f := FastNoiseLite.new(); f.seed = semente; f.frequency = freq; f.fractal_octaves = oitavas
	return f.get_seamless_image(N, N)
func _init():
	var base := ruido(3, 0.004, 4); var manchas := ruido(11, 0.0025, 3); var grao := ruido(27, 0.05, 2)
	var img := Image.create(N, N, false, Image.FORMAT_RGBA8)
	var c1 := Color("c46a3c"); var c2 := Color("b4532a"); var c3 := Color("9e4426"); var c4 := Color("d9825a")
	for y in N:
		for x in N:
			var b := base.get_pixel(x, y).r; var m := manchas.get_pixel(x, y).r; var g := grao.get_pixel(x, y).r
			var c := c2.lerp(c1, smoothstep(0.35, 0.7, b))
			c = c.lerp(c3, smoothstep(0.55, 0.8, m) * 0.55)
			c = c.lerp(c4, smoothstep(0.72, 0.9, b) * 0.35)
			c = c.darkened((g - 0.5) * 0.10)
			img.set_pixel(x, y, c)
	var rng := RandomNumberGenerator.new(); rng.seed = 5
	var forma := ruido(41, 0.08, 2)
	for i in 150:   # pedrinhas irregulares e foscas (com volta na borda, para não criar emenda)
		var p := Vector2(rng.randf() * N, rng.randf() * N); var r := rng.randf_range(3.0, 8.0) if i % 7 else rng.randf_range(10.0, 15.0)
		var topo := Color("8e3a24").lerp(Color("6e2c22"), rng.randf()); var borda := topo.darkened(0.3)
		for dy in range(-int(r) - 3, int(r) + 4):
			for dx in range(-int(r) - 3, int(r) + 4):
				var px := posmod(int(p.x) + dx, N); var py := posmod(int(p.y) + dy, N)
				var rr := r * (0.75 + 0.5 * forma.get_pixel(px, py).r)
				var d := Vector2(dx, dy * 1.25).length()
				var cor := img.get_pixel(px, py)
				if d <= rr - 1.5: cor = topo.lightened(0.12 if dy < -rr * 0.3 else 0.0)
				elif d <= rr: cor = borda
				elif d <= rr + 2.0 and dy > 0: cor = cor.darkened(0.18)
				else: continue
				img.set_pixel(px, py, cor)
	for i in 9000:  # grãos de areia
		var px := rng.randi() % N; var py := rng.randi() % N
		img.set_pixel(px, py, img.get_pixel(px, py).lightened(rng.randf_range(0.08, 0.2)) if i % 2 else img.get_pixel(px, py).darkened(0.2))
	img.save_png(OS.get_cmdline_user_args()[0])
	var t := Image.create(N * 2, N * 2, false, Image.FORMAT_RGBA8)   # 2x2 para ver se tem emenda
	for k in 4: t.blit_rect(img, Rect2i(0, 0, N, N), Vector2i((k % 2) * N, int(k / 2) * N))
	t.resize(1024, 1024); t.save_png(OS.get_cmdline_user_args()[1]); print("ok"); quit()
