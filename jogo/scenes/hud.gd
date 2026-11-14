extends CanvasLayer
## A interface: as 3 barras, o sol, o menu de construir e o menu do item tocado.
## Decide o que um toque na base faz, conforme o modo atual (nada, construir ou mover).

enum Mode { NONE, BUILD, MOVE }

const LANGS := ["en", "pt_BR", "es", "fr"]
const LANG_NAMES := {"en": "EN", "pt_BR": "PT", "es": "ES", "fr": "FR"}
const BAR_KEYS := {"energy": "BAR_ENERGY", "oxygen": "BAR_OXYGEN", "shield": "BAR_SHIELD"}

var base: Node3D
var mode := Mode.NONE
var build_type := ""
var selected := Vector2i(-1, -1)

var _bars := {}           # "energy" -> ProgressBar
var _bar_labels := {}     # "energy" -> Label
var _bar_fill := {}       # "energy" -> StyleBoxFlat
var _sol_label: Label
var _lang_btn: Button
var _build_btns := {}     # tipo -> Button
var _panel: PanelContainer
var _panel_title: Label
var _panel_info: Label
var _panel_buttons: HBoxContainer
var _hint: Label
var _toast: Label
var _toast_tween: Tween
var _dim: ColorRect
var _storm: PanelContainer
var _storm_labels := {}   # "title", "real", "curiosity", "q" -> Label
var _storm_shield_btn: Button
var _storm_inside_btn: Button
var _card: PanelContainer
var _card_style: StyleBoxFlat
var _card_title: Label
var _card_rarity: Label
var _card_name: Label
var _card_fact: Label
var _card_photo: TextureRect
var _card_queue: Array[int] = []

const REVEAL_SOUND := {"comum": "revelar-comum", "raro": "revelar-raro", "épico": "revelar-epico", "lendário": "revelar-lendario"}


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Palette.make_theme()
	add_child(root)
	_build_top(root)
	_build_bottom(root)
	_build_messages(root)
	_build_popups(root)
	State.changed.connect(_refresh)
	State.storm_started.connect(_show_storm)
	State.storm_ended.connect(func(_shielded: bool) -> void: _show_toast(tr("STORM_OVER")))
	State.card_won.connect(_queue_card)
	_refresh()
	if State.paused and not State.storm_event.is_empty():
		_show_storm.call_deferred(State.storm_event)


# ───────────── Tempestade solar ─────────────
func _show_storm(event: Dictionary) -> void:
	_set_mode(Mode.NONE)
	_close_panel()
	_storm_labels.title.text = tr("EV_SOLAR_TITLE")
	_storm_labels.real.text = tr("EV_SOLAR_REAL").format({"date": event.get("date", "")})
	_storm_labels.curiosity.text = tr("EV_SOLAR_CURIOSITY")
	_storm_labels.curiosity.visible = bool(event.get("curiosity", false))
	_storm_labels.q.text = tr("EV_SOLAR_Q")
	_storm_shield_btn.text = "%s  -%d" % [tr("EV_SOLAR_A"), int(State.STORM_SHIELD_COST)]
	_storm_shield_btn.disabled = not State.can_afford(State.STORM_SHIELD_COST)
	_storm_inside_btn.text = tr("EV_SOLAR_B")
	_storm.visible = true
	_dim.visible = true
	Sfx.play("alerta")


func _on_storm_choice(raise_shield: bool) -> void:
	if not State.choose_storm(raise_shield):
		return
	Sfx.play("escudo" if raise_shield else "toque-botao")
	_storm.visible = false
	_dim.visible = _card.visible


# ───────────── Carta ganha ─────────────
func _queue_card(id: int, _is_new: bool) -> void:
	_card_queue.append(id)
	if not _card.visible:
		_show_next_card()


func _show_next_card() -> void:
	if _card_queue.is_empty():
		_card.visible = false
		_dim.visible = _storm.visible
		return
	var id: int = _card_queue.pop_front()
	var info := State.card_info(id)
	var rarity: String = info.get("rarity", "comum")
	var color: Color = Palette.RARITY.get(rarity, Palette.TEXT)
	_card_style.border_color = color
	_card_title.text = tr("CARD_NEW")
	_card_rarity.text = tr(Palette.RARITY_KEY.get(rarity, "RARITY_COMMON"))
	_card_rarity.add_theme_color_override("font_color", color)
	_card_name.text = tr("CARD_%d_NAME" % id)
	_card_fact.text = "%s %s" % [tr("CARD_REAL"), tr("CARD_%d_FACT" % id)]
	var photo := "res://ui/cards/%s" % info.get("photo_file", "")
	_card_photo.visible = info.get("photo_file", "") != "" and ResourceLoader.exists(photo)
	if _card_photo.visible:
		_card_photo.texture = load(photo)
	_card.visible = true
	_dim.visible = true
	Sfx.play(REVEAL_SOUND.get(rarity, "revelar-comum"))


# ───────────── O que um toque na base faz ─────────────
func on_cell_tapped(c: Vector2i) -> void:
	var free: bool = c != base.OUTSIDE and State.item_at(c).is_empty()
	match mode:
		Mode.BUILD:
			if free and State.build(build_type, c):
				Sfx.play("construir")
				base.walk_to(c)
			_set_mode(Mode.NONE)
		Mode.MOVE:
			if free and State.move(selected, c):
				Sfx.play("construir")
				base.walk_to(c)
			_set_mode(Mode.NONE)
			_close_panel()
		_:
			if c == base.OUTSIDE or free:
				_close_panel()
			else:
				Sfx.play("toque-botao")
				_open_panel(c)
				base.walk_to(c)


func _set_mode(m: Mode) -> void:
	mode = m
	if m == Mode.NONE:
		base.highlight([])
	else:
		base.highlight(State.free_cells())
	_refresh()


# ───────────── Botões ─────────────
func _on_build_pressed(type: String) -> void:
	Sfx.play("toque-botao")
	_close_panel()
	if mode == Mode.BUILD and build_type == type:
		_set_mode(Mode.NONE)
		return
	if not State.can_afford(State.ITEMS[type].cost):
		_show_toast(tr("NEED_ENERGY"))
		Sfx.play("travado")
		return
	build_type = type
	_set_mode(Mode.BUILD)


func _on_move() -> void:
	Sfx.play("toque-botao")
	_panel.visible = false
	_set_mode(Mode.MOVE)


func _on_upgrade() -> void:
	if State.upgrade(selected):
		Sfx.play("melhorar")
	else:
		_show_toast(tr("NEED_ENERGY"))
		Sfx.play("travado")


func _on_remove() -> void:
	if State.remove(selected):
		Sfx.play("remover")
	_close_panel()


func _on_plant() -> void:
	if State.plant(selected, "lettuce"):
		Sfx.play("plantar")


func _on_harvest() -> void:
	var p := State.harvest(selected)
	if p != "":
		Sfx.play("colher")
		base.jump()
		_show_toast("+1 " + tr(State.PLANTS[p].name))


func _on_lang() -> void:
	var i := LANGS.find(State.locale)
	State.set_locale(LANGS[(i + 1) % LANGS.size()])


# ───────────── Painel do item tocado ─────────────
func _open_panel(c: Vector2i) -> void:
	selected = c
	_panel.visible = true
	_refresh_panel()


func _close_panel() -> void:
	selected = Vector2i(-1, -1)
	_panel.visible = false


func _refresh_panel() -> void:
	var it := State.item_at(selected)
	if it.is_empty():
		_close_panel()
		return
	var def: Dictionary = State.ITEMS[it.type]
	_panel_title.text = "%s · %s" % [tr(def.name), tr("LEVEL").format({"n": int(it.level)})]
	_panel_info.visible = false
	for b in _panel_buttons.get_children():
		b.queue_free()
	if it.type == "greenhouse":
		_panel_info.visible = it.plant != ""
		if it.plant == "":
			_add_panel_button(tr("BTN_PLANT"), _on_plant)
		elif State.plant_ready(selected):
			_panel_info.text = tr("PLANT_READY").format({"plant": tr(State.PLANTS[it.plant].name)})
			_add_panel_button(tr("BTN_HARVEST"), _on_harvest)
		else:
			_panel_info.text = tr("PLANT_GROWING").format({
				"plant": tr(State.PLANTS[it.plant].name), "n": int(it.growth), "max": State.PLANTS[it.plant].sols})
	_add_panel_button(tr("BTN_MOVE"), _on_move)
	var cost := State.upgrade_cost(selected)
	if cost >= 0:
		var up := _add_panel_button("%s -%d" % [tr("BTN_UPGRADE"), cost], _on_upgrade)
		up.disabled = not State.can_afford(cost)
	if def.get("removable", true):
		_add_panel_button(tr("BTN_REMOVE"), _on_remove)


func _add_panel_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 96)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(action)
	_panel_buttons.add_child(b)
	return b


# ───────────── Atualizar a tela ─────────────
func _refresh() -> void:
	for bar in BAR_KEYS:
		var value: float = State.get(bar)
		_bars[bar].value = value
		_bar_labels[bar].text = tr(BAR_KEYS[bar])
		_bar_fill[bar].bg_color = Palette.ALERT if value < State.LOW else Palette.BAR[bar]
	_sol_label.text = "%s  ·  %s" % [tr("HUD_SOL").format({"n": State.sol}), tr("HUD_PLACE")]
	_lang_btn.text = LANG_NAMES.get(State.locale, "EN")
	for type in _build_btns:
		var def: Dictionary = State.ITEMS[type]
		var b: Button = _build_btns[type]
		b.text = "%s\n-%d" % [tr(def.name), def.cost]
		b.modulate = Color.WHITE if State.can_afford(def.cost) else Color(1, 1, 1, 0.55)
	match mode:
		Mode.BUILD:
			_hint.text = tr("TUT_BUILD")
		Mode.MOVE:
			_hint.text = tr("MOVE_HINT")
		_:
			if State.storm_active():
				_hint.text = tr("STORM_SHIELDED" if State.storm_shielded else "STORM_INSIDE").format({"n": State.storm_left})
			else:
				_hint.text = tr("TUT_BUILD") if State.items.size() <= 1 else ""
	if _panel.visible:
		_refresh_panel()


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.4)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.5)


# ───────────── Montagem da tela ─────────────
func _build_top(root: Control) -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 16
	panel.offset_right = -16
	panel.offset_top = 16
	root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var row := HBoxContainer.new()
	box.add_child(row)
	_sol_label = Label.new()
	_sol_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_sol_label)
	_lang_btn = Button.new()
	_lang_btn.custom_minimum_size = Vector2(96, 64)
	_lang_btn.pressed.connect(_on_lang)
	row.add_child(_lang_btn)

	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", 14)
	box.add_child(bars)
	for bar in BAR_KEYS:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bars.add_child(col)
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 22)
		col.add_child(label)
		var pb := ProgressBar.new()
		pb.max_value = State.BAR_MAX
		pb.show_percentage = false
		pb.custom_minimum_size = Vector2(0, 22)
		var fill := Palette.bar_fill(Palette.BAR[bar])
		pb.add_theme_stylebox_override("fill", fill)
		col.add_child(pb)
		_bars[bar] = pb
		_bar_labels[bar] = label
		_bar_fill[bar] = fill


func _build_bottom(root: Control) -> void:
	var bottom := VBoxContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 16
	bottom.offset_right = -16
	bottom.offset_bottom = -16
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_theme_constant_override("separation", 12)
	root.add_child(bottom)

	_panel = PanelContainer.new()
	_panel.visible = false
	bottom.add_child(_panel)
	var pbox := VBoxContainer.new()
	pbox.add_theme_constant_override("separation", 10)
	_panel.add_child(pbox)
	_panel_title = Label.new()
	_panel_title.add_theme_color_override("font_color", Palette.GOLD)
	pbox.add_child(_panel_title)
	_panel_info = Label.new()
	_panel_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pbox.add_child(_panel_info)
	_panel_buttons = HBoxContainer.new()
	_panel_buttons.add_theme_constant_override("separation", 10)
	pbox.add_child(_panel_buttons)

	var menu := PanelContainer.new()
	bottom.add_child(menu)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	menu.add_child(row)
	for type in State.BUILDABLE:
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 110)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 22)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.pressed.connect(_on_build_pressed.bind(type))
		row.add_child(b)
		_build_btns[type] = b


func _build_popups(root: Control) -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.55)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.visible = false
	root.add_child(_dim)

	_storm = _popup(root)
	var sbox: VBoxContainer = _storm.get_child(0)
	for k in ["title", "real", "curiosity", "q"]:
		var l := Label.new()
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sbox.add_child(l)
		_storm_labels[k] = l
	_storm_labels.title.add_theme_font_size_override("font_size", 38)
	_storm_labels.title.add_theme_color_override("font_color", Palette.GOLD)
	_storm_labels.curiosity.add_theme_color_override("font_color", Palette.GOLD)
	_storm_shield_btn = _popup_button(sbox, _on_storm_choice.bind(true))
	_storm_inside_btn = _popup_button(sbox, _on_storm_choice.bind(false))

	_card = _popup(root)
	_card_style = Palette._box(Palette.BG, 24)
	_card_style.set_border_width_all(8)
	_card.add_theme_stylebox_override("panel", _card_style)
	var cbox: VBoxContainer = _card.get_child(0)
	_card_title = Label.new()
	_card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cbox.add_child(_card_title)
	_card_photo = TextureRect.new()
	_card_photo.custom_minimum_size = Vector2(0, 300)
	_card_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cbox.add_child(_card_photo)
	_card_name = Label.new()
	_card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_name.add_theme_font_size_override("font_size", 44)
	cbox.add_child(_card_name)
	_card_rarity = Label.new()
	_card_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cbox.add_child(_card_rarity)
	_card_fact = Label.new()
	_card_fact.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_fact.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cbox.add_child(_card_fact)
	var ok := _popup_button(cbox, _show_next_card)
	ok.text = "OK"


func _popup(root: Control) -> PanelContainer:
	var p := PanelContainer.new()
	p.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	p.custom_minimum_size = Vector2(620, 0)
	p.visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	p.add_child(box)
	root.add_child(p)
	return p


func _popup_button(box: VBoxContainer, action: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 96)
	b.pressed.connect(action)
	box.add_child(b)
	return b


func _build_messages(root: Control) -> void:
	_hint = Label.new()
	_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_hint.offset_top = 230
	_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_color_override("font_outline_color", Palette.BG)
	_hint.add_theme_constant_override("outline_size", 10)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_hint)

	_toast = Label.new()
	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast.grow_vertical = Control.GROW_DIRECTION_BOTH
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 40)
	_toast.add_theme_color_override("font_outline_color", Palette.BG)
	_toast.add_theme_constant_override("outline_size", 14)
	_toast.modulate.a = 0.0
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_toast)
