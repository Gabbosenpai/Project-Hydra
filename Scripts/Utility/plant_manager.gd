extends Node

signal plant_placed(cell_key)
signal plant_removed(cell_key, plant_instance)

@export var tilemap: TileMap
@export var highlight: ColorRect

# Dizionario che mappa celle a istanze di piante
var plants = {}
# Scena della pianta attualmente selezionata per il piazzamento
var selected_plant_scene: PackedScene = null
# Modalità correnti: nessuna, piazzamento o rimozione
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE
# Ultima posizione del tocco (utile per dispositivi touch)
var last_touch_position: Vector2 = Vector2.ZERO

# Precaricamento delle scene delle piante disponibili
var plant_scenes = {
	"plant1": preload("res://Scenes/Base Tower/base_tower.tscn"),
	"plant2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"plant3": preload("res://Scenes/Plants/plant_3.tscn"),
	"plant4": preload("res://Scenes/Plants/plant_4.tscn")
}

# Seleziona una pianta da piazzare e attiva la modalità piazzamento
func select_plant(key: String):
	var point_manager = $"/root/Main/PointManager"
	if point_manager.can_select_plant(key):
		selected_plant_scene = plant_scenes[key]
		current_mode = Mode.PLACE
		highlight.visible = true
	else:
		print("Non hai abbastanza punti per piazzare questa pianta!")


# Attiva la modalità rimozione
func remove_mode():
	current_mode = Mode.REMOVE

# Disattiva qualsiasi modalità attiva
func clear_mode():
	current_mode = Mode.NONE
	highlight.visible = false

# Gestisce l'aggiornamento visivo dell'highlight e controlla se il puntatore è sopra una cella valida
func _process(_delta):
	# Mostra il pulsante di rimozione solo se ci sono piante
	$"/root/Main/UI/ButtonRemove".visible = not plants.is_empty()

	if current_mode == Mode.NONE:
		highlight.visible = false
		return

	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		highlight.visible = false
		return

	# Converte la posizione del puntatore in coordinate cella
	var local_pos = tilemap.to_local(pointer_pos)
	var cell = tilemap.local_to_map(local_pos)

	# Verifica se la cella è all'interno della griglia di gioco
	if cell.x >= 0 and cell.x < GameConstants.GRID_WIDTH and cell.y >= 0 and cell.y < GameConstants.GRID_HEIGHT:
		var tile_size = tilemap.tile_set.tile_size
		var tile_top_left = tilemap.map_to_local(cell)
		var tile_center = tile_top_left + tile_size * 0.5
		var global_pos = tilemap.to_global(tile_center)
		# Posiziona l'highlight centrato sulla cella
		highlight.position = highlight.get_parent().to_local(global_pos - tile_size * 0.5)
		highlight.visible = true

		# Cambia colore dell'highlight in base alla modalità
		if current_mode == Mode.PLACE:
			highlight.modulate = Color(0.4, 1.0, 0.4, 0.6) # verde trasparente
		else:
			highlight.modulate = Color(1.0, 0.4, 0.4, 0.6) # rosso trasparente
	else:
		highlight.visible = false

# Gestisce input di mouse o touch per piazzare o rimuovere piante
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

		if current_mode == Mode.PLACE:
			place_plant(cell_key)
		elif current_mode == Mode.REMOVE:
			remove_plant(cell_key)

# Piazza una pianta in una cella vuota e invia il segnale corrispondente
func place_plant(cell_key: Vector2i):
	if not plants.has(cell_key) and selected_plant_scene != null:
		var plant_instance = selected_plant_scene.instantiate()
		var tile_size = tilemap.tile_set.tile_size
		var tile_center = tilemap.map_to_local(cell_key) + tile_size * 0.5
		plant_instance.global_position = tilemap.to_global(tile_center)
		# Imposta la riga per allineamento dei proiettili o logica interna
		if plant_instance.has_method("set_riga"):
			plant_instance.set_riga(cell_key.y)
		add_child(plant_instance)
		plants[cell_key] = plant_instance
		emit_signal("plant_placed", cell_key)
		clear_mode()

# Rimuove una pianta esistente e invia il segnale corrispondente
func remove_plant(cell_key: Vector2i):
	if plants.has(cell_key):
		var plant_instance = plants[cell_key]
		emit_signal("plant_removed", cell_key, plant_instance) # Passiamo anche l’istanza
		plant_instance.queue_free()
		plants.erase(cell_key)
		clear_mode()

# Restituisce la posizione del puntatore (mouse o touch)
func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position
