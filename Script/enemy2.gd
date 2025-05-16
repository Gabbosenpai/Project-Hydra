extends Area2D

@export var speed: float = 150.0
@export var damage: int = 10  
@export var max_health: int = 5  

var current_health: int

@onready var health_bar = $HealthBar

func _ready():
	add_to_group("Enemy")
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

func _process(delta):
	position.x -= speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tower"):
		area.take_damage(damage)
		queue_free()  # Sparisce dopo l’attacco

func take_damage(amount: int) -> void:
	current_health -= amount
	health_bar.value = current_health
	if current_health <= 0:
		queue_free()
