extends Control

var point_manager = preload("res://Scripts/Utility/point_manager.gd")
var bolt_shooter = preload("res://Scripts/Towers/bolt_shooter.gd")

@onready var TreeScrap: Label = $TreeScrap 


func _ready():
	update_slot_texts()


func update_slot_texts():
	TreeScrap.text = "Risorse disponibili: %d" % point_manager.get_total_points_for_current_slot()


func _on_next_level_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	
	var max_unlocked_level = SaveManager.get_max_unlocked_level()
	
	# Precarico la musica e cambio scena in base al livello max sbloccato
	var level_music : AudioStream = null
	var level_scene_path : String = ""
	
	match max_unlocked_level:
		1:
			level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl1.tscn"
		2:
			level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl2.tscn"
		3:
			level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
			level_scene_path = "res://Scenes/Levels/Lvl3.tscn"
		4:
			level_music = preload("res://Assets/Sound/OST/Jeremy Blake - Powerup!  NO COPYRIGHT 8-bit Music.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl4.tscn"
		5:
			level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl5.tscn"
		_:
			# Se non esiste un livello sbloccato valido, fai qualcosa (ad esempio torna al menu)
			get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
			return
	
	AudioManager.play_music(level_music)
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(level_scene_path)


func _on_back_to_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")


# Funzione di  prova
#	aumentiamo la velocita di fuoco del bolt shooter
#	per ora non c'è un limite se non i punti ma andrà
#	cambiata la condizione
func _on_upgrade_button_pressed() -> void:
	
	var current_total = point_manager.get_total_points_for_current_slot()
	
	if current_total >= 10:
		current_total -= 10
		point_manager.save_total_points_for_current_slot(current_total)
		TreeScrap.text = "Risorse disponibili: %d" % current_total
		
		bolt_shooter.bs_recharge_time -= 0.2
		print("Velocità di fuoco aumentata! Nuovo recharge_time: ", bolt_shooter.bs_recharge_time)
	else:
		print("Punti insufficienti per upgrade")
