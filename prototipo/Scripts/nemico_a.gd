extends CharacterBody2D  # Il nodo principale del nemico è un CharacterBody2D, usato per il movimento

# Variabili per la velocità e la salute
var velocita = 100
var health_max = 100
var health_current = 100

# Riferimenti ai nodi figli
@onready var barra = $Sprite2D/BarraSalute  # La barra della salute è un nodo ProgressBar figlio di Sprite2D
@onready var area_rilevamento = $Area2D  # Area2D usata per rilevare proiettili o altri oggetti
@onready var collisione = $Area2D/CollisionShape2D  # CollisionShape2D che definisce la forma dell'area

func _ready() -> void:
	update_health_bar()  # Imposta la barra salute iniziale

func _process(delta: float) -> void:
	# Se il nemico è ancora vivo, si muove verso sinistra
	if health_current > 0:
		position.x -= velocita * delta
		print("Posizione nemico aggiornata a:", position.x)

# Aggiorna graficamente la barra della salute
func update_health_bar():
	barra.max_value = health_max
	barra.value = health_current
	print("Barra salute aggiornata. Salute: ", health_current)

# Quando il nemico prende danno
func take_damage(danno: int):
	health_current -= danno  # Riduce la salute
	update_health_bar()  # Aggiorna la barra visiva
	print("Il nemico ha ricevuto", danno, "danno. Salute rimanente:", health_current)

	if health_current <= 0:
		die()  # Se la salute è finita, il nemico muore

# Elimina il nemico dalla scena
func die():
	print("☠️ Nemico eliminato. Salute a zero.")
	queue_free()

# Funzione chiamata quando un corpo entra nell'Area2D del nemico
func _on_body_entered(body: Node) -> void:
	print("Corpo entrato nell'area di rilevamento:", body.name)
	if body.is_in_group("Proiettile"):  # Se è un proiettile, infligge danno
		print("Proiettile rilevato! Infliggi danno.")
		take_damage(20)

# Funzione chiamata quando un corpo esce dall'Area2D del nemico
func _on_body_exited(body: Node) -> void:
	print("Corpo uscito dall'area di rilevamento:", body.name)
	if body.is_in_group("Proiettile"):
		print("Proiettile uscito dall'area.")  # (Opzionale: solo per debug)
