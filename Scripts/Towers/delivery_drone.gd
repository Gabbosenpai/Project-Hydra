class_name DeliveryDrone
extends Area2D

@export var tower_max_health : int = 100
@export var scrap_scene : PackedScene

signal died(instance)

# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var drop_pad_sprite : AnimatedSprite2D = $DropPad
@onready var drone_sprite : AnimatedSprite2D = $Drone

# Variabili di un Drone, torretta che genera risorse invece di sparare
var current_health : int
var hasPackage : bool
var hasPlayed : bool
var dropPadPosition : Vector2
var dronePosition : Vector2
var droneStartingPosition : Vector2
var current_animation : StringName
var drop_sfx : AudioStreamWAV = preload("res://Assets/Sound/SFX/rilascio risorse.wav")

func _ready() -> void:
	current_health = tower_max_health
	hasPackage = true
	hasPlayed = false
	drone_sprite.z_index = 5
	dropPadPosition = drop_pad_sprite.position
	droneStartingPosition = drone_sprite.position
	dronePosition = droneStartingPosition
	#print(droneStartingPosition)

# Override
func _process(delta: float) -> void:
	drone_sprite.position = dronePosition
	var distanceDronePad = dropPadPosition.y - dronePosition.y
	drop_pad_sprite.play("idle")
	
	if hasPackage and distanceDronePad > 10:
		drone_sprite.play("fly")
		dronePosition.y += 200 * delta
	elif hasPackage:
		drop()
	
	if !hasPackage:
		drone_sprite.play("fly-no-pack")
		dronePosition.y -= 200 * delta
		# Quando torna in alto, ricarica il pacco
		if dronePosition.y <= droneStartingPosition.y:
			dronePosition.y = droneStartingPosition.y
			hasPackage = true
			hasPlayed = false
			#print("Carico")

func drop() -> void:
	#print("Scarico")
	drone_sprite.play("drop")
	if !hasPlayed:
		AudioManager.play_sfx(drop_sfx)
		hasPlayed = true

func _on_drone_animation_finished() -> void:
	current_animation = drone_sprite.animation
	if (current_animation == "drop"):
		drone_sprite.play("fly-no-pack")
		hasPackage = false
		spawn_scrap()

func spawn_scrap() -> void:
	var scrap_instance = scrap_scene.instantiate()
	
	# Aggiungi prima al parent giusto (lo stesso della pedana)
	drop_pad_sprite.get_parent().add_child(scrap_instance)

	# Poi assegna la posizione globale
	scrap_instance.global_position = drop_pad_sprite.global_position

	# Porta sopra la pedana
	scrap_instance.z_index = drop_pad_sprite.z_index + 1

	# Collega il point manager
	var pm = get_tree().get_first_node_in_group("PointManager")
	scrap_instance.point_manager = pm
	#print("DropPad at:", drop_pad_sprite.global_position)
	#print("Scrap at:", scrap_instance.global_position)

#Funzione che fa prendere danno allo torretta
func take_damage(amount):
	current_health -= amount
	flash_bright()
	print("Tower HP:", current_health)
	if current_health < 0:
		current_health = 0
	if current_health == 0:
		die()

#Funzione di morte per ora il nemico viene solamente deallocato dalla scena 
func die():
	emit_signal("died", self)
	queue_free()

# Modula lo sprite per dare feedback visivo
func flash_bright():
	drop_pad_sprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	drop_pad_sprite.modulate = Color(1, 1, 1) # Normale
