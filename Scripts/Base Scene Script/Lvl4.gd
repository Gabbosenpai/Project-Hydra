extends baseLevel

var level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
var level4 = "res://Scenes/Levels/Lvl4.tscn"
var point_manager = preload("res://Scripts/Utility/point_manager.gd")

func _ready():
	super._set_level_music(level_music)
	super.set_current_level(level4)
	super._ready()
	
	

func _on_level_completed():
	AudioManager.play_victory_music()

	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 5:
		SaveManager.unlock_level(5)
		print("Livello 5 sbloccato!")
	# Aggiungi i punti del livello al totale TechTree
	var level_points = point_manager.current_points
	point_manager.add_level_points_to_total(level_points)
	get_tree().change_scene_to_file("res://Scenes/Utilities/tech_tree.tscn")
