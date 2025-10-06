extends Node

signal turret_placed(cell_key)
signal turret_removed(cell_key, turret_instance)

@export var tilemap: TileMap
# Costanti per il nuovo metodo di Evidenziazione tramite TileMap Layer
const HIGHLIGHT_LAYER = 1    # Layer ID 1 per l'evidenziazione
const HIGHLIGHT_TILE_ID = 0  # ID della Tile che hai creato nel TileSet (la tua texture)
const HIGHLIGHT_ATLAS_COORDS = Vector2i.ZERO # Coordinate Atlas, per le single tile è sempre (0, 0)
# Dizionario che mappa celle a istanze di piante
var turrets = {}
# Scena della pianta attualmente selezionata per il piazzamento
var selected_turret_scene: PackedScene = null
# Modalità correnti: nessuna, piazzamento o rimozione
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE
# Ultima posizione del tocco (utile per dispositivi touch)
var last_touch_position: Vector2 = Vector2.ZERO

# Precaricamento delle scene delle piante disponibili
var turret_scenes = {
	"turret1": preload("res://Scenes/Towers/delivery_drone.tscn"),
	"turret2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"turret3": preload("res://Scenes/Towers/jammer_cannon.tscn"),
	"turret4": preload("res://Scenes/Plants/plant_4.tscn")
}

# Seleziona una torretta da piazzare e attiva la modalità piazzamento
func select_turret(key: String):
	var point_manager = $"/root/Main/PointManager"
	if point_manager.can_select_turret(key):
		selected_turret_scene = turret_scenes[key]
		current_mode = Mode.PLACE
	else:
		print("Non hai abbastanza punti per piazzare questa pianta!")


# Attiva la modalità rimozione
func remove_mode():
	current_mode = Mode.REMOVE

# Disattiva qualsiasi modalità attiva
func clear_mode():
	current_mode = Mode.NONE
	# Pulizia tramite Layer
	tilemap.clear_layer(HIGHLIGHT_LAYER)

# Gestisce l'aggiornamento visivo dell'highlight e controlla se il puntatore è sopra una cella valida
func _process(_delta):
	# Mostra il pulsante di rimozione solo se ci sono piante
	$"/root/Main/UI/ButtonRemove".visible = not turrets.is_empty()

	# 1. Pulisci il layer di highlight ad ogni frame per rimuovere l'evidenziazione precedente
	tilemap.clear_layer(HIGHLIGHT_LAYER)

	if current_mode == Mode.NONE:
		return

	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		return

	# Converte la posizione del puntatore in coordinate cella
	var local_pos = tilemap.to_local(pointer_pos)
	var cell = tilemap.local_to_map(local_pos)

	# Verifica se la cella è all'interno della griglia di gioco
	if cell.x >= 0 and cell.x < GameConstants.COLUMN and cell.y >= 0 and cell.y < GameConstants.ROW:
		
		var modulate_color = Color.WHITE # Colore di base

		if current_mode == Mode.PLACE:
			# Imposta un colore modulato verde per il piazzamento
			modulate_color = Color(0.4, 1.0, 0.4, 0.6) 
		else:
			# Imposta un colore modulato rosso per la rimozione
			modulate_color = Color(1.0, 0.4, 0.4, 0.6) 

		# 2. PIAZZA LA TILE DI HIGHLIGHT sulla cella corrente
		tilemap.set_cell(HIGHLIGHT_LAYER, cell, HIGHLIGHT_TILE_ID, HIGHLIGHT_ATLAS_COORDS)

		# 3. MODULA IL COLORE della tile per il feedback visivo
		var tile_data = tilemap.get_cell_tile_data(HIGHLIGHT_LAYER, cell)
		if tile_data: # Assicurati che i dati della tile esistano
			tile_data.set_modulate(modulate_color)

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
		# Questo compensa la tendenza all'arrotondamento verso il basso/destra 
		# quando si clicca vicino al confine inferiore/destro di una cella.
		var tile_size = tilemap.tile_set.tile_size
		var correction_offset = tile_size * 0.01 # Un piccolo 1% di correzione
		
		# Applica la correzione: (pointer_pos - correction_offset)
		var corrected_pos = pointer_pos - correction_offset

		var local_pos = tilemap.to_local(corrected_pos)
		var cell = tilemap.local_to_map(local_pos)
		var cell_key = Vector2i(cell.x, cell.y)

		if current_mode == Mode.PLACE:
			place_turret(cell_key)
		elif current_mode == Mode.REMOVE:
			remove_turret(cell_key)

# Piazza una pianta in una cella vuota e invia il segnale corrispondente
func place_turret(cell_key: Vector2i):
	if not turrets.has(cell_key) and selected_turret_scene != null:
		var turret_instance = selected_turret_scene.instantiate()
		
		# Connette il segnale di morte per la pulizia automatica
		if turret_instance.has_signal("died"):
			turret_instance.died.connect(handle_turret_death)
			
		var tile_size = tilemap.tile_set.tile_size
		var tile_center = tilemap.map_to_local(cell_key) + tile_size * 0.5
		# Applica un offset verticale negativo (rispetto all'altezza della tile) 
		# per sollevare la torretta e allineare il suo centro visivo alla riga.
		# Prova con un valore piccolo, ad esempio l'8% dell'altezza della tile.
		var visual_offset = tile_size.y * 0.50 
		tile_center.y -= visual_offset 
		turret_instance.global_position = tilemap.to_global(tile_center)
		# Imposta la riga per allineamento dei proiettili o logica interna
		if turret_instance.has_method("set_riga"):
			turret_instance.set_riga(cell_key.y)
		add_child(turret_instance)
		turrets[cell_key] = turret_instance
		emit_signal("turret_placed", cell_key)
		clear_mode()

# Funzione per pulire il dizionario turrets quando una torretta muore automaticamente
func handle_turret_death(turret_instance: Node2D):
	# Trova la chiave della cella associata all'istanza
	var cell_key: Vector2i = Vector2i.ZERO
	# Si itera per trovare la chiave a partire dal valore (l'istanza)
	for key in turrets:
		if turrets[key] == turret_instance:
			cell_key = key
			break
	
	if cell_key != Vector2i.ZERO:
		# Emette il segnale per notificare la rimozione ad altri sistemi (es. PointManager)
		emit_signal("turret_removed", cell_key, turret_instance) 
		# Pulisce il riferimento dal dizionario
		turrets.erase(cell_key)
		# Non è necessario chiamare queue_free() qui, in quanto è chiamato dalla funzione die() della torretta

# Rimuove una pianta esistente e invia il segnale corrispondente (rimozione manuale)
func remove_turret(cell_key: Vector2i):
	if turrets.has(cell_key):
		var turret_instance = turrets[cell_key]
		
		# Aggiungi la verifica con is_instance_valid() per evitare Null Pointer Exception
		if is_instance_valid(turret_instance):
			emit_signal("turret_removed", cell_key, turret_instance) # Passiamo anche l’istanza
			turret_instance.queue_free()
		
		# Rimuovi la chiave dal dizionario per pulire il riferimento, sia che fosse valida o meno
		turrets.erase(cell_key)
		clear_mode()

# Restituisce la posizione del puntatore (mouse o touch)
func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position
