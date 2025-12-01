extends Node2D

const TILE_SIZE = 160 # La dimensione del tile in pixel (160x160)
const FONT_SIZE = 20
const CONVEYOR_STEP_SCENE: PackedScene = preload("res://Scenes/Utilities/conveyor_belt.tscn")

@export var tilemap: TileMap
# Export booleano per attivare/disattivare la griglia di debug nell'Inspector.
@export var debug_draw_grid: bool = false:
	# Setter personalizzato. Quando il valore cambia (nell'editor o in runtime),
	# aggiorniamo il valore e chiediamo al nodo di ridisegnare.
	set(value):
		debug_draw_grid = value
		queue_redraw() # Chiede a Godot di chiamare _draw()

# Il tuo dizionario, usato per tracciare le proprietà della cella
var dic = {} 


# Funzione che si occupa solo di inizializzare la griglia e il dizionario.
func _ready():
	if not tilemap:
		print("ERRORE: TileMap non assegnata a GridInitializer!")
		return
	
	# 1. Inizializzazione del Dizionario 'dic' e della TileMap
	# Assicurati che GameConstants.COLUMN e GameConstants.ROW siano disponibili
	for x in range(1,GameConstants.COLUMN):
		for y in range(GameConstants.ROW):
			var pos_key = str(Vector2i(x,y))
			# 2. Logica per il Motivo a Scacchiera
			var source_id: int
		
		# Se la somma delle coordinate è pari, usa il tile Scuro
			if (x + y) % 2 == 0:
				source_id = 0
				dic[pos_key] = {
				"Type" : "Conveyor_Belt_Scuro", # Potresti voler cambiare il tipo
				"Position" : pos_key
				}
			else:
			# Se la somma delle coordinate è dispari, usa il tile Chiaro
				source_id = 2
				dic[pos_key] = {
				"Type" : "Conveyor_Belt_Chiaro", # Nuovo tipo
				"Position" : pos_key
				}
			# 2. Disegna la cella base sul livello 0
			tilemap.set_cell(0, Vector2i(x,y), source_id, Vector2i(0,0), 0)
	
	print("Griglia TileMap e Dizionario 'dic' inizializzati.")
	
	# Richiedi un disegno iniziale per assicurarti che la griglia 
	# appaia se è attiva nell'editor.
	queue_redraw() 


# Funzione di disegno personalizzata chiamata quando 
# il nodo viene aggiornato con queue_redraw()
func _draw():
	# Disegna la griglia solo se la variabile di debug è TRUE
	if debug_draw_grid:
		# Colori e spessore per il debug
		var line_color = Color(1.0, 0.0, 0.0, 0.7)
		var line_width = 2.0
		var text_color = Color.YELLOW
		
		var tilemap_pos = tilemap.position
		
		# NUOVO OFFSET: Sposta l'origine di disegno a destra 
		# di 1 TILE_SIZE (esclude Colonna 0)
		var offset = tilemap_pos + Vector2(TILE_SIZE, 0)
		
		var display_columns = GameConstants.COLUMN - 1
		var grid_width = display_columns * TILE_SIZE
		var grid_height = GameConstants.ROW * TILE_SIZE
		
		# --- Linee Verticali (Inizia da Colonna 1) ---
		for x in range(display_columns + 1):
			var start_pos = offset + Vector2(x * TILE_SIZE, 0)
			var end_pos = offset + Vector2(x * TILE_SIZE, grid_height)
			draw_line(start_pos, end_pos, line_color, line_width)
			
		# --- Linee Orizzontali (Inizia da Colonna 1) ---
		for y in range(GameConstants.ROW + 1):
			var start_pos = offset + Vector2(0, y * TILE_SIZE)
			var end_pos = offset + Vector2(grid_width, y * TILE_SIZE)
			draw_line(start_pos, end_pos, line_color, line_width)
			
		# --- DISEGNO NUMERI COLONNA (Sopra) ---
		for x in range(display_columns):
			var col_index = x + 1 
			var text = str(col_index)
			
			var center_x = offset.x + x * TILE_SIZE + TILE_SIZE / 2.0
			var pos = Vector2(center_x, tilemap_pos.y - 20)
			
			var default_font = ThemeDB.get_default_theme().default_font
			# Se il default_font non è null, usalo per ottenere la dimensione
			var text_size = Vector2.ZERO
			if default_font:
				text_size = default_font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, FONT_SIZE)
			
			pos.x -= text_size.x / 2
			
			draw_string(default_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, FONT_SIZE, text_color)
			
		# --- DISEGNO NUMERI RIGA (A Fianco) ---
		for y in range(GameConstants.ROW):
			var row_index = y
			var text = str(row_index)
			
			var center_y = tilemap_pos.y + y * TILE_SIZE + TILE_SIZE / 2.0
			
			var pos = Vector2(tilemap_pos.x + TILE_SIZE - 40, center_y + FONT_SIZE / 2.0)
			
			var default_font = ThemeDB.get_default_theme().default_font
			
			draw_string(default_font,pos,text,HORIZONTAL_ALIGNMENT_CENTER,-1.0,FONT_SIZE,text_color)
		
		# --- Disegno dei centri delle celle (Esclude Colonna 0) ---
		var center_color = Color(0.0, 1.0, 1.0, 1.0)
		
		for x in range(display_columns):
			for y in range(GameConstants.ROW):
				var cell_center = offset + Vector2(x * TILE_SIZE + TILE_SIZE / 2.0, y * TILE_SIZE + TILE_SIZE / 2.0)
				draw_circle(cell_center, 4, center_color)


func update_conveyors_phase(phase: int, rows_to_shift: Array = []):
	
	var is_blackout_mode = !rows_to_shift.is_empty()
	var rows_to_process: Array
	
	if is_blackout_mode:
		rows_to_process = rows_to_shift
	else:
		rows_to_process = range(GameConstants.ROW)
	
	for x in range(1, GameConstants.COLUMN):
		for y in rows_to_process:
			
			var cell = Vector2i(x, y)
			
			# 1. Determina il Source ID attuale per capire lo stato di partenza
			var current_source_id = tilemap.get_cell_source_id(0, cell)
			var animation_name: String
			
			# 2. DECIDI QUALE ANIMAZIONE ESEGUIRE (in base allo stato attuale del tile)
			if current_source_id == 0: # Scuro
				# Se il tile è Scuro e sta per cambiare stato, va a Chiaro
				animation_name = "scuroToChiaro"
			elif current_source_id == 2: # Chiaro
				# Se il tile è Chiaro e sta per cambiare stato, va a Scuro
				animation_name = "chiaroToScuro"
			else:
				# Salta se il tile non è un conveyor (sicurezza)
				continue
				
			# 3. Crea l'istanza dell'animazione
			var step_instance = CONVEYOR_STEP_SCENE.instantiate()
			
			# 4. Imposta i dati per l'animazione e la sincronizzazione
			step_instance.grid_initializer = self
			step_instance.cell_position = cell
			step_instance.next_phase = phase           # La fase finale
			step_instance.animation_name = animation_name # Il nome dell'animazione
			
			# 5. Posiziona l'animazione e aggiungi alla scena
			step_instance.global_position = tilemap.to_global(tilemap.map_to_local(cell))
			add_child(step_instance)
			
	print("Conveyor step animati istanziati.")


func update_tilemap_base(cell: Vector2i, phase: int):
	# Applica nuovamente la logica a scacchiera per l'ultima fase raggiunta
	
	var source_id: int
	
	# Usiamo la tua logica a scacchiera per determinare il nuovo stato statico
	if (cell.x + cell.y + phase) % 2 == 0:
		source_id = 0 # Tile Scuro
	else:
		source_id = 2 # Tile Chiaro
		
	# Imposta la cella sulla TileMap al nuovo Source ID permanente.
	# Le Atlas Coords (0,0) vengono usate per specificare 
	# il frame statico iniziale del tile.
	tilemap.set_cell(0, cell, source_id, Vector2i(0,0), 0)
