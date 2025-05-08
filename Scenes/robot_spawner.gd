extends Node2D

@onready var robot_A = preload("res://Scenes/Robots/robot_a.tscn")
@onready var robot_B = preload("res://Scenes/Robots/robot_B.tscn")
@onready var timer = $Timer

@export var robot_power = 10


func _on_timer_timeout() -> void:
	var tempRobot = robot_A.instantiate()
	add_child(tempRobot)
	robot_power -= 1
	if robot_power == 0:
		timer.wait_time = 5
		var boss = robot_B.instantiate()
		add_child(boss)
		boss.global_position.y = 245.0
		boss.global_position.x = 1000.0
