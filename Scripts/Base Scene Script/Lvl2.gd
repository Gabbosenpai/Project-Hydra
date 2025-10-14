extends "res://Scripts/Base Scene Script/BaseLevel.gd" 

func _set_level_music():
	var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
	AudioManager.play_music(level_music)

func _on_level_completed():
	AudioManager.play_victory_music()

	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 3:
		SaveManager.unlock_level(3)
		print("Livello 3 sbloccato!")
	get_tree().change_scene_to_file("res://Scenes/Utilities/tech_tree.tscn")
