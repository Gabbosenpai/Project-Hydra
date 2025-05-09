extends Node2D

@export var nemico_a_scene: PackedScene
@export var nemico_b_scene: PackedScene
@export var spawn_point: NodePath
@export var tempo_tra_nemici: float = 0.5
@export var tempo_tra_ondate: float = 3.0
@export var wave_label_path: NodePath
@export var wave_announcement_path: NodePath

var ondata_corrente: int = 1
var nemici_per_ondata: int = 5
var nemici_spawnati: int = 0
var nemici_morti: int = 0
var spawnando: bool = false

func _ready() -> void:
	print("🌟 WaveSpawner pronto e inizializzato.")
	start_wave()

func start_wave() -> void:
	print("🚨 Inizio ondata ", ondata_corrente)

	var announcement = get_node(wave_announcement_path) as Label
	var wave_label = get_node(wave_label_path) as Label

	announcement.text = "🚨 ONDATA %d IN ARRIVO!" % ondata_corrente
	announcement.visible = true
	wave_label.visible = false

	print("⏲️ Annuncio ondata mostrato, attendo 2.5 secondi...")
	await get_tree().create_timer(2.5).timeout
	announcement.visible = false
	print("⏳ Annuncio ondata nascosto.")

	wave_label.text = "Ondata: %d" % ondata_corrente
	wave_label.visible = true

	nemici_spawnati = 0
	nemici_morti = 0
	spawnando = true

	print("🔄 Inizio spawn nemici. Totale nemici per ondata: ", nemici_per_ondata)

	for i in range(nemici_per_ondata):
		var delay = i * tempo_tra_nemici
		print("⏲️ Timer attivato! Spawn nemico in", delay, "secondi.")
		await get_tree().create_timer(delay).timeout
		spawn_enemy()

	spawnando = false
	print("✅ Fine ondata ", ondata_corrente)

func spawn_enemy() -> void:
	var tipo_nemico := randi() % 2
	var scena_nemico := nemico_a_scene if tipo_nemico == 0 else nemico_b_scene
	var nemico = scena_nemico.instantiate()

	# Ottieni il nodo di spawn
	var spawn_node = get_node(spawn_point)

	if spawn_node:
		print("Nodo di spawn trovato alla posizione globale:", spawn_node.global_position)

		# Aggiungi il nemico come figlio del nodo di spawn
		spawn_node.add_child(nemico)

		# Imposta la posizione globale del nemico alla posizione globale del nodo di spawn
		nemico.global_position = spawn_node.global_position

		var sprite = nemico.get_node_or_null("Sprite2D")
		if sprite:
			print("Sprite controllato.")
			if sprite.visible:
				print("✅ Il nemico ha uno sprite visibile!")
			else:
				print("⚠️ Il nemico ha uno sprite NON visibile.")
			if sprite.texture:
				print("✅ Lo sprite ha una texture assegnata.")
			else:
				print("⚠️ Lo sprite NON ha texture assegnata.")
		else:
			print("❌ Il nemico NON ha un nodo Sprite2D!")

		print("Nemico spawnato correttamente alla posizione globale:", nemico.global_position)
		print("Scala del nemico:", nemico.scale)
		print("Nemico visibile:", nemico.visible)
	else:
		print("❌ Errore: Nodo di spawn non trovato!")

	nemico.tree_exited.connect(_on_enemy_died)
	nemici_spawnati += 1
	print("Spawnato nemico tipo ", tipo_nemico, " - Totale spawnati: ", nemici_spawnati)

func _on_enemy_died() -> void:
	if get_tree() == null:
		print("⚠️ get_tree() è null — probabilmente la scena è stata ricaricata.")
		return
	nemici_morti += 1
	print("☠️ Nemico eliminato. Morti: ", nemici_morti, "/", nemici_spawnati)
	if nemici_morti >= nemici_spawnati and not spawnando:
		print("⏲️ Tutti i nemici morti, attendo prima della prossima ondata...")
		await get_tree().create_timer(tempo_tra_ondate).timeout
		ondata_corrente += 1
		nemici_per_ondata += 2
		print("🔄 Inizio nuova ondata: ", ondata_corrente)
		start_wave()
