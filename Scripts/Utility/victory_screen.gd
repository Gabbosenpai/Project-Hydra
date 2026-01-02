extends Control


func _on_select_level_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")

func _on_next_level_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	
	var max_unlocked_level = SaveManager.get_max_unlocked_level()
	
	# Precarico la musica e cambio scena in base al livello max sbloccato
	var level_music : AudioStream = null
	var level_scene_path : String = ""
	
	match max_unlocked_level:
		1:
			level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl1.tscn"
		2:
			level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl2.tscn"
		3:
			level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
			level_scene_path = "res://Scenes/Levels/Lvl3.tscn"
		4:
			level_music = preload("res://Assets/Sound/OST/Jeremy Blake - Powerup!  NO COPYRIGHT 8-bit Music.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl4.tscn"
		5:
			level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl5.tscn"
		_:
			# Se non esiste un livello sbloccato valido, fai qualcosa (ad esempio torna al menu)
			get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
			return
	
	AudioManager.play_music(level_music)
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(level_scene_path)


func _on_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
