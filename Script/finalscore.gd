extends CanvasLayer

@onready var final_score_label = $FinalScoreLabel
@onready var retry_button = $VBoxContainer/RetryButton
@onready var menu_button = $VBoxContainer/MenuButton

func _ready():
	final_score_label.text = "PUNTEGGIO FINALE: %d" % Globals.score

	# Connette i segnali dei pulsanti alle funzioni
	retry_button.pressed.connect(on_retry_pressed)
	menu_button.pressed.connect(on_menu_pressed)

func on_retry_pressed():
	get_tree().change_scene_to_file("res://Scene/main.tscn")  

func on_menu_pressed():
	get_tree().change_scene_to_file("res://Scene/menu.tscn")  
 
