extends CanvasLayer

@onready var final_score_label = $FinalScoreLabel
@onready var retry_button = $VBoxContainer/RetryButton
@onready var menu_button = $VBoxContainer/MenuButton

func _ready():
	final_score_label.text = "PUNTEGGIO FINALE: %d" % Globals.score
	
func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")  


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/menu.tscn") 
