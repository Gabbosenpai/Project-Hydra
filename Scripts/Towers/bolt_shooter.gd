extends Node2D

signal died(instance) 

@export var BULLET: PackedScene = null # Permette l'assegnazione della scena bullet nell'editor
@export var max_health = 100  # Salute massima 

var robots_coming = [] # Array con i robot identificati come bersaglio
var armed = false # Se true, la torretta spara
var riga: int # Riga della torretta nella griglia, inizializzata al piazzamento
var shoot_sfx = preload("res://Assets/Sound/SFX/8bit-hit-cut.mp3") # Effetto sonoro sparo del proiettile

# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var health = max_health
@onready var bulletOrigin = $BulletOrigin
@onready var rayCast = $RayCast2D # NON RIMUOVERE, FA FUNZIONARE IL TUTTO                 
@onready var towerSprite = $TowerSprite            
@onready var reloadTimer = $RayCast2D/ReloadTimer

func _process(_delta: float):
	robots_coming = get_valid_robots()  # Controlla se ci sono robot bersaglio
	armed = not robots_coming.is_empty() # True se ci sono robot bersaglio
	if reloadTimer.is_stopped() and armed: # Spara solo se ci sono bersagli e la torretta è carica
		shoot()
	elif towerSprite.animation != "shoot": # Non interrompere lo shoot a metà
		
		towerSprite.play("idle")

# Funzione per sparare un proiettile
func shoot():
	towerSprite.play("shoot")
	AudioManager.play_sfx(shoot_sfx)
	if BULLET:           # Controlla che la scena del proiettile sia assegnata
		var bullet: Node2D = BULLET.instantiate()  # Istanzia un nuovo bullet
		bullet.z_index = 5 # Fa passare il bullet sopra gli sprite
		get_tree().current_scene.add_child(bullet) # Aggiunge il proiettile come figlio della scena corrente, così è visibile
		bullet.global_position = bulletOrigin.global_position    # Il proiettile esce da BulletOrigin
	reloadTimer.start()   # Cooldown starts

func _on_reload_timer_timeout():
	rayCast.enabled = true  # NON RIMUOVERE, NON SO COSA FACCIA MA FA FUNZIONARE TUTTO

#Funzione che fa prendere danno allo sparatore
func take_damage(amount):
	health -= amount
	flash_bright()
	print("Tower HP:", health)
	if health < 0:
		health = 0
	if health == 0:
		die()

#Funzione di morte per ora il nemico viene solamente deallocato dalla scena 
func die():
	emit_signal("died", self) 
	queue_free()

# Ottiene tutti i robot validi che si trovano nella stessa riga e sono visibili
func get_valid_robots() -> Array:
	var all_robots = get_tree().get_nodes_in_group("Robot")  # Prende tutti i nodi nel gruppo "Robot"
	return all_robots.filter(is_valid_robot)                 # Filtra robot validi

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

func _on_tower_sprite_animation_finished() -> void:
	if towerSprite.animation == "shoot":
		towerSprite.play("idle") # Torna idle solo dopo aver finito lo sparo

# Modula lo sprite per dare feedback visivo
func flash_bright():
	towerSprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	towerSprite.modulate = Color(1, 1, 1) # Normale
