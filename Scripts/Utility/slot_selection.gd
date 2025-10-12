extends Control





func _on_file_1_pressed() -> void:
	SaveManager.current_slot = 1
	SaveManager.load_progress()
	#temporanemante vogliamo andare alla selezione livello
	#questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_file_2_pressed() -> void:
	SaveManager.current_slot = 2
	SaveManager.load_progress()
	#temporanemante vogliamo andare alla selezione livello
	#questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_file_3_pressed() -> void:
	SaveManager.current_slot = 3
	SaveManager.load_progress()
	#temporanemante vogliamo andare alla selezione livello
	#questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")
