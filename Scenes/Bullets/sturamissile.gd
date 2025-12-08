class_name Sturamissile
extends Bullet

@export var sturamissile_speed: float = 200 # Velocità del proiettile
@export var sturamissile_damage: int = 10 # Danno del proiettile

func _ready() -> void:
	super.bullet_set_up(sturamissile_speed, sturamissile_damage)
	super._ready()
