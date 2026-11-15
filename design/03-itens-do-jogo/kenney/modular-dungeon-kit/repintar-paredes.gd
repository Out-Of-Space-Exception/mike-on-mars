extends SceneTree
func lum(c): return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b
func region(img, r, target):
	var tot = 0.0; var cnt = 0
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x): tot += lum(img.get_pixel(x,y)); cnt += 1
	var mean = tot/cnt
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var f = clampf(lum(img.get_pixel(x,y))/mean, 0.7, 1.25)
			img.set_pixel(x, y, Color(clampf(target.r*f,0,1), clampf(target.g*f,0,1), clampf(target.b*f,0,1)))
func _init():
	var a = OS.get_cmdline_user_args()
	var img = Image.load_from_file(a[0]); img.convert(Image.FORMAT_RGBA8)
	region(img, Rect2i(160,384,32,128), Color("#E9D2A6"))  # main wall: cream/light stone
	region(img, Rect2i(32,384,32,128), Color("#E8B23A"))   # trim/edge: gold
	region(img, Rect2i(96,384,32,128), Color("#73242A"))   # details: wine
	region(img, Rect2i(224,384,32,128), Color("#A87C2A"))  # shadow/door: dark gold
	print("save ", img.save_png(a[1])); quit()
