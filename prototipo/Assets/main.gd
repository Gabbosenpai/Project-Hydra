extends Node2D

@onready var game_over_label= $"CanvasLayer/Game Over"
@onready var retry_button = $CanvasLayer/Riprova


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All'inizio nascondiamo tutto
	game_over_label.visible = false
	retry_button.visible = false
	retry_button.pressed.connect(_on_retry_pressed)

func game_over():
	# Quando chiamato, mostra la scritta e il pulsante
	game_over_label.visible = true
	retry_button.visible = true
	get_tree().paused = true  # Pausa il gioco

func _on_retry_pressed():
	print("🔄 Bottone RIPROVA premuto")
	get_tree().paused = false
	get_tree().reload_current_scene()  # Ricarica la scena corrente

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
