extends StaticBody2D  # Estende StaticBody2D, quindi questo nodo è statico e parte della fisica

# Variabili della salute
var health_max = 500       # Salute massima della torre
var health_current = 500   # Salute attuale della torre

# Riferimento alla barra della salute nell'albero dei nodi
@onready var barra_salute = $Sprite2D/BarraSalute

# Funzione chiamata all'avvio del nodo
func _ready() -> void:
	aggiorna_barra_salute()  # Imposta il valore iniziale della barra della salute

# Funzione per subire danno
func take_damage(danno: int):
	health_current -= danno  # Riduce la salute attuale
	print("🏰 Torre ha subito", danno, "danno. Salute attuale:", health_current)
	aggiorna_barra_salute()  # Aggiorna la barra dopo il danno
	
	if health_current <= 0:  # Se la salute è finita, distruggi la torre
		die()

# Aggiorna la barra della salute
func aggiorna_barra_salute():
	if barra_salute:
		barra_salute.max_value = health_max
		barra_salute.value = health_current

# Funzione di distruzione della torre
func die():
	print("💥 Torre distrutta!")
	var main = get_tree().current_scene  # Ottiene la scena attuale
	print("Scena corrente:", main.name)
	if main and main.has_method("game_over"):  # Se la scena ha il metodo game_over, lo chiama
		main.game_over()
	queue_free()  # Rimuove la torre dalla scena
