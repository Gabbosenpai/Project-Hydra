extends Node
@onready var level = get_parent()
@onready var popup = $"../UI/TutorialPopup"
@onready var spawner = $"../EnemySpawner"
@onready var anim_player = $"../UI/TutorialPopup/AnimationPlayer"

func _ready():
	# Controlliamo se il livello è già stato sbloccato/completato in passato
	var max_level = SaveManager.get_max_unlocked_level()
	
	if max_level <= 1: # Se è la prima volta che entriamo nel gioco
		mostra_domanda_tutorial()
	else:
		# Gioca normalmente
		pass

func mostra_domanda_tutorial():
	popup.visible = true
	get_tree().paused = true # Mette in pausa tutto il gioco
	anim_player.play("entrata")

func _on_btn_no_pressed():
	anim_player.play("chiusura")
	await anim_player.animation_finished
	popup.visible = false
	get_tree().paused = false # Riparte il gioco normalmente

func _on_btn_si_pressed():
	anim_player.play("chiusura")
	await anim_player.animation_finished
	popup.visible = false
	get_tree().paused = false
	anim_player.play("chiusura")
	avvia_sequenza_tutorial()

#Vedere come implementare questa parte
func avvia_sequenza_tutorial():
	# Qui piloti i tuoi manager già esistenti
	spawner.initial_delay_timer.stop() # Blocca i 15 secondi di attesa
	print("Tutorial avviato: segui le istruzioni...")
	# Esempio: forza la selezione di una torretta
	level.ui_controller.emit_signal("select_turret", "turret1")
