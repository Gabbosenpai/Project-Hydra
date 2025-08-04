extends Node2D

@export var BULLET:PackedScene = null

var robots_coming = []
var armed = false
var riga

@onready var rayCast = $RayCast2D
@onready var towerSprite = $TowerSprite
@onready var reloadTimer = $RayCast2D/ReloadTimer

func shoot():
	$TowerSprite.play()
	if BULLET:
		var bullet: Node2D = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
	reloadTimer.start()

func _on_reload_timer_timeout():
	rayCast.enabled = true

func _process(_delta: float):
	robots_coming = get_valid_robots()
	armed = not robots_coming.is_empty()

	if reloadTimer.is_stopped() and armed:
		shoot()

# 🔹 Ottiene tutti i robot validi nella stessa riga e visibili
func get_valid_robots() -> Array:
	var all_robots = get_tree().get_nodes_in_group("Robot")
	return all_robots.filter(is_valid_robot)

# 🔹 Controlla se un singolo robot è valido per questa torretta
func is_valid_robot(robot: Node) -> bool:
	return is_same_row(robot) and is_robot_visible(robot)

func is_same_row(robot: Node) -> bool:
	#return robot.riga == riga
	return true


func is_robot_visible(robot: Node) -> bool:
	return robot.is_on_screen()
