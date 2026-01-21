
extends Node

signal level_completed
signal victory
signal wave_completed(wave_number)

@export var grace_time = 15.0
@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer
@export var initial_delay_timer: Timer
@export var wave_number: Label
@export var animation_player: AnimationPlayer
@export var victory_screen: Panel
@export var inter_wave_delay = 5.0
@export var next_wave_delay_timer: Timer
@export var is_blackout_level: bool = false

var all_enemy_scenes = {
	"romba": preload("res://Scenes/Robots/romba.tscn"),
	"we9k": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"mf": preload("res://Scenes/Robots/mecha_freezer.tscn"),
	"fh": preload("res://Scenes/Robots/fire_hydrant.tscn"),
	"cs": preload("res://Scenes/Robots/cassa_schierata.tscn")
}

# Modifica 'interval' per cambiare quanto velocemente escono i nemici (secondi tra uno e l'altro)
var waves = [
	{ "interval": 1.5 }, # Ondata 1
	{ "interval": 1.8 }, # Ondata 2
	{ "interval": 2.0 }, # Ondata 3
	{ "interval": 2.5 }  # Ondata 4
]

# Variabile per definire i pattern fissi per livello
# STRUTTURA:
# Numero Livello: {
#    Numero Ondata: [ [Corsia 1], [Corsia 2], [Corsia 3], [Corsia 4], [Corsia 5] ]
# }
var level_patterns = {
	1: { # LIVELLO 1
		1: [["romba", "romba"], ["romba"], ["romba", "romba"], ["romba"], ["romba"]], # Tot 8
		2: [["romba", "romba", "romba"], ["romba"], ["romba", "romba"], ["romba"], ["romba", "romba"]], # Tot 10
		3: [["romba", "romba"], ["romba", "romba"], ["romba", "romba"], ["romba", "romba"], ["romba", "romba"]], # Tot 10
		4: [["romba", "romba", "romba"], ["romba", "romba"], ["romba", "romba", "romba"], ["romba", "romba"], ["romba", "romba", "romba"]] # Tot 13
	},
	2: { # LIVELLO 2 (Introduzione Weed Eater 9000 - we9k)
		1: [["romba", "we9k"], ["romba"], ["we9k", "romba"], ["romba"], ["romba"]],
		2: [["we9k", "we9k"], ["romba", "romba"], ["we9k"], ["romba", "romba"], ["we9k", "romba"]],
		3: [["romba", "romba", "we9k"], ["we9k", "we9k"], ["romba", "romba"], ["we9k", "romba"], ["romba", "we9k"]],
		4: [["we9k", "we9k", "we9k"], ["romba", "romba", "romba"], ["we9k", "we9k"], ["romba", "romba", "romba"], ["we9k", "we9k"]]
	},
	3: { # LIVELLO 3 (Introduzione Mecha Freezer - mf)
		1: [["mf", "romba"], ["romba"], ["mf"], ["romba", "romba"], ["we9k"]],
		2: [["mf", "we9k"], ["mf", "romba"], ["we9k", "we9k"], ["mf"], ["romba", "mf"]],
		3: [["mf", "mf"], ["we9k", "we9k", "we9k"], ["mf", "romba"], ["we9k", "mf"], ["romba", "mf", "romba"]],
		4: [["mf", "mf", "mf"], ["we9k", "we9k"], ["mf", "mf"], ["we9k", "we9k"], ["mf", "mf", "mf"]]
	},
	4: { # LIVELLO 4 (Introduzione Fire Hydrant - fh)
		1: [["fh", "romba"], ["mf"], ["fh"], ["we9k", "we9k"], ["romba"]],
		2: [["fh", "mf"], ["fh", "we9k"], ["mf", "mf"], ["fh"], ["we9k", "fh"]],
		3: [["fh", "fh"], ["mf", "mf", "mf"], ["fh", "we9k"], ["mf", "fh"], ["fh", "romba"]],
		4: [["fh", "fh", "fh"], ["fh", "mf", "fh"], ["fh", "fh"], ["mf", "mf", "mf"], ["fh", "fh", "fh"]]
	},
	5: { # LIVELLO 5 (Introduzione Cassa Schierata - cs)
		1: [["cs", "romba"], ["fh"], ["cs"], ["mf", "mf"], ["we9k"]],
		2: [["cs", "fh"], ["cs", "mf"], ["fh", "fh"], ["cs"], ["mf", "cs"]],
		3: [["cs", "cs"], ["fh", "fh", "fh"], ["cs", "mf"], ["fh", "cs"], ["cs", "romba"]],
		4: [["cs", "cs", "cs"], ["cs", "fh", "cs"], ["cs", "cs"], ["fh", "fh", "fh"], ["cs", "cs", "cs"]]
	}
}

var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false
var current_level: int = 1
const ENEMY_DESTRUCTION_DELAY: float = 0.5
const TILE_SIZE = 160
const INCINERATE_COLUMN_THRESHOLD: float = 9.0
var INCINERATE_X_LIMIT: float
#Dizionario dei nemici rimanenti con una lista di oggetti da spawnare
var spawn_queue = []

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
	
	print("--- DEBUG READY ---")
	print("Livello rilevato: ", current_level)
	print("Scene Path: ", path)
	print("-------------------")
	
	if tilemap:
		INCINERATE_X_LIMIT = tilemap.global_position.x + (INCINERATE_COLUMN_THRESHOLD + 1.0) * TILE_SIZE
		print("Limite X Incenerimento impostato a: ", INCINERATE_X_LIMIT)
	else:
		push_error("TileMap non è assegnata in enemy_spawner, il limite X potrebbe essere errato.")
		INCINERATE_X_LIMIT = (INCINERATE_COLUMN_THRESHOLD + 10) * TILE_SIZE
	
	if initial_delay_timer:
		initial_delay_timer.wait_time = grace_time
		initial_delay_timer.start()
		print("DEBUG: Timer iniziale avviato (", grace_time, " secondi)")
	else:
		start_wave()


func _on_initial_delay_timeout():
	print("Ritardo iniziale terminato. Avvio prima ondata.")
	start_wave()


func start_wave():
	if is_wave_active or current_wave >= waves.size():
		print("DEBUG: Impossibile avviare ondata - Ondata già attiva.")
		return
		
	current_wave += 1
	if current_wave > 1:
		emit_signal("wave_completed", current_wave)
	
	is_wave_active = true
	spawn_queue.clear()

	# Recupera il dizionario del livello
	var level_data = level_patterns.get(current_level, level_patterns[1])
	# Recupera il pattern dell'ondata attuale
	var patterns = level_data.get(current_wave, level_data[1])
	# Recupera l'intervallo (sicurezza: se waves è corto, usa l'ultimo intervallo disponibile)
	var wave_config = waves[min(current_wave - 1, waves.size() - 1)]
	var interval = wave_config["interval"]
	print("--- DEBUG ONDATA ", current_wave, " ---")
	print("Pattern Originale (Dizionario): ", patterns)
	# --- LOGICA DI SHUFFLE DELLE RIGHE ---
	var physical_rows = []
	for i in range(GameConstants.ROW):
		physical_rows.append(i)
	physical_rows.shuffle() # Mischia l'ordine delle righe (es: [2, 0, 1])
	print("Ordine Righe Fisiche (Dopo Shuffle): ", physical_rows)
	print("--- RISULTATO ACCOPPIAMENTO ---")
	
	# 1. Assegna ogni pattern a una riga fisica (già mischiata)
	for pattern_index in patterns.size():
		# Evita crash se il pattern ha più righe di quelle permesse dal gioco
		if pattern_index >= physical_rows.size(): break
		var row = physical_rows[pattern_index]
		var enemies_in_row = patterns[pattern_index]
		
		print("Corsia Pattern [", pattern_index, "] (", enemies_in_row, ") -> Assegnata alla RIGA FISICA: ", row)

		# 2. Aggiungi i nemici di questa riga alla coda globale
		for pos in enemies_in_row.size():
			spawn_queue.append({
				"type": enemies_in_row[pos],
				"row": row,
				"delay": (pos * interval) + randf_range(0, 0.5)
			})

	# Ordiniamo la coda per tempo di delay per farli uscire in ordine cronologico
	spawn_queue.sort_custom(func(a, b): return a["delay"] < b["delay"])
	
	enemies_to_spawn = spawn_queue.size()
	
	print("Nemici totali da spawnare: ", enemies_to_spawn)
	print("Righe fisiche assegnate (shuffled): ", physical_rows)
	print("---------------------------------")
	
	label_wave.text = "Ondata: " + str(current_wave)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	wave_number.text = "Ondata " + str(current_wave)
	wave_number.visible = true
	animation_player.play("wave_intro")
	
	# Usiamo un Timer o il _process per svuotare la coda
	wave_timer.wait_time = 0.1 # Frequenza di controllo della coda
	wave_timer.start()


func _on_wave_timer_timeout():
	# In questo nuovo sistema, usiamo il tempo trascorso dall'inizio dell'ondata
	# Ma per semplicità, spawniamo il prossimo nemico se presente
	if not spawn_queue.is_empty():
		var data = spawn_queue.pop_front()
		spawn_enemy(data["type"], data["row"])
		
		if not spawn_queue.is_empty():
			# Impostiamo il timer per il prossimo nemico in coda
			var next_delay = spawn_queue[0]["delay"] - data["delay"]
			wave_timer.start(max(0.1, next_delay))
		else:
			enemies_to_spawn = 0
			_check_wave_completion()

func _on_next_wave_delay_timeout():
	print("Ritardo tra ondate terminato. Avvio prossima ondata.")
	start_wave()


func spawn_enemy(type: String, row: int):
	var enemy = all_enemy_scenes[type].instantiate()
	var spawn_cell = Vector2i(GameConstants.COLUMN + 2, row)
	var center_pos = tilemap.map_to_local(spawn_cell)
	
	enemy.global_position = tilemap.to_global(center_pos)
	enemy.riga = row
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated_with_row").bind(row))
	
	add_child(enemy)
	enemies_alive += 1
	print("DEBUG: Spawned ", type, " in riga ", row, " (Vivi: ", enemies_alive, ")")
	if is_blackout_level and enemy.has_method("set_blackout_state"):
		enemy.set_blackout_state(true)
	label_enemies.text = "Nemici: " + str(enemies_alive)


func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	check_enemies_for_next_wave()


func kill_all():
	# Forziamo la fine dello spawn e l'eliminazione dei nemici.
	enemies_to_spawn = 0
	
	var children_to_kill = []
	for child in get_children():
		if child.has_method("die"):
			child.disconnect("enemy_defeated", Callable(self, "_on_enemy_defeated_with_row"))
			children_to_kill.append(child)
			enemies_alive -= 1
	
	for child in children_to_kill:
		child.queue_free()
	
	enemies_alive = max(0, enemies_alive)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	# Se l'onda era attiva, forziamo il passaggio 
	# alla successiva (incrementando current_wave e avviando il timer)
	if is_wave_active:
		is_wave_active = false
		wave_timer.stop()
		#_check_wave_completion()
	
	# La funzione di check gestirà l'avvio immediato dell'ondata successiva 
	# o la vittoria (poiché enemies_alive = 0).
	check_enemies_for_next_wave()


# Funzione asincrona che TurretManager chiamerà per distruggere i robot
func destroy_robots_in_row_with_animation(row: int):
	var killed_count = 0
	
	for child in get_children():
		if child.is_in_group("Robot") and child.has_method("die") and is_instance_valid(child):
			var robot = child
			var can_incinerate = (
				robot.riga == row and
				robot.global_position.x <= INCINERATE_X_LIMIT
			)
			if can_incinerate:
				child.queue_free()
				killed_count += 1
	
	# Aggiorna il contatore globale dopo l'attesa
	enemies_alive = max(0, enemies_alive - killed_count)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	print("🔥 %d robot inceneriti (animati) in riga %d. Nemici rimanenti: %d" % [killed_count, row, enemies_alive])
	
	# Verifica la fine dell'ondata
	check_enemies_for_next_wave()


func _check_wave_completion():
	# Questa funzione viene chiamata SOLO quando 
	# lo spawn è terminato (enemies_to_spawn = 0).
	if enemies_to_spawn <= 0 and is_wave_active:
		is_wave_active = false
		
		if current_wave < waves.size():
			if next_wave_delay_timer:
				print("Spawn completato. Avvio timer di ritardo di %s secondi." % inter_wave_delay)
				next_wave_delay_timer.wait_time = inter_wave_delay
				next_wave_delay_timer.start()
			
			# Controlla immediatamente se i nemici sono già zero per avvio anticipato
			check_enemies_for_next_wave()
		else:
			print("Ultima ondata spawnata. Attendo sconfitta nemici per vittoria.")
			# L'ultima ondata è stata spawnata, chiamiamo il check per la vittoria
			check_enemies_for_next_wave()


func check_enemies_for_next_wave():
	# Avviene se enemies_alive = 0 E siamo in fase di transizione (lo spawn è finito)
	if enemies_alive <= 0 and not is_wave_active:
		# Se il timer è attivo, fermalo (Avvio Anticipato)
		if next_wave_delay_timer and next_wave_delay_timer.is_stopped() == false:
			next_wave_delay_timer.stop()
			print("Avvio prossima ondata anticipato: tutti i nemici sconfitti!")
			
		if current_wave < waves.size():
			start_wave()
		else:
			emit_signal("victory")
			if "AudioManager" in get_tree().get_nodes_in_group("singleton"):
				AudioManager.play_victory_music()
			emit_signal("level_completed")

func _on_enemy_defeated_with_row(_row_index: int):
	_on_enemy_defeated() # Richiama la logica standard
