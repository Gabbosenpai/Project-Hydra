extends Control

signal kill_all
signal select_turret(turret_key)
signal remove_mode

# Riferimenti a nodi dell'interfaccia impostati dall'editor
@export var pause_button: TextureButton
@export var pause_menu : Panel
@export var game_over_ui : Control

@onready var button_remove = $ButtonRemove
@onready var button_kill_all = $ButtonKillAll

var is_wave_active = false

# Attiva la modalità rimozione piante
func _on_button_remove_pressed():
	emit_signal("remove_mode")

# Selezione rapida di una pianta specifica in base al tasto premuto
func _on_button_turret_1_pressed():
	emit_signal("select_turret", "turret1")

func _on_button_turret_2_pressed():
	emit_signal("select_turret", "turret2")

func _on_button_turret_3_pressed():
	emit_signal("select_turret", "turret3")

func _on_button_turret_4_pressed():
	emit_signal("select_turret", "turret4")

# Uccide istantaneamente tutti i nemici in scena
func _on_button_kill_all_pressed():
	emit_signal("kill_all")

# Mostra il menu di pausa e ferma il gioco
func _on_pause_button_pressed():
	get_tree().paused = true
	pause_menu.visible = true
	pause_button.visible = false

# Riprende il gioco dopo la pausa
func _on_resume_button_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	pause_button.visible = true

# Torna al menu principale
func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

# Mostra la schermata di game over e nasconde i pulsanti di gioco
func show_game_over():
	is_wave_active = false
	game_over_ui.visible = true
	get_tree().paused = true  # Metti in pausa il gioco
	AudioManager.play_game_over_music()
	button_remove.visible = false
	button_kill_all.visible = false

# Ricarica il livello 1 per riprovare
func _on_retry_button_pressed():
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://Scenes/Lvl1.tscn")
	

# Esce al menu principale dalla schermata di game over
func _on_exit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_select_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")
