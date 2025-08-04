extends Node2D

# --- RIFERIMENTI AI NODI DELLA SCENA ---
@onready var tilemap = $TileMap  # TileMap principale che rappresenta la griglia di gioco
@onready var highlight = $Highlight  # Sprite trasparente che evidenzia la cella selezionata
@onready var button_place = $UI/ButtonPlace  # Bottone per attivare la modalità piazzamento piante
@onready var button_remove = $UI/ButtonRemove  # Bottone per attivare la modalità rimozione piante
@onready var button_cancel = $UI/Abort  # Bottone per annullare l'azione corrente
@onready var plant_selector = $UI/PlantSelector  # Finestra UI per scegliere la pianta da piazzare
@onready var button_plant1 = $UI/PlantSelector/ButtonPlant1  # Bottone per selezionare la pianta 1
@onready var button_plant2 = $UI/PlantSelector/ButtonPlant2  # Bottone per selezionare la pianta 2

# --- SISTEMA AD ONDATE ---
@onready var wave_timer = $WaveTimer  # Timer per gestire lo spawn dei nemici
@onready var label_wave = $UI/LabelWave  # Etichetta UI che mostra il numero dell'ondata
@onready var label_enemies = $UI/LabelEnemies  # Etichetta UI che mostra quanti nemici sono vivi

var current_wave = 0  # Numero dell'ondata corrente
var enemies_alive = 0  # Numero di nemici attualmente vivi
var is_wave_active = false  # Flag che indica se un'ondata è in corso

# Precarica la scena del nemico da instanziare
var enemy_scene = preload("res://Scene/Nemici/enemy.tscn")

# Definizione delle ondate: quanti nemici e intervallo tra gli spawn
var waves = [
	{ "count": 3, "interval": 1.0 },
	{ "count": 5, "interval": 0.8 },
	{ "count": 7, "interval": 0.6 }
]

var enemies_to_spawn = 0  # Contatore dei nemici da spawnare in questa ondata
var spawn_interval = 1.0  # Intervallo di spawn tra un nemico e l’altro

# --- GRIGLIA DI GIOCO ---
const GRID_WIDTH = 10
const GRID_HEIGHT = 6

# --- VARIABILI DI STATO GENERALI ---
var last_touch_position: Vector2 = Vector2.ZERO  # Ultima posizione di tocco (per dispositivi mobili)
var selected_plant_scene: PackedScene = null  # Scena della pianta attualmente selezionata per il piazzamento

# Dizionario con le scene delle piante disponibili
var plant_scenes = {
	"plant1": preload("res://Scene/Piante/plant.tscn"),
	"plant2": preload("res://Scene/Torrette/base_tower.tscn")
}

# Dizionario che tiene traccia delle piante piazzate, mappate per cella (Vector2i)
var plants = {}

# Modalità dell’utente: nessuna, piazzamento o rimozione
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE

# --- FUNZIONE CHIAMATA OGNI FRAME ---
func _process(delta):
	# Se non siamo in nessuna modalità attiva, nascondi l'highlight
	if current_mode == Mode.NONE:
		highlight.visible = false
		return

	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		highlight.visible = false
		return
	
	var local_pos = tilemap.to_local(pointer_pos)
	var cell = tilemap.local_to_map(local_pos)
	
	# Verifica che la cella sia dentro i limiti della griglia
	if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
		var tile_size = tilemap.tile_set.tile_size
		var tile_top_left = tilemap.map_to_local(cell)
		var tile_center = tile_top_left + tile_size * 0.5
		var global_pos = tilemap.to_global(tile_center)
		
		# Posiziona l’highlight centrato sulla cella
		highlight.position = highlight.get_parent().to_local(global_pos - tile_size * 0.5)
		highlight.visible = true

		# Cambia il colore dell’highlight in base alla modalità attiva
		match current_mode:
			Mode.PLACE:
				highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)  # Verde trasparente
			Mode.REMOVE:
				highlight.modulate = Color(1.0, 0.4, 0.4, 0.6)  # Rosso trasparente
	else:
		highlight.visible = false

# --- GESTIONE INPUT (mouse o tocco) ---
func _unhandled_input(event):
	if current_mode == Mode.NONE:
		return

	var pointer_pos = null

	# Touch su mobile
	if event is InputEventScreenTouch and event.pressed:
		pointer_pos = event.position
		last_touch_position = pointer_pos
	# Click del mouse su PC
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pointer_pos = event.position

	if pointer_pos != null:
		var local_pos = tilemap.to_local(pointer_pos)
		var cell = tilemap.local_to_map(local_pos)
		var cell_key = Vector2i(cell.x, cell.y)

		match current_mode:
			# PIAZZAMENTO PIANTE
			Mode.PLACE:
				if not plants.has(cell_key) and selected_plant_scene != null:
					var plant_instance = selected_plant_scene.instantiate()
					var tile_size = tilemap.tile_set.tile_size
					var tile_top_left = tilemap.map_to_local(cell)
					var tile_center = tile_top_left + tile_size * 0.5
					plant_instance.global_position = tilemap.to_global(tile_center)
					add_child(plant_instance)
					plants[cell_key] = plant_instance
					print("Planted at cell: ", cell_key)
				else:
					print("Cell already occupied or no plant selected: ", cell_key)

			# RIMOZIONE PIANTE
			Mode.REMOVE:
				if plants.has(cell_key):
					plants[cell_key].queue_free()
					plants.erase(cell_key)
					print("Removed plant at cell: ", cell_key)
				else:
					print("No plant to remove at cell: ", cell_key)

# Ottiene la posizione del puntatore (mouse su PC o tocco su mobile)
func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position

# --- FUNZIONI LEGATE AI BOTTONI UI ---

# Quando si clicca il bottone "piazza"
func _on_button_place_pressed() -> void:
	current_mode = Mode.NONE
	plant_selector.visible = true
	selected_plant_scene = null  # Aspetta che l'utente selezioni una pianta

# Quando si clicca il bottone "rimuovi"
func _on_button_remove_pressed() -> void:
	current_mode = Mode.REMOVE

# Quando si clicca il bottone "annulla"
func _on_abort_pressed() -> void:
	current_mode = Mode.NONE
	plant_selector.visible = false

# Selezione della pianta 1
func _on_button_plant_1_pressed() -> void:
	selected_plant_scene = plant_scenes["plant1"]
	current_mode = Mode.PLACE
	plant_selector.visible = false

# Selezione della pianta 2
func _on_button_plant_2_pressed() -> void:
	selected_plant_scene = plant_scenes["plant2"]
	current_mode = Mode.PLACE
	plant_selector.visible = false

# --- GESTIONE DELLE ONDATE DI NEMICI ---

# Inizio di una nuova ondata
func _on_start_wave_button_pressed() -> void:
	if is_wave_active:
		return
	
	if current_wave >= waves.size():
		print("Tutte le ondate completate.")
		return
	
	var wave = waves[current_wave]
	enemies_to_spawn = wave["count"]
	spawn_interval = wave["interval"]
	enemies_alive = 0
	is_wave_active = true
	
	label_wave.text = "Ondata: " + str(current_wave + 1)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	wave_timer.wait_time = spawn_interval
	wave_timer.start()

# Timer scaduto: spawn di un nuovo nemico o fine spawn
func _on_wave_timer_timeout() -> void:
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		wave_timer.start()  # Riavvia il timer finché ci sono nemici da spawnare
	else:
		print("Attendi la fine dell'ondata.")  # Attesa che vengano uccisi tutti

# Funzione che istanzia un nemico e lo aggiunge alla scena
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Posizione iniziale del nemico (adatta alla tua mappa)
	enemy.global_position = Vector2(1200, 64 + randi() % 300)
	
	# Collegamento al segnale "enemy_defeated"
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	
	add_child(enemy)
	
	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)

# Quando un nemico viene sconfitto
func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	# Se tutti i nemici sono stati spawnati e sconfitti, passa alla prossima ondata
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		print("Ondata completata.")

# Bottone di debug per uccidere tutti i nemici (usa il metodo die() se presente)
func _on_button_kill_all_pressed() -> void:
	for child in get_children():
		if child.has_method("die"):
			child.die()
