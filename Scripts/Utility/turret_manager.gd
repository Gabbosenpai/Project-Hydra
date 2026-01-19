extends Node

signal turret_placed(cell_key)
signal turret_placed_UI
signal turret_deleted_UI
signal not_enough_scrap

# --- COSTANTI: Configurazione TileMap ---
const HIGHLIGHT_LAYER: int = 1
const HIGHLIGHT_TILE_ID: int = 5
const HIGHLIGHT_ATLAS_COORDS: Vector2i = Vector2i(0, 0)
const CONVEYOR_SHIFT_DURATION: float = 0.85
const INCINERATOR_LAYER: int = 0
const INCINERATOR_TILE_ID: int = 4
const INCINERATOR_ATLAS_COORDS: Vector2i = Vector2i(0, 0)
const BLAST_DURATION: float = 0.5
const TURRET_UNLOCKS = {
	"turret1": 1, # Delivery Drone (Sempre disponibile)
	"turret2": 1, # Bolt Shooter (Sempre disponibile)
	"turret3": 2, # Jammer Cannon (Dal Livello 2)
	"turret4": 3, # HKCM (Dal Livello 3)
	"turret5": 4, # Spaghetti Cable (Dal Livello 4)
	"turret6": 5  # Toilet Silo (Dal Livello 5)
}

@export var tilemap: TileMap

var conveyor_phase_shift: int = 0
var turrets = {}
var selected_turret_scene: PackedScene = null
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE
var last_touch_position: Vector2 = Vector2.ZERO
var dic = {} # Inizializzato vuoto, verrà assegnato da GridInitializer
var incinerator_scene: PackedScene = preload("res://Scenes/Utilities/incinerator.tscn")
var tower_construcion: PackedScene = preload("res://Scenes/Towers/tower_construction.tscn")
var placing_sfx: AudioStream = preload("res://Assets/Sound/SFX/placingTower.mp3")
var active_incinerators = {} # Mappa: {row_y: incinerator_instance}
var row_locked_by_robot = {}
var turret_scenes = {
	"turret1": preload("res://Scenes/Towers/delivery_drone.tscn"),
	"turret2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"turret3": preload("res://Scenes/Towers/jammer_cannon.tscn"),
	"turret4": preload("res://Scenes/Towers/HKCM.tscn"),
	"turret5": preload("res://Scenes/Towers/spaghetti_cable.tscn"),
	"turret6": preload("res://Scenes/Towers/toilet_silo.tscn")
}

@onready var grid_initializer = get_parent().get_node("GridInitializer")
@onready var enemy_manager = get_parent().get_node("EnemySpawner")


func initialize_incinerators():
	if !tilemap: return
	
	for y in range(GameConstants.ROW):
		var cell_key = Vector2i(0, y)
		
		# 1. Imposta lo stato iniziale: Inceneritore Aperto / Sicuro
		row_locked_by_robot[y] = false 
		
		# 2. Rimuovi il tile statico e istanzia l'inceneritore animato
		tilemap.erase_cell(INCINERATOR_LAYER, cell_key) 
		
		var incinerator_instance = incinerator_scene.instantiate()
		incinerator_instance.global_position = tilemap.to_global(tilemap.map_to_local(cell_key))
		add_child(incinerator_instance)
		
		# 3. Inizializza nello stato 'attesa' (aperto)
		incinerator_instance.open_incinerator() 
		
		active_incinerators[y] = incinerator_instance


# Riceve il dizionario della griglia dal GridInitializer
func set_grid_data(data: Dictionary):
	dic = data
	print("TurretManager ha ricevuto i dati della griglia.")


# Aggiornamento visivo del piazzamento e rimozione
func _process(_delta):
	if dic.is_empty():
		return 
	
	#$"/root/Main/UI/ButtonRemove".visible = not turrets.is_empty()
	
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


# Gestione torrette 
func select_turret(key: String):
	if current_mode == Mode.REMOVE:
		clear_mode()
		emit_signal("turret_deleted_UI")
	var level_path = get_parent().current_level
	var level_num = 1
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(level_path)
	if result:
		level_num = result.get_string().to_int()

	# Controllo sblocco
	if TURRET_UNLOCKS.has(key) and level_num < TURRET_UNLOCKS[key]:
		print("Torretta bloccata! Si sblocca al livello: ", TURRET_UNLOCKS[key])
		return
	var point_manager = $"/root/Main/PointManager"
	if selected_turret_scene == turret_scenes[key]:
		emit_signal("turret_placed_UI")
		selected_turret_scene = null
	elif point_manager.can_select_turret(key):
		selected_turret_scene = turret_scenes[key]
		current_mode = Mode.PLACE
	else:
		selected_turret_scene = null
		emit_signal("turret_placed_UI")
		emit_signal("not_enough_scrap")
		print("Non hai abbastanza punti per piazzare questa torretta!")


func remove_mode():
	if current_mode != Mode.REMOVE:
		current_mode = Mode.REMOVE
		emit_signal("turret_placed_UI")
	else:
		clear_mode()


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
		var turret_scene_to_place = selected_turret_scene
		clear_mode()
		
		var spawn_point = tilemap.to_global(tilemap.map_to_local(cell_key))
		var turret_key_to_place = turret_scenes.find_key(turret_scene_to_place)
		
		var turret_instance = turret_scene_to_place.instantiate()
		
		if turret_instance.has_signal("died"):
			turret_instance.died.connect(handle_turret_death)
		
		turret_instance.global_position = spawn_point
		
		if turret_instance.has_method("set_riga"):
			turret_instance.set_riga(cell_key.y)
		
		if turret_instance.has_method("set_colonna"):
			turret_instance.set_colonna(cell_key.x)
		
		if turret_key_to_place:
			turret_instance.turret_key = turret_key_to_place
			print("Torretta piazzata con chiave: ", turret_key_to_place)
			
		add_child(turret_instance)
		turret_instance.visible = false
		turrets[cell_key] = turret_instance
		emit_signal("turret_placed", cell_key)
		emit_signal("turret_placed_UI")
		clear_mode()
		
		var construction = tower_construcion.instantiate()
		construction.global_position = spawn_point
		
		print("DEBUG: Avvio animazione drone, posizione iniziale: ", construction.global_position)
		add_child(construction)
		await get_tree().process_frame
		
		if construction:
			AudioManager.play_sfx(placing_sfx)
			print("DEBUG: Sprite del drone pronto. Avvio animazioni.")
			var animation = construction.get_node("AnimatedSprite2D")
			var construction_timer = Timer.new()
			construction_timer.wait_time = 1.0
			construction_timer.one_shot = true
			construction_timer.autostart = true
			add_child(construction_timer)
			animation.play("construction")
			selected_turret_scene = null
			await construction_timer.timeout
			construction_timer.queue_free()
			
		
		if is_instance_valid(construction):
			construction.queue_free()
		
		if is_instance_valid(turret_instance):
			turret_instance.visible = true
			if turret_instance.has_method("has_just_spawned"):
				turret_instance.has_just_spawned()


func remove_turret(cell_key: Vector2i):
	if turrets.has(cell_key):
		var turret_instance = turrets[cell_key]
		
		if is_instance_valid(turret_instance):
			turret_instance.queue_free()
			emit_signal("turret_deleted_UI")
		turrets.erase(cell_key)
		clear_mode()


func handle_turret_death(turret_instance: Node2D):
	var cell_key: Vector2i = Vector2i.ZERO
	for key in turrets:
		if turrets[key] == turret_instance:
			cell_key = key
			break
	
	if cell_key != Vector2i.ZERO:
		turrets.erase(cell_key)


# Spostamento torrette dopo ogni ondata
func move_turrets_back(_wave_number: int, rows_to_shift: Array = []):
	if _wave_number == 1:
		print("Salto Movimento Torrette: Ondata 1 è la prima ondata. Non devono indietreggiare le torrette.")
		return
	
	if turrets.is_empty():
		print("Nessuna torretta da spostare.")
		return
		
	var is_blackout_mode = !rows_to_shift.is_empty()
		
	if is_blackout_mode:
		print("Movimento torrette limitato alle righe: ", rows_to_shift)
	else:
		print("Movimento torrette su tutte le righe (Modalità Standard).")
		
	if grid_initializer and grid_initializer.has_method("update_conveyors_phase"):
		# 1. Aggiorna la variabile di fase del conveyor
		conveyor_phase_shift = 1 - conveyor_phase_shift
		
		# 2. Chiama la funzione nel GridInitializer per ridisegnare i tile
		grid_initializer.update_conveyors_phase(conveyor_phase_shift,rows_to_shift)
	
	var new_turrets = {}
	var turrets_to_incinerate = [] # Array per tracciare le torrette in colonna 0
	
	# 1. Fase di Spostamento e Istruzione Torrette da Incenerire
	for old_cell in turrets.keys():
		var turret_instance = turrets[old_cell]
		var new_cell = Vector2i(old_cell.x - 1, old_cell.y)
		if is_blackout_mode and !rows_to_shift.has(old_cell.y):
			# Torretta nella riga non selezionata: NON si sposta
			new_turrets[old_cell] = turret_instance
			continue # Passa alla prossima torretta
		
		if is_instance_valid(turret_instance):
			
			var new_pos = tilemap.to_global(tilemap.map_to_local(new_cell))
			var tween = create_tween()
			
			# NON usiamo 'await', avviamo l'animazione e proseguiamo subito
			tween.tween_property(turret_instance, "global_position", new_pos, CONVEYOR_SHIFT_DURATION) 
			
			if new_cell.x < 1:
				# Torretta destinata alla Colonna 0 (Inceneritore)
				turrets_to_incinerate.append({instance = turret_instance, row = old_cell.y})
				tween.finished.connect(func():_incinerate_with_delay(turret_instance, old_cell.y))
				if turret_instance.has_method("set_colonna"):
					turret_instance.set_colonna(0)
				# Non aggiungiamo la torretta a new_turrets, viene incenerita
			else:
				# Caso di Spostamento (Colonna 2 -> Colonna 1, ecc.)
				
				# Aggiungere la torretta al nuovo dizionario con la NUOVA cella
				new_turrets[new_cell] = turret_instance
				
				# Aggiorniamo la riga/colonna interna della torretta se necessario (dipende dalla sua implementazione)
				if turret_instance.has_method("set_riga"):
					turret_instance.set_riga(new_cell.y)
				
				if turret_instance.has_method("set_colonna"):
					turret_instance.set_colonna(new_cell.x)
		
		else:
			print("ATTENZIONE: Trovata istanza torretta non valida in cella: ", old_cell)
	
	# 2. Sostituisci il vecchio dizionario con quello delle torrette sopravvissute
	turrets = new_turrets
	
	print("✅ Tutte le torrette hanno iniziato a muoversi indietro di una cella.")


# Distrugge la torretta in colonna 0 (posizione inceneritore)
func destroy_turret_at_incinerator_pos(row_y: int):
	var cell_key = Vector2i(0, row_y)
	
	if turrets.has(cell_key):
		var turret_instance = turrets[cell_key]
		
		if is_instance_valid(turret_instance):
			turret_instance.queue_free()
		
		turrets.erase(cell_key)


# Incenerisce TUTTE le torrette in una riga (dopo l'attivazione)
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


# Gestisce l'attesa e la distruzione di una singola torretta
func _incinerate_with_delay(turret_instance: Node2D, row_y: int):
	var cell_key = Vector2i(0, row_y)
	var incinerator_pos = tilemap.to_global(tilemap.map_to_local(cell_key))
	
	# Determina lo stato: L'inceneritore è 'Aperto di Default' (Punto 1 & 2) 
	# se NON è stato bloccato da un robot.
	var is_open_by_default = !row_locked_by_robot.get(row_y, false) 
	
	var incinerator_instance = active_incinerators.get(row_y)

	# Gestione Apertura On-Demand 
	# (Solo se l'inceneritore è Chiuso/Bloccato - Punto 4) 
	if !is_open_by_default and not active_incinerators.has(row_y):
		# Inceneritore è chiuso (tile statico) e una torretta sta arrivando. Riaprilo.
		
		# A) Rimuovi il tile statico dell'inceneritore
		tilemap.erase_cell(INCINERATOR_LAYER, cell_key) 
		
		# B) Istanzia e avvia l'animazione di apertura
		incinerator_instance = incinerator_scene.instantiate()
		incinerator_instance.global_position = incinerator_pos
		add_child(incinerator_instance)
		active_incinerators[row_y] = incinerator_instance
		
		# Inceneritore si apre
		await incinerator_instance.open_incinerator() 
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(turret_instance, "scale", Vector2(0, 0), 2.0)
	tween.parallel().tween_property(turret_instance, "rotation", 7.5 , 2.0)
	# Ritardo e Distruzione della Torretta 
	var delay_seconds = 3 
	var timer = get_tree().create_timer(delay_seconds)
	await timer.timeout
	
	if turret_instance.has_method("spawn_scrap_on_incinerate"):
			turret_instance.spawn_scrap_on_incinerate()
	
	print("🔥 Incenerita torretta dopo il ritardo.")
	turret_instance.queue_free()
	
	var post_destruction_delay = 1.0
	var post_timer = get_tree().create_timer(post_destruction_delay)
	await post_timer.timeout
	
	# Gestione Chiusura Finale 
	if is_open_by_default:
		# L'inceneritore resta attivo e aperto (Punto 2)
		pass 
	
	# Se era bloccato (o riaperto on-demand), lo richiudiamo se non ci sono altre torrette in coda
	elif not _is_any_turret_moving_to_incinerator_in_row(row_y):
		_close_incinerator(row_y)


func _is_any_turret_moving_to_incinerator_in_row(row_y: int) -> bool:
	# Controlliamo il dizionario 'turrets' per vedere se c'è qualcosa in colonna 0
	return turrets.has(Vector2i(0, row_y))


func _close_incinerator(row_y: int):
	if active_incinerators.has(row_y):
		var incinerator_instance = active_incinerators[row_y]
		active_incinerators.erase(row_y) # Rimuovi dalla mappa degli inceneritori attivi
		
		if is_instance_valid(incinerator_instance):
			# L'incenertiore si chiude
			await incinerator_instance.close_incinerator()
		
		# Sostituisci con il tile statico dell'inceneritore chiuso
		var cell_key = Vector2i(0, row_y)
		tilemap.set_cell(INCINERATOR_LAYER, cell_key, INCINERATOR_TILE_ID, INCINERATOR_ATLAS_COORDS)


func close_incinerator_on_robot_entry(row_y: int):
	# 1. Imposta lo stato di blocco/pericolo
	row_locked_by_robot[row_y] = true 
	# 2. Esegui la chiusura fisica (rimozione istanza e ripristino tile)
	_close_incinerator(row_y)

# Funzione per eseguire la pulizia della riga con animazione coordinata
# Questa è la funzione che dovrai chiamare da un'abilità o evento.
func execute_row_blast_cleanup(row_y: int):
	print("--- Esecuzione Blast di Riga %d Iniziata ---" % row_y)
	
	# 1. Avvia le animazioni del conveyor (SINCRONA - parte subito in parallelo)
	if grid_initializer and grid_initializer.has_method("animate_conveyors_blast"):
		grid_initializer.animate_conveyors_blast(row_y)
	
	# 2. Distrugge le torrette presenti sulla riga (SINCRONA - SPARIZIONE IMMEDIATA)
	destroy_all_turrets_in_row(row_y) 
	
	# 3. Avvia la distruzione animata dei nemici e ASPEtta il tempo del blast (TASK ASINCRONO)
	if enemy_manager and enemy_manager.has_method("destroy_robots_in_row_with_animation"):
		# Questo await aspetta 0.5 secondi e poi aggiorna i contatori
		await enemy_manager.destroy_robots_in_row_with_animation(row_y)
	else:
		# Se l'EnemyManager non c'è, aspetta solo la durata del blast
		await get_tree().create_timer(BLAST_DURATION).timeout
		
	# 4. Ripristina i tile statici del conveyor (solo dopo l'attesa)
	if grid_initializer and grid_initializer.has_method("restore_conveyor_tiles"):
		grid_initializer.restore_conveyor_tiles(row_y, conveyor_phase_shift)
	
	print("--- Pulizia di Riga %d Completata ---" % row_y)
