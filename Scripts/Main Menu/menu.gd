class_name Menu
extends CanvasLayer

# Riferimenti ai pulsanti del menu
@onready var play_button = $VBoxPanel/VBoxContainer/PlayButton
@onready var quit_button = $VBoxPanel/VBoxContainer/QuitButton
@onready var credits_button = $VBoxPanel/VBoxContainer/CreditsButton
@onready var encyclopedia_button = $VBoxPanel/VBoxContainer/EncyclopediaButton
@onready var confirm_box = $ResetConfirm
@onready var main_menu = $VBoxPanel/VBoxContainer
@onready var admin_timer = Timer.new()
@export var mute_music_button: TextureButton
@export var mute_sfx_button: TextureButton
@export var option_menu: Panel
@export var music_slider: HSlider
@export var sfx_slider: HSlider

static var adminMode = true
var adminButtonPressed = 0
var texture_muted_music = preload("res://Assets/Sprites/UI/Music and SFX/Music Button Off.png")
var texture_not_muted_music = preload("res://Assets/Sprites/UI/Music and SFX/Music Button On.png")
var texture_muted_sfx = preload("res://Assets/Sprites/UI/Music and SFX/Sound Button Off.png")
var texture_not_muted_sfx = preload("res://Assets/Sprites/UI/Music and SFX/Sound Button On.png")


# Funzione che inizializza il menu principale
func _ready():
	if(adminMode == true):
		adminMode = true
	else:
		adminMode = false
	add_child(admin_timer)
	admin_timer.wait_time = 5.0
	admin_timer.one_shot = true
	admin_timer.timeout.connect(_on_admin_timer_timeout)
	var menu_music = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	AudioManager.play_music(menu_music)# Sincronizza gli sprite dei pulsanti muto con lo stato effettivo
	_sync_sliders_with_audio()
	_refresh_audio_ui()

# Aggiornata UI bottoni SFX e Music, dovrebbeero sincronizzarsi automaticamente
# Per sincronizzare le icone audio
func _refresh_audio_ui():
	if !AudioManager.is_music_muted:
		mute_music_button.texture_normal = texture_not_muted_music
		mute_music_button.texture_pressed = texture_muted_music
	else:
		mute_music_button.texture_normal = texture_muted_music
		mute_music_button.texture_pressed = texture_not_muted_music
	if !AudioManager.is_sfx_muted:
		mute_sfx_button.texture_normal = texture_not_muted_sfx
		mute_sfx_button.texture_pressed = texture_muted_sfx
	else:
		mute_sfx_button.texture_normal = texture_muted_sfx
		mute_sfx_button.texture_pressed = texture_not_muted_sfx



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
	if option_menu.visible == false:
		option_menu.visible = true
		_sync_sliders_with_audio()
		#_refresh_audio_ui()
		if PlayFabManager.client_config.is_logged_in():
			var userButtonText = $MenuOption/UserButton/UserText
			var username = PlayFabManager.client_config.username
			
			if username == "":
				userButtonText.text = "Utente non loggato per procedere al login cliccare sul pulsante con l'omino qui a sinistra"
			else:
				userButtonText.text = "Utente loggato: " + username
	else:
		option_menu.visible = false

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
	get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaFirstScreen.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value/100.0)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value/100.0)


func _on_mute_music_button_pressed() -> void:
	AudioManager.toggle_music_mute()
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	#_refresh_audio_ui()


func _on_mute_sfx_button_pressed() -> void:
	AudioManager.toggle_sfx_mute()
	#_refresh_audio_ui()


func _on_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	# By changing scene we see the scene flickering, not good for the eyes :/
	#get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
	option_menu.visible = false


func _on_user_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	if(PlayFabManager.client_config.is_logged_in()):
		var account_management = $MenuOption/AccountManagement
		account_management.reset_label_()
		toggle_main_options_ui(false)
		account_management.visible = true
		#get_tree().change_scene_to_file("res://Scenes/Login/account_management.tscn")
	else:
			var login = $MenuOption/Login
			toggle_main_options_ui(false)
			login.visible = true
		#get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

func update_user_display() -> void:
	var userButtonText = $MenuOption/UserButton/UserText
	
	if PlayFabManager.client_config.is_logged_in():
		var username = PlayFabManager.client_config.username
		if username == "" or username == null:
			userButtonText.text = "Utente loggato (DisplayName mancante)"
		else:
			userButtonText.text = "Utente loggato: " + username
	else:
		# QUESTO RESETTA IL TESTO DOPO IL LOGOUT
		userButtonText.text = "Utente non loggato per procedere al login cliccare sul pulsante con l'omino qui a sinistra"
	

func toggle_main_options_ui(boolean: bool):
	$MenuOption/MenuButton.visible = boolean
	$MenuOption/MuteMusicButton.visible = boolean
	$MenuOption/MuteSFXButton.visible = boolean
	$MenuOption/UserButton.visible = boolean
	$MenuOption/LanguageButton.visible = boolean
	
	if show:
		update_user_display()


func _on_admin_button_pressed() -> void:

	adminButtonPressed += 1
	admin_timer.start()
	
	if(adminButtonPressed >= 7):
		adminMode = true
		admin_timer.stop()
		print("ADMIN MODE ACTIVATED!")
		$AdminModeLabel.visible = true
		var adminModeLabelTimer = Timer.new()
		add_child(adminModeLabelTimer)
		adminModeLabelTimer.wait_time = 2.0
		adminModeLabelTimer.one_shot = true
		adminModeLabelTimer.timeout.connect(_on_admin_label_timer_timeout)
		adminModeLabelTimer.start()

func _on_admin_timer_timeout():
	adminButtonPressed = 0

func _on_admin_label_timer_timeout():
	$AdminModeLabel.visible = false
