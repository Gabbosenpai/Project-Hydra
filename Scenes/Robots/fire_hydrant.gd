class_name FireHydrant
extends Robot

@export var fh_max_health : int = 100
@export var fh_speed : float = 45
@export var fh_damage : int = 10

# Called when the node enters the scene tree for pthe first time.
func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare un robot con valori nulli
	super.robot_set_up(fh_max_health, fh_speed, fh_damage)
	super._ready()

func can_move() -> bool:
	return !violence and current_health > 0
