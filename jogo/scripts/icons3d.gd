class_name Icons3D
extends RefCounted
## Ícones em 3D, feitos pelo time em código (estilo Kenney: formas grossas, cores chapadas, luz de cima).
## Cada ícone é montado com formas simples e desenhado uma vez numa SubViewport; o botão usa a textura.

const BG := Color("73242a")
const GOLD := Color("e8b23a")
const GOLD_DARK := Color("a87c2a")
const OXYGEN := Color("7cc6e0")
const SHIELD := Color("3b8fd6")
const STEEL := Color("b8bec6")
const STEEL_DARK := Color("5a5f66")
const WOOD := Color("8a5a3c")
const PAPER := Color("f6e6c4")
const TERRA := Color("d96941")


## Desenha "model" (um Node3D com ~1 de altura, no meio) numa textura quadrada.
## spin = continua desenhando (para quem gira na tela); senão desenha uma vez só.
static func render(host: Node, model: Node3D, px := 160, cam_size := 1.7, spin := false, view := Vector3(1.0, 0.9, 2.2)) -> ViewportTexture:
	var vp := SubViewport.new()
	vp.size = Vector2i(px, px)
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if spin else SubViewport.UPDATE_ONCE
	host.add_child(vp)
	vp.add_child(model)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(1.0, 0.95, 0.9)
	env.environment.ambient_light_energy = 0.65
	vp.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	key.light_energy = 1.15
	vp.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-15.0, -150.0, 0.0)
	fill.light_energy = 0.35
	vp.add_child(fill)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = cam_size
	vp.add_child(cam)
	cam.position = view.normalized() * 6.0
	cam.look_at(Vector3.ZERO)
	return vp.get_texture()


static func mat(color: Color, rough := 0.55, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metal
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


static func part(mesh: Mesh, color: Color, pos := Vector3.ZERO, rot := Vector3.ZERO, rough := 0.55, metal := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(color, rough, metal)
	mi.position = pos
	mi.rotation_degrees = rot
	return mi


static func cyl(r: float, h: float, top := -1.0) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r if top < 0.0 else top
	c.bottom_radius = r
	c.height = h
	c.radial_segments = 32
	return c


static func box(x: float, y: float, z: float) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3(x, y, z)
	return b


static func ball(r: float, half := false) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r if half else r * 2.0
	s.is_hemisphere = half
	return s


## Uma forma 2D (y para cima) virando peça 3D com espessura.
static func extrude(poly: PackedVector2Array, depth: float, color: Color) -> MeshInstance3D:
	var area := 0.0
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		area += a.x * b.y - b.x * a.y
	var out_sign := 1.0 if area > 0.0 else -1.0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hz := depth / 2.0
	var tris := Geometry2D.triangulate_polygon(poly)
	for face in [1.0, -1.0]:
		for i in tris.size():
			var p := poly[tris[i]]
			st.set_normal(Vector3(0, 0, face))
			st.add_vertex(Vector3(p.x, p.y, hz * face))
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		var d := (b - a).normalized()
		var n := Vector3(d.y, -d.x, 0.0) * out_sign
		for v in [Vector3(a.x, a.y, hz), Vector3(b.x, b.y, hz), Vector3(b.x, b.y, -hz), Vector3(a.x, a.y, hz), Vector3(b.x, b.y, -hz), Vector3(a.x, a.y, -hz)]:
			st.set_normal(n)
			st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var m := mat(color)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	return mi


# ───────────── Os ícones ─────────────
static func energy() -> Node3D:
	var root := Node3D.new()
	var bolt := PackedVector2Array([Vector2(0.14, 0.62), Vector2(-0.32, -0.04), Vector2(-0.03, -0.04), Vector2(-0.16, -0.62), Vector2(0.32, 0.07), Vector2(0.03, 0.07)])
	root.add_child(extrude(bolt, 0.26, GOLD))
	return root


static func oxygen() -> Node3D:
	var root := Node3D.new()
	root.add_child(part(cyl(0.27, 0.72), OXYGEN, Vector3(0, -0.12, 0)))
	root.add_child(part(ball(0.27, true), OXYGEN, Vector3(0, 0.24, 0)))
	root.add_child(part(cyl(0.285, 0.12), Color.WHITE, Vector3(0, -0.05, 0)))
	root.add_child(part(cyl(0.09, 0.16), STEEL, Vector3(0, 0.56, 0), Vector3.ZERO, 0.3, 0.6))
	root.add_child(part(box(0.3, 0.06, 0.06), STEEL_DARK, Vector3(0, 0.64, 0)))
	root.rotation_degrees.z = -12.0
	return root


static func shield() -> Node3D:
	var root := Node3D.new()
	var pts := [Vector2(64, 8), Vector2(110, 24), Vector2(110, 56), Vector2(106, 78), Vector2(95, 98), Vector2(80, 113), Vector2(64, 122),
		Vector2(48, 113), Vector2(33, 98), Vector2(22, 78), Vector2(18, 56), Vector2(18, 24)]
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for p in pts:
		var q := Vector2((p.x - 64.0) / 128.0 * 1.25, (64.0 - p.y) / 128.0 * 1.25)
		outer.append(q)
		inner.append(q * 0.72 + Vector2(0, 0.02))
	root.add_child(extrude(outer, 0.18, SHIELD))
	var face := extrude(inner, 0.08, SHIELD.lightened(0.35))
	face.position.z = 0.1
	root.add_child(face)
	return root


static func hammer() -> Node3D:
	var root := Node3D.new()
	root.add_child(part(cyl(0.065, 1.0), WOOD, Vector3(0, -0.1, 0)))
	root.add_child(part(box(0.62, 0.22, 0.22), STEEL, Vector3(0, 0.42, 0), Vector3.ZERO, 0.35, 0.5))
	root.add_child(part(box(0.12, 0.26, 0.26), STEEL_DARK, Vector3(-0.3, 0.42, 0), Vector3.ZERO, 0.35, 0.5))
	root.rotation_degrees.z = -35.0
	return root


static func tube() -> Node3D:
	var root := Node3D.new()
	root.add_child(part(cyl(0.17, 0.72), Color(0.82, 0.93, 0.97, 0.5), Vector3.ZERO, Vector3.ZERO, 0.1))
	root.add_child(part(ball(0.12), Color("b4532a"), Vector3(0, -0.2, 0)))
	root.add_child(part(ball(0.08), Color("8a3a22"), Vector3(0.05, -0.05, 0.02)))
	root.add_child(part(cyl(0.2, 0.13), GOLD, Vector3(0, 0.42, 0), Vector3.ZERO, 0.3, 0.6))
	root.add_child(part(cyl(0.2, 0.13), GOLD, Vector3(0, -0.42, 0), Vector3.ZERO, 0.3, 0.6))
	root.rotation_degrees.z = -25.0
	return root


static func cards(frames: Array) -> Node3D:
	var root := Node3D.new()
	var angles := [-18.0, 0.0, 18.0]
	for i in frames.size():
		var card := Node3D.new()
		card.rotation_degrees.z = angles[i % 3]
		card.position = Vector3((i - 1) * 0.22, -0.05 + absf(i - 1) * -0.04, i * 0.03)
		var back := part(box(0.6, 0.72, 0.03), PAPER)
		card.add_child(back)
		var front := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(0.6, 0.72)
		front.mesh = q
		var m := StandardMaterial3D.new()
		m.albedo_texture = frames[i]
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		front.material_override = m
		front.position.z = 0.017
		card.add_child(front)
		root.add_child(card)
	return root


static func camera() -> Node3D:
	var root := Node3D.new()
	root.add_child(part(box(0.92, 0.58, 0.36), Color("3a3f47")))
	root.add_child(part(box(0.94, 0.14, 0.38), TERRA, Vector3(0, 0.2, 0)))
	root.add_child(part(cyl(0.22, 0.2), Color("1c1c1c"), Vector3(0, -0.03, 0.24), Vector3(90, 0, 0)))
	root.add_child(part(cyl(0.14, 0.04), Color("4aa3d8"), Vector3(0, -0.03, 0.35), Vector3(90, 0, 0), 0.1))
	root.add_child(part(cyl(0.07, 0.07), Color("bf2a2a"), Vector3(0.3, 0.33, 0)))
	root.add_child(part(box(0.2, 0.12, 0.12), Color.WHITE, Vector3(-0.28, 0.35, 0)))
	return root


static func gear() -> Node3D:
	var root := Node3D.new()
	var body := Node3D.new()
	body.rotation_degrees.x = 90.0
	root.add_child(body)
	body.add_child(part(cyl(0.4, 0.2), STEEL, Vector3.ZERO, Vector3.ZERO, 0.35, 0.55))
	for i in 8:
		var a := TAU * i / 8.0
		body.add_child(part(box(0.18, 0.2, 0.18), STEEL, Vector3(cos(a) * 0.45, 0, sin(a) * 0.45), Vector3(0, -rad_to_deg(a), 0), 0.35, 0.55))
	body.add_child(part(cyl(0.15, 0.22), STEEL_DARK, Vector3.ZERO, Vector3.ZERO, 0.4, 0.4))
	return root


static func flag(texture: Texture2D) -> Node3D:
	var root := Node3D.new()
	root.add_child(part(cyl(0.035, 1.1), STEEL, Vector3(-0.4, -0.05, 0), Vector3.ZERO, 0.3, 0.6))
	root.add_child(part(ball(0.06), GOLD, Vector3(-0.4, 0.52, 0)))
	var cloth := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.78, 0.52)
	cloth.mesh = q
	var m := StandardMaterial3D.new()
	m.albedo_texture = texture
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	cloth.material_override = m
	cloth.position = Vector3(0.0, 0.22, 0)
	cloth.rotation_degrees.y = -12.0
	root.add_child(cloth)
	return root
