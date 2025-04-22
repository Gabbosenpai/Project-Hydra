extends Area2D

@export var max_health := 10
var health := max_health

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health

func take_damage(amount):
	health -= amount
	$HealthBar.value = health
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate = Color.WHITE

	if health <= 0:
		get_node("/root/MainScene/UI/GameOverLabel").show()
