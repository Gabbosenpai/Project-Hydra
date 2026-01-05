extends baseLevel

var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
var level5 = "res://Scenes/Levels/Lvl5.tscn"

func _ready():
	super._set_level_music(level_music)
	super.set_current_level(level5)
	super._ready()

func _on_level_completed():
	AudioManager.play_victory_music()
	# Stato logico: gioco completato
	if SaveManager.get_max_unlocked_level() < 6:
		SaveManager.unlock_level(6)
		print("Progressione completa (6) sbloccata!")
