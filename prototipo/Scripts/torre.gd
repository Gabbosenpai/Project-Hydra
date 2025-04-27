extends StaticBody2D

# Variabili della salute
var health_max = 500
var health_current = 500

# Riferimento alla barra della salute
@onready var barra_salute = $Sprite2D/BarraSalute

func _ready() -> void:
	aggiorna_barra_salute()

func take_damage(danno: int):
	health_current -= danno
	print("🏰 Torre ha subito", danno, "danno. Salute attuale:", health_current)
	aggiorna_barra_salute()
	
	if health_current <= 0:
		die()

func aggiorna_barra_salute():
	if barra_salute:
		barra_salute.max_value = health_max
		barra_salute.value = health_current

func die():
	print("💥 Torre distrutta!")
	print("💥 Torre distrutta!")
	var main = get_tree().current_scene
	print("Scena corrente:", main.name)  # Questo ti dirà il nome della scena
	if main and main.has_method("game_over"):
		main.game_over()
	queue_free()
