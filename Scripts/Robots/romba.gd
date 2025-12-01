class_name Romba
extends Robot

@export var romba_max_health: int = 100
@export var romba_speed: float = 50
@export var romba_damage: int = 25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare un robot con valori nulli
	super.robot_set_up(romba_max_health, romba_speed, romba_damage)
	super._ready()


# Un Romba si muove solo se vivo e non sta attacando
func can_move() -> bool:
	return !violence and current_health > 0
