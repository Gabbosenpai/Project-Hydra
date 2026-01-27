extends Node
@onready var level = get_parent()
@onready var popup = $"../UI/TutorialPopup"
@onready var spawner = $"../EnemySpawner"
@onready var anim_player = $"../UI/TutorialPopup/AnimationPlayer"
@onready var tutorialUI = $"../UI/TutorialPopup/TutorialUI"
@onready var label = $"../UI/TutorialPopup/Label"
@onready var buttonYes = $"../UI/TutorialPopup/BtnSi"
@onready var buttonNo = $"../UI/TutorialPopup/BtnNo"
@onready var tutorial1 = $"../UI/TutorialPopup/TutorialUI/Part1"
@onready var tutorial2 = $"../UI/TutorialPopup/TutorialUI/PartScrap"
@onready var tutorial3 = $"../UI/TutorialPopup/TutorialUI/Part2"
@onready var tutorial4 = $"../UI/TutorialPopup/TutorialUI/Part3"
@onready var tutorial5 = $"../UI/TutorialPopup/TutorialUI/PosTurret1"
@onready var tutorial6 = $"../UI/TutorialPopup/TutorialUI/PosTurret2"

var tutorialPart = 0

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
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	anim_player.play("chiusura")
	await anim_player.animation_finished
	popup.visible = false
	get_tree().paused = false # Riparte il gioco normalmente

func _on_btn_si_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	label.visible = false
	buttonYes.visible = false
	buttonNo.visible = false
	tutorialUI.visible = true
	tutorialPart = 1
	#avvia_sequenza_tutorial()

#Vedere come implementare questa parte
func avvia_sequenza_tutorial():
	# Qui piloti i tuoi manager già esistenti
	spawner.initial_delay_timer.stop() # Blocca i 15 secondi di attesa
	print("Tutorial avviato: segui le istruzioni...")
	# Esempio: forza la selezione di una torretta
	level.ui_controller.emit_signal("select_turret", "turret1")


func _on_button_continue_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	match tutorialPart:
		1:
			tutorial1.visible = false
			tutorial2.visible = true
			tutorialPart = 2
		2:
			tutorial2.visible = false
			tutorial3.visible = true
			tutorialPart = 3
		3:
			tutorial3.visible = false
			tutorial4.visible = true
			tutorialPart = 4
		4:
			tutorial4.visible = false
			tutorial5.visible = true
			tutorialPart = 5
		5:
			tutorial5.visible = false
			tutorial6.visible = true
			tutorialPart = 6
		6:
			# Reset e chiusura
			tutorialPart = 0 
			_on_button_skip_pressed()

#Per Test da Sistemare
func _on_button_skip_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	anim_player.play("chiusura")
	await anim_player.animation_finished
	popup.visible = false
	get_tree().paused = false
