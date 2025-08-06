extends Node2D

@onready var robot_A = preload("res://Roomba/romba.tscn")
@onready var robot_B = preload("res://Scenes/Robots/robot_b.tscn")
@onready var timer = $Timer

@export var robot_power = 10


func _on_timer_timeout() -> void:
	var tempRobot = robot_A.instantiate()
	add_child(tempRobot)
	timer.stop()
	robot_power -= 1
	if robot_power == 0:
		robot_power = 7
		timer.wait_time +=1
		var boss = robot_B.instantiate()
		add_child(boss)
		boss.global_position.y = 245.0
		boss.global_position.x = 1000.0
