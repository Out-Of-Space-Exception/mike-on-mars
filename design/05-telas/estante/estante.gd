extends Control
## Estante de exposição (ideia e modelo: dupla de Design, design/03-itens-do-jogo/estante/).
## Constrói como qualquer item. Tocar nela abre o painel normal do item, com um botão a mais:
## "Ver estante". Ele leva a câmera para a frente da estante (com o céu do jogo atrás) e abre
## embaixo as vagas. Tocar numa vaga: escolhe uma planta ou pedra que a criança já conquistou.
## Casa do Mike no nível 2: 3 vagas. Casa no último nível (State.MAX_LEVEL): as 6 vagas.
## O que fica exposto mora em State.items[chave].expo (6 textos) e é salvo junto com a base.

const VAGAS := 6
const TAM_VAGA := 0.17          # tamanho de cada vaga, nas medidas do estante.glb
const ALTURA_NA_TELA := 0.42    # a estante ocupa esta fração da altura da tela no zoom
const CENTRO_NA_TELA := 0.30    # e fica com o meio nesta altura (0 = topo), acima do painel
const INCLINACAO := -12.0      # no zoom a câmera olha quase de frente, como na prévia
const FUNDO_ATRAS := 1.2        # o céu do jogo vira um "fundo de foto" logo atrás da estante (em metros)
const INCLINACAO_JOGO := -35.264 # a do jogo (base.gd)

## Tudo o que pode ir para a estante. "carta": a carta que libera (achada explorando, no tubo de amostra).
## Se a carta não existe no jogo, a pedra já começa liberada.
const PEDRAS := [
	{"id": "hematita", "modelo": "hematita", "carta": 7},
	{"id": "enxofre", "modelo": "enxofre", "carta": 9},
	{"id": "leopardo", "modelo": "leopardo", "carta": 10},
	{"id": "veios-brancos", "modelo": "veios-brancos", "carta": 26},
	{"id": "rocknest-3", "modelo": "rocknest-3", "carta": 41},
	{"id": "oxido-de-manganes", "modelo": "oxido-de-manganes", "carta": 32},
	{"id": "john-klein-a", "modelo": "john-klein-a", "carta": 34},
	{"id": "john-klein-b", "modelo": "john-klein-b", "carta": 34},
	{"id": "john-klein-c", "modelo": "john-klein-c", "carta": 34},
	{"id": "meteorito-lebanon", "modelo": "meteorito-lebanon", "carta": 35},
]

var base: Node3D                # a cena da base (se ninguém passar, pega a da cena principal)
var _chave := ""
var _vaga := -1
var _cam := {}
var _fundo: MeshInstance3D
var _grade: GridContainer
var _lista: GridContainer
var _rolar: ScrollContainer
var _titulo: Label
var _aviso: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var painel := PanelContainer.new()
	painel.add_theme_stylebox_override("panel", Palette.paper(Palette.GOLD))
	painel.anchor_left = 0.0
	painel.anchor_right = 1.0
	painel.anchor_top = 0.58
	painel.anchor_bottom = 1.0
	painel.offset_left = 16
	painel.offset_right = -16
	painel.offset_bottom = -16
	painel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(painel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	painel.add_child(col)
	var topo := HBoxContainer.new()
	col.add_child(topo)
	_titulo = Label.new()
	_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_titulo.add_theme_color_override("font_color", Palette.BG)
	_titulo.add_theme_font_size_override("font_size", 34)
	topo.add_child(_titulo)
	var x := _botao("X", Palette.GOLD)
	x.custom_minimum_size = Vector2(72, 64)
	x.pressed.connect(_voltar)
	topo.add_child(x)
	_aviso = Label.new()
	_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso.add_theme_color_override("font_color", Palette.INK)
	_aviso.add_theme_font_size_override("font_size", 22)
	col.add_child(_aviso)
	_grade = GridContainer.new()
	_grade.columns = 2            # igual à estante: 2 colunas x 3 andares
	_grade.add_theme_constant_override("h_separation", 12)
	_grade.add_theme_constant_override("v_separation", 12)
	_grade.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_grade)
	_rolar = ScrollContainer.new()
	_rolar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rolar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(_rolar)
	_lista = GridContainer.new()
	_lista.columns = 2
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("h_separation", 10)
	_lista.add_theme_constant_override("v_separation", 10)
	_rolar.add_child(_lista)


## Quantas vagas a Casa do Mike libera agora: 0 (antes do nível 2), 3 ou 6 (último nível).
static func vagas_liberadas() -> int:
	var nivel := State.house_level()
	if nivel >= State.MAX_LEVEL:
		return 6
	if nivel >= 2:
		return 3
	return 0


## Abre a estante da chave (a casa âncora em State.items): câmera de frente para ela, como na prévia.
func abrir(chave: String) -> void:
	if base == null:
		base = get_tree().current_scene.get("base")
	_chave = chave
	_vaga = -1
	var node: Node3D = base._nodes.get(chave)
	_cam = {"pos": base._pos_goal, "size": base._size_goal, "yaw": base._yaw_goal, "manual": base._manual_cam}
	_inclinar(INCLINACAO)
	_por_fundo()
	base._take_camera()
	if node:
		var caixa: AABB = node.global_transform * base._merged_aabb(node)
		var modelo: Node3D = node.get_node_or_null("Model")
		var frente: Vector3 = (modelo if modelo else node).global_transform.basis.z
		var yaw := atan2(frente.x, frente.z)
		var tela := get_viewport().get_visible_rect().size
		var proporcao := tela.y / maxf(tela.x, 1.0)
		var alto_visivel := caixa.size.y / ALTURA_NA_TELA
		var cima := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, deg_to_rad(INCLINACAO)) * Vector3.UP
		base._yaw_goal = yaw
		base._size_goal = alto_visivel / proporcao        # a câmera mede pela largura (KEEP_WIDTH)
		base._pos_goal = caixa.get_center() - cima * (0.5 - CENTRO_NA_TELA) * alto_visivel
	visible = true
	_mostrar_vagas()


func fechar() -> void:
	visible = false
	if _cam.is_empty():
		return
	_inclinar(INCLINACAO_JOGO)
	if _fundo:
		_fundo.queue_free()
		_fundo = null
	base._pos_goal = _cam.pos
	base._size_goal = _cam.size
	base._yaw_goal = _cam.yaw
	base._manual_cam = _cam.manual
	_cam = {}


## Coloca os modelos expostos nas vagas do modelo 3D (chamar ao criar a estante e quando mudar).
static func vestir(base_node: Node3D, node: Node3D, it: Dictionary) -> void:
	var expo: Array = it.get("expo", [])
	var livres := vagas_liberadas()
	for i in VAGAS:
		var vaga := node.find_child("vaga-%d" % (i + 1), true, false)
		if vaga == null:
			continue
		var velho := vaga.get_node_or_null("Expo")
		if velho:
			velho.free()
		var item: String = expo[i] if i < expo.size() and i < livres else ""
		var modelo := _modelo_de(item)
		if modelo == "":
			continue
		var m: Node3D = base_node._load_model(State.model_file(modelo), 1.0, 1.0)
		if m == null:
			continue
		var holder := Node3D.new()
		holder.add_child(m)
		base_node._fit(holder, TAM_VAGA, TAM_VAGA)
		var expo_node := Node3D.new()
		expo_node.name = "Expo"
		expo_node.add_child(holder)
		vaga.add_child(expo_node)


## O mesmo céu do jogo (o material do base.gd), só que logo atrás da estante: cobre o chão do
## planetinha que ficaria atrás dela quando a câmera olha de frente. Sai quando a estante fecha.
func _por_fundo() -> void:
	if base.get("_sky") == null or _fundo:
		return
	_fundo = MeshInstance3D.new()
	_fundo.mesh = QuadMesh.new()
	_fundo.material_override = base._sky_mat
	_fundo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	base.camera.add_child(_fundo)
	_fundo.position = Vector3(0.0, 0.0, -(40.0 + FUNDO_ATRAS))


func _process(_delta: float) -> void:
	if _fundo:
		_fundo.scale = base._sky.scale   # acompanha o zoom, igual ao céu do jogo


## Gira a câmera para cima/baixo devagar (ela fica a 40 m do tripé, como no base.gd).
func _inclinar(graus: float) -> void:
	var cam: Camera3D = base.camera
	create_tween().tween_method(func(a: float) -> void:
		cam.rotation_degrees.x = a
		cam.position = cam.transform.basis.z * 40.0, cam.rotation_degrees.x, graus, 0.45).set_trans(Tween.TRANS_SINE)


static func _pedra(id: String) -> Dictionary:
	for p in PEDRAS:
		if p.id == id:
			return p
	return {}


static func _modelo_de(item: String) -> String:
	if item.begins_with("plant:"):
		return State.PLANTS.get(item.substr(6), {}).get("model", "")
	if item.begins_with("rock:"):
		return _pedra(item.substr(5)).get("modelo", "")
	return ""


static func _nome_de(item: String) -> String:
	if item.begins_with("plant:"):
		return TranslationServer.translate(State.PLANTS[item.substr(6)].name)
	if item.begins_with("rock:"):
		return TranslationServer.translate("SHELF_" + item.substr(5).to_upper().replace("-", "_"))
	return TranslationServer.translate("SHELF_EMPTY")


## A criança já conquistou? Planta: colheu pelo menos 1. Pedra: ganhou a carta (explorando).
static func _tem(item: String) -> bool:
	if item.begins_with("plant:"):
		return int(State.inventory.get(item.substr(6), 0)) > 0
	var carta := int(_pedra(item.substr(5)).get("carta", 0))
	if carta == 0 or State.card_info(carta).is_empty():
		return true
	return State.cards.has(str(carta))


## Tudo o que pode ir para a estante (plantas e pedras com modelo 3D).
static func _todos() -> Array:
	var out := []
	for p in State.PLANTS:
		out.append("plant:" + p)
	for p in PEDRAS:
		out.append("rock:" + p.id)
	return out


func _expo() -> Array:
	var it: Dictionary = State.items[_chave]
	var expo: Array = it.get("expo", [])
	while expo.size() < VAGAS:
		expo.append("")
	it["expo"] = expo
	return expo


func _mostrar_vagas() -> void:
	_vaga = -1
	_titulo.text = tr("SHELF_TITLE")
	_grade.visible = true
	_rolar.visible = false
	var livres := vagas_liberadas()
	_aviso.text = tr("SHELF_MORE") if livres < VAGAS else ""
	_aviso.visible = _aviso.text != ""
	for c in _grade.get_children():
		c.queue_free()
	var expo := _expo()
	for i in VAGAS:
		var texto := "%d · %s" % [i + 1, _nome_de(expo[i]) if expo[i] != "" else "+"]
		if i >= livres:
			texto = "%d · %s" % [i + 1, tr("SHELF_SLOT_LOCKED")]
		var b := _botao(texto, Palette.BG.lightened(0.85))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = i >= livres
		b.pressed.connect(_escolher.bind(i))
		_grade.add_child(b)


func _escolher(i: int) -> void:
	_vaga = i
	_titulo.text = tr("SHELF_PICK").format({"n": i + 1})
	_aviso.text = tr("SHELF_HINT")
	_aviso.visible = true
	_grade.visible = false
	_rolar.visible = true
	for c in _lista.get_children():
		c.queue_free()
	var expo := _expo()
	var vazio := _botao(tr("SHELF_EMPTY"), Palette.BG.lightened(0.85))
	vazio.pressed.connect(_colocar.bind(""))
	_lista.add_child(vazio)
	for item in _todos():
		var b: Button
		if not _tem(item):
			b = _botao("???", Palette.OFF)        # ainda não achou: mistério, como num álbum
			b.disabled = true
		elif item in expo and expo[i] != item:
			b = _botao(_nome_de(item), Palette.BG.lightened(0.7))
			b.disabled = true               # cada coisa aparece uma vez só
		else:
			b = _botao(_nome_de(item), Palette.BG.lightened(0.85))
			b.pressed.connect(_colocar.bind(item))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_lista.add_child(b)


func _colocar(item: String) -> void:
	var expo := _expo()
	expo[_vaga] = item
	State.save_game()
	var node: Node3D = base._nodes.get(_chave)
	if node:
		vestir(base, node, State.items[_chave])
	Sfx.play("construir")
	_mostrar_vagas()


## X: da lista volta para as vagas; das vagas fecha a estante.
func _voltar() -> void:
	if _vaga >= 0:
		_mostrar_vagas()
	else:
		fechar()


func _botao(texto: String, cor: Color) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, 64)
	b.add_theme_font_size_override("font_size", 24)
	b.clip_text = true
	for s in ["normal", "hover", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, Palette.key(cor))
	b.add_theme_stylebox_override("pressed", Palette.key(cor, true))
	var tinta := Palette.INK if cor.get_luminance() > 0.4 else Palette.TEXT
	b.add_theme_color_override("font_color", tinta)
	b.add_theme_color_override("font_disabled_color", tinta.lerp(cor, 0.45))
	return b
