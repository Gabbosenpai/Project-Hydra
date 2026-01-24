extends Control

# Prendiamo i bottoni dei livelli
@onready var level_1: TextureButton = $Level1
@onready var level_2: TextureButton = $Level2
@onready var level_3: TextureButton = $Level3
@onready var level_4: TextureButton = $Level4
@onready var level_5: TextureButton = $Level5
@onready var blink_timer: Timer = $BlinkTimer

var blink: bool = false
var lvl_done = preload("res://Assets/Sprites/UI/Menu/Small Confirm Button Pressed.png")
var lvl_blocked = preload("res://Assets/Sprites/UI/Menu/Small Confirm Button Not Pressed.png")


func _ready():
	# Disattiva bottone se il max unlocked è minore del numero del livello
	# massimo livello sbloccato 
	var max_unlocked_level: int = SaveManager.get_max_unlocked_level()
	level_2.disabled = max_unlocked_level < 2
	level_3.disabled = max_unlocked_level < 3
	level_4.disabled = max_unlocked_level < 4
	level_5.disabled = max_unlocked_level < 5
	# Suona la musica di selezione solo se diversa
	var selection_music = preload("res://Assets/Sound/OST/Quincas Moreira - Robot City ♫ NO COPYRIGHT 8-bit Music (MENU AUDIO).mp3")
	if AudioManager.music_player.stream != selection_music:
		AudioManager.play_music(selection_music)
	refresh_select_lvl_ui(max_unlocked_level)


func check_lvl():
	var max_lvl: int = SaveManager.get_max_unlocked_level()
	match max_lvl:
		1:
			if blink:
				level_1.texture_normal = lvl_blocked
				blink = false
			else:
				level_1.texture_normal = lvl_done
				blink = true
		2:
			if blink:
				level_2.texture_normal = lvl_blocked
				blink = false
			else:
				level_2.texture_normal = lvl_done
				blink = true
		3:
			if blink:
				level_3.texture_normal = lvl_blocked
				blink = false
			else:
				level_3.texture_normal = lvl_done
				blink = true
		4:
			if blink:
				level_4.texture_normal = lvl_blocked
				blink = false
			else:
				level_4.texture_normal = lvl_done
				blink = true
		5:
			if blink:
				level_5.texture_normal = lvl_blocked
				blink = false
			else:
				level_5.texture_normal = lvl_done
				blink = true


func refresh_select_lvl_ui(max_lvl):
	match max_lvl:
		1:
			pass
		2:
			level_1.texture_normal = lvl_done
			level_1.texture_pressed = lvl_blocked
		3:
			level_1.texture_normal = lvl_done
			level_1.texture_pressed = lvl_blocked
			level_2.texture_normal = lvl_done
			level_2.texture_pressed = lvl_blocked
		4:
			level_1.texture_normal = lvl_done
			level_1.texture_pressed = lvl_blocked
			level_2.texture_normal = lvl_done
			level_2.texture_pressed = lvl_blocked
			level_3.texture_normal = lvl_done
			level_3.texture_pressed = lvl_blocked
		5:
			level_1.texture_normal = lvl_done
			level_1.texture_pressed = lvl_blocked
			level_2.texture_normal = lvl_done
			level_2.texture_pressed = lvl_blocked
			level_3.texture_normal = lvl_done
			level_3.texture_pressed = lvl_blocked
			level_4.texture_normal = lvl_done
			level_4.texture_pressed = lvl_blocked
		6:
			level_1.texture_normal = lvl_done
			level_1.texture_pressed = lvl_blocked
			level_2.texture_normal = lvl_done
			level_2.texture_pressed = lvl_blocked
			level_3.texture_normal = lvl_done
			level_3.texture_pressed = lvl_blocked
			level_4.texture_normal = lvl_done
			level_4.texture_pressed = lvl_blocked
			level_5.texture_normal = lvl_done
			level_5.texture_pressed = lvl_blocked


func _on_level_1_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	#var level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
	#AudioManager.play_music(level_music)
	
	# Aspetta la fine del click con un breve timer
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Lvl1.tscn")


# Musica da scegliere
func _on_level_2_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	#var level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
	#AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Lvl2.tscn")


func _on_level_3_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	#var level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
	#AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Lvl3.tscn")


func _on_level_4_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	#var level_music = preload("res://Assets/Sound/OST/Jeremy Blake - Powerup!  NO COPYRIGHT 8-bit Music.mp3")
	#AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Lvl4.tscn")


func _on_level_5_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	#var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
	#AudioManager.play_music(level_music)
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Lvl5.tscn")


func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/slot_selection.tscn")


func _on_blink_timer_timeout() -> void:
	check_lvl()
