extends baseLevel

var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
var level2 = "res://Scenes/Levels/Lvl2.tscn"

func _ready():
	super._set_level_music(level_music)
	super.set_current_level(level2)
	super._ready()
	


func _on_level_completed():
	AudioManager.play_victory_music()

	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 3:
		SaveManager.unlock_level(3)
		print("Livello 3 sbloccato!")
	get_tree().change_scene_to_file("res://Scenes/Utilities/tech_tree.tscn")
