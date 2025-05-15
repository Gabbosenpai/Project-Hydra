extends Node2D
#due tipi di cannoni
@onready var cannon_scene = preload("res://Scene/cannon.tscn")
@onready var cannon_fast_scene = preload("res://Scene/cannon_fast.tscn")
@onready var score_label = $CanvasLayer/ScoreLabel   
@onready var ost_player = $OST 
var score = 0
#non sono in modalità piazzamento inizialmente
var placing_cannon = false

#non ho selezionato nessun tipo di cannone inizialmente
var current_cannon_scene = null



func _ready():
	ost_player.play()
	$ScoreTimer.start()  # Avvia il timer per il punteggio

func _on_score_timer_timeout() -> void:
	
	score += 1
	Globals.score = score   
	score_label.text = "Score: %d" % score

func _unhandled_input(event):
	if placing_cannon and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cannon = current_cannon_scene.instantiate()
		cannon.global_position = get_global_mouse_position()
		
		cannon.bullet_scene = preload("res://Scene/bullet.tscn")  
		add_child(cannon)
		placing_cannon = false


func _on_place_cannon_button_1_pressed() -> void:
	current_cannon_scene = cannon_scene
	placing_cannon = true


func _on_place_cannon_button_2_pressed() -> void:
	current_cannon_scene = cannon_fast_scene
	placing_cannon = true
