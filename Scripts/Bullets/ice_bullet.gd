extends Area2D

@export var speed := 400.0
@export var freeze_time := 20.0 # tempo in secondi di congelamento totale

var direction := Vector2.RIGHT

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		return
	if area.has_method("freeze"):
		area.freeze(freeze_time)
	queue_free()
