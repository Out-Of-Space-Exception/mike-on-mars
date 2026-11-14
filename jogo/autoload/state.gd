extends Node
## O estado do jogo: barras, base, estufas, cartas e sol. Salva em user://save.json
## (no navegador vira IndexedDB). Toda regra numérica mora no bloco BALANCEAMENTO.

signal changed

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
const SLOW_GROWTH := 0.5            # com energia baixa, a planta cresce pela metade
const ITEMS := {
	"habitat": {"name": "B_HABITAT", "cost": 0, "height": 1.6, "removable": false},
	"greenhouse": {"name": "B_GREENHOUSE", "cost": 15, "height": 1.2, "energy_when_planted": -1.0},
	"solar": {"name": "B_SOLAR", "cost": 10, "height": 0.4, "energy": 3.0},
	"rtg": {"name": "B_RTG", "cost": 30, "height": 1.0, "energy": 1.0},
	"moxie": {"name": "B_MOXIE", "cost": 20, "height": 0.9, "energy": -1.0, "oxygen": 2.0},
}
const BUILDABLE := ["greenhouse", "solar", "rtg", "moxie"]
const PLANTS := {"lettuce": {"name": "P_LETTUCE", "sols": 33, "card": 1}}
# ─────────────────────────────────────────────────────────────────────────────

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

var energy := 0.0
var oxygen := 0.0
var shield := 0.0
var sol := 1
var items := {}     # "x,y" -> {"type", "level", "plant", "growth", "spent"}
var cards := {}     # "id" -> quantas vezes ganhou
var locale := ""

var _sol_timer := 0.0
var _save_timer := 0.0


func _ready() -> void:
	if not load_game():
		new_game()
	if locale == "":
		locale = _device_locale()
	TranslationServer.set_locale(locale)


func _process(delta: float) -> void:
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


func item_at(c: Vector2i) -> Dictionary:
	return items.get(key(c), {})


func free_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x in GRID_W:
		for y in GRID_H:
			if not items.has(key(Vector2i(x, y))):
				out.append(Vector2i(x, y))
	return out


# ───────────── Ações (cada uma salva e avisa a tela) ─────────────
func can_afford(cost: float) -> bool:
	return energy >= cost


func build(type: String, c: Vector2i) -> bool:
	var cost: float = ITEMS[type].cost
	if not in_grid(c) or items.has(key(c)) or not can_afford(cost):
		return false
	energy -= cost
	items[key(c)] = _new_item(type)
	items[key(c)].spent = cost
	_after_action()
	return true


func move(from: Vector2i, to: Vector2i) -> bool:
	if not items.has(key(from)) or items.has(key(to)) or not in_grid(to):
		return false
	items[key(to)] = items[key(from)]
	items.erase(key(from))
	_after_action()
	return true


func upgrade_cost(c: Vector2i) -> int:
	var it := item_at(c)
	return UPGRADE_COST.get(int(it.get("level", MAX_LEVEL)), -1)


func upgrade(c: Vector2i) -> bool:
	var cost := upgrade_cost(c)
	if cost < 0 or not can_afford(cost):
		return false
	energy -= cost
	items[key(c)].level += 1
	items[key(c)].spent += cost
	_after_action()
	return true


## Remover devolve tudo o que foi gasto: sem multa.
func remove(c: Vector2i) -> bool:
	var it := item_at(c)
	if it.is_empty() or not ITEMS[it.type].get("removable", true):
		return false
	energy = minf(BAR_MAX, energy + float(it.spent))
	items.erase(key(c))
	_after_action()
	return true


func plant(c: Vector2i, plant_type: String) -> bool:
	var it := item_at(c)
	if it.get("type") != "greenhouse" or it.plant != "":
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
	it.plant = ""
	it.growth = 0.0
	add_card(PLANTS[p].card)
	_after_action()
	return p


func add_card(id: int) -> bool:
	var k := str(id)
	var is_new := not cards.has(k)
	cards[k] = int(cards.get(k, 0)) + 1
	return is_new


func set_locale(l: String) -> void:
	locale = l
	TranslationServer.set_locale(l)
	_after_action()


# ───────────── O tempo passa: 1 sol ─────────────
func _tick() -> void:
	var d_energy := 0.0
	var d_oxygen := 0.0
	for k in items:
		var it: Dictionary = items[k]
		var def: Dictionary = ITEMS[it.type]
		var bonus := 1.0 + LEVEL_BONUS * (int(it.level) - 1)
		var e: float = def.get("energy", 0.0)
		if it.type == "greenhouse" and it.plant != "":
			e = def.energy_when_planted
		d_energy += e * bonus if e > 0.0 else e
		# O MOXIE precisa de energia para fazer oxigênio, como o de verdade.
		if def.has("oxygen") and energy > 0.0:
			d_oxygen += def.oxygen * bonus
		if it.type == "greenhouse" and it.plant != "":
			it.growth += 1.0 if energy >= LOW else SLOW_GROWTH
	energy = clampf(energy + d_energy, 0.0, BAR_MAX)
	oxygen = clampf(oxygen + d_oxygen, 0.0, BAR_MAX)
	if energy > LOW:
		shield = minf(BAR_MAX, shield + SHIELD_RECHARGE)
	sol += 1
	changed.emit()


# ───────────── Salvar e carregar ─────────────
func save_game() -> void:
	_save_timer = 0.0
	var data := {
		"version": SAVE_VERSION, "saved_at": int(Time.get_unix_time_from_system()),
		"energy": energy, "oxygen": oxygen, "shield": shield, "sol": sol,
		"items": items, "cards": cards, "locale": locale,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY or int(data.get("version", 0)) != SAVE_VERSION:
		return false
	energy = float(data.energy)
	oxygen = float(data.oxygen)
	shield = float(data.shield)
	sol = int(data.sol)
	locale = str(data.get("locale", ""))
	cards = data.get("cards", {})
	items.clear()
	for k in data.items:
		var it: Dictionary = data.items[k]
		it.level = int(it.level)
		items[k] = it
	return true


func _new_item(type: String) -> Dictionary:
	return {"type": type, "level": 1, "plant": "", "growth": 0.0, "spent": 0.0}


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
