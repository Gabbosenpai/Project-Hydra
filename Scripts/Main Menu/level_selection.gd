extends Control

#tutto da aggiornare con gli altri 4 livelli

func _on_level_1_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
	AudioManager.play_music(level_music)
	#aspetta la fine del click con un breve timer
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")

#musica da scegliere
func _on_level_2_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
	AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout

# Asset Mancante
func _on_level_3_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
	AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout
	
	
func _on_level_4_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var level_music = preload("res://Assets/Sound/OST/Jeremy Blake - Powerup!  NO COPYRIGHT 8-bit Music.mp3")
	AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout
	
	
func _on_level_5_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
	AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
