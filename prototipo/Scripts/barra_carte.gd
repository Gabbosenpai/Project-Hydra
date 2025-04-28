extends CanvasLayer

# Quantità iniziale di punti (elisir)
var punti = 10

# Variabili per la carta selezionata e il cannone in anteprima
var carta_selezionata : PackedScene = null
var anteprima_cannone : StaticBody2D = null
var tipo_cannone_selezionato: String = ""

# Costi dei vari cannoni
const COSTO_CANNONE1 = 5
const COSTO_CANNONE2 = 7

# Riferimenti ai nodi UI
@onready var punti_bar = $Barra_Punti
@onready var punti_label = $Barra_Punti/Punti
@onready var timer_punti = $TimerPunti

@onready var carta1 = $BarraCarte/Carta
@onready var carta2 = $BarraCarte/Carta2

func _ready():
	# Avvia il timer per la generazione automatica dei punti
	timer_punti.start()
	# Connetti il click delle carte alle funzioni
	carta1.gui_input.connect(_on_Carta1_clicked)
	carta2.gui_input.connect(_on_Carta2_clicked)

# Funzione quando clicchiamo sulla carta1
func _on_Carta1_clicked(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("🖱️ Cliccato su Carta1 - Punti attuali:", punti)
		if punti >= COSTO_CANNONE1:
			carta_selezionata = preload("res://Scene/Cannone_A/cannone_A.tscn")
			tipo_cannone_selezionato = "Cannone_A"
			crea_anteprima("Cannone_A")
			print("🎴 Cannone1 selezionato!")
		else:
			print("⚠️ Non abbastanza punti per selezionare il Cannone1!")

# Funzione quando clicchiamo sulla carta2
func _on_Carta2_clicked(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("🖱️ Cliccato su Carta2 - Punti attuali:", punti)
		if punti >= COSTO_CANNONE2:
			carta_selezionata = preload("res://Scene/Cannone_B/cannone_b.tscn")
			tipo_cannone_selezionato = "Cannone_B"
			crea_anteprima("Cannone_B")
			print("🎴 Cannone2 selezionato!")
		else:
			print("⚠️ Non abbastanza punti per selezionare il Cannone2!")

# Crea l'anteprima del cannone che segue il mouse
func crea_anteprima(cannone_tipo: String):
	if anteprima_cannone:
		print("🧹 Rimuovo anteprima precedente")
		anteprima_cannone.queue_free()

	if carta_selezionata != null:
		anteprima_cannone = carta_selezionata.instantiate() as StaticBody2D
		add_child(anteprima_cannone)
		anteprima_cannone.modulate.a = 0.5  # Rendi semi-trasparente
		anteprima_cannone.global_position = get_viewport().get_mouse_position()
		print("🆕 Creata nuova anteprima:", cannone_tipo)

# Gestione degli input (clic del mouse)
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if anteprima_cannone:
			print("✅ Confermato posizionamento di", tipo_cannone_selezionato)
			anteprima_cannone.modulate.a = 1.0  # Rendi il cannone completamente visibile
			# Attiva il cannone per permettergli di sparare
			anteprima_cannone.attivo = true

			# Scala i punti in base al tipo di cannone
			if tipo_cannone_selezionato == "Cannone_A" and punti >= COSTO_CANNONE1:
				punti -= COSTO_CANNONE1
				print("💸 Scalato", COSTO_CANNONE1, "punti! Rimasti:", punti)
				aggiorna_punti()
			elif tipo_cannone_selezionato == "Cannone_B" and punti >= COSTO_CANNONE2:
				punti -= COSTO_CANNONE2
				print("💸 Scalato", COSTO_CANNONE2, "punti! Rimasti:", punti)
				aggiorna_punti()
			else:
				print("⚠️ Non abbastanza punti per confermare il cannone")
			
			# Resetta le variabili per permettere nuove selezioni
			anteprima_cannone = null
			carta_selezionata = null
			tipo_cannone_selezionato = ""

# Aggiorna la barra dei punti e il testo
func aggiorna_punti():
	print("🔄 Aggiornamento barra punti:", punti)
	punti_label.text = "Punti: %d/10" % punti
	punti_bar.value = punti

# Funzione che aggiorna la posizione dell'anteprima ogni frame
func _process(delta: float) -> void:
	if anteprima_cannone:
		anteprima_cannone.global_position = get_viewport().get_mouse_position()

# Funzione chiamata dal timer ogni tot secondi per incrementare i punti
func _on_TimerPunti_timeout():
	print("⏲️ Timer attivato! Punti prima:", punti)
	punti += 1
	if punti > 10:
		punti = 10  # Non supera mai 10 punti massimi
	print("⏲️ Timer - punti incrementati a", punti)
	aggiorna_punti()
