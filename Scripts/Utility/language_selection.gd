extends Control

@onready var italian_button = $ItalianoButton
@onready var english_button = $EnglishButton
@onready var chinese_button = $ChineseButton
func _ready():
	# lingua predefinita
	TranslationServer.set_locale("it")
	italian_button.set_pressed(true)  

func _on_italiano_button_pressed():
	
	italian_button.set_pressed(true)
	english_button.set_pressed(false)
	chinese_button.set_pressed(false)
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	TranslationServer.set_locale("it")

func _on_english_button_pressed():
	
	english_button.set_pressed(true)
	italian_button.set_pressed(false)
	chinese_button.set_pressed(false)
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	TranslationServer.set_locale("en")


func _on_chinese_button_pressed() -> void:
	
	chinese_button.set_pressed(true)
	italian_button.set_pressed(false)
	english_button.set_pressed(false)
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	TranslationServer.set_locale("zh")


func _on_back_to_menu_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
