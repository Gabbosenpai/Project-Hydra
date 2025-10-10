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

# Il tuo dizionario 'dic' ORA SARÀ ASSEGNATO ESTERNAMENTE.
var dic = {} # Inizializzato vuoto, verrà riempito da GridInitializer

var turret_scenes = {
	"turret1": preload("res://Scenes/Towers/delivery_drone.tscn"),
	"turret2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"turret3": preload("res://Scenes/Towers/jammer_cannon.tscn")
}

# ----------------------------------------------------------------------

# Rimuovi _ready() da qui. Il dizionario 'dic' deve essere assegnato dopo che
# GridInitializer ha eseguito il suo _ready().
func set_grid_data(data: Dictionary):
	# Metodo per ricevere il dizionario dal GridInitializer
	dic = data
	print("TurretManager ha ricevuto i dati della griglia.")

# Logica di pulizia totale e ridisegno (basata sul tuo codice)
func _process(_delta):
	# Controlla se il dizionario è stato inizializzato prima di usarlo
	if dic.is_empty():
		return 

	$"/root/Main/UI/ButtonRemove".visible = not turrets.is_empty()

	# 1. Pulizia Totale del Livello Highlight (Logica Semplificata)
	for x in range(GameConstants.COLUMN):
		for y in range(GameConstants.ROW):
			tilemap.erase_cell(HIGHLIGHT_LAYER, Vector2i(x, y))

	if current_mode == Mode.NONE:
		return

	var pointer_pos = get_pointer_position()
	var cell: Vector2i = Vector2i.ZERO
	
	if pointer_pos != null:
		# 2. Ottieni la cella usando la conversione CORRETTA (risolve lo sfalsamento)
		var maybe_cell = get_valid_cell_from_position(pointer_pos)
		if maybe_cell != null:
			cell = maybe_cell
		else:
			return
	else:
		return

	# --- Controllo con il Dizionario e Disegno ---
	# 3. Verifica se la cella è valida (collegata al cursore)
	var cell_key = str(cell)
	if not dic.has(cell_key):
		return # Cella non valida o non mappata nel dizionario

	var draw_highlight = false
	var tile_modulate: Color = Color.WHITE
	var is_occupied = turrets.has(cell)
	
	# Logica di colore
	if current_mode == Mode.PLACE:
		tile_modulate = Color(1.0, 0.4, 0.4, 0.6) if is_occupied else Color(0.4, 1.0, 0.4, 0.6)
		draw_highlight = true
		
	elif current_mode == Mode.REMOVE:
		if is_occupied:
			tile_modulate = Color(1.0, 0.4, 0.4, 0.6)
			draw_highlight = true

	if draw_highlight:
		# Disegna il tile sul Livello 1
		tilemap.set_cell(HIGHLIGHT_LAYER, cell, HIGHLIGHT_TILE_ID, HIGHLIGHT_ATLAS_COORDS)
		
		# Modifica il colore usando TileData (Godot 4)
		var tile_data = tilemap.get_cell_tile_data(HIGHLIGHT_LAYER, cell)
		if tile_data:
			tile_data.modulate = tile_modulate

# ----------------------------------------------------------------------

func select_turret(key: String):
	var point_manager = $"/root/Main/PointManager"
	if point_manager.can_select_turret(key):
		selected_turret_scene = turret_scenes[key]
		current_mode = Mode.PLACE
	else:
		print("Non hai abbastanza punti per piazzare questa pianta!")

func remove_mode():
	current_mode = Mode.REMOVE

func clear_mode():
	current_mode = Mode.NONE

# Risolve lo sfalsamento convertendo la posizione globale in coordinate di cella valide.
func get_valid_cell_from_position(screen_pos: Vector2) -> Vector2i:
	# Ottieni la trasformazione del canvas
	var canvas_xform = get_viewport().get_canvas_transform()
	
	# Calcola la posizione nel mondo
	var world_pos = canvas_xform.affine_inverse() * screen_pos
	
	# Converte la posizione nel mondo in coordinate locali della TileMap
	var local_pos = tilemap.to_local(world_pos)
	var cell = tilemap.local_to_map(local_pos)

	# Verifica se la cella è valida
	if cell.x >= 0 and cell.x < GameConstants.COLUMN and cell.y >= 0 and cell.y < GameConstants.ROW:
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
		
		# Controlla che la cella sia valida e mappata nel dizionario
		# Usa 'dic' qui, quindi deve essere stato assegnato prima!
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
			emit_signal("turret_removed", cell_key, turret_instance)
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
		emit_signal("turret_removed", cell_key, turret_instance)
		turrets.erase(cell_key)
