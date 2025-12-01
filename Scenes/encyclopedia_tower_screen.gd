extends Control

@onready var desc_panel = $MonsterDescriptionPanel
@onready var desc_label = $MonsterDescriptionPanel/MonsterDescription
@onready var name_label = $MonsterDescriptionPanel/MonsterName
@onready var monster_image = $MonsterDescriptionPanel/MonsterTexture
#da modificare con i percorsi giusti
var monster_textures = {
	"bolt_shooter": preload("res://Assets/Sprites/Towers/Bolt Shooter/Idle/Bolt Shooter-Idle_0001.png"),
	"delivery_drone": preload("res://Assets/Sprites/Towers/Delivery Drone/Delivery Drone Fly-00.png"),
	"hkcm": preload("res://Assets/Sprites/Towers/HKCM/Hot Kawaii Coffee Machine.png"),
	"jammer": preload("res://Assets/Sprites/Towers/Jammer Cannon/Jammer Cannon.png"),
	"spaghetti_cable": preload("res://Assets/Sprites/Towers/Spaghetti Cable/Spaghetti Cable.png")
}








var monster_names = {
	"bolt_shooter": "BOLT SHOOTER",
	"delivery_drone": "DELIVERY DRONE",
	"hkcm": "HOT KAWAII COFFEE MACHINE",
	"jammer": "JAMMER",
	"spaghetti_cable": "SPAGHETTI CABLE"
}


var monster_texts = {
	"bolt_shooter": "Questo è il Bolt Shooter! "+
	"Il suo corpo simile all’elettricità può introdursi "+
	"in alcuni apparecchi, di cui prende il controllo "+
	"per combinare guai.",
	
	"weed_eater": "Questo è il Weed Eater! "+
	"due ruote motrici, tre lame che fanno ognuna 800 rpm "+
	"e sembrano anche dei bei baffoni utili per tosare l'erba con stile!",
	
	"delivery_drone": "Questo è il Delivery Drone! " +
	"il suo corpo elettrico può introdursi in alcuni strumenti" +
	" prendendone il controllo e creando caos.",
	
	"hkcm": "Questo è la Hot Kawaii Coffe Machine! " +
	"È in grado di avvertire l’aura di tutte le cose. " +
	" Comprende il linguaggio umano.",
	
	
	
	"jammer": "Questo è il Jammer! "+
	"avevamo progettato questo nuovo tipo di jammer ma le misure "+
	"invece che in centimetri le abbiamo scritte in metri!"
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



# Esempio di pulsante
func _on_bolt_shooter_pressed() -> void:
	show_description("bolt_shooter")

# Nasconde al click
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_description()


func _on_back_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/EncyclopediaFirstScreen.tscn")

	
func _on_jammer_pressed() -> void:
	show_description("jammer")
#
#
#
#
func _on_delivery_drone_pressed() -> void:
	show_description("delivery_drone")
#
#
func _on_hkcm_pressed() -> void:
	show_description("hkcm")
