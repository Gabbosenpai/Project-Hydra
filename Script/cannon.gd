extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0

@onready var bullet_spawn_point: Marker2D = $BulletSpawnPoint
@onready var fire_timer: Timer = $FireTimer
@onready var range_area: Area2D = $RangeArea

var enemies_in_range: Array = []

func _ready():
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	

func _process(_delta):
	if enemies_in_range.size() > 0:
		if fire_timer.is_stopped():
			fire_timer.start()
	else:
		fire_timer.stop()

func _on_fire_timer_timeout():
	if bullet_scene and enemies_in_range.size() > 0:
		#istanzio un bullet e lo aggiungo al main
		var bullet = bullet_scene.instantiate()
		
		bullet.global_position = bullet_spawn_point.global_position
		get_tree().current_scene.add_child(bullet)


func _on_range_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		enemies_in_range.append(area)


func _on_range_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		enemies_in_range.erase(area)
