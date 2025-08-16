extends Area2D

@export var scrap_value: int = 50
@export var point_manager: Node # viene settato da chi spawna il rottame

func _ready():
	# Abilita la ricezione di eventi input
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	print("Scrap ready at:", global_position, " z:", z_index)


func _on_input_event(viewport, event, shape_idx):
	# Click con mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		collect_scrap()

	# Tap su touch screen
	if event is InputEventScreenTouch and event.pressed:
		collect_scrap()

func collect_scrap():
	if point_manager:
		point_manager.current_points += scrap_value
		point_manager.update_points_label()
	queue_free()
