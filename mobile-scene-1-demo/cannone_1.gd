extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 1
var fire_timer := 0.0

func _process(delta):
	fire_timer -= delta
	if fire_timer <= 0:
		fire_timer = fire_rate
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.rotation = rotation
	get_tree().get_current_scene().add_child(bullet)
