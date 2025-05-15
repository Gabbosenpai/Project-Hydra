extends CanvasLayer

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	play_button.pressed.connect(on_play_pressed)
	quit_button.pressed.connect(on_quit_pressed)

func on_play_pressed():
	get_tree().change_scene_to_file("res://Scene/main.tscn")  # Cambia col nome della tua scena di gioco

func on_quit_pressed():
	get_tree().quit()
