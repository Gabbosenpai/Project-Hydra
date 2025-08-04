extends Node2D  # Estende Node2D, quindi questo script è associato a un nodo 2D generico (ad esempio una torretta)

# Variabile esportata per assegnare dal editor una scena PackedScene del proiettile
@export var BULLET: PackedScene = null

# Lista dei robot che stanno arrivando (minacce attive)
var robots_coming = []

# Stato se la torretta è pronta a sparare o no
var armed = false

# Variabile che indica la riga in cui si trova la torretta (non usata in questo codice, ma utile per logica di fila)
var riga

# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var rayCast = $RayCast2D                  # Riferimento al nodo RayCast2D, usato per il rilevamento
@onready var towerSprite = $TowerSprite            # Riferimento allo sprite animato della torretta
@onready var reloadTimer = $RayCast2D/ReloadTimer # Timer per la ricarica, figlio del RayCast2D

# Funzione per sparare un proiettile
func shoot():
	$TowerSprite.play()  # Avvia l'animazione dello sprite della torretta
	if BULLET:           # Controlla che la scena del proiettile sia assegnata
		var bullet: Node2D = BULLET.instantiate()  # Istanzia un nuovo proiettile dalla scena PackedScene
		get_tree().current_scene.add_child(bullet) # Aggiunge il proiettile come figlio della scena corrente, così è visibile
		bullet.global_position = global_position    # Posiziona il proiettile nella posizione globale della torretta
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

# 🔹 Ottiene tutti i robot validi che si trovano nella stessa riga e sono visibili
func get_valid_robots() -> Array:
	var all_robots = get_tree().get_nodes_in_group("Robot")  # Prende tutti i nodi nel gruppo "Robot"
	return all_robots.filter(is_valid_robot)                 # Filtra quelli validi secondo la funzione is_valid_robot

# 🔹 Controlla se un singolo robot è valido per questa torretta
func is_valid_robot(robot: Node) -> bool:
	return is_same_row(robot) and is_robot_visible(robot)    # Deve essere nella stessa riga e visibile

# Controlla se il robot è nella stessa riga della torretta (attualmente sempre true)
func is_same_row(robot: Node) -> bool:
	# Se vuoi, puoi usare la variabile "riga" per controllare la fila esatta
	# return robot.riga == riga
	return true  # Per ora ignora la riga e considera tutti validi

# Controlla se il robot è attualmente visibile sullo schermo
func is_robot_visible(robot: Node) -> bool:
	return robot.is_on_screen()  # Ritorna true se il robot è visibile nella viewport
