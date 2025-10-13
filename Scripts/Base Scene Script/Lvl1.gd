extends "res://Scripts/Base Scene Script/BaseLevel.gd" 

# Musica unica per il Livello 1
func _set_level_music():
	var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
	AudioManager.play_music(level_music)

# Logica di sblocco: sblocca il Livello 2
func _on_level_completed():
	AudioManager.play_victory_music()

	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 2:
		SaveManager.unlock_level(2)
		print("Livello 2 sbloccato!")
