extends Node

signal wave_completed
signal enemy_reached_base
signal level_completed

@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer
@export var label_wave_center: Label
@export var animation_player: AnimationPlayer
@export var victory_screen: Control

# Tutti i tipi di nemico
var all_enemy_scenes = {
	"romba": preload("res://Scenes/Robots/romba.tscn"),
	"weed_eater_9000": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"ice_robot": preload("res://Scenes/Robots/ice_robot.tscn"),
	"kamikaze": preload("res://Scenes/Robots/kamikaze.tscn")
}

# Dizionario: livello → tipi di nemici disponibili
var level_enemy_pool = {
	1: ["romba"],
	2: ["romba", "weed_eater_9000"],
	3: ["romba", "weed_eater_9000", "ice_robot"],
	4: ["romba", "weed_eater_9000", "ice_robot", "kamikaze"],
	5: ["romba", "weed_eater_9000", "ice_robot", "kamikaze"]
}

# Stato corrente
var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false
var current_level: int = 1   # sarà impostato automaticamente

# Configurazione delle ondate
var waves = [
	{ "count": 3, "interval": 1.0 },
	{ "count": 5, "interval": 0.8 },
	{ "count": 7, "interval": 0.6 }
]

func _ready():
	randomize()

	var path = get_tree().current_scene.scene_file_path
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(path)
	if result:
		current_level = int(result.get_string())
	else:
		current_level = 1

	print("Spawner avviato in livello: ", current_level, " (path=", path, ")")


# Avvia un’ondata
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
	label_wave_center.text = "ONDATA " + str(current_wave + 1)
	label_wave_center.visible = true
	animation_player.play("wave_intro")
	wave_timer.start()

# Timer → spawn nemici
func _on_wave_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		wave_timer.start()


# Spawn singolo nemico
func spawn_enemy():
	# Prende i nemici consentiti per questo livello
	var pool = level_enemy_pool.get(current_level, ["romba"])
	var choice = pool[randi() % pool.size()]
	print("Lvl", current_level, " pool=", pool, " → scelto: ", choice)
	# Sceglie uno casuale dal pool
	var enemy_scene = all_enemy_scenes[choice]
	var enemy = enemy_scene.instantiate()

	var row = randi() % GameConstants.GRID_HEIGHT
	var spawn_cell = Vector2i(GameConstants.GRID_WIDTH, row)
	var tile_center = tilemap.map_to_local(spawn_cell) + tilemap.tile_set.tile_size * 0.5
	enemy.global_position = tilemap.to_global(tile_center)
	enemy.riga = row
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	add_child(enemy)

	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)

# Quando un nemico muore
func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		if current_wave < waves.size():
			start_wave()
		else:
			victory_screen.visible = true
			get_tree().paused = true
			emit_signal("level_completed")

# Uccide tutti i nemici
func kill_all():
	enemies_to_spawn = 0
	for child in get_children():
		if child.has_method("die"):
			child.queue_free()
			enemies_alive -= 1

	is_wave_active = false
	current_wave += 1
	if current_wave < waves.size():
		start_wave()
	else:
		victory_screen.visible = true
		AudioManager.play_victory_music()
		emit_signal("level_completed")
