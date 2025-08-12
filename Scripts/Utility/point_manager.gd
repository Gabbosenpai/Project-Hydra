extends Node

@export var starting_points: int = 5000
@export var regen_amount: int = 25

#dizionario dei costi delle piante il nome deve combaciare con quello di plant manager
var turret_costs := {
	"turret1": 50,
	"turret2": 75,
	"turret3": 100,
	"turret4": 125
}

var current_points: int

@export var turret_manager: Node
@export var label_points: Label

@onready var regen_timer: Timer = $RegenTimer

# Inizializza i punti correnti con quelli di partenza e aggiorna la visualizzazione del punteggio
func _ready():
	current_points = starting_points
	update_points_label()

# Verifica se il giocatore ha abbastanza punti per selezionare una pianta specificata da plant_key
func can_select_turret(turret_key: String) -> bool:
	if not turret_costs.has(turret_key):
		return false
	return current_points >= turret_costs[turret_key]

# Gestisce la riduzione dei punti quando una pianta viene piazzata
# Recupera il tipo di pianta dalla scena selezionata e sottrae il suo costo ai punti correnti
func _on_turret_placed(cell_key):
	var turret_key = get_turret_key_from_scene(turret_manager.selected_turret_scene)
	if turret_key and turret_costs.has(turret_key):
		current_points -= turret_costs[turret_key]
		update_points_label()

# Gestisce il rimborso totale dei punti quando una pianta viene rimossa
# Identifica la pianta tramite il percorso della scena e aggiunge il costo ai punti correnti
func _on_turret_removed(cell_key, turret_instance):
	var turret_key = ""
	# Cerca la chiave della pianta confrontando il percorso della scena con quella dell'istanza rimossa
	for key in turret_manager.turret_scenes.keys():
		if turret_manager.turret_scenes[key].resource_path == turret_instance.scene_file_path:
			turret_key = key
			break
	# Se trovata, rimborsa i punti al giocatore
	if turret_key != "" and turret_costs.has(turret_key):
		current_points += turret_costs[turret_key] # Rimborso totale
		update_points_label()

# Funzione chiamata quando il timer di rigenerazione scade
# Aggiunge una quantità fissa di punti e aggiorna l'etichetta
func _on_regen_timer_timeout():
	current_points += regen_amount
	update_points_label()

# Aggiorna il testo dell'etichetta che mostra i punti attuali al giocatore
func update_points_label():
	if label_points:
		label_points.text = str("Scrap: ") + str(current_points)

# Ricava la chiave della pianta dato un PackedScene della pianta stessa
# Cerca tra tutte le piantine disponibili in plant_manager per trovare corrispondenza
func get_turret_key_from_scene(scene: PackedScene) -> String:
	for key in turret_costs.keys():
		if turret_manager.turret_scenes.has(key) and turret_manager.turret_scenes[key] == scene:
			return key
	return ""
