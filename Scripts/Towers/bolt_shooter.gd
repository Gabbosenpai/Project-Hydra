class_name BoltShooter
extends Tower

# Permette l'assegnazione della scena bullet nell'editor
@export var bs_bullet: PackedScene 
@export var bs_max_health : int = 100  # Salute massima 
@export var bs_recharge_time : float = 2.5 # Tempo di ricarica 

# Effetto sonoro sparo del proiettile
var bs_shoot_sfx : AudioStream = preload("res://Assets/Sound/SFX/explosion.wav") 

func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare una torretta con valori nulli
	super.tower_set_up(bs_max_health, bs_bullet, bs_recharge_time ,bs_shoot_sfx)
	super._ready()
