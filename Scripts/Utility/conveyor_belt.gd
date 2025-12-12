extends Node2D

# Variabili che riceveremo dal GridInitializer
var grid_initializer: Node2D = null
var cell_position: Vector2i
var next_phase: int
var animation_name: String

@onready var step_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blast_sprite: AnimatedSprite2D = $Blast


func _ready():
	if animation_name == "blast":
		# Se l'animazione è 'blast', usiamo la sprite Blast e la rendiamo visibile
		blast_sprite.visible = true
		blast_sprite.play("blast")
		
		# Connettiamo il segnale di fine animazione dal nodo Blast
		blast_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	else:
		# Se l'animazione è movimento, usiamo la sprite principale
		blast_sprite.visible = false
		step_sprite.play(animation_name)
		
		# Connettiamo il segnale di fine animazione dal nodo AnimatedSprite2D
		step_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))


func _on_animation_finished():
	if animation_name == "blast":
		# Se l'animazione è 'blast', la pulizia della TileMap e il ripristino
		# sono gestiti dal GridInitializer, quindi solo il nodo deve liberarsi.
		queue_free()
	# 1. Chiama la funzione di aggiornamento sulla TileMap di base
	if grid_initializer and is_instance_valid(grid_initializer):
		grid_initializer.update_tilemap_base(cell_position, next_phase)
	# 2. Rimuovi il nodo animato temporaneo (lo step è finito)
	queue_free()
