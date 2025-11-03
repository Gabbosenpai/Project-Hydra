extends Control

@onready var desc = $MonsterDescription

# Dizionario dei testi per ogni mostro
var monster_texts = {
	"bolt_shooter": "Questo è il Bolt Shooter!",
	"weed_eater": "Questo è il Weed Eater!",
	"jammer": "Questo è il Jammer!"
}

func ready():
	desc.visible = false

# Mostra la descrizione del mostro
func show_description(monster_name: String):
	if monster_name in monster_texts:
		desc.text = monster_texts[monster_name]
		desc.visible = true
		#desc.position = get_viewport_rect().size / 2 - desc.rect_size / 2

# Nasconde la descrizione
func hide_description():
	desc.visible = false

func _on_back_to_menu_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

# Esempio di pulsante
func _on_bolt_shooter_pressed() -> void:
	show_description("bolt_shooter")

# Nasconde al click
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_description()


func _on_weed_eater_pressed() -> void:
	show_description("weed_eater")




func _on_weed_eater_2_pressed() -> void:
	show_description("jammer")
