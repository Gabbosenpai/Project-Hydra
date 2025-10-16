extends Node

@export var starting_points: int = 5000
@export var max_points: int = 5000
@export var regen_amount: int = 25
@export var refund_percentage: float = 0.5 # Rimborso del 50% per distruzione

#dizionario dei costi delle piante il nome deve combaciare con quello di plant manager
var turret_costs := {
	"turret1": 50,
	"turret2": 75,
	"turret3": 100,
	"turret4": 125
}

var current_points: int
var current_ratio: float = 0.0 
@export var turret_manager: Node
@export var label_points: Label

@onready var regen_timer: Timer = $RegenTimer
@export var PointsBar: ColorRect

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
func _on_turret_placed(_cell_key):
	var turret_key = get_turret_key_from_scene(turret_manager.selected_turret_scene)
	if turret_key and turret_costs.has(turret_key):
		current_points -= turret_costs[turret_key]
		update_points_label()

# Gestisce il rimborso totale dei punti quando una pianta viene rimossa
# Identifica la pianta tramite il percorso della scena e aggiunge il costo ai punti correnti
func _on_turret_removed(_cell_key, turret_instance, is_destruction: bool = false): # Modificato per accettare un flag di distruzione
	var turret_key = ""
	
	# 1. Trova la chiave della torretta
	for key in turret_manager.turret_scenes.keys():
		# Il confronto tramite scene_file_path è robusto
		if turret_manager.turret_scenes[key].resource_path == turret_instance.scene_file_path:
			turret_key = key
			break
			
	if turret_key != "" and turret_costs.has(turret_key):
		var cost = turret_costs[turret_key]
		var refund_amount = cost
		
		# 2. Calcola il rimborso: Totale per rimozione manuale, Parziale per distruzione
		if is_destruction:
			# Distruzione (scorrimento o inceneritore): rimborso parziale
			refund_amount = int(cost * refund_percentage) 
			print("Rimborso PARZIALE (", refund_percentage * 100, "%): ", refund_amount)
		else:
			# Rimozione manuale (pulsante 'Rimuovi'): rimborso totale
			refund_amount = cost
			print("Rimborso TOTALE: ", refund_amount)

		current_points += refund_amount
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
# aggiorna lo shader della barra
	if PointsBar and PointsBar.material is ShaderMaterial:
		var mat: ShaderMaterial = PointsBar.material as ShaderMaterial
		var target_ratio: float = clamp(float(current_points) / float(max_points), 0.0, 1.0)
		
		# Calcola differenza percentuale rispetto al massimo
		var diff = abs(target_ratio - current_ratio)
		
		# Imposta durata proporzionale alla differenza, così anche piccoli valori si muovono lentamente
		var duration = diff * 1.0  # puoi moltiplicare per un fattore per velocità più lenta
		duration = max(duration, 0.1)  # durata minima per vedere sempre movimento
		
		var tween = PointsBar.create_tween()
		tween.tween_property(mat, "shader_parameter/progress_value", target_ratio, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		current_ratio = target_ratio

# Ricava la chiave della pianta dato un PackedScene della pianta stessa
# Cerca tra tutte le piantine disponibili in plant_manager per trovare corrispondenza
func get_turret_key_from_scene(scene: PackedScene) -> String:
	for key in turret_costs.keys():
		if turret_manager.turret_scenes.has(key) and turret_manager.turret_scenes[key] == scene:
			return key
	return ""
