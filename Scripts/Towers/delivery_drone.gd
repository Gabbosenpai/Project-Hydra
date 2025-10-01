extends Node2D

@export var max_health = 100 # Salute massima

var riga: int # Riga della torretta nella griglia, inizializzata al piazzamento
var dropPadPosition # Posizione di scarico 
var dronePosition   # Posizione del drone
var droneStartingPosition  # Posizione iniziale del drone
var current_animation      # Animazione corrente
var drop_sfx = preload("res://Assets/Sound/SFX/rilascio risorse.wav") # Effetto sonoro del rilascio risorse 
# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var health = max_health
@onready var rayCast = $RayCast2D # NON RIMUOVERE, FA FUNZIONARE IL TUTTO
@onready var dropPadSprite = $DropPad
@onready var droneSprite = $Drone
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var hasPackage = true;

#Funzione che inizializza il drone
func _ready() -> void:
	droneSprite.z_index = 5
	dropPadPosition = dropPadSprite.position
	droneStartingPosition = droneSprite.position
	dronePosition = droneStartingPosition
	#print(droneStartingPosition)

#Funzione che si occupa della logica di movimento del drone e dello scarico delle risorse
func _process(delta: float):
	droneSprite.position = dronePosition
	var distanceDronePad = dropPadPosition.y - dronePosition.y  #misura la distanza del drone dal landing pad
	dropPadSprite.play("idle")
	
	#Se il drone ha il pacco e la distanza dal landing pad è maggiore di 10 il drone vola e si dirige al landing pad
	if hasPackage and distanceDronePad > 10:
		droneSprite.play("fly")
		dronePosition.y += 200 * delta
	#Altrimenti se ha il pacco e la distanza è inferiore a 10 lo droppa
	elif hasPackage:
		drop()
	#Se non ha il pacco vola per prendere un altro pacco
	if !hasPackage:
		droneSprite.play("fly-no-pack")
		dronePosition.y -= 200 * delta
		# Quando torna in alto, ricarica il pacco
		if dronePosition.y <= droneStartingPosition.y:
			dronePosition.y = droneStartingPosition.y
			hasPackage = true
			#print("Carico")

#Funzione di scarico
func drop():
	#print("Scarico")
	droneSprite.play("drop")
	AudioManager.play_sfx(drop_sfx)

func _on_reload_timer_timeout():
	rayCast.enabled = true  # NON RIMUOVERE, NON SO COSA FACCIA MA FA FUNZIONARE TUTTO

#Funzione che si occupa della presa del danno per il drone
func take_damage(amount):
	health -= amount
	flash_bright()
	#print("Tower HP:", health)
	if health < 0:
		health = 0
	if health == 0:
		die()

#Funzione di morte per ora viene semplicemente deallocato
func die():
	queue_free()

func set_riga(value: int) -> void:
	riga = value

# Modula lo sprite per dare feedback visivo
func flash_bright():
	dropPadSprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	dropPadSprite.modulate = Color(1, 1, 1) # Normale

#Funzione che si occupa di cambiare animazione quando l'animazione di drop è finita
func _on_drone_animation_finished() -> void:
	current_animation = droneSprite.animation
	if (current_animation == "drop"):
		droneSprite.play("fly-no-pack")
		hasPackage = false
		spawn_scrap()

#Funzione che si occupa di spawnare lo scrap
func spawn_scrap():
	var scrap_scene: PackedScene = preload("res://Scenes/Scrap.tscn")
	var scrap_instance = scrap_scene.instantiate()

	# Aggiungi prima al parent giusto (lo stesso della pedana)
	dropPadSprite.get_parent().add_child(scrap_instance)

	# Poi assegna la posizione globale
	scrap_instance.global_position = dropPadSprite.global_position

	# Porta sopra la pedana
	scrap_instance.z_index = dropPadSprite.z_index + 1

	# Collega il point manager
	var pm = get_tree().get_first_node_in_group("PointManager")
	scrap_instance.point_manager = pm
	#print("DropPad at:", dropPadSprite.global_position)
	#print("Scrap at:", scrap_instance.global_position)
