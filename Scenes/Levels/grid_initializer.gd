extends Node2D
@export var tilemap: TileMap

# Il tuo dizionario, usato per tracciare le proprietà della cella (es. "Grass")
# Questo dizionario DEVE essere accessibile anche da TurretManager, 
# quindi lo rendiamo un campo del nodo e lo passiamo a TurretManager o usiamo un riferimento.
# IMPORTANTE: Se TurretManager è collegato al nodo principale, dovrai accedervi.
# Per semplicità, lo terremo qui e lo assegneremo al TurretManager.
var dic = {} 

# Funzione che si occupa solo di inizializzare la griglia e il dizionario.
func _ready():
	if not tilemap:
		print("ERRORE: TileMap non assegnata a GridInitializer!")
		return
		
	# 1. Inizializzazione del Dizionario 'dic'
	for x in range(GameConstants.COLUMN):
		for y in range(GameConstants.ROW):
			var pos_key = str(Vector2i(x,y))
			dic[pos_key] = {
				"Type" : "Grass",
				"Position" : pos_key
			}
			# 2. Disegna la cella base sul livello 0
			# Assicurati che GameConstants.COLUMN e GameConstants.ROW siano disponibili globalmente o passate
			tilemap.set_cell(0, Vector2i(x,y), 1, Vector2i(0,0), 0)
	
	print("Griglia TileMap e Dizionario 'dic' inizializzati.")
