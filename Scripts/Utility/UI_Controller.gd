extends Control

signal kill_all
signal select_turret(turret_key)
signal remove_mode
signal retry
signal exit

const TURRET_UNLOCKS = {
	"turret1": 1, # Delivery Drone (Sempre)
	"turret2": 1, # Bolt Shooter (Sempre)
	"turret3": 2, # Jammer Cannon (Livello 2+)
	"turret4": 3, # HKCM (Livello 3+)
	"turret5": 4, # Spaghetti (Livello 4+)
	"turret6": 5  # Toilet (Livello 5)
}
# Riferimenti a nodi dell'interfaccia impostati dall'editor
@export var pause_button: TextureButton
@export var pause_menu: Panel
@export var game_over_ui: Control
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var mute_music_button: Button
@export var mute_sfx_button: Button
@onready var button_remove = $ButtonRemove
@onready var button_kill_all = $ButtonKillAll
@export var music_on_sprite: Sprite2D
@export var music_off_sprite: Sprite2D
@export var sfx_on_sprite: Sprite2D
@export var sfx_off_sprite: Sprite2D

var current_level
var is_wave_active = false

# Sincronizzo gli slider nel menu di pausa con il livello audio attuale 
func _sync_sliders_with_audio():
	music_slider.value = AudioManager.music_volume *100
	sfx_slider.value = AudioManager.sfx_volume * 100


func set_current_level(level):
	current_level = level
	call_deferred("update_available_turrets")

func update_available_turrets():
	if not current_level:
		return

	# 1. Estrazione numero livello
	var level_number = 1
	var regex = RegEx.new()
	regex.compile("Lvl(\\d+)") 
	var result = regex.search(current_level)
	if result:
		level_number = result.get_string(1).to_int()

	print("Configurazione UI per Livello: ", level_number)

	# 2. Cerchiamo i bottoni. 
	# Se ButtonTurret1 è dentro un Container (es. HBoxContainer), 
	# usiamo find_child per trovarlo ovunque nella gerarchia della UI.
	for i in range(1, 7):
		var turret_key = "turret" + str(i)
		var button_name = "ButtonTurret" + str(i)
		
		# find_child cerca ricorsivamente in tutti i figli della UI
		var button_node = find_child(button_name, true, false)
		
		if button_node:
			var unlock_at = TURRET_UNLOCKS.get(turret_key, 1)
			var is_unlocked = (level_number >= unlock_at)
			
			# Nasconde completamente il bottone se bloccato
			button_node.visible = is_unlocked
			
			# Opzionale: se vuoi che occupino comunque spazio ma siano neri/disabilitati
			# button_node.disabled = !is_unlocked 
			
			print("Torretta ", i, " visibile: ", is_unlocked)
		else:
			push_warning("Attenzione: Non trovo il nodo chiamato: " + button_name)

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


func _on_button_turret_5_pressed() -> void:
	emit_signal("select_turret", "turret5")

func _on_button_turret_6_pressed() -> void:
	emit_signal("select_turret", "turret6")


# Uccide istantaneamente tutti i nemici in scena
func _on_button_kill_all_pressed():
	emit_signal("kill_all")


# Mostra il menu di pausa, ferma il menu di gioco e sincronizza le icone mute/unmute
func _on_pause_button_pressed():
	get_tree().paused = true
	pause_menu.visible = true
	pause_button.visible = false
	_sync_sliders_with_audio()
	_refresh_audio_ui()

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


# Da schermata di vittoria
func _on_select_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value/100.0)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value/100.0)


func _on_mute_music_button_pressed() -> void:
	AudioManager.toggle_music_mute()
	_refresh_audio_ui()


func _on_mute_sfx_button_pressed() -> void:
	AudioManager.toggle_sfx_mute()
	_refresh_audio_ui()

#per tenere sincronizzate le icone audio
func _refresh_audio_ui():
	music_on_sprite.visible = !AudioManager.is_music_muted
	music_off_sprite.visible = AudioManager.is_music_muted

	sfx_on_sprite.visible = !AudioManager.is_sfx_muted
	sfx_off_sprite.visible = AudioManager.is_sfx_muted
