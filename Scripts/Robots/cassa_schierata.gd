class_name CassaSchierata
extends Robot

@export var cs_max_health : int = 100
@export var cs_speed : float = 40
@export var cs_damage : int = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare un robot con valori nulli
	super.robot_set_up(cs_max_health, cs_speed, cs_damage)
	super._ready()

# Un Romba si muove solo se vivo e non sta attacando
func can_move() -> bool:
	return !violence and current_health > 0
