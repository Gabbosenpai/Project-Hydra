extends Control

@onready var anim_player = $AnimationPlayer

#Funzione che inizializza i crediti
func _ready():
	var credits_music = preload("res://Assets/Sound/OST/Kevin MacLeod - Itty Bitty (CREDITS THEME).mp3")

	var credits_text := "OST" + "\n"
	credits_text += "Quincas Moreira – Robot City\nCody O'Quinn – Scrub Slayer\n"
	credits_text += "Epic Music Journey – 8 BIT RPG BATTLE\nAdventureChiptunes – NEW POWER\n"
	credits_text += "HeatleyBros – 8 Bit Scrap!\nHeatleyBros – 8 BIT BOSS\n"
	credits_text += "Pix – A Lonely Cherry Tree\nAdam Haynes – 8-bit Victory Theme\nKevin MacLeod – Itty Bitty\n"
	credits_text += "Party's Cancelled - RoccoW ｜ Chiptune\n\n"
	
	credits_text += tr("UI_design")+"\n"
	credits_text += "da completare\n\n"
	
	credits_text += tr("monster_design")+"\n"
	credits_text += "da completare\n\n"
	
	credits_text += tr("programming")+"\n"
	credits_text += "da completare\n\n"
	
	credits_text += tr("balancing_testing")+"\n"
	credits_text += "da completare\n\n"
	
	
	
	
	
	$Label.text = credits_text

	AudioManager.play_music(credits_music)
	anim_player.play("ScorriCrediti")


#Funzione che rileva quando il pulsante per tonare al menu viene cliccato
func _on_back_to_menu_button_pressed() -> void:
	#AudioManager.play_sfx(AudioManager.button_click_sfx) #Viene avviata la OST del menu principale
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
