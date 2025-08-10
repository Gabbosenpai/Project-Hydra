extends Control

signal start_wave
signal kill_all
signal select_plant(plant_key)
signal remove_mode
@export var pause_button: TextureButton
@export var pause_menu : Panel

func _on_button_remove_pressed():
	emit_signal("remove_mode")

func _on_button_plant_1_pressed():
	emit_signal("select_plant", "plant1")

func _on_button_plant_2_pressed():
	emit_signal("select_plant", "plant2")

func _on_button_plant_3_pressed():
	emit_signal("select_plant", "plant3")

func _on_button_plant_4_pressed():
	emit_signal("select_plant", "plant4")

func _on_start_wave_button_pressed():
	emit_signal("start_wave")

func _on_button_kill_all_pressed():
	emit_signal("kill_all")


func _on_pause_button_pressed():
	get_tree().paused = true
	pause_menu.visible = true
	pause_button.visible = false

func _on_resume_button_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	pause_button.visible = true

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
