class_name FloatingDust
extends CPUParticles3D
## Golden and cream dust slowly floating in the air of the base (a playful scenery effect).
## Usage: add it to the base scene, in the center. Adjust `area` to the size of the map.

@export var area := Vector3(30.0, 6.0, 30.0)
@export var particle_count := 160

func _ready() -> void:
	amount = particle_count
	lifetime = 9.0
	preprocess = 9.0
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emission_box_extents = area / 2.0
	position.y = area.y / 2.0
	direction = Vector3(1.0, 0.25, 0.3)
	spread = 35.0
	gravity = Vector3(0.0, 0.05, 0.0)
	initial_velocity_min = 0.15
	initial_velocity_max = 0.45
	scale_amount_min = 0.5
	scale_amount_max = 1.4
	var colors := Gradient.new()
	colors.set_color(0, Color(0.95, 0.82, 0.57, 0.0))
	colors.add_point(0.2, Color(0.91, 0.70, 0.23, 0.9))
	colors.add_point(0.8, Color(0.95, 0.82, 0.57, 0.7))
	colors.set_color(colors.get_point_count() - 1, Color(0.95, 0.82, 0.57, 0.0))
	color_ramp = colors
	var m := QuadMesh.new(); m.size = Vector2(0.08, 0.08)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.vertex_color_use_as_albedo = true
	mat.emission_enabled = true; mat.emission = Color(0.91, 0.70, 0.23); mat.emission_energy_multiplier = 0.6
	m.material = mat
	mesh = m
