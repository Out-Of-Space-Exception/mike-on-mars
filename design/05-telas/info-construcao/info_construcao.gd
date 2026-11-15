extends Control
## Building info panel (Design 05). Opens when tapping a button in the build bar.
## Shows name, model, effects (top bar icons + number) and a short sentence.
## Buttons: "Close" (returns with the build bar open) and "Build -N ⚡".
## The numbers come from State.ITEMS (jogo/autoload/state.gd): if the game changes, the panel changes with it.
## How to hook it up in hud.gd: see the LEIAME.md in this folder.

signal build_requested(type: String)

## Items that open this panel (the others go straight to construction, as today).
const WITH_INFO := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad"]
const FOLDER := "res://ui/info-construcao/"   # copy the images from this design folder to here
const IMG := {"greenhouse": "item-estufa.png", "solar": "item-solar.png", "rtg": "item-rtg.png",
	"moxie": "item-moxie.png", "antenna": "item-antena.png", "pad": "item-pista.png"}
const ICONS := {"energy": "res://ui/icons/ic-energia.svg", "oxygen": "res://ui/icons/ic-oxigenio.svg"}
const GREEN := Color("6cc04a")
const WINE_LIGHT := Color("4a2226")

var _type := ""
var _title: Label
var _image: TextureRect
var _effects: VBoxContainer
var _text: Label
var _build_button: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var dim := ColorRect.new(); dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(dim)
	dim.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: close())
	var center_box := CenterContainer.new(); center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_box.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(center_box)
	var panel := PanelContainer.new(); panel.custom_minimum_size = Vector2(900, 0)
	panel.add_theme_stylebox_override("panel", Palette.plate()); center_box.add_child(panel)
	var col := VBoxContainer.new(); col.add_theme_constant_override("separation", 18); panel.add_child(col)
	# title on the cream plaque of the card frame
	var plaque := TextureRect.new(); plaque.texture = load(FOLDER + "placa-titulo.png")
	plaque.custom_minimum_size = Vector2(700, 92); plaque.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plaque.stretch_mode = TextureRect.STRETCH_SCALE; plaque.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(plaque)
	_title = _label(42, Palette.BG); _title.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; _title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plaque.add_child(_title)
	# model + effects + text
	var row := HBoxContainer.new(); row.add_theme_constant_override("separation", 28); col.add_child(row)
	var box := PanelContainer.new(); box.custom_minimum_size = Vector2(280, 270)
	var sb := StyleBoxFlat.new(); sb.bg_color = WINE_LIGHT; sb.border_color = Palette.GOLD
	sb.set_border_width_all(3); sb.set_corner_radius_all(18); box.add_theme_stylebox_override("panel", sb)
	row.add_child(box)
	_image = TextureRect.new(); _image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; box.add_child(_image)
	var right_col := VBoxContainer.new(); right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 12); row.add_child(right_col)
	_effects = VBoxContainer.new(); _effects.add_theme_constant_override("separation", 10); right_col.add_child(_effects)
	_text = _label(26, Palette.TEXT); _text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; right_col.add_child(_text)
	# buttons
	var buttons := HBoxContainer.new(); buttons.add_theme_constant_override("separation", 40)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER; col.add_child(buttons)
	var close_button := _button(tr("INFO_CLOSE")); close_button.pressed.connect(close); buttons.add_child(close_button)
	_build_button = _button(""); _build_button.icon = load(ICONS.energy)
	_build_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT   # number before the icon: "Build -10 ⚡"
	_build_button.add_theme_color_override("icon_normal_color", Palette.GOLD)
	_build_button.pressed.connect(func(): var t := _type; close(); build_requested.emit(t))
	buttons.add_child(_build_button)
	# moon ornament (card frame)
	var orn := TextureRect.new(); orn.texture = load(FOLDER + "ornamento-luas.png")
	orn.custom_minimum_size = Vector2(520, 34); orn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	orn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; orn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(orn)

func open(type: String) -> void:
	_type = type
	var def: Dictionary = State.ITEMS[type]
	_title.text = tr(def.name)
	_image.texture = load(FOLDER + IMG[type])
	_text.text = tr("INFO_" + def.name.trim_prefix("B_"))
	for c in _effects.get_children(): c.queue_free()
	if type == "greenhouse":
		_effect("energy", def.get("energy_when_planted", 0.0), "INFO_WHEN_PLANTING")
		_effect("oxygen", State.PLANT_OXYGEN, "INFO_EACH_PLANT", true)
	else:
		if def.has("energy"): _effect("energy", def.energy, "INFO_ENERGY_SOL")
		if def.has("oxygen"): _effect("oxygen", def.oxygen, "INFO_OXYGEN_SOL")
		if def.has("card"): _effect("card", 1, "INFO_CARD")
	_build_button.text = "%s  -%d" % [tr("INFO_BUILD"), def.cost]
	_build_button.disabled = State.build_block_reason(type) != ""
	visible = true

func close() -> void:
	visible = false   # the build bar stays open underneath

func _effect(kind: String, value: float, key: String, sign_only := false) -> void:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new(); sb.bg_color = WINE_LIGHT; sb.set_corner_radius_all(12)
	sb.content_margin_left = 14; sb.content_margin_right = 14; sb.content_margin_top = 8; sb.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new(); h.add_theme_constant_override("separation", 14); p.add_child(h)
	var ic := TextureRect.new(); ic.custom_minimum_size = Vector2(40, 40)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if kind == "card":
		ic.texture = load(FOLDER + "ic-carta.png"); ic.modulate = Palette.GOLD
	else:
		ic.texture = load(ICONS[kind]); ic.modulate = Palette.BAR[kind]
	h.add_child(ic)
	var sign := "+" if value >= 0 else "-"
	var n := _label(36, GREEN if value >= 0 else Palette.ALERT)
	n.text = sign if sign_only else "%s%s" % [sign, str(snappedf(absf(value), 0.1)).trim_suffix(".0")]
	h.add_child(n)
	var l := _label(26, Palette.TEXT); l.text = tr(key); h.add_child(l)
	_effects.add_child(p)

func _label(size_px: int, col: Color) -> Label:
	var l := Label.new(); l.add_theme_font_size_override("font_size", size_px); l.add_theme_color_override("font_color", col)
	return l

func _button(label_text: String) -> Button:
	var b := Button.new(); b.text = label_text; b.custom_minimum_size = Vector2(370, 68)
	b.add_theme_font_size_override("font_size", 32)
	return b   # the game theme already paints the button terracotta, as in the build bar
