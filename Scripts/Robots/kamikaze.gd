extends Area2D

# Variabili esportabili (modificabili dall'editor)
@export var max_health = 100
@export var speed = 50
@export var explosion_damage = 150  # Danno alla torretta quando esplode

# Variabili onready
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

func _ready():
	starting_speed = speed

func _process(delta):
	# Movimento base del robot
	if health > 0 and not jamming:
		move(delta)

func take_damage(amount):
	health -= amount
	flash_bright()
	if health <= 0:
		die()

func move(delta):
	position.x -= speed * delta
	robotSprite.play("move")
	
	# Controllo se ha raggiunto la base
	if position.x <= 0:
		var main_scene = get_tree().current_scene
		if main_scene.has_method("enemy_reached_base"):
			main_scene.enemy_reached_base()

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

func freeze(duration: float) -> void:
	if health <= 0: # non congelare un robot già morto
		return
	var old_speed = speed
	speed = 0
	robotSprite.modulate = Color(0.5, 0.8, 1.0) # effetto visivo azzurrato
	print("Robot congelato per ", duration, " secondi")
	
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	
	# Ripristina velocità se non ci sono altri debuff
	if health > 0:
		speed = starting_speed
		robotSprite.modulate = Color(1, 1, 1)


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
