extends Node2D

@onready var tilemap = $TileMap
@onready var highlight = $Highlight
@onready var button_place = $UI/ButtonPlace
@onready var button_remove = $UI/ButtonRemove
@onready var button_cancel = $UI/Abort
@onready var plant_selector = $UI/PlantSelector
@onready var button_plant1 = $UI/PlantSelector/ButtonPlant1
@onready var button_plant2 = $UI/PlantSelector/ButtonPlant2
@onready var overlay_tilemap = $OverlayTileMap

const GRID_WIDTH = 10
const GRID_HEIGHT = 6

var last_touch_position: Vector2 = Vector2.ZERO
var selected_plant_scene: PackedScene = null

var plant_scenes = {
	"plant1": preload("res://Scene/Piante/plant.tscn"),
	"plant2": preload("res://Scene/Piante/plant_2.tscn")
}

var plants = {}

enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE

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
	
	if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
		var tile_size = tilemap.tile_set.tile_size
		var tile_top_left = tilemap.map_to_local(cell)
		var tile_center = tile_top_left + tile_size * 0.5
		var global_pos = tilemap.to_global(tile_center)
		
		# Posiziona l'highlight centrato sulla cella
		highlight.position = highlight.get_parent().to_local(global_pos - tile_size * 0.5)
		highlight.visible = true

		match current_mode:
			Mode.PLACE:
				highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)
			Mode.REMOVE:
				highlight.modulate = Color(1.0, 0.4, 0.4, 0.6)
	else:
		highlight.visible = false


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
					plant_instance.global_position = tilemap.to_global(tile_center)  # Posiziona la pianta al centro
					add_child(plant_instance)
					plants[cell_key] = plant_instance
					print("Planted at cell: ", cell_key)
				else:
					print("Cell already occupied or no plant selected: ", cell_key)

			Mode.REMOVE:
				if plants.has(cell_key):
					plants[cell_key].queue_free()
					plants.erase(cell_key)
					print("Removed plant at cell: ", cell_key)
				else:
					print("No plant to remove at cell: ", cell_key)


func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position


func _on_button_place_pressed() -> void:
	current_mode = Mode.NONE
	plant_selector.visible = true
	selected_plant_scene = null


func _on_button_remove_pressed() -> void:
	current_mode = Mode.REMOVE


func _on_abort_pressed() -> void:
	current_mode = Mode.NONE
	plant_selector.visible = false


func _on_button_plant_1_pressed() -> void:
	selected_plant_scene = plant_scenes["plant1"]
	current_mode = Mode.PLACE
	plant_selector.visible = false

	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var cell = Vector2i(x, y)
			if plants.has(cell):
				overlay_tilemap.set_cell(0, cell, -1)


func _on_button_plant_2_pressed() -> void:
	selected_plant_scene = plant_scenes["plant2"]
	current_mode = Mode.PLACE
	plant_selector.visible = false

	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var cell = Vector2i(x, y)
			if plants.has(cell):
				overlay_tilemap.set_cell(0, cell, -1)
