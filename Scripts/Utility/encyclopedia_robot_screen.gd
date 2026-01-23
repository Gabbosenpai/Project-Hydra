extends Control

var robot_textures = {
	"weed_eater": preload("res://Assets/Sprites/Robots/Weed Eater 9000/Weed Eater 9000.png"),
	"mecha_freezer": preload("res://Assets/Sprites/Robots/Mecha Freezer/Mecha Freezer.png"),
	"fire_hydrant": preload("res://Assets/Sprites/Robots/Fire Hydrant/Firehydrant.png"),
	"romba": preload("res://Assets/Sprites/Robots/Romba/Romba.png"),
	"cassa_schierata": preload("res://Assets/Sprites/Robots/Cassa Schierata/Cassa Schierata.png")
}

var robot_names = {
	"weed_eater": "weed_eater_9000",
	"mecha_freezer": "mecha_freezer",
	"fire_hydrant": "fire_hydrant",
	"romba": "vacuumba", #da verificare copyright
	"cassa_schierata": "aligned_speaker"
}
#valore livello massimo per sbloccare una voce
var robot_unlock_levels = {
	"romba": 2,
	"weed_eater": 3,         
	"mecha_freezer": 4,
	"fire_hydrant": 5,
	"cassa_schierata": 6
}
var robot_texts = {
	"weed_eater": "weed_eater_9000_desc",
	"mecha_freezer": "mecha_freezer_desc",
	"cassa_schierata": "aligned_speaker_desc",
	"romba": "vacuumba_desc",
	"fire_hydrant": "fire_hydrant_desc"
}
var clicked: bool

@onready var desc_panel = $RiquadroRobot/RobotDescriptionPanel
@onready var desc_label = $RiquadroRobot/RobotDescriptionPanel/RobotDescription
@onready var name_label = $RiquadroRobot/RobotDescriptionPanel/RobotName
#corrispondenza nome->nodo
@onready var robot_buttons = {
	"weed_eater": $WeedEater,         
	"mecha_freezer": $MechaFreezer,
	"fire_hydrant": $FireHydrant,
	"romba": $Romba,
	"cassa_schierata": $CassaSchierata
}

func _ready():
	clicked = false
	desc_label.text = tr("no_robot_selected_text")
	name_label.text = ""
	update_buttons()

# Mostra la descrizione del robot
func show_description(robot_name: String):
	if robot_name in robot_texts:
		name_label.text = tr(robot_names[robot_name])
		desc_label.text = tr(robot_texts[robot_name])
		desc_panel.modulate.a = 0.0
		desc_panel.visible = true

		# Aspetta un frame per calcolare bene la dimensione
		await get_tree().process_frame

		# Centra il pannello sullo schermo
		#desc_panel.position = (get_viewport_rect().size - desc_panel.size) / 2

		# Effetto fade-in morbido
		var tween = create_tween()
		tween.tween_property(desc_panel, "modulate:a", 1.0, 0.3)


# Deprecated, not needed anymore
# Nasconde la descrizione
#func hide_description():
	#desc_panel.visible = false


# Nasconde gli altri bottoni e mette in evidenza quello premuto
func show_entry(towerName: String):
	if not clicked:
		AudioManager.play_sfx(AudioManager.button_click_sfx)
		show_description(towerName)
		for button in robot_buttons:
			if button != towerName:
				robot_buttons[button].hide()
			else:
				#robot_buttons[button].texture_normal = null
				#robot_buttons[button].texture_pressed = null
				var tween = create_tween()
				tween.set_parallel()
				tween.tween_property(robot_buttons[button], "scale", Vector2(2, 2), 0.35)
				tween.tween_property(robot_buttons[button], "position", Vector2(210,227), 0.35)
		clicked = true
	else:
		AudioManager.play_sfx(AudioManager.button_click_sfx)
		get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaRobotScreen.tscn")


# Per aggiornare dinamicamente l'enciclopedia
func update_buttons():
	var max_level = SaveManager.get_max_level_all_slots()
	
	for robot_name in robot_unlock_levels.keys():
		var button = robot_buttons[robot_name]        
		var texture = button.get_node("TextureRect")  
		
		if max_level >= robot_unlock_levels[robot_name]:
			button.disabled = false
			texture.visible = true
		else:
			button.disabled = true
			texture.modulate = Color.BLACK


# Deprecated, not needed anymore
# Per nascondere la descrizione cliccando 
# al di fuori delle immagini dei robot
#func _unhandled_input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#hide_description()


func _on_back_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	if clicked:
		get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaRobotScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaFirstScreen.tscn")


func _on_weed_eater_pressed() -> void:
	show_entry("weed_eater")


func _on_mecha_freezer_pressed() -> void:
	show_entry("mecha_freezer")


func _on_cassa_schierata_pressed() -> void:
	show_entry("cassa_schierata")


func _on_fire_hydrant_pressed() -> void:
	show_entry("fire_hydrant")


func _on_romba_pressed() -> void:
	show_entry("romba")
