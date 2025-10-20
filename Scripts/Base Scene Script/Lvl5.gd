extends baseLevel

func _set_level_music():
	var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
	AudioManager.play_music(level_music)
