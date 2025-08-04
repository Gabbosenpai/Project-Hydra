extends Node2D

signal enemy_defeated

var speed := 40  # velocità in pixel al secondo

func _physics_process(delta):
	position.x -= speed * delta  # movimento semplice verso sinistra

func die():
	emit_signal("enemy_defeated")
	queue_free()
