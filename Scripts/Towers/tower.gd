@abstract
class_name Tower
extends Area2D

# Nodi-Figlio della scena, inizializzati con onready perchè astratta
@onready var tower_sprite : AnimatedSprite2D = $TowerSprite
@onready var bullet_origin : Marker2D = $BulletOrigin
@onready var rayCast : RayCast2D = $RayCast2D # NON RIMUOVERE, FA FUNZIONARE IL TUTTO
@onready var reload_timer : Timer = $RayCast2D/ReloadTimer
@onready var tower_hitbox : CollisionShape2D = $TowerHitbox

# Variabili di un torretta standard
var robots_coming : Array # Array con i robot identificati come bersaglio
var armed : bool # Se true, la torretta spara
var riga : int # Riga della torretta nella griglia, inizializzata al piazzamento
var tower_current_health : int
var recharge_time : float
var max_health : int
var shoot_sfx : AudioStream
var BULLET: PackedScene
var turret_key: String = ""
var refund_percentage: float = 0.5
var scrap_scene : PackedScene = preload("res://Scenes/Utilities/Scrap.tscn")

# Segnali Custom
# Segnale di morte utilizzato per segnalare la morte della torretta 
# affinche la si possa rilevare ed eliminare dalle torrette presenti 
# evitando Null Pointer Exception
signal died(instance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Inizializzo variabili per tutti i tipi di torretta
	armed = false
	robots_coming = []
	tower_current_health = max_health
	reload_timer.wait_time = recharge_time
	reload_timer.one_shot = true
	# Connetto segnali
	tower_sprite.animation_finished.connect(_on_tower_sprite_animation_finished)
	reload_timer.timeout.connect(_on_reload_timer_timeout)

# Inizializzo variabili per tipologia di torretta
func tower_set_up(tower_max_health : int, tower_bullet : PackedScene, 
		tower_recharge_time: float, tower_shoot_sfx : AudioStream):
	max_health = tower_max_health
	BULLET = tower_bullet
	recharge_time = tower_recharge_time
	shoot_sfx = tower_shoot_sfx
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	robots_coming = get_valid_robots()  # Controlla se ci sono robot bersaglio
	armed = not robots_coming.is_empty() # True se ci sono robot bersaglio
	# Spara solo se ci sono bersagli e la torretta è carica
	if reload_timer.is_stopped() and armed: 
		shoot()
	elif tower_sprite.animation != "shoot": # Non interrompere lo shoot a metà
		tower_sprite.play("idle")

# Funzione per sparare un proiettile
func shoot():
	tower_sprite.play("shoot")
	AudioManager.play_sfx(shoot_sfx,true)
	if BULLET:           # Controlla che la scena del proiettile sia assegnata
		var bullet: Node2D = BULLET.instantiate()  # Istanzia un nuovo bullet
		bullet.z_index = 5 # Fa passare il bullet sopra gli sprite
		# Aggiunge il proiettile come figlio della scena corrente, così è visibile
		get_tree().current_scene.add_child(bullet) 
		# Il proiettile esce da BulletOrigin
		bullet.global_position = bullet_origin.global_position    
	reload_timer.start()   # Cooldown starts

#Funzione che fa prendere danno allo torretta
func take_damage(amount):
	tower_current_health -= amount
	flash_bright()
	print("Tower HP:", tower_current_health)
	if tower_current_health < 0:
		tower_current_health = 0
	if tower_current_health == 0:
		die()

#Funzione di morte per ora il nemico viene solamente deallocato dalla scena 
func die():
	emit_signal("died", self) 
	queue_free()

# Ottiene tutti i robot validi che si trovano nella stessa riga e sono visibili
func get_valid_robots() -> Array:
	# Prende tutti i nodi nel gruppo "Robot"
	var all_robots = get_tree().get_nodes_in_group("Robot") 
	# Filtra robot validi 
	return all_robots.filter(is_valid_robot)                 

# Controlla se un robot è un bersaglio valido: stessa riga e visibile sullo schermo
func is_valid_robot(robot: Node) -> bool:
	return is_same_row(robot) and is_robot_visible(robot)

# Controlla se il robot è nella stessa riga della torretta (attualmente sempre true)
func is_same_row(robot: Node) -> bool:
	return "riga" in robot and robot.riga == riga # Che sfaccimma vor di!? by Gabbo

# Controlla se il robot è visibile sullo schermo
func is_robot_visible(robot: Node) -> bool:
	return robot.is_on_screen()  # return true se visibile nella viewport

func set_riga(value: int) -> void:
	riga = value

# Modula lo sprite per dare feedback visivo
func flash_bright():
	tower_sprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	tower_sprite.modulate = Color(1, 1, 1) # Normale

func _on_tower_sprite_animation_finished() -> void:
	if tower_sprite.animation == "shoot":
		tower_sprite.play("idle") # Torna idle solo dopo aver finito lo sparo

func _on_reload_timer_timeout():
	rayCast.enabled = true  # NON RIMUOVERE, NON SO COSA FACCIA MA FA FUNZIONARE TUTTO

func spawn_scrap_on_incinerate() -> void:
	# 1. Trova il PointManager
	var pm = get_tree().get_first_node_in_group("PointManager")
	
	if pm and scrap_scene and turret_key != "":
		# Recupera i dati necessari dal PointManager
		var turret_costs = pm.turret_costs
		var incinerate_refund_percentage: float = pm.refund_percentage
		
		if turret_costs.has(turret_key):
			var cost = turret_costs[turret_key]
			# Calcola il valore fisso (50% del costo)
			var points_to_earn = int(cost * incinerate_refund_percentage) 
			
			if points_to_earn > 0:
				var scrap_instance = scrap_scene.instantiate()
				var scrap_sprite = scrap_instance.get_node_or_null("Sprite2D")
				if scrap_sprite:
					scrap_sprite.scale = Vector2(1.0, 1.0)
					
				# Aggiungi al nodo genitore (Main/Level)
				get_parent().call_deferred("add_child", scrap_instance)

				# Assegna la posizione globale e i valori
				scrap_instance.global_position = global_position
				scrap_instance.scrap_value = points_to_earn
				scrap_instance.point_manager = pm
				scrap_instance.z_index = 100 
				
				print("Scrap Torretta (", points_to_earn, ") generato dall'inceneritore.")
