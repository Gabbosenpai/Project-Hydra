extends CanvasLayer

#Riferimenti ai pulsanti del menu
@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var reset_button = $VBoxContainer/ResetButton
@onready var confirm_box = $ResetConfirm
@onready var main_menu = $VBoxContainer

#Funzione che inizializza il menu principale
func _ready():
	var menu_music = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	AudioManager.play_music(menu_music)
	# Collegamenti bottoni conferma
	confirm_box.get_node("YesButton").pressed.connect(_on_confirm_yes)
	confirm_box.get_node("NoButton").pressed.connect(_on_confirm_no)

	# Nascondi conferma all'avvio
	confirm_box.visible = false

#se clicco gioca ferma l'OST del menù
func _on_play_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)

  #Ferma la musica del menu
	get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")
	

#Funzione che dealloca la scena quando si clicca esci e per cui fa terminaare il gioco
func _on_quit_button_pressed() -> void:
	
	get_tree().quit()

#Funzione che mostra i crediti e avvia la sfx del pulsante dei crediti
func _on_credits_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)

	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")

#Funzione che mostra le opzioni e avvia la sfx del pulsante opzioni
func _on_option_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)

	get_tree().change_scene_to_file("res://Scenes/Opzioni.tscn")


#Funzione che consente di cambiare la lingua e avvia la sfx del pulsante opzioni
func _on_languages_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/language_selection.tscn")

#Funzione che si occupa di resettare i salvataggi fatti e lancia la sfx del pulsante reset
func _on_reset_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	main_menu.visible = false
	confirm_box.visible = true

# Funzione che si occupa conferma il reset dei salvataggi fatti e lancia la sfx del pulsante yes
func _on_confirm_yes() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.reset_progress()
	print("Progress reset!")
	confirm_box.visible = false
	main_menu.visible = true

# Funzione che si occupa impedire il reset dei salvataggi fatti e lancia la sfx del pulsante no
func _on_confirm_no() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	confirm_box.visible = false
	main_menu.visible = true
