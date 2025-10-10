extends Node2D

signal game_over

# Riferimenti ai nodi principali nella scena
@onready var turret_manager = $TurretManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI
@onready var grid_initializer = $GridInitializer # Riferimento al nuovo nodo inizializzatore

@export var tilemap: TileMap

func _ready():
	# IMPORTANTE: Se GridInitializerNode è un figlio del nodo corrente,
	# il suo _ready() è già stato eseguito a questo punto (se è posizionato prima di TurretManager nell'albero).
	
	# 1. Assegna il dizionario inizializzato a TurretManager
	if grid_initializer:
		turret_manager.set_grid_data(grid_initializer.dic)
	else:
		print("ERRORE: Il nodo GridInitializer non è stato trovato o collegato.")
	
	# 2. Connessioni dei segnali tra i vari manager e controller.
	turret_manager.connect("turret_removed", Callable(self, "_on_turret_removed"))
	ui_controller.connect("kill_all", Callable(enemy_spawner, "kill_all"))
	ui_controller.connect("select_turret", Callable(turret_manager, "select_turret"))
	ui_controller.connect("remove_mode", Callable(turret_manager, "remove_mode"))
	connect("game_over", Callable(ui_controller, "show_game_over"))

	enemy_spawner.connect("level_completed", Callable(self, "_on_level_completed"))
	enemy_spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))

	var level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
	AudioManager.play_music(level_music)
	
	# Avvia la prima ondata DOPO che la griglia è stata inizializzata e il TurretManager è pronto.
	enemy_spawner.start_wave()
	

# Chiamata quando termina un'ondata
func _on_wave_completed(_wave_number):
	print("Ondata completata — sposto indietro le torrette.")
	if turret_manager:
		turret_manager.move_turrets_back()


# Quando un nemico raggiunge la base del giocatore
func enemy_reached_base():
	emit_signal("game_over")


# Quando il livello viene completato (tutte le ondate finite)
func _on_level_completed():
	var max_level = SaveManager.get_max_unlocked_level()
	if max_level < 2:
		SaveManager.unlock_level(2)
		print("Livello 2 sbloccato!")
