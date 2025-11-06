extends Node

signal turret_placed(cell_key)
signal turret_removed(cell_key, turret_instance)

@export var tilemap: TileMap

# --- COSTANTI: Configurazione TileMap ---
const HIGHLIGHT_LAYER: int = 1
const HIGHLIGHT_TILE_ID: int = 5
const HIGHLIGHT_ATLAS_COORDS: Vector2i = Vector2i(0, 0)

var turrets = {}
var selected_turret_scene: PackedScene = null
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE
var last_touch_position: Vector2 = Vector2.ZERO
var dic = {} # Inizializzato vuoto, verrà assegnato da GridInitializer

var turret_scenes = {
	"turret1": preload("res://Scenes/Towers/delivery_drone.tscn"),
	"turret2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"turret3": preload("res://Scenes/Towers/jammer_cannon.tscn")
}

# Riceve il dizionario della griglia dal GridInitializer
func set_grid_data(data: Dictionary):
	dic = data
	print("TurretManager ha ricevuto i dati della griglia.")


# --- Aggiornamento visivo del piazzamento e rimozione ---
func _process(_delta):
	if dic.is_empty():
		return 

	$"/root/Main/UI/ButtonRemove".visible = not turrets.is_empty()

	for x in range(GameConstants.COLUMN):
		for y in range(GameConstants.ROW):
			tilemap.erase_cell(HIGHLIGHT_LAYER, Vector2i(x, y))

	if current_mode == Mode.NONE:
		return

	var pointer_pos = get_pointer_position()
	var cell: Vector2i = Vector2i.ZERO
	
	if pointer_pos != null:
		var maybe_cell = get_valid_cell_from_position(pointer_pos)
		if maybe_cell != null:
			cell = maybe_cell
		else:
			return
	else:
		return

	var cell_key = str(cell)
	if not dic.has(cell_key):
		return

	var draw_highlight = false
	var tile_modulate: Color = Color.WHITE
	var is_occupied = turrets.has(cell)
	
	if current_mode == Mode.PLACE:
		tile_modulate = Color(1.0, 0.4, 0.4, 0.6) if is_occupied else Color(0.4, 1.0, 0.4, 0.6)
		draw_highlight = true
		
	elif current_mode == Mode.REMOVE:
		if is_occupied:
			tile_modulate = Color(1.0, 0.4, 0.4, 0.6)
			draw_highlight = true

	if draw_highlight:
		tilemap.set_cell(HIGHLIGHT_LAYER, cell, HIGHLIGHT_TILE_ID, HIGHLIGHT_ATLAS_COORDS)
		var tile_data = tilemap.get_cell_tile_data(HIGHLIGHT_LAYER, cell)
		if tile_data:
			tile_data.modulate = tile_modulate


# --- Gestione torrette ---
func select_turret(key: String):
	var point_manager = $"/root/Main/PointManager"
	if point_manager.can_select_turret(key):
		selected_turret_scene = turret_scenes[key]
		current_mode = Mode.PLACE
	else:
		print("Non hai abbastanza punti per piazzare questa torretta!")


func remove_mode():
	current_mode = Mode.REMOVE

func clear_mode():
	current_mode = Mode.NONE


# Conversione da posizione globale a cella TileMap
func get_valid_cell_from_position(screen_pos: Vector2) -> Vector2i:
	var canvas_xform = get_viewport().get_canvas_transform()
	var world_pos = canvas_xform.affine_inverse() * screen_pos
	var local_pos = tilemap.to_local(world_pos)
	var cell = tilemap.local_to_map(local_pos)
	if cell.x > 0 and cell.x < GameConstants.COLUMN and cell.y >= 0 and cell.y < GameConstants.ROW:
		return cell
	return Vector2i(-1, -1)


func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position


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
		if cell_key != null and dic.has(str(cell_key)):
			if current_mode == Mode.PLACE:
				place_turret(cell_key)
			elif current_mode == Mode.REMOVE:
				remove_turret(cell_key)


func place_turret(cell_key: Vector2i):
	if not turrets.has(cell_key) and selected_turret_scene != null:
		var turret_instance = selected_turret_scene.instantiate()
		
		if turret_instance.has_signal("died"):
			turret_instance.died.connect(handle_turret_death)

		turret_instance.global_position = tilemap.to_global(tilemap.map_to_local(cell_key))

		if turret_instance.has_method("set_riga"):
			turret_instance.set_riga(cell_key.y)
			
		add_child(turret_instance)
		turrets[cell_key] = turret_instance
		emit_signal("turret_placed", cell_key)
		clear_mode()


func remove_turret(cell_key: Vector2i):
	if turrets.has(cell_key):
		var turret_instance = turrets[cell_key]
		
		if is_instance_valid(turret_instance):
			# NON è una distruzione, quindi is_destruction è false (default)
			emit_signal("turret_removed", cell_key, turret_instance, false) 
			turret_instance.queue_free()
		
		turrets.erase(cell_key)
		clear_mode()


func handle_turret_death(turret_instance: Node2D):
	var cell_key: Vector2i = Vector2i.ZERO
	for key in turrets:
		if turrets[key] == turret_instance:
			cell_key = key
			break
	
	if cell_key != Vector2i.ZERO:
		emit_signal("turret_removed", cell_key, turret_instance, false) # false = rimborso totale
		turrets.erase(cell_key)


# --- 🔥 Nuova funzione: spostamento torrette dopo ogni ondata ---
func move_turrets_back(_wave_number: int):
	if _wave_number == 1:
		print("Salto Movimento Torrette: Ondata 1 è la prima ondata. Non devono indietreggiare le torrette.")
		return
	
	if turrets.is_empty():
		print("Nessuna torretta da spostare.")
		return

	var new_turrets = {}
	var turrets_to_incinerate = [] # Array per tracciare le torrette in colonna 0

	# 1. Fase di Spostamento e Istruzione Torrette da Incenerire
	for old_cell in turrets.keys():
		var turret_instance = turrets[old_cell]
		var new_cell = Vector2i(old_cell.x - 1, old_cell.y)

		if is_instance_valid(turret_instance):
			
			var new_pos = tilemap.to_global(tilemap.map_to_local(new_cell))
			var tween = create_tween()
			
			# NON usiamo 'await', avviamo l'animazione e proseguiamo subito
			tween.tween_property(turret_instance, "global_position", new_pos, 0.3) 

			if new_cell.x < 1:
				# 🛑 Torretta destinata alla Colonna 0 (Inceneritore)
				turrets_to_incinerate.append(turret_instance)
				# Non aggiungiamo la torretta a new_turrets, viene incenerita
			else:
				# ✅ Caso di Spostamento (Colonna 2 -> Colonna 1, ecc.)
				
				# Aggiungere la torretta al nuovo dizionario con la NUOVA cella
				new_turrets[new_cell] = turret_instance
				
				# Aggiorniamo la riga/colonna interna della torretta se necessario (dipende dalla sua implementazione)
				if turret_instance.has_method("set_riga"):
					turret_instance.set_riga(new_cell.y)
		else:
			print("ATTENZIONE: Trovata istanza torretta non valida in cella: ", old_cell)
	
	# 2. Sostituisci il vecchio dizionario con quello delle torrette sopravvissute
	turrets = new_turrets
	
	print("✅ Tutte le torrette hanno iniziato a muoversi indietro di una cella.")
	
	# 3. Avvia il processo di incenerimento per tutte le torrette in Colonna 0
	for turret_instance in turrets_to_incinerate:
		_incinerate_with_delay(turret_instance)

# 🔥 Nuova funzione: distrugge la torretta in colonna 0 (posizione inceneritore)
func destroy_turret_at_incinerator_pos(row_y: int):
	var cell_key = Vector2i(0, row_y)

	if turrets.has(cell_key):
		var turret_instance = turrets[cell_key]
		
		if is_instance_valid(turret_instance):
			# È una distruzione: is_destruction = true
			emit_signal("turret_removed", cell_key, turret_instance, true) 
			turret_instance.queue_free()
		
		turrets.erase(cell_key)

# 🔥 Nuova funzione: Incenerisce TUTTE le torrette in una riga (dopo l'attivazione)
func destroy_all_turrets_in_row(row_y: int):
	var to_destroy = []
	
	for cell_key in turrets.keys():
		if cell_key.y == row_y:
			to_destroy.append(cell_key)
			var turret_instance = turrets[cell_key]
			
			if is_instance_valid(turret_instance):
				# Nessun rimborso, queste vengono incenerite
				turret_instance.queue_free() 

	for cell_key in to_destroy:
		turrets.erase(cell_key)
	
	print("🔥 Tutte le %d torrette in riga %d sono state incenerite." % [to_destroy.size(), row_y])

# 🔥 NUOVA FUNZIONE: Gestisce l'attesa e la distruzione di una singola torretta
func _incinerate_with_delay(turret_instance: Node2D):
	# 1. Non aspettiamo qui il tween, l'animazione di movimento è già partita!
	
	var delay_seconds = 0.5 # Ritardo dell'inceneritore

	# 2. Avvia il timer per il ritardo (per simulare il tempo nell'inceneritore)
	var timer = get_tree().create_timer(delay_seconds)
	await timer.timeout
	
	# 3. Distruzione finale
	if is_instance_valid(turret_instance):
		print("🔥 Incenerita torretta dopo il ritardo.")
		
		# È una distruzione: is_destruction = true
		# Nota: qui stiamo usando Vector2i.ZERO come chiave fittizia perché l'istanza è già stata rimossa da 'turrets'
		emit_signal("turret_removed", Vector2i.ZERO, turret_instance, true) 
		turret_instance.queue_free()
