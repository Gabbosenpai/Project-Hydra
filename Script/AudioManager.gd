extends Node

var music_volume: float = 0.01
var sfx_volume: float = 0.01

var music_player: AudioStreamPlayer = null
var sfx_player: AudioStreamPlayer = null

func _ready():
	# CREA E CONFIGURA IL MUSIC PLAYER
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	# Carica e suona la musica di sottofondo
	var music_stream = preload("res://OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3") # <-- cambia con il tuo file
	music_player.stream = music_stream
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()

	# CREA E CONFIGURA IL SFX PLAYER
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.volume_db = linear_to_db(sfx_volume)

func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume)

func play_sfx(sfx_stream: AudioStream) -> void:
	if sfx_player:
		sfx_player.stream = sfx_stream
		sfx_player.play()
