extends Control

signal kill_all
signal select_turret(turret_key)
signal remove_mode
signal retry
signal exit

# Riferimenti a nodi dell'interfaccia impostati dall'editor
@export var pause_button: TextureButton
@export var pause_menu : Panel
@export var game_over_ui : Control
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var mute_button: Button
@onready var button_remove = $ButtonRemove
@onready var button_kill_all = $ButtonKillAll
var current_level
var is_wave_active = false


#sincronizzo gli slider nel menu di pausa con
#il livello audio attuale 
func _sync_sliders_with_audio():
	music_slider.value = AudioManager.music_volume *100
	sfx_slider.value = AudioManager.sfx_volume * 100

func set_current_level(level):
	current_level = level

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
	_sync_sliders_with_audio()


# Riprende il gioco dopo la pausa
func _on_resume_button_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().paused = false
	pause_menu.visible = false
	pause_button.visible = true

# Torna al menu principale dalla schermata di vittoria
func _on_menu_button_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

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
	emit_signal("retry")
	get_tree().paused = false
	get_tree().change_scene_to_file(current_level)
	

# Esce al menu principale dalla schermata di game over
func _on_exit_button_pressed():
	emit_signal("exit")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

#da schermata di vittoria
func _on_select_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value/100.0)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value/100.0)


func _on_mute_button_pressed() -> void:
	AudioManager.toggle_music_mute()
	if AudioManager.is_music_muted:
		mute_button.text = "RIATTIVA AUDIO"
	else:
		mute_button.text = "DISATTIVA AUDIO"
