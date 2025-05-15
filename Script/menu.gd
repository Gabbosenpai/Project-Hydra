extends CanvasLayer

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
