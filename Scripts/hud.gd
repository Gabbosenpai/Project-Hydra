extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Message.hide()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	$Message.show()
	$MessageTimer.start()
	# Wait until the MessageTimer has counted down
	await $MessageTimer.timeout


func _on_message_timer_timeout() -> void:
	get_tree().quit()
