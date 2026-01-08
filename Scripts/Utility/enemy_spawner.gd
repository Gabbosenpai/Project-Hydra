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
@export var is_blackout_level: bool = false
@export var weight_penalty: float = 10.0  # Quanto "pesa" un nemico in più sulla riga
@export var weight_recovery: float = 2.0 # Quanto velocemente la riga torna appetibile nel tempo

var all_enemy_scenes = {
	"romba": preload("res://Scenes/Robots/romba.tscn"),
	"we9k": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"mf": preload("res://Scenes/Robots/mecha_freezer.tscn"),
	"fh": preload("res://Scenes/Robots/fire_hydrant.tscn"),
	"cs": preload("res://Scenes/Robots/cassa_schierata.tscn")
}
var level_enemy_pool = {
	1: ["romba"],
	2: ["we9k","mf","fh"],
	3: ["cs"],
	4: ["romba","we9k","mf","fh","cs"],
	5: ["romba","we9k","mf","fh","cs"]
}
var waves = [
	{ "count": 13, "interval": 1.5 },
	{ "count": 16, "interval": 1.8 },
	{ "count": 19, "interval": 2.0 },
	{ "count": 22, "interval": 2.5 }
]
var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false
var current_level: int = 1
const ENEMY_DESTRUCTION_DELAY: float = 0.5
const TILE_SIZE = 160
const INCINERATE_COLUMN_THRESHOLD: float = 9.0
var INCINERATE_X_LIMIT: float
var row_weights = []
var remaining_enemies_queue = {}

func _process(delta):
	# Diminuisce lentamente tutti i pesi nel tempo
	for i in range(row_weights.size()):
		if row_weights[i] > 0:
			row_weights[i] = max(0.0, row_weights[i] - weight_recovery * delta)
	if Input.is_action_just_pressed("ui_focus_next"): # Premi TAB per vedere i pesi
		print("Pesi attuali righe: ", row_weights)

func _ready():
	randomize()
	row_weights.resize(GameConstants.ROW)
	row_weights.fill(0.0)
	var path = get_tree().current_scene.scene_file_path
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(path)
	if result:
		current_level = int(result.get_string())
	else:
		current_level = 1
	
	print("Spawner avviato in livello: ", current_level, " (path=", path, ")")
	
	if tilemap:
		INCINERATE_X_LIMIT = tilemap.global_position.x + (INCINERATE_COLUMN_THRESHOLD + 1.0) * TILE_SIZE
		print("Limite X Incenerimento impostato a: ", INCINERATE_X_LIMIT)
	else:
		push_error("TileMap non è assegnata in enemy_spawner, il limite X potrebbe essere errato.")
		INCINERATE_X_LIMIT = (INCINERATE_COLUMN_THRESHOLD + 10) * TILE_SIZE
	
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
		
	current_wave += 1
	
	if current_wave > 1: # Emetti il segnale solo dalla seconda ondata in poi
		emit_signal("wave_completed", current_wave)
		print("✅ Segnale 'wave_completed' emesso (Inizio Onda ", current_wave, ").")
	
	#Recupera i dati (quanti nemici e ogni quanto tempo) dall'array 'waves'
	var wave = waves[current_wave - 1]
	enemies_to_spawn = wave["count"]
	wave_timer.wait_time = wave["interval"]
	
	#Svuota la coda dell'ondata precedente
	remaining_enemies_queue.clear()
	
	# Recupera i tipi di nemici permessi per questo specifico livello
	var pool = level_enemy_pool.get(current_level, ["romba"])
	#base_share: quanti nemici spettano "di base" a ogni tipologia (divisione intera)
	var base_share = enemies_to_spawn / pool.size()
	## remainder: i nemici che avanzano se la divisione non è perfetta (resto)
	var remainder = enemies_to_spawn % pool.size()
	
	# riempimento della coda di spawn
	for i in range(pool.size()):
		var type = pool[i]
		var quantity = base_share
		# Distribuisce i nemici rimasti dal resto uno alla volta ai primi tipi della lista
		if i < remainder:
			quantity += 1
		# Registra nel dizionario: "TipoNemico": QuantitàFissa
		remaining_enemies_queue[type] = quantity
	
	is_wave_active = true
	
	label_wave.text = "Ondata: " + str(current_wave)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	label_wave_center.text = "ONDATA " + str(current_wave)
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
	#Recupero i nemici validi per questo livello
	var pool = level_enemy_pool.get(current_level, ["romba"])
	
	#Decido quale nemico creare in base alle percentuali
	var choice = ""
	var roll = randf() # Estrae un numero tra 0.0 e 1.0
	
	# Per modificare le probabilità, usa la "Somma Progressiva":
	# 1. Decidi la % per ogni nemico ne caso 3 (es. 70%, 20%, 10%)
	# 2. Il primo numero è la % del primo nemico (0.70)
	# 3. I successivi numeri sono la somma del precedenti + attuale nel caso 3 (0.70 + 0.20 = 0.90)
	# 4. L'ultimo nemico prende automaticamente il resto ad esempio nel caso 3 0.1 ovvero (il 10%)
	
	# Usiamo match (stessa logica di switch) per creare regole diverse in base a quanti tipi di nemici sono presenti nel pool
	match pool.size():
		1:
			#CASO 1 NEMICO: Se c'è solo un nemico, viene scelto sempre (100% di probabilità)
			choice = pool[0] # 100%
		2:
			# CASO 2 NEMICI: Dividiamo il range 0.0-1.0 in due parti
			if roll < 0.80: choice = pool[0] # 80%
			else:           choice = pool[1] # 20%
		3:
			# CASO 3 NEMICI: Tre fasce di probabilità
			if roll < 0.60:   choice = pool[0] # 60%
			elif roll < 0.99: choice = pool[1] # 39%
			else:             choice = pool[2] # 1%
		4:
			# CASO 4 NEMICI: quattro fasce di probabilità
			if roll < 0.50:   choice = pool[0] # 50%
			elif roll < 0.80: choice = pool[1] # 30%
			elif roll < 0.95: choice = pool[2] # 15%
			else:             choice = pool[3] # 5%
		5:
			# CASO 5 NEMICI: cinque fasce di probabilità
			if roll < 0.40:   choice = pool[0] # 40%
			elif roll < 0.70: choice = pool[1] # 30%
			elif roll < 0.90: choice = pool[2] # 20%
			elif roll < 0.99: choice = pool[3] # 9%
			else:             choice = pool[4] # 1%
		_:
			# Fallback per sicurezza (casuale puro)
			choice = pool.pick_random()
	
	#Decide DOVE crearlo ovvero nella riga meno affollata
	var row = _get_weighted_row()
	row_weights[row] += weight_penalty
	
	#Crea l'oggetto nella scena e lo posiziona
	var enemy = all_enemy_scenes[choice].instantiate()
	var spawn_cell = Vector2i(GameConstants.COLUMN + 2, row)
	var center_pos = tilemap.map_to_local(spawn_cell)
	enemy.global_position = tilemap.to_global(center_pos)
	enemy.riga = row
	
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated_with_row").bind(row))
	add_child(enemy)
	
	enemies_alive += 1
	if is_blackout_level:
		# Devi anche comunicare al robot che il livello è in blackout
		if enemy.has_method("set_blackout_state"):
			enemy.set_blackout_state(true)
	label_enemies.text = "Nemici: " + str(enemies_alive)


func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	check_enemies_for_next_wave()


func kill_all():
	# Forziamo la fine dello spawn e l'eliminazione dei nemici.
	enemies_to_spawn = 0
	row_weights.fill(0.0)
	
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
				row_weights[row] = max(0.0, row_weights[row] - weight_penalty)
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
			# Gestione vittoria finale
			victory_screen.visible = true
			
			if "AudioManager" in get_tree().get_nodes_in_group("singleton"):
				AudioManager.play_victory_music()
			emit_signal("level_completed")

func _get_weighted_row() -> int:
	# Lista che conterrà gli indici delle righe "migliori" (quelle meno affollate)
	var best_rows = []
	# Inizializziamo il peso minimo prendendo come riferimento il valore della prima riga
	var min_weight = row_weights[0]
	
	# Cicliamo attraverso tutti i pesi registrati per trovare il valore più basso attuale
	for w in row_weights:
		if w < min_weight:
			min_weight = w
			
	# Identifichiamo tutte le righe che hanno il peso minimo
	for i in range(row_weights.size()):
		if row_weights[i] <= min_weight:
			best_rows.append(i)
	
	# Scegli a caso tra le migliori righe disponibili
	return best_rows[randi() % best_rows.size()]

func _on_enemy_defeated_with_row(row_index: int):
	# Sottraiamo la penalità di peso perché il nemico è stato rimosso. 
	# Questo rende la corsia nuovamente disponibile e appetibile per nuovi spawn.
	row_weights[row_index] -= weight_penalty

# Se a causa del recupero naturale nel tempo il peso è sceso molto, evitiamo che diventi negativo
	if row_weights[row_index] < 0.0:
		row_weights[row_index] = 0.0
		
# Richiama la funzione principale per decrementare il numero totale di nemici vivi e controllare se l'ondata è terminata.
	_on_enemy_defeated()
