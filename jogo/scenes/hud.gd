extends CanvasLayer
## A interface (telas do design/05): tela inicial, barras, sol, botões Construir/Explorar/Álbum/Foto,
## janelas de eventos, carta, tubo, álbum, dados da NASA e cartão-postal.
## Decide o que um toque na base faz, conforme o modo atual (nada, construir ou mover).

enum Mode { NONE, BUILD, MOVE }

const LANGS := ["en", "pt_BR", "es", "fr"]
const LANG_NAMES := {"en": "EN", "pt_BR": "PT", "es": "ES", "fr": "FR"}
## Menu de idiomas: bandeira (Kenney Flag Pack, CC0) + nome escrito no próprio idioma.
const LANG_FLAGS := {"en": "res://ui/flags/us.png", "pt_BR": "res://ui/flags/br.png", "es": "res://ui/flags/es.png", "fr": "res://ui/flags/fr.png"}
const LANG_LABELS := {"en": "English", "pt_BR": "Português", "es": "Español", "fr": "Français"}
const BAR_KEYS := {"energy": "BAR_ENERGY", "oxygen": "BAR_OXYGEN", "shield": "BAR_SHIELD"}
const REVEAL_SOUND := {"comum": "revelar-comum", "raro": "revelar-raro", "épico": "revelar-epico", "lendário": "revelar-lendario"}
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
var _sol_label: Label
var _hint: Label
var _toast: PanelContainer
var _toast_label: Label
var _toast_tween: Tween
var _buttons := {}            # "build", "explore", "album", "photo" -> Button
var _build_menu: PanelContainer
var _build_grid: GridContainer
var _panel: PanelContainer
var _panel_title: Label
var _panel_info: Label
var _panel_buttons: HFlowContainer
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
var _card_source := ""
var _card_queue: Array[int] = []
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
var _inv_labels := {}         # planta -> Label "× n"
var _icons := {}              # planta -> textura desenhada do modelo 3D


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
	_build_postcard()
	_build_start()
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


# ───────────── Tela inicial ─────────────
func _on_play() -> void:
	Sfx.play("toque-botao")
	Sfx.play_music("musica-base")
	_start.visible = false
	_root.visible = true
	base.orbit = false
	State.start()
	var away: Dictionary = State.away
	if int(away.get("sols", 0)) >= 4:
		var text := tr("AWAY_SOLS").format({"n": away.sols})
		if int(away.get("plants", 0)) > 0:
			text += "\n" + tr("AWAY_PLANTS").format({"n": away.plants})
		_show_info(tr("AWAY_TITLE"), text, Callable())
		Sfx.play("bem-vindo")
		State.away = {}
	_resume_pending()
	if State.tube_card != 0:
		_show_tube()


## Se o jogo foi fechado no meio de uma escolha, mostra a janela de novo.
func _resume_pending() -> void:
	match State.pending_event:
		"storm":
			_show_storm(State.storm_event)
		"dust", "devil", "cold", "nosignal":
			_show_event(State.pending_event)


## O Mike reage quando a criança toca nele (pesquisa, item 17).
func on_mike_tapped() -> void:
	base.jump()
	Sfx.play("bem-vindo")
	_show_toast(tr("MIKE_%d" % randi_range(1, 4)))


func _on_lang() -> void:
	# Abre o menu de idiomas logo abaixo do botão.
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
	# Português primeiro (o time é do Brasil), depois os outros.
	for l in ["pt_BR", "en", "es", "fr"]:
		_lang_popup.add_icon_item(load(LANG_FLAGS[l]), LANG_LABELS[l], LANGS.find(l))
	_lang_popup.set_focused_item(_lang_popup.get_item_index(LANGS.find(State.locale)))
	return _lang_popup


# ───────────── O que um toque na base faz ─────────────
func on_cell_tapped(c: Vector2i) -> void:
	if _build_menu.visible:
		_build_menu.visible = false
		return
	var free: bool = c != base.OUTSIDE and State.item_at(c).is_empty()
	# Área ainda fechada: abre quando a Casa do Mike sobe de nível.
	if c != base.OUTSIDE and free and not State.cell_open(c) and mode != Mode.MOVE:
		_show_toast(tr("MAP_LOCKED"), true)
		Sfx.play("travado")
		_close_panel()
		return
	match mode:
		Mode.BUILD:
			if c != base.OUTSIDE and State.build(build_type, c):
				Sfx.play("construir")
				base.walk_to(c)
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
	match m:
		Mode.BUILD:
			base.highlight(State.free_cells())
		Mode.MOVE:
			base.highlight(State.move_targets(selected))
		_:
			base.highlight([])
	_refresh()


# ───────────── Botões de baixo ─────────────
func _on_build() -> void:
	Sfx.play("abrir-menu")
	_close_panel()
	if mode != Mode.NONE:
		_set_mode(Mode.NONE)
	_build_menu.visible = not _build_menu.visible
	_refresh_build_menu()


func _on_build_item(type: String) -> void:
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
	Sfx.play("abrir-menu")
	_build_menu.visible = false
	_close_panel()
	_refresh_album()
	_album.visible = true


## Cartão-postal: esconde a interface, põe "Sol N · Gale Crater" e baixa a foto da base.
func _on_photo() -> void:
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


# ───────────── Painel do item tocado ─────────────
func _open_panel(c: Vector2i) -> void:
	selected = c
	_panel.visible = true
	_build_menu.visible = false
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
	var title := tr(State.item_name(it))
	if State.upgrade_cost(selected) >= 0 or int(it.level) > 1:
		title += " · " + tr("LEVEL").format({"n": int(it.level)})
	_panel_title.text = title
	_panel_info.visible = false
	for b in _panel_buttons.get_children():
		b.queue_free()
	if it.type == "greenhouse":
		if it.plant == "":
			for p in State.unlocked_plants():
				var plant_def: Dictionary = State.PLANTS[p]
				var pb := _add_panel_button("%s (%d)" % [tr(plant_def.name), plant_def.sols], _on_plant.bind(p))
				pb.icon = _plant_icon(p)   # Design: a planta antes do nome, mais visual
				pb.expand_icon = true
				pb.add_theme_constant_override("icon_max_width", 56)
		elif State.plant_ready(selected):
			_panel_info.visible = true
			_panel_info.text = tr("PLANT_READY").format({"plant": tr(State.PLANTS[it.plant].name)})
			_add_panel_button(tr("BTN_HARVEST"), _on_harvest)
		else:
			_panel_info.visible = true
			_panel_info.text = tr("PLANT_GROWING").format({
				"plant": tr(State.PLANTS[it.plant].name), "n": int(it.growth), "max": State.PLANTS[it.plant].sols})
	if State.base_locked_reason() != "":
		return
	_add_panel_button(tr("BTN_MOVE"), _on_move)
	_add_panel_button(tr("BTN_ROTATE"), _on_rotate)
	var cost := State.upgrade_cost(selected)
	if cost >= 0:
		var up := _add_panel_button("%s -%d" % [tr("BTN_UPGRADE"), cost], _on_upgrade)
		up.modulate = Color.WHITE if State.upgrade_block_reason(selected) == "" else Color(1, 1, 1, 0.55)
	if def.get("removable", true):
		_add_panel_button(tr("BTN_REMOVE"), _on_remove)


func _add_panel_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(150, 90)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(action)
	_panel_buttons.add_child(b)
	return b


func _on_move() -> void:
	Sfx.play("toque-botao")
	_panel.visible = false
	_set_mode(Mode.MOVE)


func _on_rotate() -> void:
	var reason := State.rotate_block_reason(selected)
	if reason == "" and State.rotate(selected):
		Sfx.play("construir")
	else:
		_show_toast(tr(reason), true)
		Sfx.play("travado")


func _on_upgrade() -> void:
	var reason := State.upgrade_block_reason(selected)
	if reason == "" and State.upgrade(selected):
		Sfx.play("melhorar")
	else:
		_show_toast(tr(reason), true)
		Sfx.play("travado")


func _on_remove() -> void:
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


# ───────────── Eventos ─────────────
func _show_storm(event: Dictionary) -> void:
	var lines := [tr("EV_SOLAR_REAL").format({"date": event.get("date", "")})]
	if event.get("curiosity", false):
		lines.append(tr("EV_SOLAR_CURIOSITY"))
	lines.append(tr("EV_SOLAR_Q"))
	_show_choice(tr("EV_SOLAR_TITLE"), lines,
		"%s  ·  -%d %s" % [tr("EV_SOLAR_A"), int(State.STORM_SHIELD_COST), tr("BAR_ENERGY").to_lower()], State.can_afford(State.STORM_SHIELD_COST),
		_storm_shield, tr("EV_SOLAR_B"), _storm_inside)
	Sfx.play("alerta")


func _storm_shield() -> void:
	if State.choose_storm(true):
		Sfx.play("escudo")


func _storm_inside() -> void:
	State.choose_storm(false)


func _show_event(type: String) -> void:
	match type:
		"dust":
			_show_info(tr("EV_DUST_TITLE"), tr("EV_DUST_TEXT"), State.ack_event)
			Sfx.play("energia-cai")
		"devil":
			_show_info(tr("EV_DEVIL_TITLE"), tr("EV_DEVIL_TEXT"), State.ack_event)
			Sfx.play("energia-volta")
		"cold":
			_show_choice(tr("EV_COLD_TITLE"), [tr("EV_COLD_TEXT"), tr("EV_COLD_Q")],
				"%s  ·  -%d %s" % [tr("EV_COLD_A"), int(State.COLD_HEAT_COST), tr("BAR_ENERGY").to_lower()], State.can_afford(State.COLD_HEAT_COST),
				func() -> void: State.choose_cold(true),
				tr("EV_COLD_B"), func() -> void: State.choose_cold(false))
			Sfx.play("alerta")
		"nosignal":
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


# ───────────── Tubo de amostra ─────────────
func _show_tube() -> void:
	if State.tube_card == 0 or _tube.visible or _start.visible:
		return
	var color: Color = Palette.RARITY.get(State.tube_rarity(), Palette.TEXT)
	_tube_glass.albedo_color = Color(color, 0.6)
	_tube_glass.emission = color
	_tube_light.light_color = color
	_tube_label.text = tr("TUBE_TAP")
	_tube.visible = true
	_update_dim()
	Sfx.play("tubo-abrir")
	# O tubo gira devagar e dá tremidinhas, como se a amostra quisesse sair.
	if _tube_tween:
		_tube_tween.kill()
	_tube_node.rotation = Vector3.ZERO
	_tube_tween = create_tween().set_loops()
	_tube_tween.tween_property(_tube_node, "rotation:z", 0.2, 0.08)
	_tube_tween.tween_property(_tube_node, "rotation:z", -0.2, 0.16)
	_tube_tween.tween_property(_tube_node, "rotation:z", 0.0, 0.08)
	_tube_tween.parallel().tween_property(_tube_node, "rotation:y", TAU, 1.2).as_relative()
	_tube_tween.tween_interval(0.3)


func _on_tube_tap() -> void:
	if _tube_tween:
		_tube_tween.kill()
	_tube.visible = false
	_update_dim()
	State.open_tube()


# ───────────── Carta ─────────────
func _queue_card(id: int, _is_new: bool = true) -> void:
	_card_queue.append(id)
	if not _card.visible:
		_show_next_card()


func _show_next_card() -> void:
	if _card_queue.is_empty():
		_card.visible = false
		_update_dim()
		return
	var id: int = _card_queue.pop_front()
	var info := State.card_info(id)
	var rarity: String = info.get("rarity", "comum")
	var color: Color = Palette.RARITY.get(rarity, Palette.TEXT)
	_card_style.border_color = color
	_card_title.text = tr("CARD_NEW") if State.cards.get(str(id), 0) == 1 else ""
	_card_rarity.text = tr(Palette.RARITY_KEY.get(rarity, "RARITY_COMMON"))
	_card_rarity.add_theme_color_override("font_color", color.darkened(0.3))
	_card_name.text = tr("CARD_%d_NAME" % id)
	_card_fact.text = "%s %s" % [tr("CARD_REAL"), tr("CARD_%d_FACT" % id)]
	_card_source = str(info.get("source", ""))
	var source_btn: Button = _card.find_child("Source", true, false)
	source_btn.text = tr("BTN_SOURCE")
	source_btn.visible = _card_source != ""
	var photo := "res://ui/cards/%s" % info.get("photo_file", "")
	_card_photo.visible = str(info.get("photo_file", "")) != "" and ResourceLoader.exists(photo)
	if _card_photo.visible:
		_card_photo.texture = load(photo)
	_card.visible = true
	_update_dim()
	Sfx.play(REVEAL_SOUND.get(rarity, "revelar-comum"))
	if id == State.CARD_AURORA:
		Sfx.play("aurora")


func _on_card_source() -> void:
	if _card_source != "":
		OS.shell_open(_card_source)


# ───────────── Álbum ─────────────
func _refresh_album() -> void:
	_album_title.text = tr("ALBUM_COUNT").format({"n": State.cards.size(), "total": State.cards_total()})
	for c in _album_grid.get_children():
		c.queue_free()
	for id in State.card_ids():
		var info := State.card_info(id)
		var owned := State.cards.has(str(id))
		var b := Button.new()
		b.custom_minimum_size = Vector2(150, 150)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 20)
		var color: Color = Palette.RARITY.get(info.get("rarity", "comum"), Palette.TEXT)
		# Carta que a criança tem = papel com a borda da raridade; carta que falta = chapa escura.
		var box: StyleBoxFlat = Palette.paper(color) if owned else Palette.plate()
		box.content_margin_left = 10
		box.content_margin_right = 10
		box.shadow_offset = Vector2(4, 5)
		for s in ["normal", "hover", "pressed", "disabled"]:
			b.add_theme_stylebox_override(s, box)
		b.add_theme_color_override("font_color", Palette.INK if owned else Palette.TEXT.darkened(0.3))
		b.add_theme_color_override("font_disabled_color", Palette.TEXT.darkened(0.3))
		if owned:
			b.text = tr("CARD_%d_NAME" % id)
			b.pressed.connect(_queue_card.bind(id, false))
		else:
			b.text = "?"
			b.add_theme_font_size_override("font_size", 48)
			# Carta que falta: o toque diz como ganhar.
			b.pressed.connect(func() -> void: _show_info(tr("HOW_TITLE"), State.card_hint(id), Callable()))
		_album_grid.add_child(b)


# ───────────── Dados da NASA ─────────────
func _on_nasa() -> void:
	Sfx.play("abrir-menu")
	_nasa_text.text = "%s\n\n%s\n\n%s" % [tr("NASA_DONKI").format({"n": State.donki_count()}), tr("NASA_CARDS"), tr("NASA_MODEL")]
	_nasa.visible = true
	_update_dim()


# ───────────── Atualizar a tela ─────────────
func _refresh() -> void:
	for bar in BAR_KEYS:
		var value: float = State.get(bar)
		_bars[bar].value = value
		_bar_labels[bar].text = tr(BAR_KEYS[bar])
		_bar_fill[bar].bg_color = Palette.ALERT if value < State.LOW else Palette.BAR[bar]
	_sol_label.text = "%s  •  %s" % [tr("HUD_SOL").format({"n": State.sol}), tr("HUD_PLACE")]
	_start_lang.text = LANG_NAMES.get(State.locale, "EN")
	_start_lang.icon = load(LANG_FLAGS.get(State.locale, LANG_FLAGS.en))
	_start_play.text = tr("BTN_PLAY")
	_start_nasa.text = tr("BTN_NASA")
	_buttons.build.text = tr("BTN_BUILD")
	_buttons.album.text = tr("BTN_ALBUM")
	_buttons.photo.text = tr("BTN_PHOTO")
	if State.exploring():
		_buttons.explore.text = tr("EXPLORING").format({"n": State.explore_left})
	elif State.tube_card != 0:
		_buttons.explore.text = tr("TUBE_READY")
	else:
		_buttons.explore.text = tr("BTN_EXPLORE")
	_buttons.explore.modulate = Color(1, 1, 1, 0.55) if State.explore_block_reason() != "" and State.tube_card == 0 and not State.exploring() else Color.WHITE
	_buttons.build.modulate = Color(1, 1, 1, 0.55) if State.base_locked_reason() != "" else Color.WHITE
	_hint.text = _status_text()
	_refresh_inventory()
	if _panel.visible:
		_refresh_panel()
	if _build_menu.visible:
		_refresh_build_menu()


func _status_text() -> String:
	if State.nosignal_left > 0:
		return tr("NOSIGNAL_LEFT").format({"n": State.nosignal_left})
	if State.storm_active():
		return tr("STORM_SHIELDED" if State.storm_shielded else "STORM_INSIDE").format({"n": State.storm_left})
	if mode == Mode.BUILD:
		return tr("TUT_BUILD")
	if mode == Mode.MOVE:
		return tr("MOVE_HINT")
	if State.oxygen <= 0.0:
		return tr("OUT_OXYGEN_HINT")
	if State.energy <= 0.0:
		return tr("OUT_ENERGY_HINT")
	if State.cold_left > 0:
		return tr("COLD_LEFT").format({"n": State.cold_left})
	if State.dust_left > 0:
		return tr("DUST_LEFT").format({"n": State.dust_left})
	if State.items.size() <= 1:
		return tr("TUT_BUILD")
	if State.cards.size() <= 3 and not State.exploring() and State.tube_card == 0:
		return tr("TUT_EXPLORE")
	return ""


## Quantas de cada planta a criança já colheu, com o próprio modelo 3D como ícone.
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
			style.content_margin_right = 14
			style.content_margin_top = 2
			style.content_margin_bottom = 2
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
			_inventory.add_child(chip)
			_inv_labels[p] = label
		_inv_labels[p].text = "× %d" % int(State.inventory[p])


## Desenha o modelo da planta uma vez numa telinha separada e usa a imagem como ícone.
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
	for c in _build_grid.get_children():
		c.queue_free()
	for type in State.BUILDABLE:
		var def: Dictionary = State.ITEMS[type]
		if not State.is_unlocked(type):
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 100)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 22)
		b.text = tr(def.name) + ("\n-%d" % def.cost if def.cost > 0 else "")
		b.modulate = Color.WHITE if State.build_block_reason(type) == "" else Color(1, 1, 1, 0.5)
		b.pressed.connect(_on_build_item.bind(type))
		_build_grid.add_child(b)


func _update_dim() -> void:
	_dim.visible = _choice.visible or _info.visible or _card.visible or _tube.visible or _nasa.visible


## Aviso curto num "bilhetinho" de papel inclinado. Quando é bloqueio (falta algo), ele treme de leve.
func _show_toast(text: String, shake := false) -> void:
	_toast_label.text = text
	_toast.modulate.a = 1.0
	_toast.reset_size()
	_toast.pivot_offset = _toast.size / 2.0
	_toast.position = (get_viewport().get_visible_rect().size - _toast.size) / 2.0
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast.scale = Vector2(0.85, 0.85)
	_toast_tween.tween_property(_toast, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if shake:
		var x := _toast.position.x
		for d in [14.0, -12.0, 8.0, -4.0, 0.0]:
			_toast_tween.tween_property(_toast, "position:x", x + d, 0.05)
	_toast_tween.tween_interval(1.6)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


## Todo botão responde na hora: afunda quando aperta e quica quando solta (pesquisa, item 16).
func _juice(b: Button) -> void:
	b.resized.connect(func() -> void: b.pivot_offset = b.size / 2.0)
	b.button_down.connect(func() -> void: create_tween().tween_property(b, "scale", Vector2(0.93, 0.93), 0.06))
	b.button_up.connect(func() -> void:
		create_tween().tween_property(b, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))


# ───────────── Montagem da tela ─────────────
func _build_top() -> void:
	var top := VBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 24
	top.offset_right = -24
	top.offset_top = 24
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", 14)
	_root.add_child(top)

	var panel := Plate.new()
	top.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	panel.add_child(rows)
	for bar in BAR_KEYS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		rows.add_child(row)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(44, 44)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists(BAR_ICONS[bar]):
			icon.texture = load(BAR_ICONS[bar])
		icon.modulate = Palette.BAR[bar]
		row.add_child(icon)
		var label := Label.new()
		label.custom_minimum_size = Vector2(150, 0)
		label.add_theme_font_size_override("font_size", 28)
		row.add_child(label)
		var pb := ProgressBar.new()
		pb.max_value = State.BAR_MAX
		pb.show_percentage = false
		pb.custom_minimum_size = Vector2(0, 24)
		pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var fill := Palette.bar_fill(Palette.BAR[bar])
		pb.add_theme_stylebox_override("fill", fill)
		row.add_child(pb)
		_bars[bar] = pb
		_bar_labels[bar] = label
		_bar_fill[bar] = fill

	# O "Sol N · Cratera Gale" é uma placa no canto, um pouco torta (nada de tudo centralizado).
	var pill := PanelContainer.new()
	pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pill.add_theme_stylebox_override("panel", Palette.paper(Palette.GOLD.darkened(0.25)))
	pill.rotation_degrees = -2.0
	top.add_child(pill)
	_sol_label = Label.new()
	_sol_label.add_theme_font_size_override("font_size", 28)
	_sol_label.add_theme_color_override("font_color", Palette.INK)
	pill.add_child(_sol_label)

	_inventory = HFlowContainer.new()
	_inventory.alignment = FlowContainer.ALIGNMENT_CENTER
	_inventory.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_inventory.add_theme_constant_override("h_separation", 10)
	top.add_child(_inventory)

	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.add_theme_color_override("font_outline_color", Palette.BG)
	_hint.add_theme_constant_override("outline_size", 10)
	top.add_child(_hint)


func _build_bottom() -> void:
	var bottom := VBoxContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 24
	bottom.offset_right = -24
	bottom.offset_bottom = -24
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_theme_constant_override("separation", 14)
	_root.add_child(bottom)

	_build_menu = Plate.new()
	_build_menu.visible = false
	bottom.add_child(_build_menu)
	_build_grid = GridContainer.new()
	_build_grid.columns = 3
	_build_grid.add_theme_constant_override("h_separation", 10)
	_build_grid.add_theme_constant_override("v_separation", 10)
	_build_menu.add_child(_build_grid)

	_panel = Plate.new()
	_panel.visible = false
	bottom.add_child(_panel)
	var pbox := VBoxContainer.new()
	pbox.add_theme_constant_override("separation", 10)
	_panel.add_child(pbox)
	_panel_title = Label.new()
	_panel_title.add_theme_color_override("font_color", Palette.GOLD)
	pbox.add_child(_panel_title)
	_panel_info = _wrap_label("", 26)
	pbox.add_child(_panel_info)
	_panel_buttons = HFlowContainer.new()
	_panel_buttons.add_theme_constant_override("h_separation", 10)
	_panel_buttons.add_theme_constant_override("v_separation", 10)
	pbox.add_child(_panel_buttons)

	# Embaixo, no alcance do polegar. Explorar é a ação principal: maior, dourada e mais alta que as outras.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_END
	bottom.add_child(row)
	for k in ["build", "explore", "album", "photo"]:
		var main_action: bool = k == "explore"
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 176 if main_action else 140)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_SHRINK_END
		b.size_flags_stretch_ratio = 1.5 if main_action else 1.0
		b.add_theme_font_size_override("font_size", 32 if main_action else 26)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var color := Palette.GOLD if main_action else Palette.BUTTON
		for s in ["normal", "hover", "disabled"]:
			b.add_theme_stylebox_override(s, Palette.key(color))
		b.add_theme_stylebox_override("pressed", Palette.key(color, true))
		if ICONS.has(k) and ResourceLoader.exists(ICONS[k]):
			b.icon = load(ICONS[k])
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			b.add_theme_constant_override("icon_max_width", 64 if main_action else 52)
			for ic in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color"]:
				b.add_theme_color_override(ic, Palette.INK)
		_juice(b)
		row.add_child(b)
		_buttons[k] = b
	_buttons.build.pressed.connect(_on_build)
	_buttons.explore.pressed.connect(_on_explore)
	_buttons.album.pressed.connect(_on_album)
	_buttons.photo.pressed.connect(_on_photo)


func _build_messages() -> void:
	_toast = PanelContainer.new()
	_toast.add_theme_stylebox_override("panel", Palette.paper(Palette.GOLD))
	_toast.rotation_degrees = -3.0
	_toast.custom_minimum_size = Vector2(0, 0)
	_toast.modulate.a = 0.0
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast)
	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_label.custom_minimum_size = Vector2(460, 0)
	_toast_label.add_theme_font_size_override("font_size", 34)
	_toast_label.add_theme_color_override("font_color", Palette.INK)
	_toast.add_child(_toast_label)


func _build_album() -> void:
	_album = PanelContainer.new()
	_album.set_anchors_preset(Control.PRESET_FULL_RECT)
	_album.add_theme_stylebox_override("panel", Palette._box(Palette.BG, 0))
	_album.visible = false
	_root.add_child(_album)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	_album.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	_album_title = Label.new()
	_album_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_album_title.add_theme_font_size_override("font_size", 40)
	_album_title.add_theme_color_override("font_color", Palette.GOLD)
	head.add_child(_album_title)
	var nasa := Button.new()
	nasa.text = "NASA"
	nasa.custom_minimum_size = Vector2(120, 80)
	nasa.pressed.connect(_on_nasa)
	head.add_child(nasa)
	var close := Button.new()
	close.text = "X"
	close.custom_minimum_size = Vector2(80, 80)
	close.pressed.connect(func() -> void: _album.visible = false)
	head.add_child(close)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_album_grid = GridContainer.new()
	_album_grid.columns = 4
	_album_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_album_grid.add_theme_constant_override("h_separation", 10)
	_album_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_album_grid)


func _build_popups() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0.08, 0.02, 0.03, 0.6)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.visible = false
	_root.add_child(_dim)

	# Escolha (tempestade, noite fria, sem sinal): chapa da base com a faixa de perigo listrada.
	_choice = _popup(640, "alert")
	var cbox: VBoxContainer = _choice.get_child(0)
	_choice_title = _title_label(40)
	cbox.add_child(_choice_title)
	_choice_lines = VBoxContainer.new()
	_choice_lines.add_theme_constant_override("separation", 10)
	cbox.add_child(_choice_lines)
	_choice_a = _popup_button(cbox, _on_choice.bind(0))
	_choice_b = _popup_button(cbox, _on_choice.bind(1), true)

	# Aviso com OK (poeira, redemoinho, enquanto você estava fora): chapa da base.
	_info = _popup(620)
	var ibox: VBoxContainer = _info.get_child(0)
	_info_title = _title_label(40)
	ibox.add_child(_info_title)
	_info_text = _wrap_label("", 30)
	_info_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ibox.add_child(_info_text)
	_popup_button(ibox, _on_info_ok).text = "OK"

	# Carta: papel creme com a borda na cor da raridade, um pouco torta, como uma carta de verdade.
	_card = _popup(600, "paper")
	_card.rotation_degrees = -2.0
	_card_style = Palette.paper()
	_card.add_theme_stylebox_override("panel", _card_style)
	var kbox: VBoxContainer = _card.get_child(0)
	_card_title = _wrap_label("", 26)
	_card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_card_title.add_theme_color_override("font_color", Palette.INK.lightened(0.25))
	kbox.add_child(_card_title)
	_card_photo = TextureRect.new()
	_card_photo.custom_minimum_size = Vector2(0, 300)
	_card_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	kbox.add_child(_card_photo)
	_card_name = _title_label(46)
	_card_name.add_theme_color_override("font_color", Palette.INK)
	kbox.add_child(_card_name)
	_card_rarity = _wrap_label("", 28)
	_card_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	kbox.add_child(_card_rarity)
	_card_fact = _wrap_label("", 30)
	_card_fact.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_card_fact.add_theme_color_override("font_color", Palette.INK)
	kbox.add_child(_card_fact)
	var crow := HBoxContainer.new()
	crow.add_theme_constant_override("separation", 12)
	kbox.add_child(crow)
	var source := _key_button(_on_card_source, true)
	source.name = "Source"
	crow.add_child(source)
	var ok := _key_button(_show_next_card)
	ok.text = "OK"
	crow.add_child(ok)

	# Tubo de amostra em 3D (o mesmo material do jogo): gira e treme na cor da raridade até a criança tocar.
	_tube = _popup(460)
	var tbox: VBoxContainer = _tube.get_child(0)
	tbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var view := SubViewportContainer.new()
	view.stretch = true
	view.custom_minimum_size = Vector2(320, 400)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tbox.add_child(view)
	var vp := SubViewport.new()
	vp.transparent_bg = true
	vp.own_world_3d = true
	view.add_child(vp)
	_build_tube_scene(vp)
	_tube_label = _title_label(36)
	_tube_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tbox.add_child(_tube_label)
	_popup_button(tbox, _on_tube_tap).text = "OK"

	# Dados da NASA
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


## O tubo de amostra: vidro na cor da raridade, tampas de metal, uma pedrinha dentro e uma luz da mesma cor.
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
	# Cartão-postal: uma etiqueta de papel torta no canto, com o lugar e o sol.
	var strip := PanelContainer.new()
	strip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	strip.offset_left = 36
	strip.offset_bottom = -60
	strip.grow_vertical = Control.GROW_DIRECTION_BEGIN
	strip.rotation_degrees = -4.0
	strip.add_theme_stylebox_override("panel", Palette.paper(Palette.BUTTON))
	_postcard.add_child(strip)
	var col := VBoxContainer.new()
	strip.add_child(col)
	var title := _title_label(50)
	title.text = "Mike on Mars"
	title.add_theme_color_override("font_color", Palette.BUTTON.darkened(0.2))
	col.add_child(title)
	_postcard_label = _wrap_label("", 32)
	_postcard_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_postcard_label.add_theme_color_override("font_color", Palette.INK)
	col.add_child(_postcard_label)


func _build_start() -> void:
	_start = Control.new()
	_start.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_start)
	# Fundo: a própria base (a câmera gira devagar atrás), só escurecida. Nada de degradê genérico.
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
	# Título como letreiro: duas linhas, torto, alinhado à esquerda, "Mars" em terracota.
	var sign := VBoxContainer.new()
	sign.rotation_degrees = -4.0
	sign.add_theme_constant_override("separation", -18)
	col.add_child(sign)
	var t1 := _title_label(120)
	t1.text = "Mike"
	sign.add_child(t1)
	var t2 := _title_label(84)
	t2.text = "on Mars"
	t2.add_theme_color_override("font_color", Palette.BUTTON)
	sign.add_child(t2)
	for t in [t1, t2]:
		t.add_theme_color_override("font_shadow_color", Color(0.1, 0.02, 0.03, 0.9))
		t.add_theme_constant_override("shadow_offset_x", 5)
		t.add_theme_constant_override("shadow_offset_y", 7)
	var mike := TextureRect.new()
	if ResourceLoader.exists("res://ui/icons/mike.png"):
		mike.texture = load("res://ui/icons/mike.png")
	mike.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mike.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mike.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(mike)
	_start_play = _key_button(_on_play)
	_start_play.custom_minimum_size = Vector2(360, 170)
	_start_play.size_flags_horizontal = Control.SIZE_SHRINK_END
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
	# A interface do jogo só aparece depois do Jogar.
	_root.visible = false
	# A janela de dados da NASA também abre na tela inicial: fica por cima de tudo.
	_nasa.reparent(self)
	_nasa.theme = _root.theme
	move_child(_nasa, -1)
	_toast.theme = _root.theme
	_postcard.theme = _root.theme
	move_child(_toast, -1)


## Janela no meio da tela. "plate" = chapa da base; "alert" = chapa com faixa de perigo; "paper" = papel.
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
	return p


## Botão-tecla. O principal é dourado; o secundário, terracota.
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


## Título com a Rubik bem grossa, alinhado à esquerda (nada de tudo centralizado).
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
