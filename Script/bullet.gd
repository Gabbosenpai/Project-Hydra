extends Area2D

@export var speed: float = 400.0

func _process(delta):
	#movimento verso destra
	position.x += speed * delta

func _on_area_entered(area: Area2D):
	if area.is_in_group("Enemy"):
		if area.has_method("take_damage"):
			area.take_damage(50)  # Ogni proiettile fa 1 danno
		queue_free()  # Distruggi il proiettile
