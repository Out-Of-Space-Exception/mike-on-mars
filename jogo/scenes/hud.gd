extends CanvasLayer
## The UI (design/05 screens): start screen, bars, sol, Build/Explore/Album/Photo buttons,
## event windows, card, tube, album, NASA data and postcard.
## Decides what a tap on the base does, depending on the current mode (nothing, build or move).

enum Mode { NONE, BUILD, MOVE }

const LANGS := ["en", "pt_BR", "es", "fr"]
const LANG_NAMES := {"en": "EN", "pt_BR": "PT", "es": "ES", "fr": "FR"}
## Language menu: flag (Kenney Flag Pack, CC0) + name written in its own language.
const LANG_FLAGS := {"en": "res://ui/flags/us.png", "pt_BR": "res://ui/flags/br.png", "es": "res://ui/flags/es.png", "fr": "res://ui/flags/fr.png"}
const LANG_LABELS := {"en": "English", "pt_BR": "Português", "es": "Español", "fr": "Français"}
const BAR_KEYS := {"energy": "BAR_ENERGY", "oxygen": "BAR_OXYGEN", "shield": "BAR_SHIELD"}
const REVEAL_SOUND := {"common": "revelar-comum", "rare": "revelar-raro", "epic": "revelar-epico", "legendary": "revelar-lendario"}   # sound file names (Content team)
const BAR_ICONS := {"energy": "res://ui/icons/ic-energia.svg", "oxygen": "res://ui/icons/ic-oxigenio.svg", "shield": "res://ui/icons/ic-escudo.svg"}
const ICONS := {"build": "res://ui/icons/ic-wrench.png", "explore": "res://ui/icons/ic-target.png", "album": "res://ui/icons/ic-menugrid.png", "photo": "res://ui/icons/ic-camera.svg"}
const DONKI_URL := "https://kauai.ccmc.gsfc.nasa.gov/DONKI/"

var base: Node3D
var mode := Mode.NONE
var build_type := ""
var selected := Vector2i(-1, -1)

var _root: Control
var _bars := {}
var _bar_labels := {}
var _bar_fill := {}
var _bar_box: Control
var _btn_labels := {}         # text of each bottom button (the button is built from icon + text)
var _hint_chip: PanelContainer
var _card_rarity_pill: PanelContainer
var _card_rays: Control
var _tube_q: Label3D
var _tube_opening := false
var _tube_btn: Button
var _tube_lid: MeshInstance3D
var _tube_ring: MeshInstance3D
var _tube_beam: MeshInstance3D
var _top_box: Control
var _bottom_box: Control
var _popups: Array[PanelContainer] = []
const MAX_W := 680.0          # max UI width; on a wide screen it stays in the middle, with margins on the sides
var _bar_nums := {}           # the current number inside the bar
var _bar_rates := {}          # how much it gains or loses per sol
var _sol_label: Label
var _hint: Label
var _toast: PanelContainer
var _toast_label: Label
var _toast_style: StyleBoxFlat
var _toast_tween: Tween
var _toast_down := false
var _mike_line := 0
var _mike_said_at := -100.0
var _buttons := {}            # "build", "explore", "album", "photo" -> Button
var _build_menu: PanelContainer
var _build_grid: GridContainer
var _panel: PanelContainer
var _panel_title: Label
var _panel_info: Label
var _panel_buttons: VBoxContainer
var _panel_level: Label
var _panel_desc: Label
var _panel_stats: HBoxContainer
var _panel_tail: Polygon2D
var _panel_pos := Vector2.INF
var _panel_sig := ""          # what the floating menu shows; only rebuilds the buttons when this changes
var _build_sig := ""
var _dim: ColorRect
var _choice: PanelContainer
var _choice_title: Label
var _choice_lines: VBoxContainer
var _choice_a: Button
var _choice_b: Button
var _choice_actions := []     # [Callable a, Callable b]
var _info: PanelContainer
var _info_title: Label
var _info_text: Label
var _info_action := Callable()
var _card: PanelContainer
var _card_style: StyleBoxFlat
var _card_title: Label
var _card_rarity: Label
var _card_name: Label
var _card_fact: Label
var _card_photo: TextureRect
var _card_frame: TextureRect
var _build_info: Control
var _icon_cache := {}         # 3D icons already rendered
var _settings: PanelContainer
var _set_title: Label
var _set_lang: Label
var _set_flags: HBoxContainer
var _set_music: Button
var _set_sounds: Button
var _set_tutorial: Button
var _set_nasa: Button
var _gear: Button
# First-minute tutorial: fixed message from Mike at the top + golden arrow over what to tap.
var _tut_card: PanelContainer
var _tut_label: Label
var _tut_skip: Button
var _tut_arrow: TextureRect
var _tut_ring: Panel          # golden frame pulsing around the button Mike asked for (covers nothing)
var _tut_done_at := -1.0
var _pc_hint_shown := false
const CARD_W := 560.0          # the card with the Design frame (1066 x 1280) at this width
const FRAME := {"common": "comum", "rare": "raro", "epic": "epico", "legendary": "lendario"}   # card frame file names (Design team)
var _card_source := ""
var _card_queue: Array[int] = []
var _card_new: Array[bool] = []
var _card_reveal := false
var _card_badge: PanelContainer   # tilted "NEW!" badge in the corner of the card
var _badge_tween: Tween       # the card that just came out of the tube enters with a party    # "New card!" only when the child just won it
var _tube: PanelContainer
var _tube_node: Node3D
var _tube_glass: StandardMaterial3D
var _tube_light: OmniLight3D
var _bold: FontVariation
var _tube_label: Label
var _tube_tween: Tween
var _album: PanelContainer
var _album_title: Label
var _album_grid: GridContainer
var _album_scroll: ScrollContainer
# Drag anywhere in the album to scroll it (the cards are buttons and used to swallow the finger).
var _album_drag := {"down": false, "moved": false, "start": Vector2.ZERO, "from": 0.0, "last_y": 0.0, "speed": 0.0}
var _album_bar: TubeBar
var _album_count: Label
var _album_next: Label
var _album_tabs: HBoxContainer
var _album_page_title: Label
var _album_page := 0
var _album_badge: PanelContainer
var _album_box: StyleBoxFlat
var _shelf: Control
const ALBUM_MAX_W := 1000.0   # on PC the album stays in the middle, at most this wide   # red dot on the Album button: how many new cards
var _nasa: PanelContainer
var _nasa_text: Label
var _start: Control
var _start_play: Button
var _start_lang: Button
var _start_nasa: Button
var _postcard: Control
var _postcard_label: Label
var _flash: ColorRect
var _inventory: HFlowContainer
var _inv_labels := {}         # plant -> Label "× n"
var _icons := {}              # plant -> texture rendered from the 3D model


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = Palette.make_theme()
	add_child(_root)
	_build_top()
	_build_bottom()
	_build_messages()
	_build_album()
	_build_popups()
	# Building info panel (Design 05): opens when tapping an item in the Build menu.
	_build_info = preload("res://scenes/build_info.gd").new()
	_build_info.icons = {"energy": _icon("energy"), "oxygen": _icon("oxygen"), "shield": _icon("shield"), "card": _icon("card")}
	_build_info.model_for = func(type: String) -> Node3D: return _item_model(type, 1.25)
	_root.add_child(_build_info)
	_shelf = preload("res://scenes/shelf.gd").new()
	_shelf.hud = self
	_shelf.red_x = _red_x
	_root.add_child(_shelf)
	_build_info.build_pressed.connect(_on_build_item)
	_build_settings()
	_build_postcard()
	_build_tutorial()
	_build_start()
	_fit_layout()
	get_viewport().size_changed.connect(_fit_layout)
	State.changed.connect(_refresh)
	State.storm_started.connect(_show_storm)
	State.storm_ended.connect(func(_s: bool) -> void: _show_toast(tr("STORM_OVER")))
	State.event_started.connect(_show_event)
	State.event_message.connect(_on_event_message)
	State.card_won.connect(_queue_card)
	State.explore_returned.connect(func(_id: int) -> void: get_tree().create_timer(1.6).timeout.connect(_show_tube))
	_refresh()


func _on_event_message(key: String, extra: String) -> void:
	_show_toast(tr(key).format({"name": extra}))
	if key.begins_with("OUT_"):
		Sfx.play("alerta")


# ───────────── Start screen ─────────────
func _on_play() -> void:
	Sfx.play("toque-botao")
	Sfx.play_music("musica-base")
	_start.visible = false
	_root.visible = true
	base.orbit = false
	State.start()
	_tut_update()
	if not DisplayServer.is_touchscreen_available() and not _pc_hint_shown:
		_pc_hint_shown = true
		get_tree().create_timer(1.5 if State.tutorial >= State.TUTORIAL_DONE else 12.0).timeout.connect(func() -> void: _show_toast(tr("HINT_PC")))
	var away: Dictionary = State.away
	if int(away.get("sols", 0)) >= 4:
		var text := _sols(tr("AWAY_SOLS").format({"n": away.sols}))
		if int(away.get("plants", 0)) > 0:
			text += "\n" + tr("AWAY_PLANTS").format({"n": away.plants})
		# One window at a time: first the "while you were away" one, then whatever was waiting.
		_show_info(tr("AWAY_TITLE"), text, _after_welcome)
		Sfx.play("bem-vindo")
		State.away = {}
		return
	_after_welcome()


func _after_welcome() -> void:
	_resume_pending()
	if State.tube_card != 0 and not _choice.visible:
		_show_tube()


## If the game was closed in the middle of a choice, shows the window again.
func _resume_pending() -> void:
	match State.pending_event:
		"storm":
			_show_storm(State.storm_event)
		"dust", "devil", "cold", "nosignal":
			_show_event(State.pending_event)


## Mike reacts when the child taps him (research, item 17).
## He always jumps; he talks at most once every 8 seconds, and a different line each time.
func on_mike_tapped() -> void:
	base.jump()
	Sfx.play("bem-vindo")
	var now := Time.get_ticks_msec() / 1000.0
	if now - _mike_said_at < 8.0:
		return
	_mike_said_at = now
	_mike_line = _mike_line % 4 + 1
	_show_toast(tr("MIKE_%d" % _mike_line))


func _on_lang() -> void:
	# Opens the language menu right below the button.
	var menu := _lang_menu()
	var r := _start_lang.get_global_rect()
	menu.popup(Rect2i(Vector2i(int(r.end.x) - 300, int(r.end.y) + 12), Vector2i(300, 0)))


var _lang_popup: PopupMenu

func _lang_menu() -> PopupMenu:
	if _lang_popup == null:
		_lang_popup = PopupMenu.new()
		_lang_popup.add_theme_stylebox_override("panel", Palette.plate())
		var sel := StyleBoxFlat.new()
		sel.bg_color = Color("4a2226"); sel.border_color = Palette.GOLD
		sel.set_border_width_all(3); sel.set_corner_radius_all(12)
		_lang_popup.add_theme_stylebox_override("hover", sel)
		_lang_popup.add_theme_color_override("font_color", Palette.TEXT)
		_lang_popup.add_theme_color_override("font_hover_color", Palette.TEXT)
		_lang_popup.add_theme_font_size_override("font_size", 32)
		_lang_popup.add_theme_constant_override("icon_max_width", 52)
		_lang_popup.add_theme_constant_override("v_separation", 22)
		_lang_popup.add_theme_constant_override("h_separation", 16)
		_lang_popup.id_pressed.connect(func(id: int):
			Sfx.play("toque-botao")
			State.set_locale(LANGS[id]))
		add_child(_lang_popup)
	_lang_popup.clear()
	# Portuguese first (the team is from Brazil), then the others.
	for l in ["pt_BR", "en", "es", "fr"]:
		_lang_popup.add_icon_item(_icon("flag_" + l), LANG_LABELS[l], LANGS.find(l))
	_lang_popup.set_focused_item(_lang_popup.get_item_index(LANGS.find(State.locale)))
	return _lang_popup


# ───────────── What a tap on the base does ─────────────
func on_cell_tapped(c: Vector2i) -> void:
	if _build_menu.visible:
		_build_menu.visible = false
		_tut_update()
		return
	if mode == Mode.NONE and _tut_blocks("greenhouse" if State.item_at(c).get("type", "") == "greenhouse" else "base"):
		return
	var free: bool = c != base.OUTSIDE and State.item_at(c).is_empty()
	# Area still closed: opens when Mike's House levels up.
	if c != base.OUTSIDE and free and not State.cell_open(c) and mode != Mode.MOVE:
		_show_toast(tr("MAP_LOCKED"), true)
		Sfx.play("travado")
		_close_panel()
		return
	match mode:
		Mode.BUILD:
			base.build_fx = true
			if c != base.OUTSIDE and State.build(build_type, c):
				Sfx.play("construir")
			base.build_fx = false
			_set_mode(Mode.NONE)
		Mode.MOVE:
			if c != base.OUTSIDE and State.move(selected, c):
				Sfx.play("construir")
				base.walk_to(c)
			_set_mode(Mode.NONE)
			_close_panel()
		_:
			if c == base.OUTSIDE or free:
				_close_panel()
			else:
				Sfx.play("toque-botao")
				_open_panel(State.anchor_of(c))
				base.walk_to(c)


func _set_mode(m: Mode) -> void:
	mode = m
	_tut_update.call_deferred()
	match m:
		Mode.BUILD:
			base.highlight(State.free_cells())
		Mode.MOVE:
			base.highlight(State.move_targets(selected))
		_:
			base.highlight([])
	_refresh()


# ───────────── Bottom buttons ─────────────
func _on_build() -> void:
	if _tut_blocks("build"):
		return
	Sfx.play("abrir-menu")
	_close_panel()
	if mode != Mode.NONE:
		_set_mode(Mode.NONE)
	_build_menu.visible = not _build_menu.visible
	_refresh_build_menu()
	_tut_update()


func _on_build_item(type: String) -> void:
	if _tut_blocks("build_" + type):
		return
	var reason := State.build_block_reason(type)
	if reason != "":
		_show_toast(tr(reason), true)
		Sfx.play("travado")
		return
	Sfx.play("toque-botao")
	_build_menu.visible = false
	build_type = type
	_set_mode(Mode.BUILD)


func _on_explore() -> void:
	if _tut_blocks("explore"):
		return
	_build_menu.visible = false
	if State.tube_card != 0:
		_show_tube()
		return
	var reason := State.explore_block_reason()
	if reason != "":
		_show_toast(tr(reason), true)
		Sfx.play("travado")
		return
	if State.start_explore():
		Sfx.play("toque-botao")
		_set_mode(Mode.NONE)
		_close_panel()


func _on_album() -> void:
	if _tut_blocks("album"):
		return
	Sfx.play("abrir-menu")
	_build_menu.visible = false
	_close_panel()
	_refresh_album()
	_album.visible = true
	State.save_game()


## Postcard: hides the UI, shows "Sol N · Gale Crater" and saves the photo of the base.
func _on_photo() -> void:
	if _tut_blocks("photo"):
		return
	_build_menu.visible = false
	_close_panel()
	_set_mode(Mode.NONE)
	_root.visible = false
	_postcard_label.text = tr("POSTCARD").format({"n": State.sol})
	_postcard.visible = true
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	_postcard.visible = false
	_root.visible = true
	Sfx.play("foto")
	_flash.modulate.a = 1.0
	create_tween().tween_property(_flash, "modulate:a", 0.0, 0.5)
	var file := "mike-on-mars-sol-%d.png" % State.sol
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(img.save_png_to_buffer(), file, "image/png")
	else:
		img.save_png("user://" + file)
	_show_toast(tr("PHOTO_SAVED"))


# ───────────── Tapped item panel ─────────────
func _open_panel(c: Vector2i) -> void:
	var was_open := _panel.visible and selected == c
	_panel_sig = ""
	selected = c
	_panel.visible = true
	_build_menu.visible = false
	_refresh_panel()
	if not was_open:
		_panel_pos = Vector2.INF
		_panel.scale = Vector2(0.8, 0.8)
		create_tween().tween_property(_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tut_update()


func _close_panel() -> void:
	selected = Vector2i(-1, -1)
	_panel.visible = false


func _refresh_panel() -> void:
	var it := State.item_at(selected)
	if it.is_empty():
		_close_panel()
		return
	# Each sol only the "Lettuce · 12/33 sols" text changes: the buttons stay as they are (they used to blink).
	var sig := "%s|%s|%d|%s|%s|%s|%s|%s|%s|%s" % [selected, it.type, int(it.level), it.get("plant", ""), State.plant_ready(selected), it.get("broken", false),
		State.base_locked_reason(), State.upgrade_block_reason(selected), State.unlocked_plants(), TranslationServer.get_locale()]
	if sig == _panel_sig:
		if it.type == "greenhouse" and str(it.get("plant", "")) != "" and not State.plant_ready(selected):
			_panel_info.text = tr("PLANT_GROWING").format({
				"plant": tr(State.PLANTS[it.plant].name), "n": int(it.growth), "max": State.PLANTS[it.plant].sols})
		return
	_panel_sig = sig
	var def: Dictionary = State.ITEMS[it.type]
	_panel_title.text = tr(State.item_name(it))
	_panel_level.text = tr("LEVEL").format({"n": int(it.level)})
	_panel_level.get_parent().visible = State.upgrade_cost(selected) >= 0 or int(it.level) > 1
	_panel_desc.text = State.item_text(State.item_name(it))
	_panel_desc.visible = _panel_desc.text != ""
	# How much it makes per sol, with the icons from the top bars.
	for c in _panel_stats.get_children():
		c.queue_free()
	var rates: Dictionary = State.item_rates(it)
	for bar in ["energy", "oxygen", "shield"]:
		var v: float = rates[bar]
		if absf(v) < 0.05:
			continue
		var chip := PanelContainer.new()
		var chip_box := Palette._box(Palette.BG, 16)
		chip_box.content_margin_left = 16
		chip_box.content_margin_right = 16
		chip_box.content_margin_top = 8
		chip_box.content_margin_bottom = 8
		chip.add_theme_stylebox_override("panel", chip_box)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		chip.add_child(row)
		var ic := TextureRect.new()
		ic.texture = _icon(bar)
		ic.custom_minimum_size = Vector2(30, 30)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(ic)
		var n := Label.new()
		n.text = ("%+d/sol" % roundi(v)) if absf(v) >= 1.0 else ("%+.1f/sol" % v)
		n.add_theme_font_size_override("font_size", 22)
		n.add_theme_color_override("font_color", Color("9be27a") if v > 0.0 else Color("ff9a8a"))
		row.add_child(n)
		_panel_stats.add_child(chip)
	_panel_stats.visible = _panel_stats.get_child_count() > 0
	_panel_info.visible = false
	for b in _panel_buttons.get_children():
		b.queue_free()
	if it.type == "greenhouse":
		if it.plant == "":
			# Seeds in 2 columns, so the menu doesn't get too long.
			var seeds := GridContainer.new()
			seeds.columns = 2
			seeds.add_theme_constant_override("h_separation", 16)
			seeds.add_theme_constant_override("v_separation", 16)
			_panel_buttons.add_child(seeds)
			for p in State.unlocked_plants():
				var plant_def: Dictionary = State.PLANTS[p]
				var pb := _add_panel_button("%s (%d)" % [tr(plant_def.name), plant_def.sols], _on_plant.bind(p), true)
				pb.reparent(seeds)
				pb.custom_minimum_size = Vector2(0, 128)
				pb.add_theme_font_size_override("font_size", 23)
				pb.icon = _plant_icon(p)   # Design: the plant next to the name, more visual
				pb.expand_icon = true
				pb.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				pb.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				pb.add_theme_constant_override("icon_max_width", 64)
		elif State.plant_ready(selected):
			_panel_info.visible = true
			_panel_info.text = tr("PLANT_READY").format({"plant": tr(State.PLANTS[it.plant].name)})
			_add_panel_button(tr("BTN_HARVEST"), _on_harvest)
		else:
			_panel_info.visible = true
			_panel_info.text = tr("PLANT_GROWING").format({
				"plant": tr(State.PLANTS[it.plant].name), "n": int(it.growth), "max": State.PLANTS[it.plant].sols})
	# Shelf: the golden "View shelf" button (front camera and the slots to choose what to display).
	if it.type == "shelf":
		var shelf_key := State.key(State.anchor_of(selected))
		var view_btn := _add_panel_button(tr("BTN_SHELF"), func() -> void:
			Sfx.play("abrir-menu")
			_close_panel()
			_shelf.open(shelf_key), true)
		view_btn.custom_minimum_size.y = 88
		view_btn.set_meta("base_color", Palette.GOLD)
		_style_key(view_btn, true)
	if State.base_locked_reason() != "":
		return
	# Broken: the main action is to repair (and it can't be upgraded while broken).
	var cost := State.upgrade_cost(selected)
	if it.get("broken", false):
		_panel_info.visible = true
		_panel_info.text = tr("BROKEN_TEXT")
		var fix := _add_panel_button("%s  %d" % [tr("BTN_REPAIR"), State.repair_cost(selected)], _on_repair, true)
		fix.icon = _icon("energy")
		fix.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fix.custom_minimum_size.y = 88
		fix.set_meta("base_color", Palette.GOLD)
		_style_key(fix, State.can_afford(State.repair_cost(selected)))
		cost = -1
	if cost >= 0:
		var up := _add_panel_button("%s  %d" % [tr("BTN_UPGRADE"), cost], _on_upgrade, true)
		up.icon = _icon("energy")
		up.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		up.custom_minimum_size.y = 88
		up.set_meta("base_color", Palette.GOLD)
		_style_key(up, State.upgrade_block_reason(selected) == "")
	# Move, rotate and remove: icons only (cross arrows, curved arrow and trash can), side by side.
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 16)
	_panel_buttons.add_child(tools)
	var kinds := [["move", _on_move], ["turn", _on_rotate]]
	if def.get("removable", true):
		kinds.append(["trash", _on_remove])
	for pair in kinds:
		var t := _key_button(pair[1], true)
		t.custom_minimum_size = Vector2(0, 88)
		t.add_theme_constant_override("icon_max_width", 56)
		t.icon = _icon(pair[0])
		t.expand_icon = true
		t.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.tooltip_text = tr({"move": "BTN_MOVE", "turn": "BTN_ROTATE", "trash": "BTN_REMOVE"}[pair[0]])
		if pair[0] == "trash":
			t.set_meta("base_color", Palette.OFF)
			for s in ["normal", "hover", "focus"]:
				t.add_theme_stylebox_override(s, Palette.key(Palette.OFF))
			t.add_theme_stylebox_override("pressed", Palette.key(Palette.OFF, true))
		tools.add_child(t)


func _add_panel_button(text: String, action: Callable, main := false) -> Button:
	var b := _key_button(action, not main)
	b.text = text
	b.custom_minimum_size = Vector2(0, 88)
	b.add_theme_font_size_override("font_size", 28)
	b.autowrap_mode = TextServer.AUTOWRAP_OFF
	b.add_theme_constant_override("icon_max_width", 34)
	_panel_buttons.add_child(b)
	return b


## The floating menu follows the building (if the camera moves) and stays inside the screen,
## between the top bars and the bottom buttons. The little tail always points at the building.
func _place_panel(delta: float) -> void:
	if not _panel.visible:
		return
	var anchor: Vector2 = base.item_screen_top(selected)
	if anchor == Vector2.INF:
		return
	var vp := get_viewport().get_visible_rect().size
	_panel.size = _panel.get_combined_minimum_size()   # 3 buttons or 4: the card gets the right size
	var sz := _panel.size
	var target := Vector2(anchor.x - sz.x / 2.0, anchor.y - sz.y - 34.0)
	target.x = clampf(target.x, 12.0, vp.x - sz.x - 12.0)
	target.y = clampf(target.y, 250.0, maxf(250.0, vp.y - sz.y - 330.0))
	_panel_pos = target if _panel_pos == Vector2.INF else _panel_pos.lerp(target, 1.0 - exp(-delta * 14.0))
	_panel.position = _panel_pos
	_panel.pivot_offset = Vector2(clampf(anchor.x - _panel_pos.x, 30.0, sz.x - 30.0), sz.y)
	_panel_tail.position = Vector2(_panel.pivot_offset.x, sz.y)
	_panel_tail.visible = anchor.y > _panel_pos.y + sz.y


func _on_move() -> void:
	if _tut_blocks("action"):
		return
	Sfx.play("toque-botao")
	_panel.visible = false
	_set_mode(Mode.MOVE)


func _on_rotate() -> void:
	if _tut_blocks("action"):
		return
	var reason := State.rotate_block_reason(selected)
	if reason == "" and State.rotate(selected):
		Sfx.play("construir")
	else:
		_show_toast(tr(reason), true)
		Sfx.play("travado")


func _on_upgrade() -> void:
	if _tut_blocks("action"):
		return
	var reason := State.upgrade_block_reason(selected)
	if reason == "" and State.upgrade(selected):
		Sfx.play("melhorar")
	else:
		_show_toast(tr(reason), true)
		Sfx.play("travado")


func _on_remove() -> void:
	if _tut_blocks("action"):
		return
	var it := State.item_at(selected)
	if it.is_empty():
		return
	var target := selected
	Sfx.play("toque-botao")
	_show_choice(tr("REMOVE_TITLE").format({"name": tr(State.item_name(it))}), [tr("REMOVE_TEXT")],
		tr("REMOVE_YES"), true, func() -> void:
			selected = target
			_do_remove(), tr("REMOVE_NO"), Callable())


func _on_repair() -> void:
	if State.repair(selected):
		Sfx.play("melhorar")
		_show_toast(tr("ITEM_FIXED"))
	else:
		_show_toast(tr("NEED_ENERGY"), true)
		Sfx.play("travado")


func _do_remove() -> void:
	if State.remove(selected):
		Sfx.play("remover")
	_close_panel()


func _on_plant(plant_type: String) -> void:
	if State.plant(selected, plant_type):
		Sfx.play("plantar")


func _on_harvest() -> void:
	var p := State.harvest(selected)
	if p != "":
		Sfx.play("colher")
		base.jump()


# ───────────── Events ─────────────
func _show_storm(event: Dictionary) -> void:
	var lines := [tr("EV_SOLAR_REAL").format({"date": _nice_date(str(event.get("date", "")))})]
	if event.get("curiosity", false):
		lines.append(tr("EV_SOLAR_CURIOSITY"))
	lines.append(tr("EV_SOLAR_Q"))
	_show_choice(tr("EV_SOLAR_TITLE"), lines,
		_with_cost(tr("EV_SOLAR_A"), State.storm_shield_cost()), State.can_afford(State.storm_shield_cost()),
		_storm_shield, tr("EV_SOLAR_B"), _storm_inside)
	Sfx.play("alerta")


## "Yes, raise it (costs 30 energy)": the choice button says how much energy it uses.
func _with_cost(text: String, cost: float) -> String:
	return "%s (%s)" % [text, tr("COST_ENERGY").format({"n": int(cost)})]


func _storm_shield() -> void:
	if State.choose_storm(true):
		Sfx.play("escudo")


func _storm_inside() -> void:
	State.choose_storm(false)


func _show_event(type: String) -> void:
	match type:
		"dust":
			# With panels they get dirty; without panels the storm passes and the energy does not change.
			var panel := State.count_items("solar") > 0
			_show_info(tr("EV_DUST_TITLE"), tr("EV_DUST_TEXT" if panel else "EV_DUST_TEXT_NOPANEL"), State.ack_event)
			Sfx.play("energia-cai" if panel else "alerta")
		"devil":
			# It only "cleans the panels" when there were dirty panels to clean.
			_show_info(tr("EV_DEVIL_TITLE"), tr("EV_DEVIL_TEXT" if State.devil_cleaned else "EV_DEVIL_TEXT_NOPANEL"), State.ack_event)
			Sfx.play("energia-volta" if State.devil_cleaned else "alerta")
		"cold":
			_show_choice(tr("EV_COLD_TITLE"), [tr("EV_COLD_TEXT"), tr("EV_COLD_Q")],
				_with_cost(tr("EV_COLD_A"), State.cold_cost()), State.can_afford(State.cold_cost()),
				func() -> void: State.choose_cold(true),
				tr("EV_COLD_B"), func() -> void: State.choose_cold(false))
			Sfx.play("alerta")
		"nosignal":
			if State.count_items("greenhouse") == 0:
				# Without a greenhouse the autopilot question (save energy / keep planting) makes no sense: just the notice.
				_show_info(tr("EV_NOSIGNAL_TITLE"), tr("EV_NOSIGNAL_TEXT"), func() -> void: State.choose_nosignal("save"))
			else:
				_show_choice(tr("EV_NOSIGNAL_TITLE"), [tr("EV_NOSIGNAL_TEXT"), tr("EV_NOSIGNAL_Q")],
					tr("PLAN_SAVE"), true, func() -> void: State.choose_nosignal("save"),
					tr("PLAN_PLANT"), func() -> void: State.choose_nosignal("plant"))
			Sfx.play("alerta")


func _show_choice(title: String, lines: Array, a_text: String, a_enabled: bool, a_action: Callable, b_text: String, b_action: Callable) -> void:
	_set_mode(Mode.NONE)
	_close_panel()
	_build_menu.visible = false
	_choice_title.text = title
	for c in _choice_lines.get_children():
		c.queue_free()
	for line in lines:
		var l := _wrap_label(line, 28)
		_choice_lines.add_child(l)
	_choice_a.text = a_text
	_choice_a.disabled = not a_enabled
	_choice_b.text = b_text
	_choice_actions = [a_action, b_action]
	_choice.visible = true
	_update_dim()


func _on_choice(i: int) -> void:
	_choice.visible = false
	_update_dim()
	(_choice_actions[i] as Callable).call()


func _show_info(title: String, text: String, action: Callable) -> void:
	_info_title.text = title
	_info_text.text = text
	_info_action = action
	_info.visible = true
	_update_dim()


func _on_info_ok() -> void:
	_info.visible = false
	_update_dim()
	if _info_action.is_valid():
		_info_action.call()


# ───────────── Sample tube ─────────────
func _show_tube() -> void:
	if State.tube_card == 0 or _tube.visible or _start.visible:
		return
	# Suspense: all grey and a "?". The rarity color only shows when it opens.
	var grey := Color(0.72, 0.72, 0.76)
	_tube_glass.albedo_color = Color(grey, 0.6)
	_tube_glass.emission = grey.darkened(0.4)
	_tube_light.light_color = Color(0.9, 0.9, 0.95)
	_tube_q.visible = true
	_tube_q.modulate.a = 1.0
	_tube_q.scale = Vector3.ONE
	_tube_node.scale = Vector3.ONE
	_tube_node.visible = true
	_tube_lid.position = Vector3(0.0, 0.82, 0.0)
	_tube_lid.rotation = Vector3.ZERO
	_tube_lid.visible = true
	_tube_ring.visible = false
	_tube_beam.visible = false
	_tube_glass.emission_energy_multiplier = 0.6
	_tube_light.light_energy = 2.0
	_tube_opening = false
	_tube_label.text = tr("TUBE_MYSTERY")
	_tube_btn.text = tr("BTN_OPEN")
	_tube_btn.disabled = false
	_tube.visible = true
	_update_dim()
	_tut_update()
	Sfx.play("tubo-abrir")
	# The tube slowly turns and shivers a little, as if the sample wanted to get out.
	if _tube_tween:
		_tube_tween.kill()
	_tube_node.rotation = Vector3.ZERO
	_tube_node.position = Vector3.ZERO
	_tube_btn.modulate.a = 1.0
	_tube_glass.emission = Color(0.72, 0.72, 0.76).darkened(0.4)
	_tube_tween = create_tween().set_loops()
	_tube_tween.tween_property(_tube_node, "rotation:z", 0.06, 0.9).set_trans(Tween.TRANS_SINE)
	_tube_tween.tween_property(_tube_node, "rotation:z", -0.06, 0.9).set_trans(Tween.TRANS_SINE)


## Open (like opening a chest): the tube makes 3 hops, each higher, blinking lightly; on the last one it
## rises spinning and glows; a flash covers the screen and the card comes out of a puff of smoke in its color.
func _on_tube_tap() -> void:
	if _tube_opening or State.tube_card == 0:
		return
	_tube_opening = true
	_tube_btn.disabled = true
	_tube_btn.modulate.a = 0.0
	if _tube_tween:
		_tube_tween.kill()
	_tube_node.rotation = Vector3.ZERO
	_tube_node.position = Vector3.ZERO
	var color: Color = Palette.RARITY.get(State.tube_rarity(), Palette.TEXT)
	_tube_label.text = ""
	create_tween().tween_property(_tube_q, "modulate:a", 0.0, 0.2)
	var t := create_tween()
	for i in 3:
		var h := 0.16 + i * 0.12
		t.tween_callback(func() -> void: Sfx.play("toque-botao"))
		t.tween_property(_tube_node, "scale", Vector3(1.14, 0.84, 1.14), 0.08).set_ease(Tween.EASE_OUT)
		t.tween_property(_tube_node, "scale", Vector3(0.92, 1.1, 0.92), 0.09)
		t.parallel().tween_property(_tube_node, "position:y", h, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(_tube_glass, "emission_energy_multiplier", 1.2 + i * 0.9, 0.18)
		t.tween_property(_tube_node, "position:y", 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.parallel().tween_property(_tube_node, "scale", Vector3(1.1, 0.9, 1.1), 0.14)
		t.tween_property(_tube_node, "scale", Vector3.ONE, 0.1)
		t.parallel().tween_property(_tube_glass, "emission_energy_multiplier", 0.8, 0.1)
		t.tween_interval(0.16)
	# The last one: rises spinning and lights up completely.
	t.tween_callback(func() -> void: Sfx.play("tubo-abrir"))
	t.tween_property(_tube_node, "position:y", 0.3, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(_tube_node, "rotation:y", TAU * 2.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_tube_glass, "emission", Color.WHITE, 0.45)
	t.parallel().tween_property(_tube_glass, "emission_energy_multiplier", 4.0, 0.45)
	t.parallel().tween_property(_tube_light, "light_energy", 6.0, 0.45)
	t.tween_callback(_tube_reveal.bind(color))


## White flash over the whole screen; behind it the tube disappears and the card appears coming out of a puff of smoke.
func _tube_reveal(color: Color) -> void:
	_flash.color = Color.WHITE
	_flash.modulate.a = 1.0
	move_child(_flash, get_child_count() - 1)
	_tube.visible = false
	_tube_btn.modulate.a = 1.0
	_update_dim()
	_card_reveal = true
	State.open_tube()
	_smoke_puffs(color)
	var f := create_tween()
	f.tween_interval(0.06)
	f.tween_property(_flash, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)


## 2D puff of smoke in the card color: little balls that leave the middle of the screen, grow and fade (behind the card).
func _smoke_puffs(color: Color) -> void:
	var center := get_viewport().get_visible_rect().size / 2.0
	for i in 18:
		var puff := Panel.new()
		var box := StyleBoxFlat.new()
		box.bg_color = Color(color.lightened(0.25 + randf() * 0.3), 0.8)
		box.set_corner_radius_all(80)
		puff.add_theme_stylebox_override("panel", box)
		puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var r := randf_range(50.0, 90.0)
		puff.size = Vector2(r, r) * 2.0
		puff.pivot_offset = puff.size / 2.0
		puff.position = center - puff.size / 2.0
		puff.scale = Vector2.ONE * 0.4
		_root.add_child(puff)
		_root.move_child(puff, _card.get_index())
		var dir := Vector2.from_angle(TAU * i / 18.0 + randf() * 0.3)
		var t := create_tween().set_parallel()
		t.tween_property(puff, "position", puff.position + dir * randf_range(220.0, 380.0), 0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(puff, "scale", Vector2.ONE * randf_range(1.4, 2.2), 0.9).set_ease(Tween.EASE_OUT)
		t.tween_property(puff, "modulate:a", 0.0, 0.9).set_ease(Tween.EASE_IN)
		t.chain().tween_callback(puff.queue_free)


## Colored smoke coming out of the tube (little balls that grow and fade).
func _tube_smoke(color: Color) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.amount = 46
	p.lifetime = 1.0
	p.explosiveness = 0.95
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = 1.2
	p.initial_velocity_max = 3.2
	p.gravity = Vector3(0, 0.6, 0)
	p.damping_min = 1.5
	p.damping_max = 2.5
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.2
	var grow := Curve.new()
	grow.add_point(Vector2(0, 0.4))
	grow.add_point(Vector2(1, 1.6))
	p.scale_amount_curve = grow
	var fade := Gradient.new()
	fade.set_color(0, Color(color.lightened(0.35), 0.95))
	fade.set_color(1, Color(color, 0.0))
	p.color_ramp = fade
	var m := SphereMesh.new()
	m.radius = 0.18
	m.height = 0.36
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.vertex_color_use_as_albedo = true
	m.material = mat
	p.mesh = m
	_tube_node.get_parent().add_child(p)
	p.emitting = true
	get_tree().create_timer(1.6).timeout.connect(p.queue_free)


# ───────────── Card ─────────────
func _queue_card(id: int, is_new: bool = true) -> void:
	_card_queue.append(id)
	_card_new.append(is_new)
	if not _card.visible:
		_show_next_card()


func _show_next_card() -> void:
	if _card_queue.is_empty():
		_card_new.clear()
		_card.visible = false
		_card_rays.visible = false
		_update_dim()
		return
	var id: int = _card_queue.pop_front()
	var is_new_card: bool = _card_new.pop_front() if not _card_new.is_empty() else false
	var info := State.card_info(id)
	var rarity: String = info.get("rarity", "common")
	var color: Color = Palette.RARITY.get(rarity, Palette.TEXT)
	_card_title.text = ""          # the "NEW!" badge on the card already says that
	_card_title.visible = false
	var frame := "res://ui/frames/moldura-carta-%s.png" % FRAME.get(rarity, "comum")
	if ResourceLoader.exists(frame):
		_card_frame.texture = load(frame)
	_card_rarity.text = tr(Palette.RARITY_KEY.get(rarity, "RARITY_COMMON"))
	var pill_box := Palette._box(color, 22)
	pill_box.border_color = Palette.INK
	pill_box.set_border_width_all(3)
	pill_box.content_margin_left = 26
	pill_box.content_margin_right = 26
	_card_rarity_pill.add_theme_stylebox_override("panel", pill_box)
	_card_rarity.add_theme_color_override("font_color", Color.WHITE if rarity == "epic" else Palette.INK)
	_card_name.text = tr("CARD_%d_NAME" % id).to_upper()
	var n := _card_name.text.length()
	_card_name.add_theme_font_size_override("font_size", 30 if n <= 16 else (25 if n <= 24 else 20))
	_card_fact.text = tr("CARD_%d_FACT" % id)
	_card_source = str(info.get("source", ""))
	var source_btn: Button = _card.find_child("Source", true, false)
	source_btn.text = tr("BTN_SOURCE")
	source_btn.visible = _card_source != ""
	var photo := "res://ui/cards/%s" % info.get("photo_file", "")
	_card_photo.texture = load(photo) if str(info.get("photo_file", "")) != "" and ResourceLoader.exists(photo) else null
	_card.visible = true
	_update_dim()
	# Reward party: rays in the rarity color spinning behind, and the card arrives spinning and bouncing.
	var brand_new: bool = is_new_card and int(State.cards.get(str(id), 0)) <= 1
	_card_badge.visible = brand_new
	if _badge_tween:
		_badge_tween.kill()
	if brand_new:
		(_card_badge.get_node("Text") as Label).text = tr("CARD_NEW_BADGE")
		_card_badge.reset_size()
		_card_badge.pivot_offset = _card_badge.size / 2.0
		_card_badge.scale = Vector2.ZERO
		_badge_tween = create_tween()
		_badge_tween.tween_interval(0.45)
		_badge_tween.tween_property(_card_badge, "scale", Vector2.ONE * 1.25, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_badge_tween.tween_property(_card_badge, "scale", Vector2.ONE, 0.12)
		_badge_tween.tween_callback(func() -> void:
			_badge_tween = create_tween().set_loops()
			_badge_tween.tween_property(_card_badge, "scale", Vector2.ONE * 1.1, 0.45).set_trans(Tween.TRANS_SINE)
			_badge_tween.tween_property(_card_badge, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE))
	var festive := _card_reveal or brand_new
	_card_reveal = false
	_card_rays.visible = festive
	_card_rays.set_meta("color", color)
	_card_rays.queue_redraw()
	if festive:
		# The rays stay right behind the card (never on top of it).
		if _card_rays.get_index() > _card.get_index():
			_root.move_child(_card_rays, _card.get_index())
		_card.scale = Vector2(0.3, 0.3)
		_card.rotation_degrees = -12.0
		var t := create_tween().set_parallel()
		t.tween_property(_card, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(_card, "rotation_degrees", 0.0, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		_card_rays.modulate.a = 0.0
		t.tween_property(_card_rays, "modulate:a", 1.0, 0.4)
	Sfx.play(REVEAL_SOUND.get(rarity, "revelar-comum"))
	if id == State.CARD_AURORA:
		Sfx.play("aurora")


func _on_card_source() -> void:
	if _card_source != "":
		OS.shell_open(_card_source)


# ───────────── Album ─────────────
func _refresh_album() -> void:
	_album_title.text = tr("ALBUM_TITLE")
	var total := State.cards_total()
	_album_bar.value = 100.0 * State.cards.size() / maxf(total, 1)
	_album_count.text = "%d / %d" % [State.cards.size(), total]
	var reward := State.next_album_reward()
	var pages_done := 0
	for p in State.ALBUM_PAGES.size():
		if State.page_owned(p) == State.page_cards(p).size():
			pages_done += 1
	if not reward.is_empty():
		_album_next.text = tr("ALBUM_NEXT").format({"n": reward.left, "name": tr(reward.name)})
	elif State.cards.size() < total:
		_album_next.text = tr("ALBUM_LEFT").format({"n": total - State.cards.size()})
	else:
		_album_next.text = tr("ALBUM_DONE")
	_album_tabs.visible = false
	_album_page_title.visible = false
	# Tabs (kept for when there are more cards; today the album shows everything together)
	for c in _album_tabs.get_children():
		c.queue_free()
	for p in State.ALBUM_PAGES.size():
		var owned := State.page_owned(p)
		var count := State.page_cards(p).size()
		var tab := Button.new()
		tab.custom_minimum_size = Vector2(0, 112)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.set_meta("base_color", Palette.GOLD if p == _album_page else Palette.BUTTON)
		var col := VBoxContainer.new()
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_top = 8
		col.offset_bottom = -16
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 0)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tab.add_child(col)
		var ic := TextureRect.new()
		ic.texture = _page_icon(p)
		ic.custom_minimum_size = Vector2(0, 52)
		ic.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(ic)
		tab.set_meta("icon", ic)
		var lb := Label.new()
		lb.text = ("★ " if owned == count else "") + "%d/%d" % [owned, count]
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lb.add_theme_font_override("font", Palette.font(800))
		lb.add_theme_font_size_override("font_size", 20)
		lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(lb)
		tab.set_meta("label", lb)
		_style_key(tab, true)
		# Page with a new card not yet seen: red dot on the tab.
		for id in State.page_cards(p):
			if State.cards.has(str(id)) and not State.seen_cards.has(str(id)) and p != _album_page:
				var dot := Panel.new()
				var db := Palette._box(Palette.ALERT, 12)
				db.border_color = Palette.INK
				db.set_border_width_all(2)
				dot.add_theme_stylebox_override("panel", db)
				dot.size = Vector2(24, 24)
				dot.position = Vector2(4, 4)
				dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
				tab.add_child(dot)
				break
		tab.pressed.connect(func() -> void:
			Sfx.play("toque-botao")
			_album_page = p
			_refresh_album())
		_juice(tab)
		_album_tabs.add_child(tab)
	# Open page
	var page_owned := State.page_owned(_album_page)
	var page_ids := State.page_cards(_album_page)
	_album_page_title.text = "%s  %d/%d%s" % [tr(State.ALBUM_PAGES[_album_page][1]), page_owned, page_ids.size(), "  ★" if page_owned == page_ids.size() else ""]
	# All the cards together, big: 2 columns on phones and more columns on wide screens.
	for c in _album_grid.get_children():
		c.queue_free()
	# The album takes one column in the middle of the screen (like the rest of the UI): 2 cards per row
	# on phones and up to 3 on PC, always big.
	var vw := get_viewport().get_visible_rect().size.x
	var side := maxf(32.0, (vw - ALBUM_MAX_W) / 2.0)
	_album_box.content_margin_left = side
	_album_box.content_margin_right = side
	var room := vw - side * 2.0 - 24.0
	var cols := clampi(int((room + 16.0) / 300.0), 2, 3)
	_album_grid.columns = cols
	var tile_w := minf((room - (cols - 1) * 16.0) / cols, 320.0)
	var all_ids := State.card_ids()
	for id in all_ids:
		_album_grid.add_child(_album_tile(id, tile_w))
	# Saw the album: new cards stop being new (the badge goes away next time).
	for id in all_ids:
		if State.cards.has(str(id)):
			State.seen_cards[str(id)] = true


# ───────────── NASA data ─────────────
func _on_nasa() -> void:
	Sfx.play("abrir-menu")
	_nasa_text.text = "%s\n\n%s\n\n%s" % [tr("NASA_DONKI").format({"n": State.donki_count()}), tr("NASA_CARDS"), tr("NASA_MODEL")]
	_nasa.visible = true
	_update_dim()


# ───────────── Refresh the screen ─────────────
func _refresh() -> void:
	var rates: Dictionary = State.current_rates()
	for bar in BAR_KEYS:
		var value: float = State.get(bar)
		_bars[bar].value = value
		_bar_nums[bar].text = str(int(floor(value)))
		_bar_nums[bar].add_theme_color_override("font_color", Color.WHITE if value < State.low_line(bar) else Palette.INK)
		_bars[bar].cap = State.bar_cap(bar)
		var r: float = rates[bar]
		var rl: Label = _bar_rates[bar]
		rl.get_parent().modulate.a = 1.0 if absf(r) >= 0.05 else 0.0
		rl.text = ("%+d/sol" % roundi(r)) if absf(r) >= 1.0 else ("%+.1f/sol" % r)
		rl.add_theme_color_override("font_color", Palette.UP if r > 0.0 else Palette.DOWN)
		_bar_labels[bar].text = tr(BAR_KEYS[bar])
		_bars[bar].color = Palette.ALERT if value < State.low_line(bar) else Palette.BAR[bar]
	_sol_label.text = tr("POSTCARD").format({"n": State.sol})
	_start_lang.text = LANG_NAMES.get(State.locale, "EN")
	_start_lang.icon = _icon("flag_" + State.locale)
	_start_play.text = tr("BTN_PLAY")
	_start_nasa.text = tr("BTN_NASA")
	_btn_labels.build.text = tr("BTN_BUILD")
	_btn_labels.album.text = tr("BTN_ALBUM")
	_btn_labels.photo.text = tr("BTN_PHOTO")
	var unseen := State.unseen_count()
	_album_badge.visible = unseen > 0
	(_album_badge.get_node("N") as Label).text = str(unseen)
	_btn_labels.settings.text = tr("BTN_SETTINGS")
	if State.exploring():
		_btn_labels.explore.text = tr("EXPLORING_SHORT")   # "Mike is exploring": up to 2 lines inside the button
	elif State.tube_card != 0:
		_btn_labels.explore.text = tr("TUBE_READY")
	else:
		_btn_labels.explore.text = tr("BTN_EXPLORE")
	var explore_icon: TextureRect = _buttons.explore.get_meta("icon")
	explore_icon.custom_minimum_size.y = 40 if State.exploring() else 66
	# Only "Mike is exploring" breaks into 2 lines; "Explore" stays as before.
	_btn_labels.explore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if State.exploring() else TextServer.AUTOWRAP_OFF
	if not State.exploring():
		_btn_labels.explore.custom_minimum_size = Vector2.ZERO
	_style_key(_buttons.explore, not (State.explore_block_reason() != "" and State.tube_card == 0 and not State.exploring()))
	_style_key(_buttons.build, State.base_locked_reason() == "")
	_fit_button_texts()
	_hint.text = _status_text()
	_hint_chip.visible = _hint.text != ""
	_tut_update()
	_refresh_inventory()
	if _panel.visible:
		_refresh_panel()
	if _build_menu.visible:
		_refresh_build_menu()


## "1 sóis" becomes "1 sol" (and "1 sols", "1 soles" too).
func _sols(text: String) -> String:
	var re := RegEx.new()
	re.compile("(^|[^0-9/])1 (sóis|sols|soles)")
	return re.sub(text, "${1}1 sol", true)


## NASA date (2024-05-20) the way the child reads it: 20/05/2024 (in English, May 20, 2024).
func _nice_date(iso: String) -> String:
	var p := iso.split("-")
	if p.size() != 3:
		return iso
	if State.locale.begins_with("en"):
		var months := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		return "%s %d, %s" % [months[clampi(int(p[1]) - 1, 0, 11)], int(p[2]), p[0]]
	return "%s/%s/%s" % [p[2], p[1], p[0]]


func _status_text() -> String:
	return _sols(_status_raw())


func _status_raw() -> String:
	if State.nosignal_left > 0:
		return tr("NOSIGNAL_LEFT").format({"n": State.nosignal_left})
	if State.storm_active():
		return tr("STORM_SHIELDED" if State.storm_shielded else "STORM_INSIDE").format({"n": State.storm_left})
	var to_storm: int = State.next_storm_sol - State.sol
	if State.storm_warned and to_storm > 0 and to_storm <= State.STORM_WARN_SOLS:
		return tr("STORM_SOON").format({"n": to_storm})
	if mode == Mode.BUILD:
		return "" if State.tutorial < State.TUTORIAL_DONE else tr("TUT_BUILD")
	if mode == Mode.MOVE:
		return tr("MOVE_HINT")
	if State.oxygen <= 0.0:
		return tr("OUT_OXYGEN_HINT")
	if State.energy <= 0.0:
		return tr("OUT_ENERGY_HINT")
	if State.cold_left > 0:
		return tr("COLD_LEFT").format({"n": State.cold_left})
	if State.dust_left > 0 and State.count_items("solar") > 0:   # "dirty panels" only if there is a panel
		return tr("DUST_LEFT").format({"n": State.dust_left})
	if State.tutorial < State.TUTORIAL_DONE:
		return ""
	if State.items.size() <= 1:
		return tr("TUT_BUILD")
	if State.cards.size() <= 3 and not State.exploring() and State.tube_card == 0:
		return tr("TUT_EXPLORE")
	return ""


## How many of each plant the child has harvested, with its own 3D model as the icon.
func _refresh_inventory() -> void:
	if base == null:
		return
	for p in State.inventory:
		if int(State.inventory[p]) <= 0:
			continue
		if not _inv_labels.has(p):
			var chip := PanelContainer.new()
			var style := Palette._box(Palette.BG.darkened(0.35), 20)
			style.content_margin_left = 8
			style.content_margin_right = 16
			style.content_margin_top = 4
			style.content_margin_bottom = 4
			chip.add_theme_stylebox_override("panel", style)
			var row := HBoxContainer.new()
			chip.add_child(row)
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(48, 48)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture = _plant_icon(p)
			row.add_child(icon)
			var label := Label.new()
			label.add_theme_font_size_override("font_size", 26)
			row.add_child(label)
			chip.mouse_filter = Control.MOUSE_FILTER_STOP
			chip.gui_input.connect(func(e: InputEvent) -> void:
				if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
					_show_toast(tr("SNACK_HINT")))
			_inventory.add_child(chip)
			_inv_labels[p] = label
		_inv_labels[p].text = "× %d" % int(State.inventory[p])
	for p in _inv_labels:
		(_inv_labels[p] as Label).get_parent().get_parent().visible = int(State.inventory.get(p, 0)) > 0


## Renders the plant model once in a small separate viewport and uses the image as the icon.
func _plant_icon(p: String) -> Texture2D:
	if _icons.has(p):
		return _icons[p]
	var file := State.model_file(State.PLANTS[p].model)
	var vp := SubViewport.new()
	vp.size = Vector2i(96, 96)
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(vp)
	var model: Node3D = base._load_model(file, 1.0, 1.0)
	if model == null and p == "potato":
		model = base.potato_model()
		model.position.y = -0.1
	if model:
		vp.add_child(model)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.7
	vp.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	vp.add_child(light)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 1.4
	vp.add_child(cam)
	cam.position = Vector3(1.5, 1.6, 1.5)
	cam.look_at(Vector3(0.0, 0.45, 0.0))
	_icons[p] = vp.get_texture()
	return _icons[p]


func _refresh_build_menu() -> void:
	var sig := TranslationServer.get_locale()
	for type in State.BUILDABLE:
		sig += "|%s%s%s" % [type, State.is_unlocked(type), State.build_block_reason(type)]
	if sig == _build_sig and _build_grid.get_child_count() > 0:
		return   # nothing changed: don't rebuild (no blinking)
	_build_sig = sig
	for c in _build_grid.get_children():
		c.queue_free()
	for type in State.BUILDABLE:
		var def: Dictionary = State.ITEMS[type]
		if not State.is_unlocked(type):
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 176)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.set_meta("type", type)
		b.set_meta("base_color", Palette.BUTTON)
		var col := VBoxContainer.new()
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_top = 12
		col.offset_bottom = -20
		col.offset_left = 6
		col.offset_right = -6
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 4)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(col)
		var pic := TextureRect.new()
		pic.texture = _thumb(type)
		pic.custom_minimum_size = Vector2(0, 72)
		pic.size_flags_vertical = Control.SIZE_EXPAND_FILL
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(pic)
		b.set_meta("icon", pic)
		var name_label := Label.new()
		name_label.text = tr(def.name)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.max_lines_visible = 2
		name_label.add_theme_font_override("font", Palette.font(700))
		name_label.add_theme_font_size_override("font_size", 19)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(name_label)
		b.set_meta("label", name_label)
		if def.cost > 0:
			var pill := PanelContainer.new()
			var pill_box := Palette._box(Color("8e2219"), 16)
			pill_box.content_margin_left = 12
			pill_box.content_margin_right = 16
			pill_box.content_margin_top = 4
			pill_box.content_margin_bottom = 4
			pill_box.border_color = Palette.INK
			pill_box.set_border_width_all(2)
			pill.add_theme_stylebox_override("panel", pill_box)
			pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.add_child(pill)
			var cost_row := HBoxContainer.new()
			cost_row.add_theme_constant_override("separation", 4)
			cost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pill.add_child(cost_row)
			var bolt := TextureRect.new()
			bolt.texture = _icon("energy")
			bolt.custom_minimum_size = Vector2(24, 24)
			bolt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bolt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			bolt.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cost_row.add_child(bolt)
			var cost := Label.new()
			cost.text = str(def.cost)
			cost.add_theme_font_override("font", Palette.font(700))
			cost.add_theme_font_size_override("font_size", 19)
			cost.add_theme_color_override("font_color", Palette.TEXT)
			cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cost_row.add_child(cost)
		_style_key(b, State.build_block_reason(type) == "")
		if type in _build_info.WITH_INFO:
			b.pressed.connect(_open_build_info.bind(type))
		else:
			b.pressed.connect(_on_build_item.bind(type))
		_build_grid.add_child(b)


func _open_build_info(type: String) -> void:
	if _tut_blocks("build_" + type):
		return
	Sfx.play("toque-botao")
	_build_info.open(type)
	_tut_update()


func _update_dim() -> void:
	_dim.visible = _choice.visible or _info.visible or _card.visible or _tube.visible or _nasa.visible or (_settings != null and _settings.visible)


## Message from Mike at the top of the screen, like a phone notification: slides down, stays a bit and slides up.
## When it is a block (something is missing), the border turns red and the message shakes slightly.
func _show_toast(text: String, shake := false) -> void:
	_toast_label.text = text
	move_child(_toast, get_child_count() - 1)   # always on top of everything
	# Same width as the bars and buttons (in the middle of the screen), not the whole screen.
	var vw := get_viewport().get_visible_rect().size.x
	var w := minf(vw - 40.0, MAX_W)
	var x0 := (vw - w) / 2.0
	_toast_label.custom_minimum_size.x = w - 40.0 - 48.0 - 18.0   # margin (16 + 24), face (48), gap (16)
	_toast_style.border_color = Palette.ALERT if shake else Palette.INK
	_toast.custom_minimum_size.x = w
	_toast.reset_size()
	_toast.position.x = x0
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	# Appears right below the bars (never on top of them): slides down a little and disappears on its own.
	var y := _toast_top()
	if not _toast_down:
		_toast.position.y = y - 24.0
		_toast.modulate.a = 0.0
		_toast_tween.set_parallel()
		_toast_tween.tween_property(_toast, "position:y", y, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.2)
		_toast_tween.set_parallel(false)   # the rest (wait 5 s, then fade) comes one after the other
	else:
		_toast.position.y = y
		_toast.modulate.a = 1.0
	_toast_down = true
	if shake:
		for d in [14.0, -12.0, 8.0, -4.0, 0.0]:
			_toast_tween.tween_property(_toast, "position:x", x0 + d, 0.05)
	_toast_tween.tween_interval(5.0)
	_toast_tween.tween_callback(func() -> void: _toast_down = false)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.3)


## Bars and buttons in the middle of the screen, at most MAX_W wide, with margins on the sides.
func _fit_layout() -> void:
	var vw := get_viewport().get_visible_rect().size.x
	var side := maxf(32.0, (vw - MAX_W) / 2.0)   # 16 dp margin on phones
	for box in [_top_box, _bottom_box]:
		if box:
			box.offset_left = side
			box.offset_right = -side


func _bars_bottom() -> float:
	return (_bar_box.get_global_rect().end.y + 10.0) if _bar_box else 18.0


func _toast_top() -> float:
	return _bars_bottom() + (_tut_card.size.y + 8.0 if _tut_card and _tut_card.visible else 0.0)


# ───────────── First-minute tutorial ─────────────
func _build_tutorial() -> void:
	_tut_card = PanelContainer.new()
	var box := Palette.paper()
	box.set_corner_radius_all(14)
	box.set_border_width_all(3)
	box.shadow_offset = Vector2(0, 6)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	_tut_card.add_theme_stylebox_override("panel", box)
	_tut_card.visible = false
	_tut_card.position = Vector2(16, 18)
	_tut_card.theme = _root.theme
	_tut_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tut_card)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	_tut_card.add_child(row)
	var face := TextureRect.new()
	var head := AtlasTexture.new()
	head.atlas = load("res://ui/icons/mike.png")
	head.region = Rect2(300, 230, 290, 290)
	face.texture = head
	face.custom_minimum_size = Vector2(50, 50)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(face)
	_tut_label = Label.new()
	_tut_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tut_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tut_label.add_theme_font_size_override("font_size", 24)
	_tut_label.add_theme_color_override("font_color", Palette.INK)
	row.add_child(_tut_label)
	var skip := Button.new()
	_tut_skip = skip
	skip.flat = true
	skip.add_theme_font_override("font", Palette.font(700))
	skip.add_theme_font_size_override("font_size", 24)
	skip.add_theme_color_override("font_color", Palette.BG)
	skip.custom_minimum_size = Vector2(110, 72)
	skip.size_flags_vertical = Control.SIZE_SHRINK_END
	skip.pressed.connect(func() -> void:
		State.finish_tutorial()
		_tut_update())
	row.add_child(skip)
	_tut_arrow = TextureRect.new()
	_tut_arrow.texture = load("res://ui/icons/seta.svg")
	_tut_arrow.custom_minimum_size = Vector2(72, 90)
	_tut_arrow.size = Vector2(72, 90)
	_tut_arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tut_arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_tut_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut_arrow.visible = false
	add_child(_tut_arrow)
	_tut_ring = Panel.new()
	var ring := StyleBoxFlat.new()
	ring.bg_color = Color(0, 0, 0, 0)
	ring.border_color = Palette.GOLD
	ring.set_border_width_all(6)
	ring.set_corner_radius_all(26)
	ring.shadow_color = Color(Palette.GOLD, 0.55)
	ring.shadow_size = 14
	_tut_ring.add_theme_stylebox_override("panel", ring)
	_tut_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut_ring.visible = false
	add_child(_tut_ring)


## Advances the tutorial based on what the child has already done and picks the message for the current step.
## Steps: 0 solar panel · 1 greenhouse · 2 plant · 3 explore · 4 open the tube · 5 congratulations.
func _tut_update() -> void:
	var s := State.tutorial
	if s >= State.TUTORIAL_DONE or _start.visible:
		_tut_card.visible = false
		_tut_arrow.visible = false
		return
	if s == 0 and State.count_items("solar") > 0:
		s = 1
	if s == 1 and State.count_items("greenhouse") > 0:
		s = 2
	if s == 2 and State._has_growing_plant():
		s = 3
	if s == 3 and (State.exploring() or State.tube_card != 0):
		s = 4
	if s == 4 and not State.exploring() and State.tube_card == 0:
		s = 5
	if s != State.tutorial:
		State.tutorial = s
		Sfx.play("toque-botao")
	var text := ""
	match s:
		0, 1:
			var type := "solar" if s == 0 else "greenhouse"
			if State.tutorial_needs_energy() and mode != Mode.BUILD:
				text = tr("TUTO_WAIT_ENERGY")
			elif mode == Mode.BUILD:
				text = tr("TUTO_PLACE")
			elif _build_info.visible:
				text = tr("TUTO_CONFIRM")
			elif _build_menu.visible:
				text = tr("TUTO_PICK").format({"name": tr(State.ITEMS[type].name)})
			else:
				text = tr("TUTO_HELLO" if s == 0 else "TUTO_GREENHOUSE")
		2:
			text = tr("TUTO_PICK").format({"name": tr("P_LETTUCE")}) if _panel.visible else tr("TUTO_PLANT")
		3:
			text = tr("TUTO_EXPLORE")
		4:
			text = tr("TUTO_TUBE") if _tube.visible else _sols(tr("TUTO_WAIT").format({"n": maxi(State.explore_left, 1)}))
		5:
			text = tr("TUTO_DONE")
			if _tut_done_at < 0.0:
				_tut_done_at = Time.get_ticks_msec() / 1000.0
	_tut_label.text = text
	_tut_skip.text = tr("TUTO_SKIP")
	_tut_skip.visible = s < 5
	var vwt := get_viewport().get_visible_rect().size.x
	var w := minf(vwt - 40.0, MAX_W)
	_tut_card.position.x = (vwt - w) / 2.0
	_tut_card.custom_minimum_size.x = w
	_tut_label.custom_minimum_size.x = w - 32.0 - 50.0 - 32.0 - (_tut_skip.get_minimum_size().x + 14.0 if s < 5 else 0.0)
	_tut_card.size = Vector2(w, 0.0)
	_tut_card.reset_size()
	if not _tut_card.visible:
		_tut_card.visible = true
		_tut_card.modulate.a = 0.0
		_tut_card.position.y = _bars_bottom()
		create_tween().tween_property(_tut_card, "modulate:a", 1.0, 0.3)


## What the tutorial asks to tap now: a button (gets the golden frame), a point on the base
## (gets the arrow, well above the building) or nothing.
func _tut_target() -> Variant:
	if not _tut_card.visible or _choice.visible or _info.visible or _card.visible or _nasa.visible or _album.visible:
		return null
	match State.tutorial:
		0, 1:
			var type := "solar" if State.tutorial == 0 else "greenhouse"
			if mode == Mode.BUILD:
				return null
			if _build_info.visible:
				return _build_info._build_button
			if _build_menu.visible:
				for b in _build_grid.get_children():
					if b is Button and not b.is_queued_for_deletion() and b.get_meta("type", "") == type:
						return b
				return null
			return _buttons.build
		2:
			if _panel.visible:
				for b in _panel_buttons.find_children("*", "Button", true, false):
					if not b.is_queued_for_deletion() and not b.get_parent().is_queued_for_deletion():
						return b
				return null
			for k in State.items:
				if State.items[k].type == "greenhouse":
					var node: Node3D = base._nodes.get(k)
					if node:
						var box: AABB = node.global_transform * base._merged_aabb(node)
						return base.camera.unproject_position(Vector3(box.get_center().x, box.end.y + 0.6, box.get_center().z))
		3:
			return _buttons.explore
		4:
			if _tube.visible:
				return _tube
	return null


## The point the tutorial indicates (for the tests): the top middle of the button, the base point, or INF.
func _tut_point() -> Vector2:
	var t: Variant = _tut_target()
	if t is Control:
		var r := (t as Control).get_global_rect()
		return Vector2(r.get_center().x, r.position.y)
	if t is Vector2:
		return t
	return Vector2.INF


## The name of what Mike asked to tap (for the "First, tap ...").
func _tut_target_name() -> String:
	match State.tutorial:
		0, 1:
			var type := "solar" if State.tutorial == 0 else "greenhouse"
			if mode == Mode.BUILD:
				return tr("TUTO_SQUARE")
			if _build_info.visible:
				return tr("INFO_BUILD")
			if _build_menu.visible:
				return tr(State.ITEMS[type].name)
			return tr("BTN_BUILD")
		2:
			return tr("P_LETTUCE") if _panel.visible else tr("B_GREENHOUSE")
		3:
			return tr("BTN_EXPLORE")
	return ""


## In the tutorial, only tapping what Mike asked counts. Tapped something else: he reminds what it is (and nothing happens).
func _tut_blocks(what: String) -> bool:
	if State.tutorial >= State.TUTORIAL_DONE or _start.visible:
		return false
	var allowed := false
	match State.tutorial:
		0, 1:
			var type := "solar" if State.tutorial == 0 else "greenhouse"
			allowed = what in ["build", "place", "build_" + type]
		2:
			allowed = what in ["greenhouse", "plant"]
		3:
			allowed = what == "explore"
		4:
			allowed = what in ["explore", "tube"]
		_:
			allowed = true
	if allowed:
		return false
	if State.tutorial == 4 and not _tube.visible:
		_show_toast(_sols(tr("TUTO_WAIT").format({"n": maxi(State.explore_left, 1)})))
	else:
		_show_toast(tr("TUTO_NUDGE").format({"name": _tut_target_name()}), true)
	Sfx.play("travado")
	return true


## Album: drag the finger (or the mouse) anywhere on the cards to scroll, with a little glide at the end.
## Runs before the buttons get the event, so it works on top of the cards too.
func _input(event: InputEvent) -> void:
	if _album == null or not _album.visible or _album_scroll == null:
		return
	var d := _album_drag
	var is_press: bool = (event is InputEventScreenTouch) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)
	if is_press:
		if event.pressed:
			if _album_scroll.get_global_rect().has_point(event.position) and not _card.visible and not _info.visible:
				d.down = true
				d.moved = false
				d.start = event.position
				d.from = float(_album_scroll.scroll_vertical)
				d.last_y = event.position.y
				d.speed = 0.0
		elif d.down:
			d.down = false
			# The card buttons get this same release right after: only then forget the drag.
			(func() -> void: d.moved = false).call_deferred()
		return
	var is_drag: bool = (event is InputEventScreenDrag) or (event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT != 0)
	if is_drag and d.down:
		var dy: float = event.position.y - d.start.y
		if not d.moved and absf(dy) > 12.0:   # small wiggles still count as a tap
			d.moved = true
		if d.moved:
			_album_scroll.scroll_vertical = int(d.from - dy)
			if event.position.y != d.last_y:   # on phones the same move also arrives as an emulated mouse move
				d.speed = lerpf(float(d.speed), (d.last_y - event.position.y) / maxf(get_process_delta_time(), 0.001), 0.5)
				d.last_y = event.position.y
			get_viewport().set_input_as_handled()


func _album_glide(delta: float) -> void:
	var d := _album_drag
	if _album_scroll == null or d.down or absf(float(d.speed)) < 20.0:
		return
	_album_scroll.scroll_vertical += int(float(d.speed) * delta)
	d.speed = float(d.speed) * pow(0.04, delta)   # slows down in about a second


func _process(delta: float) -> void:
	_album_glide(delta)
	if _tut_card == null:
		return
	_place_panel(delta)
	if _card_rays.visible:
		_card_rays.queue_redraw()
	var vp := get_viewport().get_visible_rect().size
	for p in _popups:
		if p.visible:
			var m: Vector2 = p.get_combined_minimum_size()
			if not p.size.is_equal_approx(m):
				p.size = m
			p.position = ((vp - m) / 2.0).round()
	for p in [_tut_card, _toast]:
		var want: float = p.get_combined_minimum_size().y
		if p.visible and absf(p.size.y - want) > 1.0:
			p.size.y = want
	if _tut_card.visible:
		_tut_card.position.y = _bars_bottom()
	if State.tutorial == 5 and _tut_done_at > 0.0 and Time.get_ticks_msec() / 1000.0 - _tut_done_at > 5.0:
		State.finish_tutorial()
		_tut_update()
	var target: Variant = _tut_target()
	var t := Time.get_ticks_msec() / 1000.0
	_tut_ring.visible = target is Control
	if _tut_ring.visible:
		move_child(_tut_ring, get_child_count() - 1)
		var r := (target as Control).get_global_rect().grow(8.0 + sin(t * 6.0) * 3.0)
		_tut_ring.position = r.position
		_tut_ring.size = r.size
		_tut_ring.modulate.a = 0.6 + 0.4 * sin(t * 6.0)
	_tut_arrow.visible = target is Vector2
	if _tut_arrow.visible:
		move_child(_tut_arrow, get_child_count() - 1)
		var bob := sin(t * 7.0) * 10.0
		_tut_arrow.position = (target as Vector2) - Vector2(_tut_arrow.size.x / 2.0, _tut_arrow.size.y + 6.0 + bob)


# ───────────── 3D icons ─────────────
## All the game icons are little 3D pieces (scripts/icons3d.gd), rendered once and cached.
func _icon(key: String) -> Texture2D:
	if _icon_cache.has(key):
		return _icon_cache[key]
	var model: Node3D
	match key:
		"energy":
			model = Icons3D.energy()
		"oxygen":
			model = Icons3D.oxygen()
		"shield":
			model = Icons3D.shield()
		"build":
			model = Icons3D.hammer()
		"explore":
			model = Icons3D.tube()
		"album":
			model = Icons3D.cards(_frames(["comum", "raro", "lendario"]))
		"card":
			model = Icons3D.cards(_frames(["lendario"]))
		"photo":
			model = Icons3D.camera()
		"settings":
			model = Icons3D.gear()
		"move":
			model = Icons3D.move_arrows()
		"turn":
			model = Icons3D.turn_arrow()
		"trash":
			model = Icons3D.trash()
		"nasa":
			model = _item_model("antenna", 1.0)
		_:
			if key.begins_with("flag_"):
				model = Icons3D.flag(load(LANG_FLAGS.get(key.trim_prefix("flag_"), LANG_FLAGS.en)))
			else:
				model = Node3D.new()
	_icon_cache[key] = Icons3D.render(self, model, 160, 1.3)
	return _icon_cache[key]


func _frames(names: Array) -> Array:
	var out := []
	for n in names:
		var path := "res://ui/frames/moldura-carta-%s.png" % n
		out.append(load(path) if ResourceLoader.exists(path) else null)
	return out


## The 3D model of a building (level 1), centered, for the thumbnail and for the spinning panel.
func _item_model(type: String, fit := 1.0) -> Node3D:
	var holder := Node3D.new()
	var file := State.model_file(State.ITEMS[type].get("model", ""), 1)
	var m: Node3D = base._load_model(file, fit, fit)
	if m:
		var box: AABB = base._merged_aabb(m)
		m.position.y -= (box.position.y + box.size.y / 2.0) * m.scale.y
		holder.add_child(m)
	return holder


## 3D thumbnail of each item in the Build menu (the child sees what it is before tapping).
func _thumb(type: String) -> Texture2D:
	var k := "thumb_" + type
	if not _icon_cache.has(k):
		_icon_cache[k] = Icons3D.render(self, _item_model(type), 160, 1.25, false, Vector3(1.0, 0.85, 1.7))
	return _icon_cache[k]


# ───────────── Settings (gear in the corner) ─────────────
func _build_settings() -> void:
	_settings = _popup(620, "paper")
	var sbox: VBoxContainer = _settings.get_child(0)
	sbox.add_theme_constant_override("separation", 16)
	var head := HBoxContainer.new()
	sbox.add_child(head)
	_set_title = _title_label(42)
	_set_title.add_theme_color_override("font_color", Palette.BG)
	_set_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_set_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_set_title)
	head.add_child(_red_x(func() -> void:
		_settings.visible = false
		_update_dim()))
	_set_lang = _wrap_label("", 28)
	_set_lang.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_set_lang.add_theme_color_override("font_color", Palette.INK)
	sbox.add_child(_set_lang)
	_set_flags = HBoxContainer.new()
	_set_flags.add_theme_constant_override("separation", 16)
	sbox.add_child(_set_flags)
	for l in ["pt_BR", "en", "es", "fr"]:
		var f := Button.new()
		f.custom_minimum_size = Vector2(0, 110)
		f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f.icon = _icon("flag_" + l)
		f.expand_icon = true
		f.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		f.set_meta("lang", l)
		f.pressed.connect(func() -> void:
			Sfx.play("toque-botao")
			State.set_locale(l)
			_refresh_settings())
		_set_flags.add_child(f)
	_set_music = _key_button(func() -> void:
		State.music_on = not State.music_on
		Sfx.apply_settings()
		State.save_game()
		_refresh_settings())
	sbox.add_child(_set_music)
	_set_sounds = _key_button(func() -> void:
		State.sounds_on = not State.sounds_on
		State.save_game()
		Sfx.play("toque-botao")
		_refresh_settings())
	sbox.add_child(_set_sounds)
	_set_tutorial = _key_button(func() -> void:
		_settings.visible = false
		_update_dim()
		_choice.visible = false
		_info.visible = false
		State.restart_tutorial()
		_tut_done_at = -1.0
		_update_dim()
		_tut_update(), true)
	sbox.add_child(_set_tutorial)
	_set_nasa = _key_button(func() -> void:
		_settings.visible = false
		_on_nasa(), true)
	sbox.add_child(_set_nasa)


func _open_settings() -> void:
	if _tut_blocks("settings"):
		return
	Sfx.play("abrir-menu")
	_build_menu.visible = false
	_close_panel()
	_refresh_settings()
	_settings.visible = true
	_update_dim()


func _refresh_settings() -> void:
	if _settings == null:
		return
	_set_title.text = tr("SET_TITLE")
	_set_lang.text = tr("SET_LANG")
	for f in _set_flags.get_children():
		var on: bool = f.get_meta("lang") == State.locale
		for s in ["normal", "hover", "pressed", "focus"]:
			f.add_theme_stylebox_override(s, Palette.key(Palette.GOLD if on else Palette.BUTTON, s == "pressed"))
	for pair in [[_set_music, "SET_MUSIC", State.music_on], [_set_sounds, "SET_SOUNDS", State.sounds_on]]:
		var b: Button = pair[0]
		b.text = "%s: %s" % [tr(pair[1]), tr("SET_ON" if pair[2] else "SET_OFF")]
		for s in ["normal", "hover", "disabled"]:
			b.add_theme_stylebox_override(s, Palette.key(Palette.GOLD if pair[2] else Palette.BUTTON))
		b.add_theme_stylebox_override("pressed", Palette.key(Palette.GOLD if pair[2] else Palette.BUTTON, true))
	_set_tutorial.text = tr("SET_TUTORIAL")
	_set_nasa.text = tr("BTN_NASA")
	_set_nasa.icon = _icon("nasa")
	_set_nasa.expand_icon = true
	_set_nasa.add_theme_constant_override("icon_max_width", 64)


## Round red button with X: closes the window (sits in the top right corner, away from the main button).
func _red_x(action: Callable) -> Button:
	var x := Button.new()
	x.text = "X"
	x.custom_minimum_size = Vector2(96, 96)
	x.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	x.add_theme_font_size_override("font_size", 38)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		x.add_theme_color_override(c, Color.WHITE)
	var xb := Palette._box(Palette.ALERT, 48)
	xb.border_color = Color.WHITE
	xb.set_border_width_all(4)
	for s in ["normal", "hover", "pressed", "focus"]:
		x.add_theme_stylebox_override(s, xb)
	x.pressed.connect(action)
	_juice(x)
	return x


## Key on (its color, dark text) or off (dark wine, cream text and dimmed icon).
## Off is not transparent: it stays clearly visible over the Mars ground.
func _style_key(b: Button, enabled: bool) -> void:
	var color: Color = b.get_meta("base_color", Palette.BUTTON) if enabled else Palette.OFF
	for s in ["normal", "hover", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, Palette.key(color))
	b.add_theme_stylebox_override("pressed", Palette.key(color, true))
	var ink: Color = Palette.TEXT if not enabled else (Palette.INK if color == Palette.GOLD else Palette.INK_DEEP)
	var lb: Label = b.get_meta("label") if b.has_meta("label") else null
	if lb:
		lb.add_theme_color_override("font_color", ink)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, ink)
	var ic: TextureRect = b.get_meta("icon") if b.has_meta("icon") else null
	if ic:
		ic.modulate = Color.WHITE if enabled else Color(0.6, 0.6, 0.6)


## Each bottom button name fits on one line (shrinks the font if needed, as in "Construire").
func _fit_button_texts() -> void:
	for k in _btn_labels:
		if not _buttons.has(k):
			continue
		var lb: Label = _btn_labels[k]
		var room: float = _buttons[k].size.x - 18.0
		if room < 40.0:
			continue   # the button has no width yet (before the first draw)
		var size := 26 if k == "explore" else 21
		var f: Font = Palette.font(700)
		var lines := 2 if lb.autowrap_mode != TextServer.AUTOWRAP_OFF else 1
		if lines > 1:
			size = 21   # 2 lines + the icon must fit in the golden box
			room -= 12.0
		while size > 16 and room > 0.0 and not _text_fits(f, lb.text, size, room, lines):
			size -= 1
		if lines > 1:
			# A wrapped label has no height of its own inside the box: reserve the lines it needs.
			var extra: float = lb.get_theme_stylebox("normal").get_minimum_size().y + lb.get_theme_constant("line_spacing") * (lines - 1)
			lb.custom_minimum_size = Vector2(0.0, f.get_height(size) * lines + extra + 2.0)
		lb.add_theme_font_size_override("font_size", size)


## Fits in "lines" lines of width "room": no word wider than the room and the whole text within the lines.
func _text_fits(f: Font, text: String, size: int, room: float, lines: int) -> bool:
	if lines <= 1:
		return f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= room
	for w in text.split(" ", false):
		if f.get_string_size(w, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > room:
			return false
	return f.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, room, size).y <= f.get_height(size) * lines + 1.0


## Every button responds right away: sinks when pressed and bounces when released (research, item 16).
func _juice(b: Button) -> void:
	b.resized.connect(func() -> void: b.pivot_offset = b.size / 2.0)
	b.button_down.connect(func() -> void: create_tween().tween_property(b, "scale", Vector2(0.93, 0.93), 0.06))
	b.button_up.connect(func() -> void:
		create_tween().tween_property(b, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))


# ───────────── Screen assembly ─────────────
func _build_top() -> void:
	var top := VBoxContainer.new()
	_top_box = top
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 32
	top.offset_right = -32
	top.offset_top = 32
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", 16)
	_root.add_child(top)

	# The 3 bars are loose glass tubes on the screen (no dark plate behind): more of the base shows.
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(rows)
	_bar_box = rows
	for bar in BAR_KEYS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rows.add_child(row)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(40, 40)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _icon(bar)
		row.add_child(icon)
		var label := Label.new()   # the name is kept (hidden on screen: the icon already says what it is)
		label.visible = false
		row.add_child(label)
		var pb := TubeBar.new()
		pb.custom_minimum_size = Vector2(0, 32)
		pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pb.color = Palette.BAR[bar]
		row.add_child(pb)
		_bars[bar] = pb
		_bar_labels[bar] = label
		# Inside the bar: how much there is now (left) and how much it changes per sol (right).
		var num := Label.new()
		num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		num.offset_left = 18
		num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		num.add_theme_font_override("font", Palette.font(700))
		num.add_theme_font_size_override("font_size", 22)
		num.add_theme_color_override("font_color", Palette.INK)
		pb.add_child(num)
		var chip := PanelContainer.new()
		var chip_box := Palette._box(Palette.PLATE, 10)
		chip_box.content_margin_left = 8
		chip_box.content_margin_right = 8
		chip_box.content_margin_top = 2
		chip_box.content_margin_bottom = 2
		chip.add_theme_stylebox_override("panel", chip_box)
		chip.custom_minimum_size = Vector2(88, 32)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(chip)
		var rate := Label.new()
		rate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rate.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		rate.add_theme_font_override("font", Palette.font(700))
		rate.add_theme_font_size_override("font_size", 19)
		chip.add_child(rate)
		_bar_nums[bar] = num
		_bar_rates[bar] = rate

	# The "Sol N · Gale Crater" is a plate in the corner, slightly crooked (nothing all centered).
	var pill := PanelContainer.new()
	pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pill.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var pill_row := HBoxContainer.new()
	pill_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(pill_row)
	pill_row.add_child(pill)

	_sol_label = Label.new()
	_sol_label.add_theme_font_override("font", Palette.font(700))
	_sol_label.add_theme_font_size_override("font_size", 24)
	_sol_label.add_theme_color_override("font_color", Palette.TEXT)
	_sol_label.add_theme_color_override("font_outline_color", Palette.BG.darkened(0.3))
	_sol_label.add_theme_constant_override("outline_size", 8)
	pill.add_child(_sol_label)

	_inventory = HFlowContainer.new()
	_inventory.alignment = FlowContainer.ALIGNMENT_CENTER
	_inventory.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_inventory.add_theme_constant_override("h_separation", 16)
	top.add_child(_inventory)

	_hint_chip = PanelContainer.new()
	var hint_box := Palette._box(Color("4b171b"), 20)
	hint_box.content_margin_left = 16
	hint_box.content_margin_right = 16
	hint_box.content_margin_top = 8
	hint_box.content_margin_bottom = 8
	_hint_chip.add_theme_stylebox_override("panel", hint_box)
	_hint_chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_hint_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_hint_chip)
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_override("font", Palette.font(700))
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.add_theme_color_override("font_color", Palette.TEXT)
	_hint_chip.add_child(_hint)


func _build_bottom() -> void:
	var bottom := VBoxContainer.new()
	_bottom_box = bottom
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 32
	bottom.offset_right = -32
	bottom.offset_bottom = -32
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_theme_constant_override("separation", 16)
	_root.add_child(bottom)

	_build_menu = Plate.new()
	_build_menu.visible = false
	bottom.add_child(_build_menu)
	_build_grid = GridContainer.new()
	_build_grid.columns = 3
	_build_grid.add_theme_constant_override("h_separation", 16)
	_build_grid.add_theme_constant_override("v_separation", 16)
	_build_menu.add_child(_build_grid)

	# Building menu: a paper card floating ON TOP of the tapped building, with a
	# little tail pointing at it. Name and level, a sentence about what it does, how much it makes per sol
	# and the actions as a list (one under the other). Tapping outside or on another building closes it.
	_panel = PanelContainer.new()
	var card := Palette.paper()
	card.set_corner_radius_all(14)
	card.set_border_width_all(3)
	card.shadow_offset = Vector2(0, 10)
	card.shadow_size = 4
	card.content_margin_left = 24
	card.content_margin_right = 24
	card.content_margin_top = 24
	card.content_margin_bottom = 24
	_panel.add_theme_stylebox_override("panel", card)
	_panel.custom_minimum_size = Vector2(448, 0)
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_panel)
	_panel_tail = Polygon2D.new()
	_panel_tail.polygon = PackedVector2Array([Vector2(-22, -6), Vector2(22, -6), Vector2(0, 24)])
	_panel_tail.color = Palette.PAPER
	_panel.add_child(_panel_tail)
	var tail_edge := Line2D.new()
	tail_edge.points = PackedVector2Array([Vector2(-22, -1), Vector2(0, 24), Vector2(22, -1)])
	tail_edge.width = 3.0
	tail_edge.default_color = Palette.INK
	tail_edge.joint_mode = Line2D.LINE_JOINT_ROUND
	_panel_tail.add_child(tail_edge)
	var pbox := VBoxContainer.new()
	pbox.add_theme_constant_override("separation", 16)
	_panel.add_child(pbox)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 16)
	pbox.add_child(head)
	_panel_title = Label.new()
	_panel_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel_title.add_theme_font_size_override("font_size", 34)
	_panel_title.add_theme_color_override("font_color", Palette.BG)
	head.add_child(_panel_title)
	var pill := PanelContainer.new()
	var pill_box := Palette._box(Palette.GOLD, 18)
	pill_box.content_margin_left = 14
	pill_box.content_margin_right = 14
	pill_box.content_margin_top = 4
	pill_box.content_margin_bottom = 4
	pill.add_theme_stylebox_override("panel", pill_box)
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(pill)
	_panel_level = Label.new()
	_panel_level.add_theme_font_size_override("font_size", 22)
	_panel_level.add_theme_color_override("font_color", Palette.INK)
	pill.add_child(_panel_level)
	_panel_desc = Label.new()
	_panel_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel_desc.add_theme_font_size_override("font_size", 25)
	_panel_desc.add_theme_color_override("font_color", Palette.INK)
	pbox.add_child(_panel_desc)
	_panel_stats = HBoxContainer.new()
	_panel_stats.add_theme_constant_override("separation", 8)
	pbox.add_child(_panel_stats)
	_panel_info = _wrap_label("", 25)
	_panel_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_panel_info.add_theme_color_override("font_color", Palette.BG)
	pbox.add_child(_panel_info)
	_panel_buttons = VBoxContainer.new()
	_panel_buttons.add_theme_constant_override("separation", 16)
	pbox.add_child(_panel_buttons)

	# At the bottom, within thumb reach. Explore is the main action: bigger, golden and taller than the others.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.alignment = BoxContainer.ALIGNMENT_END
	bottom.add_child(row)
	for k in ["build", "album", "explore", "photo", "settings"]:
		var main_action: bool = k == "explore"
		var b := Button.new()
		var gear := false   # the gear is now a button like the others, with the name below
		b.custom_minimum_size = Vector2(0, 136 if main_action else 112)   # 56 dp: easy tap for a child
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_SHRINK_END
		b.size_flags_stretch_ratio = 1.3 if main_action else 1.0
		b.set_meta("base_color", Palette.GOLD if main_action else Palette.BUTTON)
		# Inside: the big 3D icon on top and the bold name below (built by hand, so each one has its own contrast).
		var col := VBoxContainer.new()
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_top = 12
		col.offset_bottom = -20
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 0)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(col)
		var ic := TextureRect.new()
		ic.texture = _icon(k)
		ic.custom_minimum_size = Vector2(0, 66 if main_action else 54)
		ic.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(ic)
		b.set_meta("icon", ic)
		if not gear:
			var lb := Label.new()
			lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lb.add_theme_font_override("font", Palette.font(700))
			lb.add_theme_font_size_override("font_size", 26 if main_action else 21)
			# A long text never widens the button (that pushed the icon out of the box): it is cut with "…".
			lb.clip_text = true
			lb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			if main_action:
				lb.max_lines_visible = 2   # "Mike is / exploring" (the 2 lines are turned on in _refresh)
			lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.add_child(lb)
			b.set_meta("label", lb)
			_btn_labels[k] = lb
		_style_key(b, true)
		b.resized.connect(_fit_button_texts)   # the text adjusts when the button gets its real width
		_juice(b)
		row.add_child(b)
		_buttons[k] = b
	_buttons.build.pressed.connect(_on_build)
	_buttons.explore.pressed.connect(_on_explore)
	_buttons.album.pressed.connect(_on_album)
	_buttons.photo.pressed.connect(_on_photo)
	_album_badge = PanelContainer.new()
	var ab := Palette._box(Palette.ALERT, 18)
	ab.border_color = Palette.INK
	ab.set_border_width_all(3)
	ab.content_margin_left = 10
	ab.content_margin_right = 10
	ab.content_margin_top = 0
	ab.content_margin_bottom = 2
	_album_badge.add_theme_stylebox_override("panel", ab)
	_album_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_album_badge.position = Vector2(-10, -14)
	var abl := Label.new()
	abl.name = "N"
	abl.add_theme_font_override("font", Palette.font(800))
	abl.add_theme_font_size_override("font_size", 22)
	abl.add_theme_color_override("font_color", Color.WHITE)
	_album_badge.add_child(abl)
	_buttons.album.add_child(_album_badge)
	_buttons.settings.pressed.connect(_open_settings)
	_gear = _buttons.settings


func _build_messages() -> void:
	_toast = PanelContainer.new()
	_toast_style = Palette.paper()
	_toast_style.set_corner_radius_all(14)
	_toast_style.set_border_width_all(3)
	_toast_style.shadow_offset = Vector2(0, 6)
	_toast_style.content_margin_left = 16
	_toast_style.content_margin_right = 24
	_toast_style.content_margin_top = 12
	_toast_style.content_margin_bottom = 12
	_toast.add_theme_stylebox_override("panel", _toast_style)
	_toast.modulate.a = 0.0
	_toast.position.y = -400.0
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	_toast.add_child(row)
	# Mike's little face, like the photo of whoever sent the message.
	var face := TextureRect.new()
	var head := AtlasTexture.new()
	head.atlas = load("res://ui/icons/mike.png")
	head.region = Rect2(300, 230, 290, 290)
	face.texture = head
	face.custom_minimum_size = Vector2(48, 48)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(face)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 0)
	row.add_child(col)
	var from := Label.new()
	from.text = "Mike"
	from.add_theme_font_override("font", Palette.font(700))
	from.add_theme_font_size_override("font_size", 22)
	from.add_theme_color_override("font_color", Palette.BG)
	col.add_child(from)
	_toast_label = Label.new()
	_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_label.add_theme_font_size_override("font_size", 24)
	_toast_label.add_theme_color_override("font_color", Palette.INK)
	col.add_child(_toast_label)


## Album as a sticker book: 5 pages (one per theme), each with its own progress.
## A missing card shows the rarity frame and a "?" (makes you want to find it); the new one gets the NEW badge.
func _build_album() -> void:
	_album = PanelContainer.new()
	_album.set_anchors_preset(Control.PRESET_FULL_RECT)
	var album_box := Palette._box(Palette.BG.darkened(0.15), 0)
	_album_box = album_box
	album_box.content_margin_left = 32
	album_box.content_margin_right = 32
	album_box.content_margin_top = 32
	album_box.content_margin_bottom = 32
	_album.add_theme_stylebox_override("panel", album_box)
	_album.visible = false
	_root.add_child(_album)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	_album.add_child(box)
	# Header: album name, NASA and the X.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 16)
	box.add_child(head)
	_album_title = Label.new()
	_album_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_album_title.add_theme_font_override("font", Palette.font(800))
	_album_title.add_theme_font_size_override("font_size", 38)
	_album_title.add_theme_color_override("font_color", Palette.GOLD)
	head.add_child(_album_title)
	var nasa := _key_button(_on_nasa, true)
	nasa.text = "NASA"
	nasa.custom_minimum_size = Vector2(136, 88)
	nasa.size_flags_horizontal = Control.SIZE_SHRINK_END
	head.add_child(nasa)
	head.add_child(_red_x(func() -> void:
		_album.visible = false
		_refresh()))
	# Progress: golden tube with "17 / 35" and the next reward.
	var prog := VBoxContainer.new()
	prog.add_theme_constant_override("separation", 8)
	box.add_child(prog)
	_album_bar = TubeBar.new()
	_album_bar.color = Palette.GOLD
	_album_bar.custom_minimum_size = Vector2(0, 40)
	prog.add_child(_album_bar)
	_album_count = Label.new()
	_album_count.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_album_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_album_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_album_count.add_theme_font_override("font", Palette.font(800))
	_album_count.add_theme_font_size_override("font_size", 24)
	_album_count.add_theme_color_override("font_color", Color.WHITE)
	_album_count.add_theme_color_override("font_outline_color", Palette.INK)
	_album_count.add_theme_constant_override("outline_size", 8)
	_album_bar.add_child(_album_count)
	_album_next = Label.new()
	_album_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_album_next.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_album_next.add_theme_font_override("font", Palette.font(700))
	_album_next.add_theme_font_size_override("font_size", 22)
	_album_next.add_theme_color_override("font_color", Palette.TEXT)
	prog.add_child(_album_next)
	# Tabs: one per page, with the 3D icon of the theme and "4/7" (star when complete).
	_album_tabs = HBoxContainer.new()
	_album_tabs.add_theme_constant_override("separation", 8)
	box.add_child(_album_tabs)
	_album_page_title = Label.new()
	_album_page_title.add_theme_font_override("font", Palette.font(800))
	_album_page_title.add_theme_font_size_override("font_size", 30)
	_album_page_title.add_theme_color_override("font_color", Palette.TEXT)
	box.add_child(_album_page_title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_album_scroll = scroll
	# The grid stays in the middle (before, it all went to the left on PC).
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	_album_grid = GridContainer.new()
	_album_grid.columns = 3
	_album_grid.add_theme_constant_override("h_separation", 16)
	_album_grid.add_theme_constant_override("v_separation", 24)
	center.add_child(_album_grid)


func _page_icon(page: int) -> Texture2D:
	match State.ALBUM_PAGES[page][0]:
		"plants":
			return _plant_icon("lettuce")
		"tech":
			return _thumb("solar")
		"minerals":
			if not _icon_cache.has("page_minerals"):
				var holder := Node3D.new()
				var m: Node3D = base._load_model(State.model_file("hematita"), 1.0, 1.0)
				if m:
					m.position.y -= 0.5
					holder.add_child(m)
				_icon_cache["page_minerals"] = Icons3D.render(self, holder, 160, 1.3)
			return _icon_cache["page_minerals"]
		"discoveries":
			return _icon("explore")
		"sky":
			if not _icon_cache.has("page_sky"):
				_icon_cache["page_sky"] = Icons3D.render(self, Icons3D.sun(), 160, 1.4)
			return _icon_cache["page_sky"]
	return null


## Album sticker: the card in miniature (rarity frame, photo, number and name).
func _album_tile(id: int, w := 192.0) -> Control:
	var info := State.card_info(id)
	var owned := State.cards.has(str(id))
	var rarity: String = info.get("rarity", "common")
	var k := w / 1066.0
	var f := w / 192.0          # the letters grow along with the card
	var b := Button.new()
	b.custom_minimum_size = Vector2(w, 1280.0 * k)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	_juice(b)
	var window := Rect2(Vector2(60, 236) * k, Vector2(944, 614) * k)
	if owned:
		var photo := TextureRect.new()
		photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE   # before the size: otherwise the image forces its own size
		photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var file := "res://ui/cards/%s" % info.get("photo_file", "")
		if str(info.get("photo_file", "")) != "" and ResourceLoader.exists(file):
			photo.texture = load(file)
		photo.position = window.position
		photo.size = window.size
		photo.clip_contents = true
		photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(photo)
	else:
		# Not owned yet: the window is dark with a golden "?" (the frame already shows the rarity).
		var dark := ColorRect.new()
		dark.color = Palette.PLATE
		dark.position = window.position
		dark.size = window.size
		dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(dark)
		var q := Label.new()
		q.text = "?"
		q.position = window.position
		q.size = window.size
		q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		q.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		q.add_theme_font_override("font", Palette.font(800))
		q.add_theme_font_size_override("font_size", int(64 * f))
		q.add_theme_color_override("font_color", Palette.GOLD)
		q.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(q)
	var frame := TextureRect.new()
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE   # before the size: otherwise the frame takes the image's size
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	var frame_file := "res://ui/frames/moldura-carta-%s.png" % FRAME.get(rarity, "comum")
	if ResourceLoader.exists(frame_file):
		frame.texture = load(frame_file)
	frame.size = b.custom_minimum_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not owned:
		frame.modulate = Color(0.8, 0.8, 0.8)
	b.add_child(frame)
	# Sticker number at the top; name below (in place of the fact).
	var num := Label.new()
	num.text = tr("CARD_NUMBER").format({"n": id})
	num.position = Vector2(107, 92) * k
	num.size = Vector2(855, 108) * k
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num.add_theme_font_override("font", Palette.font(800))
	num.add_theme_font_size_override("font_size", int(15 * f))
	num.add_theme_color_override("font_color", Palette.BG)
	num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(num)
	var name_label := Label.new()
	name_label.text = tr("CARD_%d_NAME" % id) if owned else "???"
	name_label.position = Vector2(84, 866) * k
	name_label.size = Vector2(906, 268) * k
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_override("font", Palette.font(700))
	name_label.add_theme_font_size_override("font_size", int(16 * f))
	name_label.add_theme_color_override("font_color", Color("3a261c"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(name_label)
	# New card (not yet seen in the album): tilted NEW badge.
	if owned and not State.seen_cards.has(str(id)):
		var badge := PanelContainer.new()
		var bb := Palette._box(Palette.ALERT, 10)
		bb.border_color = Palette.INK
		bb.set_border_width_all(2)
		bb.content_margin_left = 8
		bb.content_margin_right = 8
		bb.content_margin_top = 2
		bb.content_margin_bottom = 2
		badge.add_theme_stylebox_override("panel", bb)
		badge.rotation_degrees = -16.0
		badge.position = Vector2(-10, -8)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bt := Label.new()
		bt.text = tr("CARD_NEW_BADGE")
		bt.add_theme_font_override("font", Palette.font(800))
		bt.add_theme_font_size_override("font_size", int(16 * f))
		bt.add_theme_color_override("font_color", Color.WHITE)
		badge.add_child(bt)
		b.add_child(badge)
	# Legendary that the child owns: glows slowly.
	if owned and rarity == "legendary":
		var glow := create_tween().set_loops()
		glow.tween_property(frame, "modulate", Color(1.35, 1.25, 0.9), 0.8).set_trans(Tween.TRANS_SINE)
		glow.tween_property(frame, "modulate", Color.WHITE, 0.8).set_trans(Tween.TRANS_SINE)
		b.tree_exiting.connect(glow.kill)
	if owned:
		b.pressed.connect(func() -> void:
			if not _album_drag.moved:   # a drag to scroll is not a tap on the card
				_queue_card(id, false))
	else:
		b.pressed.connect(func() -> void:
			if not _album_drag.moved:
				_show_info(tr("HOW_TITLE"), State.card_hint(id), Callable()))
	return b


func _build_popups() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0.08, 0.02, 0.03, 0.6)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.visible = false
	_root.add_child(_dim)

	# Choice (storm, cold night, no signal): base plate with the striped danger band.
	_choice = _popup(640, "alert")
	var cbox: VBoxContainer = _choice.get_child(0)
	_choice_title = _title_label(40)
	cbox.add_child(_choice_title)
	_choice_lines = VBoxContainer.new()
	_choice_lines.add_theme_constant_override("separation", 8)
	cbox.add_child(_choice_lines)
	_choice_a = _popup_button(cbox, _on_choice.bind(0))
	_choice_b = _popup_button(cbox, _on_choice.bind(1), true)

	# Notice with OK (dust, whirlwind, while you were away): base plate.
	_info = _popup(620)
	var ibox: VBoxContainer = _info.get_child(0)
	_info_title = _title_label(40)
	ibox.add_child(_info_title)
	_info_text = _wrap_label("", 30)
	_info_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ibox.add_child(_info_text)
	_popup_button(ibox, _on_info_ok).text = "OK"

	# Card: cream paper with the border in the rarity color, slightly crooked, like a real card.
	# Rays behind the card (only when it is new): spin slowly, in the rarity color.
	_card_rays = Control.new()
	_card_rays.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_rays.visible = false
	_root.add_child(_card_rays)
	_card_rays.draw.connect(func() -> void:
		var c: Vector2 = _card_rays.size / 2.0
		var col: Color = _card_rays.get_meta("color", Palette.GOLD)
		var turn := Time.get_ticks_msec() / 1000.0 * 0.35
		var reach := _card_rays.size.length()
		for i in 14:
			var a := turn + TAU * i / 14.0
			var w := 0.11
			_card_rays.draw_colored_polygon(PackedVector2Array([c, c + Vector2(cos(a - w), sin(a - w)) * reach, c + Vector2(cos(a + w), sin(a + w)) * reach]), Color(col, 0.28))
		_card_rays.draw_circle(c, 260.0, Color(col.lightened(0.4), 0.25)))
	# The card is the Design 05 frame (one per rarity) with the NASA photo underneath,
	# the name in the title and the fact below, in the rectangles from design/05-telas/moldura-carta.md.
	_card = _popup(int(CARD_W))
	_card_style = StyleBoxFlat.new()
	_card_style.bg_color = Color(0, 0, 0, 0)
	_card.add_theme_stylebox_override("panel", _card_style)
	var kbox: VBoxContainer = _card.get_child(0)
	kbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_title = _title_label(40)
	_card_title.add_theme_color_override("font_color", Palette.GOLD)
	_card_title.add_theme_color_override("font_outline_color", Palette.BG)
	_card_title.add_theme_constant_override("outline_size", 12)
	kbox.add_child(_card_title)
	var k := CARD_W / 1066.0
	var face := Control.new()
	face.custom_minimum_size = Vector2(CARD_W, 1280.0 * k)
	face.rotation_degrees = -2.0
	face.resized.connect(func() -> void: face.pivot_offset = face.size / 2.0)
	kbox.add_child(face)
	_card_photo = TextureRect.new()
	_card_photo.position = Vector2(60, 236) * k
	_card_photo.size = Vector2(944, 614) * k
	_card_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_card_photo.clip_contents = true
	face.add_child(_card_photo)
	_card_frame = TextureRect.new()
	_card_frame.size = face.custom_minimum_size
	_card_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_frame.stretch_mode = TextureRect.STRETCH_SCALE
	face.add_child(_card_frame)
	# "NEW!" badge: tilted in the top left corner, pulsing (only on a card the child did not have yet).
	_card_badge = PanelContainer.new()
	var badge_box := Palette._box(Palette.ALERT, 14)
	badge_box.border_color = Palette.INK
	badge_box.set_border_width_all(3)
	badge_box.content_margin_left = 16
	badge_box.content_margin_right = 16
	badge_box.content_margin_top = 4
	badge_box.content_margin_bottom = 6
	badge_box.shadow_color = Color(Palette.INK, 0.45)
	badge_box.shadow_offset = Vector2(3, 4)
	_card_badge.add_theme_stylebox_override("panel", badge_box)
	_card_badge.rotation_degrees = -16.0
	_card_badge.position = Vector2(-22, -14)
	_card_badge.visible = false
	var badge_text := Label.new()
	badge_text.name = "Text"
	badge_text.add_theme_font_override("font", Palette.font(800))
	badge_text.add_theme_font_size_override("font_size", 30)
	badge_text.add_theme_color_override("font_color", Color.WHITE)
	_card_badge.add_child(badge_text)
	_card_name = Label.new()
	_card_name.position = Vector2(107, 92) * k
	_card_name.size = Vector2(855, 108) * k
	_card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_name.add_theme_color_override("font_color", Palette.BG)
	face.add_child(_card_name)
	_card_fact = Label.new()
	_card_fact.position = Vector2(84, 866) * k
	_card_fact.size = Vector2(906, 268) * k
	_card_fact.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card_fact.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card_fact.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_fact.add_theme_font_size_override("font_size", 24)
	_card_fact.add_theme_color_override("font_color", Color("3a261c"))
	face.add_child(_card_fact)
	face.add_child(_card_badge)
	_card_rarity_pill = PanelContainer.new()
	_card_rarity_pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	kbox.add_child(_card_rarity_pill)
	_card_rarity = _wrap_label("", 32)
	_card_rarity.autowrap_mode = TextServer.AUTOWRAP_OFF
	_card_rarity.add_theme_font_override("font", Palette.font(800))
	_card_rarity_pill.add_child(_card_rarity)
	var crow := HBoxContainer.new()
	crow.add_theme_constant_override("separation", 16)
	kbox.add_child(crow)
	var source := _key_button(_on_card_source, true)
	source.name = "Source"
	crow.add_child(source)
	var ok := _key_button(_show_next_card)
	ok.text = "OK"
	crow.add_child(ok)

	# 3D sample tube (same material as the game): spins and shivers in the rarity color until the child taps.
	_tube = _popup(460)
	var tbox: VBoxContainer = _tube.get_child(0)
	tbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var view := SubViewportContainer.new()
	view.stretch = true
	view.custom_minimum_size = Vector2(320, 400)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.gui_input.connect(func(e: InputEvent) -> void:
		if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
			_on_tube_tap())
	tbox.add_child(view)
	var vp := SubViewport.new()
	vp.transparent_bg = true
	vp.own_world_3d = true
	view.add_child(vp)
	_build_tube_scene(vp)
	_tube_label = _title_label(34)
	_tube_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tbox.add_child(_tube_label)
	_tube_btn = _popup_button(tbox, _on_tube_tap)

	# NASA data
	_nasa = _popup(640)
	var nbox: VBoxContainer = _nasa.get_child(0)
	var ntitle := _title_label(36)
	nbox.add_child(ntitle)
	_nasa_text = _wrap_label("", 28)
	_nasa_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	nbox.add_child(_nasa_text)
	_popup_button(nbox, func() -> void: OS.shell_open(DONKI_URL), true).text = "DONKI (NASA)"
	_popup_button(nbox, _close_nasa).text = "OK"
	_nasa.visibility_changed.connect(func() -> void: ntitle.text = tr("NASA_TITLE"))


## The sample tube: glass in the rarity color, metal caps, a little rock inside and a light of the same color.
func _build_tube_scene(vp: SubViewport) -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(1.0, 0.92, 0.85)
	env.environment.ambient_light_energy = 0.6
	vp.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, 35.0, 0.0)
	vp.add_child(sun)
	_tube_node = Node3D.new()
	vp.add_child(_tube_node)
	var glass := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.42
	cyl.bottom_radius = 0.42
	cyl.height = 1.5
	cyl.radial_segments = 12
	glass.mesh = cyl
	_tube_glass = StandardMaterial3D.new()
	_tube_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_tube_glass.roughness = 0.15
	_tube_glass.emission_enabled = true
	_tube_glass.emission_energy_multiplier = 0.6
	glass.material_override = _tube_glass
	_tube_node.add_child(glass)
	for y in [0.82, -0.82]:
		var cap := MeshInstance3D.new()
		var c := CylinderMesh.new()
		c.top_radius = 0.47
		c.bottom_radius = 0.47
		c.height = 0.2
		c.radial_segments = 12
		cap.mesh = c
		var metal := StandardMaterial3D.new()
		metal.albedo_color = Palette.SUIT.darkened(0.15)
		metal.metallic = 0.6
		metal.roughness = 0.35
		cap.material_override = metal
		cap.position.y = y
		_tube_node.add_child(cap)
		if y > 0.0:
			_tube_lid = cap
	var rock := MeshInstance3D.new()
	var r := SphereMesh.new()
	r.radius = 0.22
	r.height = 0.36
	r.radial_segments = 6
	r.rings = 3
	rock.mesh = r
	var rock_mat := StandardMaterial3D.new()
	rock_mat.albedo_color = Palette.GROUND.darkened(0.2)
	rock.material_override = rock_mat
	rock.position.y = -0.45
	_tube_node.add_child(rock)
	# The "?" in front of the tube: nobody knows the rarity until it opens.
	_tube_q = Label3D.new()
	_tube_q.text = "?"
	_tube_q.font = Palette.font(800)
	_tube_q.font_size = 160
	_tube_q.outline_size = 36
	_tube_q.modulate = Palette.GOLD
	_tube_q.outline_modulate = Palette.INK
	_tube_q.pixel_size = 0.006
	_tube_q.position = Vector3(0.0, 0.05, 0.6)
	_tube_node.add_child(_tube_q)
	# Shock ring and light beam of the burst (hidden until it opens).
	_tube_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.42
	torus.outer_radius = 0.55
	torus.rings = 32
	_tube_ring.mesh = torus
	var ring_mat := StandardMaterial3D.new()
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_tube_ring.material_override = ring_mat
	_tube_ring.rotation_degrees.x = 70.0
	_tube_ring.visible = false
	_tube_node.get_parent().add_child(_tube_ring)
	_tube_beam = MeshInstance3D.new()
	var beam := CylinderMesh.new()
	beam.top_radius = 0.65
	beam.bottom_radius = 0.3
	beam.height = 4.0
	_tube_beam.mesh = beam
	var beam_mat := StandardMaterial3D.new()
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	beam_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_tube_beam.material_override = beam_mat
	_tube_beam.position.y = 2.0
	_tube_beam.visible = false
	_tube_node.get_parent().add_child(_tube_beam)
	_tube_light = OmniLight3D.new()
	_tube_light.position = Vector3(0.0, 0.0, -0.9)
	_tube_light.omni_range = 3.0
	_tube_light.light_energy = 2.0
	vp.add_child(_tube_light)
	var cam := Camera3D.new()
	cam.fov = 40.0
	vp.add_child(cam)
	cam.position = Vector3(0.0, 0.3, 3.4)
	cam.look_at(Vector3(0.0, 0.0, 0.0))


func _close_nasa() -> void:
	_nasa.visible = false
	_update_dim()


func _build_postcard() -> void:
	_flash = ColorRect.new()
	_flash.color = Color.WHITE
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.modulate.a = 0.0
	add_child(_flash)
	_postcard = Control.new()
	_postcard.set_anchors_preset(Control.PRESET_FULL_RECT)
	_postcard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_postcard.visible = false
	add_child(_postcard)
	# Postcard: a crooked paper label in the corner, with the place and the sol.
	var strip := PanelContainer.new()
	strip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	strip.offset_left = 36
	strip.offset_bottom = -60
	strip.grow_vertical = Control.GROW_DIRECTION_BEGIN
	strip.rotation_degrees = -4.0
	strip.custom_minimum_size = Vector2(500, 0)
	strip.add_theme_stylebox_override("panel", Palette.paper(Palette.BUTTON))
	_postcard.add_child(strip)
	var col := VBoxContainer.new()
	strip.add_child(col)
	var title := _title_label(50)
	title.text = "Mike on Mars"
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_color_override("font_color", Palette.BUTTON.darkened(0.2))
	col.add_child(title)
	_postcard_label = _wrap_label("", 32)
	_postcard_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_postcard_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_postcard_label.add_theme_color_override("font_color", Palette.INK)
	col.add_child(_postcard_label)


func _build_start() -> void:
	_start = Control.new()
	_start.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_start)
	# Background: the base itself (the camera slowly turns behind), just darkened. No generic gradient.
	var shade := ColorRect.new()
	shade.color = Color(0.12, 0.03, 0.05, 0.42)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_start.add_child(shade)
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 48
	col.offset_right = -48
	col.offset_top = 140
	col.offset_bottom = -90
	col.add_theme_constant_override("separation", 6)
	col.theme = _root.theme
	_start.add_child(col)
	# The Design 06 logo (the name, Mars and the rocket), swaying lightly.
	var logo := TextureRect.new()
	logo.texture = load("res://ui/logo.png") if ResourceLoader.exists("res://ui/logo.png") else load("res://ui/icons/mike.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(logo)
	logo.resized.connect(func() -> void: logo.pivot_offset = logo.size / 2.0)
	var sway := create_tween().set_loops()
	sway.tween_property(logo, "rotation_degrees", 2.5, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(logo, "rotation_degrees", -2.5, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_start_play = _key_button(_on_play)
	_start_play.custom_minimum_size = Vector2(360, 170)
	_start_play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_start_play.add_theme_font_size_override("font_size", 52)
	_start_play.autowrap_mode = TextServer.AUTOWRAP_OFF
	col.add_child(_start_play)
	var corner := HBoxContainer.new()
	corner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	corner.offset_left = 24
	corner.offset_right = -24
	corner.offset_top = 24
	corner.theme = _root.theme
	_start.add_child(corner)
	_start_nasa = _key_button(_on_nasa, true)
	_start_nasa.custom_minimum_size = Vector2(0, 96)
	_start_nasa.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_start_nasa.autowrap_mode = TextServer.AUTOWRAP_OFF
	corner.add_child(_start_nasa)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corner.add_child(spacer)
	_start_lang = _key_button(_on_lang, true)
	_start_lang.custom_minimum_size = Vector2(170, 96)
	_start_lang.expand_icon = true
	_start_lang.add_theme_constant_override("icon_max_width", 48)
	_start_lang.size_flags_horizontal = Control.SIZE_SHRINK_END
	_start_lang.autowrap_mode = TextServer.AUTOWRAP_OFF
	corner.add_child(_start_lang)
	# The game UI only shows up after Play.
	_root.visible = false
	# The NASA data window also opens on the start screen: it stays on top of everything.
	_nasa.reparent(self)
	_nasa.theme = _root.theme
	move_child(_nasa, -1)
	_toast.theme = _root.theme
	_postcard.theme = _root.theme
	move_child(_toast, -1)


## Window in the middle of the screen. "plate" = base plate; "alert" = plate with danger stripe; "paper" = paper.
func _popup(width: int, kind := "plate") -> PanelContainer:
	var p: PanelContainer
	if kind == "paper":
		p = PanelContainer.new()
		p.add_theme_stylebox_override("panel", Palette.paper())
	else:
		var plate := Plate.new()
		plate.stripe = kind == "alert"
		p = plate
	p.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	p.custom_minimum_size = Vector2(width, 0)
	p.visible = false
	p.resized.connect(func() -> void: p.pivot_offset = p.size / 2.0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	p.add_child(box)
	_root.add_child(p)
	_popups.append(p)
	return p


## Key button. The main one is golden; the secondary one, terracotta.
func _key_button(action: Callable, secondary := false) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 104)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var color := Palette.BUTTON if secondary else Palette.GOLD
	for s in ["normal", "hover", "disabled"]:
		b.add_theme_stylebox_override(s, Palette.key(color))
	b.add_theme_stylebox_override("pressed", Palette.key(color, true))
	b.pressed.connect(action)
	_juice(b)
	return b


func _popup_button(box: VBoxContainer, action: Callable, secondary := false) -> Button:
	var b := _key_button(action, secondary)
	box.add_child(b)
	return b


## Title with very bold Rubik, left-aligned (nothing all centered).
func _title_label(size: int) -> Label:
	var l := _wrap_label("", size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l.add_theme_color_override("font_color", Palette.GOLD)
	if _bold == null and ResourceLoader.exists(Palette.FONT):
		_bold = FontVariation.new()
		_bold.base_font = load(Palette.FONT)
		_bold.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 800}
	if _bold:
		l.add_theme_font_override("font", _bold)
	return l


func _wrap_label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	return l
