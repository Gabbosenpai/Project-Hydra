extends Node

signal wave_completed
signal enemy_reached_base

@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer

var enemy_scene = preload("res://Scenes/Robots/romba.tscn")

var waves = [
	{ "count": 3, "interval": 1.0 },
	{ "count": 5, "interval": 0.8 },
	{ "count": 7, "interval": 0.6 }
]

var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false

func start_wave():
	if is_wave_active or current_wave >= waves.size():
		return
	var wave = waves[current_wave]
	enemies_to_spawn = wave["count"]
	wave_timer.wait_time = wave["interval"]
	enemies_alive = 0
	is_wave_active = true
	label_wave.text = "Ondata: " + str(current_wave + 1)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	wave_timer.start()

func _on_wave_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		wave_timer.start()
	else:
		if enemies_alive == 0:
			is_wave_active = false
			current_wave += 1
			emit_signal("wave_completed")

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var row = randi() % 8
	var spawn_cell = Vector2i(15, row)
	var tile_center = tilemap.map_to_local(spawn_cell) + tilemap.tile_set.tile_size * 0.5
	enemy.global_position = tilemap.to_global(tile_center)
	enemy.riga = row
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	add_child(enemy)
	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)

func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		emit_signal("wave_completed")

func kill_all():
	for child in get_children():
		if child.has_method("die"):
			child.die()
