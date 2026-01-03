extends CanvasLayer

# Riferimenti ai pulsanti del menu
@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var encyclopedia_button = $VBoxContainer/EncyclopediaButton
@onready var confirm_box = $ResetConfirm
@onready var main_menu = $VBoxContainer
@export var mute_music_button: Button
@export var mute_sfx_button: Button
@export var option_menu: Panel
@export var music_slider: HSlider
@export var sfx_slider: HSlider
#sprite per le icone del volume
@export var music_on_sprite: Sprite2D
@export var music_off_sprite: Sprite2D
@export var sfx_on_sprite: Sprite2D
@export var sfx_off_sprite: Sprite2D




# Funzione che inizializza il menu principale
func _ready():
	var menu_music = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	AudioManager.play_music(menu_music)# Sincronizza gli sprite dei pulsanti muto con lo stato effettivo
	_sync_sliders_with_audio()
	_refresh_audio_ui()

#per sincronizzare le icone audio
func _refresh_audio_ui():
	
	music_on_sprite.visible = !AudioManager.is_music_muted
	music_off_sprite.visible = AudioManager.is_music_muted

	sfx_on_sprite.visible = !AudioManager.is_sfx_muted
	sfx_off_sprite.visible = AudioManager.is_sfx_muted



# Se clicco gioca ferma l'OST del menù
func _on_play_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	# Ferma la musica del menu
	get_tree().change_scene_to_file("res://Scenes/Utilities/slot_selection.tscn")


# Funzione che dealloca la scena quando si clicca esci e per cui fa terminaare il gioco
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Funzione che mostra i crediti e avvia la sfx del pulsante dei crediti
func _on_credits_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/Credits.tscn")


# Funzione che mostra le opzioni, avvia la sfx del pulsante opzioni e sincronizza
# icona mute/unmute
func _on_option_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	option_menu.visible = true
	_sync_sliders_with_audio()
	_refresh_audio_ui()
	if PlayFabManager.client_config.is_logged_in():
		var userButtonText = $MenuOption/UserText
		var username = PlayFabManager.client_config.username
		
		if username == "":
			userButtonText.text = "Utente non loggato per procedere al login cliccare sul pulsante con l'omino qui a sinistra"
		else:
			userButtonText.text = "Utente loggato: " + username


# Funzione che consente di cambiare la lingua e avvia la sfx del pulsante opzioni
func _on_languages_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/language_selection.tscn")

##Funzione che si occupa di resettare i salvataggi fatti e lancia la sfx del pulsante reset
#func _on_reset_button_pressed() -> void:
	#AudioManager.play_sfx(AudioManager.button_click_sfx)
	#main_menu.visible = false
	#confirm_box.visible = true
#
## Funzione che si occupa conferma il reset dei salvataggi fatti e lancia la sfx del pulsante yes
#func _on_confirm_yes() -> void:
	#AudioManager.play_sfx(AudioManager.button_click_sfx)
	#SaveManager.reset_progress()
	#print("Progress reset!")
	#confirm_box.visible = false
	#main_menu.visible = true
#
## Funzione che si occupa impedire il reset dei salvataggi fatti e lancia la sfx del pulsante no
#func _on_confirm_no() -> void:
	#AudioManager.play_sfx(AudioManager.button_click_sfx)
	#confirm_box.visible = false
	#main_menu.visible = true





# Sincronizzo gli slider nelle opzioni con il livello audio attuale 
func _sync_sliders_with_audio():
	music_slider.value = AudioManager.music_volume *100
	sfx_slider.value = AudioManager.sfx_volume * 100

func _on_encyclopedia_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/EncyclopediaFirstScreen.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value/100.0)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value/100.0)


func _on_mute_music_button_pressed() -> void:
	AudioManager.toggle_music_mute()
	_refresh_audio_ui()


func _on_mute_sfx_button_pressed() -> void:
	AudioManager.toggle_sfx_mute()
	_refresh_audio_ui()


func _on_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")


func _on_user_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	if(PlayFabManager.client_config.is_logged_in()):
		get_tree().change_scene_to_file("res://Scenes/Login/account_management.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")
