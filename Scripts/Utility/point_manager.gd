extends Node

static var current_points: int

@export var turret_manager: Node
@export var label_points: Label
@export var PointsBar: ColorRect
@export var starting_points: int = 100
@export var max_points: int = 500000
@export var refund_points: int = 25

# Dizionario dei costi delle torrette il nome deve combaciare 
# con quello di turret manager
var turret_costs := {
	"turret1": 50,
	"turret2": 75,
	"turret3": 100,
	"turret4": 125,
	"turret5": 50
}
var current_ratio: float = 0.0 


static func get_total_points_for_current_slot() -> int:
	var slot = SaveManager.current_slot
	var save_path = "user://tech_tree_slot_%d.save" % slot
	if !FileAccess.file_exists(save_path):
		return 0
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return 0
	var points = file.get_var()
	file.close()
	return points


static func save_total_points_for_current_slot(points: int) -> void:
	var slot = SaveManager.current_slot
	var save_path = "user://tech_tree_slot_%d.save" % slot
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		print("Errore salvataggio punti TechTree!")
		return
	file.store_var(points)
	file.close()


# Funzione per aggiornare i punti del techtree per lo slot corrente
static func add_level_points_to_total(points: int) -> void:
	var current_total = get_total_points_for_current_slot()
	current_total += points
	save_total_points_for_current_slot(current_total)


# Inizializza i punti correnti con quelli di partenza e 
# aggiorna la visualizzazione del punteggio
func _ready():
	current_points = starting_points
	update_points_label()


# Verifica se il giocatore ha abbastanza punti per selezionare 
# una torretta specificata da turret_key
func can_select_turret(turret_key: String) -> bool:
	if not turret_costs.has(turret_key):
		return false
	return current_points >= turret_costs[turret_key]


# Gestisce la riduzione dei punti quando una torretta viene piazzata
# Recupera il tipo di torretta dalla scena selezionata e 
# sottrae il suo costo ai punti correnti
func _on_turret_placed(_cell_key):
	var turret_key = get_turret_key_from_scene(turret_manager.selected_turret_scene)
	if turret_key and turret_costs.has(turret_key):
		current_points -= turret_costs[turret_key]
		update_points_label()


func earn_points(amount: int):
	if amount > 0:
		current_points += amount
		# Assicurati di non superare il massimo
		current_points = min(current_points, max_points) 
		update_points_label()
		print("Punti guadagnati: ", amount, " (Totale: ", current_points, ")")


# Aggiorna il testo dell'etichetta che mostra i punti attuali al giocatore
func update_points_label():
	if label_points:
		label_points.text = str("Scrap: ") + str(current_points)
# Aggiorna lo shader della barra
	if PointsBar and PointsBar.material is ShaderMaterial:
		var mat: ShaderMaterial = PointsBar.material as ShaderMaterial
		var target_ratio: float = clamp(float(current_points) / float(max_points), 0.0, 1.0)
		
		# Calcola differenza percentuale rispetto al massimo
		var diff = abs(target_ratio - current_ratio)
		
		# Imposta durata proporzionale alla differenza, 
		# così anche piccoli valori si muovono lentamente.
		# Puoi moltiplicare per un fattore per velocità più lenta
		var duration = diff * 1.0  
		duration = max(duration, 0.1)  # Durata min per vedere sempre movimento
		
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
