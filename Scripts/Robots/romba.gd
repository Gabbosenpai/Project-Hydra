extends Area2D

#Variabili della salute max,velocità e danno
@export var max_health = 100 
@export var speed = 50 
@export var damage = 25 

#Inizializzazione del robot
@onready var health = max_health
@onready var violence: bool = false # Se true, il robot inizia ad attaccare!
@onready var robotSprite = $RobotSprite
@onready var starting_speed = speed 
@onready var jamming_sources = 0

var riga : int
var target : Area2D = null # Bersaglio dell'attacco, vienne aggiornata dai signal
var jamming : bool = false

signal enemy_defeated  # Emesso quando il robot muore

#Funzione che fa muovere il robot
func _process(delta: float):
	# Finchè il robot non attacca ed è vivo, continua a muoversi
	if !violence and health>0:
		move(delta)

#Funzione che si occupa della presa dei danni per il robot
func take_damage(amount):
	health -= amount
	flash_bright() # Fornisce feedback visivo
	print("Robot HP:",health)
	if health < 0:
		health = 0
	if health == 0:
		die()
#Funzione che si occupa del muovimento del robot
func move(delta):
	position.x -= speed * delta 
	robotSprite.play("move") 
	# Controllo: se il nemico è arrivato alla colonna x <= 0
	if position.x <= 0:
		var main_scene = get_tree().current_scene
		if main_scene.has_method("enemy_reached_base"):
			main_scene.enemy_reached_base()  

# Funzione che si occupa di far morire il robot eseguendo l'animazione e poi deallocando il robot dalla scena
func die():
	var hitbox = $RobotHitbox
	var detector = $TowerDetector/CollisionShape2D
	robotSprite.z_as_relative = false # Mette il robot morente in secondo piano
	robotSprite.stop()
	robotSprite.play("death")
	hitbox.set_deferred("disabled", true)
	detector.set_deferred("disabled", true)
	emit_signal("enemy_defeated")
	await robotSprite.animation_finished
	queue_free()

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
	
	# Ripristina velocità se non ci sono altri debuff
	if health > 0:
		speed = starting_speed
		robotSprite.modulate = Color(1, 1, 1)


# Se il Robot ha una torretta davanti, inizia ad attaccare
func _on_tower_detector_area_entered(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = true
		target = tower
		robotSprite.play("attack")

# Se il Robot non ha più una torretta davanti, smette di attaccare
func _on_tower_detector_area_exited(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = false
		target = null

# Quando finisce l'animazione d'attacco, facciamo un controllo sulla validità del 
# bersaglio: se true, il bersaglio subisce danno e il robot ricomincia l'animazione
# d'attacco
func _on_robot_sprite_animation_finished() -> void:
	var current_animation = robotSprite.animation
	if current_animation == "attack" and violence and target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(damage)
		robotSprite.play("attack")

# Funzione che controlla se il nemico è visibile nella viewport (schermo)
func is_on_screen() -> bool:
	# Usa il nodo figlio VisibleOnScreenNotifier2D per verificare la visibilità
	return $VisNot.is_on_screen()

# Modula lo sprite per dare feedback visivo
func flash_bright():
	robotSprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	robotSprite.modulate = Color(1, 1, 1) # Normale
