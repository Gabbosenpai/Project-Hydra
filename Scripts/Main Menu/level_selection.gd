extends Control

#tutto da aggiornare con gli altri 4 livelli

func _on_level_1_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/The Whole Other - 8-Bit Dreamscape NO COPYRIGHT 8-bit Music( PRIMA WAVE LEVEL).mp3")
	AudioManager.play_music(level_music)
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")

#musica da scegliere
func _on_level_2_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
	AudioManager.play_music(level_music)

func _on_level_3_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/8-Bit Boss Battle： 4 - By EliteFerrex (ADVANCED WAVE LEVEL).mp3")
	AudioManager.play_music(level_music)

func _on_level_4_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/8Bit Boss Chiptune - Boss Theme - Sawsquarenoise · Free Copyright-Safe Music (WAVE OST).mp3")
	AudioManager.play_music(level_music)

func _on_level_5_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/8 Bit⧸16 Bit Music  - ＂This Is Our Only Chance!＂(FINAL LEVEL).mp3")
	AudioManager.play_music(level_music)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
