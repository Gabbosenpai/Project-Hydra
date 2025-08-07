extends Area2D

@export var max_health = 100 
@export var speed = 50 
@export var damage = 25 

@onready var health = max_health
@onready var violence: bool = false # Se true, il robot inizia ad attaccare!
@onready var robotSprite = $RobotSprite

var riga : int
var target = null # Bersaglio dell'attacco, vienne aggiornata dai signal

func _process(delta: float):
	# Finchè il robot non attacca, continua a muoversi
	if !violence:
		move(delta)

func take_damage(amount):
	health -= amount
	print("Robot HP:",health)
	if health < 0:
		health = 0
	if health == 0:
		die()

func move(delta):
	position.x -= speed * delta 
	robotSprite.play("move")   

func die():
	queue_free()

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
