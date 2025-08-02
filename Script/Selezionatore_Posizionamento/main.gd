extends Node2D

# Riferimenti ai nodi della scena tramite @onready
@onready var tilemap = $TileMap              # TileMap per la griglia
@onready var highlight = $Highlight          # Nodo per evidenziare la cella attiva
@onready var button_place = $UI/ButtonPlace  # Pulsante "Posiziona"
@onready var button_remove = $UI/ButtonRemove # Pulsante "Rimuovi"
@onready var button_cancel = $UI/Abort       # Pulsante "Annulla"
@onready var plant_selector = $UI/PlantSelector # Contenitore UI per selezionare la pianta
@onready var button_plant1 = $UI/PlantSelector/ButtonPlant1 # Pulsante selezione pianta 1
@onready var button_plant2 = $UI/PlantSelector/ButtonPlant2 # Pulsante selezione pianta 2

# Dimensioni della griglia di gioco
const GRID_WIDTH = 9 
const GRID_HEIGHT = 5

# Ultima posizione toccata (per touch devices)
var last_touch_position: Vector2 = Vector2.ZERO

# Pianta selezionata per il posizionamento (PackedScene)
var selected_plant_scene: PackedScene = null

# Dizionario con le scene preloadate delle piante
var plant_scenes = {
	"plant1": preload("res://Scene/Piante/plant.tscn"),
	"plant2": preload("res://Scene/Piante/plant_2.tscn")
}

# Dizionario per tenere traccia delle piante posizionate sulla griglia
# Key: Vector2i cella della griglia, Value: nodo pianta istanziato
var plants = {}

# Enumerazione per le modalità di interazione
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE  # Modalità iniziale: nessuna

func _process(delta):
	# Se non siamo in nessuna modalità attiva, nascondi l'evidenziatore e esci
	if current_mode == Mode.NONE:
		highlight.visible = false
		return

	# Prendo la posizione attuale del cursore o touch
	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		highlight.visible = false
		return

	# Converto la posizione in coordinate della griglia TileMap
	var cell = tilemap.local_to_map(pointer_pos)

	# Controllo che la cella sia dentro i limiti della griglia
	if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
		# Calcolo la posizione locale della cella nella TileMap
		var local_pos = tilemap.map_to_local(cell)
		# Posiziono l'evidenziatore nella cella corretta (in coordinate globali)
		highlight.global_position = tilemap.to_global(local_pos)
		highlight.visible = true

		# Cambia il colore dell'evidenziatore in base alla modalità corrente
		match current_mode:
			Mode.PLACE:
				highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)  # Verde semitrasparente per posizionamento
			Mode.REMOVE:
				highlight.modulate = Color(1.0, 0.4, 0.4, 0.6)  # Rosso semitrasparente per rimozione
	else:
		highlight.visible = false  # Se fuori griglia, nascondi evidenziatore

func _unhandled_input(event):
	# Se non siamo in nessuna modalità attiva, non gestiamo input
	if current_mode == Mode.NONE:
		return

	var pointer_pos = null

	# Rilevo input da touch o mouse sinistro premuto
	if event is InputEventScreenTouch and event.pressed:
		pointer_pos = event.position
		last_touch_position = pointer_pos  # Aggiorno la posizione touch
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pointer_pos = event.position

	if pointer_pos != null:
		var cell = tilemap.local_to_map(pointer_pos)

		# Controllo che la cella sia valida nella griglia
		if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
			var cell_key = Vector2i(cell.x, cell.y)

			match current_mode:
				Mode.PLACE:
					# Se la cella non è già occupata e una pianta è selezionata
					if not plants.has(cell_key) and selected_plant_scene != null:
						# Istanzio la pianta e la posiziono correttamente
						var plant_instance = selected_plant_scene.instantiate()
						var pos = tilemap.map_to_local(cell)
						plant_instance.global_position = tilemap.to_global(pos)
						add_child(plant_instance)
						plants[cell_key] = plant_instance  # Salvo la pianta nel dizionario

				Mode.REMOVE:
					# Se la cella contiene una pianta, la rimuovo
					if plants.has(cell_key):
						plants[cell_key].queue_free()
						plants.erase(cell_key)

func get_pointer_position() -> Vector2:
	# Restituisce la posizione attuale del mouse su desktop o ultima touch position su mobile
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position

# Funzione chiamata quando si preme il pulsante "Posiziona"
func _on_button_place_pressed() -> void:
	current_mode = Mode.NONE        # Nessuna modalità attiva finché non seleziono pianta
	plant_selector.visible = true  # Mostra il selettore di piante
	selected_plant_scene = null     # Reset selezione pianta

# Funzione chiamata quando si preme il pulsante "Rimuovi"
func _on_button_remove_pressed() -> void:
	current_mode = Mode.REMOVE      # Attivo modalità rimozione

# Funzione chiamata quando si preme il pulsante "Annulla"
func _on_abort_pressed() -> void:
	current_mode = Mode.NONE        # Torno a nessuna modalità attiva
	plant_selector.visible = false # Nascondo il selettore di piante

# Funzione chiamata quando si seleziona la pianta 1 nel selettore
func _on_button_plant_1_pressed() -> void:
	selected_plant_scene = plant_scenes["plant1"]  # Seleziono la scena della pianta 1
	current_mode = Mode.PLACE                     # Attivo modalità posizionamento
	plant_selector.visible = false                # Nascondo il selettore

# Funzione chiamata quando si seleziona la pianta 2 nel selettore
func _on_button_plant_2_pressed() -> void:
	selected_plant_scene = plant_scenes["plant2"]  # Seleziono la scena della pianta 2
	current_mode = Mode.PLACE                     # Attivo modalità posizionamento
	plant_selector.visible = false                # Nascondo il selettore
