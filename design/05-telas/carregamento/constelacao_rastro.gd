class_name ConstelacaoRastro
extends Node2D
## Rastro de constelação do Mike on Mars (efeito original do time).
## Quem se mexe deixa estrelinhas douradas e creme, ligadas por linhas finas, que piscam e somem.
## Uso: adicione como filho de qualquer Node2D que se mexe (a nave, o Mike na tela, um botão).

@export var alvo: Node2D          ## quem deixa o rastro; vazio = o pai
@export var passo := 22.0         ## distância (px) entre uma estrela e a próxima
@export var vida := 1.6           ## segundos até a estrela sumir
@export var espalhar := 14.0      ## quanto as estrelas fogem da linha reta
@export var tamanho := 1.0       ## multiplica o tamanho das estrelas e linhas
@export var cores: Array[Color] = [Color("e8b23a"), Color("f2d091"), Color("fff4d6")]

var _pts: Array = []
var _ultimo := Vector2.INF


func _ready() -> void:
	top_level = true


func _process(dt: float) -> void:
	global_position = Vector2.ZERO
	var a: Node2D = alvo
	if a == null:
		a = get_parent() as Node2D
	if a != null:
		var p: Vector2 = a.global_position
		if _ultimo == Vector2.INF:
			_ultimo = p
		while p.distance_to(_ultimo) >= passo:
			_ultimo = _ultimo.move_toward(p, passo)
			_adicionar(_ultimo)
	for q in _pts:
		q["t"] += dt
	_pts = _pts.filter(func(q): return q["t"] < vida)
	queue_redraw()


func _adicionar(p: Vector2) -> void:
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * espalhar
	_pts.append({"pos": p + off, "t": 0.0, "size": randf_range(2.5, 5.5) * tamanho,
		"col": cores.pick_random(), "brilho": randf() < 0.35, "fase": randf() * TAU})


func _draw() -> void:
	for i in range(1, _pts.size()):
		var a: Dictionary = _pts[i - 1]
		var b: Dictionary = _pts[i]
		var k: float = 1.0 - maxf(a["t"], b["t"]) / vida
		draw_line(a["pos"], b["pos"], Color(b["col"], 0.7 * k), 1.6 * tamanho, true)
		if i >= 2 and i % 3 == 0:
			var c: Dictionary = _pts[i - 2]
			draw_line(c["pos"], b["pos"], Color(b["col"], 0.35 * k), 1.0 * tamanho, true)
	for q in _pts:
		var k: float = 1.0 - q["t"] / vida
		var pisca: float = 0.75 + 0.25 * sin(q["t"] * 12.0 + q["fase"])
		var s: float = q["size"] * (0.6 + 0.4 * k) * pisca
		draw_circle(q["pos"], s * 2.6, Color(q["col"], 0.22 * k))
		draw_circle(q["pos"], s * 0.7, Color(q["col"], k))
		if q["brilho"]:
			var c2 := Color(q["col"], 0.9 * k)
			draw_line(q["pos"] - Vector2(s * 2.4, 0), q["pos"] + Vector2(s * 2.4, 0), c2, 1.5 * tamanho, true)
			draw_line(q["pos"] - Vector2(0, s * 2.4), q["pos"] + Vector2(0, s * 2.4), c2, 1.5 * tamanho, true)
