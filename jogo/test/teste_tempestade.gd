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
	State.tutorial = State.TUTORIAL_DONE
	# Os testes de regra começam com as barras cheias (o começo devagar tem o teste dele).
	State.energy = 100.0
	State.oxygen = 100.0
	State.shield = 100.0
	_tempestade()
	_expedicao()
	_construir_e_plantar()
	_eventos()
	_jogo_fechado()
	_ingenuity(main.get_node("Base"))
	_niveis_e_album()
	_girar_energia_oxigenio()
	_area_da_casa()
	_caminho_do_mike(main.get_node("Base"))
	_tutorial()
	_regras_novas()
	_batata_e_album()
	_quebrar_e_consertar()
	_comeco_devagar()
	# O recado do tutorial tem o tamanho do texto (antes crescia até a tela inteira e não voltava).
	State.restart_tutorial()
	hud._start.visible = false
	hud._tut_update()
	for i in 4:
		await get_tree().process_frame
	ok(hud._tut_card.visible and hud._tut_card.size.y < 260.0, "o recado do tutorial é pequeno (%d px de altura)" % hud._tut_card.size.y)
	ok(hud._tut_card.position.y >= hud._bars_bottom() - 1.0, "o recado fica abaixo das barras, não por cima")
	State.finish_tutorial()
	hud._show_toast("teste")
	await get_tree().create_timer(1.5).timeout
	ok(hud._toast.modulate.a > 0.9, "o aviso do Mike continua na tela depois de 1,5 s")
	ok(hud._toast.size.x <= hud.MAX_W + 1.0, "o aviso fica na largura do meio, não na tela inteira")
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
	ok(hud._card_badge.visible, "carta nova ganha o selo NOVA!")
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
	ok(info.place == "Gale", "o tubo só traz carta da Gale")
	var carta := State.open_tube()
	ok(State.cards.has(str(carta)), "abrir o tubo dá a carta")


func _construir_e_plantar() -> void:
	State.energy = 100.0
	ok(State.build("solar", Vector2i(3, 3)), "constrói um painel solar")
	ok(State.cards.has("11"), "o 1º painel solar dá a carta Painel solar")
	ok(State.build_block_reason("flag") == "" or State.cards.size() < 5, "a bandeira destrava com 5 cartas")
	State.energy = 100.0
	ok(State.build("antenna", Vector2i(4, 3)), "constrói a antena")
	ok(State.build_block_reason("antenna") == "NEED_MAX", "só dá para ter uma antena")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(6, 6))
	ok(State.unlocked_plants().size() == 2, "começa com alface e rabanete")
	ok(State.plant(Vector2i(6, 6), "radish"), "planta rabanete")
	State.energy = 100.0
	_ticks(State.PLANTS.radish.sols)
	ok(State.harvest(Vector2i(6, 6)) == "radish", "colhe o rabanete")
	State.oxygen = 100.0
	var raros_antes: int = int(State.inventory.get("radish", 0))
	State.start_explore()
	ok(State.snack == "radish" and int(State.inventory.get("radish", 0)) == raros_antes - 1, "a colheita vira lanche da expedição")
	_ticks(State.EXPLORE_SOLS)
	ok(State.snack == "" and State.tube_card != 0, "o lanche é usado no sorteio do tubo")
	State.open_tube()
	ok("kale" in State.unlocked_plants(), "a 1ª colheita destrava a couve")


func _eventos() -> void:
	State.plant(Vector2i(6, 6), "lettuce")   # a noite congelante só vem com planta crescendo
	_forcar_evento("cold")
	ok(State.pending_event == "cold" and hud._choice.visible, "noite congelante pede uma escolha")
	State.energy = 100.0
	hud._on_choice(0)
	ok(State.cold_left == State.COLD_SOLS and State.cold_heated, "aquecer a estufa gasta energia e protege as plantas")
	_ticks(State.COLD_SOLS)
	_forcar_evento("nosignal")
	hud._on_choice(0)
	ok(State.base_locked_reason() == "LOCK_NOSIGNAL" and not State.build("rtg", Vector2i(3, 5)), "sem sinal: não dá para mexer na base")
	_ticks(State.NOSIGNAL_SOLS)
	ok(State.cards.has("4"), "quando o sinal volta, o pacote traz a carta Batata")
	_forcar_evento("dust")
	ok(State.dust_left > 0 and hud._info.visible, "tempestade de poeira suja os painéis e avisa")
	ok(State.next_event_sol - State.sol < State.DUST_SOLS, "depois da poeira, o redemoinho vem enquanto o painel ainda está sujo")
	hud._on_info_ok()
	_forcar_evento("devil")
	ok(State.dust_left == 0 and State.cards.has("22"), "o redemoinho limpa os painéis e dá a carta")
	hud._on_info_ok()


func _jogo_fechado() -> void:
	State.energy = 100.0
	State.build("greenhouse", Vector2i(3, 6))
	State.plant(Vector2i(3, 6), "lettuce")
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
	State.build("pad", Vector2i(6, 3))
	ok(base._pet != null, "a pista do Ingenuity faz o pet aparecer")
	if base._pet == null:
		return
	var rotor: Node3D = base._rotors[0]
	var eixo: Vector3 = (rotor.global_transform.basis * base._rotor_axes[0]).normalized()
	ok(absf(eixo.dot(Vector3.UP)) > 0.9, "as hélices do Ingenuity giram em pé (eixo para cima)")
	var tam: Vector3 = base._merged_aabb(base._pet).size
	ok(tam.x > 0.8 and tam.x < 4.0, "o Ingenuity tem tamanho visível (%.1f m)" % tam.x)


func _niveis_e_album() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	var casa := Vector2i(4, 4)
	ok(State.upgrade_block_reason(casa) == "", "a casa pode ir para o nível 2 (tem espaço ao lado)")
	State.upgrade(casa)
	ok(State.cells_of(casa, "habitat", 2).size() == 2 and State.anchor_of(Vector2i(5, 4)) == casa, "casa no nível 2 ocupa 2 casas")
	State.energy = 100.0
	State.build("solar", Vector2i(6, 4))
	ok(State.upgrade_block_reason(casa) == "NEED_SPACE", "sem espaço ao lado, a casa não sobe para o nível 3")
	ok(not State.build("moxie", Vector2i(5, 4)), "não dá para construir em cima da casa grande")
	State.remove(Vector2i(6, 4))
	State.energy = 100.0
	ok(State.upgrade(casa) and State.cells_of(casa, "habitat", 3).size() == 3, "com espaço, a casa vai para o nível 3 (3 casas)")
	State.energy = 100.0
	State.build("rtg", Vector2i(2, 1))
	State.energy = 100.0
	State.upgrade(Vector2i(2, 1))
	State.energy = 100.0
	State.upgrade(Vector2i(2, 1))
	ok(State.item_name(State.item_at(Vector2i(2, 1))) == "B_KILOPOWER" and State.cards.has("14"), "RTG no nível 3 vira Kilopower e dá a carta")
	var sem_dica := 0
	for id in State.card_ids():
		if State.card_hint(id).strip_edges() == "":
			sem_dica += 1
	ok(sem_dica == 0, "todas as %d cartas dizem como ganhar" % State.cards_total())
	State.energy = 100.0
	State.build("greenhouse", Vector2i(2, 7))
	State.plant(Vector2i(2, 7), "radish")
	_ticks(30)
	State.harvest(Vector2i(2, 7))
	ok(int(State.inventory.get("radish", 0)) == 1, "colher conta no inventário (rabanete × 1)")


func _girar_energia_oxigenio() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	var casa := Vector2i(4, 4)
	State.upgrade(casa)
	ok(State.anchor_of(Vector2i(5, 4)) == casa, "casa nível 2 deitada ocupa a casa ao lado")
	ok(State.rotate(casa) and State.anchor_of(Vector2i(4, 5)) == casa and State.anchor_of(Vector2i(5, 4)) == Vector2i(-1, -1), "girar a casa: a fileira vai para a frente")
	State.energy = 100.0
	State.build("solar", Vector2i(5, 4))
	State.rotate(casa)
	State.build("moxie", Vector2i(4, 5))
	ok(State.rotate_block_reason(casa) == "NEED_SPACE", "não gira se a fileira nova não couber")
	# Sem energia: a bateria de emergência da casa ajuda devagar.
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 0.0
	State.oxygen = 50.0
	State._tick()
	ok(State.energy > 0.0, "sem energia, a bateria de emergência da casa dá um pouquinho")
	# Sem oxigênio: o Mike fica em casa; a planta faz oxigênio.
	State.oxygen = 0.4
	State._tick()
	ok(State.oxygen <= 0.0 and State.mike_inside() and State.explore_block_reason() == "LOCK_OXYGEN", "sem oxigênio, o Mike fica em casa e não explora")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(3, 3))
	State.plant(Vector2i(3, 3), "lettuce")
	State.oxygen = 10.0
	var antes: float = State.oxygen
	State.energy = 100.0
	State._tick()
	ok(is_equal_approx(State.oxygen, antes - State.OXYGEN_BREATH + State.PLANT_OXYGEN), "o Mike respira e a planta faz oxigênio")


func _area_da_casa() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	ok(State.free_cells().size() == 15, "casa no nível 1: a base tem 4 x 4 casas (15 livres)")
	ok(not State.build("solar", Vector2i(2, 1)), "não dá para construir fora da área aberta")
	ok(State.build("rtg", Vector2i(3, 3)), "dentro da área, dá")
	State.energy = 100.0
	ok(State.upgrade_block_reason(Vector2i(3, 3)) == "NEED_HOUSE", "construção não passa do nível da casa")
	State.upgrade(Vector2i(4, 4))
	ok(State.free_cells().size() == 49 - 3, "casa no nível 2: a base cresce para 7 x 7")
	State.energy = 100.0
	ok(State.upgrade(Vector2i(3, 3)), "com a casa no nível 2, o RTG sobe para o nível 2")
	State.energy = 100.0
	ok(State.upgrade_block_reason(Vector2i(3, 3)) == "NEED_HOUSE", "mas não passa para o nível 3")
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	ok(State.zone() == Rect2i(0, 0, State.GRID_W, State.GRID_H), "casa no nível 3: a grade inteira abre")
	var em_breve := 0
	for id in State.card_ids():
		if str(State.card_info(id).get("place", "")).to_lower().contains("em breve"):
			em_breve += 1
	ok(em_breve == 0 and State.cards_total() == 35, "nenhuma carta \"em breve\" (35 cartas no álbum)")


func _caminho_do_mike(base: Node3D) -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	State.build("greenhouse", Vector2i(4, 5))
	# Do lado de trás da casa para a frente da estufa: a linha reta atravessa as duas.
	var de: Vector3 = base.cell_center(Vector2i(5, 3))
	var para: Vector3 = base.cell_center(Vector2i(5, 7))
	var caminho: PackedVector3Array = base._round_corners(base._find_path(de, para))
	var bateu := 0
	for i in range(1, caminho.size()):
		for s in 5:
			if base._nav_solid(caminho[i - 1].lerp(caminho[i], s / 4.0)):
				bateu += 1
	ok(caminho.size() > 2 and bateu == 0, "o Mike dá a volta nas construções (%d pontos, sem bater)" % caminho.size())
	ok(caminho[-1].distance_to(para) < 0.6, "e chega onde a criança tocou")
	var curva := true
	for i in range(1, caminho.size() - 1):
		var a := (caminho[i] - caminho[i - 1]).normalized()
		var b := (caminho[i + 1] - caminho[i]).normalized()
		if a.length() > 0.5 and b.length() > 0.5 and rad_to_deg(a.angle_to(b)) > 50.0:
			curva = false
	ok(curva, "sem quina reta: cada virada do caminho é suave")
	# Construir em cima do Mike: ele sai andando para um lugar livre.
	base._walking_out = false
	base.mike.position = base.cell_center(Vector2i(6, 5))
	base._path = PackedVector3Array()
	base._path_i = 0
	State.energy = 100.0
	State.build("moxie", Vector2i(6, 5))
	ok(base._path.size() > 0 and not base._nav_solid(base._path[-1]), "construíram em cima do Mike: ele sai para o lado")
	# Toque no alto da casa (fora do chão dela) abre a casa.
	base.whole_grid = false
	var casa: Node3D = base._nodes["4,4"]
	var topo: AABB = casa.global_transform * base._merged_aabb(casa)
	var tela: Vector2 = base.camera.unproject_position(topo.get_center() + Vector3(0, topo.size.y * 0.4, 0))
	var acerto: Dictionary = base._item_under(base.camera.project_ray_origin(tela), base.camera.project_ray_normal(tela))
	ok(not acerto.is_empty() and State.anchor_of(acerto.cell) == Vector2i(4, 4), "tocar no telhado da casa abre a casa")
	ok(base._mike_skins.has("suit"), "o Mike de traje está carregado para a expedição")
	base._set_suit(true)
	ok(base._mike_skins.suit[0].visible and not base._mike_skins.casual[0].visible, "na expedição, o Mike veste o traje")
	base._set_suit(false)
	var anims: PackedStringArray = base._mike_anim.get_animation_list() if base._mike_anim else PackedStringArray()
	ok("run" in anims and "idle" in anims, "o Mike tem as animações idle e run: %s" % ", ".join(anims))
	var esq: Skeleton3D = base._mike_skins.casual[0].find_children("*", "Skeleton3D", true, false)[0]
	var idle: Animation = base._mike_anim.get_animation("idle")
	var braco := idle.find_track(NodePath("Root/Skeleton3D:LeftArm"), Animation.TYPE_ROTATION_3D)
	var repouso := esq.get_bone_rest(esq.find_bone("LeftArm")).basis.get_rotation_quaternion()
	var abaixou := rad_to_deg((idle.track_get_key_value(braco, 0) as Quaternion).angle_to(repouso))
	ok(abaixou > 40.0, "o Mike fica com os braços para baixo, sem pose de T (%.0f°)" % abaixou)


func _tutorial() -> void:
	State.new_game()
	ok(State.tutorial == 0, "jogo novo começa com o tutorial")
	State.next_storm_sol = State.sol + 1
	State._tick()
	ok(State.pending_event == "" and not State.paused, "durante o tutorial não vem tempestade")
	hud._start.visible = false   # como se a criança tivesse tocado em Jogar
	for janela in [hud._card, hud._choice, hud._info, hud._nasa, hud._album]:
		janela.visible = false
	hud._card_queue.clear()
	hud._tut_update()
	ok(hud._tut_card.visible and hud._tut_label.text == tr("TUTO_HELLO"), "o Mike dá o 1º recado: tocar em Construir")
	ok(hud._tut_target() == hud._buttons.build, "a moldura dourada fica em volta do botão Construir")
	hud._on_album()
	ok(not hud._album.visible and hud._toast_label.text == tr("TUTO_NUDGE").format({"name": tr("BTN_BUILD")}), "no tutorial, tocar em outra coisa não abre: o Mike lembra o que tocar")
	State.energy = 100.0
	State.build("solar", Vector2i(3, 3))
	hud._tut_update()
	ok(State.tutorial == 1, "construiu o painel: passo da estufa")
	State.energy = 100.0
	State.build("greenhouse", Vector2i(5, 3))
	State.plant(Vector2i(5, 3), "lettuce")
	hud._tut_update()
	ok(State.tutorial == 3 and hud._tut_label.text == tr("TUTO_EXPLORE"), "plantou: o Mike pede para explorar")
	State.oxygen = 100.0
	State.start_explore()
	_ticks(State.EXPLORE_SOLS)
	hud._tut_update()
	ok(State.tutorial == 4 and State.tube_card != 0, "voltou com o tubo: passo de abrir")
	State.open_tube()
	hud._tut_update()
	ok(State.tutorial == 5, "abriu o tubo: parabéns")
	State.tutorial = 0
	State.started = true
	State.energy = 100.0
	var sol_parado: int = State.sol
	State._process(30.0)
	ok(State.sol == sol_parado, "no tutorial, o tempo fica parado esperando a criança")
	State.tutorial = 5
	hud._tut_skip.pressed.emit()
	ok(State.tutorial == State.TUTORIAL_DONE and not hud._tut_card.visible, "o tutorial termina e o recado some")
	hud._card.visible = false
	hud._card_queue.clear()
	ok(hud._sols(tr("COLD_LEFT").format({"n": 1})).ends_with("1 sol"), "1 sol (não \"1 sóis\")")


func _regras_novas() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.oxygen = 100.0
	ok(State.zone(3).size == Vector2i(10, 10) and State.zone(2).size == Vector2i(7, 7), "a base vai até 10 x 10 (4x4, 7x7, 10x10)")
	ok(State.best_snack() == "lettuce", "o jogo começa com um lanche que veio da Terra")
	State.inventory.clear()
	ok(State.explore_block_reason() == "NEED_FOOD", "sem lanche, o Mike não sai para explorar")
	State.inventory = {"lettuce": 1, "chile": 1}
	ok(State.best_snack() == "chile" or State.plant_rarity("chile") == State.plant_rarity("lettuce"), "ele leva o lanche mais raro")
	State.shield = 10.0
	ok(State.explore_block_reason() == "LOCK_SHIELD", "com o escudo baixo, não dá para sair")
	State.shield = 100.0
	ok(State.start_explore(), "com lanche, oxigênio e escudo, ele sai")
	ok(not State.build("solar", Vector2i(3, 3)) and State.build_block_reason("solar") == "LOCK_EXPLORING", "com o Mike fora, não dá para construir")
	_ticks(State.EXPLORE_SOLS)
	State.open_tube()
	State.energy = 100.0
	State.build("greenhouse", Vector2i(3, 3))
	State.plant(Vector2i(3, 3), "lettuce")
	_ticks(10)
	var antes: float = float(State.item_at(Vector2i(3, 3)).growth)
	State.next_storm_sol = State.sol + 1
	State._tick()
	hud._on_choice(1)
	ok(is_equal_approx(float(State.item_at(Vector2i(3, 3)).growth), antes * State.STORM_PLANT_LOSS + 0.0) or float(State.item_at(Vector2i(3, 3)).growth) < antes, "sem escudo, as plantas perdem metade do que cresceram")
	_ticks(State.STORM_SOLS)
	State.energy = 100.0
	ok(is_equal_approx(State.storm_shield_cost(), State.STORM_SHIELD_COST), "sem antena, o escudo custa %d" % int(State.STORM_SHIELD_COST))
	State.build("antenna", Vector2i(4, 3))
	ok(is_equal_approx(State.storm_shield_cost(), State.STORM_SHIELD_COST_WARNED), "com a antena (aviso da NASA), o escudo sai mais barato")
	State.storm_warned = false
	State.next_storm_sol = State.sol + 7
	State.next_event_sol = State.sol + 99
	State._tick()
	State._tick()
	ok(State.storm_warned, "a antena avisa a tempestade alguns sóis antes")
	# Lixeira pede confirmação.
	hud._card.visible = false
	hud._card_queue.clear()
	hud._choice.visible = false
	hud._info.visible = false
	hud._open_panel(Vector2i(4, 3))
	hud._on_remove()
	ok(hud._choice.visible and not State.item_at(Vector2i(4, 3)).is_empty(), "a lixeira primeiro pergunta (nada some sem confirmar)")
	hud._on_choice(0)
	ok(State.item_at(Vector2i(4, 3)).is_empty(), "confirmou: a construção sai")
	# Colher de novo uma planta que já está no álbum não mostra a carta de novo.
	var cartas_antes: int = State.cards.size()
	var fila_antes: int = hud._card_queue.size()
	State.energy = 100.0
	State.plant(Vector2i(3, 3), "lettuce")
	State.item_at(Vector2i(3, 3)).growth = 999.0
	State.harvest(Vector2i(3, 3))
	State.plant(Vector2i(3, 3), "lettuce")
	State.item_at(Vector2i(3, 3)).growth = 999.0
	State.harvest(Vector2i(3, 3))
	ok(hud._card_queue.size() <= fila_antes + 1 and State.cards.size() <= cartas_antes + 1, "colher alface de novo não mostra a carta outra vez")
	hud._card.visible = false
	hud._card_queue.clear()
	hud._choice.visible = false
	hud._info.visible = false


func _batata_e_album() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	ok(not ("potato" in State.unlocked_plants()), "a batata ainda não aparece no começo")
	State.harvests = 2
	ok("potato" in State.unlocked_plants(), "depois de 2 colheitas, a semente de batata aparece")
	var soma := 0
	for p in State.ALBUM_PAGES.size():
		soma += State.page_cards(p).size()
	ok(soma == State.cards_total(), "as 5 páginas do álbum têm todas as %d cartas" % State.cards_total())
	State.add_card(1)
	ok(State.unseen_count() >= 1, "carta ganha e ainda não vista conta como nova")
	hud._start.visible = false
	hud._on_album()
	ok(hud._album.visible and hud._album_grid.get_child_count() == State.cards_total(), "o álbum mostra todas as cartas juntas")
	ok(State.seen_cards.has("1"), "depois de ver a página, a carta deixa de ser nova")
	hud._album.visible = false
	hud._card.visible = false
	hud._card_queue.clear()


func _quebrar_e_consertar() -> void:
	State.new_game()
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	ok(State.upgrade_cost(Vector2i(4, 4)) == 30, "melhorar a casa para o nível 2 custa 30")
	State.build("solar", Vector2i(3, 3))
	ok(State.upgrade_cost(Vector2i(3, 3)) == 30, "painel solar: nível 2 custa 3 vezes o preço (30)")
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	State.energy = 100.0
	State.upgrade(Vector2i(3, 3))
	ok(State.upgrade_cost(Vector2i(3, 3)) == 80, "e o nível 3 custa 8 vezes (80)")
	var k := State.break_something()
	ok(k == "3,3" and State.item_at(Vector2i(3, 3)).get("broken", false), "algo quebra (nunca a casa)")
	ok(is_zero_approx(float(State.item_rates(State.item_at(Vector2i(3, 3))).energy)), "quebrado não faz energia")
	State.energy = 100.0
	ok(State.repair(Vector2i(3, 3)) and not State.item_at(Vector2i(3, 3)).get("broken", false), "consertar faz voltar a funcionar")


func _comeco_devagar() -> void:
	State.new_game()
	ok(is_equal_approx(State.energy, 20.0) and is_equal_approx(State.oxygen, 40.0) and is_equal_approx(State.shield, 40.0), "começo devagar: energia 20, oxigênio e escudo 40")
	State.build("solar", Vector2i(3, 3))
	State.tutorial = 1
	ok(State.tutorial_needs_energy() and not State.tutorial_holds_time(), "no tutorial, sem energia para a estufa o tempo anda")
	State.tutorial = State.TUTORIAL_DONE
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	ok(State.oxygen >= 60.0 and State.shield >= 60.0, "casa no nível 2: as barras sobem para 60")
	State.energy = 100.0
	State.upgrade(Vector2i(4, 4))
	ok(is_equal_approx(State.energy, 100.0) and is_equal_approx(State.oxygen, 100.0), "casa no nível 3: as barras enchem")
