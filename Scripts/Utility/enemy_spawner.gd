extends Node

signal level_completed
signal wave_completed(wave_number)

@export var grace_time = 15.0
@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer
@export var initial_delay_timer: Timer
@export var label_wave_center: Label
@export var animation_player: AnimationPlayer
@export var victory_screen: Control
@export var inter_wave_delay = 5.0 
@export var next_wave_delay_timer: Timer 

var all_enemy_scenes = {
	"romba": preload("res://Scenes/Robots/romba.tscn"),
	"we9k": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"mf": preload("res://Scenes/Robots/mecha_freezer.tscn"),
	"fh": preload("res://Scenes/Robots/fire_hydrant.tscn")
}

var level_enemy_pool = {
	1: ["romba"],
	2: ["we9k"],
	3: ["mf"],
	4: ["fh"],
	5: ["romba","we9k","mf","fh"]
}

var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false
var current_level: int = 1

var waves = [
	{ "count": 3, "interval": 0.4 },
	{ "count": 5, "interval": 0.2 },
	{ "count": 7, "interval": 0.5 }
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
	
	if initial_delay_timer:
		initial_delay_timer.wait_time = grace_time
		initial_delay_timer.start()
		print("Ritardo iniziale di 15 secondi avviato...")
	else:
		start_wave()

func _on_initial_delay_timeout():
	print("Ritardo iniziale terminato. Avvio prima ondata.")
	start_wave()

func start_wave():
	if is_wave_active or current_wave >= waves.size():
		return

	var wave = waves[current_wave]
	enemies_to_spawn = wave["count"]
	wave_timer.wait_time = wave["interval"]
	
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
		
		if enemies_to_spawn > 0:
			# Se ci sono ancora nemici, riavvia il timer di spawn
			wave_timer.start()
		else:
			# Se l'ultimo nemico è stato spawnato, avvia la transizione
			print("Spawn completato. Avvio la transizione ondata.")
			_check_wave_completion()
		

func _on_next_wave_delay_timeout():
	print("Ritardo tra ondate terminato. Avvio prossima ondata.")
	start_wave() 


func spawn_enemy():
	var pool = level_enemy_pool.get(current_level, ["romba"])
	var choice = pool[randi() % pool.size()]
	print("Lvl", current_level, " pool=", pool, " → scelto: ", choice)
	var enemy_scene = all_enemy_scenes[choice]
	var enemy = enemy_scene.instantiate()
	
	var row = randi() % GameConstants.ROW
	var spawn_cell = Vector2i(GameConstants.COLUMN + 2, row)
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

	# ❌ RIMOSSO: Non chiamare più _check_wave_completion() qui.
	
	# ✅ AGGIUNTO: Controllo di vittoria finale.
	if current_wave >= waves.size() and enemies_alive <= 0:
		victory_screen.visible = true
		if "AudioManager" in get_tree().get_nodes_in_group("singleton"):
			AudioManager.play_victory_music()
		emit_signal("level_completed")


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


func destroy_robots_in_row(row: int):
	var killed_count = 0
	
	for child in get_children():
		if child.is_in_group("Robot") and child.has_method("die"):
			if child.riga == row:
				child.disconnect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
				child.queue_free()
				enemies_alive -= 1 
				killed_count += 1
				
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	# ❌ RIMOSSO: Non chiamare più _check_wave_completion() qui.
	
	print("🔥 %d robot inceneriti in riga %d. Nemici rimanenti: %d" % [killed_count, row, enemies_alive])
	
	# ✅ AGGIUNTO: Controllo di vittoria finale.
	if current_wave >= waves.size() and enemies_alive <= 0:
		victory_screen.visible = true


func _check_wave_completion():
	# Questa funzione viene chiamata SOLO quando lo spawn è terminato (enemies_to_spawn = 0).
	if enemies_to_spawn <= 0 and is_wave_active:
		is_wave_active = false
		current_wave += 1
		
		emit_signal("wave_completed", current_wave)

		if current_wave < waves.size():
			if next_wave_delay_timer:
				print("Spawn completato. Avvio timer di ritardo di %s secondi." % inter_wave_delay)
				next_wave_delay_timer.wait_time = inter_wave_delay
				next_wave_delay_timer.start()
			else:
				start_wave()
		else:
			# L'ultima ondata ha finito lo spawn.
			print("Ultima ondata spawnata. Attendo sconfitta nemici per vittoria.")
