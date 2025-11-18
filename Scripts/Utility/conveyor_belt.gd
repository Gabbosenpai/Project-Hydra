extends Node2D

@onready var step_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Variabili che riceveremo dal GridInitializer
var grid_initializer: Node2D = null
var cell_position: Vector2i
var next_phase: int
var animation_name: String

func _ready():
	# Connetti il segnale per la pulizia e l'aggiornamento della TileMap
	step_sprite.animation_finished.connect(_on_animation_finished)
	
	# Avvia l'animazione dinamica
	step_sprite.play(animation_name)

func _on_animation_finished():
	# 1. Chiama la funzione di aggiornamento sulla TileMap di base
	if grid_initializer and is_instance_valid(grid_initializer):
		grid_initializer.update_tilemap_base(cell_position, next_phase)
		
	# 2. Rimuovi il nodo animato temporaneo (lo step è finito)
	queue_free()
