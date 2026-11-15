extends Control
## Painel de informação da construção (Design 05). Abre ao tocar num botão da barra de construção.
## Mostra nome, modelo, efeitos (ícones da barra de cima + número) e uma frase curta.
## Botões: "Fechar" (volta com a barra de construção aberta) e "Construir -N ⚡".
## Os números vêm do State.ITEMS (jogo/autoload/state.gd): se o jogo mudar, o painel muda junto.
## Como ligar no hud.gd: veja o LEIAME.md desta pasta.
## Cópia da Dev, ajustada para a tela em pé do celular (720 de largura): o original é design/05-telas/info-construcao/.

signal construir(type: String)

## Itens que abrem este painel (os outros vão direto para a construção, como hoje).
const COM_INFO := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad"]
const PASTA := "res://ui/info-construcao/"   # copie as imagens desta pasta do design para cá
const IMG := {"greenhouse": "item-estufa.png", "solar": "item-solar.png", "rtg": "item-rtg.png",
	"moxie": "item-moxie.png", "antenna": "item-antena.png", "pad": "item-pista.png"}
const ICONE := {"energy": "res://ui/icons/ic-energia.svg", "oxygen": "res://ui/icons/ic-oxigenio.svg"}
const VERDE := Color("6cc04a")
const VINHO_CLARO := Color("4a2226")

var _tipo := ""
var _titulo: Label
var _imagem: TextureRect
var _efeitos: VBoxContainer
var _texto: Label
var _btn_construir: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var fundo := ColorRect.new(); fundo.color = Color(0, 0, 0, 0.45)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(fundo)
	fundo.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: fechar())
	var centro := CenterContainer.new(); centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(centro)
	var painel := PanelContainer.new(); painel.custom_minimum_size = Vector2(680, 0)
	painel.add_theme_stylebox_override("panel", Palette.plate()); centro.add_child(painel)
	var col := VBoxContainer.new(); col.add_theme_constant_override("separation", 18); painel.add_child(col)
	# título na placa creme da moldura das cartas
	var placa := TextureRect.new(); placa.texture = load(PASTA + "placa-titulo.png")
	placa.custom_minimum_size = Vector2(600, 80); placa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	placa.stretch_mode = TextureRect.STRETCH_SCALE; placa.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(placa)
	_titulo = _label(38, Palette.BG); _titulo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; _titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placa.add_child(_titulo)
	# modelo + efeitos + texto
	var linha := HBoxContainer.new(); linha.add_theme_constant_override("separation", 20); col.add_child(linha)
	var caixa := PanelContainer.new(); caixa.custom_minimum_size = Vector2(210, 210)
	var sb := StyleBoxFlat.new(); sb.bg_color = VINHO_CLARO; sb.border_color = Palette.GOLD
	sb.set_border_width_all(3); sb.set_corner_radius_all(18); caixa.add_theme_stylebox_override("panel", sb)
	linha.add_child(caixa)
	_imagem = TextureRect.new(); _imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; caixa.add_child(_imagem)
	var dir := VBoxContainer.new(); dir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dir.add_theme_constant_override("separation", 12); linha.add_child(dir)
	_efeitos = VBoxContainer.new(); _efeitos.add_theme_constant_override("separation", 10); dir.add_child(_efeitos)
	_texto = _label(26, Palette.TEXT); _texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; dir.add_child(_texto)
	# botões
	var botoes := HBoxContainer.new(); botoes.add_theme_constant_override("separation", 20)
	botoes.alignment = BoxContainer.ALIGNMENT_CENTER; col.add_child(botoes)
	var b_fechar := _botao(tr("INFO_CLOSE")); b_fechar.pressed.connect(fechar); botoes.add_child(b_fechar)
	_btn_construir = _botao(""); _btn_construir.icon = load(ICONE.energy)
	_btn_construir.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT   # número antes do ícone: "Construir -10 ⚡"
	_btn_construir.add_theme_color_override("icon_normal_color", Palette.GOLD)
	_btn_construir.pressed.connect(func(): var t := _tipo; fechar(); construir.emit(t))
	botoes.add_child(_btn_construir)
	# ornamento das luas (moldura das cartas)
	var orn := TextureRect.new(); orn.texture = load(PASTA + "ornamento-luas.png")
	orn.custom_minimum_size = Vector2(440, 30); orn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	orn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; orn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(orn)

func abrir(type: String) -> void:
	_tipo = type
	var def: Dictionary = State.ITEMS[type]
	_titulo.text = tr(def.name)
	_imagem.texture = load(PASTA + IMG[type])
	_texto.text = tr("INFO_" + def.name.trim_prefix("B_"))
	for c in _efeitos.get_children(): c.queue_free()
	if type == "greenhouse":
		_efeito("energy", def.get("energy_when_planted", 0.0), "INFO_WHEN_PLANTING")
		_efeito("oxygen", State.PLANT_OXYGEN, "INFO_EACH_PLANT", true)
	else:
		if def.has("energy"): _efeito("energy", def.energy, "INFO_ENERGY_SOL")
		if def.has("oxygen"): _efeito("oxygen", def.oxygen, "INFO_OXYGEN_SOL")
		if def.has("card"): _efeito("card", 1, "INFO_CARD")
	_btn_construir.text = "%s  -%d" % [tr("INFO_BUILD"), def.cost]
	# Bloqueado (falta energia, por exemplo): o botão fica apagado, e o toque explica o porquê.
	_btn_construir.modulate = Color(1, 1, 1, 0.55) if State.build_block_reason(type) != "" else Color.WHITE
	visible = true

func fechar() -> void:
	visible = false   # a barra de construção continua aberta por baixo

func _efeito(tipo: String, valor: float, chave: String, so_sinal := false) -> void:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new(); sb.bg_color = VINHO_CLARO; sb.set_corner_radius_all(12)
	sb.content_margin_left = 14; sb.content_margin_right = 14; sb.content_margin_top = 8; sb.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new(); h.add_theme_constant_override("separation", 14); p.add_child(h)
	var ic := TextureRect.new(); ic.custom_minimum_size = Vector2(40, 40)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if tipo == "card":
		ic.texture = load(PASTA + "ic-carta.png"); ic.modulate = Palette.GOLD
	else:
		ic.texture = load(ICONE[tipo]); ic.modulate = Palette.BAR[tipo]
	h.add_child(ic)
	var sinal := "+" if valor >= 0 else "-"
	var n := _label(36, VERDE if valor >= 0 else Palette.ALERT)
	n.text = sinal if so_sinal else "%s%s" % [sinal, str(snappedf(absf(valor), 0.1)).trim_suffix(".0")]
	h.add_child(n)
	var l := _label(26, Palette.TEXT); l.text = tr(chave); h.add_child(l)
	_efeitos.add_child(p)

func _label(tam: int, cor: Color) -> Label:
	var l := Label.new(); l.add_theme_font_size_override("font_size", tam); l.add_theme_color_override("font_color", cor)
	return l

func _botao(texto: String) -> Button:
	var b := Button.new(); b.text = texto; b.custom_minimum_size = Vector2(300, 84)
	b.add_theme_font_size_override("font_size", 30)
	return b   # o tema do jogo já pinta o botão de terracota, como na barra de construção
