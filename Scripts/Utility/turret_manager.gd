extends Node

signal turret_placed(cell_key)
signal turret_removed(cell_key, turret_instance)

@export var tilemap: TileMap
@export var highlight: ColorRect

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
	$"/root/Main/UI/ButtonRemove".visible = not turrets.is_empty()

	if current_mode == Mode.NONE:
		highlight.visible = false
		return

	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		highlight.visible = false
		return

	# Ottiene la cella valida (o null se fuori dai limiti)
	var cell = get_valid_cell_from_position(pointer_pos)

	if cell != null:
		# Posiziona l'highlight centrato sulla cella
		highlight.position = tilemap.map_to_local(cell)
		highlight.visible = true

		# Cambia colore dell'highlight in base alla modalità
		if current_mode == Mode.PLACE:
			highlight.modulate = Color(0.4, 1.0, 0.4, 0.6) # verde trasparente
		else:
			highlight.modulate = Color(1.0, 0.4, 0.4, 0.6) # rosso trasparente
	else:
		highlight.visible = false

# Restituisce la chiave della cella (Vector2i) se è all'interno dei limiti della griglia, altrimenti null.
func get_valid_cell_from_position(position: Vector2) -> Variant:
	var local_pos = tilemap.to_local(position)
	var cell = tilemap.local_to_map(local_pos)
	
	# Verifica se la cella è all'interno della griglia di gioco
	if cell.x >= 0 and cell.x < GameConstants.COLUMN and cell.y >= 0 and cell.y < GameConstants.ROW:
		return Vector2i(cell.x, cell.y)
	return null

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
		var cell_key = get_valid_cell_from_position(pointer_pos)
		
		# Procede solo se la cella è valida (non è null)
		if cell_key != null:
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
