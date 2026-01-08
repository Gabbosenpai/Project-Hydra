class_name ToiletSilo
extends Tower

# Permette l'assegnazione della scena bullet nell'editor
@export var ts_bullet: PackedScene 
@export var ts_max_health: int = 75  # Salute massima 
@export var ts_recharge_time: float = 10.0 # Tempo di ricarica 

# Effetto sonoro sparo del proiettile
var ts_shoot_sfx: AudioStream = preload("res://Assets/Sound/SFX/flush.mp3") 


func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare una torretta con valori nulli
	super.tower_set_up(ts_max_health, ts_bullet, ts_recharge_time ,ts_shoot_sfx)
	super._ready()
