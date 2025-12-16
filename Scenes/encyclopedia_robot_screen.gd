extends Control

@onready var desc_panel = $MonsterDescriptionPanel
@onready var desc_label = $MonsterDescriptionPanel/MonsterDescription
@onready var name_label = $MonsterDescriptionPanel/MonsterName
@onready var monster_image = $MonsterDescriptionPanel/MonsterTexture


var monster_textures = {
	"weed_eater": preload("res://Assets/Sprites/Robots/Weed Eater 9000/Weed Eater 9000.png"),
	"mecha_freezer": preload("res://Assets/Sprites/Robots/Mecha Freezer/Mecha Freezer.png"),
	"fire_hydrant": preload("res://Assets/Sprites/Robots/Fire Hydrant/Firehydrant.png"),
	"romba": preload("res://Assets/Sprites/Robots/Romba/Romba.png"),
	"cassa_schierata": preload("res://Assets/Sprites/Robots/Cassa Schierata/Cassa Schierata.png")
}	


var monster_names = {
	"weed_eater": "WEED EATER 9000",
	"mecha_freezer": "MECHA FREEZER",
	"fire_hydrant": "FIRE HYDRANT",
	"romba": "ROMBA", #da verificare copyright
	"cassa_schierata": "CASSA SCHIERATA"
}	

#valore livello massimo per sbloccare una voce
var robot_unlock_levels = {
	"weed_eater": 2,         
	"mecha_freezer": 2,
	"fire_hydrant": 3,
	"romba": 4,
	"cassa_schierata": 5
}



#corrispondenza nome->nodo
@onready var robot_buttons = {
	"weed_eater": $WeedEater,         
	"mecha_freezer": $MechaFreezer,
	"fire_hydrant": $FireHydrant,
	"romba": $Romba,
	"cassa_schierata": $CassaSchierata
}

var monster_texts = {
	
	"weed_eater": "Questo è il Weed Eater! "+
	"Due ruote motrici, tre lame che fanno ognuna 800 rpm "+
	"e sembrano anche dei bei baffoni utili per tosare l'erba con stile!",
	
	"mecha_freezer": "Si dice che appaia nei centri abitati nelle notti in cui imperversano bufere di neve. Se bussa alla porta, non bisogna aprire per nessun motivo.",
	"cassa_schierata": "Le sue urla si sentono a 10 km di distanza. Emette diversi suoni dalle numerose aperture sul suo corpo.",
	"romba": "Ha gli arti superiori dotati di foglie affilate come rasoi e si muove agilmente fra i rami degli alberi per attaccare dall'alto i nemici.",
	"fire_hydrant": "I cannoni sul suo guscio sparano getti d'acqua capaci di bucare l'acciaio."
	
}

func _ready():
	update_buttons()
	
	
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
	update_buttons()


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


func _on_mecha_freezer_pressed() -> void:
	show_description("mecha_freezer")


func _on_cassa_schierata_pressed() -> void:
	show_description("cassa_schierata")


func _on_fire_hydrant_pressed() -> void:
	show_description("fire_hydrant")


func _on_romba_pressed() -> void:
	show_description("romba")


#per aggiornare dinamicamente l'enciclopedia
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
			texture.visible = false
