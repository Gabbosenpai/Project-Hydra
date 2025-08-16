extends Node2D

@export var max_health = 100

var riga: int # Riga della torretta nella griglia, inizializzata al piazzamento
var dropPadPosition
var dronePosition
var droneStartingPosition
var current_animation

# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var health = max_health
@onready var rayCast = $RayCast2D # NON RIMUOVERE, FA FUNZIONARE IL TUTTO
@onready var dropPadSprite = $DropPad
@onready var droneSprite = $Drone
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var hasPackage = true;

func _ready() -> void:
	droneSprite.z_index = 5
	dropPadPosition = dropPadSprite.position
	droneStartingPosition = droneSprite.position
	dronePosition = droneStartingPosition
	print(droneStartingPosition)

func _process(delta: float):
	droneSprite.position = dronePosition
	var distanceDronePad = dropPadPosition.y - dronePosition.y
	dropPadSprite.play("idle")
	
	if hasPackage and distanceDronePad > 10:
		droneSprite.play("fly")
		dronePosition.y += 200 * delta
	elif hasPackage:
		drop()
	
	if !hasPackage:
		droneSprite.play("fly-no-pack")
		dronePosition.y -= 200 * delta
		# Quando torna in alto, ricarica il pacco
		if dronePosition.y <= droneStartingPosition.y:
			dronePosition.y = droneStartingPosition.y
			hasPackage = true
			print("Carico")


func drop():
	print("Scarico")
	droneSprite.play("drop")

func _on_reload_timer_timeout():
	rayCast.enabled = true  # NON RIMUOVERE, NON SO COSA FACCIA MA FA FUNZIONARE TUTTO

func take_damage(amount):
	health -= amount
	flash_bright()
	print("Tower HP:", health)
	if health < 0:
		health = 0
	if health == 0:
		die()

func die():
	queue_free()

func set_riga(value: int) -> void:
	riga = value

# Modula lo sprite per dare feedback visivo
func flash_bright():
	dropPadSprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	dropPadSprite.modulate = Color(1, 1, 1) # Normale

func _on_drone_animation_finished() -> void:
	current_animation = droneSprite.animation
	if (current_animation == "drop"):
		droneSprite.play("fly-no-pack")
		hasPackage = false
		spawn_scrap()

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
	print("DropPad at:", dropPadSprite.global_position)
	print("Scrap at:", scrap_instance.global_position)
