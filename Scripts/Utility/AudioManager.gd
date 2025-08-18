extends Node

var initialized: bool = false

# Volume attuale
var music_volume: float = 0.01
var sfx_volume: float = 0.01

# Musica di game over
var game_over_music = preload("res://Assets/Sound/OST/A Lonely Cherry Tree (GAME OVER MENU).mp3")

#musica di vittoria
var victory_music = preload("res://Assets/Sound/OST/8-bit RPG Music ｜ Victory Theme(VICTORY SOUND EFFECT + MENU THEME).mp3")

# Per gestire mute musica
var previous_music_volume: float = 0.01
var is_music_muted: bool = false
#suono bottoni
var button_click_sfx = preload("res://Assets/Sound/SFX/8bit Click Sound Effect.mp3")
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
	sfx_player.volume_db = linear_to_db(sfx_volume)
	add_child(sfx_player)

	

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

# Suona un effetto sonoro (anche sovrapposto)
func play_sfx(sfx_stream: AudioStream) -> void:
	var new_sfx_player = AudioStreamPlayer.new()
	new_sfx_player.stream = sfx_stream
	new_sfx_player.bus = "SFX"
	new_sfx_player.volume_db = linear_to_db(sfx_volume)
	add_child(new_sfx_player)
	new_sfx_player.play()

	# Rimuove il nodo una volta finito
	new_sfx_player.connect("finished", Callable(new_sfx_player, "queue_free"))

# Mute/unmute musica
func toggle_music_mute() -> void:
	is_music_muted = !is_music_muted
	if is_music_muted:
		music_player.volume_db = linear_to_db(0.0)
	else:
		music_player.volume_db = linear_to_db(music_volume)

# Cambia la musica
func play_music(music_stream: AudioStream) -> void:
	if music_player and (music_player.stream != music_stream or !music_player.playing):
		music_player.stop()
		music_player.stream = music_stream
		music_player.seek(0)

		if is_music_muted:
			music_player.volume_db = linear_to_db(0.0)
		else:
			music_player.volume_db = linear_to_db(music_volume)

		music_player.play()

# Suona la musica di game over
func play_game_over_music():
	play_music(game_over_music)

#suona la musica di vittoria
func play_victory_music():
	play_music(victory_music)
