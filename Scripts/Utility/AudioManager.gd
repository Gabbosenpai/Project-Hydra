extends Node

var initialized: bool = false

# Volume attuale
var music_volume: float = 0.01
var sfx_volume: float = 0.01
var game_over_music = preload("res://Assets/Sound/OST/A Lonely Cherry Tree (GAME OVER MENU).mp3")

# Per gestire mute musica
var previous_music_volume: float = 0.01
var is_music_muted: bool = false

# Audio Players
var music_player: AudioStreamPlayer = null
var sfx_player: AudioStreamPlayer = null

func _ready():
	if initialized:
		return  # Evita di re-inizializzare se già fatto

	initialized = true  # Segna come inizializzato

	# CREA E CONFIGURA IL MUSIC PLAYER
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	music_player.connect("finished", Callable(self, "_on_music_finished"))
	add_child(music_player)

	# CREA E CONFIGURA IL SFX PLAYER
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.volume_db = linear_to_db(sfx_volume)

	# Carica e suona la musica iniziale solo se non sta già suonando
	var music_stream = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	play_music(music_stream)
# Loop manuale della musica
func _on_music_finished():
	music_player.play()

# Cambia il volume della musica
func set_music_volume(vol: float) -> void:
	vol = clamp(vol, 0.0, 1.0)
	music_volume = vol
	if is_music_muted:
		music_player.volume_db = linear_to_db(0.0)
	else:
		music_player.volume_db = linear_to_db(music_volume)

# Cambia il volume degli effetti
func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
	sfx_player.volume_db = linear_to_db(sfx_volume)

# Suona un effetto sonoro
func play_sfx(sfx_stream: AudioStream) -> void:
	sfx_player.stream = sfx_stream
	sfx_player.play()

# Mute/unmute musica
func toggle_music_mute() -> void:
	is_music_muted = !is_music_muted
	if is_music_muted:
		music_player.volume_db = linear_to_db(0.0)
	else:
		music_player.volume_db = linear_to_db(music_volume)

# Cambia la musica
func play_music(music_stream: AudioStream) -> void:
	if music_player:
		if music_player.stream == music_stream and music_player.playing:
			return  # Sta già suonando questa traccia

		music_player.stop()
		music_player.stream = music_stream
		music_player.seek(0)

		if is_music_muted:
			music_player.volume_db = linear_to_db(0.0)
		else:
			music_player.volume_db = linear_to_db(music_volume)

		music_player.play()
func play_game_over_music():
	play_music(game_over_music)
