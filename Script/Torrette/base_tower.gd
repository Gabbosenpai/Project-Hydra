extends Node2D

@export var BULLET: PackedScene = null # Permette l'assegnazione della scena bullet nell'editor
@export var max_health = 100 

var robots_coming = [] # Array con i robot identificati come bersaglio
var armed = false # Se true, la torretta spara
var riga: int # Riga della torretta nella griglia, inizializzata al piazzamento

# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var health = max_health
@onready var bulletOrigin = $BulletOrigin
@onready var rayCast = $RayCast2D # NON RIMUOVERE, FA FUNZIONARE IL TUTTO                 
@onready var towerSprite = $TowerSprite            
@onready var reloadTimer = $RayCast2D/ReloadTimer

# Funzione per sparare un proiettile
func shoot():
	$TowerSprite.play()  # Avvia l'animazione
	if BULLET:           # Controlla che la scena del proiettile sia assegnata
		var bullet: Node2D = BULLET.instantiate()  # Istanzia un nuovo proiettile dalla scena PackedScene
		get_tree().current_scene.add_child(bullet) # Aggiunge il proiettile come figlio della scena corrente, così è visibile
		bullet.global_position = bulletOrigin.global_position    # Posiziona il proiettile nella posizione globale della torretta
	reloadTimer.start()   # Avvia il timer di ricarica per evitare spari continui

# Funzione chiamata quando il timer di ricarica termina
func _on_reload_timer_timeout():
	rayCast.enabled = true  # Riabilita il raycast per rilevare nuovi robot

# Funzione di processo chiamata ogni frame
func _process(_delta: float):
	robots_coming = get_valid_robots()  # Ottiene la lista aggiornata dei robot validi minacciosi
	armed = not robots_coming.is_empty() # Se ci sono robot validi, la torretta è armata (pronta a sparare)

	# Se il timer di ricarica è fermo (quindi pronto a sparare) e la torretta è armata, spara
	if reloadTimer.is_stopped() and armed:
		shoot()

func take_damage(amount):
	health -= amount
	print("Tower HP:", health)
	if health < 0:
		health = 0
	if health == 0:
		die()

func die():
	queue_free()

# Ottiene tutti i robot validi che si trovano nella stessa riga e sono visibili
func get_valid_robots() -> Array:
	var all_robots = get_tree().get_nodes_in_group("Robot")  # Prende tutti i nodi nel gruppo "Robot"
	return all_robots.filter(is_valid_robot)                 # Filtra quelli validi secondo la funzione is_valid_robot

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
