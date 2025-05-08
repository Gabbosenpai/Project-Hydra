extends Panel

@onready var tower = preload("res://Scenes/Turrets/turret_a.tscn")

func _on_gui_input(event: InputEvent):
	var tempTower = tower.instantiate()
	if event is InputEventMouseButton and event.button_mask == 1:
		#Left Click Down
		add_child(tempTower)
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED
	elif  event is InputEventMouseMotion and event.button_mask == 1:
		#Left Click Drag Down
		if get_child_count() > 1:
			get_child(1).global_position = event.global_position
	elif event is InputEventMouseButton and event.button_mask == 0:
		if get_child_count() > 1:
			get_child(1).queue_free()
		var map = get_tree().get_root().get_node("TestScene")
		map.add_child(tempTower)
		tempTower.global_position = event.global_position
	else:
			if get_child_count() > 1:
				get_child(1).queue_free()
