extends Area2D

@export var max_health = 100
@export var speed = 150
@export var damage = 25

@onready var health = max_health
@onready var health_bar = $HealthBar

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health         # Inizializza HealthBar

func _process(delta: float) -> void:
	position.x -= speed * delta       # Muove Robot verso il muro


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Wall"):
		position.x += 100     # "Rimbalza" sul muro per continuare ad attaccare


func take_damage(amount):
	health -= amount
	health_bar.value = health
	print("Robot:" + str(health))
	if health <= 0:
		queue_free()
