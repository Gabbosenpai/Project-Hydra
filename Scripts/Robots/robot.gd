@abstract
class_name Robot
extends Area2D

# Nodi-Figlio della scena, inizializzati con onready perchè astratta
@onready var robot_sprite: AnimatedSprite2D = $RobotSprite
@onready var robot_hitbox : CollisionShape2D = $RobotHitbox
@onready var tower_detector_collision : CollisionShape2D = $TowerDetector/CollisionShape2D
@onready var tower_detector : Area2D = $TowerDetector
@onready var visNot : VisibleOnScreenNotifier2D = $VisNot

# Variabili di un robot standard
var current_health: int
var speed: float
var damage: int
var max_health: int
var violence: bool # Se true, il robot inizia ad attaccare!
var starting_speed: float 
var jamming : bool
var jamming_sources: int
var target: Area2D # Bersaglio dell'attacco, vienne aggiornata dai signal
var riga : int
var max_points_on_defeat: int  = 25 # Valore max pts ottenibili da questo robot
var scrap_drop_chance: float = 0.05 # Probabilità (0.0 a 1.0) drop alla morte

@export var scrap_scene : PackedScene = preload("res://Scenes/Utilities/Scrap.tscn")


# Segnali Custom
signal enemy_defeated  # Emesso quando il robot muore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Inizializzo variabili per tutti i tipi di robot
	current_health = max_health
	violence = false
	randomize_speed()
	starting_speed = speed
	print("Robot Starting Speed:", starting_speed)
	jamming = false
	jamming_sources = 0
	target = null
	# Connetto segnali
	tower_detector.area_entered.connect(_on_tower_detector_area_entered)
	tower_detector.area_exited.connect(_on_tower_detector_area_exited)
	robot_sprite.animation_finished.connect(_on_robot_sprite_animation_finished)

# Inizializzo variabili per tipologia di robot
func robot_set_up(robot_max_health : int, robot_speed : float, robot_damage: int):
	max_health = robot_max_health
	speed = robot_speed
	damage = robot_damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_move():
		move(delta)

# Ogni Robot potrebbe avere motivi diversi per muoversi e/o fermarsi
@abstract
func can_move() -> bool;

# Ogni Robot varia leggermente la sua velocità così che si evitino effetti di
# sovrapposizione visivamente odiosi
func randomize_speed():
	var random_offset = randi_range(-5, +5)
	print("Robot offset:", random_offset)
	speed += random_offset

# Movimento del robot
func move(delta) -> void:
	position.x -= speed * delta 
	robot_sprite.play("move") 
	# Controllo: se il nemico è arrivato alla colonna x <= 0
	if position.x <= 150:
		var main_scene = get_tree().current_scene
		if main_scene.has_method("enemy_reached_base"):
			# Passa l'istanza del robot al main level
			main_scene.enemy_reached_base(self) # ✅ CORRETTO
		queue_free()

# Robot prende danno, se la sua salute va a 0, muore.
func take_damage(amount: int) -> void:
	current_health -= amount
	flash_bright() # Fornisce feedback visivo
	print("Robot HP:",current_health)
	if current_health < 0:
		current_health = 0
	if current_health == 0:
		die()

# Se colpito dal jammer il robot viene rallentato, mi creo un timer temporaneo
# per non scomodare altri nodi figlio, inoltre metto un hard cap al debuff per 
# non immobilizzare il robot
func jamming_debuff(amount: float, duration: float) -> void:
	jamming = true
	jamming_sources += 1
	# Riduci la velocità
	speed = max(starting_speed/3.0, speed - amount)
	print("New Speed: ", speed)
	# Timer per ripristinare la velocità
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	jamming_sources -= 1
	if(jamming_sources <= 0):
		speed = starting_speed
		jamming = false

# Robot muore eseguendo l'animazione, poi è deallocato dalla scena
func die() -> void:
	spawn_scrap_on_death()
	robot_sprite.z_as_relative = false # Mette il robot morente in secondo piano
	robot_sprite.stop()
	robot_sprite.play("death")
	robot_hitbox.set_deferred("disabled", true)
	tower_detector_collision.set_deferred("disabled", true)
	emit_signal("enemy_defeated")
	await robot_sprite.animation_finished
	queue_free()

# Controlla se il nemico è visibile nella viewport (schermo)
func is_on_screen() -> bool:
	# Usa il nodo figlio VisibleOnScreenNotifier2D per verificare la visibilità
	return visNot.is_on_screen()

# Modula lo sprite per dare feedback visivo
func flash_bright():
	robot_sprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	robot_sprite.modulate = Color(1, 1, 1) # Normale

# Se il Robot ha una torretta davanti, inizia ad attaccare
func _on_tower_detector_area_entered(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = true
		target = tower
		robot_sprite.play("attack")

# Se il Robot non ha più una torretta davanti, smette di attaccare
func _on_tower_detector_area_exited(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = false
		target = null

# Quando finisce l'animazione d'attacco, facciamo un controllo sulla validità del 
# bersaglio: se true, il bersaglio subisce danno e il robot ricomincia l'animazione
# d'attacco
func _on_robot_sprite_animation_finished() -> void:
	var current_animation = robot_sprite.animation
	if current_animation == "attack" and violence and target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(damage)
		robot_sprite.play("attack")

#Genera la risorsa Scrap con un valore di punti casuale.
func spawn_scrap_on_death() -> void:
	# 1. Calcolo Punti Casuali (Probabilità e Ammontare)
	var points_to_earn = 0
	
	# Se il valore randf (0.0 a 1.0) è minore o uguale alla probabilità, guadagna punti
	if randf() <= scrap_drop_chance:
		# Punti casuali tra 1 e il valore massimo configurato
		points_to_earn = randi_range(1, max_points_on_defeat)
	
	# 2. Istanzia la Scrap e assegna il valore
	if points_to_earn > 0 and scrap_scene:
		var scrap_instance = scrap_scene.instantiate()
		
		#Trova il nodo Sprite all'interno dell'istanza
		var scrap_sprite = scrap_instance.get_node_or_null("Sprite2D")
	
		#Ingrandisce lo sprite
		if scrap_sprite:
			scrap_sprite.scale = Vector2(2.0, 2.0)
		
		# Aggiungi al nodo genitore (di solito Main/Level)
		get_parent().call_deferred("add_child", scrap_instance)

		# Assegna la posizione globale (dove è morto il robot)
		scrap_instance.global_position = global_position
		
		# Assegna il valore dei punti calcolato
		scrap_instance.scrap_value = points_to_earn
		
		# Collega il point manager
		var pm = get_tree().get_first_node_in_group("PointManager")
		scrap_instance.point_manager = pm
		
		# Facciamo in modo che lo scrap sia sotto gli sprite dei robot in movimento (z_index 4 o meno)
		scrap_instance.z_index = 1 
		
		print("Scrap (", points_to_earn, ") generato alla morte del Robot.")
