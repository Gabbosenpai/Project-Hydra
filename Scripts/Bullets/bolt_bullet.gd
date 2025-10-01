extends Area2D  

@export var speed = 200          # Velocità del proiettile
@export var bullet_damage = 10    # Danno che il proiettile infligge agli nemici

@onready var bulletSprite = $BulletSprite #Sprite del Proiettile

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

# Funzione che controlla se il proiettile è entrato nell'area del nemico
func _on_area_entered(area: Area2D):
	var enemy_node = area.get_parent()
	
	# Controlla se il nodo genitore appartiene al gruppo "Robot" e ha il metodo "take_damage"
	if enemy_node.is_in_group("Robot") and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(bullet_damage) #Se nell'area fa danno al nemico
		
		# Dopo aver colpito il nemico, il proiettile si distrugge
		queue_free()
