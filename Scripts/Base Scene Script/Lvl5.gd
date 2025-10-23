extends baseLevel

var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
var level5 = "res://Scenes/Levels/Lvl5.tscn"

func _ready():
	super._set_level_music(level_music)
	super.set_current_level(level5)
	super._ready()
