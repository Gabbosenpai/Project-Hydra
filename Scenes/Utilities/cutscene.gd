extends Node

var concluso: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	concluso = true

func go_to_lvl_sel():
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		#if not concluso:
		salta_intro()

func salta_intro():
	animation_player.advance(10.0)
