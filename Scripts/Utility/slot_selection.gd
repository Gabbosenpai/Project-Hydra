extends Control

# Salviamo quale slot vogliamo cancellare
var slot_to_delete = 0  
 
@onready var file1_label: Label = $VBoxContainer/File1/Label
@onready var file2_label: Label = $VBoxContainer/File2/Label
@onready var file3_label: Label = $VBoxContainer/File3/Label
@onready var slot_1_led: TextureRect = $LedSlots/Slot1Led
@onready var slot_2_led: TextureRect = $LedSlots/Slot2Led
@onready var slot_3_led: TextureRect = $LedSlots/Slot3Led
@onready var delete_1: TextureButton = $Delete1
@onready var delete_2: TextureButton = $Delete2
@onready var delete_3: TextureButton = $Delete3


var slot_occupato = preload("res://Assets/Sprites/UI/Menu/SaveSlot Led On.png")
var slot_vuoto = preload("res://Assets/Sprites/UI/Menu/SaveSlot Led Off.png")
var delete_slot_occupato = preload("res://Assets/Sprites/UI/Menu/Small Delete Button Pressed.png")
var delete_slot_vuoto = preload("res://Assets/Sprites/UI/Menu/Small Delete Button Not Pressed.png")


func _ready():
	update_slot_texts()
	# La schermata di conferma è inizialmente non visibile
	$ConfirmPanel.visible = false


# Funzione che aggiorna dinamicamente il testo dei vari file
# Livello1 significa livello del file 1 e così per il file 2 e 3
func update_slot_texts():
	var livello1 = SaveManager.get_saved_level(1)
	var completato1 = 0
	if livello1 > 1:
		completato1 = livello1 - 1
	if completato1 > 0:
		file1_label.text = "Livello %d superato" % completato1
		slot_1_led.texture = slot_occupato
		delete_1.texture_normal = delete_slot_occupato
		delete_1.texture_pressed = delete_slot_vuoto
	else:
		file1_label.text = "Vuoto"
		slot_1_led.texture = slot_vuoto
		delete_1.texture_pressed = delete_slot_occupato
		delete_1.texture_normal = delete_slot_vuoto
	
	# Stessa cosa del file 1
	var livello2 = SaveManager.get_saved_level(2)
	var completato2 = 0
	if livello2 > 1:
		completato2 = livello2 - 1
	if completato2 > 0:
		file2_label.text = "Livello %d superato" % completato2
		slot_2_led.texture = slot_occupato
		delete_2.texture_normal = delete_slot_occupato
		delete_2.texture_pressed = delete_slot_vuoto
	else:
		file2_label.text = "Vuoto"
		slot_2_led.texture = slot_vuoto
		delete_2.texture_pressed = delete_slot_occupato
		delete_2.texture_normal = delete_slot_vuoto
	
	# Stessa cosa del file 1
	var livello3 = SaveManager.get_saved_level(3)
	var completato3 = 0
	if livello3 > 1:
		completato3 = livello3 - 1
	if completato3 > 0:
		file3_label.text = "Livello %d superato" % completato3
		slot_3_led.texture = slot_occupato
		delete_3.texture_normal = delete_slot_occupato
		delete_3.texture_pressed = delete_slot_vuoto
	else:
		file3_label.text = "Vuoto"
		slot_3_led.texture = slot_vuoto
		delete_3.texture_pressed = delete_slot_occupato
		delete_3.texture_normal = delete_slot_vuoto


func _on_file_1_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = 1
	SaveManager.load_progress()
	# Temporanemante vogliamo andare alla selezione livello,
	# questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_file_2_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = 2
	SaveManager.load_progress()
	# Temporanemante vogliamo andare alla selezione livello,
	# questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_file_3_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = 3
	SaveManager.load_progress()
	# Temporanemante vogliamo andare alla selezione livello,
	# questa parte andrà successivamente tolta
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


# Schemrata conferma cancellazione salvataggio
func show_confirm_panel():
	$ConfirmPanel.visible = true
	$ConfirmPanel/Text.text = "Vuoi davvero cancellare il salvataggio %d?" % slot_to_delete


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


# Gestione pulsante conferma cancellazione salvataggio
func _on_yes_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	SaveManager.current_slot = slot_to_delete
	SaveManager.reset_progress()
	update_slot_texts()
	$ConfirmPanel.visible = false


# Gestione pulsante annulla cancellazione salvataggio
func _on_no_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	$ConfirmPanel.visible = false


func _on_back_to_menu_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
