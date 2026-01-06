class_name DeliveryDrone
extends Area2D

signal died(instance)
signal spawn_animation_finished

const DRONE_FLYING_SPEED: float = 200.0
const DRONE_FLYING_SPEED_SPAWN_TURRET: float = 500.0
const SPAWN_DISTANCE: float = 300.0

@export var dd_max_health: int = 100
@export var scrap_scene: PackedScene
@export var is_spawn_animation: bool = false

# Variabili di un Drone, torretta che genera risorse invece di sparare
var current_health: int
var hasPackage: bool
var hasPlayed: bool
var dropPadPosition: Vector2
var dronePosition: Vector2
var droneStartingPosition: Vector2
var current_animation: StringName
var drop_sfx: AudioStreamWAV = preload("res://Assets/Sound/SFX/rilascio risorse.wav")
var turret_key: String = ""


# Riferimenti ai nodi figli, inizializzati al caricamento del nodo
@onready var drop_pad_sprite: AnimatedSprite2D = $DropPad
@onready var drone_sprite: AnimatedSprite2D = $Drone


func _ready() -> void:

	drone_sprite.z_index = 5
	dropPadPosition = drop_pad_sprite.position
	droneStartingPosition = drone_sprite.position
	dronePosition = droneStartingPosition

	if is_spawn_animation:
		dronePosition.y = dropPadPosition.y - SPAWN_DISTANCE 
		droneStartingPosition.y = dronePosition.y
		return
	
	current_health = dd_max_health
	hasPackage = true
	hasPlayed = false
	
	#print(droneStartingPosition)

# Override
func _process(delta: float) -> void:
	if is_spawn_animation:
		drone_sprite.position = dronePosition
		var distanza = dropPadPosition.y - dronePosition.y
		if distanza > 10:
			drone_sprite.play("fly")
			dronePosition.y += DRONE_FLYING_SPEED_SPAWN_TURRET * delta
		else:
			drop()
		return

	drone_sprite.position = dronePosition
	var distanceDronePad = dropPadPosition.y - dronePosition.y
	drop_pad_sprite.play("idle")
	
	if hasPackage and distanceDronePad > 10:
		drone_sprite.play("fly")
		dronePosition.y += DRONE_FLYING_SPEED * delta
	elif hasPackage:
		drop()
	
	if !hasPackage:
		drone_sprite.play("fly-no-pack")
		dronePosition.y -= DRONE_FLYING_SPEED * delta
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
	
	if is_spawn_animation and current_animation == "drop":
		emit_signal("spawn_animation_finished")
		is_spawn_animation = false
		return
	
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
	if is_spawn_animation:
		return
	
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


func spawn_scrap_on_incinerate() -> void:
	# 1. Trova il PointManager
	var pm = get_tree().get_first_node_in_group("PointManager")
	
	if pm and scrap_scene and turret_key != "":
		var points_to_earn: int = pm.refund_points
		if points_to_earn > 0:
			var scrap_instance = scrap_scene.instantiate()
			var scrap_sprite = scrap_instance.get_node_or_null("Sprite2D")
			var scrap_collision = scrap_instance.get_node_or_null("CollisionShape2D")
			if scrap_sprite:
				scrap_sprite.scale = Vector2(1.5, 1.5)
				scrap_collision.scale = Vector2(2.0, 2.0)
					
				# Aggiungi al nodo genitore (Main/Level)
				get_parent().call_deferred("add_child", scrap_instance)
				
				# Assegna la posizione globale e i valori
				scrap_instance.global_position = global_position
				scrap_instance.scrap_value = points_to_earn
				scrap_instance.point_manager = pm
				scrap_instance.z_index = 100 
				
				print("Scrap Torretta (", points_to_earn, ") generato dall'inceneritore.")
