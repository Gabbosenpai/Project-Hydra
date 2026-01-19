extends Control

signal kill_all
signal select_turret(turret_key)
signal remove_mode

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
@export var mute_music_button: TextureButton
@export var mute_sfx_button: TextureButton
@export var game_over_timer_value: float = 2.0

@onready var button_remove = $TurretSelector/ButtonRemove
@onready var button_kill_all = $ButtonKillAll
@onready var h_box_container: HBoxContainer = $TurretSelector/HBoxContainer
@onready var retry_lvl = $PauseMenu/GameOverUI/RetryButton
@onready var sel_lvl = $PauseMenu/GameOverUI/ExitButton
@onready var pause_label: Label = $PauseMenu/PauseLabel
@onready var resume_button: TextureButton = $PauseMenu/ResumeButton
@onready var menu_button: TextureButton = $PauseMenu/MenuButton
@onready var scrap_ui: TextureRect = $TurretSelector/ScrapUI
@onready var scrap_points: Label = $TurretSelector/ScrapPoints
@onready var game_over_timer: Timer = $PauseMenu/GameOverUI/GameOverTimer


var scrap_pos
var texture_muted_music = preload("res://Assets/Sprites/UI/Music and SFX/Music Button Off.png")
var texture_not_muted_music = preload("res://Assets/Sprites/UI/Music and SFX/Music Button On.png")
var texture_muted_sfx = preload("res://Assets/Sprites/UI/Music and SFX/Sound Button Off.png")
var texture_not_muted_sfx = preload("res://Assets/Sprites/UI/Music and SFX/Sound Button On.png")
var current_level
var is_wave_active = false
var opzioni_aperte = false
@onready var anim_player = $PauseMenu/AnimationPlayer


func _ready():
	game_over_timer.wait_time = game_over_timer_value
	scrap_pos = scrap_ui.position
	_refresh_audio_ui()
	pause_menu.position.y = -1300
	opzioni_aperte = false
	get_tree().paused = false
	retry_lvl.pressed.connect(_on_retry_button_pressed)
	sel_lvl.pressed.connect(_on_exit_button_pressed)


# Sincronizzo gli slider nel menu di pausa con il livello audio attuale 
func _sync_sliders_with_audio():
	music_slider.value = AudioManager.music_volume * 100
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
			
			# Nasconde l'icona della torretta se non sbloccata
			if !is_unlocked:
				button_node.get_child(1).visible = false
				button_node.get_child(0).modulate = Color.BLACK
				button_node.disabled = true
			
			print("Torretta ", i, " visibile: ", is_unlocked)
		else:
			push_warning("Attenzione: Non trovo il nodo chiamato: " + button_name)


func turret_placed_UI():
	for i in range(0, 6):
		var button = h_box_container.get_child(i)
		button.button_pressed = false


func turret_deleted_UI():
	button_remove.button_pressed = false


func not_enough_scrap():
	shake(scrap_ui)
	flash_red(scrap_points)


func shake(node, intensity := 8.0, duration := 0.3):
	var tween = create_tween()
	# Transizione interpolata con una funzione seno
	#tween.set_trans(Tween.TRANS_SINE)
	
	# Piccoli spostamenti casuali
	for i in range(6):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(
			node,
			"position",
			scrap_pos + offset,
			duration / 6.0
		)
	
	# Ritorno alla posizione iniziale
	tween.tween_property(node, "position", scrap_pos, duration / 6.0)


func flash_red(node):
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(node, "modulate", Color.RED, 0.08)
		tween.tween_property(node, "modulate", Color(1,1,1,1), 0.08)


func update_buttons_UI(ButtonName: String):
	for i in range(0, 6):
		var button = h_box_container.get_child(i)
		if button.name != ButtonName:
			button.button_pressed = false


func _on_button_remove_pressed():
	emit_signal("remove_mode")


func _on_button_turret_1_pressed():
	emit_signal("select_turret", "turret1")
	update_buttons_UI("ButtonTurret1")


func _on_button_turret_2_pressed():
	emit_signal("select_turret", "turret2")
	update_buttons_UI("ButtonTurret2")


func _on_button_turret_3_pressed():
	emit_signal("select_turret", "turret3")
	update_buttons_UI("ButtonTurret3")


func _on_button_turret_4_pressed():
	emit_signal("select_turret", "turret4")
	update_buttons_UI("ButtonTurret4")


func _on_button_turret_5_pressed() -> void:
	emit_signal("select_turret", "turret5")
	update_buttons_UI("ButtonTurret5")


func _on_button_turret_6_pressed() -> void:
	emit_signal("select_turret", "turret6")
	update_buttons_UI("ButtonTurret6")


# Uccide istantaneamente tutti i nemici in scena
func _on_button_kill_all_pressed():
	emit_signal("kill_all")


# Mostra il menu di pausa, ferma il menu di gioco e sincronizza le icone mute/unmute
func _on_pause_button_pressed():
	if anim_player.is_playing():
		return
	AudioManager.play_pause_click(AudioManager.button_click_sfx)
	if opzioni_aperte:
		anim_player.play("chiudiOpzioni")
		await anim_player.animation_finished
		get_tree().paused = false
		opzioni_aperte = false
	else:
		get_tree().paused = true
		pause_menu.move_to_front()
		_sync_sliders_with_audio()
		anim_player.play("apriOpzioni")
		await anim_player.animation_finished
		opzioni_aperte = true
	
	#pause_menu.visible = true
	#pause_button.visible = false
	#_refresh_audio_ui()

# Riprende il gioco dopo la pausa
func _on_resume_button_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	_on_pause_button_pressed()


# Torna al menu principale dalla schermata di vittoria
func _on_menu_button_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")


# Mostra la schermata di game over e nasconde i pulsanti di gioco
func show_game_over():
	if anim_player.is_playing():
		return
	is_wave_active = false
	mute_music_button.visible = false
	mute_sfx_button.visible = false
	pause_label.visible = false
	resume_button.visible = false
	menu_button.visible = false
	game_over_ui.visible = true
	game_over_timer.start()
	await game_over_timer.timeout
	if is_instance_valid(game_over_timer):
		game_over_timer.queue_free()
	get_tree().paused = true  # Metti in pausa il gioco
	pause_menu.move_to_front()
	_sync_sliders_with_audio()
	AudioManager.play_game_over_music()
	anim_player.play("apriOpzioni")
	await anim_player.animation_finished
	


# Ricarica il livello 1 per riprovare
func _on_retry_button_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().paused = false
	get_tree().change_scene_to_file(current_level)


# Esce al menu principale dalla schermata di game over
func _on_exit_button_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


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
	#_refresh_audio_ui()


func _on_mute_sfx_button_pressed() -> void:
	AudioManager.toggle_sfx_mute()
	#_refresh_audio_ui()

# Aggiornata UI bottoni SFX e Music, ora questa funzione cambia le texture
# normal e pressed dei bottoni in base allo stato AudioManager
func _refresh_audio_ui():
	if !AudioManager.is_music_muted:
		mute_music_button.texture_normal = texture_not_muted_music
		mute_music_button.texture_pressed = texture_muted_music
	else:
		mute_music_button.texture_normal = texture_muted_music
		mute_music_button.texture_pressed = texture_not_muted_music
	if !AudioManager.is_sfx_muted:
		mute_sfx_button.texture_normal = texture_not_muted_sfx
		mute_sfx_button.texture_pressed = texture_muted_sfx
	else:
		mute_sfx_button.texture_normal = texture_muted_sfx
		mute_sfx_button.texture_pressed = texture_not_muted_sfx
