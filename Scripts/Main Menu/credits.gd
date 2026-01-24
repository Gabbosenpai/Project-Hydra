extends Control

@onready var anim_player = $AnimationPlayer

#Funzione che inizializza i crediti
func _ready():
	var credits_music = preload("res://Assets/Sound/OST/Kevin MacLeod - Itty Bitty (CREDITS THEME).mp3")
	$Label.text = "MANCANO CREDITI OST CUTSCENE\n\n\n" + tr("menu_credits") + " OST\n" + "Quincas Moreira: Robot City\nCody O'Quinn: Scrub Slayer\nEpic Music Journey: 8 BIT RPG BATTLE\nAdventureChiptunes: NEW POWER\nHeatleyBros: 8 Bit Scrap!\nHeatleyBros: 8 BIT BOSS\nPix: A Lonely Cherry Tree\nAdam Haynes: 8-bit Victory Theme\nKevin MacLeod: Itty Bitty"
	AudioManager.play_music(credits_music) #Viene avviata la OST
	anim_player.play("ScorriCrediti")



#Funzione che rileva quando il pulsante per tonare al menu viene cliccato
func _on_back_to_menu_button_pressed() -> void:
	#AudioManager.play_sfx(AudioManager.button_click_sfx) #Viene avviata la OST del menu principale
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
