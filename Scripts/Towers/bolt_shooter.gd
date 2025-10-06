class_name BoltShooter
extends Tower

@export var bs_bullet: PackedScene # Permette l'assegnazione della scena bullet nell'editor
@export var bs_max_health : int = 100  # Salute massima 

# Effetto sonoro sparo del proiettile
var bs_shoot_sfx : AudioStream = preload("res://Assets/Sound/SFX/explosion.wav") 

func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare una torretta con valori nulli
	super.tower_set_up(bs_max_health, bs_bullet, bs_shoot_sfx)
	super._ready()
