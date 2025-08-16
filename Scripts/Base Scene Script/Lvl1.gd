extends Node2D

signal game_over

# Riferimenti ai nodi principali nella scena
@onready var turret_manager = $TurretManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI

func _ready():
	# Connessioni dei segnali tra i vari manager e controller.
	# Questi collegamenti permettono ai diversi componenti del gioco di comunicare tra loro.
	turret_manager.connect("turret_removed", Callable(self, "_on_turret_removed"))
	enemy_spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))
	enemy_spawner.connect("enemy_reached_base", Callable(self, "_on_enemy_reached_base"))
	ui_controller.connect("kill_all", Callable(enemy_spawner, "kill_all"))
	ui_controller.connect("select_turret", Callable(turret_manager, "select_turret"))
	ui_controller.connect("remove_mode", Callable(turret_manager, "remove_mode"))
	connect("game_over", Callable(ui_controller, "show_game_over"))
	var level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
	AudioManager.play_music(level_music)
	enemy_spawner.start_wave()

# Chiamata quando l’ondata di nemici viene completata.
# Utile per avviare la successiva o mostrare messaggi all’utente.
func _on_wave_completed():
	print("Ondata completata.")

# Chiamata quando un nemico raggiunge la base del giocatore.
# In questo caso emette il segnale "game_over" che avvia la schermata di fine partita.
func enemy_reached_base():
	emit_signal("game_over")
