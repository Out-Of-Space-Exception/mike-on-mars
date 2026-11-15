extends Node
## Plays a sound by its file name (without extension), if it exists in res://sounds/.
## The names are those in the "arquivo" column of conteudo/01-sons/sons.csv (e.g. Sfx.play("construir")).

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


## Looping background music (starts on "Play": the browser only allows sound after a tap).
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


## Turns the music on or off (settings). The button sound is checked on every play().
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
