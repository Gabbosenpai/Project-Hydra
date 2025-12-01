class_name BoltBullet
extends Bullet

@export var bolt_bullet_speed: float = 200 # Velocità del proiettile
@export var bolt_bullet_damage: int = 10 # Danno del proiettile

func _ready() -> void:
	super.bullet_set_up(bolt_bullet_speed, bolt_bullet_damage)
	super._ready()
