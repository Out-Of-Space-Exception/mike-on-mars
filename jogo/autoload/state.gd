extends Node
## Game state: bars, base, greenhouses, cards, events and sol. Saved to user://save.json
## (in the browser it becomes IndexedDB). Every numeric rule lives in the BALANCE block.

signal changed
signal storm_started(event: Dictionary)
signal storm_ended(shielded: bool)
signal card_won(id: int, is_new: bool)
signal explore_started
signal explore_returned(card_id: int)
signal event_started(type: String)      # dust, dust devil, cold, no signal (the HUD shows the window)
signal event_message(key: String, extra: String)   # short notices (package arrived, new decoration...)

# ───────────── BALANCE (all the game numbers live here) ─────────────
const SOL_SECONDS := 3.5            # 1 sol (a Mars day) = 3.5 s of game time (longer game, Design request)
const SAVE_EVERY := 10.0
const GRID_W := 10
const GRID_H := 10
const BAR_MAX := 100.0
const LOW_PART := 0.2               # bar below 1/5 of its cap: things slow down (at level 3, below 20)
const START := {"energy": 20.0, "oxygen": 40.0, "shield": 40.0}   # slow start: the house makes the bars grow
## Bar caps: Mike's House makes the bars grow. Level 1: energy up to 20, oxygen and shield up to 40;
## level 2: everything up to 60; level 3: everything up to 100. Upgrading the house also fills the bars up to the new cap.
const BAR_CAPS := {
	1: {"energy": 20.0, "oxygen": 40.0, "shield": 40.0},
	2: {"energy": 60.0, "oxygen": 60.0, "shield": 60.0},
	3: {"energy": 100.0, "oxygen": 100.0, "shield": 100.0},
}
const HOUSE_UPGRADE_COST := {1: 18, 2: 55}   # upgrading the house always fits in the energy bar of its level
const START_ITEMS := {"4,4": "habitat"}
const START_INVENTORY := {"lettuce": 1}   # a snack that came from Earth, for the 1st expedition
const MAX_LEVEL := 3
## The base area grows with Mike's House level: 4x4 at level 1, 7x7 at 2 and the whole grid (10x10) at 3.
const ZONES := {1: Rect2i(3, 3, 4, 4), 2: Rect2i(2, 2, 7, 7), 3: Rect2i(0, 0, GRID_W, GRID_H)}
const OLD_GRID_SHIFT := Vector2i(2, 1)   # saves from the old grid (6x8) move to the middle of the new one
const LEVEL_BONUS := 0.5            # +50% production per level above 1
const UPGRADE_MULT := {1: 3.0, 2: 8.0}   # upgrading costs the build price x3 (level 2) and x8 (level 3)
const UPGRADE_MAX := 95                  # cap: the energy bar goes up to 100
const UPGRADE_BASE_FREE := 10.0          # for things that cost nothing to build (Mike's House)
# Broken equipment: from time to time (and sometimes after a storm without shield) something stops working.
const BREAK_EVERY := Vector2i(110, 170)  # sols between one breakdown and the next
const BREAK_AFTER_STORM := 0.5           # without shield: chance that something breaks
const REPAIR_FACTOR := 0.4               # repairing costs 40% of the build price (at least 6)
const BREAKABLE := ["greenhouse", "solar", "rtg", "moxie", "antenna"]
const SHIELD_RECHARGE := 2.0        # per sol, if energy is not low (and the shield is not full)
const SHIELD_RADIATION := 1.0       # every sol, Mars radiation eats a little of the shield (it never stays full by itself)
const SHIELD_ENERGY_COST := 0.5     # recharging the shield uses energy: the child chooses where the energy goes
const OXYGEN_BREATH := 0.5          # Mike breathes: uses oxygen every sol
const PLANT_OXYGEN := 0.3           # each plant growing in the greenhouse makes a little oxygen
const EMERGENCY_ENERGY := 0.5       # the house's emergency battery, when energy is low
const SLOW_GROWTH := 0.5            # with low energy, the plant grows at half speed
# "model" = item name in design/03-itens-do-jogo/itens.csv · "card" = card won when building the 1st one
# "decor" = how many cards in the album unlock the decoration · "max" = how many you can have
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
	# Display shelf (Design): only 1, with Mike's House at level 2. The house is what unlocks the slots.
	"shelf": {"name": "D_SHELF", "cost": 0, "height": 1.8, "model": "estante", "max": 1, "house": 2},
}
const BUILDABLE := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad", "flag", "lights", "pot", "shelf"]
const CARD_KILOPOWER := 14          # RTG at level 3 becomes a mini power plant (Kilopower card)
const KILOPOWER_ENERGY := 4.0       # the Kilopower (level 3 RTG) gives 4 energy per sol, day and night
## Solar panel energy per level (it takes 1, 2 and 3 cells). It grows with the space it uses, so the panel
## is the cheap choice that suffers with dust, and the RTG/Kilopower is the expensive one that never stops.
const SOLAR_ENERGY := [3.0, 7.0, 12.0]
# How many grid cells each level takes up (the design/03 models grow sideways: level 3 = 3 cells)
const FOOTPRINT := {"habitat": [1, 2, 3], "greenhouse": [1, 2, 3], "solar": [1, 2, 3]}
const GREENHOUSE_LEVEL_SPEED := 0.5 # bigger greenhouse: +50% speed per level above 1
# Plants: proportional real time (1 sol ≈ 1 day). "unlock" = harvests needed to unlock the seed.
const PLANTS := {
	"lettuce": {"name": "P_LETTUCE", "sols": 33, "card": 1, "model": "alface", "unlock": 0},
	"radish": {"name": "P_RADISH", "sols": 27, "card": 2, "model": "rabanete", "unlock": 0},
	"kale": {"name": "P_KALE", "sols": 28, "card": 3, "model": "couve", "unlock": 1},
	# Potato: grows in about 3 months on Earth (here, 90 sols). Grown in Mars simulators (CHECK source in cartas.csv).
	"potato": {"name": "P_POTATO", "sols": 90, "card": 4, "model": "batata", "unlock": 2},
	"zinnia": {"name": "P_ZINNIA", "sols": 60, "card": 5, "model": "zinia", "unlock": 3},
	"chile": {"name": "P_CHILE", "sols": 120, "card": 6, "model": "pimenta", "unlock": 5},
}
# Cards that arrive over time
const SOL_CARDS := {3: 19, 12: 20, 30: 37}   # 1st day (Sun), 1st night (Gale cold), following nights (Phobos and Deimos); spaced out so they don't get in the way
const BLUE_SUNSET_CHANCE := 0.01    # per sol: "Blue sunset" card
const EARTH_SEEN_CHANCE := 0.02     # per sol, with antenna: "Earth seen from Mars" card
const CARD_BLUE_SUNSET := 38
const CARD_EARTH_SEEN := 39
# Solar storm (real DONKI data in res://data/donki.json)
const FIRST_STORM_SOL := 45         # the 1st one arrives after the tutorial, so the child (and the judge) sees it soon
const STORM_EVERY := Vector2i(70, 100)
const STORM_SOLS := 5               # how long it lasts
const STORM_SHIELD_COST := 30.0     # raising the shield uses energy
const STORM_RADIATION := 30.0       # without shield, radiation eats the shield bar
const STORM_PLANT_LOSS := 0.5        # without shield, growing plants lose half of what they grew
const STORM_WARN_SOLS := 5           # with the antenna, NASA warns about the storm 5 sols ahead
const STORM_SHIELD_COST_WARNED := 20.0  # when warned, the shield is cheaper (there was time to prepare)
const AURORA_CHANCE := 0.10         # survived with shield: chance of the legendary "Aurora on Mars"
const CARD_STORM := 23              # "Solar storm of 2024" card (1st storm)
const CARD_AURORA := 25
# Other events (drawn at random; every event has a bad side and a good side)
const EVENT_FIRST_SOL := 90
const EVENT_EVERY := Vector2i(60, 90)
const DUST_SOLS := 15               # dirty panels
const DUST_FACTOR := 0.3            # a dirty panel produces 30%
const COLD_SOLS := 5
const COLD_HEAT_COST := 20.0        # heating the greenhouse uses energy
const COLD_GROWTH := 0.2            # without heating, the plant almost stops
const FROST_CHANCE := 0.35          # in the morning: "Frost on Mars" card
const NOSIGNAL_SOLS := 10           # no signal: the autopilot follows the plan
const CARD_DUST := 21
const CARD_DEVIL := 22
const CARD_FROST := 24
const PACKAGE_CARDS := [4, 40]      # the package from Earth brings potato and then tomato
# Expedition: Mike leaves the base and comes back with a sample tube
const EXPLORE_SOLS := 4             # stays out 4 sols (~10 s)
const EXPLORE_OXYGEN := 30.0        # the suit uses oxygen (a lot: no going out all the time)
const EXPLORE_EMPTY_CHANCE := 0.25  # sometimes Mike comes back with nothing (never twice in a row, never in the tutorial)
const EXPLORE_MIN_SHIELD := 25.0     # with low shield, there is too much radiation outside
const EXPLORE_RADIATION := 5.0      # outside, radiation eats a bit of the shield
const TUBE_ODDS := {"common": 60, "rare": 27, "epic": 10, "legendary": 3}   # in %
## Every expedition takes a snack from the greenhouse. The rarer the snack (the rarity of the plant's card),
## the higher the chance of a rare card in the tube.
const SNACK_ODDS := {
	"common": {"common": 55, "rare": 30, "epic": 11, "legendary": 4},
	"rare": {"common": 38, "rare": 37, "epic": 19, "legendary": 6},
	"epic": {"common": 22, "rare": 40, "epic": 28, "legendary": 10},
	"legendary": {"common": 10, "rare": 35, "epic": 35, "legendary": 20},
}
const RARITY_ORDER := ["common", "rare", "epic", "legendary"]
# Growing while the game is closed
const OFFLINE_MIN_SECONDS := 30
const OFFLINE_MAX_SOLS := 2000      # ~1h20 of game time; after that it stops counting
# ─────────────────────────────────────────────────────────────────────────────

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

var free_bars := false   # only in rule tests: bars without a cap (the cap has its own test)
var started := false             # time only runs after "Play"
var energy := 0.0
var oxygen := 0.0
var shield := 0.0
var sol := 1
var items := {}     # "x,y" -> {"type", "level", "plant", "growth", "spent"}
var cards := {}     # "id" -> quantas vezes ganhou
var harvests := 0
var inventory := {}  # plant -> how many the child has harvested
var locale := ""
var paused := false              # the game pauses when the child needs to choose
var pending_event := ""          # event waiting for the child's choice or "OK"
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
var devil_cleaned := false   # the last dust devil cleaned dirty panels (picks the message)
var explore_left := 0            # sols left until Mike returns
var storm_warned := false   # the antenna already warned about the next storm
var last_empty := false   # the last expedition came back with nothing
var seen_cards := {}   # cards the child has already seen in the album (the others get the "NEW" badge)
var next_break_sol := 140       # when something will break again

## Album pages, by the "categoria" column of cartas.csv (Robots go together with Technology).
const ALBUM_PAGES := [
	["plants", "ALBUM_PLANTS", ["plants"]],
	["tech", "ALBUM_TECH", ["tech", "robots"]],
	["minerals", "ALBUM_MINERALS", ["minerals"]],
	["discoveries", "ALBUM_DISCOVERIES", ["discoveries"]],
	["sky", "ALBUM_SKY", ["sky"]],
]
var snack := ""                 # the snack (one harvest) Mike took on the current expedition
var music_on := true
var sounds_on := true
var tutorial := 0               # step of the first-minute tutorial (TUTORIAL_DONE = finished)
const TUTORIAL_DONE := 99
var tube_card := 0               # card inside the tube that has not been opened yet (0 = none)
var away := {}                   # what happened while the game was closed: {"sols", "plants"}

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
		clamp_bars()   # old saves: the bars went above the house cap
	else:
		new_game()
	if locale == "":
		locale = _device_locale()
	TranslationServer.set_locale(locale)
	_catch_up(saved_at)
	# Shortcut for testing and recording the video: opening the link with ?tempestade brings the storm in 2 sols.
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.search", true)).contains("tempestade"):
		next_storm_sol = sol + 2
	# Shortcut for testing and recording the video: ?tubo brings a sample tube waiting to be opened.
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.search", true)).contains("tubo") and tube_card == 0:
		tube_card = _draw_tube()
	# Test shortcut: ?shelf sets Mike's House to level 2, with the shelf and a few cards.
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.search", true)).contains("shelf") and count_items("shelf") == 0:
		_test_shelf()


## Testing only (?shelf shortcut): house at level 2, shelf built and a few cards in the album.
func _test_shelf() -> void:
	tutorial = TUTORIAL_DONE
	for k in items:
		if items[k].type == "habitat":
			items[k].level = maxi(int(items[k].level), 2)
	for id in [1, 2, 9, 26, 35]:
		if not cards.has(str(id)):
			add_card(id)
	var area: Rect2i = ZONES[2]
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			if count_items("shelf") == 0 and can_place("shelf", 1, Vector2i(x, y)):
				items[key(Vector2i(x, y))] = _new_item("shelf")
	clamp_bars()
	save_game()


func card_info(id: int) -> Dictionary:
	return _cards_info.get(id, {})


func cards_total() -> int:
	return _cards_info.size()


## The cards of an album page (in order).
func page_cards(page: int) -> Array:
	var cats: Array = ALBUM_PAGES[page][2]
	var out := []
	for id in card_ids():
		if str(card_info(id).get("category", "")) in cats:
			out.append(id)
	return out


func page_owned(page: int) -> int:
	var n := 0
	for id in page_cards(page):
		if cards.has(str(id)):
			n += 1
	return n


## How many cards the child has won and not yet seen in the album.
func unseen_count() -> int:
	var n := 0
	for k in cards:
		if not seen_cards.has(k):
			n += 1
	return n


## The next decoration the album unlocks: {"name": name key, "left": how many cards are missing}.
func next_album_reward() -> Dictionary:
	var best := {}
	for t in ITEMS:
		var need := int(ITEMS[t].get("decor", 0))
		if need > cards.size() and (best.is_empty() or need < int(best.need)):
			best = {"name": ITEMS[t].name, "need": need, "left": need - cards.size()}
	return best


## The album card numbers, in order.
func card_ids() -> Array:
	var ids := _cards_info.keys()
	ids.sort()
	return ids


func donki_count() -> int:
	return _donki.size()


## The item's .glb file in the game (comes from the Design itens.csv), or "" if there is none yet.
## With a level, looks for that level's version (e.g. casa-do-mike-n2.glb).
func model_file(model_name: String, level := 1) -> String:
	if model_name == "rtg" and level >= MAX_LEVEL and _models.get("files", {}).has("kilopower"):
		return _models.files.kilopower   # the level 3 RTG becomes the Kilopower (design/03 model)
	var file: String = _models.get("files", {}).get(model_name, "")
	if level > 1 and file.contains("-n1."):
		var leveled := file.replace("-n1.", "-n%d." % level)
		if ResourceLoader.exists("res://models/items/" + leveled):
			return leveled
	return file


## Item height in the game, from the Design tamanhos.csv (measured with Mike = 2.2). 0 = none.
func model_height(game_key: String) -> float:
	return float(_models.get("heights", {}).get(game_key, 0.0))


## How to win the card (text for the child, in the album).
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
	return tr("HOW_TUBE")


## In the tutorial, time stands still while Mike waits for the child (no rush, no bars dropping).
## It only moves when Mike goes out to explore, so he can come back with the tube.
## Restart the tutorial (settings): closes any notice that is waiting and postpones storm and events.
func restart_tutorial() -> void:
	tutorial = 0
	if paused and pending_event != "":
		paused = false
		pending_event = ""
	# Whatever was happening (no signal, cold night) ends: the tutorial needs a free base.
	nosignal_left = 0
	cold_left = 0
	next_storm_sol = maxi(next_storm_sol, sol + 30)
	next_event_sol = maxi(next_event_sol, sol + 40)
	_after_action()


## End of the tutorial: the first storm comes calmly, a little while later.
func finish_tutorial() -> void:
	tutorial = TUTORIAL_DONE
	next_storm_sol = maxi(next_storm_sol, sol + 30)
	next_event_sol = maxi(next_event_sol, sol + 45)
	_after_action()


func tutorial_holds_time() -> bool:
	return tutorial < TUTORIAL_DONE and not exploring() and not tutorial_needs_energy()


## In the tutorial, Mike asked to build something that cannot be paid for yet: time runs until the energy arrives.
func tutorial_needs_energy() -> bool:
	if tutorial == 0:
		return energy < float(ITEMS.solar.cost) and count_items("solar") == 0
	if tutorial == 1:
		return energy < float(ITEMS.greenhouse.cost) and count_items("greenhouse") == 0
	return false


func start() -> void:
	started = true


func _process(delta: float) -> void:
	if paused or not started or tutorial_holds_time():
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
	tutorial = 0
	snack = ""
	seen_cards = {}
	next_break_sol = sol + BREAK_EVERY.x + 30
	inventory = START_INVENTORY.duplicate()
	for k in START_ITEMS:
		items[k] = _new_item(START_ITEMS[k])
	changed.emit()


# ───────────── Grid ─────────────
static func key(c: Vector2i) -> String:
	return "%d,%d" % [c.x, c.y]


static func parse_key(k: String) -> Vector2i:
	var p := k.split(",")
	return Vector2i(int(p[0]), int(p[1]))


static func in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < GRID_W and c.y < GRID_H


## Mike's House level: it opens new area in the base and is the maximum level of the other buildings.
func house_level() -> int:
	var lv := 1
	for k in items:
		if items[k].type == "habitat":
			lv = maxi(lv, int(items[k].level))
	return lv


## The cap of each bar right now: grows with Mike's House (20/40/40, then 60 and 100).
func bar_cap(bar: String) -> float:
	if free_bars:
		return BAR_MAX
	return float(BAR_CAPS[clampi(house_level(), 1, MAX_LEVEL)][bar])


## "Low" is below 1/5 of the cap (with energy up to 20, low is below 4).
func low_line(bar: String) -> float:
	return bar_cap(bar) * LOW_PART


## No bar goes above its cap.
func clamp_bars() -> void:
	energy = clampf(energy, 0.0, bar_cap("energy"))
	oxygen = clampf(oxygen, 0.0, bar_cap("oxygen"))
	shield = clampf(shield, 0.0, bar_cap("shield"))


## The area open for building with the house at level "level" (0 = the current level).
func zone(level := 0) -> Rect2i:
	return ZONES[clampi(level if level > 0 else house_level(), 1, MAX_LEVEL)]


func cell_open(c: Vector2i, level := 0) -> bool:
	return zone(level).has_point(c)


## How many cells the item takes up (to the right of the anchor cell), by level.
static func width_of(type: String, level: int) -> int:
	var sizes: Array = FOOTPRINT.get(type, [1])
	return int(sizes[clampi(level - 1, 0, sizes.size() - 1)])


## The cells the item takes up. Turned sideways (rot 1 or 3), the row goes forward instead of sideways.
static func cells_of(anchor: Vector2i, type: String, level: int, rot := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var step := Vector2i(1, 0) if rot % 2 == 0 else Vector2i(0, 1)
	for i in width_of(type, level):
		out.append(anchor + step * i)
	return out


static func item_cells(anchor_key: String, it: Dictionary) -> Array[Vector2i]:
	return cells_of(parse_key(anchor_key), it.type, int(it.level), int(it.get("rot", 0)))


## Map of "occupied cell" -> "anchor cell of the item on it".
func _occupancy() -> Dictionary:
	var occ := {}
	for k in items:
		for c in item_cells(k, items[k]):
			occ[key(c)] = k
	return occ


## The anchor cell of the item that occupies cell c (or (-1, -1) if it is free).
func anchor_of(c: Vector2i) -> Vector2i:
	var occ := _occupancy()
	return parse_key(occ[key(c)]) if occ.has(key(c)) else Vector2i(-1, -1)


func item_at(c: Vector2i) -> Dictionary:
	var occ := _occupancy()
	return items.get(occ.get(key(c), ""), {})


## Can this item (at this level) be placed with its anchor at c? (ignore = the item itself, when moving or upgrading)
func can_place(type: String, level: int, c: Vector2i, ignore := "", rot := 0) -> bool:
	var occ := _occupancy()
	# The house itself uses the area of its own level (when it grows, it already opens the new area).
	var area := zone(level if type == "habitat" else 0)
	for cell in cells_of(c, type, level, rot):
		if not area.has_point(cell) or (occ.has(key(cell)) and occ[key(cell)] != ignore):
			return false
	return true


func count_items(type: String) -> int:
	var n := 0
	for k in items:
		if items[k].type == type:
			n += 1
	return n


## Item name on screen (the level 3 RTG becomes Kilopower).
func item_name(it: Dictionary) -> String:
	if it.get("type") == "rtg" and int(it.get("level", 1)) >= MAX_LEVEL:
		return "B_KILOPOWER"
	return ITEMS[it.type].name


func free_cells() -> Array[Vector2i]:
	var occ := _occupancy()
	var area := zone()
	var out: Array[Vector2i] = []
	for x in range(area.position.x, area.end.x):
		for y in range(area.position.y, area.end.y):
			if not occ.has(key(Vector2i(x, y))):
				out.append(Vector2i(x, y))
	return out


## Where the item at anchor "from" fits if it is moved.
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


## Turn 90°. Anything taking more than one cell only turns if the new row fits.
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


# ───────────── Actions (each one saves and notifies the screen) ─────────────
func can_afford(cost: float) -> bool:
	return energy >= cost


## Why the base cannot be changed right now ("" = it can). Returns the text key.
func base_locked_reason() -> String:
	if nosignal_left > 0:
		return "LOCK_NOSIGNAL"
	if exploring():
		return "LOCK_EXPLORING"   # building, moving and upgrading only with Mike at home
	return ""


func is_unlocked(type: String) -> bool:
	return cards.size() >= int(ITEMS[type].get("decor", 0))


func build_block_reason(type: String) -> String:
	var def: Dictionary = ITEMS[type]
	if base_locked_reason() != "":
		return base_locked_reason()
	if not is_unlocked(type):
		return "LOCKED_DECOR"
	if house_level() < int(def.get("house", 1)):
		return "NEED_HOUSE_%d" % int(def.house)
	if def.has("max") and count_items(type) >= int(def.max):
		return "NEED_MAX"
	if float(def.cost) > bar_cap("energy"):
		return "NEED_BIGGER_BAR"
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
	if it.is_empty() or it.type == "shelf":
		return -1   # the shelf has no level: Mike's House is what unlocks the slots
	var lv := int(it.level)
	if lv >= MAX_LEVEL:
		return -1
	if it.type == "habitat":
		return int(HOUSE_UPGRADE_COST.get(lv, -1))
	var base := float(ITEMS[it.type].cost)
	if base <= 0.0:
		base = UPGRADE_BASE_FREE
	return mini(roundi(base * float(UPGRADE_MULT.get(lv, 8.0))), UPGRADE_MAX)


## Why it cannot be upgraded ("" = it can): not enough energy or no room beside it for the bigger level.
func upgrade_block_reason(c: Vector2i) -> String:
	var it: Dictionary = items.get(key(c), {})
	var cost := upgrade_cost(c)
	if it.is_empty() or cost < 0:
		return "MAX_LEVEL"
	if base_locked_reason() != "":
		return base_locked_reason()
	# No building goes above Mike's House level.
	if it.type != "habitat" and int(it.level) >= house_level():
		return "NEED_HOUSE"
	if not can_place(it.type, int(it.level) + 1, c, key(c), int(it.get("rot", 0))):
		return "NEED_SPACE"
	if float(cost) > bar_cap("energy"):
		return "NEED_BIGGER_BAR"
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
	if items[key(c)].type == "habitat":
		energy = maxf(energy, bar_cap("energy"))
		oxygen = maxf(oxygen, bar_cap("oxygen"))
		shield = maxf(shield, bar_cap("shield"))
		event_message.emit("MAP_GROW", "")
	_after_action()
	return true


## Removing refunds everything that was spent: no penalty.
func remove(c: Vector2i) -> bool:
	var it := item_at(c)
	if base_locked_reason() != "" or it.is_empty() or not ITEMS[it.type].get("removable", true):
		return false
	energy = minf(bar_cap("energy"), energy + float(it.spent))
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
	if not cards.has(str(PLANTS[p].card)):
		add_card(PLANTS[p].card)
	if unlocked_plants().size() > before:
		var new_plant: String = unlocked_plants()[-1]
		event_message.emit("SEED_NEW", tr(PLANTS[new_plant].name))
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


# ───────────── Expedition and sample tube ─────────────
func exploring() -> bool:
	return explore_left > 0


## Why Mike cannot go out right now ("" = he can). Returns the text key for the screen.
func explore_block_reason() -> String:
	if base_locked_reason() != "":
		return base_locked_reason()
	if oxygen < EXPLORE_OXYGEN:
		return "LOCK_OXYGEN"
	if shield < EXPLORE_MIN_SHIELD:
		return "LOCK_SHIELD"
	if mike_inside():
		return "LOCK_STORM"
	if best_snack() == "":
		return "NEED_FOOD"
	return ""


## Rarity of a plant as a snack: the rarity of its card in cartas.csv.
func plant_rarity(p: String) -> String:
	return str(card_info(int(PLANTS[p].card)).get("rarity", "common"))


## The snack Mike takes: the rarest one he has harvested.
func best_snack() -> String:
	var best := ""
	for p in inventory:
		if int(inventory[p]) <= 0 or not PLANTS.has(p):
			continue
		if best == "" or RARITY_ORDER.find(plant_rarity(p)) > RARITY_ORDER.find(plant_rarity(best)):
			best = p
	return best


func start_explore() -> bool:
	if paused or exploring() or tube_card != 0 or explore_block_reason() != "":
		return false
	oxygen -= EXPLORE_OXYGEN
	shield = maxf(0.0, shield - EXPLORE_RADIATION)
	explore_left = EXPLORE_SOLS
	# The snack goes in the backpack (the rarest): the rarer it is, the higher the chance of a rare card.
	snack = best_snack()
	if snack != "":
		inventory[snack] = int(inventory[snack]) - 1
		event_message.emit("SNACK_PACKED", tr(PLANTS[snack].name))
	explore_started.emit()
	_after_action()
	return true


## Opens the tube Mike brought: the card goes to the album (and shows on screen).
func open_tube() -> int:
	var id := tube_card
	if id == 0:
		return 0
	tube_card = 0
	add_card(id)
	_after_action()
	return id


func tube_rarity() -> String:
	return card_info(tube_card).get("rarity", "common")


## Draws the rarity using TUBE_ODDS, then a card of that rarity that can be found at Gale.
func _draw_tube() -> int:
	var pool := {}
	for id in _cards_info:
		var c: Dictionary = _cards_info[id]
		if c.place != "Gale" or not (c.how in ["tube", "explore"]):
			continue
		if not pool.has(c.rarity):
			pool[c.rarity] = []
		pool[c.rarity].append(id)
	if pool.is_empty():
		return 0
	var roll := randi_range(1, 100)
	var rarity := "common"
	var odds: Dictionary = SNACK_ODDS.get(plant_rarity(snack), TUBE_ODDS) if snack != "" else TUBE_ODDS
	snack = ""
	for r in odds:
		roll -= odds[r]
		if roll <= 0:
			rarity = r
			break
	if not pool.has(rarity):
		rarity = pool.keys()[0]
	return pool[rarity].pick_random()


# ───────────── Solar storm ─────────────
func storm_active() -> bool:
	return storm_left > 0


## Without shield, Mike stays home until the storm passes (he does not go out to explore).
func mike_inside() -> bool:
	return (storm_left > 0 and not storm_shielded) or oxygen <= 0.0


## How much it costs to raise the shield: with the antenna (NASA warning), it is cheaper.
func storm_shield_cost() -> float:
	return event_cost(STORM_SHIELD_COST_WARNED if count_items("antenna") > 0 else STORM_SHIELD_COST)


## Heating the greenhouse in the cold.
func cold_cost() -> float:
	return event_cost(COLD_HEAT_COST)


## Events fit the small bar at the start: with energy up to 20, they cost half.
func event_cost(base: float) -> float:
	return roundf(base * clampf(bar_cap("energy") / 40.0, 0.5, 1.0))


func choose_storm(raise_shield: bool) -> bool:
	if not paused or pending_event != "storm" or (raise_shield and not can_afford(storm_shield_cost())):
		return false
	storm_shielded = raise_shield
	if raise_shield:
		energy -= storm_shield_cost()
	else:
		# Without shield: radiation eats the shield and hurts the plants that are growing.
		shield = maxf(0.0, shield - STORM_RADIATION)
		var hurt := false
		for k in items:
			if items[k].type == "greenhouse" and str(items[k].get("plant", "")) != "" and float(items[k].get("growth", 0.0)) > 0.0:
				items[k].growth = float(items[k].growth) * STORM_PLANT_LOSS
				hurt = true
		if hurt:
			event_message.emit("STORM_PLANTS", "")
		if tutorial >= TUTORIAL_DONE and randf() < BREAK_AFTER_STORM:
			break_something()
	storm_left = STORM_SOLS
	_resume()
	return true


func _start_storm() -> void:
	storm_warned = false
	if _donki.is_empty():
		next_storm_sol = sol + STORM_EVERY.x
		return
	# The 1st storm is always the one from 2024-05-20, which Curiosity measured here at Gale.
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


# ───────────── Other events ─────────────
## Events that hold back another event (dust does not: the dust devil can come and clean).
func event_active() -> bool:
	return cold_left > 0 or nosignal_left > 0


func _start_event() -> void:
	next_event_sol = sol + randi_range(EVENT_EVERY.x, EVENT_EVERY.y)
	# Dust storm and dust devil happen with or without solar panels (it is Mars weather);
	# only the effect on the panels needs a panel, and the message changes (see hud.gd, _show_event).
	var options := ["dust", "devil", "cold", "nosignal"]
	# The freezing night only comes when a plant is growing in the greenhouse (otherwise the question makes no sense).
	if not _has_growing_plant():
		options.erase("cold")
	var has_panel := count_items("solar") > 0
	if dust_left > 0:
		if has_panel:
			options = ["devil"]  # dirty panel? the next event is the dust devil that cleans it
		else:
			dust_left = 0        # the panels were removed: there is nothing left to clean
	var type: String = options.pick_random()
	if type == "dust":
		_reward_once(CARD_DUST)
		if has_panel:
			dust_left = DUST_SOLS
			# The dust devil that cleans the panels comes while they are still dirty (before, there was never time).
			next_event_sol = sol + randi_range(5, DUST_SOLS - 4)
	elif type == "devil":
		devil_cleaned = dust_left > 0
		dust_left = 0
		_reward_once(CARD_DEVIL)
	_pause_for(type)
	event_started.emit(type)


func _has_growing_plant() -> bool:
	for k in items:
		if items[k].type == "greenhouse" and str(items[k].get("plant", "")) != "":
			return true
	return false


## The child tapped "OK" on a notice (dust, dust devil).
func ack_event() -> void:
	if pending_event in ["dust", "devil"]:
		_resume()


func choose_cold(heat: bool) -> bool:
	if pending_event != "cold" or (heat and not can_afford(cold_cost())):
		return false
	cold_heated = heat
	if heat:
		energy -= cold_cost()
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
	# The package opens by itself: its card shows up on the screen right away (no need to look for it).
	var brought := ""
	for id in PACKAGE_CARDS:
		if not cards.has(str(id)):
			brought = tr("CARD_%d_NAME" % id)
			add_card(id)
			break
	event_message.emit("EV_NOSIGNAL_BACK" if brought != "" else "EV_SIGNAL_BACK", brought)


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


# ───────────── Time passes: 1 sol ─────────────
func _tick() -> void:
	# During the tutorial, no storm or event: the child learns in peace.
	if tutorial < TUTORIAL_DONE:
		next_storm_sol = maxi(next_storm_sol, sol + 12)
		next_event_sol = maxi(next_event_sol, sol + 12)
	var d_energy := 0.0
	var d_oxygen := 0.0
	var greenhouse_off := nosignal_left > 0 and nosignal_plan == "save"
	var low_e := low_line("energy")
	for k in items:
		var it: Dictionary = items[k]
		var def: Dictionary = ITEMS[it.type]
		if it.get("broken", false):
			continue   # broken: makes no energy or oxygen, and the plant stops growing
		var bonus := 1.0 + LEVEL_BONUS * (int(it.level) - 1)
		var e: float = def.get("energy", 0.0)
		if it.type == "solar":
			e = SOLAR_ENERGY[clampi(int(it.level), 1, MAX_LEVEL) - 1]
			bonus = 1.0
		if it.type == "solar" and dust_left > 0:
			e *= DUST_FACTOR
		if it.type == "rtg" and int(it.level) >= MAX_LEVEL:
			e = KILOPOWER_ENERGY
			bonus = 1.0
		if def.has("shield") and energy > low_e:
			shield = minf(bar_cap("shield"), shield + def.shield * (int(it.level) - 1))
		if it.type == "greenhouse":
			e = def.energy_when_planted if it.plant != "" and not greenhouse_off else 0.0
		d_energy += e * bonus if e > 0.0 else e
		# MOXIE needs energy to make oxygen, like the real one.
		if def.has("oxygen") and energy > 0.0:
			d_oxygen += def.oxygen * bonus
		if it.type == "greenhouse" and it.plant != "" and not greenhouse_off and energy > 0.0:
			var speed := 1.0 if energy >= low_e else SLOW_GROWTH
			if cold_left > 0 and not cold_heated:
				speed = COLD_GROWTH
			it.growth += speed * (1.0 + GREENHOUSE_LEVEL_SPEED * (int(it.level) - 1))
			# A growing plant makes oxygen (photosynthesis), like on the Space Station.
			d_oxygen += PLANT_OXYGEN
	# Mike breathes. And the house has an emergency battery: with little energy, it helps slowly
	# (so the child never gets stuck unable to build anything).
	d_oxygen -= OXYGEN_BREATH
	if energy < low_e:
		d_energy += EMERGENCY_ENERGY
	var had_energy := energy > 0.0
	var had_oxygen := oxygen > 0.0
	energy = clampf(energy + d_energy, 0.0, bar_cap("energy"))
	oxygen = clampf(oxygen + d_oxygen, 0.0, bar_cap("oxygen"))
	if not _offline:
		if had_energy and energy <= 0.0:
			event_message.emit("OUT_ENERGY", "")
		if had_oxygen and oxygen <= 0.0:
			event_message.emit("OUT_OXYGEN", "")
	# Mars radiation eats the shield every sol; recharging it costs energy (only when it is not full).
	shield = maxf(0.0, shield - SHIELD_RADIATION)
	if energy > low_e and shield < bar_cap("shield"):
		shield = minf(bar_cap("shield"), shield + SHIELD_RECHARGE)
		energy = maxf(0.0, energy - SHIELD_ENERGY_COST)
	sol += 1
	if explore_left > 0:
		explore_left -= 1
		if explore_left == 0:
			if tutorial >= TUTORIAL_DONE and not last_empty and randf() < EXPLORE_EMPTY_CHANCE:
				# Came back with nothing: the snack goes back in the backpack (the child does not lose twice).
				last_empty = true
				tube_card = 0
				if snack != "":
					inventory[snack] = int(inventory.get(snack, 0)) + 1
				snack = ""
				if not _offline:
					event_message.emit("EXPLORE_EMPTY", "")
			else:
				last_empty = false
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
	if not _offline and tutorial >= TUTORIAL_DONE and sol >= next_break_sol:
		next_break_sol = sol + randi_range(BREAK_EVERY.x, BREAK_EVERY.y)
		break_something()
	if not _offline:
		_time_cards()
		if storm_left > 0:
			storm_left -= 1
			if storm_left == 0:
				_end_storm()
		elif tutorial < TUTORIAL_DONE:
			pass   # during the tutorial, no storm or event
		elif count_items("antenna") > 0 and not storm_warned and next_storm_sol - sol <= STORM_WARN_SOLS and next_storm_sol > sol:
			storm_warned = true   # the antenna received the NASA warning
			event_message.emit("STORM_WARNING", str(next_storm_sol - sol))
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


## The short text of each building: Thais's (INFO_*, from the info panel), otherwise the short sentence.
func item_text(name_key: String) -> String:
	var info := "INFO_" + name_key.trim_prefix("B_").trim_prefix("D_")
	if tr(info) != info:
		return tr(info)
	var desc := name_key + "_DESC"
	return tr(desc) if tr(desc) != desc else ""


## Breaks a working building (never the house or a decoration). Returns the anchor cell or "".
func break_something() -> String:
	var options := []
	for k in items:
		if items[k].type in BREAKABLE and not items[k].get("broken", false):
			options.append(k)
	if options.is_empty():
		return ""
	var k: String = options.pick_random()
	items[k].broken = true
	event_message.emit("ITEM_BROKEN", tr(item_name(items[k])))
	changed.emit()
	return k


func repair_cost(c: Vector2i) -> int:
	var it := item_at(c)
	if it.is_empty():
		return 0
	return maxi(6, roundi(float(ITEMS[it.type].cost) * REPAIR_FACTOR))


func repair(c: Vector2i) -> bool:
	var it := item_at(c)
	if it.is_empty() or not it.get("broken", false) or not can_afford(repair_cost(c)):
		return false
	energy -= repair_cost(c)
	it.broken = false
	_after_action()
	return true


## How much each building makes per sol right now (the same math as _tick, without changing anything).
func item_rates(it: Dictionary) -> Dictionary:
	var def: Dictionary = ITEMS[it.type]
	if it.get("broken", false):
		return {"energy": 0.0, "oxygen": 0.0, "shield": 0.0}
	var lv := int(it.level)
	var bonus := 1.0 + LEVEL_BONUS * (lv - 1)
	var e: float = def.get("energy", 0.0)
	if it.type == "solar":
		e = SOLAR_ENERGY[clampi(lv, 1, MAX_LEVEL) - 1]
		bonus = 1.0
	if it.type == "solar" and dust_left > 0:
		e *= DUST_FACTOR
	if it.type == "rtg" and lv >= MAX_LEVEL:
		e = KILOPOWER_ENERGY
		bonus = 1.0
	if it.type == "greenhouse":
		e = def.energy_when_planted if str(it.get("plant", "")) != "" else 0.0
	var o: float = def.get("oxygen", 0.0) * bonus
	if it.type == "greenhouse" and str(it.get("plant", "")) != "":
		o += PLANT_OXYGEN
	return {"energy": e * bonus if e > 0.0 else e, "oxygen": o, "shield": def.get("shield", 0.0) * (lv - 1)}


## How much each bar gains (or loses) per sol, adding up the whole base and Mike breathing.
func current_rates() -> Dictionary:
	var r := {"energy": 0.0, "oxygen": -OXYGEN_BREATH, "shield": -SHIELD_RADIATION}
	for k in items:
		var ir := item_rates(items[k])
		for b in r:
			r[b] += ir[b]
	if energy < low_line("energy"):
		r.energy += EMERGENCY_ENERGY
	elif shield < bar_cap("shield"):
		r.shield += SHIELD_RECHARGE
		r.energy -= SHIELD_ENERGY_COST
	return r


## Growing while the game is closed: advances the sols that passed (without events) and keeps the summary.
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


# ───────────── Save and load ─────────────
const _SAVED := ["energy", "oxygen", "shield", "sol", "items", "cards", "harvests", "inventory", "locale", "paused",
	"pending_event", "next_storm_sol", "storms_seen", "storm_left", "storm_shielded", "storm_event",
	"next_event_sol", "dust_left", "cold_left", "cold_heated", "nosignal_left", "nosignal_plan",
	"explore_left", "tube_card", "tutorial", "music_on", "sounds_on", "snack", "last_empty", "seen_cards", "next_break_sol"]


func save_game() -> void:
	_save_timer = 0.0
	var data := {"version": SAVE_VERSION, "saved_at": int(Time.get_unix_time_from_system()), "grid": GRID_W}
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
	# Save from the old grid (6x8): everything moves to the middle of the new grid (10x10).
	if int(data.get("grid", 6)) != GRID_W:
		var moved := {}
		for k in items:
			moved[key(parse_key(k) + OLD_GRID_SHIFT)] = items[k]
		items = moved
	# Save from before the new album: the cards already owned count as seen.
	if not data.has("seen_cards"):
		for k in cards:
			seen_cards[k] = true
	# Save from before the tutorial: anyone who already built something does not need it.
	if not data.has("tutorial"):
		tutorial = TUTORIAL_DONE if items.size() > 1 else 0
	# Old save (from before the new events) with a storm waiting for the choice.
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
	clamp_bars()
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
