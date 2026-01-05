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
	"romba": 2,
	"weed_eater": 3,         
	"mecha_freezer": 4,
	"fire_hydrant": 5,
	"cassa_schierata": 6
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
	
	"weed_eater": "Dotato di tre possenti lame d’acciaio estremamente affilate. Le lame sono grado di compiere ben 800 giri al minuto e falciare anche la più insidiosa delle erbacce. Non accarezzare le sue lame anche se possono sembrare dei bei baffoni (l’Azienda non è responsabile in caso della perdita di arti, leggere attentamente il foglio illustrativo non presente nella confezione).",
	"mecha_freezer": "È più grosso! È più cattivo! Signore e signori,questo è troppo anche per l’estate più torrida che abbiate mai vissuto! Il nuovo modello di Mecha Freezer è progettato per farti sentire al fresco come se fossi in mezzo ad una bufera di neve e può raggiungere qualsiasi luogo grazie ai suoi possenti cingoli (necessita comunque di essere collegato ad una presa per il corretto funzionamento).",
	"cassa_schierata": "Questa cassa ha uno stile moderno e selvaggio allo stesso tempo, per alcuni incute timore, per altri ispira sicurezza. Purtroppo crede a tutti gli ordini del software e li esegue sempre senza mai metterli in discussione, se provi a contraddirlo ti urla addosso. Crede che si stava meglio quando c’era lui a dirigere la musica, ovvero la versione 2.2 del software.",
	"romba": "Il suo unico scopo è divorare anche la più piccola briciola presente sulla faccia della terra. Non si fermerà dinanzi a nulla, nemmeno davanti a un muro! (si prega di non posizionare ostacoli davanti al suo passaggio per un corretto funzionamento).",
	"fire_hydrant": "Non dovrai aspettare mai più i pompieri! Le braccia del Fire Hydrant sono in grado di spruzzare getti d’acqua ad alta pressione per contrastare anche le fiamme più ostinate e, grazie alle sue molle, neanche il fuoco ad alta quota è un problema! I pompieri sono scettici nel suo uso a causa dell’elevata probabilità che saltelli via a domare mozziconi di sigaretta roventi sui marciapiedi (acqua non inclusa)."
	
	




	
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
	get_tree().change_scene_to_file("res://Scenes/Utilities/Encyclopedia/EncyclopediaFirstScreen.tscn")


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
