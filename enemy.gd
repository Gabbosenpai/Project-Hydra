extends Area2D

@export var speed: float = 100.0
@export var damage: int = 3
var attacking_tower: Area2D = null  # salvo la torre colpita

@onready var damage_timer = $DamageTimer

func _process(delta):
	if attacking_tower == null:
		position.x -= speed * delta  # muoviti solo se non stai attaccando

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		attacking_tower = area
		damage_timer.start()  # comincia ad attaccare


	


func _on_damage_timer_timeout() -> void:
	if attacking_tower:
		attacking_tower.take_damage(damage)
		if attacking_tower.current_health <= 0:
			damage_timer.stop()
