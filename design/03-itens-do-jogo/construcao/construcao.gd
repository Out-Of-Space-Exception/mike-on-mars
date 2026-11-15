extends Node3D
## Construction site: little blocks get stacked while the building is being made.
## APPLIES TO ALL BUILDINGS in the SITE_ITEMS list (greenhouse, solar panel, nuclear battery/RTG, MOXIE, antenna,
## Ingenuity pad and string lights). The pot and the flag use the short version: place() (PLACE_ITEMS list),
## with Mike playing the "colocar" animation (crouches and puts it on the ground, 0.6 s) and the item popping from the ground, no blocks.
## At the end, the blocks vanish and the building "sprouts" from the ground (flattened -> normal size, with a bounce).
## Usage (Dev):
##   var site := preload("res://.../construcao.gd").new()
##   add_child(site); site.position = pos
##   site.start(building_scene, duration_in_seconds, plot_size)
##   Mike: turn to the site and play the "construir" animation (mike.glb) while site.is_building == true.

signal finished(building: Node3D)

## Keys of ITEMS in jogo/autoload/state.gd that go through the site (Mike hammering + blocks + rising).
const SITE_ITEMS := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad", "lights"]
## Small items: short version, no blocks (Mike plays "colocar").
const PLACE_ITEMS := ["flag", "pot"]

## Short version: waits for Mike to crouch (0.35 s) and the item pops from the ground with a bounce and a little dust.
func place(scene: PackedScene) -> void:
	is_building = true
	await get_tree().create_timer(0.35).timeout
	var c: Node3D = scene.instantiate()
	add_child(c)
	var final_scale := c.scale
	c.scale = final_scale * 0.01
	var tw := c.create_tween()
	tw.tween_property(c, "scale", final_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_dust(10)
	is_building = false
	finished.emit(c)

const COLORS := [Color("D96941"), Color("F2D091"), Color("E8B23A"), Color("73242A")]
const BLOCK := 0.35

var is_building := false
var _blocks: Array[MeshInstance3D] = []

func start(scene: PackedScene, duration: float, plot_size := Vector2(1.5, 1.5)) -> void:
	is_building = true
	var n := 12
	var mesh := BoxMesh.new(); mesh.size = Vector3.ONE * BLOCK
	for i in n:
		var b := MeshInstance3D.new(); b.mesh = mesh
		var mat := StandardMaterial3D.new(); mat.albedo_color = COLORS[i % COLORS.size()]; mat.roughness = 0.8
		b.material_override = mat
		var col := i % 4; var row := i / 4
		b.position = Vector3((col % 2 - 0.5) * plot_size.x * 0.5, BLOCK * 0.5 + row * BLOCK, (col / 2 - 0.5) * plot_size.y * 0.5)
		b.rotation.y = randf_range(-0.3, 0.3)
		b.scale = Vector3.ZERO
		add_child(b); _blocks.append(b)
		# each block drops from above and bounces into place
		var t := create_tween()
		t.tween_interval(duration * float(i) / n)
		t.tween_callback(func(): b.position.y += 1.2; b.scale = Vector3.ONE)
		t.tween_property(b, "position:y", b.position.y, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(duration).timeout
	_finish(scene)

func _finish(scene: PackedScene) -> void:
	# blocks shrink and vanish
	for b in _blocks:
		create_tween().tween_property(b, "scale", Vector3.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.2).timeout
	for b in _blocks: b.queue_free()
	_blocks.clear()
	# the building appears ("rising" effect)
	var c: Node3D = scene.instantiate()
	add_child(c)
	var final_scale := c.scale
	c.scale = Vector3(final_scale.x, 0.01, final_scale.z)
	var tw := c.create_tween()
	tw.tween_property(c, "scale", final_scale, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_dust()
	is_building = false
	finished.emit(c)

func _dust(amount := 24) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true; p.amount = amount; p.lifetime = 0.6; p.explosiveness = 1.0
	p.direction = Vector3.UP; p.spread = 80.0; p.initial_velocity_min = 1.0; p.initial_velocity_max = 2.5
	p.gravity = Vector3(0, -2, 0); p.scale_amount_min = 0.15; p.scale_amount_max = 0.3
	var m := SphereMesh.new(); m.radius = 0.15; m.height = 0.3
	var mat := StandardMaterial3D.new(); mat.albedo_color = Color("F2D091"); m.material = mat
	p.mesh = m
	add_child(p); p.emitting = true
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)
