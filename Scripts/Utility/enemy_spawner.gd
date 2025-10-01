extends Node

signal wave_completed
signal enemy_reached_base
signal level_completed

#Variabili che servono per tenere lo stato delle etichette e delle ondate per poter aggiornare l'UI
@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer
@export var label_wave_center: Label
@export var animation_player: AnimationPlayer
@export var victory_screen: Control

# Tutti i tipi di nemico
var all_enemy_scenes = {
	"romba": preload("res://Scenes/Robots/romba.tscn"),
	"weed_eater_9000": preload("res://Scenes/Robots/weed_eater_9000.tscn"),
	"ice_robot": preload("res://Scenes/Robots/ice_robot.tscn"),
	"kamikaze": preload("res://Scenes/Robots/kamikaze.tscn")
}

# Dizionario: livello → tipi di nemici disponibili
var level_enemy_pool = {
	1: ["romba"],
	2: ["romba", "weed_eater_9000"],
	3: ["romba", "weed_eater_9000", "ice_robot"],
	4: ["romba", "weed_eater_9000", "ice_robot", "kamikaze"],
	5: ["romba", "weed_eater_9000", "ice_robot", "kamikaze"]
}

# Stato corrente
var current_wave = 0 
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false
var current_level: int = 1   # sarà impostato automaticamente

# Configurazione delle ondate
var waves = [
	{ "count": 3, "interval": 1.0 },
	{ "count": 5, "interval": 0.8 },
	{ "count": 7, "interval": 0.6 }
]

# Funzione che inizializza lo spawner
func _ready():
	randomize() #utilizzato per randomizzare i nemici da spawnare 

	var path = get_tree().current_scene.scene_file_path #percorso della scena del nemico
	var regex = RegEx.new() #utilizzato per trovare il nome che corssionde esattamente al livello da utilizzare per il dizionario
	regex.compile("\\d+")
	var result = regex.search(path) #raccoglie il valore del livello in cui ci si trova
	if result:
		current_level = int(result.get_string())
	else:
		current_level = 1

	print("Spawner avviato in livello: ", current_level, " (path=", path, ")")


# Funzione che si occupa di avviare un’ondata
func start_wave():
	#Se l'ondata è attiva o l'ondata corrente è maggiore alle ondate presenti non devo fare nulla
	if is_wave_active or current_wave >= waves.size():
		return
	var wave = waves[current_wave]
	enemies_to_spawn = wave["count"] #Spawno i nemici previsti dal dizionario
	wave_timer.wait_time = wave["interval"]
	enemies_alive = 0
	is_wave_active = true
	#Aggiorna le etichette 
	label_wave.text = "Ondata: " + str(current_wave + 1)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	label_wave_center.text = "ONDATA " + str(current_wave + 1)
	label_wave_center.visible = true
	animation_player.play("wave_intro")
	wave_timer.start()

# Timer → spawn nemici
func _on_wave_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		wave_timer.start()


# Funzione che si occupa di spawnare il nemico
func spawn_enemy():
	# Prende i nemici consentiti per questo livello
	var pool = level_enemy_pool.get(current_level, ["romba"])
	var choice = pool[randi() % pool.size()]
	print("Lvl", current_level, " pool=", pool, " → scelto: ", choice)
	# Sceglie uno casuale dal pool
	var enemy_scene = all_enemy_scenes[choice]
	var enemy = enemy_scene.instantiate()
	#Spawna il nemico in una riga causale 
	var row = randi() % GameConstants.GRID_HEIGHT
	var spawn_cell = Vector2i(GameConstants.GRID_WIDTH, row)
	var tile_center = tilemap.map_to_local(spawn_cell) + tilemap.tile_set.tile_size * 0.5
	enemy.global_position = tilemap.to_global(tile_center)
	enemy.riga = row
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	add_child(enemy)
	#Aggiorna etichetta
	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)

# Funzione che si occupa di verficare la morte del nemico
func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	#Se i nemici in vita sono 0 e i nemici da spawnare è pari a 0 l'ondata attuale è finita per cui passo alla successiva 
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		#Se l'ondata corrente è minore delle ondate previste avvio la nuova ondata
		if current_wave < waves.size():
			start_wave()
		#Altrimenti le ondate sono finite e per cui il livello è completato
		else:
			victory_screen.visible = true
			get_tree().paused = true
			emit_signal("level_completed")

# Funzione di debug che uccide tutti i nemici
func kill_all():
	enemies_to_spawn = 0
	for child in get_children():
		if child.has_method("die"):
			child.queue_free()
			enemies_alive -= 1

	is_wave_active = false
	current_wave += 1
	if current_wave < waves.size():
		start_wave()
	else:
		victory_screen.visible = true
		AudioManager.play_victory_music()
		emit_signal("level_completed")
