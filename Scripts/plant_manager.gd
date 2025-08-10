extends Node

signal plant_placed(cell_key)
signal plant_removed(cell_key)

@export var tilemap: TileMap
@export var highlight: ColorRect

const GRID_WIDTH = 15
const GRID_HEIGHT = 8

var plants = {}
var selected_plant_scene: PackedScene = null
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE
var last_touch_position: Vector2 = Vector2.ZERO

var plant_scenes = {
	"plant1": preload("res://Scenes/Base Tower/base_tower.tscn"),
	"plant2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"plant3": preload("res://Scenes/Plants/plant_3.tscn"),
	"plant4": preload("res://Scenes/Plants/plant_4.tscn")
}

func select_plant(key: String):
	selected_plant_scene = plant_scenes[key]
	current_mode = Mode.PLACE
	highlight.visible = true

func remove_mode():
	current_mode = Mode.REMOVE

func clear_mode():
	current_mode = Mode.NONE
	highlight.visible = false

func _process(_delta):
	$"/root/Main/UI/ButtonRemove".visible = not plants.is_empty()
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
		highlight.position = highlight.get_parent().to_local(global_pos - tile_size * 0.5)
		highlight.visible = true
		if current_mode == Mode.PLACE:
			highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)
		else:
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
		if current_mode == Mode.PLACE:
			place_plant(cell_key)
		elif current_mode == Mode.REMOVE:
			remove_plant(cell_key)

func place_plant(cell_key: Vector2i):
	if not plants.has(cell_key) and selected_plant_scene != null:
		var plant_instance = selected_plant_scene.instantiate()
		var tile_size = tilemap.tile_set.tile_size
		var tile_center = tilemap.map_to_local(cell_key) + tile_size * 0.5
		plant_instance.global_position = tilemap.to_global(tile_center)
		if plant_instance.has_method("set_riga"):
			plant_instance.set_riga(cell_key.y)
		add_child(plant_instance)
		plants[cell_key] = plant_instance
		emit_signal("plant_placed", cell_key)
		clear_mode()

func remove_plant(cell_key: Vector2i):
	if plants.has(cell_key):
		plants[cell_key].queue_free()
		plants.erase(cell_key)
		emit_signal("plant_removed", cell_key)
		clear_mode()

func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position
