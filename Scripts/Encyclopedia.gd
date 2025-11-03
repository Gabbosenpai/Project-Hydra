extends Control

@onready var desc = $MonsterDescription

func ready():
	desc.visible = false

func show_description(text):
	desc.text = text
	desc.visible = true
	desc.position = get_viewport_rect().size / 2 - desc.size / 2
	
func hide_description():
	desc.visible = false


func _on_back_to_menu_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

func _on_bolt_shooter_pressed() -> void:
	show_description("Questo è il Bolt Shooter!")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_description()
