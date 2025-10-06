class_name JammerCannon
extends Tower

@export var tower_bullet: PackedScene # Permette l'assegnazione della scena bullet nell'editor
@export var tower_max_health : int = 100 

var tower_shoot_sfx : AudioStreamMP3 = preload("res://Assets/Sound/SFX/Robotic-shoot-cut.mp3")

func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare una torretta con valori nulli
	super.tower_set_up(tower_max_health, tower_bullet, tower_shoot_sfx)
	super._ready()
