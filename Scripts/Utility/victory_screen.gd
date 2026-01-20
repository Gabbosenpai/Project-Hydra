extends Control

@onready var unlock_label = $Text
@onready var turret_background = $"../TextureRect"
@onready var turret_icon = $"../TextureRect/TurretIcon"
@onready var menu_button: TextureButton = $MenuButton
@onready var select_level: TextureButton = $SelectLevel
@onready var next_level_label: Label = $NextLevel/Label

var current_level

func _ready() -> void:
	var scene_path = get_tree().current_scene.scene_file_path
	
	#Cerchiamo nel percorso della scena (es. "Lvl3.tscn") il modello "Lvl" seguito da numeri.
	# "Lvl" -> Cerca il testo letterale
	#"(\\d+)" -> Cattura uno o più cifre numeriche (0-9)
	var regex = RegEx.new()
	regex.compile("Lvl(\\d+)") 
	var result = regex.search(scene_path)
	
	if result:
		# Recuperiamo il primo gruppo catturato (il numero) e lo convertiamo in intero
		current_level = result.get_string(1).to_int() + 1
	
	var turret_name = get_turret_name_for_level(current_level)
	if turret_name != "":
		unlock_label.text += "\n\n NUOVA TORRETTA SBLOCCATA: " + turret_name
		unlock_label.visible = true
		var image_path = get_turret_image_for_level(current_level)
		if image_path != "":
			var tex = load(image_path)
			if tex:
				turret_icon.texture = tex
				turret_background.visible = true
				turret_icon.visible = true
			else:
				print("Errore: Immagine non trovata al percorso: ", image_path)
				turret_icon.visible = false
				turret_background.visible = false
	else:
		# Se non c'è una nuova torretta, nascondiamo l'icona
		turret_background.visible = false
		turret_icon.visible = false
	if current_level == 6:
		unlock_label.text = "Congratulazioni Ingegnere!\n Hai salvato il tuo posto di lavoro!"
		var settings := LabelSettings.new()
		settings.font_size = 60
		settings.line_spacing = 20
		unlock_label.label_settings = settings
		unlock_label.position += Vector2(0, 100)
		menu_button.visible = false
		select_level.visible = false
		next_level_label.text = "Continua"
		


func _on_select_level_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/level_selection.tscn")


func _on_next_level_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var next_level = current_level
	# Precarico la musica e cambio scena in base al livello max sbloccato
	var level_music : AudioStream = null
	var level_scene_path : String = ""
	
	match next_level:
		1:
			level_music = preload("res://Assets/Sound/OST/16-Bit Music - ＂Scrub Slayer＂.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl1.tscn"
		2:
			level_music = preload("res://Assets/Sound/OST/8 BIT RPG BATTLE  Retro Game Music  No Copyright Music.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl2.tscn"
		3:
			level_music = preload("res://Assets/Sound/OST/NEW POWER ▸ 8-Bit Chiptune ｜ Free Game Music [No Copyright].mp3")
			level_scene_path = "res://Scenes/Levels/Lvl3.tscn"
		4:
			level_music = preload("res://Assets/Sound/OST/Jeremy Blake - Powerup!  NO COPYRIGHT 8-bit Music.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl4.tscn"
		5:
			level_music = preload("res://Assets/Sound/OST/8 Bit Boss - Boss Battle Music By HeatleyBros.mp3")
			level_scene_path = "res://Scenes/Levels/Lvl5.tscn"
		_:
			# Se non esiste un livello sbloccato valido, fai qualcosa (ad esempio torna al menu)
			get_tree().change_scene_to_file("res://Scenes/Utilities/Credits.tscn")
			return
	
	AudioManager.play_music(level_music)
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(level_scene_path)


func _on_menu_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")


func get_turret_name_for_level(lvl: int) -> String:
	match lvl:
		#1: return "Delivery Drone & Bolt Shooter"
		2: return "Jammer Cannon"
		3: return "HKCM"
		4: return "Spaghetti Cable"
		5: return "Toilet Silo"
		_: return ""


func get_turret_image_for_level(lvl: int) -> String:
	match lvl:
		2: return "res://Assets/Sprites/Towers/Jammer Cannon/Jammer Cannon.png" 
		3: return "res://Assets/Sprites/Towers/HKCM/Hot Kawaii Coffee Machine.png"
		4: return "res://Assets/Sprites/Towers/Spaghetti Cable/Spaghetti Cable.png"
		5: return "res://Assets/Sprites/Towers/Toilet Silo/Sturamissile Launcher.png"
		_: return ""
