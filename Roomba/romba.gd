extends Area2D

@export var max_health = 100
@export var speed = 50
@export var damage = 25

@onready var health = max_health
@onready var violence = false
@onready var robotSprite = $RobotSprite

var riga : int
var target = null

func _process(delta: float):
	if !violence:
		move(delta)

func take_damage(amount):
	health -= amount
	if health < 0:
		health = 0
	if health == 0:
		die()

func move(delta):
	position.x -= speed * delta 
	if robotSprite.animation != "move":
		robotSprite.play("move")   

func die():
	queue_free()

func _on_tower_detector_area_entered(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = true
		target = tower
		robotSprite.play("attack")

func _on_tower_detector_area_exited(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = false
		target = null
		
func _on_robot_sprite_animation_finished() -> void:
	print("animazione finita")
	var current_aniamtion = robotSprite.animation
	if current_aniamtion == "attack" and violence and target and is_instance_valid(target):
		print("Violenza!!!")
		if target.has_method("take_damage"):
			print("Ha il metodo!")
			target.take_damage(damage)
		robotSprite.play("attack")
