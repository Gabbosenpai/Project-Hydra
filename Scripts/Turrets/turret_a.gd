extends Node2D

@export var BULLET:PackedScene = null

var robots_coming = []
var armed = false

@onready var rayCast = $RayCast2D
@onready var turretSprite = $TurretSprite
@onready var reloadTimer = $RayCast2D/ReloadTimer

func shoot():
	#print("PEW")
	if BULLET:
		var bullet: Node2D = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
	
	reloadTimer.start()

func _on_reload_timer_timeout() -> void:
	rayCast.enabled = true

func _ready() -> void:
	pass
	#await get_tree()

func _process(_delta: float) -> void:
	if robots_coming.is_empty():
		armed = false
	else:
		armed = true
	if reloadTimer.is_stopped() and armed:
		shoot()

func _on_tower_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("Robot"):
		robots_coming.append(area)

func _on_tower_range_area_exited(area: Area2D) -> void:
	if area.is_in_group("Robot"):
		robots_coming.erase(area)
