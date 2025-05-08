extends Area2D

@export var max_health = 1000
@export var speed = 25
@export var damage = 1000

@onready var health = max_health
@onready var health_bar = $HealthBar

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health         # Inizializza HealthBar

func _process(delta: float) -> void:
	position.x -= speed * delta       # Muove Robot verso il muro

#func _on_area_entered(area: Area2D) -> void:
	#if area.is_in_group("Wall"):
		#position.x += 100     # "Rimbalza" sul muro per continuare ad attaccare

func take_damage(amount):
	health -= amount
	if health < 0:
		health = 0
	health_bar.value = health
	print("Robot:" + str(health))
	if health == 0:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
	$Music.play()
