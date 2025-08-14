extends Control

#tutto da aggiornare con gli altri 4 livelli

func _on_level_1_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
	AudioManager.play_music(level_music)
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")

#musica da scegliere
func _on_level_2_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
	AudioManager.play_music(level_music)

# Asset Mancante
func _on_level_3_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
	AudioManager.play_music(level_music)

func _on_level_4_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/Jeremy Blake - Powerup!  NO COPYRIGHT 8-bit Music.mp3")
	AudioManager.play_music(level_music)

func _on_level_5_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
	AudioManager.play_music(level_music)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
