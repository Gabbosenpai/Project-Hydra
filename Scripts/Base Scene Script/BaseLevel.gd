extends Node2D

signal game_over

@onready var turret_manager = $TurretManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI
@onready var grid_initializer = $GridInitializer
@export var tilemap: TileMap

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
func enemy_reached_base():
	emit_signal("game_over")
	
# Logica di default per la fine dell'ondata. 
func _on_wave_completed(_wave_number):
	print("Ondata completata — sposto indietro le torrette.")
	if turret_manager:
		turret_manager.move_turrets_back()
