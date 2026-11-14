extends Node
## Teste rápido (sem tela): roda o jogo de verdade e confere as regras principais.
## Uso: godot --headless --path jogo res://test/teste_tempestade.tscn

var falhas := 0
var hud: Node


func _ready() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	hud = main.get_node("Hud")
	State.new_game()
	_tempestade()
	_expedicao()
	_construir_e_plantar()
	_eventos()
	_jogo_fechado()
	_ingenuity(main.get_node("Base"))
	print("RESULTADO: ", "TUDO OK" if falhas == 0 else "%d FALHA(S)" % falhas)
	get_tree().quit(falhas)


func _tempestade() -> void:
	State.next_storm_sol = State.sol + 1
	State._tick()
	ok(State.paused and State.pending_event == "storm", "a tempestade pausa o jogo")
	ok(State.storm_event.get("date", "") == "2024-05-20", "a 1ª é a de 20/05/2024 (Curiosity)")
	ok(hud._choice.visible, "a janela da tempestade aparece")
	var energia: float = State.energy
	hud._on_choice(0)
	ok(is_equal_approx(State.energy, energia - State.STORM_SHIELD_COST), "escolher o escudo gasta energia")
	ok(not State.paused and State.storm_left == State.STORM_SOLS, "o jogo volta e a tempestade dura 5 sóis")
	_ticks(State.STORM_SOLS)
	ok(State.cards.has(str(State.CARD_STORM)), "ganha a carta Tempestade solar de 2024")
	ok(hud._card.visible, "a carta aparece na tela")
	State.next_storm_sol = State.sol + 1
	State._tick()
	var escudo: float = State.shield
	hud._on_choice(1)
	ok(State.shield < escudo and State.mike_inside(), "sem escudo: perde escudo e o Mike fica em casa")
	ok(State.explore_block_reason() == "LOCK_STORM", "com o Mike em casa, não dá para explorar")
	_ticks(State.STORM_SOLS)


func _expedicao() -> void:
	State.oxygen = 100.0
	ok(State.start_explore(), "o Mike sai em expedição")
	ok(not State.start_explore(), "não sai duas vezes ao mesmo tempo")
	_ticks(State.EXPLORE_SOLS)
	ok(not State.exploring() and State.tube_card != 0, "volta depois de 4 sóis com um tubo")
	var info := State.card_info(State.tube_card)
	ok(info.place == "Gale" and not info.locked, "o tubo só traz carta da Gale (nunca trancada)")
	var carta := State.open_tube()
	ok(State.cards.has(str(carta)), "abrir o tubo dá a carta")


func _construir_e_plantar() -> void:
	State.energy = 100.0
	ok(State.build("solar", Vector2i(0, 0)), "constrói um painel solar")
	ok(State.cards.has("11"), "o 1º painel solar dá a carta Painel solar")
	ok(State.build_block_reason("flag") == "" or State.cards.size() < 5, "a bandeira destrava com 5 cartas")
	State.energy = 100.0
	ok(State.build("antenna", Vector2i(1, 0)), "constrói a antena")
	ok(State.build_block_reason("antenna") == "NEED_MAX", "só dá para ter uma antena")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(4, 6))
	ok(State.unlocked_plants().size() == 2, "começa com alface e rabanete")
	ok(State.plant(Vector2i(4, 6), "radish"), "planta rabanete")
	State.energy = 100.0
	_ticks(State.PLANTS.radish.sols)
	ok(State.harvest(Vector2i(4, 6)) == "radish", "colhe o rabanete")
	ok("kale" in State.unlocked_plants(), "a 1ª colheita destrava a couve")


func _eventos() -> void:
	_forcar_evento("cold")
	ok(State.pending_event == "cold" and hud._choice.visible, "noite congelante pede uma escolha")
	State.energy = 100.0
	hud._on_choice(0)
	ok(State.cold_left == State.COLD_SOLS and State.cold_heated, "aquecer a estufa gasta energia e protege as plantas")
	_ticks(State.COLD_SOLS)
	_forcar_evento("nosignal")
	hud._on_choice(0)
	ok(State.base_locked_reason() == "LOCK_NOSIGNAL" and not State.build("rtg", Vector2i(5, 7)), "sem sinal: não dá para mexer na base")
	_ticks(State.NOSIGNAL_SOLS)
	ok(State.cards.has("4"), "quando o sinal volta, o pacote traz a carta Batata")
	_forcar_evento("dust")
	ok(State.dust_left > 0 and hud._info.visible, "tempestade de poeira suja os painéis e avisa")
	hud._on_info_ok()
	_forcar_evento("devil")
	ok(State.dust_left == 0 and State.cards.has("22"), "o redemoinho limpa os painéis e dá a carta")
	hud._on_info_ok()


func _jogo_fechado() -> void:
	State.energy = 100.0
	State.build("greenhouse", Vector2i(5, 0))
	State.plant(Vector2i(5, 0), "lettuce")
	var sol_antes: int = State.sol
	State._catch_up(int(Time.get_unix_time_from_system()) - 600)
	ok(State.sol > sol_antes and int(State.away.get("sols", 0)) > 0, "com o jogo fechado, o tempo passa")
	ok(int(State.away.get("plants", 0)) >= 1, "a alface fica pronta enquanto o jogo estava fechado")


func _forcar_evento(tipo: String) -> void:
	hud._card.visible = false
	hud._card_queue.clear()
	State.next_event_sol = State.sol + 1
	State.next_storm_sol = State.sol + 999
	State.dust_left = 5 if tipo == "devil" else 0
	seed(0)
	# Força o tipo sorteado tentando de novo até sair o evento pedido.
	for i in 50:
		var antes := State.sol
		State.paused = false
		State.pending_event = ""
		State.dust_left = 5 if tipo == "devil" else State.dust_left
		State.next_event_sol = State.sol + 1
		State._tick()
		if State.pending_event == tipo:
			return
		State.paused = false
		State.pending_event = ""
		State.cold_left = 0
		State.nosignal_left = 0
		State.dust_left = 0
		hud._choice.visible = false
		hud._info.visible = false
	ok(false, "não consegui forçar o evento %s" % tipo)


func _ticks(n: int) -> void:
	for i in n:
		State._tick()


func ok(cond: bool, nome: String) -> void:
	print(("  ✅ " if cond else "  ❌ ") + nome)
	if not cond:
		falhas += 1


func _ingenuity(base: Node3D) -> void:
	State.energy = 100.0
	State.build("pad", Vector2i(3, 7))
	ok(base._pet != null, "a pista do Ingenuity faz o pet aparecer")
	if base._pet == null:
		return
	var rotor: Node3D = base._rotors[0]
	var eixo: Vector3 = (rotor.global_transform.basis * base._rotor_axes[0]).normalized()
	ok(absf(eixo.dot(Vector3.UP)) > 0.9, "as hélices do Ingenuity giram em pé (eixo para cima)")
	var tam: Vector3 = base._merged_aabb(base._pet).size
	ok(tam.x > 0.8 and tam.x < 4.0, "o Ingenuity tem tamanho visível (%.1f m)" % tam.x)
