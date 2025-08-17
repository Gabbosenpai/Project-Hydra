extends Area2D  # Estende la classe Area2D, quindi questo script è per un nodo Area2D (ad esempio un proiettile)

# Variabili esportate per poterle modificare facilmente dall'editor di Godot
@export var speed = 200          # Velocità del proiettile
@export var bullet_damage = 10    # Danno che il proiettile infligge agli nemici

@onready var bulletSprite = $BulletSprite

# Funzione chiamata ad ogni frame fisico (numero fisso di frame al secondo)
func _physics_process(delta):
	# Calcola il movimento in base alla direzione a destra, alla velocità e al tempo trascorso (delta)
	var movement = Vector2.RIGHT * speed * delta
	bulletSprite.play("travel")
	# Aggiorna la posizione globale del proiettile spostandolo in avanti
	global_position += movement

# Funzione chiamata quando il nodo esce dallo schermo (usando un VisibleOnScreenNotifier2D collegato)
func _on_visible_on_screen_notifier_2d_screen_exited():
	# Distrugge il nodo, liberando la memoria e rimuovendo il proiettile
	queue_free()

# Funzione chiamata quando questo Area2D entra in collisione con un altro Area2D
func _on_area_entered(area: Area2D):
	# Ottiene il nodo genitore dell'area entrata in collisione (di solito l'enemy)
	var enemy_node = area.get_parent()
	
	# Controlla se il nodo genitore appartiene al gruppo "Robot" e ha il metodo "take_damage"
	if enemy_node.is_in_group("Robot") and enemy_node.has_method("take_damage"):
		# Chiama la funzione take_damage sull'enemy, passando il valore del danno del proiettile
		enemy_node.take_damage(bullet_damage)
		
		# Dopo aver colpito l'enemy, il proiettile si distrugge
		queue_free()
