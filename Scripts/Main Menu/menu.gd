extends CanvasLayer

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var credits_button = $VBoxContainer/CreditsButton

#se clicco gioca ferma l'OST del menù
func _on_play_button_pressed() -> void:
	AudioManager.music_player.stop()
  #Ferma la musica del menu
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")


func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Opzioni.tscn")
