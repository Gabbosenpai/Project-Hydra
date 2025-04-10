extends Area2D

var speed = 200

func _physics_process(delta):
	var movement = Vector2.RIGHT * speed * delta
	global_position += movement


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	#if body.is_in_group("Robots"):
	queue_free()
