extends Area2D 

@export var bullet_speed = 100          
@export var bullet_damage = 5 

func _physics_process(delta):
	var movement = Vector2.RIGHT * bullet_speed * delta
	global_position += movement

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D):
	var enemy_node = area.get_parent()
	if enemy_node.is_in_group("Robot") and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(bullet_damage)
		queue_free() # Bullet viene distrutto quando colpisce un robot
