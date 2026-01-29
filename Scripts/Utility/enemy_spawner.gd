
extends Node

signal level_completed
signal victory
signal wave_completed(wave_number)

@export var initial_grace_time = 15.0
@export var grace_time = 5.0
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
	"r": preload("res://Scenes/Robots/romba.tscn"),
	"w": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"m": preload("res://Scenes/Robots/mecha_freezer.tscn"),
	"f": preload("res://Scenes/Robots/fire_hydrant.tscn"),
	"c": preload("res://Scenes/Robots/cassa_schierata.tscn")
}

# Modifica 'interval' per cambiare quanto velocemente escono i nemici (secondi tra uno e l'altro)
var waves = [
	{ "interval": 4.0 }, # Ondata 1
	{ "interval": 2.0 }, # Ondata 2
	{ "interval": 2.0 }, # Ondata 3
	{ "interval": 1.0 }  # Ondata 4  
]

# Variabile per definire i pattern fissi per livello
# STRUTTURA:
# Numero Livello: {
#    Numero Ondata: [ [Corsia 1], [Corsia 2], [Corsia 3], [Corsia 4], [Corsia 5] ]
# }
var level_patterns = {
	1: { # LIVELLO 1
		# TOT = 4 -> 4 roomba
		1: ["2r", "0r", "2r", "0r", "0r"],
		# TOT = 10 -> 10 romba
		2: ["2r", "3r", "0r", "3r", "2r"],
		# TOT = 23 -> 23 romba
		3: ["7r", "3r", "4r", "5r", "4r"],
		# TOT = 41 -> 41 romba
		4: ["8r", "7r", "10r", "8r", "8r"]
	},
	2: { # LIVELLO 2
		# TOT = 2 -> 1 roomba, 1 weed eater
		1: ["1w", "1r", "0w, 0r", "0r", "0r"],
		# TOT = 7 -> 4 roomba, 3 weed eater
		2: ["0w", "1r, 1w", "1w, 1r", "0r", "1r, 1w, 1r"],
		# TOT = 27 -> 16 roomba, 11 weed eater
		3: ["2r, 1w, 3r", "2w, 2r, 2w", "3r, 2w", "1w, 1r, 1w, 1r", "2r, 2w, 2r"],
		# TOT = 38 -> 23 roomba, 15 weed eater
		4: ["4r, 2w, 3r", "2w, 4r, 2w", "3r, 3w", "1w, 2r, 2w, 1r", "3r, 3w, 3r"]
	},
	3: { # LIVELLO 3
		# TOT = 1 -> 1 mecha freezer
		1: ["1m", "0r", "0m", "0r", "0w"],
		# TOT = 12 -> 3 roomba, 1 weed eater, 2 mecha freezer 
		2: ["1m, 2r", "1m, 1r, 1w", "0w, 0r", "0r", "0w, 0m"],
		# TOT = 27 -> 17 roomba, 7 weed eater, 3 mecha freezer
		3: ["2w, 4r", "2r, 2w", "2w, 1m, 6r", "1m, 2r, 1w", "3r, 1m"],
		# TOT = 37 -> 21 roomba, 11 weed eater, 5 mecha freezer
		4: ["1m, 5r, 2w", "1m, 2w, 2r", "1m, 2w, 2r", "1m, 2r, 2w, 3r", "1m, 2r, 1w, 2r, 1w, 3r"]
	},
	4: { # LIVELLO 4
		# TOT = 4 -> 2 roomba, 0 weed eater, 0 mecha freezer, 2 fire hydrant
		1: ["1f, 1r", "0m", "1f, 1r", "0w", "0r"],
		# TOT = 14 -> 3 roomba, 4 weed eater, 1 mecha freezer, 6 fire hydrant
		2: ["1m, 2f, 2w", "1r, 2f, 2w", "2r, 2f", "0w", "0w, 0f"],
		# TOT = 27 -> 10 roomba, 6 weed eater, 2 mecha freezer, 9 fire hydrant
		3: ["1w, 1f, 3r", "1m, 2r, 1w, 1f, 1w, 1r", "3f, 2w", "1m, 1w, 2r, 2f", "2f, 2r"],
		# TOT = 45 -> 17 roomba, 8 weed eater, 4 mecha freezer, 12 fire hydrant
		4: ["1m, 2r, 3f, 1w", "3r, 1f, 1m, 2r, 2w, 1f, 1w, 3r", "2f, 2w, 1f, 3r", "2m, 1w, 3f, 2r", "1m, 3f, 2r, 1w, 2f"]
	},
	5: { # LIVELLO 5
		# TOT = 2 -> 0 roomba, 0 weed eater, 0 mecha freezer, 0 fire hydrant, 2 cassa schierata
		1: ["1c", "0f", "1c", "0m", "0w"],
		# TOT = 12 -> 3 roomba, 3 weed eater, 0 mecha freezer, 2 fire hydrant, 4 cassa schierata
		2: ["1c, 1f, 2r", "1w, 1r, 2c", "0f, 0w", "1c, 1f, 1w", "0r, 0c"],
		# TOT = 28 -> 9 roomba, 6 weed eater, 2 mecha freezer, 3 fire hydrant, 7 cassa schierata
		3: ["2c, 1w, 3r, 1f", "1f, 1w", "1m, 1w, 2r, 2f, 1c", "1m, 1w, 2c", "1w, 2r, 1w, 2c"],
		# TOT = 55 -> 20 roomba, 10 weed eater, 5 mecha freezer, 9 fire hydrant, 10 cassa schierata
		4: ["1m, 4r, 1w, 2c, 1f, 1w, 3r", "1m, 1c, 1f, 2w, 1c, 2r", "1m, 2w, 1f, 1c, 4r", "1m, 2f, 1c, 3r, 1c, 1f", "1m, 3c, 2w, 3r, 3f, 2w, 1r"]
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
# Nuovo dizionario per gestire le code separate per ogni riga fisica
var spawn_queues = {}

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
		if current_wave == 0:
			initial_delay_timer.wait_time = initial_grace_time
		else:
			initial_delay_timer.wait_time = grace_time
		initial_delay_timer.start()
		print("DEBUG: Timer iniziale avviato (", grace_time, " secondi)")
	else:
		start_wave()


func _on_initial_delay_timeout():
	if current_wave == 0:
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
	spawn_queues.clear()
	enemies_to_spawn = 0

	# Recupera il dizionario del livello
	var level_data = level_patterns.get(current_level, level_patterns[1])
	# Recupera il pattern dell'ondata attuale
	var patterns = level_data.get(current_wave, level_data[1])
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
		#Prende la stringa "3xromba"
		var raw_pattern = patterns[pattern_index]
		var enemies_in_row = []
		if raw_pattern is String:
			enemies_in_row = unpack_pattern(raw_pattern)
		else:
			enemies_in_row = raw_pattern
		
		spawn_queues[row] = []
		
		print("Corsia Pattern [", pattern_index, "] (", enemies_in_row, ") -> Assegnata alla RIGA FISICA: ", row)

		# 2. Aggiungi i nemici di questa riga alla coda
		for robot_name in enemies_in_row:
			spawn_queues[row].append(robot_name)
			enemies_to_spawn += 1
	
	print("Nemici totali da spawnare: ", enemies_to_spawn)
	print("Righe fisiche assegnate (shuffled): ", physical_rows)
	print("---------------------------------")
	
	label_wave.text = "Ondata: " + str(current_wave)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	wave_number.text = tr("wave") + " " + str(current_wave)
	wave_number.visible = true
	print("--- LOG: Code generate con successo ---")
	debug_spawn_queues()
	animation_player.play("wave_intro")
	
	# Usiamo un Timer o il _process per svuotare la coda
	wave_timer.wait_time = 0.1 # Frequenza di controllo della coda 
	wave_timer.start()


func _on_wave_timer_timeout():
	# Individuiamo le code che non sono ancora vuote
	var active_rows = []
	for r in spawn_queues.keys():
		if not spawn_queues[r].is_empty():
			active_rows.append(r)

	# Se ci sono ancora robot da far uscire...
	if not active_rows.is_empty():
		# 2. SCEGLI RIGA RANDOM (tra quelle che hanno robot)
		var random_row = active_rows[randi() % active_rows.size()]
		
		# 3. POP del robot in cima alla coda di quella specifica riga
		var enemy_type = spawn_queues[random_row].pop_front()
		
		# 4. SPAWN
		spawn_enemy(enemy_type, random_row)
		enemies_to_spawn -= 1
		debug_spawn_queues()
		
		print("DEBUG: Pescato ", enemy_type, " da riga ", random_row, ". Rimanenti da spawnare: ", enemies_to_spawn)
		
		# 5. WAIT TIME (intervallo dell'ondata)
		var wave_config = waves[min(current_wave - 1, waves.size() - 1)]
		wave_timer.start(wave_config["interval"])
	else:
		# TUTTI I ROBOT SONO SPAWNATI (anche se sono ancora vivi)
		print("DEBUG: Tutti i robot spawnati. Ondata ", current_wave, " conclusa come spawn.")
		is_wave_active = false 
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
	print("--- DEBUG KILL ALL (SKIP ATTESA) ---")
	# 1. Fermiamo tutto lo spawn corrente
	enemies_to_spawn = 0
	is_wave_active = false
	wave_timer.stop()
	spawn_queues.clear()
	
	# 2. Fermiamo eventuali timer di attesa tra ondate già partiti
	if next_wave_delay_timer:
		next_wave_delay_timer.stop()
	
	# 3. Eliminiamo i nemici in campo
	var children_to_kill = []
	for child in get_children():
		# Verifichiamo se è un robot (usando il gruppo o il metodo die)
		if child.is_in_group("Robot") or child.has_method("die"):
			children_to_kill.append(child)
	
	for child in children_to_kill:
		child.queue_free()
	
	# 4. Resettiamo i contatori
	enemies_alive = 0
	label_enemies.text = "Nemici: 0"
	
	# 5. LOGICA DI SALTO IMMEDIATO
	if current_wave < waves.size():
		print("Kill All: Salto l'attesa. Avvio ondata ", current_wave + 1)
		start_wave() # Chiamata diretta senza timer
	else:
		# Se era l'ultima ondata, triggeriamo la vittoria
		print("Kill All: Ultima ondata completata. Vittoria!")
		emit_signal("victory")
		if "AudioManager" in get_tree().get_nodes_in_group("singleton"):
			AudioManager.play_victory_music()
		emit_signal("level_completed")


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
	if enemies_to_spawn <= 0:
		if current_wave < waves.size():
			if next_wave_delay_timer:
				if next_wave_delay_timer.is_stopped():
					print("Spawn completato. Avvio timer di ritardo di %s secondi." % inter_wave_delay)
					next_wave_delay_timer.wait_time = inter_wave_delay
					next_wave_delay_timer.one_shot = true
					next_wave_delay_timer.start()
			# Controlla immediatamente se i nemici sono già zero per avvio anticipato
			if enemies_alive <= 0:
				check_enemies_for_next_wave()
		else:
			print("Ultima ondata spawnata. Attendo sconfitta nemici per vittoria.")

func check_enemies_for_next_wave():
	# Avviene se enemies_alive = 0 E siamo in fase di transizione (lo spawn è finito)
	if enemies_alive <= 0 and not is_wave_active:
		if current_wave < waves.size():
			if next_wave_delay_timer:
				print("DEBUG: Tutti I nemici Ondata Uccisi! Prossima ondata tra 10 secondi.")
				next_wave_delay_timer.stop() 
				next_wave_delay_timer.wait_time = 10.0 #Timer in caso di completa uccisione nemici tra ondate
				next_wave_delay_timer.one_shot = true
				next_wave_delay_timer.start()
		else:
			emit_signal("victory")
			if "AudioManager" in get_tree().get_nodes_in_group("singleton"):
				AudioManager.play_victory_music()
			emit_signal("level_completed")

func _on_enemy_defeated_with_row(_row_index: int):
	_on_enemy_defeated() # Richiama la logica standard

func debug_spawn_queues():
	print("\n=== [DEBUG CODE DI SPAWN] Ondata: ", current_wave, " ===")
	if spawn_queues.is_empty():
		print(" > Code attualmente vuote.")
	else:
		for row in spawn_queues.keys():
			var coda = spawn_queues[row]
			if coda.is_empty():
				print(" > Riga ", row, ": [ VUOTA ]")
			else:
				# Stampa la riga e l'elenco dei nemici (es. ["romba", "we9k"])
				print(" > Riga ", row, ": ", str(coda), " (Tot: ", coda.size(), ")")
	print("Nemici totali ancora da far uscire: ", enemies_to_spawn)
	print("===============================================\n")


## Converte la stringa "3r"
## Esempio: "2r, mf" diventa ["r", "r", "m"]
func unpack_pattern(pattern_string: String) -> Array:
	var final_list = []
	# Dividiamo per virgola se vuoi mettere tipi diversi nella stessa riga (es: "2xromba, 1xwe9k")
	var parts = pattern_string.split(",")
	
	for part in parts:
		part = part.strip_edges() # Rimuove spazi inutili
		if part.length() >= 2:
			# Prende tutto tranne l'ultimo carattere (il numero)
			var count = int(part.left(-1))
			# Prende l'ultimo carattere (la chiave: r, w, m, f o c)
			var type = part.right(1)
			
			for i in range(count):
				final_list.append(type)
		else:
			# Se scrivi solo "r", lo aggiunge una volta sola
			final_list.append(part)
			
	return final_list
