class_name baseLevel
extends Node2D

signal game_over

@onready var turret_manager = $TurretManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI
@onready var grid_initializer = $GridInitializer
@export var tilemap: TileMap
var incinerator_used_in_row: Array = [false, false, false, false, false]
var is_game_over: bool = false 
var OST: AudioStream
var current_level

# Variabili per Blackout
var is_blackout_level: bool = false
var active_shift_rows: Array = []

# Variabili per le luci intermittenti
var blackout_light_timer: Timer = null
const LIGHT_FLASH_DURATION: float = 1.0
const LIGHT_FLASH_INTERVAL: float = 15.0

#variabile per tracciare i nodi luce
var blackout_lights: Array[ColorRect] = []


func _ready():
	# 1. Assegna il dizionario inizializzato a TurretManager
	if grid_initializer:
		turret_manager.set_grid_data(grid_initializer.dic)
	else:
		# Blocca il gioco se il nodo fondamentale non c'è
		push_error("ERRORE: Il nodo GridInitializer non è stato trovato o collegato.")
		return

	print("DEBUG: current_level in _ready(): ", current_level)
		
	if current_level == "res://Scenes/Levels/Lvl5.tscn":
		is_blackout_level = true
		_init_blackout_lights()
		_create_blackout_light_nodes()
	
	# 2. Connessioni dei segnali COMUNI
	turret_manager.connect("turret_removed", Callable(self, "_on_turret_removed"))
	ui_controller.connect("kill_all", Callable(enemy_spawner, "kill_all"))
	ui_controller.connect("select_turret", Callable(turret_manager, "select_turret"))
	ui_controller.connect("remove_mode", Callable(turret_manager, "remove_mode"))
	connect("game_over", Callable(ui_controller, "show_game_over"))
	
	enemy_spawner.connect("level_completed", Callable(self, "_on_level_completed"))
	enemy_spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))
	
	AudioManager.play_music(OST)
	
# Implementa questo metodo in ogni livello figlio per caricare la musica unica.
func _set_level_music(levelOST: AudioStream):
	OST = levelOST
	
func set_current_level(level):
	current_level = level
	ui_controller.current_level=level
	print("DEBUG: Livello Corrente Impostato su: ", current_level)
	
# Implementa questo metodo per specificare quale livello sbloccare.
func _on_level_completed():
	push_warning("Il livello figlio non ha implementato _on_level_completed(). Nessun livello sbloccato.")

# --- Logica Condivisa (Non va modificata nei figli) ---

# Chiamata quando un nemico raggiunge la base del giocatore.
func enemy_reached_base(robot_instance: Node2D):
	# *** 0. CONTROLLO DI SICUREZZA ***
	# Blocca immediatamente se il Game Over è già stato innescato da un altro robot.
	if is_game_over:
		return 
		
	var row = robot_instance.riga
	
	# Assicurati che 'row' sia un indice valido per l'array.
	if row < 0 or row >= incinerator_used_in_row.size():
		push_error("ERRORE: Riga robot non valida: " + str(row))
		return

	# 1. Distruzione Torretta in Colonna 0 (per coerenza)
	turret_manager.destroy_turret_at_incinerator_pos(row)
	
	# 2. Logica Inceneritore PER RIGA
	if incinerator_used_in_row[row]:
		# SECONDA VOLTA NELLA STESSA RIGA: GAME OVER
		print("🔥 GAME OVER: Inceneritore GIA' usato in riga ", row)
		
		# *** BLOCCO DEL GIOCO E SEGNALE ***
		is_game_over = true # Imposta lo stato prima di emettere il segnale
		emit_signal("game_over")
		
	else:
		# PRIMA VOLTA NELLA RIGA: Salva la vita e segna come usata
		print("✅Inceneritore Attivato in riga ", row)
		incinerator_used_in_row[row] = true
		
		# Distrugge tutti gli oggetti nella riga
		kill_all_in_row(row)
	
# 🔥 Nuova funzione per incenerire tutti gli oggetti in una riga
func kill_all_in_row(row: int):
	print("🔥 Attivazione Inceneritore: Rimuovo tutti gli oggetti in riga ", row)
	# ⚡️ Feedback Visivo Semplice: Applica un flash rosso a tutti gli oggetti prima di distruggerli
	apply_incinerate_flash(row)
	
	# Incenerisce i Robot (DELEGA ALLO SPINNER PER GESTIRE enemies_alive)
	# Assicurati che enemy_spawner abbia il metodo destroy_robots_in_row(row)
	if enemy_spawner.has_method("destroy_robots_in_row"):
		enemy_spawner.destroy_robots_in_row(row)
	else:
		push_error("ERRORE: enemy_spawner non ha il metodo destroy_robots_in_row.")
			
	# Incenerisce le Torrette (DELEGA AL MANAGER)
	turret_manager.destroy_all_turrets_in_row(row)

# ⚡️ Funzione per applicare un flash rosso e un suono
func apply_incinerate_flash(row: int):
	# 1. Flash sulle Torrette
	for cell_key in turret_manager.turrets.keys():
		var turret = turret_manager.turrets[cell_key]
		if cell_key.y == row and is_instance_valid(turret):
			flash_sprite_red(turret)
			
	# 2. Flash sui Robot
	for child in enemy_spawner.get_children():
		if child.is_in_group("Robot") and child.riga == row and child.has_method("robot_sprite"):
			flash_sprite_red(child)

# Funzione ausiliaria per il flash (da mettere anche nel turret_manager se necessario)
func flash_sprite_red(node_with_sprite):
	# Assumiamo che il nodo abbia un AnimatedSprite2D chiamato 'robot_sprite' o 'tower_sprite'
	var sprite = null
	if node_with_sprite.has_node("RobotSprite"):
		sprite = node_with_sprite.get_node("RobotSprite")
	elif node_with_sprite.has_node("TowerSprite"):
		sprite = node_with_sprite.get_node("TowerSprite")
	
	if sprite:
		var original_modulate = sprite.modulate
		sprite.modulate = Color(1.5, 0.5, 0.5) # Rosso acceso
		
		# Timer breve per far tornare il colore normale (0.2 secondi)
		var timer = get_tree().create_timer(0.2)
		await timer.timeout
		
		# Nota: L'oggetto è già stato distrutto da kill_all_in_row,
		# quindi spesso il reset del colore non è strettamente necessario, 
		# ma lo lasciamo per completezza se l'ordine delle chiamate fosse invertito.
		if is_instance_valid(sprite):
			sprite.modulate = original_modulate


# Logica di default per la fine dell'ondata. 
func _on_wave_completed(_wave_number):
	print("Ondata completata ", _wave_number, " — sposto indietro le torrette.")
	
	if is_blackout_level:
		# Logica LvL5: Seleziona casualmente le righe
		if _wave_number == 1:
			active_shift_rows = []
		else:
			active_shift_rows = _get_random_rows_to_shift()
			
		turret_manager.move_turrets_back(_wave_number, active_shift_rows)
	else:
		# Logica Standard per gli altri livelli
		turret_manager.move_turrets_back(_wave_number)

func _init_blackout_lights():
	# Inizializza il timer se siamo in LvL5
	blackout_light_timer = Timer.new()
	blackout_light_timer.wait_time = LIGHT_FLASH_INTERVAL
	blackout_light_timer.autostart = true
	blackout_light_timer.timeout.connect(_on_blackout_light_timer_timeout)
	add_child(blackout_light_timer)
	
	# Simula l'illuminazione iniziale (se non è subito buio)
	_toggle_blackout_lights(true)

func _on_blackout_light_timer_timeout():
	# 1. Attiva le luci per LIGHT_FLASH_DURATION secondi
	_toggle_blackout_lights(true)
	await get_tree().create_timer(LIGHT_FLASH_DURATION).timeout
	
	# 2. Disattiva le luci
	_toggle_blackout_lights(false)
	

#Funzione per accendere/spegnere le luci
func _toggle_blackout_lights(should_be_visible: bool):
	for light_rect in blackout_lights:
		if is_instance_valid(light_rect):
			light_rect.visible = should_be_visible
	
	# Opzionale: Aggiungi un Overlay Grafico Globale per scurire l'area non illuminata
	# (Richiederebbe l'aggiunta di un nodo ColorRect/CanvasModulate sopra l'intero gioco, ma è più complesso)
	
	print("🚨 Luci Blackout: ", "ACCESE" if visible else "SPENTE")

# Funzione per selezionare un sottoinsieme casuale di righe
func _get_random_rows_to_shift() -> Array:
	var all_rows = range(GameConstants.ROW) # Assumendo GameConstants.ROW sia definito e corretto
	all_rows.shuffle()
	# Scegli un numero casuale di righe da spostare (es. tra 1 e 4)
	var num_rows = randi_range(1, min(4, all_rows.size()))
	var selected_rows = []
	for i in range(num_rows):
		selected_rows.append(all_rows[i])
	
	return selected_rows.duplicate() # Restituisce una copia pulita

# NUOVA FUNZIONE: Creazione dinamica dei ColorRect
func _create_blackout_light_nodes():
	var tile_size = 160 # La dimensione dei tuoi tile (TILE_SIZE da GridInitializer)
	var start_col = 7   # Colonna 7
	var num_cols = 3    # Colonne 7, 8, 9
	
	# Calcola la posizione globale dell'angolo in alto a sinistra della Colonna 7, Riga 0
	# Assumendo che il tuo TileMap sia un nodo figlio del Level (o abbia una posizione nota)
	var tilemap_pos = tilemap.global_position
	
	for y in range(GameConstants.ROW):
		var light_rect = ColorRect.new()
		
		# 1. Dimensione (3 colonne di larghezza)
		light_rect.size = Vector2(tile_size * num_cols, tile_size)
		
		# 2. Posizione (Dalla colonna 7 in poi)
		# Posizione X: (Colonna 7 * Dimensione Tile) + Posizione Globale del TileMap
		# Posizione Y: (Riga y * Dimensione Tile) + Posizione Globale del TileMap
		light_rect.global_position = tilemap_pos + Vector2(start_col * tile_size, y * tile_size)
		
		# 3. Aspetto (Colore giallastro/bianco per la luce, semi-trasparente)
		light_rect.color = Color(1.0, 1.0, 0.7, 0.25) # Giallo chiaro trasparente
		
		# 4. Inizialmente invisibile (blackout attivo)
		light_rect.visible = false
		
		add_child(light_rect)
		blackout_lights.append(light_rect)
	
	print("Creati %d nodi ColorRect per le luci del blackout." % blackout_lights.size())
