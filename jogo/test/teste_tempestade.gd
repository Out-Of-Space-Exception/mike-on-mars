extends Node
## Teste rápido (sem tela): roda o jogo de verdade, força uma tempestade e confere cada passo.
## Uso: godot --headless --path jogo res://test/teste_tempestade.tscn

var falhas := 0


func _ready() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	State.new_game()
	State.next_storm_sol = State.sol + 1
	State._tick()
	ok(State.paused, "a tempestade pausa o jogo")
	ok(State.storm_event.get("date", "") == "2024-05-20", "a 1ª é a de 20/05/2024 (Curiosity)")
	var hud: Node = main.get_node("Hud")
	ok(hud._storm.visible, "a janela da tempestade aparece")
	var energia: float = State.energy
	ok(State.choose_storm(true), "dá para escolher o escudo")
	ok(is_equal_approx(State.energy, energia - State.STORM_SHIELD_COST), "o escudo gasta energia")
	ok(not State.paused and State.storm_left == State.STORM_SOLS, "o jogo volta e a tempestade dura 5 sóis")
	for i in State.STORM_SOLS:
		State._tick()
	ok(not State.storm_active(), "a tempestade passa")
	ok(State.cards.has(str(State.CARD_STORM)), "ganha a carta Tempestade solar de 2024")
	ok(hud._card.visible, "a carta aparece na tela")
	# Sem escudo: a radiação come a barra de escudo e o Mike fica em casa.
	State.next_storm_sol = State.sol + 1
	State._tick()
	var escudo: float = State.shield
	State.choose_storm(false)
	ok(State.shield < escudo and State.mike_inside(), "sem escudo: perde escudo e o Mike fica em casa")
	ok(State.explore_block_reason() == "LOCK_STORM", "com o Mike em casa, não dá para explorar")
	for i in State.STORM_SOLS:
		State._tick()
	hud._card.visible = false
	hud._card_queue.clear()
	# Expedição de 4 sóis e tubo de amostra.
	State.oxygen = 100.0
	ok(State.start_explore(), "o Mike sai em expedição")
	ok(is_equal_approx(State.oxygen, 100.0 - State.EXPLORE_OXYGEN), "a expedição gasta oxigênio")
	ok(not State.start_explore(), "não sai duas vezes ao mesmo tempo")
	for i in State.EXPLORE_SOLS:
		State._tick()
	ok(not State.exploring() and State.tube_card != 0, "volta depois de 4 sóis com um tubo")
	var info := State.card_info(State.tube_card)
	ok(info.place == "Gale" and not info.locked, "o tubo só traz carta da Gale (nunca trancada)")
	var carta := State.open_tube()
	ok(State.cards.has(str(carta)) and hud._card.visible, "abrir o tubo dá a carta e ela aparece")
	var contagem := {}
	for i in 400:
		var r: String = State.card_info(State._draw_tube()).rarity
		contagem[r] = contagem.get(r, 0) + 1
	print("  sorteio de 400 tubos: ", contagem)
	ok(contagem.get("comum", 0) > contagem.get("raro", 0) and contagem.get("raro", 0) > contagem.get("épico", 0), "comum sai mais que raro, e raro mais que épico")
	print("RESULTADO: ", "TUDO OK" if falhas == 0 else "%d FALHA(S)" % falhas)
	get_tree().quit(falhas)


func ok(cond: bool, nome: String) -> void:
	print(("  ✅ " if cond else "  ❌ ") + nome)
	if not cond:
		falhas += 1
