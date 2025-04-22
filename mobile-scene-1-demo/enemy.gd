extends CharacterBody2D

@export var speed := 20
@export var max_health := 1
var health := max_health

func _ready():
	$"/root/Main Scene/Tower/HealthBar".max_value = max_health
	$"/root/Main Scene/Tower/HealthBar".value = health

func _physics_process(delta):
	var tower = get_tree().get_current_scene().get_node_or_null("Tower")
	if tower:
		var direction = (tower.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount):
	health -= amount
	$"/root/Main Scene/Tower/HealthBar".value = health
	if health <= 0:
		queue_free()
