extends Node2D

# Esportazione scene nemici dall'Inspector
@export var enemy1_scene: PackedScene
@export var enemy2_scene: PackedScene

# Punto spawn
@export var spawn_position = Vector2(1500, 300)

# Impostazione dell' ondate
@export var enemies_per_wave: int = 5
@export var time_between_spawns: float = 1.0
@export var time_between_waves: float = 5.0

var current_wave = 0  #numero nemico corrente
var enemies_spawned = 0  #quanti ne sono spawnati

func _ready():
	start_wave()

# Avvia una nuova ondata
func start_wave():
	current_wave += 1
	enemies_spawned = 0
	print("Wave ", current_wave)
	await spawn_enemies()

# Spawna tutti i nemici per un'ondata
func spawn_enemies():
	for i in range(enemies_per_wave):
		# Scegli a caso tra i due tipi di nemico
		var scene_to_spawn: PackedScene #variabile che contiene la scena del nemico che deve spawnare
		if randf() < 0.5:
			scene_to_spawn = enemy1_scene
		else:
			scene_to_spawn = enemy2_scene

		# Istanzia il nemico 1 o 2
		var enemy = scene_to_spawn.instantiate()

		call_deferred("add_child", enemy) #per evitare conflitti durante l'aggiornamento
		enemy.global_position = spawn_position
		# Incrementa il contatore dei nemici spawnati
		enemies_spawned += 1

		# Aspetta prima di spawnare il prossimo
		await get_tree().create_timer(time_between_spawns).timeout

	# Quando tutti i nemici sono spawniati, aspetta e avvia la successiva ondata
	await get_tree().create_timer(time_between_waves).timeout
	start_wave()  # Avvia la prossima ondata solo dopo aver completato la precedente
