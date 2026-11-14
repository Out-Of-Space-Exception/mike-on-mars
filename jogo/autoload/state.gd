extends Node
## O estado do jogo: barras, base, estufas, cartas, eventos e sol. Salva em user://save.json
## (no navegador vira IndexedDB). Toda regra numérica mora no bloco BALANCEAMENTO.

signal changed
signal storm_started(event: Dictionary)
signal storm_ended(shielded: bool)
signal card_won(id: int, is_new: bool)
signal explore_started
signal explore_returned(card_id: int)
signal event_started(type: String)      # poeira, redemoinho, frio, sem sinal (o HUD mostra a janela)
signal event_message(key: String, extra: String)   # avisos curtos (pacote chegou, decoração nova...)

# ───────────── BALANCEAMENTO (todos os números do jogo moram aqui) ─────────────
const SOL_SECONDS := 2.5            # 1 sol (dia de Marte) = 2,5 s de jogo
const SAVE_EVERY := 10.0
const GRID_W := 6
const GRID_H := 8
const BAR_MAX := 100.0
const LOW := 20.0                   # barra abaixo disso trava ou desacelera
const START := {"energy": 60.0, "oxygen": 60.0, "shield": 100.0}
const START_ITEMS := {"2,3": "habitat"}
const MAX_LEVEL := 3
const LEVEL_BONUS := 0.5            # +50% de produção por nível acima do 1
const UPGRADE_COST := {1: 20, 2: 40}  # energia para subir do nível N para N+1
const SHIELD_RECHARGE := 2.0        # por sol, se a energia estiver acima de LOW
const OXYGEN_BREATH := 0.5          # o Mike respira: gasta oxigênio todo sol
const PLANT_OXYGEN := 0.3           # cada planta crescendo na estufa faz um pouco de oxigênio
const EMERGENCY_ENERGY := 0.5       # bateria de emergência da casa, quando a energia está baixa
const SLOW_GROWTH := 0.5            # com energia baixa, a planta cresce pela metade
# "model" = nome do item no design/03-itens-do-jogo/itens.csv · "card" = carta ganha ao construir o 1º
# "decor" = quantas cartas no álbum destravam a decoração · "max" = quantos dá para ter
const ITEMS := {
	"habitat": {"name": "B_HABITAT", "cost": 0, "height": 1.6, "removable": false, "model": "casa-do-mike", "shield": 1.0},
	"greenhouse": {"name": "B_GREENHOUSE", "cost": 15, "height": 1.2, "energy_when_planted": -1.0, "model": "estufa"},
	"solar": {"name": "B_SOLAR", "cost": 10, "height": 0.4, "energy": 3.0, "model": "painel-solar", "card": 11},
	"rtg": {"name": "B_RTG", "cost": 30, "height": 1.0, "energy": 1.0, "model": "rtg", "card": 12},
	"moxie": {"name": "B_MOXIE", "cost": 20, "height": 0.9, "energy": -1.0, "oxygen": 2.0, "model": "moxie", "card": 13},
	"antenna": {"name": "B_ANTENNA", "cost": 15, "height": 1.0, "model": "decoracao-antena", "max": 1},
	"pad": {"name": "B_PAD", "cost": 40, "height": 0.15, "card": 15, "max": 1, "model": "plataforma-pouso"},
	"flag": {"name": "D_FLAG", "cost": 0, "height": 1.4, "model": "decoracao-bandeira", "decor": 5},
	"lights": {"name": "D_LIGHTS", "cost": 0, "height": 1.2, "model": "decoracao-luzinhas", "decor": 10},
	"pot": {"name": "D_POT", "cost": 0, "height": 0.6, "model": "decoracao-vaso", "decor": 15},
}
const BUILDABLE := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad", "flag", "lights", "pot"]
const CARD_KILOPOWER := 14          # RTG no nível 3 vira uma mini usina (carta Kilopower)
const KILOPOWER_ENERGY := 4.0       # o Kilopower (RTG nível 3) dá 4 de energia por sol, dia e noite
# Quantas casas da grade cada nível ocupa (os modelos do design/03 crescem para o lado: nível 3 = 3 casas)
const FOOTPRINT := {"habitat": [1, 2, 3], "greenhouse": [1, 2, 3], "solar": [1, 2, 3]}
const GREENHOUSE_LEVEL_SPEED := 0.5 # estufa maior: +50% de velocidade por nível acima do 1
# Plantas: tempo real proporcional (1 sol ≈ 1 dia). "unlock" = colheitas para destravar a semente.
const PLANTS := {
	"lettuce": {"name": "P_LETTUCE", "sols": 33, "card": 1, "model": "alface", "unlock": 0},
	"radish": {"name": "P_RADISH", "sols": 27, "card": 2, "model": "rabanete", "unlock": 0},
	"kale": {"name": "P_KALE", "sols": 28, "card": 3, "model": "couve", "unlock": 1},
	"zinnia": {"name": "P_ZINNIA", "sols": 60, "card": 5, "model": "zinia", "unlock": 3},
	"chile": {"name": "P_CHILE", "sols": 120, "card": 6, "model": "pimenta", "unlock": 5},
}
# Cartas que chegam com o tempo
const SOL_CARDS := {3: 19, 12: 20, 30: 37}   # 1º dia (Sol), 1ª noite (Frio da Gale), noites seguidas (Fobos e Deimos); espaçadas para não atrapalhar
const BLUE_SUNSET_CHANCE := 0.01    # por sol: carta "Pôr do sol azul"
const EARTH_SEEN_CHANCE := 0.02     # por sol, com antena: carta "Terra vista de Marte"
const CARD_BLUE_SUNSET := 38
const CARD_EARTH_SEEN := 39
# Tempestade solar (dados reais do DONKI em res://data/donki.json)
const FIRST_STORM_SOL := 20         # a 1ª chega cedo, para a criança (e o jurado) ver logo
const STORM_EVERY := Vector2i(30, 50)
const STORM_SOLS := 5               # quanto tempo dura
const STORM_SHIELD_COST := 30.0     # levantar o escudo gasta energia
const STORM_RADIATION := 30.0       # sem escudo, a radiação come a barra de escudo
const AURORA_CHANCE := 0.10         # aguentou com escudo: chance da lendária "Aurora em Marte"
const CARD_STORM := 23              # carta "Tempestade solar de 2024" (1ª tempestade)
const CARD_AURORA := 25
# Outros eventos (sorteados; todo evento tem lado ruim e lado bom)
const EVENT_FIRST_SOL := 40
const EVENT_EVERY := Vector2i(25, 40)
const DUST_SOLS := 15               # painéis sujos
const DUST_FACTOR := 0.3            # painel sujo produz 30%
const COLD_SOLS := 5
const COLD_HEAT_COST := 20.0        # aquecer a estufa gasta energia
const COLD_GROWTH := 0.2            # sem aquecer, a planta quase para
const FROST_CHANCE := 0.35          # de manhã: carta "Geada em Marte"
const NOSIGNAL_SOLS := 10           # sem sinal: o piloto automático segue o plano
const CARD_DUST := 21
const CARD_DEVIL := 22
const CARD_FROST := 24
const PACKAGE_CARDS := [4, 40]      # o pacote da Terra traz batata e depois tomate
# Expedição: o Mike sai da base e volta com um tubo de amostra
const EXPLORE_SOLS := 4             # fica fora 4 sóis (~10 s)
const EXPLORE_OXYGEN := 20.0        # o traje gasta oxigênio
const EXPLORE_RADIATION := 5.0      # lá fora a radiação come um pouco do escudo
const TUBE_ODDS := {"comum": 60, "raro": 27, "épico": 10, "lendário": 3}   # em %
# Crescer com o jogo fechado
const OFFLINE_MIN_SECONDS := 30
const OFFLINE_MAX_SOLS := 2000      # ~1h20 de jogo; depois disso para de contar
# ─────────────────────────────────────────────────────────────────────────────

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

var started := false             # o tempo só corre depois do "Jogar"
var energy := 0.0
var oxygen := 0.0
var shield := 0.0
var sol := 1
var items := {}     # "x,y" -> {"type", "level", "plant", "growth", "spent"}
var cards := {}     # "id" -> quantas vezes ganhou
var harvests := 0
var inventory := {}  # planta -> quantas a criança já colheu
var locale := ""
var paused := false              # o jogo pausa quando a criança precisa escolher
var pending_event := ""          # evento esperando a escolha ou o "OK" da criança
var next_storm_sol := FIRST_STORM_SOL
var storms_seen := 0
var storm_left := 0
var storm_shielded := false
var storm_event := {}
var next_event_sol := EVENT_FIRST_SOL
var dust_left := 0
var cold_left := 0
var cold_heated := false
var nosignal_left := 0
var nosignal_plan := ""
var explore_left := 0            # sóis que faltam para o Mike voltar
var tube_card := 0               # carta dentro do tubo que ainda não foi aberto (0 = nenhum)
var away := {}                   # o que aconteceu com o jogo fechado: {"sols", "plants"}

var _sol_timer := 0.0
var _save_timer := 0.0
var _offline := false
var _donki: Array = []
var _cards_info := {}
var _models := {}


func _ready() -> void:
	_donki = _read_json("res://data/donki.json").get("events", [])
	for c in _read_json("res://data/cartas.json", []):
		_cards_info[int(c.id)] = c
	_models = _read_json("res://data/itens.json", {})
	var saved_at := 0
	if load_game():
		saved_at = int(_read_json(SAVE_PATH).get("saved_at", 0))
	else:
		new_game()
	if locale == "":
		locale = _device_locale()
	TranslationServer.set_locale(locale)
	_catch_up(saved_at)
	# Atalho para testar e gravar o vídeo: abrir o link com ?tempestade traz a tempestade em 2 sóis.
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.search", true)).contains("tempestade"):
		next_storm_sol = sol + 2


func card_info(id: int) -> Dictionary:
	return _cards_info.get(id, {})


func cards_total() -> int:
	return _cards_info.size()


func donki_count() -> int:
	return _donki.size()


## Arquivo .glb do item no jogo (vem do itens.csv do Design), ou "" se ainda não tem.
## Com nível, procura a versão do nível (ex.: casa-do-mike-n2.glb).
func model_file(model_name: String, level := 1) -> String:
	if model_name == "rtg" and level >= MAX_LEVEL and _models.get("files", {}).has("kilopower"):
		return _models.files.kilopower   # o RTG no nível 3 vira o Kilopower (modelo do design/03)
	var file: String = _models.get("files", {}).get(model_name, "")
	if level > 1 and file.contains("-n1."):
		var leveled := file.replace("-n1.", "-n%d." % level)
		if ResourceLoader.exists("res://models/items/" + leveled):
			return leveled
	return file


## Altura do item no jogo, pelo tamanhos.csv do Design (que mede com o Mike = 2,2). 0 = não tem.
func model_height(game_key: String) -> float:
	return float(_models.get("heights", {}).get(game_key, 0.0))


## Como ganhar a carta (texto para a criança, no álbum).
func card_hint(id: int) -> String:
	for p in PLANTS:
		if int(PLANTS[p].card) == id:
			var txt := tr("HOW_HARVEST").format({"name": tr(PLANTS[p].name)})
			if int(PLANTS[p].unlock) > 0:
				txt += " " + tr("HOW_SEED").format({"n": PLANTS[p].unlock})
			return txt
	for t in ITEMS:
		if int(ITEMS[t].get("card", 0)) == id:
			return tr("HOW_BUILD").format({"name": tr(ITEMS[t].name)})
	match id:
		CARD_KILOPOWER:
			return tr("HOW_KILOPOWER")
		CARD_STORM:
			return tr("HOW_STORM")
		CARD_AURORA:
			return tr("HOW_AURORA")
		CARD_DUST:
			return tr("HOW_DUST")
		CARD_DEVIL:
			return tr("HOW_DEVIL")
		CARD_FROST:
			return tr("HOW_FROST")
		CARD_BLUE_SUNSET:
			return tr("HOW_SUNSET")
		CARD_EARTH_SEEN:
			return tr("HOW_EARTH")
	if id in PACKAGE_CARDS:
		return tr("HOW_PACKAGE")
	if SOL_CARDS.values().has(id):
		return tr("HOW_TIME")
	var info := card_info(id)
	if info.get("locked", false):
		return tr("HOW_LOCKED")
	return tr("HOW_TUBE")


func start() -> void:
	started = true


func _process(delta: float) -> void:
	if paused or not started:
		return
	_sol_timer += delta
	while _sol_timer >= SOL_SECONDS:
		_sol_timer -= SOL_SECONDS
		_tick()
	_save_timer += delta
	if _save_timer >= SAVE_EVERY:
		save_game()


func new_game() -> void:
	energy = START.energy
	oxygen = START.oxygen
	shield = START.shield
	sol = 1
	items.clear()
	cards.clear()
	harvests = 0
	inventory.clear()
	paused = false
	pending_event = ""
	next_storm_sol = FIRST_STORM_SOL
	storms_seen = 0
	storm_left = 0
	storm_shielded = false
	storm_event = {}
	next_event_sol = EVENT_FIRST_SOL
	dust_left = 0
	cold_left = 0
	cold_heated = false
	nosignal_left = 0
	nosignal_plan = ""
	explore_left = 0
	tube_card = 0
	for k in START_ITEMS:
		items[k] = _new_item(START_ITEMS[k])
	changed.emit()


# ───────────── Grade ─────────────
static func key(c: Vector2i) -> String:
	return "%d,%d" % [c.x, c.y]


static func parse_key(k: String) -> Vector2i:
	var p := k.split(",")
	return Vector2i(int(p[0]), int(p[1]))


static func in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < GRID_W and c.y < GRID_H


## Quantas casas o item ocupa (para a direita da casa âncora), conforme o nível.
static func width_of(type: String, level: int) -> int:
	var sizes: Array = FOOTPRINT.get(type, [1])
	return int(sizes[clampi(level - 1, 0, sizes.size() - 1)])


## As casas que o item ocupa. Girado de lado (rot 1 ou 3), a fileira vai para a frente em vez de para o lado.
static func cells_of(anchor: Vector2i, type: String, level: int, rot := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var step := Vector2i(1, 0) if rot % 2 == 0 else Vector2i(0, 1)
	for i in width_of(type, level):
		out.append(anchor + step * i)
	return out


static func item_cells(anchor_key: String, it: Dictionary) -> Array[Vector2i]:
	return cells_of(parse_key(anchor_key), it.type, int(it.level), int(it.get("rot", 0)))


## Mapa "casa ocupada" -> "casa âncora do item que está nela".
func _occupancy() -> Dictionary:
	var occ := {}
	for k in items:
		for c in item_cells(k, items[k]):
			occ[key(c)] = k
	return occ


## A casa âncora do item que ocupa a casa c (ou (-1, -1) se está livre).
func anchor_of(c: Vector2i) -> Vector2i:
	var occ := _occupancy()
	return parse_key(occ[key(c)]) if occ.has(key(c)) else Vector2i(-1, -1)


func item_at(c: Vector2i) -> Dictionary:
	var occ := _occupancy()
	return items.get(occ.get(key(c), ""), {})


## Dá para pôr este item (neste nível) com a âncora em c? (ignore = o próprio item, ao mover ou melhorar)
func can_place(type: String, level: int, c: Vector2i, ignore := "", rot := 0) -> bool:
	var occ := _occupancy()
	for cell in cells_of(c, type, level, rot):
		if not in_grid(cell) or (occ.has(key(cell)) and occ[key(cell)] != ignore):
			return false
	return true


func count_items(type: String) -> int:
	var n := 0
	for k in items:
		if items[k].type == type:
			n += 1
	return n


## Nome do item na tela (o RTG no nível 3 vira Kilopower).
func item_name(it: Dictionary) -> String:
	if it.get("type") == "rtg" and int(it.get("level", 1)) >= MAX_LEVEL:
		return "B_KILOPOWER"
	return ITEMS[it.type].name


func free_cells() -> Array[Vector2i]:
	var occ := _occupancy()
	var out: Array[Vector2i] = []
	for x in GRID_W:
		for y in GRID_H:
			if not occ.has(key(Vector2i(x, y))):
				out.append(Vector2i(x, y))
	return out


## Onde o item da âncora "from" cabe se for movido.
func move_targets(from: Vector2i) -> Array[Vector2i]:
	var it: Dictionary = items.get(key(from), {})
	var out: Array[Vector2i] = []
	if it.is_empty():
		return out
	for x in GRID_W:
		for y in GRID_H:
			if Vector2i(x, y) != from and can_place(it.type, int(it.level), Vector2i(x, y), key(from), int(it.get("rot", 0))):
				out.append(Vector2i(x, y))
	return out


## Girar 90°. Quem ocupa mais de uma casa só gira se a fileira nova couber.
func rotate_block_reason(c: Vector2i) -> String:
	var it: Dictionary = items.get(key(c), {})
	if it.is_empty():
		return "MAX_LEVEL"
	if base_locked_reason() != "":
		return base_locked_reason()
	if not can_place(it.type, int(it.level), c, key(c), (int(it.get("rot", 0)) + 1) % 4):
		return "NEED_SPACE"
	return ""


func rotate(c: Vector2i) -> bool:
	if rotate_block_reason(c) != "":
		return false
	items[key(c)].rot = (int(items[key(c)].get("rot", 0)) + 1) % 4
	_after_action()
	return true


# ───────────── Ações (cada uma salva e avisa a tela) ─────────────
func can_afford(cost: float) -> bool:
	return energy >= cost


## Por que não dá para mexer na base agora ("" = dá). Devolve a chave do texto.
func base_locked_reason() -> String:
	return "LOCK_NOSIGNAL" if nosignal_left > 0 else ""


func is_unlocked(type: String) -> bool:
	return cards.size() >= int(ITEMS[type].get("decor", 0))


func build_block_reason(type: String) -> String:
	var def: Dictionary = ITEMS[type]
	if base_locked_reason() != "":
		return base_locked_reason()
	if not is_unlocked(type):
		return "LOCKED_DECOR"
	if def.has("max") and count_items(type) >= int(def.max):
		return "NEED_MAX"
	if not can_afford(def.cost):
		return "NEED_ENERGY"
	return ""


func build(type: String, c: Vector2i) -> bool:
	var def: Dictionary = ITEMS[type]
	if not can_place(type, 1, c) or build_block_reason(type) != "":
		return false
	energy -= def.cost
	items[key(c)] = _new_item(type)
	items[key(c)].spent = def.cost
	if def.has("card") and not cards.has(str(def.card)):
		add_card(int(def.card))
	_after_action()
	return true


func move(from: Vector2i, to: Vector2i) -> bool:
	if base_locked_reason() != "" or not items.has(key(from)) or from == to:
		return false
	var it: Dictionary = items[key(from)]
	if not can_place(it.type, int(it.level), to, key(from), int(it.get("rot", 0))):
		return false
	items[key(to)] = items[key(from)]
	items.erase(key(from))
	_after_action()
	return true


func upgrade_cost(c: Vector2i) -> int:
	var it := item_at(c)
	if it.is_empty():
		return -1
	return UPGRADE_COST.get(int(it.level), -1)


## Por que não dá para melhorar ("" = dá): falta energia ou falta espaço ao lado para o nível maior.
func upgrade_block_reason(c: Vector2i) -> String:
	var it: Dictionary = items.get(key(c), {})
	var cost := upgrade_cost(c)
	if it.is_empty() or cost < 0:
		return "MAX_LEVEL"
	if base_locked_reason() != "":
		return base_locked_reason()
	if not can_place(it.type, int(it.level) + 1, c, key(c), int(it.get("rot", 0))):
		return "NEED_SPACE"
	if not can_afford(cost):
		return "NEED_ENERGY"
	return ""


func upgrade(c: Vector2i) -> bool:
	var cost := upgrade_cost(c)
	if upgrade_block_reason(c) != "":
		return false
	energy -= cost
	items[key(c)].level += 1
	items[key(c)].spent += cost
	if items[key(c)].type == "rtg" and int(items[key(c)].level) == MAX_LEVEL and not cards.has(str(CARD_KILOPOWER)):
		add_card(CARD_KILOPOWER)
	_after_action()
	return true


## Remover devolve tudo o que foi gasto: sem multa.
func remove(c: Vector2i) -> bool:
	var it := item_at(c)
	if base_locked_reason() != "" or it.is_empty() or not ITEMS[it.type].get("removable", true):
		return false
	energy = minf(BAR_MAX, energy + float(it.spent))
	items.erase(key(anchor_of(c)))
	_after_action()
	return true


func unlocked_plants() -> Array:
	var out := []
	for p in PLANTS:
		if harvests >= int(PLANTS[p].unlock):
			out.append(p)
	return out


func plant(c: Vector2i, plant_type: String) -> bool:
	var it := item_at(c)
	if it.get("type") != "greenhouse" or it.plant != "" or not (plant_type in unlocked_plants()):
		return false
	it.plant = plant_type
	it.growth = 0.0
	_after_action()
	return true


func plant_ready(c: Vector2i) -> bool:
	var it := item_at(c)
	return it.get("plant", "") != "" and it.growth >= PLANTS[it.plant].sols


func harvest(c: Vector2i) -> String:
	if not plant_ready(c):
		return ""
	var it := item_at(c)
	var p: String = it.plant
	var before := unlocked_plants().size()
	it.plant = ""
	it.growth = 0.0
	harvests += 1
	inventory[p] = int(inventory.get(p, 0)) + 1
	add_card(PLANTS[p].card)
	if unlocked_plants().size() > before:
		var nova: String = unlocked_plants()[-1]
		event_message.emit("SEED_NEW", tr(PLANTS[nova].name))
	_after_action()
	return p


func add_card(id: int) -> bool:
	var k := str(id)
	var is_new := not cards.has(k)
	var decor_before := _unlocked_decor()
	cards[k] = int(cards.get(k, 0)) + 1
	if not _offline:
		card_won.emit(id, is_new)
		for d in _unlocked_decor():
			if not (d in decor_before):
				event_message.emit("UNLOCK_DECOR", tr(ITEMS[d].name))
	return is_new


func _unlocked_decor() -> Array:
	var out := []
	for t in ITEMS:
		if ITEMS[t].has("decor") and is_unlocked(t):
			out.append(t)
	return out


func set_locale(l: String) -> void:
	locale = l
	TranslationServer.set_locale(l)
	_after_action()


# ───────────── Expedição e tubo de amostra ─────────────
func exploring() -> bool:
	return explore_left > 0


## Por que o Mike não pode sair agora ("" = pode). Devolve a chave do texto para a tela.
func explore_block_reason() -> String:
	if base_locked_reason() != "":
		return base_locked_reason()
	if oxygen < EXPLORE_OXYGEN:
		return "LOCK_OXYGEN"
	if mike_inside():
		return "LOCK_STORM"
	return ""


func start_explore() -> bool:
	if paused or exploring() or tube_card != 0 or explore_block_reason() != "":
		return false
	oxygen -= EXPLORE_OXYGEN
	shield = maxf(0.0, shield - EXPLORE_RADIATION)
	explore_left = EXPLORE_SOLS
	explore_started.emit()
	_after_action()
	return true


## Abre o tubo que o Mike trouxe: a carta vai para o álbum (e aparece na tela).
func open_tube() -> int:
	var id := tube_card
	if id == 0:
		return 0
	tube_card = 0
	add_card(id)
	_after_action()
	return id


func tube_rarity() -> String:
	return card_info(tube_card).get("rarity", "comum")


## Sorteia a raridade pelo TUBE_ODDS e depois uma carta dessa raridade que dá para achar na Gale.
func _draw_tube() -> int:
	var pool := {}
	for id in _cards_info:
		var c: Dictionary = _cards_info[id]
		if c.locked or c.place != "Gale" or not (c.how in ["tubo de amostra", "explorar"]):
			continue
		if not pool.has(c.rarity):
			pool[c.rarity] = []
		pool[c.rarity].append(id)
	if pool.is_empty():
		return 0
	var roll := randi_range(1, 100)
	var rarity := "comum"
	for r in TUBE_ODDS:
		roll -= TUBE_ODDS[r]
		if roll <= 0:
			rarity = r
			break
	if not pool.has(rarity):
		rarity = pool.keys()[0]
	return pool[rarity].pick_random()


# ───────────── Tempestade solar ─────────────
func storm_active() -> bool:
	return storm_left > 0


## Sem escudo, o Mike fica em casa até a tempestade passar (não sai para explorar).
func mike_inside() -> bool:
	return (storm_left > 0 and not storm_shielded) or oxygen <= 0.0


func choose_storm(raise_shield: bool) -> bool:
	if not paused or pending_event != "storm" or (raise_shield and not can_afford(STORM_SHIELD_COST)):
		return false
	storm_shielded = raise_shield
	if raise_shield:
		energy -= STORM_SHIELD_COST
	else:
		shield = maxf(0.0, shield - STORM_RADIATION)
	storm_left = STORM_SOLS
	_resume()
	return true


func _start_storm() -> void:
	if _donki.is_empty():
		next_storm_sol = sol + STORM_EVERY.x
		return
	# A 1ª tempestade é sempre a de 20/05/2024, que o Curiosity mediu aqui na Gale.
	var event: Dictionary = {}
	if storms_seen == 0:
		for e in _donki:
			if e.get("curiosity", false):
				event = e
	if event.is_empty():
		event = _donki[storms_seen % _donki.size()]
	storm_event = event
	storms_seen += 1
	_pause_for("storm")
	storm_started.emit(event)


func _end_storm() -> void:
	var was_shielded := storm_shielded
	next_storm_sol = sol + randi_range(STORM_EVERY.x, STORM_EVERY.y)
	storm_shielded = false
	storm_event = {}
	storm_ended.emit(was_shielded)
	if not cards.has(str(CARD_STORM)):
		add_card(CARD_STORM)
	if was_shielded and randf() < AURORA_CHANCE:
		add_card(CARD_AURORA)
	save_game()


# ───────────── Outros eventos ─────────────
## Eventos que seguram outro evento (a poeira não segura: o redemoinho pode vir limpar).
func event_active() -> bool:
	return cold_left > 0 or nosignal_left > 0


func _start_event() -> void:
	next_event_sol = sol + randi_range(EVENT_EVERY.x, EVENT_EVERY.y)
	var options := ["dust", "cold", "nosignal"]
	if dust_left > 0:
		options = ["devil"]      # painel sujo? o próximo evento é o redemoinho que limpa
	var type: String = options.pick_random()
	if type == "dust":
		dust_left = DUST_SOLS
		_reward_once(CARD_DUST)
	elif type == "devil":
		dust_left = 0
		_reward_once(CARD_DEVIL)
	_pause_for(type)
	event_started.emit(type)


## A criança tocou "OK" num aviso (poeira, redemoinho).
func ack_event() -> void:
	if pending_event in ["dust", "devil"]:
		_resume()


func choose_cold(heat: bool) -> bool:
	if pending_event != "cold" or (heat and not can_afford(COLD_HEAT_COST)):
		return false
	cold_heated = heat
	if heat:
		energy -= COLD_HEAT_COST
	cold_left = COLD_SOLS
	_resume()
	return true


func choose_nosignal(plan: String) -> bool:
	if pending_event != "nosignal":
		return false
	nosignal_plan = plan
	nosignal_left = NOSIGNAL_SOLS
	if plan == "plant":
		for k in items:
			if items[k].type == "greenhouse" and items[k].plant == "":
				items[k].plant = "lettuce"
				items[k].growth = 0.0
	_resume()
	return true


func _end_cold() -> void:
	cold_heated = false
	if randf() < FROST_CHANCE:
		_reward_once(CARD_FROST)


func _end_nosignal() -> void:
	nosignal_plan = ""
	for id in PACKAGE_CARDS:
		if not cards.has(str(id)):
			add_card(id)
			break
	event_message.emit("EV_NOSIGNAL_BACK", "")


func _reward_once(id: int) -> void:
	if not cards.has(str(id)):
		add_card(id)


func _pause_for(event_type: String) -> void:
	paused = true
	pending_event = event_type
	save_game()


func _resume() -> void:
	paused = false
	pending_event = ""
	_after_action()


# ───────────── O tempo passa: 1 sol ─────────────
func _tick() -> void:
	var d_energy := 0.0
	var d_oxygen := 0.0
	var greenhouse_off := nosignal_left > 0 and nosignal_plan == "save"
	for k in items:
		var it: Dictionary = items[k]
		var def: Dictionary = ITEMS[it.type]
		var bonus := 1.0 + LEVEL_BONUS * (int(it.level) - 1)
		var e: float = def.get("energy", 0.0)
		if it.type == "solar" and dust_left > 0:
			e *= DUST_FACTOR
		if it.type == "rtg" and int(it.level) >= MAX_LEVEL:
			e = KILOPOWER_ENERGY
			bonus = 1.0
		if def.has("shield") and energy > LOW:
			shield = minf(BAR_MAX, shield + def.shield * (int(it.level) - 1))
		if it.type == "greenhouse":
			e = def.energy_when_planted if it.plant != "" and not greenhouse_off else 0.0
		d_energy += e * bonus if e > 0.0 else e
		# O MOXIE precisa de energia para fazer oxigênio, como o de verdade.
		if def.has("oxygen") and energy > 0.0:
			d_oxygen += def.oxygen * bonus
		if it.type == "greenhouse" and it.plant != "" and not greenhouse_off and energy > 0.0:
			var speed := 1.0 if energy >= LOW else SLOW_GROWTH
			if cold_left > 0 and not cold_heated:
				speed = COLD_GROWTH
			it.growth += speed * (1.0 + GREENHOUSE_LEVEL_SPEED * (int(it.level) - 1))
			# Planta crescendo faz oxigênio (fotossíntese), como na Estação Espacial.
			d_oxygen += PLANT_OXYGEN
	# O Mike respira. E a casa tem uma bateria de emergência: com pouca energia, ela ajuda devagar
	# (assim a criança nunca fica presa sem conseguir construir nada).
	d_oxygen -= OXYGEN_BREATH
	if energy < LOW:
		d_energy += EMERGENCY_ENERGY
	var had_energy := energy > 0.0
	var had_oxygen := oxygen > 0.0
	energy = clampf(energy + d_energy, 0.0, BAR_MAX)
	oxygen = clampf(oxygen + d_oxygen, 0.0, BAR_MAX)
	if not _offline:
		if had_energy and energy <= 0.0:
			event_message.emit("OUT_ENERGY", "")
		if had_oxygen and oxygen <= 0.0:
			event_message.emit("OUT_OXYGEN", "")
	if energy > LOW:
		shield = minf(BAR_MAX, shield + SHIELD_RECHARGE)
	sol += 1
	if explore_left > 0:
		explore_left -= 1
		if explore_left == 0:
			tube_card = _draw_tube()
			if not _offline:
				explore_returned.emit(tube_card)
	if dust_left > 0:
		dust_left -= 1
	if cold_left > 0:
		cold_left -= 1
		if cold_left == 0:
			_end_cold()
	if nosignal_left > 0:
		nosignal_left -= 1
		if nosignal_left == 0:
			_end_nosignal()
	if not _offline:
		_time_cards()
		if storm_left > 0:
			storm_left -= 1
			if storm_left == 0:
				_end_storm()
		elif sol >= next_storm_sol and not event_active():
			_start_storm()
		elif sol >= next_event_sol and not event_active() and not storm_active():
			_start_event()
	changed.emit()


func _time_cards() -> void:
	if SOL_CARDS.has(sol):
		_reward_once(SOL_CARDS[sol])
	if randf() < BLUE_SUNSET_CHANCE:
		_reward_once(CARD_BLUE_SUNSET)
	if count_items("antenna") > 0 and randf() < EARTH_SEEN_CHANCE:
		_reward_once(CARD_EARTH_SEEN)


## Crescer com o jogo fechado: avança os sóis que passaram (sem eventos) e guarda o resumo.
func _catch_up(saved_at: int) -> void:
	away = {}
	if saved_at <= 0 or paused:
		return
	var seconds := int(Time.get_unix_time_from_system()) - saved_at
	if seconds < OFFLINE_MIN_SECONDS:
		return
	var n := mini(int(seconds / SOL_SECONDS), OFFLINE_MAX_SOLS)
	var ready_before := _ready_plants()
	_offline = true
	for i in n:
		_tick()
	_offline = false
	away = {"sols": n, "plants": maxi(0, _ready_plants() - ready_before)}
	save_game()


func _ready_plants() -> int:
	var n := 0
	for k in items:
		if plant_ready(parse_key(k)):
			n += 1
	return n


# ───────────── Salvar e carregar ─────────────
const _SAVED := ["energy", "oxygen", "shield", "sol", "items", "cards", "harvests", "inventory", "locale", "paused",
	"pending_event", "next_storm_sol", "storms_seen", "storm_left", "storm_shielded", "storm_event",
	"next_event_sol", "dust_left", "cold_left", "cold_heated", "nosignal_left", "nosignal_plan",
	"explore_left", "tube_card"]


func save_game() -> void:
	_save_timer = 0.0
	var data := {"version": SAVE_VERSION, "saved_at": int(Time.get_unix_time_from_system())}
	for k in _SAVED:
		data[k] = get(k)
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))


func load_game() -> bool:
	var data = _read_json(SAVE_PATH, null)
	if typeof(data) != TYPE_DICTIONARY or int(data.get("version", 0)) != SAVE_VERSION:
		return false
	for k in _SAVED:
		if not data.has(k):
			continue
		var current = get(k)
		match typeof(current):
			TYPE_INT:
				set(k, int(data[k]))
			TYPE_FLOAT:
				set(k, float(data[k]))
			TYPE_BOOL:
				set(k, bool(data[k]))
			_:
				set(k, data[k])
	for k in items:
		items[k].level = int(items[k].level)
	# Save antigo (de antes dos eventos novos) com tempestade esperando a escolha.
	if paused and pending_event == "":
		pending_event = "storm" if not storm_event.is_empty() else ""
		paused = pending_event != ""
	return true


func _read_json(path: String, fallback: Variant = {}) -> Variant:
	if not FileAccess.file_exists(path):
		return fallback
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data != null else fallback


func _new_item(type: String) -> Dictionary:
	return {"type": type, "level": 1, "plant": "", "growth": 0.0, "spent": 0.0, "rot": 0}


func _after_action() -> void:
	changed.emit()
	save_game()


func _device_locale() -> String:
	var l := OS.get_locale_language()
	match l:
		"pt":
			return "pt_BR"
		"es", "fr":
			return l
	return "en"
