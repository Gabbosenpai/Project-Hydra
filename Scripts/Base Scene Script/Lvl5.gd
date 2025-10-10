extends Node2D

signal game_over

# Riferimenti ai nodi principali nella scena
@onready var turret_manager = $TurretManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI
@onready var grid_initializer = $GridInitializer # Riferimento al nuovo nodo inizializzatore

@export var tilemap: TileMap
# Rimosso: var dic = {} (Il dizionario ora è gestito da GridInitializer)

func _ready():
	# IMPORTANTE: Se GridInitializerNode è un figlio del nodo corrente,
	# il suo _ready() è già stato eseguito a questo punto (se è posizionato prima di TurretManager nell'albero).
	
	# 1. Assegna il dizionario inizializzato a TurretManager
	if grid_initializer:
		# GridInitializer ha già popolato il suo dizionario 'dic' e la TileMap.
		turret_manager.set_grid_data(grid_initializer.dic)
	else:
		print("ERRORE: Il nodo GridInitializer non è stato trovato o collegato.")
	
	# 2. Connessioni dei segnali tra i vari manager e controller.
	turret_manager.connect("turret_removed", Callable(self, "_on_turret_removed"))
	ui_controller.connect("kill_all", Callable(enemy_spawner, "kill_all"))
	ui_controller.connect("select_turret", Callable(turret_manager, "select_turret"))
	ui_controller.connect("remove_mode", Callable(turret_manager, "remove_mode"))
	connect("game_over", Callable(ui_controller, "show_game_over"))
	var level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
	AudioManager.play_music(level_music)
	enemy_spawner.connect("level_completed", Callable(self, "_on_level_completed"))
	
	# Avvia la prima ondata DOPO che la griglia è stata inizializzata e il TurretManager è pronto.
	enemy_spawner.start_wave()
	
# Chiamata quando l’ondata di nemici viene completata.
# Utile per avviare la successiva o mostrare messaggi all’utente.
func _on_wave_completed():
	print("Ondata completata.")

# Chiamata quando un nemico raggiunge la base del giocatore.
# In questo caso emette il segnale "game_over" che avvia la schermata di fine partita.
func enemy_reached_base():
	emit_signal("game_over")
