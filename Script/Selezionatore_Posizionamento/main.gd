extends Node2D

# Riferimenti ai nodi della scena
@onready var tilemap = $TileMap  # TileMap principale (griglia)
@onready var highlight = $Highlight  # Nodo per evidenziare la cella selezionata
@onready var button_place = $UI/ButtonPlace  # Bottone per piazzare piante
@onready var button_remove = $UI/ButtonRemove  # Bottone per rimuovere piante
@onready var button_cancel = $UI/Abort  # Bottone per annullare l'azione corrente
@onready var plant_selector = $UI/PlantSelector  # UI di selezione della pianta
@onready var button_plant1 = $UI/PlantSelector/ButtonPlant1  # Bottone per selezionare pianta 1
@onready var button_plant2 = $UI/PlantSelector/ButtonPlant2  # Bottone per selezionare pianta 2

# Dimensioni della griglia
const GRID_WIDTH = 10
const GRID_HEIGHT = 6

# Variabili di stato
var last_touch_position: Vector2 = Vector2.ZERO  # Ultima posizione del tocco (mobile)
var selected_plant_scene: PackedScene = null  # Scena della pianta selezionata

# Dizionario delle piante disponibili
var plant_scenes = {
	"plant1": preload("res://Scene/Piante/plant.tscn"),
	"plant2": preload("res://Scene/Piante/plant_2.tscn")
}

# Dizionario che tiene traccia delle piante piazzate nella griglia
var plants = {}

# Modalità attuale dell'utente (nessuna, piazzamento o rimozione)
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE

# Funzione chiamata ogni frame
func _process(delta):
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
		
		# Posiziona l'highlight centrato sulla cella selezionata
		highlight.position = highlight.get_parent().to_local(global_pos - tile_size * 0.5)
		highlight.visible = true

		# Cambia colore dell'highlight in base alla modalità
		match current_mode:
			Mode.PLACE:
				highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)  # Verde trasparente
			Mode.REMOVE:
				highlight.modulate = Color(1.0, 0.4, 0.4, 0.6)  # Rosso trasparente
	else:
		highlight.visible = false

# Gestione dell'input non gestito (click o tocco)
func _unhandled_input(event):
	if current_mode == Mode.NONE:
		return

	var pointer_pos = null

	# Touch su dispositivi mobili
	if event is InputEventScreenTouch and event.pressed:
		pointer_pos = event.position
		last_touch_position = pointer_pos
	# Click con il mouse su PC
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pointer_pos = event.position

	if pointer_pos != null:
		var local_pos = tilemap.to_local(pointer_pos)
		var cell = tilemap.local_to_map(local_pos)
		var cell_key = Vector2i(cell.x, cell.y)

		match current_mode:
			Mode.PLACE:
				# Se la cella è libera e una pianta è stata selezionata, piazza la pianta
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

			Mode.REMOVE:
				# Se c'è una pianta nella cella, rimuovila
				if plants.has(cell_key):
					plants[cell_key].queue_free()
					plants.erase(cell_key)
					print("Removed plant at cell: ", cell_key)
				else:
					print("No plant to remove at cell: ", cell_key)

# Ottiene la posizione del puntatore (mouse o tocco)
func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position

# Quando si preme il bottone per piazzare piante
func _on_button_place_pressed() -> void:
	current_mode = Mode.NONE
	plant_selector.visible = true
	selected_plant_scene = null  # Aspetta che venga selezionata una pianta

# Quando si preme il bottone per rimuovere piante
func _on_button_remove_pressed() -> void:
	current_mode = Mode.REMOVE

# Quando si preme il bottone di annulla
func _on_abort_pressed() -> void:
	current_mode = Mode.NONE
	plant_selector.visible = false

# Quando si seleziona la pianta 1
func _on_button_plant_1_pressed() -> void:
	selected_plant_scene = plant_scenes["plant1"]
	current_mode = Mode.PLACE
	plant_selector.visible = false

# Quando si seleziona la pianta 2
func _on_button_plant_2_pressed() -> void:
	selected_plant_scene = plant_scenes["plant2"]
	current_mode = Mode.PLACE
	plant_selector.visible = false
