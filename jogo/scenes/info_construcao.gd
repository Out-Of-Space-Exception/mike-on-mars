extends Control
## Painel da construção (a ideia é o painel de informação da Thais, design/05-telas/info-construcao/).
## Abre ao tocar num item do menu Construir: a construção girando em 360°, o nome, uma frase curta do que
## ela faz, quanto faz por sol e um botão grande CONSTRUIR. O X vermelho no canto fecha.
## Os números vêm do State.ITEMS: se o jogo mudar, o painel muda junto.

signal construir(type: String)

const COM_INFO := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad", "flag", "lights", "pot"]
const VERDE := Color("9be27a")
const VERMELHO := Color("ff9a8a")

var icons := {}                 # o HUD passa os ícones 3D (energy, oxygen, shield, card)
var model_for := Callable()      # o HUD passa quem monta o modelo 3D de cada construção
var _tipo := ""
var _card: PanelContainer
var _spin: Node3D
var _stage_tex: ViewportTexture
var _titulo: Label
var _efeitos: HBoxContainer
var _texto: Label
var _btn_construir: Button
var _x: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var fundo := ColorRect.new()
	fundo.color = Color(0.08, 0.02, 0.03, 0.55)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	fundo.gui_input.connect(func(e: InputEvent) -> void:
		if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
			fechar())
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	_card = PanelContainer.new()
	var box := Palette.paper(Palette.GOLD)
	box.set_corner_radius_all(32)
	box.set_border_width_all(6)
	box.shadow_offset = Vector2(0, 12)
	box.shadow_size = 6
	box.content_margin_left = 26
	box.content_margin_right = 26
	box.content_margin_top = 26
	box.content_margin_bottom = 26
	_card.add_theme_stylebox_override("panel", box)
	_card.custom_minimum_size = Vector2(640, 0)
	centro.add_child(_card)
	_card.resized.connect(func() -> void: _card.pivot_offset = _card.size / 2.0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	_card.add_child(col)

	# Palco: a construção girando devagar, num fundo vinho com borda dourada.
	var palco := PanelContainer.new()
	var pbox := Palette._box(Palette.BG.darkened(0.15), 24)
	pbox.border_color = Palette.GOLD
	pbox.set_border_width_all(4)
	palco.add_theme_stylebox_override("panel", pbox)
	palco.custom_minimum_size = Vector2(0, 320)
	col.add_child(palco)
	_spin = Node3D.new()
	_stage_tex = Icons3D.render(self, _spin, 384, 1.9, true, Vector3(1.0, 0.75, 2.2))
	var tela := TextureRect.new()
	tela.texture = _stage_tex
	tela.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tela.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	palco.add_child(tela)

	_titulo = Label.new()
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_titulo.add_theme_font_size_override("font_size", 44)
	_titulo.add_theme_color_override("font_color", Palette.BG)
	col.add_child(_titulo)
	_efeitos = HBoxContainer.new()
	_efeitos.alignment = BoxContainer.ALIGNMENT_CENTER
	_efeitos.add_theme_constant_override("separation", 12)
	col.add_child(_efeitos)
	_texto = Label.new()
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.add_theme_font_size_override("font_size", 28)
	_texto.add_theme_color_override("font_color", Palette.INK)
	col.add_child(_texto)

	# O botão principal: grande, dourado, sozinho.
	_btn_construir = Button.new()
	_btn_construir.custom_minimum_size = Vector2(0, 108)
	_btn_construir.add_theme_font_size_override("font_size", 38)
	_btn_construir.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_btn_construir.expand_icon = true
	_btn_construir.add_theme_constant_override("icon_max_width", 52)
	for s in ["normal", "hover", "disabled", "focus"]:
		_btn_construir.add_theme_stylebox_override(s, Palette.key(Palette.GOLD))
	_btn_construir.add_theme_stylebox_override("pressed", Palette.key(Palette.GOLD, true))
	_btn_construir.add_theme_color_override("font_color", Palette.INK)
	_btn_construir.pressed.connect(func() -> void:
		var t := _tipo
		fechar()
		construir.emit(t))
	col.add_child(_btn_construir)

	# X vermelho no canto de cima, à direita (fechar não disputa lugar com construir).
	var fechar_btn := Button.new()
	fechar_btn.text = "X"
	fechar_btn.custom_minimum_size = Vector2(76, 76)
	fechar_btn.add_theme_font_size_override("font_size", 38)
	fechar_btn.add_theme_color_override("font_color", Color.WHITE)
	fechar_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	fechar_btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	var xb := Palette._box(Palette.ALERT, 38)
	xb.border_color = Color.WHITE
	xb.set_border_width_all(4)
	xb.shadow_color = Color(0, 0, 0, 0.35)
	xb.shadow_offset = Vector2(0, 4)
	for s in ["normal", "hover", "pressed", "focus"]:
		fechar_btn.add_theme_stylebox_override(s, xb)
	fechar_btn.pressed.connect(fechar)
	add_child(fechar_btn)   # fora do cartão (o cartão arruma os filhos); a posição segue o canto dele
	_x = fechar_btn


func _process(delta: float) -> void:
	if not visible:
		return
	_spin.rotate_y(delta * 0.9)
	_x.size = Vector2(76, 76)
	_x.position = _card.global_position - global_position + Vector2(_card.size.x * _card.scale.x - 58.0, -18.0)


func abrir(type: String) -> void:
	_tipo = type
	var def: Dictionary = State.ITEMS[type]
	_titulo.text = tr(def.name)
	_texto.text = State.item_text(def.name)
	_texto.visible = _texto.text != ""
	for c in _spin.get_children():
		c.queue_free()
	if model_for.is_valid():
		var m: Node3D = model_for.call(type)
		if m:
			_spin.add_child(m)
	_spin.rotation = Vector3.ZERO
	for c in _efeitos.get_children():
		c.queue_free()
	var rates: Dictionary = State.item_rates({"type": type, "level": 1, "plant": ""})
	if type == "greenhouse":
		_efeito("energy", def.get("energy_when_planted", 0.0))
		_efeito("oxygen", State.PLANT_OXYGEN)
	else:
		for bar in ["energy", "oxygen"]:
			if absf(float(rates[bar])) >= 0.05:
				_efeito(bar, rates[bar])
	if def.has("card") and not State.cards.has(str(def.card)):
		_efeito("card", 1.0)
	_efeitos.visible = _efeitos.get_child_count() > 0
	_btn_construir.text = "%s   -%d" % [tr("INFO_BUILD"), def.cost] if def.cost > 0 else tr("INFO_BUILD")
	_btn_construir.icon = icons.get("energy") if def.cost > 0 else null
	# Bloqueado (falta energia, por exemplo): o botão fica apagado, e o toque explica o porquê.
	_btn_construir.modulate = Color(1, 1, 1, 0.55) if State.build_block_reason(type) != "" else Color.WHITE
	visible = true
	_card.scale = Vector2(0.85, 0.85)
	create_tween().tween_property(_card, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func fechar() -> void:
	visible = false   # a barra de construção continua aberta por baixo


func _efeito(tipo: String, valor: float) -> void:
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
	ic.texture = icons.get(tipo)
	ic.custom_minimum_size = Vector2(44, 44)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	h.add_child(ic)
	var n := Label.new()
	n.add_theme_font_size_override("font_size", 26)
	if tipo == "card":
		n.text = "+1 " + tr("INFO_CARD")
		n.add_theme_color_override("font_color", Palette.GOLD)
	else:
		n.text = ("%+d/sol" % roundi(valor)) if absf(valor) >= 1.0 else ("%+.1f/sol" % valor)
		n.add_theme_color_override("font_color", VERDE if valor >= 0.0 else VERMELHO)
	h.add_child(n)
	_efeitos.add_child(chip)
