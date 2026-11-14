extends Node
## Cena principal: liga a base 3D (o que se vê) ao HUD (o que se toca).

@onready var base: Node3D = $Base
@onready var hud: CanvasLayer = $Hud


func _ready() -> void:
	hud.base = base
	base.cell_tapped.connect(hud.on_cell_tapped)
	base.mike_tapped.connect(hud.on_mike_tapped)
