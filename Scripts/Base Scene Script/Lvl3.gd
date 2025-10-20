extends baseLevel

func _set_level_music():
	var level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
	AudioManager.play_music(level_music)

func _on_level_completed():
	AudioManager.play_victory_music()

	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 4:
		SaveManager.unlock_level(4)
		print("Livello 4 sbloccato!")
	get_tree().change_scene_to_file("res://Scenes/Utilities/tech_tree.tscn")
