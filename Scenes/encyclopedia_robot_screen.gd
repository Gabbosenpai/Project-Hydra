extends Control

@onready var desc_panel = $MonsterDescriptionPanel
@onready var desc_label = $MonsterDescriptionPanel/MonsterDescription
@onready var name_label = $MonsterDescriptionPanel/MonsterName
@onready var monster_image = $MonsterDescriptionPanel/MonsterTexture

#da modificare con i percorsi giusti
var monster_textures = {
	"weed_eater": preload("res://Assets/Sprites/Robots/Weed Eater 9000/Weed Eater 9000.png"),
	
}


var monster_names = {
	"weed_eater": "WEED EATER 9000",
	"mecha_freezer": "MECHA FREEZER",
	"fire_hydrant": "FIRE HYDRANT",
	"romba": "ROMBA", #da verificare copyright
	"cassa_schierata": "CASSA SCHIERATA"
}	


var monster_texts = {
	
	"weed_eater": "Questo è il Weed Eater! "+
	"due ruote motrici, tre lame che fanno ognuna 800 rpm "+
	"e sembrano anche dei bei baffoni utili per tosare l'erba con stile!",
	
}

func ready():
	desc_panel.visible = false
	
	
 #Mostra la descrizione del mostro
func show_description(monster_name: String):
	if monster_name in monster_texts:
		name_label.text = monster_names[monster_name]
		desc_label.text = monster_texts[monster_name]
		if monster_name in monster_textures:
			monster_image.texture = monster_textures[monster_name]
		else:
			monster_image.texture = null

		desc_panel.modulate.a = 0.0
		desc_panel.visible = true

		# Aspetta un frame per calcolare bene la dimensione
		await get_tree().process_frame

		# Centra il pannello sullo schermo
		#desc_panel.position = (get_viewport_rect().size - desc_panel.size) / 2

		# Effetto fade-in morbido
		var tween = create_tween()
		tween.tween_property(desc_panel, "modulate:a", 1.0, 0.3)


# Nasconde la descrizione
func hide_description():
	desc_panel.visible = false


# per nascondere la descrizione cliccando 
# al di fuori delle immagini dei robot
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_description()


func _on_back_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/EncyclopediaFirstScreen.tscn")


func _on_weed_eater_pressed() -> void:
	show_description("weed_eater")
