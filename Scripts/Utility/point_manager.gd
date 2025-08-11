extends Node

@export var starting_points: int = 50
@export var regen_amount: int = 25

#dizionario dei costi delle piante il nome deve combaciare con quello di plant manager
var plant_costs := {
	"plant1": 50,
	"plant2": 75,
	"plant3": 100,
	"plant4": 125
}

var current_points: int

@export var plant_manager: Node
@export var label_points: Label

@onready var regen_timer: Timer = $RegenTimer

# Inizializza i punti correnti con quelli di partenza e aggiorna la visualizzazione del punteggio
func _ready():
	current_points = starting_points
	update_points_label()

# Verifica se il giocatore ha abbastanza punti per selezionare una pianta specificata da plant_key
func can_select_plant(plant_key: String) -> bool:
	if not plant_costs.has(plant_key):
		return false
	return current_points >= plant_costs[plant_key]

# Gestisce la riduzione dei punti quando una pianta viene piazzata
# Recupera il tipo di pianta dalla scena selezionata e sottrae il suo costo ai punti correnti
func _on_plant_placed(cell_key):
	var plant_key = get_plant_key_from_scene(plant_manager.selected_plant_scene)
	if plant_key and plant_costs.has(plant_key):
		current_points -= plant_costs[plant_key]
		update_points_label()

# Gestisce il rimborso totale dei punti quando una pianta viene rimossa
# Identifica la pianta tramite il percorso della scena e aggiunge il costo ai punti correnti
func _on_plant_removed(cell_key, plant_instance):
	var plant_key = ""
	# Cerca la chiave della pianta confrontando il percorso della scena con quella dell'istanza rimossa
	for key in plant_manager.plant_scenes.keys():
		if plant_manager.plant_scenes[key].resource_path == plant_instance.scene_file_path:
			plant_key = key
			break
	# Se trovata, rimborsa i punti al giocatore
	if plant_key != "" and plant_costs.has(plant_key):
		current_points += plant_costs[plant_key] # Rimborso totale
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
func get_plant_key_from_scene(scene: PackedScene) -> String:
	for key in plant_costs.keys():
		if plant_manager.plant_scenes.has(key) and plant_manager.plant_scenes[key] == scene:
			return key
	return ""
