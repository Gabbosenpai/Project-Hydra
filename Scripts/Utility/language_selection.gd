extends Control

@onready var italian_button = $ItalianoButton
@onready var english_button = $EnglishButton
@onready var chinese_button = $ChineseButton

#fondamentale per funzionare bene
static var first_time := true   

func _ready():
	
	# all'avvio
	if first_time:
		TranslationServer.set_locale("en")
		first_time = false

	# aggiorna i pulsanti in base alla lingua attuale
	_update_buttons()


func _update_buttons():
	var locale = TranslationServer.get_locale()

	italian_button.set_pressed(locale == "it")
	english_button.set_pressed(locale == "en")
	chinese_button.set_pressed(locale == "zh")


func _on_italiano_button_pressed():
	TranslationServer.set_locale("it")
	_update_buttons()
	AudioManager.play_sfx(AudioManager.button_click_sfx)


func _on_english_button_pressed():
	TranslationServer.set_locale("en")
	_update_buttons()
	AudioManager.play_sfx(AudioManager.button_click_sfx)


func _on_chinese_button_pressed():
	TranslationServer.set_locale("zh")
	_update_buttons()
	AudioManager.play_sfx(AudioManager.button_click_sfx)


func _on_back_to_menu_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
