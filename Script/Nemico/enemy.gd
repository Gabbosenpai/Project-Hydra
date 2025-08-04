extends Node2D

signal enemy_defeated

@export var health := 10
var speed := 40  # velocità in pixel al secondo

func _physics_process(delta):
	position.x -= speed * delta

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func is_on_screen() -> bool:
	return $VisibleOnScreenNotifier2D.is_on_screen()


func die():
	emit_signal("enemy_defeated")
	queue_free()
