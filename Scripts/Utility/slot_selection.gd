extends Control


var slot_to_delete = 0  # salviamo quale slot vogliamo cancellare

func _ready():
	update_slot_texts()
	$ConfirmPanel.visible = false

func update_slot_texts():
	var livello1 = SaveManager.get_saved_level(1)
	var completato1 = 0
	if livello1 > 1:
		completato1 = livello1 - 1
	if completato1 > 0:
		$VBoxContainer/File1.text = "File 1 - Livello %d completato" % completato1
	else:
		$VBoxContainer/File1.text = "File 1 - Vuoto"

	var livello2 = SaveManager.get_saved_level(2)
	var completato2 = 0
	if livello2 > 1:
		completato2 = livello2 - 1
	if completato2 > 0:
		$VBoxContainer/File2.text = "File 2 - Livello %d completato" % completato2
	else:
		$VBoxContainer/File2.text = "File 2 - Vuoto"

	var livello3 = SaveManager.get_saved_level(3)
	var completato3 = 0
	if livello3 > 1:
		completato3 = livello3 - 1
	if completato3 > 0:
		$VBoxContainer/File3.text = "File 3 - Livello %d completato" % completato3
	else:
		$VBoxContainer/File3.text = "File 3 - Vuoto"


func _on_file_1_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = 1
	SaveManager.load_progress()
	#temporanemante vogliamo andare alla selezione livello
	#questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_file_2_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = 2
	SaveManager.load_progress()
	#temporanemante vogliamo andare alla selezione livello
	#questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_file_3_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = 3
	SaveManager.load_progress()
	#temporanemante vogliamo andare alla selezione livello
	#questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")

func show_confirm_panel():
	$ConfirmPanel.visible = true
	$ConfirmPanel/Text.text = "Vuoi davvero cancellare il salvataggio nello slot %d?" % slot_to_delete



func _on_delete_1_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	slot_to_delete = 1
	show_confirm_panel()

func _on_delete_2_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	slot_to_delete = 2
	show_confirm_panel()


func _on_delete_3_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	slot_to_delete = 3
	show_confirm_panel()


func _on_yes_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = slot_to_delete
	SaveManager.reset_progress()
	update_slot_texts()
	$ConfirmPanel.visible = false


func _on_no_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	$ConfirmPanel.visible = false
