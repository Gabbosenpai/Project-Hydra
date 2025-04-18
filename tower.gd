extends Area2D

@export var max_health: int = 100
@onready var current_health: int = max_health
@onready var health_bar = $ProgressBar

func _ready():
	health_bar.max_value = max_health
	health_bar.value = current_health

func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health  # 🔥 aggiorna la barra

	if current_health == 0:
		await get_tree().create_timer(0.5).timeout  # Attendi mezzo secondo prima di cambiare scena (opzionale)
		get_tree().change_scene_to_file("res://gameover.tscn")
