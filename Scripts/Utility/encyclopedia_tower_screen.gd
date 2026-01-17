extends Control

var tower_textures = {
	"bolt_shooter": preload("res://Assets/Sprites/Towers/Bolt Shooter/Idle/Bolt Shooter-Idle_0001.png"),
	"delivery_drone": preload("res://Assets/Sprites/Towers/Delivery Drone/Delivery Drone Fly-00.png"),
	"hkcm": preload("res://Assets/Sprites/Towers/HKCM/Hot Kawaii Coffee Machine.png"),
	"jammer": preload("res://Assets/Sprites/Towers/Jammer Cannon/Jammer Cannon.png"),
	"spaghetti_cable": preload("res://Assets/Sprites/Towers/Spaghetti Cable/Spaghetti Cable.png"),
	"toilet_silo": preload("res://Assets/Sprites/Towers/Toilet Silo/Sturamissile Launcher.png"),
}
#valore livello massimo per sbloccare una voce
var tower_unlock_levels = {
	"bolt_shooter": 1,         
	"delivery_drone": 1,
	"hkcm": 3,
	"jammer": 2,
	"spaghetti_cable": 4,
	"toilet_silo": 5
}
var tower_names = {
	"bolt_shooter": "Bolt Shooter",
	"delivery_drone": "Delivery Drone",
	"hkcm": "Hot Kawaii Coffee Machine",
	"jammer": "Jammer Cannon",
	"spaghetti_cable": "Spaghetti Cable",
	"toilet_silo": "Toilet Silo"
}
var tower_texts = {
	"bolt_shooter": "Ti manca un bullone? Non preoccuparti ma sii pronto a prenderlo al volo! Il Bolt Shooter è in grado di sorvegliare i suoi dintorni e capire se hai bisogno di un bullone senza nemmeno chiedere (nastro adesivo per farlo reggere in piedi e bulloni non inclusi - l’Azienda scarica ogni responsabilità al cliente in caso di danni a cose, animali o persone).",	
	"weed_eater": "Questo è il Weed Eater! due ruote motrici, tre lame che fanno ognuna 800 rpm e sembrano anche dei bei baffoni utili per tosare l'erba con stile!",
	"delivery_drone": "Se desideri qualcosa e la desideri subito, allora il delivery drone è ciò che fa per te! Posiziona la sua piattaforma d’atterraggio ben visibile, fai l’ordine e il nostro drone la porterà sfrecciando nel cielo! (A causa di traffico, schianto del drone, caduta del pacco, scontro aereo con volatile, abbattimento dalla contraerea, alieni, etc. la mancata consegna non sarà rimborsata e sarà necessario fare un nuovo ordine)",
	"hkcm": "“せんぱ〜い！こんにちはっ！今日もすっごく頑張ったね！えへへ…よかったら、あったか〜いコーヒー、一緒に飲まない？”Questa frase d’incoraggiamento incisa su questa carinissima macchina del caffè l’ha resa una tra le più vendute sul mercato. Alcuni hanno giurato di vederla arrossire mentre faceva il caffè…",
	"jammer": "Questo è il Jammer! Avevamo progettato questo nuovo tipo di jammer, ma le misure invece che in centimetri le abbiamo scritte in metri!",
	"spaghetti_cable": "Versione Hardware del famoso Spaghetti Code e incubo di qualsiasi tecnico ma stranamente popolare sul mercato. Il suo successo ha portato l’Azienda ad allocare un intero reparto per la produzione, incrementando inspiegabilmente le vendite scrivendo “MADE IN ITALY” sulla confezione, fornendo cavi esclusivamente tricolore.",
	"toilet_silo":"Il nemico non potrà nascondersi nemmeno in bagno! Questo design permette l’installazione di missili ad alto potenziale esplosivo costruiti con materiali estremamente economici e in grado di mimetizzarsi in ogni bagno che si rispetti (Non confondere la carta igienica esplosiva non quella classica)."
}
var clicked: bool

@onready var desc_panel = $TowerDescriptionPanel
@onready var desc_label = $TowerDescriptionPanel/TowerDescription
@onready var name_label = $TowerDescriptionPanel/TowerName
#corrispondenza nome->nodo
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
	update_buttons()


 #Mostra la descrizione della torretta
func show_description(tower_name: String):
	if tower_name in tower_texts:
		name_label.text = tower_names[tower_name]
		desc_label.text = tower_texts[tower_name]
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


#per aggiornare dinamicamente l'enciclopedia
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


# Nasconde al click
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_description()


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
