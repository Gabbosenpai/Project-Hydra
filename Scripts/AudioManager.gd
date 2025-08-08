extends Node

# Volume attuale
var music_volume: float = 0.01
var sfx_volume: float = 0.01

# Per gestire mute musica
var previous_music_volume: float = 0.01
var is_music_muted: bool = false

# Audio Players
var music_player: AudioStreamPlayer = null
var sfx_player: AudioStreamPlayer = null

func _ready():
	# CREA E CONFIGURA IL MUSIC PLAYER
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	# Carica e suona la musica di sottofondo
	var music_stream = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	music_player.stream = music_stream
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()

	# CREA E CONFIGURA IL SFX PLAYER
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.volume_db = linear_to_db(sfx_volume)

# Cambia il volume della musica
func set_music_volume(vol: float) -> void:
	vol = clamp(vol, 0.0, 1.0)
	music_volume = vol  # Sempre aggiorna il valore reale del volume

	if is_music_muted:
		# Se è mutato, non cambiare il volume del player
		if music_player:
			music_player.volume_db = linear_to_db(0.0)
	else:
		# Altrimenti aggiorna normalmente
		if music_player:
			music_player.volume_db = linear_to_db(music_volume)




# Cambia il volume degli effetti
func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume)

# Suona un effetto sonoro
func play_sfx(sfx_stream: AudioStream) -> void:
	if sfx_player:
		sfx_player.stream = sfx_stream
		sfx_player.play()

# Mute/unmute musica
func toggle_music_mute() -> void:
	is_music_muted = !is_music_muted

	if is_music_muted:
		if music_player:
			music_player.volume_db = linear_to_db(0.0)
	else:
		if music_player:
			music_player.volume_db = linear_to_db(music_volume)


func play_music(music_stream: AudioStream) -> void:
	if music_player:
		music_player.stop()
		music_player.stream = music_stream
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()
