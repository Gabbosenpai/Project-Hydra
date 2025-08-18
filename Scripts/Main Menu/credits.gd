extends Control


func _ready():
	var credits_music = preload("res://Assets/Sound/OST/Kevin MacLeod - Itty Bitty (CREDITS THEME).mp3")
	AudioManager.play_music(credits_music)

func _on_back_to_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
