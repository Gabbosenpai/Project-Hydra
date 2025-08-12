extends CanvasLayer

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var credits_button = $VBoxContainer/CreditsButton

func _ready():
	var menu_music = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	AudioManager.play_music(menu_music)



#se clicco gioca ferma l'OST del menù
func _on_play_button_pressed() -> void:
	
  #Ferma la musica del menu
	get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")
	
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")


func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Opzioni.tscn")



func _on_languages_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/language_selection.tscn")
