extends Node
## Toca um som pelo nome do arquivo (sem extensão), se ele existir em res://sounds/.
## Os nomes são os da coluna "arquivo" do conteudo/01-sons/sons.csv (ex.: Sfx.play("construir")).

var _players: Array[AudioStreamPlayer] = []
var _cache := {}
var _music: AudioStreamPlayer


func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func play(sound_name: String) -> void:
	if not State.sounds_on:
		return
	var stream := _load(sound_name)
	if stream == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.play()
			return


## Música de fundo em loop (começa no "Jogar": o navegador só deixa tocar som depois de um toque).
func play_music(sound_name: String) -> void:
	var stream := _load(sound_name)
	if stream == null:
		return
	if _music == null:
		_music = AudioStreamPlayer.new()
		_music.volume_db = -10.0
		_music.finished.connect(_music.play)
		add_child(_music)
	_music.stream = stream
	_music.play()
	apply_settings()


## Liga ou desliga a música (configurações). O som dos botões é conferido a cada play().
func apply_settings() -> void:
	if _music:
		_music.stream_paused = not State.music_on


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
