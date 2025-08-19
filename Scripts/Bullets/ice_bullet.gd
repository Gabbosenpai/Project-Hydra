extends Area2D

@export var speed := 400.0
@export var freeze_time := 2.0 # tempo in secondi di congelamento totale

var direction := Vector2.RIGHT

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("freeze"):
		body.freeze(freeze_time)
	queue_free()
