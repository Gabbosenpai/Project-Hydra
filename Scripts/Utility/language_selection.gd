extends Control

@onready var italian_button = $ItalianoButton
@onready var english_button = $EnglishButton

func _ready():
	# lingua predefinita 
	TranslationServer.set_locale("it")
	

func _on_italiano_button_pressed():
	TranslationServer.set_locale("it")

func _on_english_button_pressed():
	TranslationServer.set_locale("en")



	


func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
