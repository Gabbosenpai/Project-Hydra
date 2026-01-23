extends Control

var tower_textures = {
	"bolt_shooter": preload("res://Assets/Sprites/Towers/Bolt Shooter/Idle/Bolt Shooter-Idle_0001.png"),
	"delivery_drone": preload("res://Assets/Sprites/Towers/Delivery Drone/Delivery Drone Fly-00.png"),
	"hkcm": preload("res://Assets/Sprites/Towers/HKCM/Hot Kawaii Coffee Machine.png"),
	"jammer": preload("res://Assets/Sprites/Towers/Jammer Cannon/Jammer Cannon.png"),
	"spaghetti_cable": preload("res://Assets/Sprites/Towers/Spaghetti Cable/Spaghetti Cable.png"),
	"toilet_silo": preload("res://Assets/Sprites/Towers/Toilet Silo/Sturamissile Launcher.png"),
}
# Valore livello massimo per sbloccare una voce
var tower_unlock_levels = {
	"bolt_shooter": 2,         
	"delivery_drone": 2,
	"hkcm": 4,
	"jammer": 3,
	"spaghetti_cable": 5,
	"toilet_silo": 6
}
var tower_names = {
	"bolt_shooter": "bolt_shooter",
	"delivery_drone": "delivery_drone",
	"hkcm": "hkcm",
	"jammer": "jammer_cannon",
	"spaghetti_cable": "spaghetti_cable",
	"toilet_silo": "toilet_silo"
}
var tower_texts = {
	"bolt_shooter": "bolt_shooter_desc",	
	"delivery_drone": "delivery_drone_desc",
	"hkcm": "hkcm_desc",
	"jammer": "jammer_cannon_desc",
	"spaghetti_cable": "spaghetti_cable_desc",
	"toilet_silo":"toilet_silo_desc"
}
var clicked: bool

@onready var desc_panel = $RiquadroTorrette/TowerDescriptionPanel
@onready var desc_label = $RiquadroTorrette/TowerDescriptionPanel/TowerDescription
@onready var name_label = $RiquadroTorrette/TowerDescriptionPanel/TowerName
# Corrispondenza nome->nodo
@onready var tower_buttons = {
	"bolt_shooter": $BoltShooter,
	"delivery_drone": $DeliveryDrone,
	"hkcm": $HKCM,
	"jammer": $Jammer,
	"spaghetti_cable": $SpaghettiCable,
	"toilet_silo": $ToiletSilo
}


func _ready():
	clicked = false
	desc_label.text = tr("no_tower_selected_text")
	name_label.text = ""
	update_buttons()


 # Mostra la descrizione della torretta
func show_description(tower_name: String):
	if tower_name in tower_texts:
		name_label.text = tr(tower_names[tower_name])
		desc_label.text = tr(tower_texts[tower_name])
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
		show_description(towerName)
		for button in tower_buttons:
			if button != towerName:
				tower_buttons[button].hide()
			else:
				#tower_buttons[button].texture_normal = null
				#tower_buttons[button].texture_pressed = null
				var tween = create_tween()
				tween.set_parallel()
				tween.tween_property(tower_buttons[button], "scale", Vector2(2, 2), 0.35)
				tween.tween_property(tower_buttons[button], "position", Vector2(210,227), 0.35)
		clicked = true
	else:
		get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaTowerScreen.tscn")


# Per aggiornare dinamicamente l'enciclopedia
func update_buttons():
	var max_level = SaveManager.get_max_level_all_slots()
	
	for tower_name in tower_unlock_levels.keys():
		var button = tower_buttons[tower_name]        
		var texture = button.get_node("TextureRect")  

		if max_level >= tower_unlock_levels[tower_name]:
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
		get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaTowerScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaFirstScreen.tscn")


func _on_bolt_shooter_pressed() -> void:
	show_entry("bolt_shooter")


func _on_jammer_pressed() -> void:
	show_entry("jammer")


func _on_delivery_drone_pressed() -> void:
	show_entry("delivery_drone")


func _on_hkcm_pressed() -> void:
	show_entry("hkcm")


func _on_spaghetti_cable_pressed() -> void:
	show_entry("spaghetti_cable")


func _on_toilet_silo_pressed() -> void:
	show_entry("toilet_silo")
