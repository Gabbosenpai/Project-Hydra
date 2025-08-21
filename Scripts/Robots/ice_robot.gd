extends Node2D

@export var BULLET: PackedScene = null 
@export var max_health := 100 
@export var speed := 60.0 # velocità movimento sulla riga

var robots_coming: Array = []
var armed := false 
var riga: int 
var target: Node2D = null

@onready var health = max_health
@onready var bulletOrigin = $BulletOrigin
@onready var rayCast = $RayCast2D                
@onready var towerSprite = $TowerSprite            
@onready var reloadTimer = $RayCast2D/ReloadTimer

func _process(delta: float) -> void:
	robots_coming = get_valid_robots()
	armed = not robots_coming.is_empty()

	if armed:
		target = get_closest_robot()
		if target and is_instance_valid(target):
			move_towards_target(delta)
		if reloadTimer.is_stopped():
			shoot()
	elif towerSprite.animation != "shoot":
		towerSprite.play("idle")

# Movimento orizzontale verso il nemico, restando sulla stessa riga
func move_towards_target(delta: float) -> void:
	if target and is_instance_valid(target):
		# muove solo sull'asse X (riga fissa)
		var direction_x = sign(target.global_position.x - global_position.x)
		global_position.x += direction_x * speed * delta

# Trova il robot più vicino
func get_closest_robot() -> Node2D:
	if robots_coming.is_empty():
		return null
	var closest = robots_coming[0]
	var min_dist = global_position.distance_to(closest.global_position)
	for r in robots_coming:
		var dist = global_position.distance_to(r.global_position)
		if dist < min_dist:
			closest = r
			min_dist = dist
	return closest

# Spara un proiettile di ghiaccio
func shoot() -> void:
	towerSprite.play("shoot")
	if BULLET:
		var bullet: Node2D = BULLET.instantiate()
		bullet.z_index = 5
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = bulletOrigin.global_position
		# direzione del proiettile verso il target
		if target and is_instance_valid(target):
			var dir = (target.global_position - bulletOrigin.global_position).normalized()
			if "direction" in bullet:
				bullet.direction = dir
	reloadTimer.start()

func _on_reload_timer_timeout():
	rayCast.enabled = true  

func take_damage(amount: int) -> void:
	health -= amount
	flash_bright()
	print("Tower HP:", health)
	if health <= 0:
		die()

func die() -> void:
	queue_free()

# Filtra i robot validi
func get_valid_robots() -> Array:
	var all_robots = get_tree().get_nodes_in_group("Robot")
	return all_robots.filter(is_valid_robot)

func is_valid_robot(robot: Node) -> bool:
	return is_same_row(robot) and is_robot_visible(robot)

func is_same_row(robot: Node) -> bool:
	return "riga" in robot and robot.riga == riga

func is_robot_visible(robot: Node) -> bool:
	return robot.is_on_screen()

func set_riga(value: int) -> void:
	riga = value

func _on_tower_sprite_animation_finished() -> void:
	if towerSprite.animation == "shoot":
		towerSprite.play("idle")

func flash_bright():
	towerSprite.modulate = Color(1.3, 1.3, 1.3)
	await get_tree().create_timer(0.1).timeout
	towerSprite.modulate = Color(1, 1, 1)
