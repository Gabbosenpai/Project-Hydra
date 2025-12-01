extends Control


#Funzione che inizializza i crediti
func _ready():
	var credits_music = preload("res://Assets/Sound/OST/Kevin MacLeod - Itty Bitty (CREDITS THEME).mp3")
	AudioManager.play_music(credits_music) #Viene avviata la OST


#Funzione che rileva quando il pulsante per tonare al menu viene cliccato
func _on_back_to_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx) #Viene avviata la OST del menu principale
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
