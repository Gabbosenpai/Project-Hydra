extends Node

signal wave_completed
signal enemy_reached_base
signal level_completed

# Nodi della scena passati dall'editor per gestire spawn, UI e timer
@export var tilemap: TileMap
@export var label_wave: Label
@export var label_enemies: Label
@export var wave_timer: Timer
@export var label_wave_center: Label
@export var animation_player: AnimationPlayer
@export var victory_screen: Control

# Scena del nemico da istanziare
var enemy_scene = preload("res://Scenes/Robots/romba.tscn")

# Configurazione delle ondate: numero di nemici e intervallo di spawn
var waves = [
	{ "count": 3, "interval": 1.0 },
	{ "count": 5, "interval": 0.8 },
	{ "count": 7, "interval": 0.6 }
]

# Stato corrente dello spawner
var current_wave = 0
var enemies_to_spawn = 0
var enemies_alive = 0
var is_wave_active = false

# Avvia un’ondata se non ce n’è una in corso e se non abbiamo finito tutte le ondate
func start_wave():
	if is_wave_active or current_wave >= waves.size():
		return
	var wave = waves[current_wave]
	enemies_to_spawn = wave["count"]
	wave_timer.wait_time = wave["interval"]
	enemies_alive = 0
	is_wave_active = true
	label_wave.text = "Ondata: " + str(current_wave + 1)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	label_wave_center.text = "ONDATA " + str(current_wave + 1)
	label_wave_center.visible = true
	animation_player.play("wave_intro")
	wave_timer.start()

# Gestisce lo spawn dei nemici ad ogni timeout del timer
func _on_wave_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		wave_timer.start() # riavvia il timer per il prossimo nemico
	else:
		# Se non ci sono più nemici vivi e nessuno da spawnare, l’ondata è finita
		if enemies_alive == 0:
			is_wave_active = false
			current_wave += 1
			emit_signal("wave_completed")

# Crea un nemico, lo posiziona in una riga casuale e lo aggiunge alla scena
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var row = randi() % GameConstants.GRID_HEIGHT  # seleziona una riga casuale tra 0 e 7
	var spawn_cell = Vector2i(GameConstants.GRID_WIDTH, row) # cella di partenza dei nemici
	var tile_center = tilemap.map_to_local(spawn_cell) + tilemap.tile_set.tile_size * 0.5
	enemy.global_position = tilemap.to_global(tile_center)
	enemy.riga = row
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	add_child(enemy)
	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)

# Chiamata quando un nemico viene sconfitto
func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	# Se non restano nemici vivi né da spawnare, l’ondata è conclusa
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		if current_wave < waves.size():
			start_wave()
		else:
			victory_screen.visible = true
			get_tree().paused = true
			emit_signal("level_completed")

# Uccide istantaneamente tutti i nemici presenti nella scena
func kill_all():
	# Ferma lo spawn futuro
	enemies_to_spawn = 0

	for child in get_children():
		if child.has_method("die"):
			child.queue_free()  # Rimuove immediatamente
			enemies_alive -= 1

	# Passa subito all’ondata successiva
	is_wave_active = false
	current_wave += 1
	if current_wave < waves.size():
		start_wave()
	else:
		
		victory_screen.visible = true
		AudioManager.play_victory_music()
		emit_signal("level_completed")
		
