extends Area2D

@export var scrap_value: int = 50
@export var lifetime: float = 10.0   # tempo di vita in secondi
@export var hop_distance: Vector2 = Vector2(30, 40) # spostamento in basso a destra

@export var point_manager: Node # viene settato da chi spawna il rottame

@onready var lifetime_timer := Timer.new()

func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	print("Scrap ready at:", global_position, " z:", z_index)

	# Timer per far scomparire il rottame
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = lifetime
	add_child(lifetime_timer)
	lifetime_timer.start()
	lifetime_timer.timeout.connect(_on_lifetime_timeout)

	# Animazione spawn / hop
	play_spawn_animation()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		collect_scrap()
	if event is InputEventScreenTouch and event.pressed:
		collect_scrap()

func collect_scrap():
	if point_manager:
		point_manager.current_points += scrap_value
		point_manager.update_points_label()
	queue_free()

func _on_lifetime_timeout():
	queue_free()

func play_spawn_animation():
	scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	# Pop iniziale
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Poi hop verso in basso a destra con piccolo rimbalzo
	var target_pos = position + hop_distance
	tween.tween_property(self, "position", target_pos, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", target_pos + Vector2(0, -10), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
