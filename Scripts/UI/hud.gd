extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Message.hide()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	$Message.show()
	$MessageTimer.start()
	

func _on_message_timer_timeout():
	get_tree().quit()
