extends Node
## Toca um som pelo nome do arquivo (sem extensão), se ele existir em res://sounds/.
## Os nomes são os da coluna "arquivo" do conteudo/01-sons/sons.csv (ex.: Sfx.play("construir")).

var _players: Array[AudioStreamPlayer] = []
var _cache := {}


func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func play(sound_name: String) -> void:
	var stream := _load(sound_name)
	if stream == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.play()
			return


func _load(sound_name: String) -> AudioStream:
	if _cache.has(sound_name):
		return _cache[sound_name]
	var stream: AudioStream = null
	for ext in [".ogg", ".wav"]:
		var path := "res://sounds/%s%s" % [sound_name, ext]
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	_cache[sound_name] = stream
	return stream
