extends Node

signal turret_placed(cell_key)
signal turret_removed(cell_key, turret_instance)

@export var tilemap: TileMap
@export var highlight: ColorRect
var dic = {}

var selected_turret_scene: PackedScene = null
enum Mode { NONE, PLACE, REMOVE }
var current_mode = Mode.NONE
var last_touch_position: Vector2 = Vector2.ZERO

# Precarico torrette
var turret_scenes = {
	"turret1": preload("res://Scenes/Towers/delivery_drone.tscn"),
	"turret2": preload("res://Scenes/Towers/bolt_shooter.tscn"),
	"turret3": preload("res://Scenes/Towers/jammer_cannon.tscn"),
	"turret4": preload("res://Scenes/Plants/plant_4.tscn")
}

func _ready():
	for x in GameConstants.COLUMN:
		for y in GameConstants.ROW:
			var key = str(Vector2i(x,y))
			dic[key] = {
				"Type": "Grass",
				"Instance": null,
				"Position": Vector2i(x,y)
			}
			# disegna terreno su layer 0 del tilemap
			tilemap.set_cell(0, Vector2i(x,y), 1, Vector2i(0,0))


# --- MODALITÀ ---
func select_turret(key: String):
	var point_manager = $"/root/Main/PointManager"
	if point_manager.can_select_turret(key):
		selected_turret_scene = turret_scenes[key]
		current_mode = Mode.PLACE
		highlight.visible = true
	else:
		print("Non hai abbastanza punti!")

func remove_mode():
	current_mode = Mode.REMOVE
	highlight.visible = true

func clear_mode():
	current_mode = Mode.NONE
	highlight.visible = false


# --- VISIVO ---
func _process(_delta):
	$"/root/Main/UI/ButtonRemove".visible = has_any_turret()

	if current_mode == Mode.NONE:
		highlight.visible = false
		return

	var pointer_pos = get_pointer_position()
	if pointer_pos == null:
		highlight.visible = false
		return

	var cell = tilemap.local_to_map(tilemap.to_local(pointer_pos))
	var key = str(cell)

	if dic.has(key):
		var tile_size = tilemap.tile_set.tile_size
		var tile_center = tilemap.map_to_local(cell) + tile_size * 0.5
		highlight.position = highlight.get_parent().to_local(tilemap.to_global(tile_center) - tile_size * 0.5)
		highlight.visible = true

		if current_mode == Mode.PLACE:
			highlight.modulate = Color(0.4, 1.0, 0.4, 0.6)
		else:
			highlight.modulate = Color(1.0, 0.4, 0.4, 0.6)
	else:
		highlight.visible = false


# --- INPUT ---
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
		var cell = tilemap.local_to_map(tilemap.to_local(pointer_pos))
		var key = str(cell)

		if current_mode == Mode.PLACE:
			place_turret(key)
		elif current_mode == Mode.REMOVE:
			remove_turret(key)


# --- PIAZZAMENTO ---
func place_turret(key: String):
	if dic.has(key) and dic[key]["Instance"] == null and selected_turret_scene != null:
		var cell = dic[key]["Position"]
		var turret_instance = selected_turret_scene.instantiate()

		var tile_size = tilemap.tile_set.tile_size
		var tile_center = tilemap.map_to_local(cell) + tile_size * 0.5
		turret_instance.global_position = tilemap.to_global(tile_center)

		if turret_instance.has_method("set_riga"):
			turret_instance.set_riga(cell.y)

		add_child(turret_instance)
		dic[key]["Type"] = "Turret"
		dic[key]["Instance"] = turret_instance

		emit_signal("turret_placed", key)
		clear_mode()


# --- RIMOZIONE ---
func remove_turret(key: String):
	if dic.has(key) and dic[key]["Instance"] != null:
		var turret_instance = dic[key]["Instance"]
		emit_signal("turret_removed", key, turret_instance)
		turret_instance.queue_free()
		dic[key]["Type"] = "Grass"
		dic[key]["Instance"] = null
		clear_mode()


# --- UTILS ---
func has_any_turret() -> bool:
	for c in dic.values():
		if c["Instance"] != null:
			return true
	return false

func get_pointer_position() -> Vector2:
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		return get_viewport().get_mouse_position()
	return last_touch_position
