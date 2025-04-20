extends Area2D

var speed = 200

func _physics_process(delta):
	var movement = Vector2.RIGHT * speed * delta
	global_position += movement


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Robot"):
		queue_free()
