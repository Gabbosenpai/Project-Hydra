extends Node2D  # Estende Node2D, nodo principale della scena di gioco (es. livello)

# --- RIFERIMENTI AI NODI DELLA SCENA ---
@onready var tilemap = $TileMap  # TileMap principale che rappresenta la griglia di gioco
@onready var highlight = $Highlight  # Sprite trasparente che evidenzia la cella selezionata
@onready var button_place = $UI/ButtonPlace  # Bottone UI per attivare modalità piazzamento piante
@onready var button_remove = $UI/ButtonRemove  # Bottone UI per attivare modalità rimozione piante
@onready var button_cancel = $UI/Abort  # Bottone UI per annullare l'azione corrente
@onready var plant_selector = $UI/PlantSelector  # Finestra UI per scegliere quale pianta piazzare
@onready var button_plant1 = $UI/PlantSelector/ButtonPlant1  # Bottone per selezionare pianta 1
@onready var button_plant2 = $UI/PlantSelector/ButtonPlant2  # Bottone per selezionare pianta 2

# --- SISTEMA AD ONDATE ---
@onready var wave_timer = $WaveTimer  # Timer che gestisce il ritmo dello spawn dei nemici
@onready var label_wave = $UI/LabelWave  # Etichetta UI per mostrare il numero dell'ondata attuale
@onready var label_enemies = $UI/LabelEnemies  # Etichetta UI per mostrare quanti nemici sono vivi

var current_wave = 0  # Numero corrente dell'ondata (parte da 0)
var enemies_alive = 0  # Quanti nemici sono attivi/vivi nella scena
var is_wave_active = false  # Flag che indica se un'ondata è in corso

# Precarica la scena del nemico da instanziare ad ogni spawn
var enemy_scene = preload("res://Scene/Nemici/enemy.tscn")

# Definizione delle ondate: array di dizionari con numero nemici e intervallo spawn
var waves = [
	{ "count": 3, "interval": 1.0 },  # 3 nemici, uno ogni 1 secondo
	{ "count": 5, "interval": 0.8 },
	{ "count": 7, "interval": 0.6 }
]

var enemies_to_spawn = 0  # Numero di nemici rimasti da spawnare nell'ondata corrente
var spawn_interval = 1.0  # Intervallo di tempo tra spawn nemici

# --- GRIGLIA DI GIOCO ---
const GRID_WIDTH = 9  # Larghezza griglia (numero di celle)
const GRID_HEIGHT = 5  # Altezza griglia

# --- VARIABILI DI STATO GENERALI ---
var last_touch_position: Vector2 = Vector2.ZERO  # Ultima posizione del tocco (per dispositivi touch)
var selected_plant_scene: PackedScene = null  # Pianta attualmente selezionata per il piazzamento

# Dizionario con le scene delle piante disponibili per piazzamento
var plant_scenes = {
	"plant1": preload("res://Scene/Piante/plant.tscn"),
	"plant2": preload("res://Scene/Torrette/base_tower.tscn"),
	"plant3": preload("res://Scene/Piante/plant_3.tscn"),
	"plant4": preload("res://Scene/Piante/plant_4.tscn")
}

# Dizionario che tiene traccia delle piante piazzate, con chiave la cella (Vector2i)
var plants = {}

# Modalità d’uso dell’utente: nessuna azione, piazzamento o rimozione pianta
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE

# --- FUNZIONE CHIAMATA OGNI FRAME ---
func _process(delta):
	button_remove.visible = not plants.is_empty()
	# Se non siamo in nessuna modalità attiva, nascondi l'highlight e non fare altro
	if current_mode == Mode.NONE:
		highlight.visible = false
		return

	# Ottiene la posizione del puntatore (mouse o touch)
	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		highlight.visible = false
		return
	
	# Converte la posizione globale in locale rispetto alla TileMap
	var local_pos = tilemap.to_local(pointer_pos)
	# Ottiene la cella della griglia sotto il puntatore
	var cell = tilemap.local_to_map(local_pos)
	
	# Controlla che la cella sia valida dentro i limiti della griglia
	if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
		var tile_size = tilemap.tile_set.tile_size
		# Ottiene la posizione in locale dell'angolo in alto a sinistra della cella
		var tile_top_left = tilemap.map_to_local(cell)
		# Calcola il centro della cella aggiungendo metà dimensione della tile
		var tile_center = tile_top_left + tile_size * 0.5
		# Converte la posizione locale in globale (coordinate mondo)
		var global_pos = tilemap.to_global(tile_center)
		
		# Posiziona lo sprite highlight centrato sulla cella corrispondente
		highlight.position = highlight.get_parent().to_local(global_pos - tile_size * 0.5)
		highlight.visible = true
		# Cambia colore dell'highlight in base alla modalità attiva
		match current_mode:
			Mode.PLACE:
				highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)  # Verde trasparente per piazzamento
			Mode.REMOVE:
				highlight.modulate = Color(1.0, 0.4, 0.4, 0.6)  # Rosso trasparente per rimozione
	else:
		# Se fuori griglia, nasconde l'highlight
		highlight.visible = false

# --- GESTIONE INPUT (mouse o tocco) ---
func _unhandled_input(event):
	if current_mode == Mode.NONE:
		return

	var pointer_pos = null

	if event is InputEventScreenTouch and event.pressed:
		pointer_pos = event.position
		last_touch_position = pointer_pos
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pointer_pos = event.position

	if pointer_pos != null:
		var local_pos = tilemap.to_local(pointer_pos)
		var cell = tilemap.local_to_map(local_pos)
		var cell_key = Vector2i(cell.x, cell.y)

		match current_mode:
			Mode.PLACE:
				if not plants.has(cell_key) and selected_plant_scene != null:
					var plant_instance = selected_plant_scene.instantiate()
					var tile_size = tilemap.tile_set.tile_size
					var tile_top_left = tilemap.map_to_local(cell)
					var tile_center = tile_top_left + tile_size * 0.5
					plant_instance.global_position = tilemap.to_global(tile_center)

					# Imposta la riga se la pianta ha la variabile
					if plant_instance.has_method("set_riga"):
						plant_instance.set_riga(cell.y)

					add_child(plant_instance)
					plants[cell_key] = plant_instance
					print("Planted at cell: ", cell_key)
					current_mode = Mode.NONE
					selected_plant_scene = null
					highlight.visible = false

				else:
					print("Cell already occupied or no plant selected: ", cell_key)

			Mode.REMOVE:
				if plants.has(cell_key):
					plants[cell_key].queue_free()
					plants.erase(cell_key)
					print("Removed plant at cell: ", cell_key)
					current_mode = Mode.NONE
					highlight.visible = false
					button_remove.button_pressed = false  # Disattiva il bottone se è "toggle"
				else:
					print("No plant to remove at cell: ", cell_key)

# Funzione per ottenere la posizione del puntatore (mouse o touch)
func get_pointer_position() -> Vector2:
	# Su PC ritorna posizione mouse
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	# Su mobile ritorna ultima posizione touch
	return last_touch_position

# --- FUNZIONI COLLEGATE AI BOTTONI UI ---

# Quando si preme il bottone "Piazza pianta"
func _on_button_place_pressed() -> void:
	if plant_selector.visible:
		# Se è già visibile, nascondilo e torna alla modalità NONE
		current_mode = Mode.NONE
		selected_plant_scene = null
		plant_selector.visible = false
		highlight.visible = false
	else:
		# Altrimenti mostralo
		current_mode = Mode.NONE
		plant_selector.visible = true
		selected_plant_scene = null



# Quando si preme il bottone "Rimuovi pianta"
func _on_button_remove_pressed() -> void:
	if current_mode == Mode.REMOVE:
		current_mode = Mode.NONE
		button_remove.button_pressed = false
		highlight.visible = false
	else:
		current_mode = Mode.REMOVE


# Quando si seleziona la pianta 1 dalla UI
func _on_button_plant_1_pressed() -> void:
	selected_plant_scene = plant_scenes["plant1"]  # Seleziona la scena della pianta 1
	current_mode = Mode.PLACE                      # Attiva modalità piazzamento
	plant_selector.visible = false                 # Nasconde la finestra selettore piante

# Quando si seleziona la pianta 2 dalla UI
func _on_button_plant_2_pressed() -> void:
	selected_plant_scene = plant_scenes["plant2"]  # Seleziona la scena della pianta 2 (torretta)
	current_mode = Mode.PLACE                      # Attiva modalità piazzamento
	plant_selector.visible = false                 # Nasconde la finestra selettore piante

func _on_button_plant_3_pressed() -> void:
	selected_plant_scene = plant_scenes["plant3"]  # Seleziona la scena della pianta 3
	current_mode = Mode.PLACE                      # Attiva modalità piazzamento
	plant_selector.visible = false                 # Nasconde la finestra selettore piante

func _on_button_plant_4_pressed() -> void:
	selected_plant_scene = plant_scenes["plant4"]  # Seleziona la scena della pianta 4
	current_mode = Mode.PLACE                      # Attiva modalità piazzamento
	plant_selector.visible = false                 # Nasconde la finestra selettore piante

# --- GESTIONE DELLE ONDATE DI NEMICI ---

# Inizio di una nuova ondata (triggerata da bottone UI)
func _on_start_wave_button_pressed() -> void:
	if is_wave_active:
		return  # Se ondata in corso, ignora

	if current_wave >= waves.size():
		print("Tutte le ondate completate.")  # Se non ci sono altre ondate, stoppa tutto
		return
	
	# Imposta i parametri dell'ondata corrente
	var wave = waves[current_wave]
	enemies_to_spawn = wave["count"]
	spawn_interval = wave["interval"]
	enemies_alive = 0
	is_wave_active = true
	
	# Aggiorna le etichette UI
	label_wave.text = "Ondata: " + str(current_wave + 1)
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	# Imposta e avvia il timer per lo spawn dei nemici
	wave_timer.wait_time = spawn_interval
	wave_timer.start()

# Funzione chiamata ogni volta che il timer dello spawn scade
func _on_wave_timer_timeout() -> void:
	if enemies_to_spawn > 0:
		spawn_enemy()        # Istanzia un nuovo nemico
		enemies_to_spawn -= 1 # Diminuisce il numero di nemici rimasti da spawnare
		wave_timer.start()   # Riavvia il timer se ci sono ancora nemici da spawnare
	else:
		print("Attendi la fine dell'ondata.")  # Attendi che vengano sconfitti i nemici attivi

# Funzione per istanziare un nemico e aggiungerlo alla scena
func spawn_enemy():
	var enemy = enemy_scene.instantiate()

	var row = randi() % GRID_HEIGHT
	var spawn_cell = Vector2i(GRID_WIDTH, row)

	var tile_top_left = tilemap.map_to_local(spawn_cell)
	var tile_center = tile_top_left + tilemap.tile_set.tile_size * 0.5
	var spawn_position = tilemap.to_global(tile_center)

	enemy.global_position = spawn_position

	# Imposta la riga e aggiunge al gruppo "Robot"
	enemy.riga = row

	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))

	add_child(enemy)

	enemies_alive += 1
	label_enemies.text = "Nemici: " + str(enemies_alive)


# Funzione chiamata quando un nemico viene sconfitto (segno "enemy_defeated")
func _on_enemy_defeated():
	enemies_alive -= 1
	label_enemies.text = "Nemici: " + str(enemies_alive)
	
	# Se tutti i nemici sono stati spawnati e uccisi, termina ondata
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		is_wave_active = false
		current_wave += 1
		print("Ondata completata.")

# Bottone di debug: uccide tutti i nemici attivi (chiama il metodo die() se presente)
func _on_button_kill_all_pressed() -> void:
	for child in get_children():
		if child.has_method("die"):
			child.die()
