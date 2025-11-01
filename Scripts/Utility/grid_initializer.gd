extends Node2D

@export var tilemap: TileMap

# @export booleano per attivare/disattivare la griglia di debug nell'Inspector.
@export var debug_draw_grid: bool = false:
	# Setter personalizzato. Quando il valore cambia (nell'editor o in runtime),
	# aggiorniamo il valore e chiediamo al nodo di ridisegnare.
	set(value):
		debug_draw_grid = value
		queue_redraw() # Chiede a Godot di chiamare _draw()

# --- Costanti Assunte (Adatta se necessario) ---
# Assumo che queste costanti esistano in uno script GameConstants.gd o siano definite qui.
# Se la griglia è 160x160 px totali, con tile 160x160 px,
# significa che ci sono solo 1 colonna e 1 riga (un solo tile).
# Se la griglia ha dimensioni multiple, adatta COLUMN e ROW.
# ESEMPIO: Se la griglia è 1600x1600 px, COLUMN = 10, ROW = 10
const TILE_SIZE = 160 # La dimensione del tuo singolo tile in pixel (160x160)
# Se stai usando le costanti globali, puoi rimuovere le seguenti due righe di esempio:
# const COLUMN = 10 # Esempio
# const ROW = 10    # Esempio
# --- FINE Costanti Assunte ---

# Il tuo dizionario, usato per tracciare le proprietà della cella
var dic = {} 

# Funzione che si occupa solo di inizializzare la griglia e il dizionario.
func _ready():
	if not tilemap:
		print("ERRORE: TileMap non assegnata a GridInitializer!")
		return
	
	# Questo nodo deve risiedere nella stessa posizione della TileMap nel mondo
	# per un disegno corretto, o usiamo tilemap.global_position in _draw().
	# Per semplicità, ci affidiamo alla posizione locale e la TileMap come child/sibling.
		
	# 1. Inizializzazione del Dizionario 'dic' e della TileMap
	# Assicurati che GameConstants.COLUMN e GameConstants.ROW siano disponibili
	for x in range(GameConstants.COLUMN):
		for y in range(GameConstants.ROW):
			var pos_key = str(Vector2i(x,y))
			dic[pos_key] = {
				"Type" : "Grass",
				"Position" : pos_key
			}
			# 2. Disegna la cella base sul livello 0
			tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(0,0), 0)
	
	print("Griglia TileMap e Dizionario 'dic' inizializzati.")
	
	# Richiedi un disegno iniziale per assicurarti che la griglia appaia se è attiva nell'editor.
	queue_redraw() 

# Funzione di disegno personalizzata chiamata quando il nodo viene aggiornato con queue_redraw()
func _draw():
	# Disegna la griglia solo se la variabile di debug è TRUE
	if debug_draw_grid:
		# Colori e spessore per il debug
		var color = Color(1.0, 0.0, 0.0, 0.7) # Linee della griglia (Rosso semi-trasparente)
		var line_width = 2.0
		
		# Spostiamo l'origine del disegno alla posizione della TileMap.
		var tilemap_pos = tilemap.position
		
		# 1. NUOVO OFFSET: Sposta l'origine di disegno a destra di 1 TILE_SIZE.
		var offset = tilemap_pos + Vector2(TILE_SIZE, 0)
		
		# 2. NUOVA DIMENSIONE: La larghezza è ora (Colonne totali - 1) * TILE_SIZE.
		var display_columns = GameConstants.COLUMN - 1
		var grid_width = display_columns * TILE_SIZE
		var grid_height = GameConstants.ROW * TILE_SIZE # L'altezza rimane invariata
		
		# --- Disegno Linee Verticali ---
		# Il ciclo va da 0 al numero di colonne da visualizzare (display_columns)
		for x in range(display_columns + 1):
			var start_pos = offset + Vector2(x * TILE_SIZE, 0)
			var end_pos = offset + Vector2(x * TILE_SIZE, grid_height)
			draw_line(start_pos, end_pos, color, line_width)

		# --- Disegno Linee Orizzontali ---
		# Queste linee ora iniziano all'offset (colonna 1) e finiscono dopo (display_columns)
		for y in range(GameConstants.ROW + 1):
			var start_pos = offset + Vector2(0, y * TILE_SIZE)
			var end_pos = offset + Vector2(grid_width, y * TILE_SIZE)
			draw_line(start_pos, end_pos, color, line_width)
			
		# Opzionale: Disegno dei centri delle celle
		var center_color = Color(0.0, 1.0, 1.0, 1.0) # Centri delle celle (Ciano)
		
		# Il ciclo parte da 0, ma l'offset gestisce già l'esclusione della Colonna 0
		for x in range(display_columns): # x va da 0 a display_columns - 1
			for y in range(GameConstants.ROW):
				# Il centro viene calcolato rispetto al nuovo offset
				var cell_center = offset + Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2)
				draw_circle(cell_center, 4, center_color)
