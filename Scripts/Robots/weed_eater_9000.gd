extends Area2D

@export var max_health = 75 
@export var speed = 100 
@export var damage = 2 
@export var block_chance := 0.33 # probabilità di bloccare (0.33 = 33%)

@onready var health = max_health
@onready var violence: bool = false # Se true, il robot inizia ad attaccare!
@onready var robotSprite = $RobotSprite
@onready var starting_speed = speed 
@onready var jamming_sources = 0

var riga : int
var target = null # Bersaglio dell'attacco, vienne aggiornata dai signal
var jamming : bool = false
var deflected : bool = false # Bool usata per fermare il robot al blocco

signal enemy_defeated  # Segnale personalizzato che viene emesso quando il nemico muore

func _process(delta: float):
	# Finchè il robot non attacca, è vivo o non sta bloccando, continua a muoversi
	if !violence and !deflected and health>0:
		move(delta)

func take_damage(amount):
	if deflect():  
		amount = 0  # Setta il danno a zero, dando l'illusione di averlo bloccato
		robotSprite.play("block")
		print("NO ONE CAN DEFLECT THE EMERLAD SPLASH!")
		await robotSprite.animation_finished
	health -= amount
	if amount > 0:
		flash_bright() # Fornisce feedback visivo
	print("Robot HP:",health)
	if health < 0:
		health = 0
	if health == 0:
		die()
	deflected = false

func move(delta):
	position.x -= speed * delta 
	robotSprite.play("move") 
	# Controllo: se il nemico è arrivato alla colonna x <= 0
	if position.x <= 0:
		var main_scene = get_tree().current_scene
		if main_scene.has_method("enemy_reached_base"):
			main_scene.enemy_reached_base()  

func die():
	var hitbox = $RobotHitbox
	var detector = $TowerDetector/CollisionShape2D
	robotSprite.z_as_relative = false # Mette il robot morente in secondo piano
	hitbox.set_deferred("disabled", true)
	detector.set_deferred("disabled", true)
	robotSprite.stop()
	robotSprite.play("death")
	emit_signal("enemy_defeated")
	await robotSprite.animation_finished
	queue_free()

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

# Quando finisce l'animazione d'attacco, facciamo un controllo sula validità del bersaglio:
# se true, il bersaglio subisce danno e il robot ricomincia l'animazione d'attacco
func _on_robot_sprite_animation_finished() -> void:
	var current_aniamtion = robotSprite.animation
	if current_aniamtion == "attack" and violence and target and is_instance_valid(target):
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

func flash_blocked():
	modulate = Color(1, 1, 0) # giallo
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

# Calcola con una randf se il robot riesce a bloccare il colpo 
# quando NON sta attaccando
func deflect() -> bool:
	if randf() < block_chance and !violence:
			deflected = true
			return true
	return false
