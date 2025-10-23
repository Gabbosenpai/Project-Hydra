extends baseLevel

var level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
var level1 = "res://Scenes/Levels/Lvl1.tscn"


func _ready():
	
	super._set_level_music(level_music)
	super.set_current_level(level1)
	super._ready()


# Logica di sblocco: sblocca il Livello 2
func _on_level_completed():
	AudioManager.play_victory_music()

	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 2:
		SaveManager.unlock_level(2)
		print("Livello 2 sbloccato!")
	get_tree().change_scene_to_file("res://Scenes/Utilities/tech_tree.tscn")
