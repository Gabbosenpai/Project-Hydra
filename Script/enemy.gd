extends Area2D

@export var speed: float = 100.0
@export var damage: int = 3
@export var max_health: int = 3

var current_health: int
var attacking_tower: Area2D = null

@onready var damage_timer = $DamageTimer
@onready var health_bar = $HealthBar

func _ready():
	add_to_group("Enemy")
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

func _process(delta):
	if attacking_tower == null:
		position.x -= speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		attacking_tower = area
		damage_timer.start()

func _on_damage_timer_timeout() -> void:
	if attacking_tower:
		attacking_tower.take_damage(damage)

# Nuova funzione chiamata dalla torre quando muore
func stop_attacking():
	damage_timer.stop()
	attacking_tower = null

func take_damage(amount: int) -> void:
	current_health -= amount
	health_bar.value = current_health
	if current_health <= 0:
		queue_free()
