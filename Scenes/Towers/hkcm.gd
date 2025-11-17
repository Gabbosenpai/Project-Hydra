class_name HotKawaiiCoffeeMachine
extends Tower

# Permette l'assegnazione della scena bullet nell'editor
@export var hkcm_bullet: PackedScene 
@export var hkcm_max_health : int = 100  # Salute massima 
static var  hkcm_recharge_time : float = 8.0 # Tempo di ricarica 

# Effetto sonoro sparo del proiettile
<<<<<<< HEAD
var hkcm_shoot_sfx : AudioStream = preload("res://Assets/Sound/SFX/coffemachine.wav") 
=======
var hkcm_shoot_sfx : AudioStream = preload("res://Assets/Sound/SFX/coffeMachine.wav") 
>>>>>>> 3a24e795f99998222c47d500a50c58b5c55bdb55

func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare una torretta con valori nulli
	super.tower_set_up(hkcm_max_health, hkcm_bullet, hkcm_recharge_time
	, hkcm_shoot_sfx)
	super._ready()
