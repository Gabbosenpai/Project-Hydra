extends Node2D

@export var tilemap: TileMap

# @export booleano per attivare/disattivare la griglia di debug nell'Inspector.
@export var debug_draw_grid: bool = false:
	# Setter personalizzato. Quando il valore cambia (nell'editor o in runtime),
	# aggiorniamo il valore e chiediamo al nodo di ridisegnare.
	set(value):
		debug_draw_grid = value
		queue_redraw() # Chiede a Godot di chiamare _draw()


const TILE_SIZE = 160 # La dimensione del tile in pixel (160x160)
const FONT_SIZE = 20

# Il tuo dizionario, usato per tracciare le proprietà della cella
var dic = {} 
var debug_font: SystemFont = SystemFont.new()
# Funzione che si occupa solo di inizializzare la griglia e il dizionario.
func _ready():
	if not tilemap:
		print("ERRORE: TileMap non assegnata a GridInitializer!")
		return
	
	var font_settings = ClassDB.instantiate("SystemFontSettings")
	
	# Verifica che l'istanziazione sia riuscita (prevenzione)
	if font_settings:
		# 2. Imposta la dimensione.
		font_settings.set_font_size(FONT_SIZE)
		
		# 3. Assegna le impostazioni alla proprietà font_data.
		debug_font.font_data = font_settings
	else:
		# Fallback nel caso in cui la classe non sia stata trovata
		print("ATTENZIONE: SystemFontSettings non trovato. Usa font di default.")
	
		
	# 1. Inizializzazione del Dizionario 'dic' e della TileMap
	# Assicurati che GameConstants.COLUMN e GameConstants.ROW siano disponibili
	for x in range(1,GameConstants.COLUMN):
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
		var line_color = Color(1.0, 0.0, 0.0, 0.7)
		var line_width = 2.0
		var text_color = Color.YELLOW
		
		var tilemap_pos = tilemap.position
		
		# NUOVO OFFSET: Sposta l'origine di disegno a destra di 1 TILE_SIZE (esclude Colonna 0)
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
			
			var text_size = debug_font.get_string_size(text)
			pos.x -= text_size.x / 2
			
			draw_string(debug_font,pos,text,HORIZONTAL_ALIGNMENT_CENTER,-1.0,FONT_SIZE,text_color)

		# --- DISEGNO NUMERI RIGA (A Fianco) ---
		for y in range(GameConstants.ROW):
			var row_index = y
			var text = str(row_index)
			
			var center_y = tilemap_pos.y + y * TILE_SIZE + TILE_SIZE / 2.0
			
			var pos = Vector2(tilemap_pos.x + TILE_SIZE - 40, center_y + FONT_SIZE / 2.0)
			
			draw_string(debug_font,pos,text,HORIZONTAL_ALIGNMENT_CENTER,-1.0,FONT_SIZE,text_color)
		
		# --- Disegno dei centri delle celle (Esclude Colonna 0) ---
		var center_color = Color(0.0, 1.0, 1.0, 1.0)
		
		for x in range(display_columns):
			for y in range(GameConstants.ROW):
				var cell_center = offset + Vector2(x * TILE_SIZE + TILE_SIZE / 2.0, y * TILE_SIZE + TILE_SIZE / 2.0)
				draw_circle(cell_center, 4, center_color)
