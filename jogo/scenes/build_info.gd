extends Control
## Building info panel (based on Thais's info panel, design/05-telas/info-construcao/).
## Opens when an item in the Build menu is tapped: the building spinning 360°, its name, a short line
## about what it does, how much it makes per sol and a big BUILD button. The red X in the corner closes it.
## The numbers come from State.ITEMS, so the panel changes when the game does.

signal build_pressed(type: String)

const WITH_INFO := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad", "flag", "lights", "pot", "shelf"]
const GREEN := Color("9be27a")
const RED := Color("ff9a8a")

var icons := {}                 # the HUD passes in the 3D icons (energy, oxygen, shield, card)
var model_for := Callable()      # the HUD passes in what builds each 3D model
var _type := ""
var _card: PanelContainer
var _spin: Node3D
var _stage_tex: ViewportTexture
var _title: Label
var _effects: HBoxContainer
var _text: Label
var _build_button: Button
var _cost_box: HBoxContainer     # "-30" + energy icon, in the right corner of the Build button
var _cost_label: Label
var _cost_icon: TextureRect
var _x: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.08, 0.02, 0.03, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	dim.gui_input.connect(func(e: InputEvent) -> void:
		if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
			close())
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_card = PanelContainer.new()
	var box := Palette.paper(Palette.GOLD)
	box.set_corner_radius_all(32)
	box.set_border_width_all(6)
	box.shadow_offset = Vector2(0, 12)
	box.shadow_size = 6
	box.content_margin_left = 32
	box.content_margin_right = 32
	box.content_margin_top = 32
	box.content_margin_bottom = 32
	_card.add_theme_stylebox_override("panel", box)
	_card.custom_minimum_size = Vector2(640, 0)
	center.add_child(_card)
	_card.resized.connect(func() -> void: _card.pivot_offset = _card.size / 2.0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	_card.add_child(col)

	# Stage: the building spinning slowly, on a wine background with a gold border.
	var stage := PanelContainer.new()
	var pbox := Palette._box(Palette.BG.darkened(0.15), 24)
	pbox.border_color = Palette.GOLD
	pbox.set_border_width_all(4)
	stage.add_theme_stylebox_override("panel", pbox)
	stage.custom_minimum_size = Vector2(0, 288)
	col.add_child(stage)
	_spin = Node3D.new()
	_stage_tex = Icons3D.render(self, _spin, 384, 1.9, true, Vector3(1.0, 0.75, 2.2))
	# The spinning stage is a 3D scene drawn every frame: only while this panel is open
	# (it used to keep drawing the whole game, which made weak phones slow everywhere).
	var stage_view := _spin.get_viewport() as SubViewport
	stage_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	visibility_changed.connect(func() -> void:
		stage_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if is_visible_in_tree() else SubViewport.UPDATE_DISABLED)
	var screen := TextureRect.new()
	screen.texture = _stage_tex
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stage.add_child(screen)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 44)
	_title.add_theme_color_override("font_color", Palette.BG)
	col.add_child(_title)
	_effects = HBoxContainer.new()
	_effects.alignment = BoxContainer.ALIGNMENT_CENTER
	_effects.add_theme_constant_override("separation", 12)
	col.add_child(_effects)
	_text = Label.new()
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 28)
	_text.add_theme_color_override("font_color", Palette.INK)
	col.add_child(_text)

	# The main button: big, gold and on its own.
	_build_button = Button.new()
	_build_button.custom_minimum_size = Vector2(0, 112)
	_build_button.add_theme_font_size_override("font_size", 38)
	_build_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_build_button.expand_icon = true
	_build_button.add_theme_constant_override("icon_max_width", 52)
	for s in ["normal", "hover", "disabled", "focus"]:
		_build_button.add_theme_stylebox_override(s, Palette.key(Palette.GOLD))
	_build_button.add_theme_stylebox_override("pressed", Palette.key(Palette.GOLD, true))
	_build_button.add_theme_color_override("font_color", Palette.INK)
	_build_button.pressed.connect(func() -> void:
		var t := _type
		close()
		build_pressed.emit(t))
	col.add_child(_build_button)
	# Cost in the right corner of the button ("-30" + energy icon); the word "Build" stays centered (Design request).
	_cost_box = HBoxContainer.new()
	_cost_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cost_box.alignment = BoxContainer.ALIGNMENT_END
	_cost_box.add_theme_constant_override("separation", 4)
	_cost_box.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	_cost_box.offset_left = -150.0
	_cost_box.offset_right = -18.0
	_build_button.add_child(_cost_box)
	_cost_label = Label.new()
	_cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cost_label.add_theme_font_size_override("font_size", 28)
	_cost_label.add_theme_color_override("font_color", Palette.INK)
	_cost_box.add_child(_cost_label)
	_cost_icon = TextureRect.new()
	_cost_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cost_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cost_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cost_icon.custom_minimum_size = Vector2(36, 36)
	_cost_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_cost_box.add_child(_cost_icon)

	# Red X in the top right corner (closing does not compete with building for space).
	var close_button := Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(76, 76)
	close_button.add_theme_font_size_override("font_size", 38)
	close_button.add_theme_color_override("font_color", Color.WHITE)
	close_button.add_theme_color_override("font_hover_color", Color.WHITE)
	close_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	var xb := Palette._box(Palette.ALERT, 38)
	xb.border_color = Color.WHITE
	xb.set_border_width_all(4)
	xb.shadow_color = Color(0, 0, 0, 0.35)
	xb.shadow_offset = Vector2(0, 4)
	for s in ["normal", "hover", "pressed", "focus"]:
		close_button.add_theme_stylebox_override(s, xb)
	close_button.pressed.connect(close)
	add_child(close_button)   # outside the card (the card lays out its children); it follows the card corner
	_x = close_button


func _process(delta: float) -> void:
	if not visible:
		return
	_spin.rotate_y(delta * 0.9)
	_x.size = Vector2(76, 76)
	_x.position = _card.global_position - global_position + Vector2(_card.size.x * _card.scale.x - 58.0, -18.0)


func open(type: String) -> void:
	_type = type
	var def: Dictionary = State.ITEMS[type]
	_title.text = tr(def.name)
	_text.text = State.item_text(def.name)
	_text.visible = _text.text != ""
	for c in _spin.get_children():
		c.queue_free()
	if model_for.is_valid():
		var m: Node3D = model_for.call(type)
		if m:
			_spin.add_child(m)
	_spin.rotation = Vector3.ZERO
	for c in _effects.get_children():
		c.queue_free()
	var rates: Dictionary = State.item_rates({"type": type, "level": 1, "plant": ""})
	if type == "greenhouse":
		_effect("energy", def.get("energy_when_planted", 0.0))
		_effect("oxygen", State.PLANT_OXYGEN)
	else:
		for bar in ["energy", "oxygen"]:
			if absf(float(rates[bar])) >= 0.05:
				_effect(bar, rates[bar])
	if def.has("card") and not State.cards.has(str(def.card)):
		_effect("card", 1.0)
	_effects.visible = _effects.get_child_count() > 0
	_build_button.text = tr("INFO_BUILD")
	_build_button.icon = null
	_cost_box.visible = def.cost > 0
	_cost_label.text = "-%d" % int(def.cost)
	_cost_icon.texture = icons.get("energy")
	# Blocked (not enough energy, for example): the button looks faded, and tapping it explains why.
	_build_button.modulate = Color(1, 1, 1, 0.55) if State.build_block_reason(type) != "" else Color.WHITE
	visible = true
	_card.scale = Vector2(0.85, 0.85)
	create_tween().tween_property(_card, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	visible = false   # the Build menu stays open underneath


func _effect(kind: String, value: float) -> void:
	var chip := PanelContainer.new()
	var sb := Palette._box(Palette.BG, 18)
	sb.content_margin_left = 12
	sb.content_margin_right = 16
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	chip.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	chip.add_child(h)
	var ic := TextureRect.new()
	ic.texture = icons.get(kind)
	ic.custom_minimum_size = Vector2(44, 44)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	h.add_child(ic)
	var n := Label.new()
	n.add_theme_font_size_override("font_size", 26)
	if kind == "card":
		n.text = "+1 " + tr("INFO_CARD")
		n.add_theme_color_override("font_color", Palette.GOLD)
	else:
		n.text = ("%+d/sol" % roundi(value)) if absf(value) >= 1.0 else ("%+.1f/sol" % value)
		n.add_theme_color_override("font_color", GREEN if value >= 0.0 else RED)
	h.add_child(n)
	_effects.add_child(chip)
