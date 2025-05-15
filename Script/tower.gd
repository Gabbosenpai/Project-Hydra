extends Area2D

@export var max_health: int = 100
var current_health: int

@onready var health_bar = $ProgressBar

func _ready():
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health

	if current_health == 0:
		# Diciamo a tutti i nemici di smettere di attaccare
		get_tree().call_group("Enemy", "stop_attacking")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scene/gameover.tscn")
