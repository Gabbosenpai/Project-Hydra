extends Node2D

signal game_over
@onready var plant_manager = $PlantManager
@onready var enemy_spawner = $EnemySpawner
@onready var ui_controller = $UI

func _ready():
	# Connessioni
	plant_manager.connect("plant_removed", Callable(self, "_on_plant_removed"))
	enemy_spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))
	enemy_spawner.connect("enemy_reached_base", Callable(self, "_on_enemy_reached_base"))
	ui_controller.connect("start_wave", Callable(enemy_spawner, "start_wave"))
	ui_controller.connect("kill_all", Callable(enemy_spawner, "kill_all"))
	ui_controller.connect("select_plant", Callable(plant_manager, "select_plant"))
	ui_controller.connect("remove_mode", Callable(plant_manager, "remove_mode"))
	connect("game_over", Callable(ui_controller, "show_game_over"))

func _on_plant_removed(cell_key):
	pass # eventuali azioni extra

func _on_wave_completed():
	print("Ondata completata.")

func enemy_reached_base():
	emit_signal("game_over")
