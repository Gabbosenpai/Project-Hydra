extends Panel

@onready var tower = preload("res://Scenes/tower_a_panel.tscn")

func _on_gui_input(event: InputEvent) -> void:
	var tempTower = tower.instantiate()
	if event is InputEventMouseButton and event.button_mask == 1:
		add_child(tempTower)
		tempTower.global_position = event.global_position
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED
