@abstract
class_name Robot
extends Area2D

# Variabili della salute max,velocità e danno
@export var max_health: int
@export var speed: float
@export var damage: int

# Nodi-Figlio della scena
@onready var robot_sprite: Sprite2D = $robot_sprite
@onready var robot_hitbox : CollisionShape2D = $RobotHitbox
@onready var tower_detector : CollisionShape2D = $TowerDetector/CollisionShape2D
@onready var visNot : VisibleOnScreenNotifier2D = $VisNot

var health: int
var violence: bool # Se true, il robot inizia ad attaccare!
var starting_speed: float 
var jamming : bool
var jamming_sources: int
var target: Area2D # Bersaglio dell'attacco, vienne aggiornata dai signal
var riga : int

signal enemy_defeated  # Emesso quando il robot muore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	violence = false
	starting_speed = speed
	jamming = false
	jamming_sources = 0
	target = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_move():
		move(delta)

# Ogni Robot potrebbe avere motivi diversi per muoversi e/o fermarsi
@abstract
func can_move() -> bool;

# Movimento del robot
func move(delta) -> void:
	position.x -= speed * delta 
	robot_sprite.play("move") 
	# Controllo: se il nemico è arrivato alla colonna x <= 0
	if position.x <= 0:
		var main_scene = get_tree().current_scene
		if main_scene.has_method("enemy_reached_base"):
			main_scene.enemy_reached_base()

@abstract
func take_damage(amount);

# Se colpito dal jammer il robot viene rallentato
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
	robot_sprite.z_as_relative = false # Mette il robot morente in secondo piano
	robot_sprite.stop()
	robot_sprite.play("death")
	robot_hitbox.set_deferred("disabled", true)
	tower_detector.set_deferred("disabled", true)
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
