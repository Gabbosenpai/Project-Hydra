extends Area2D

@export var max_health = 100

@onready var health = max_health
@onready var health_bar = $HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_damage(amount):
	health -= amount
	health_bar.value = health
	print("Wall:" + str(health))
	if health <= 0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Robot"):
		self.take_damage(area.damage)
