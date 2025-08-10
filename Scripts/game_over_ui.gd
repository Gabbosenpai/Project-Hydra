extends Control
@export var game_over: Control

func show_game_over():
	game_over.visible = true
	get_tree().paused = true

func _on_retry_button_pressed():
	get_tree().paused = false
	AudioManager.music_player.stop()
	AudioManager.music_player.stream = null
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")

func _on_exit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
