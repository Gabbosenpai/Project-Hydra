extends Area2D

@export var max_health = 100 # Salute massima
@export var speed = 50  # Velocità
@export var explosion_damage = 150  # Danno alla torretta quando esplode

#Inizializzazione robot
@onready var health = max_health
@onready var robotSprite = $RobotSprite
@onready var hitbox = $RobotHitbox
@onready var detector = $TowerDetector/CollisionShape2D

# Variabili di stato
var riga: int
var jamming_sources = 0
var starting_speed = speed
var jamming: bool = false

# Segnali
signal enemy_defeated

#Funzione che inizializza la velocità iniziale del robot
func _ready():
	starting_speed = speed

#Funzione che fa muovere il robot
func _process(delta):
	# Movimento base del robot
	if health > 0 and not jamming:
		move(delta)

#Funzione che si occupa della presa del danno da parte del robot
func take_damage(amount):
	health -= amount
	flash_bright()
	if health <= 0:
		die()

#Funzione che si occupa del movimento del robot
func move(delta):
	position.x -= speed * delta
	robotSprite.play("move")
	
	# Controllo se ha raggiunto la base
	if position.x <= 0:
		var main_scene = get_tree().current_scene
		if main_scene.has_method("enemy_reached_base"):
			main_scene.enemy_reached_base()

#Funzione di morte dove è viene eseguita un'animazione e poi il robot viene deallocato
func die():
	# Disabilita collisioni
	hitbox.set_deferred("disabled", true)
	detector.set_deferred("disabled", true)
	
	# Animazione morte
	robotSprite.z_as_relative = false
	robotSprite.play("death")
	emit_signal("enemy_defeated")
	
	await robotSprite.animation_finished
	queue_free()

#Funzione che si occupa di rallentare i nemici 
func jamming_debuff(amount: float, duration: float):
	jamming = true
	jamming_sources += 1
	speed = max(starting_speed/3, speed - amount)
	
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	
	jamming_sources -= 1
	if jamming_sources <= 0:
		speed = starting_speed
		jamming = false

# Funzione che si occupa dell'esplosione del robot
func explode(target_tower: Area2D):
	if health <= 0:
		return
	
	health = 0  # Imposta a 0 per evitare altre azioni
	
	# Applica danno alla torretta
	if target_tower.has_method("take_damage"):
		print("Esplosione kamikaze - Danno inflitto alla torretta: ", explosion_damage)
		target_tower.take_damage(explosion_damage)
	
	# Effetti visivi
	robotSprite.modulate = Color(1, 0.3, 0.3)  # Tinta rossa
	robotSprite.play("death")
	emit_signal("enemy_defeated")
	
	await get_tree().create_timer(0.3).timeout
	queue_free()

# Segnali collisione
func _on_tower_detector_area_entered(tower: Area2D):
	if tower.is_in_group("Tower"):
		print("Kamikaze entrato in contatto con torretta")
		explode(tower)

func _on_tower_detector_area_exited(tower: Area2D):
	pass  # Non necessario con l'esplosione immediata

# Utility
func flash_bright():
	robotSprite.modulate = Color(1.3, 1.3, 1.3)
	await get_tree().create_timer(0.1).timeout
	robotSprite.modulate = Color(1, 1, 1)

func is_on_screen() -> bool:
	return $VisNot.is_on_screen()
