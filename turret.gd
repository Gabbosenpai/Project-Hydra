extends Node2D

@export var BULLET:PackedScene = null

var target:Node2D = null

@onready var turretSprite = $TurretSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer

func shoot():
	print("PEW")
	rayCast.enabled = false
	if BULLET:
		var bullet: Node2D = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
	
	reloadTimer.start()

func _on_reload_timer_timeout() -> void:
	rayCast.enabled = true

func _ready() -> void:
	await get_tree()

func _physics_process(delta: float) -> void:
	if reloadTimer.is_stopped():
		shoot()
