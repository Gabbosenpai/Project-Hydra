extends Node

signal level_completed
signal wave_completed(wave_number)

@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer
@export var label_wave_center: Label
@export var animation_player: AnimationPlayer
@export var victory_screen: Control

var all_enemy_scenes = {
	"romba": preload("res://Scenes/Robots/romba.tscn"),
	"weed_eater_9000": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"mecha_freezer": preload("res://Scenes/Robots/mecha_freezer.tscn"),
	"kamikaze": preload("res://Scenes/Robots/kamikaze.tscn")
}

var level_enemy_pool = {
	1: ["romba"],
	2: ["romba", "weed_eater_9000"],
	3: ["romba", "weed_eater_9000", "mecha_freezer"],
	4: ["romba", "weed_eater_9000", "mecha_freezer", "kamikaze"],
	5: ["romba", "weed_eater_9000", "mecha_freezer", "kamikaze"]
}

var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false
var current_level: int = 1

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


func _on_wave_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		wave_timer.start()


func spawn_enemy():
	var pool = level_enemy_pool.get(current_level, ["romba"])
	var choice = pool[randi() % pool.size()]
	print("Lvl", current_level, " pool=", pool, " → scelto: ", choice)
	var enemy_scene = all_enemy_scenes[choice]
	var enemy = enemy_scene.instantiate()
	
	var row = randi() % GameConstants.ROW
	var spawn_cell = Vector2i(GameConstants.COLUMN + 4, row)
	var center_pos = tilemap.map_to_local(spawn_cell)
	enemy.global_position = tilemap.to_global(center_pos)
	enemy.riga = row
	
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	add_child(enemy)
	
	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)


func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)

	# ✅ CHIAMA LA FUNZIONE DI CHECK
	_check_wave_completion()


func kill_all():
	enemies_to_spawn = 0
	for child in get_children():
		if child.has_method("die"):
			child.queue_free()
			enemies_alive -= 1

	is_wave_active = false
	current_wave += 1

	emit_signal("wave_completed", current_wave)

	if current_wave < waves.size():
		start_wave()
	else:
		victory_screen.visible = true
		if "AudioManager" in get_tree().get_nodes_in_group("singleton"):
			AudioManager.play_victory_music()
		emit_signal("level_completed")

# 🔥 Nuovo: Distrugge tutti i robot in una riga specifica (usato dall'Inceneritore)
# 🔥 Nuovo: Distrugge tutti i robot in una riga specifica (usato dall'Inceneritore)
func destroy_robots_in_row(row: int):
	var killed_count = 0
	
	for child in get_children():
		if child.is_in_group("Robot") and child.has_method("die"):
			if child.riga == row:
				# Disconnetti per evitare doppio decremento da segnale
				child.disconnect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
				
				child.queue_free()
				enemies_alive -= 1 # AGGIORNAMENTO DEL CONTEGGIO
				killed_count += 1
				
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	# ✅ CHIAMA LA FUNZIONE DI CHECK DOPO LA DISTRUZIONE
	_check_wave_completion() 
	
	print("🔥 %d robot inceneriti in riga %d. Nemici rimanenti: %d" % [killed_count, row, enemies_alive])

# ✅ NUOVA FUNZIONE: Controlla se l'ondata è finita e avanza
func _check_wave_completion():
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		# Segnale emesso a fine ondata
		emit_signal("wave_completed", current_wave)

		if current_wave < waves.size():
			start_wave()
		else:
			victory_screen.visible = true
			get_tree().paused = true
			emit_signal("level_completed")
