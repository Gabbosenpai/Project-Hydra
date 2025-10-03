class_name Romba
extends Robot

const ROMBA_HEALTH : int = 100
const ROMBA_SPEED : float = 50
const ROMBA_DAMAGE : int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_health = ROMBA_HEALTH
	speed = ROMBA_SPEED
	damage = ROMBA_DAMAGE
	super._ready()

func can_move() -> bool:
	return !violence and health>0

func take_damage(amount):
	health -= amount
	super.flash_bright() # Fornisce feedback visivo
	print("Robot HP:",health)
	if health < 0:
		health = 0
	if health == 0:
		die()
