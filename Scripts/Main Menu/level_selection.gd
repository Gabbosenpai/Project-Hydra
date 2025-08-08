extends Control

#tutto da aggiornare con gli altri 4 livelli

func _on_level_1_pressed() -> void:
	var level_music = preload("res://Assets/Sound/OST/The Whole Other - 8-Bit Dreamscape NO COPYRIGHT 8-bit Music( PRIMA WAVE LEVEL).mp3")
	AudioManager.play_music(level_music)
	
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")
