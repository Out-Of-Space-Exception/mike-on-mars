extends Control
## Estante de exposição (ideia, modelo e primeira versão: dupla de Design, design/05-telas/estante/).
## Constrói como qualquer item (só 1, com a Casa do Mike no nível 2). Tocar nela abre o painel normal
## do item, com um botão a mais: "Ver estante". Ele leva a câmera para a frente da estante (com o céu
## do jogo atrás) e abre embaixo as vagas. Tocar numa vaga: escolhe o que expor, só entre as coisas
## que a criança já tem no álbum (plantas colhidas e pedras achadas explorando).
## Casa do Mike no nível 2: 3 vagas. Casa no último nível (State.MAX_LEVEL): as 6 vagas.
## O que fica exposto mora em State.items[chave].expo (6 textos) e é salvo junto com a base.

const VAGAS := 6
const TAM_VAGA := 0.17          # tamanho de cada coisa exposta, nas medidas do estante.glb
const ALTURA_NA_TELA := 0.42    # a estante ocupa esta fração da altura da tela no zoom
const CENTRO_NA_TELA := 0.30    # e fica com o meio nesta altura (0 = topo), acima do painel
const INCLINACAO := -12.0       # no zoom a câmera olha quase de frente, como na prévia
const FUNDO_ATRAS := 1.2        # o céu do jogo vira um "fundo de foto" logo atrás da estante (em metros)
const INCLINACAO_JOGO := -35.264 # a do jogo (base.gd)
const LARGURA_MAX := 680.0      # no PC o painel fica no meio, como o resto da interface
const TOPO_DO_PAINEL := 0.56    # o painel começa nesta altura da tela (a estante fica acima)

## As pedras com modelo 3D e a carta do álbum que libera cada uma (achada explorando).
## Pedra cuja carta não está no jogo não aparece (a estante só mostra o que dá para ter no álbum).
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

var hud: Node                   # o HUD (a base chega nele depois do _ready)
var base: Node3D:
	get:
		return hud.base if hud else null
var red_x: Callable             # o X vermelho do HUD, igual em todo o jogo
var _chave := ""
var _vaga := -1
var _cam := {}
var _fundo: MeshInstance3D
var _painel: PanelContainer
var _grade: GridContainer
var _lista: GridContainer
var _rolar: ScrollContainer
var _titulo: Label
var _aviso: Label
var _fotos := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP   # aberta, a estante segura os toques (a base não mexe)
	visible = false
	_painel = PanelContainer.new()
	_painel.add_theme_stylebox_override("panel", Palette.paper())
	_painel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_painel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	_painel.add_child(col)
	var topo := HBoxContainer.new()
	topo.add_theme_constant_override("separation", 16)
	col.add_child(topo)
	_titulo = Label.new()
	_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_titulo.add_theme_font_override("font", Palette.font(800))
	_titulo.add_theme_color_override("font_color", Palette.BG)
	_titulo.add_theme_font_size_override("font_size", 38)
	_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	topo.add_child(_titulo)
	if red_x.is_valid():
		topo.add_child(red_x.call(_voltar))
	_aviso = Label.new()
	_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso.add_theme_color_override("font_color", Palette.INK)
	_aviso.add_theme_font_size_override("font_size", 22)
	col.add_child(_aviso)
	_grade = GridContainer.new()
	_grade.columns = 2            # igual à estante: 2 colunas x 3 andares
	_grade.add_theme_constant_override("h_separation", 16)
	_grade.add_theme_constant_override("v_separation", 16)
	_grade.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_grade)
	_rolar = ScrollContainer.new()
	_rolar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rolar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(_rolar)
	_lista = GridContainer.new()
	_lista.columns = 3
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("h_separation", 16)
	_lista.add_theme_constant_override("v_separation", 16)
	_rolar.add_child(_lista)


## Tocar fora do painel: volta um passo (da lista para as vagas; das vagas, fecha).
func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_voltar()


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
	_arrumar()
	_painel.scale = Vector2(0.9, 0.9)
	_painel.pivot_offset = _painel.size / 2.0
	create_tween().tween_property(_painel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func fechar() -> void:
	visible = false
	if _cam.is_empty():
		return
	Sfx.play("toque-botao")
	_inclinar(INCLINACAO_JOGO)
	if _fundo:
		_fundo.queue_free()
		_fundo = null
	base._pos_goal = _cam.pos
	base._size_goal = _cam.size
	base._yaw_goal = _cam.yaw
	base._manual_cam = _cam.manual
	_cam = {}


## O painel fica embaixo, no meio da tela, com no máximo LARGURA_MAX de largura.
func _arrumar() -> void:
	var tela := get_viewport().get_visible_rect().size
	var w := minf(tela.x - 64.0, LARGURA_MAX)
	_painel.position = Vector2((tela.x - w) / 2.0, tela.y * TOPO_DO_PAINEL)
	_painel.size = Vector2(w, tela.y * (1.0 - TOPO_DO_PAINEL) - 32.0)
	_lista.columns = 3 if w >= 600.0 else 2


## Coloca os modelos expostos nas vagas do modelo 3D. Só refaz quando o que está exposto muda.
static func vestir(base_node: Node3D, node: Node3D, it: Dictionary) -> void:
	var expo: Array = it.get("expo", [])
	var livres := vagas_liberadas()
	var sig := "%s|%d" % [str(expo), livres]
	if str(node.get_meta("expo_sig", "")) == sig:
		return
	node.set_meta("expo_sig", sig)
	for i in VAGAS:
		var vaga := node.find_child("vaga-%d" % (i + 1), true, false)
		if vaga == null:
			continue
		var velho := vaga.get_node_or_null("Expo")
		if velho:
			velho.free()
		var item: String = expo[i] if i < expo.size() and i < livres else ""
		var m := _modelo_3d(base_node, item, TAM_VAGA)
		if m == null:
			continue
		var expo_node := Node3D.new()
		expo_node.name = "Expo"
		expo_node.add_child(m)
		vaga.add_child(expo_node)


## O modelo 3D de uma coisa da estante, em pé, cabendo num cubo de "tam" (ou null).
static func _modelo_3d(base_node: Node3D, item: String, tam: float) -> Node3D:
	if item == "plant:potato":
		var holder := Node3D.new()
		holder.add_child(base_node.potato_model())   # a batata é feita no código (não tem .glb)
		base_node._fit(holder, tam, tam)
		return holder
	var nome := _modelo_de(item)
	if nome == "":
		return null
	return base_node._load_model(State.model_file(nome), tam, tam)


## Foto 3D de cada coisa, para as vagas e para a lista (feita uma vez só).
func _foto(item: String) -> Texture2D:
	if _fotos.has(item):
		return _fotos[item]
	var m := _modelo_3d(base, item, 1.0)
	if m == null:
		return null
	var meio := Node3D.new()
	meio.add_child(m)
	m.position.y -= base._merged_aabb(m).size.y * m.scale.y / 2.0
	_fotos[item] = Icons3D.render(self, meio, 160, 1.25, false, Vector3(1.0, 0.85, 1.7))
	return _fotos[item]


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
	if visible:
		_arrumar()


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


## A carta do álbum que libera a coisa (planta: a carta dela; pedra: a carta achada explorando).
static func _carta(item: String) -> int:
	if item.begins_with("plant:"):
		return int(State.PLANTS.get(item.substr(6), {}).get("card", 0))
	return int(_pedra(item.substr(5)).get("carta", 0))


## Já está no álbum? Só o que a criança já ganhou pode ir para a estante.
static func _tem(item: String) -> bool:
	return State.cards.has(str(_carta(item)))


## Tudo o que pode ir para a estante: plantas e pedras com modelo 3D e carta no álbum.
static func _todos() -> Array:
	var out := []
	for p in State.PLANTS:
		out.append("plant:" + p)
	for p in PEDRAS:
		out.append("rock:" + p.id)
	return out.filter(func(item: String) -> bool: return not State.card_info(_carta(item)).is_empty())


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
		var b: Button
		if i >= livres:
			b = _botao("%d · %s" % [i + 1, tr("SHELF_SLOT_LOCKED")], Palette.OFF)
			b.disabled = true
		elif expo[i] == "":
			b = _botao("%d · +" % [i + 1], Palette.BUTTON)
		else:
			b = _botao("%d · %s" % [i + 1, _nome_de(expo[i])], Palette.BUTTON)
			b.icon = _foto(expo[i])
		b.custom_minimum_size = Vector2(0, 88)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(_escolher.bind(i))
		_grade.add_child(b)


func _escolher(i: int) -> void:
	Sfx.play("toque-botao")
	_vaga = i
	_titulo.text = tr("SHELF_PICK").format({"n": i + 1})
	_aviso.text = tr("SHELF_HINT")
	_aviso.visible = true
	_grade.visible = false
	_rolar.visible = true
	_rolar.scroll_vertical = 0
	for c in _lista.get_children():
		c.queue_free()
	var expo := _expo()
	if expo[i] != "":
		var vazio := _ficha(tr("SHELF_EMPTY"), null, Palette.BUTTON)
		vazio.pressed.connect(_colocar.bind(""))
		_lista.add_child(vazio)
	for item in _todos():
		var b: Button
		if not _tem(item):
			b = _ficha("???", null, Palette.OFF)        # ainda não achou: mistério, como no álbum
			b.disabled = true
		else:
			b = _ficha(_nome_de(item), _foto(item), Palette.GOLD if item == expo[i] else Palette.BUTTON)
			b.pressed.connect(_colocar.bind(item))
		_lista.add_child(b)


## Põe a coisa na vaga. Se ela já estava em outra vaga, muda de lugar (cada coisa aparece uma vez só).
func _colocar(item: String) -> void:
	var expo := _expo()
	if item != "":
		var antes := expo.find(item)
		if antes >= 0:
			expo[antes] = ""
	expo[_vaga] = item
	State.save_game()
	var node: Node3D = base._nodes.get(_chave)
	if node:
		vestir(base, node, State.items[_chave])
	Sfx.play("construir")
	_mostrar_vagas()


## X (ou tocar fora): da lista volta para as vagas; das vagas fecha a estante.
func _voltar() -> void:
	if _vaga >= 0:
		Sfx.play("toque-botao")
		_mostrar_vagas()
	else:
		fechar()


## Vaga: tecla larga com a foto à esquerda.
func _botao(texto: String, cor: Color) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_font_override("font", Palette.font(700))
	b.add_theme_font_size_override("font_size", 20)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # nome comprido quebra em 2 linhas (não corta)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 64)
	b.add_theme_constant_override("h_separation", 12)
	_pintar(b, cor)
	return b


## Coisa da lista: foto em cima e o nome embaixo.
func _ficha(texto: String, foto: Texture2D, cor: Color) -> Button:
	var b := Button.new()
	b.text = texto
	b.icon = foto
	b.custom_minimum_size = Vector2(0, 152 if foto else 96)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", Palette.font(700))
	b.add_theme_font_size_override("font_size", 19)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.expand_icon = true
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_constant_override("icon_max_width", 80)
	_pintar(b, cor)
	return b


func _pintar(b: Button, cor: Color) -> void:
	for s in ["normal", "hover", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, Palette.key(cor))
	b.add_theme_stylebox_override("pressed", Palette.key(cor, true))
	var tinta := Palette.TEXT if cor == Palette.OFF else (Palette.INK if cor == Palette.GOLD else Palette.INK_DEEP)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		b.add_theme_color_override(c, tinta)
