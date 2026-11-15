extends Node
## Main scene: connects the 3D base (what you see) to the HUD (what you touch).

@onready var base: Node3D = $Base
@onready var hud: CanvasLayer = $Hud


func _ready() -> void:
	hud.base = base
	base.cell_tapped.connect(hud.on_cell_tapped)
	base.mike_tapped.connect(hud.on_mike_tapped)
