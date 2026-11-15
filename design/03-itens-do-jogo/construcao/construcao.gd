extends Node3D
## Canteiro de obra: bloquinhos vão sendo empilhados enquanto a construção é feita.
## VALE PARA TODAS AS CONSTRUÇÕES da lista USA_OBRA (estufa, painel solar, bateria nuclear/RTG, MOXIE, antena,
## pista do Ingenuity e luzinhas). O vaso e a bandeira NÃO usam esta animação: aparecem direto.
## No fim, os blocos somem e a construção "brota" do chão (achatada -> tamanho normal, com quique).
## Uso (Dev):
##   var obra := preload("res://.../construcao.gd").new()
##   add_child(obra); obra.position = pos
##   obra.iniciar(cena_da_construcao, duracao_em_segundos, tamanho_do_lote)
##   Mike: virar para a obra e tocar a animação "construir" (mike.glb) enquanto obra.em_obra == true.

signal terminou(construcao: Node3D)

## Chaves do ITEMS do jogo/autoload/state.gd que passam pela obra (Mike martelando + blocos + erguer).
const USA_OBRA := ["greenhouse", "solar", "rtg", "moxie", "antenna", "pad", "lights"]   # "flag" e "pot" não

const CORES := [Color("D96941"), Color("F2D091"), Color("E8B23A"), Color("73242A")]
const BLOCO := 0.35

var em_obra := false
var _blocos: Array[MeshInstance3D] = []

func iniciar(cena: PackedScene, duracao: float, tamanho := Vector2(1.5, 1.5)) -> void:
	em_obra = true
	var n := 12
	var mesh := BoxMesh.new(); mesh.size = Vector3.ONE * BLOCO
	for i in n:
		var b := MeshInstance3D.new(); b.mesh = mesh
		var mat := StandardMaterial3D.new(); mat.albedo_color = CORES[i % CORES.size()]; mat.roughness = 0.8
		b.material_override = mat
		var col := i % 4; var lin := i / 4
		b.position = Vector3((col % 2 - 0.5) * tamanho.x * 0.5, BLOCO * 0.5 + lin * BLOCO, (col / 2 - 0.5) * tamanho.y * 0.5)
		b.rotation.y = randf_range(-0.3, 0.3)
		b.scale = Vector3.ZERO
		add_child(b); _blocos.append(b)
		# cada bloco cai do alto e quica no lugar
		var t := create_tween()
		t.tween_interval(duracao * float(i) / n)
		t.tween_callback(func(): b.position.y += 1.2; b.scale = Vector3.ONE)
		t.tween_property(b, "position:y", b.position.y, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(duracao).timeout
	_finalizar(cena)

func _finalizar(cena: PackedScene) -> void:
	# blocos encolhem e somem
	for b in _blocos:
		create_tween().tween_property(b, "scale", Vector3.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.2).timeout
	for b in _blocos: b.queue_free()
	_blocos.clear()
	# a construção surge (efeito "erguer")
	var c: Node3D = cena.instantiate()
	add_child(c)
	var escala_final := c.scale
	c.scale = Vector3(escala_final.x, 0.01, escala_final.z)
	var tw := c.create_tween()
	tw.tween_property(c, "scale", escala_final, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_poeira()
	em_obra = false
	terminou.emit(c)

func _poeira() -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true; p.amount = 24; p.lifetime = 0.6; p.explosiveness = 1.0
	p.direction = Vector3.UP; p.spread = 80.0; p.initial_velocity_min = 1.0; p.initial_velocity_max = 2.5
	p.gravity = Vector3(0, -2, 0); p.scale_amount_min = 0.15; p.scale_amount_max = 0.3
	var m := SphereMesh.new(); m.radius = 0.15; m.height = 0.3
	var mat := StandardMaterial3D.new(); mat.albedo_color = Color("F2D091"); m.material = mat
	p.mesh = m
	add_child(p); p.emitting = true
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)
