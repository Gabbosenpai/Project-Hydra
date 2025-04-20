extends Area2D

@export var max_health = 100
@export var speed = 150
@export var damage = 25

@onready var health = max_health
@onready var health_bar = $HealthBar

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health

func _process(delta: float) -> void:
	position.x -= speed * delta
