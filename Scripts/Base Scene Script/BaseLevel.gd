extends Node2D

signal game_over

@onready var turret_manager = $TurretManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI
@onready var grid_initializer = $GridInitializer
@export var tilemap: TileMap
var incinerator_used_this_level: bool = false

func _ready():
	# 1. Assegna il dizionario inizializzato a TurretManager
	if grid_initializer:
		turret_manager.set_grid_data(grid_initializer.dic)
	else:
		# Blocca il gioco se il nodo fondamentale non c'è
		push_error("ERRORE: Il nodo GridInitializer non è stato trovato o collegato.")
		return
	
	# 2. Connessioni dei segnali COMUNI
	turret_manager.connect("turret_removed", Callable(self, "_on_turret_removed"))
	ui_controller.connect("kill_all", Callable(enemy_spawner, "kill_all"))
	ui_controller.connect("select_turret", Callable(turret_manager, "select_turret"))
	ui_controller.connect("remove_mode", Callable(turret_manager, "remove_mode"))
	connect("game_over", Callable(ui_controller, "show_game_over"))
	
	enemy_spawner.connect("level_completed", Callable(self, "_on_level_completed"))
	enemy_spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))
	
	# 3. Chiamata ai metodi specifici che verranno implementati dai livelli figli
	_set_level_music()
	
	# Avvia la prima ondata DOPO che la griglia è stata inizializzata
	enemy_spawner.start_wave()

# Implementa questo metodo in ogni livello figlio per caricare la musica unica.
func _set_level_music():
	push_warning("Il livello figlio non ha implementato _set_level_music(). Nessuna musica verrà riprodotta.")
	
# Implementa questo metodo per specificare quale livello sbloccare.
func _on_level_completed():
	push_warning("Il livello figlio non ha implementato _on_level_completed(). Nessun livello sbloccato.")

# --- Logica Condivisa (Non va modificata nei figli) ---

# Chiamata quando un nemico raggiunge la base del giocatore.
func enemy_reached_base(robot_instance: Node2D):
	var row = robot_instance.riga
	
	# 1. Distruzione Torretta in Colonna 0 (e recupero materiali)
	turret_manager.destroy_turret_at_incinerator_pos(row)
	
	# 2. Logica Inceneritore
	if incinerator_used_this_level:
		# SECONDA VOLTA: GAME OVER
		print("🔥 GAME OVER: Inceneritore già chiuso, un altro robot è passato in riga ", row)
		# Aggiungi un piccolo flash di Game Over qui se vuoi, ma la logica è completa
		emit_signal("game_over")
	else:
		# PRIMA VOLTA: Salva la vita
		print("✅ Inceneritore Attivato! Distrugge il robot e la riga ", row)
		incinerator_used_this_level = true
		
		# Distrugge tutti gli oggetti nella riga (tagliaerba)
		kill_all_in_row(row) # Questa funzione contiene ora il feedback visivo!
		# Chiusura inceneritore per il resto dell'ondata corrente.
	
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
	print("Ondata completata — sposto indietro le torrette.")
	if turret_manager:
		turret_manager.move_turrets_back()
