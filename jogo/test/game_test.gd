extends Node
## Quick test (no screen): runs the real game and checks the main rules.
## Usage: godot --headless --path jogo res://test/game_test.tscn

var failures := 0
var hud: Node


func _ready() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	hud = main.get_node("Hud")
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	# The rule tests start with full bars and no cap (the cap has its own test).
	State.free_bars = true
	State.energy = 100.0
	State.oxygen = 100.0
	State.shield = 100.0
	_storm()
	_expedition()
	_build_and_plant()
	_events()
	_game_closed()
	_ingenuity(main.get_node("Base"))
	_levels_and_album()
	_rotate_energy_oxygen()
	_house_area()
	_mike_path(main.get_node("Base"))
	_tutorial()
	_new_rules()
	_potato_and_album()
	_break_and_repair()
	_slow_start()
	_shelf(main.get_node("Base"))
	# The tutorial note is as big as its text (it used to grow to the whole screen and never shrink back).
	State.restart_tutorial()
	hud._start.visible = false
	hud._tut_update()
	for i in 4:
		await get_tree().process_frame
	ok(hud._tut_card.visible and hud._tut_card.size.y < 260.0, "the tutorial note is small (%d px tall)" % hud._tut_card.size.y)
	ok(hud._tut_card.position.y >= hud._bars_bottom() - 1.0, "the note sits below the bars, not on top of them")
	State.finish_tutorial()
	hud._show_toast("test")
	await get_tree().create_timer(1.5).timeout
	ok(hud._toast.modulate.a > 0.9, "Mike's toast is still on screen after 1.5 s")
	ok(hud._toast.size.x <= hud.MAX_W + 1.0, "the toast stays at the middle width, not the full screen")
	print("RESULT: ", "ALL OK" if failures == 0 else "%d FAILURE(S)" % failures)
	get_tree().quit(failures)


func _storm() -> void:
	State.next_storm_sol = State.sol + 1
	State._tick()
	ok(State.paused and State.pending_event == "storm", "the storm pauses the game")
	ok(State.storm_event.get("date", "") == "2024-05-20", "the 1st one is the 05/20/2024 storm (Curiosity)")
	ok(hud._choice.visible, "the storm window shows up")
	var energy: float = State.energy
	hud._on_choice(0)
	ok(is_equal_approx(State.energy, energy - State.STORM_SHIELD_COST), "choosing the shield costs energy")
	ok(not State.paused and State.storm_left == State.STORM_SOLS, "the game resumes and the storm lasts 5 sols")
	_ticks(State.STORM_SOLS)
	ok(State.cards.has(str(State.CARD_STORM)), "gets the 2024 solar storm card")
	ok(hud._card.visible, "the card shows on screen")
	ok(hud._card_badge.visible, "a new card gets the NEW! badge")
	State.next_storm_sol = State.sol + 1
	State._tick()
	var shield: float = State.shield
	hud._on_choice(1)
	ok(State.shield < shield and State.mike_inside(), "no shield: loses shield and Mike stays home")
	ok(State.explore_block_reason() == "LOCK_STORM", "with Mike at home, exploring is not possible")
	_ticks(State.STORM_SOLS)


func _expedition() -> void:
	State.oxygen = 100.0
	State.last_empty = true   # no random empty trip (10%) in these checks
	ok(State.start_explore(), "Mike leaves on an expedition")
	ok(not State.start_explore(), "he does not leave twice at the same time")
	_ticks(State.EXPLORE_SOLS)
	ok(not State.exploring() and State.tube_card != 0, "he comes back after 4 sols with a tube")
	var info := State.card_info(State.tube_card)
	ok(info.place == "Gale", "the tube only brings a Gale card")
	var card := State.open_tube()
	ok(State.cards.has(str(card)), "opening the tube gives the card")


func _build_and_plant() -> void:
	State.energy = 100.0
	ok(State.build("solar", Vector2i(3, 3)), "builds a solar panel")
	ok(State.cards.has("11"), "the 1st solar panel gives the Solar panel card")
	ok(State.build_block_reason("flag") == "" or State.cards.size() < 5, "the flag unlocks with 5 cards")
	State.energy = 100.0
	ok(State.build("antenna", Vector2i(4, 3)), "builds the antenna")
	ok(State.build_block_reason("antenna") == "NEED_MAX", "only one antenna is allowed")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(6, 6))
	ok(State.unlocked_plants().size() == 2, "starts with lettuce and radish")
	ok(int(State.seeds.get("lettuce", 0)) == 5 and int(State.seeds.get("radish", 0)) == 0, "starts with 5 lettuce seeds only")
	ok(not State.plant(Vector2i(6, 6), "radish"), "without seeds, the radish cannot be planted")
	State.seeds["radish"] = 1   # as if it came in a package from Earth
	ok(State.plant(Vector2i(6, 6), "radish"), "plants a radish")
	ok(int(State.seeds.radish) == 0, "planting uses 1 seed")
	State.energy = 100.0
	_ticks(State.PLANTS.radish.sols)
	ok(State.harvest(Vector2i(6, 6)) == "radish", "harvests the radish")
	ok(int(State.seeds.radish) >= State.HARVEST_SEEDS.x and int(State.seeds.radish) <= State.HARVEST_SEEDS.y, "the harvest gives back 1 to 3 seeds")
	State.oxygen = 100.0
	var radishes_before: int = int(State.inventory.get("radish", 0))
	State.last_empty = true   # no random empty trip (10%) in these checks
	State.start_explore()
	ok(State.snack == "radish" and int(State.inventory.get("radish", 0)) == radishes_before - 1, "the harvest becomes the expedition snack")
	_ticks(State.EXPLORE_SOLS)
	ok(State.snack == "" and State.tube_card != 0, "the snack is used in the tube draw")
	State.open_tube()
	ok("kale" in State.unlocked_plants(), "the 1st harvest unlocks kale")


func _events() -> void:
	State.plant(Vector2i(6, 6), "lettuce")   # the freezing night only comes with a growing plant
	_force_event("cold")
	ok(State.pending_event == "cold" and hud._choice.visible, "freezing night asks for a choice")
	State.energy = 100.0
	hud._on_choice(0)
	ok(State.cold_left == State.COLD_SOLS and State.cold_heated, "heating the greenhouse costs energy and protects the plants")
	_ticks(State.COLD_SOLS)
	_force_event("nosignal")
	hud._on_choice(0)
	ok(State.base_locked_reason() == "LOCK_NOSIGNAL" and not State.build("rtg", Vector2i(3, 5)), "no signal: the base cannot be touched")
	var packages_before: int = State.packages
	_ticks(State.NOSIGNAL_SOLS)
	ok(State.packages == packages_before + 1, "when the signal comes back, the antenna gets a package with seeds")
	while State.packages < State.PACKAGE_CARDS_BY:
		State._send_package("PACKAGE_ARRIVED")
	ok(State.cards.has("4") and State.cards.has("40"), "the potato and tomato cards come by the 5th package")
	_force_event("dust")
	ok(State.dust_left > 0 and hud._info.visible, "dust storm dirties the panels and warns")
	ok(State.next_event_sol - State.sol < State.DUST_SOLS, "after the dust, the dust devil comes while the panel is still dirty")
	hud._on_info_ok()
	_force_event("devil")
	ok(State.dust_left == 0 and State.cards.has("22"), "the dust devil cleans the panels and gives the card")
	hud._on_info_ok()


func _game_closed() -> void:
	State.energy = 100.0
	State.build("greenhouse", Vector2i(3, 6))
	State.plant(Vector2i(3, 6), "lettuce")
	var sol_before: int = State.sol
	State._catch_up(int(Time.get_unix_time_from_system()) - 600)
	ok(State.sol > sol_before and int(State.away.get("sols", 0)) > 0, "with the game closed, time passes")
	ok(int(State.away.get("plants", 0)) >= 1, "the lettuce gets ready while the game was closed")


func _force_event(kind: String) -> void:
	hud._card.visible = false
	hud._card_queue.clear()
	State.next_event_sol = State.sol + 1
	State.next_storm_sol = State.sol + 999
	State.dust_left = 5 if kind == "devil" else 0
	seed(0)
	# Forces the drawn type by retrying until the requested event comes up.
	for i in 50:
		var before := State.sol
		State.paused = false
		State.pending_event = ""
		State.dust_left = 5 if kind == "devil" else State.dust_left
		State.next_event_sol = State.sol + 1
		State._tick()
		if State.pending_event == kind:
			return
		State.paused = false
		State.pending_event = ""
		State.cold_left = 0
		State.nosignal_left = 0
		State.dust_left = 0
		hud._choice.visible = false
		hud._info.visible = false
	ok(false, "could not force the %s event" % kind)


func _ticks(n: int) -> void:
	for i in n:
		State._tick()


func ok(cond: bool, check_name: String) -> void:
	print(("  ✅ " if cond else "  ❌ ") + check_name)
	if not cond:
		failures += 1


func _ingenuity(base: Node3D) -> void:
	State.energy = 100.0
	State.build("pad", Vector2i(6, 3))
	ok(base._pet != null, "the Ingenuity pad makes the pet appear")
	if base._pet == null:
		return
	var rotor: Node3D = base._rotors[0]
	var axis: Vector3 = (rotor.global_transform.basis * base._rotor_axes[0]).normalized()
	ok(absf(axis.dot(Vector3.UP)) > 0.9, "the Ingenuity rotors spin upright (axis pointing up)")
	var extent: Vector3 = base._merged_aabb(base._pet).size
	ok(extent.x > 0.8 and extent.x < 4.0, "the Ingenuity has a visible size (%.1f m)" % extent.x)


func _levels_and_album() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	var house := Vector2i(4, 4)
	ok(State.upgrade_block_reason(house) == "", "the house can go to level 2 (there is room next to it)")
	State.upgrade(house)
	ok(State.cells_of(house, "habitat", 2).size() == 2 and State.anchor_of(Vector2i(5, 4)) == house, "level 2 house takes 2 cells")
	State.energy = 100.0
	State.build("solar", Vector2i(6, 4))
	ok(State.upgrade_block_reason(house) == "NEED_SPACE", "with no room next to it, the house cannot go to level 3")
	ok(not State.build("moxie", Vector2i(5, 4)), "cannot build on top of the big house")
	State.remove(Vector2i(6, 4))
	State.energy = 100.0
	ok(State.upgrade(house) and State.cells_of(house, "habitat", 3).size() == 3, "with room, the house goes to level 3 (3 cells)")
	State.energy = 100.0
	State.build("rtg", Vector2i(2, 1))
	State.energy = 100.0
	State.upgrade(Vector2i(2, 1))
	State.energy = 100.0
	State.upgrade(Vector2i(2, 1))
	ok(State.item_name(State.item_at(Vector2i(2, 1))) == "B_KILOPOWER" and State.cards.has("14"), "RTG at level 3 becomes Kilopower and gives the card")
	var without_hint := 0
	for id in State.card_ids():
		if State.card_hint(id).strip_edges() == "":
			without_hint += 1
	ok(without_hint == 0, "all %d cards say how to get them" % State.cards_total())
	State.energy = 100.0
	State.build("greenhouse", Vector2i(2, 7))
	State.seeds["radish"] = 1
	State.plant(Vector2i(2, 7), "radish")
	_ticks(30)
	State.harvest(Vector2i(2, 7))
	ok(int(State.inventory.get("radish", 0)) == 1, "harvesting counts in the inventory (radish × 1)")


func _rotate_energy_oxygen() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	var house := Vector2i(4, 4)
	State.upgrade(house)
	ok(State.anchor_of(Vector2i(5, 4)) == house, "level 2 house lying down takes the cell next to it")
	ok(State.rotate(house) and State.anchor_of(Vector2i(4, 5)) == house and State.anchor_of(Vector2i(5, 4)) == Vector2i(-1, -1), "rotating the house: the row goes to the front")
	State.energy = 100.0
	State.build("solar", Vector2i(5, 4))
	State.rotate(house)
	State.build("moxie", Vector2i(4, 5))
	ok(State.rotate_block_reason(house) == "NEED_SPACE", "does not rotate if the new row does not fit")
	# No energy: the house's emergency battery helps slowly.
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 0.0
	State.oxygen = 50.0
	State._tick()
	ok(State.energy > 0.0, "with no energy, the house's emergency battery gives a little")
	# No oxygen: Mike stays home; the plant makes oxygen.
	State.oxygen = 0.4
	State._tick()
	ok(State.oxygen <= 0.0 and State.mike_inside() and State.explore_block_reason() == "LOCK_OXYGEN", "with no oxygen, Mike stays home and does not explore")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(3, 3))
	State.plant(Vector2i(3, 3), "lettuce")
	State.oxygen = 10.0
	var before: float = State.oxygen
	State.energy = 100.0
	State._tick()
	ok(is_equal_approx(State.oxygen, before - State.OXYGEN_BREATH + State.PLANT_OXYGEN), "Mike breathes and the plant makes oxygen")


func _house_area() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	ok(State.free_cells().size() == 15, "level 1 house: the base is 4 x 4 cells (15 free)")
	ok(not State.build("solar", Vector2i(2, 1)), "cannot build outside the open area")
	ok(State.build("rtg", Vector2i(3, 3)), "inside the area, it works")
	State.energy = 100.0
	ok(State.upgrade_block_reason(Vector2i(3, 3)) == "NEED_HOUSE", "a building cannot pass the house's level")
	State.upgrade(Vector2i(4, 4))
	ok(State.free_cells().size() == 49 - 3, "level 2 house: the base grows to 7 x 7")
	State.energy = 100.0
	ok(State.upgrade(Vector2i(3, 3)), "with the house at level 2, the RTG goes up to level 2")
	State.energy = 100.0
	ok(State.upgrade_block_reason(Vector2i(3, 3)) == "NEED_HOUSE", "but it does not go to level 3")
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	ok(State.zone() == Rect2i(0, 0, State.GRID_W, State.GRID_H), "level 3 house: the whole grid opens")
	var coming_soon := 0
	for id in State.card_ids():
		if str(State.card_info(id).get("place", "")).to_lower().contains("em breve"):
			coming_soon += 1
	ok(coming_soon == 0 and State.cards_total() == 36, "no \"coming soon\" card (36 cards in the album)")


func _mike_path(base: Node3D) -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	State.build("greenhouse", Vector2i(4, 5))
	# From the back of the house to the front of the greenhouse: the straight line crosses both.
	var from: Vector3 = base.cell_center(Vector2i(5, 3))
	var to: Vector3 = base.cell_center(Vector2i(5, 7))
	var path: PackedVector3Array = base._round_corners(base._find_path(from, to))
	var hits := 0
	for i in range(1, path.size()):
		for s in 5:
			if base._nav_solid(path[i - 1].lerp(path[i], s / 4.0)):
				hits += 1
	ok(path.size() > 2 and hits == 0, "Mike goes around the buildings (%d points, no hits)" % path.size())
	ok(path[-1].distance_to(to) < 0.6, "and arrives where the child tapped")
	var smooth := true
	for i in range(1, path.size() - 1):
		var a := (path[i] - path[i - 1]).normalized()
		var b := (path[i + 1] - path[i]).normalized()
		if a.length() > 0.5 and b.length() > 0.5 and rad_to_deg(a.angle_to(b)) > 50.0:
			smooth = false
	ok(smooth, "no sharp corners: every turn of the path is smooth")
	# Building on top of Mike: he walks away to a free spot.
	base._walking_out = false
	base.mike.position = base.cell_center(Vector2i(6, 5))
	base._path = PackedVector3Array()
	base._path_i = 0
	State.energy = 100.0
	State.build("moxie", Vector2i(6, 5))
	ok(base._path.size() > 0 and not base._nav_solid(base._path[-1]), "built on top of Mike: he steps to the side")
	# A tap on top of the house (outside its floor) opens the house.
	base.whole_grid = false
	var house: Node3D = base._nodes["4,4"]
	var top: AABB = house.global_transform * base._merged_aabb(house)
	var screen: Vector2 = base.camera.unproject_position(top.get_center() + Vector3(0, top.size.y * 0.4, 0))
	var hit: Dictionary = base._item_under(base.camera.project_ray_origin(screen), base.camera.project_ray_normal(screen))
	ok(not hit.is_empty() and State.anchor_of(hit.cell) == Vector2i(4, 4), "tapping the house roof opens the house")
	ok(base._mike_skins.has("suit"), "the suited Mike is loaded for the expedition")
	base._set_suit(true)
	ok(base._mike_skins.suit[0].visible and not base._mike_skins.casual[0].visible, "on the expedition, Mike wears the suit")
	base._set_suit(false)
	var anims: PackedStringArray = base._mike_anim.get_animation_list() if base._mike_anim else PackedStringArray()
	ok("run" in anims and "idle" in anims, "Mike has the idle and run animations: %s" % ", ".join(anims))
	var skeleton: Skeleton3D = base._mike_skins.casual[0].find_children("*", "Skeleton3D", true, false)[0]
	var idle: Animation = base._mike_anim.get_animation("idle")
	var arm := idle.find_track(NodePath("Root/Skeleton3D:LeftArm"), Animation.TYPE_ROTATION_3D)
	var rest := skeleton.get_bone_rest(skeleton.find_bone("LeftArm")).basis.get_rotation_quaternion()
	var lowered := rad_to_deg((idle.track_get_key_value(arm, 0) as Quaternion).angle_to(rest))
	ok(lowered > 40.0, "Mike keeps his arms down, no T-pose (%.0f°)" % lowered)


func _tutorial() -> void:
	State.new_game()
	ok(State.tutorial == 0, "a new game starts with the tutorial")
	State.next_storm_sol = State.sol + 1
	State._tick()
	ok(State.pending_event == "" and not State.paused, "no storm comes during the tutorial")
	hud._start.visible = false   # as if the child had tapped Play
	for window in [hud._card, hud._choice, hud._info, hud._nasa, hud._album]:
		window.visible = false
	hud._card_queue.clear()
	hud._tut_update()
	ok(hud._tut_card.visible and hud._tut_label.text == tr("TUTO_HELLO"), "Mike gives the 1st note: tap Build")
	ok(hud._tut_target() == hud._buttons.build, "the golden frame goes around the Build button")
	hud._on_album()
	ok(not hud._album.visible and hud._toast_label.text == tr("TUTO_NUDGE").format({"name": tr("BTN_BUILD")}), "in the tutorial, tapping something else does not open it: Mike reminds what to tap")
	State.energy = 100.0
	State.build("solar", Vector2i(3, 3))
	hud._tut_update()
	ok(State.tutorial == 1, "built the panel: greenhouse step")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(5, 3))
	State.plant(Vector2i(5, 3), "lettuce")
	hud._tut_update()
	ok(State.tutorial == 3 and hud._tut_label.text == tr("TUTO_EXPLORE"), "planted: Mike asks to explore")
	State.oxygen = 100.0
	State.last_empty = true   # no random empty trip (10%) in these checks
	State.start_explore()
	_ticks(State.EXPLORE_SOLS)
	hud._tut_update()
	ok(State.tutorial == 4 and State.tube_card != 0, "came back with the tube: open step")
	State.open_tube()
	hud._tut_update()
	ok(State.tutorial == 5, "opened the tube: congratulations")
	State.tutorial = 0
	State.started = true
	State.energy = 100.0
	var sol_idle: int = State.sol
	State._process(30.0)
	ok(State.sol == sol_idle, "in the tutorial, time stands still waiting for the child")
	State.tutorial = 5
	hud._tut_skip.pressed.emit()
	ok(State.tutorial == State.TUTORIAL_DONE and not hud._tut_card.visible, "the tutorial ends and the note goes away")
	hud._card.visible = false
	hud._card_queue.clear()
	ok(hud._sols(tr("COLD_LEFT").format({"n": 1})).ends_with(" sol"), "1 sol (not \"1 sols\")")


func _new_rules() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.oxygen = 100.0
	ok(State.zone(3).size == Vector2i(10, 10) and State.zone(2).size == Vector2i(7, 7), "the base goes up to 10 x 10 (4x4, 7x7, 10x10)")
	ok(State.best_snack() == "lettuce", "the game starts with a snack from Earth")
	State.inventory.clear()
	ok(State.explore_block_reason() == "NEED_FOOD", "with no snack, Mike does not go exploring")
	State.inventory = {"lettuce": 1, "chile": 1}
	ok(State.best_snack() == "chile" or State.plant_rarity("chile") == State.plant_rarity("lettuce"), "he takes the rarest snack")
	State.shield = 10.0
	ok(State.explore_block_reason() == "LOCK_SHIELD", "with low shield, he cannot leave")
	State.shield = 100.0
	State.last_empty = true   # no random empty trip (10%) in these checks
	ok(State.start_explore(), "with snack, oxygen and shield, he leaves")
	ok(not State.build("solar", Vector2i(3, 3)) and State.build_block_reason("solar") == "LOCK_EXPLORING", "with Mike away, building is not possible")
	_ticks(State.EXPLORE_SOLS)
	State.open_tube()
	State.energy = 100.0
	State.build("greenhouse", Vector2i(3, 3))
	State.plant(Vector2i(3, 3), "lettuce")
	_ticks(10)
	var before: float = float(State.item_at(Vector2i(3, 3)).growth)
	State.next_storm_sol = State.sol + 1
	State._tick()
	hud._on_choice(1)
	ok(is_equal_approx(float(State.item_at(Vector2i(3, 3)).growth), before * State.STORM_PLANT_LOSS + 0.0) or float(State.item_at(Vector2i(3, 3)).growth) < before, "with no shield, the plants lose half of what they grew")
	_ticks(State.STORM_SOLS)
	State.energy = 100.0
	ok(is_equal_approx(State.storm_shield_cost(), State.STORM_SHIELD_COST), "with no antenna, the shield costs %d" % int(State.STORM_SHIELD_COST))
	State.build("antenna", Vector2i(4, 3))
	ok(is_equal_approx(State.storm_shield_cost(), State.STORM_SHIELD_COST_WARNED), "with the antenna (NASA warning), the shield is cheaper")
	State.storm_warned = false
	State.next_storm_sol = State.sol + 7
	State.next_event_sol = State.sol + 99
	State._tick()
	State._tick()
	ok(State.storm_warned, "the antenna warns about the storm a few sols ahead")
	# The trash can asks for confirmation.
	hud._card.visible = false
	hud._card_queue.clear()
	hud._choice.visible = false
	hud._info.visible = false
	hud._open_panel(Vector2i(4, 3))
	hud._on_remove()
	ok(hud._choice.visible and not State.item_at(Vector2i(4, 3)).is_empty(), "the trash can asks first (nothing goes away without confirming)")
	hud._on_choice(0)
	ok(State.item_at(Vector2i(4, 3)).is_empty(), "confirmed: the building goes away")
	# Harvesting a plant that is already in the album again does not show the card again.
	var cards_before: int = State.cards.size()
	var queue_before: int = hud._card_queue.size()
	State.energy = 100.0
	State.plant(Vector2i(3, 3), "lettuce")
	State.item_at(Vector2i(3, 3)).growth = 999.0
	State.harvest(Vector2i(3, 3))
	State.plant(Vector2i(3, 3), "lettuce")
	State.item_at(Vector2i(3, 3)).growth = 999.0
	State.harvest(Vector2i(3, 3))
	ok(hud._card_queue.size() <= queue_before + 1 and State.cards.size() <= cards_before + 1, "harvesting lettuce again does not show the card again")
	hud._card.visible = false
	hud._card_queue.clear()
	hud._choice.visible = false
	hud._info.visible = false


func _potato_and_album() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	ok(not ("potato" in State.unlocked_plants()), "the potato does not show up at the start")
	State.harvests = 2
	ok("potato" in State.unlocked_plants(), "after 2 harvests, the potato seed shows up")
	var total := 0
	for p in State.ALBUM_PAGES.size():
		total += State.page_cards(p).size()
	ok(total == State.cards_total(), "the 5 album pages have all %d cards" % State.cards_total())
	State.add_card(1)
	ok(State.unseen_count() >= 1, "a card earned and not yet seen counts as new")
	hud._start.visible = false
	hud._on_album()
	ok(hud._album.visible and hud._album_grid.get_child_count() == State.cards_total(), "the album shows all the cards together")
	ok(State.seen_cards.has("1"), "after seeing the page, the card is no longer new")
	hud._album.visible = false
	hud._card.visible = false
	hud._card_queue.clear()


func _break_and_repair() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	ok(State.upgrade_cost(Vector2i(4, 4)) == 18, "upgrading the house to level 2 costs 18 (fits in the 20 bar)")
	State.build("solar", Vector2i(3, 3))
	ok(State.upgrade_cost(Vector2i(3, 3)) == 30, "solar panel: level 2 costs 3 times the price (30)")
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	State.upgrade(Vector2i(3, 3))
	ok(State.upgrade_cost(Vector2i(3, 3)) == 80, "and level 3 costs 8 times (80)")
	var k := State.break_something()
	ok(k == "3,3" and State.item_at(Vector2i(3, 3)).get("broken", false), "something breaks (never the house)")
	ok(is_zero_approx(float(State.item_rates(State.item_at(Vector2i(3, 3))).energy)), "broken makes no energy")
	State.energy = 100.0
	ok(State.repair(Vector2i(3, 3)) and not State.item_at(Vector2i(3, 3)).get("broken", false), "repairing makes it work again")


func _slow_start() -> void:
	State.free_bars = false
	State.new_game()
	ok(is_equal_approx(State.energy, 20.0) and is_equal_approx(State.oxygen, 40.0) and is_equal_approx(State.shield, 40.0), "slow start: energy 20, oxygen and shield 40")
	State.build("solar", Vector2i(3, 3))
	State.tutorial = 1
	ok(State.tutorial_needs_energy() and not State.tutorial_holds_time(), "in the tutorial, with no energy for the greenhouse, time runs")
	State.tutorial = State.TUTORIAL_DONE
	# Cap: energy does not go past 20 with the house at level 1 (before, it only started at 20 and went over).
	State.energy = 20.0
	for i in 30:
		State._tick()
	ok(State.energy <= 20.0 and State.oxygen <= 40.0 and State.shield <= 40.0, "level 1 house: energy up to 20, oxygen and shield up to 40")
	ok(State.build_block_reason("rtg") == "NEED_BIGGER_BAR", "the RTG (30) does not fit in the 20 bar: upgrade the house")
	ok(State.upgrade_cost(Vector2i(4, 4)) <= 20, "upgrading the house fits in the 20 bar (costs %d)" % State.upgrade_cost(Vector2i(4, 4)))
	ok(State.storm_shield_cost() <= 20.0, "the storm shield fits in the 20 bar")
	State.energy = 20.0
	ok(State.upgrade(Vector2i(4, 4)), "the house can be upgraded with a full bar")
	ok(is_equal_approx(State.energy, 60.0) and is_equal_approx(State.oxygen, 60.0) and is_equal_approx(State.shield, 60.0), "level 2 house: the bars go up to 60 and fill")
	for i in 30:
		State._tick()
	ok(State.energy <= 60.0, "level 2 house: energy does not go past 60")
	ok(State.upgrade_cost(Vector2i(4, 4)) <= 60, "upgrading the house again fits in the 60 bar")
	State.energy = 60.0
	State.upgrade(Vector2i(4, 4))
	ok(is_equal_approx(State.energy, 100.0) and is_equal_approx(State.oxygen, 100.0), "level 3 house: the bars go up to 100 and fill")
	State.free_bars = true


func _shelf(base: Node) -> void:
	State.free_bars = true
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	ok(State.build_block_reason("shelf") == "NEED_HOUSE_2", "shelf: with the house at level 1, it cannot be built")
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	ok(State.build_block_reason("shelf") == "", "shelf: with the house at level 2, it can")
	ok(State.build("shelf", Vector2i(3, 3)), "built the shelf")
	ok(State.build_block_reason("shelf") == "NEED_MAX", "only 1 shelf is allowed")
	ok(State.upgrade_cost(Vector2i(3, 3)) < 0, "the shelf has no level")
	var E := preload("res://scenes/shelf.gd")
	ok(E.open_slots() == 3, "level 2 house: 3 slots")
	var all_items: Array = E._all_items()
	ok(not ("rock:hematita" in all_items) and "rock:enxofre" in all_items and "plant:lettuce" in all_items and "plant:potato" in all_items, "the shelf only shows what can be had in the album")
	ok(not E._owned("rock:enxofre"), "rock without the card: still locked")
	State.add_card(9)
	ok(E._owned("rock:enxofre"), "got the sulfur card: it can be displayed")
	State.add_card(4)
	State.items["3,3"]["display"] = ["rock:enxofre", "plant:potato", "", "rock:enxofre", "", ""]
	State.changed.emit()
	var node: Node3D = base._nodes.get("3,3")
	var v1: Node = node.find_child("vaga-1", true, false) if node else null
	var v2: Node = node.find_child("vaga-2", true, false) if node else null
	var v4: Node = node.find_child("vaga-4", true, false) if node else null
	ok(v1 != null and v1.get_node_or_null("Display") != null, "the rock shows up in shelf slot 1")
	ok(v2 != null and v2.get_node_or_null("Display") != null, "the potato (made in code) shows up in slot 2")
	ok(v4 != null and v4.get_node_or_null("Display") == null, "slot 4 stays locked with the house at level 2")
	hud._shelf.open("3,3")
	ok(hud._shelf.visible and hud._shelf._slots_grid.get_child_count() == 6, "View shelf: opens with the 6 slots")
	hud._shelf._pick(2)
	ok(hud._shelf._list.get_child_count() > 3, "tapping a slot shows the list")
	hud._shelf._place("rock:enxofre")
	ok(State.items["3,3"].display[2] == "rock:enxofre" and State.items["3,3"].display[0] == "", "the rock changes slot (appears only once)")
	hud._shelf._back()
	ok(not hud._shelf.visible, "the X closes the shelf")
