extends CanvasLayer  # Layer UI che resta fisso sulla schermata

#Punti iniziali (es. Elisir o Energia)
var punti = 10

#Variabili per la carta selezionata e il cannone in anteprima
var carta_selezionata : PackedScene = null  # Scena del cannone selezionato
var anteprima_cannone : StaticBody2D = null  # Anteprima visiva del cannone
var tipo_cannone_selezionato: String = ""  # Per sapere che tipo di cannone è stato selezionato

#Costi in punti dei cannoni
const COSTO_CANNONE1 = 5
const COSTO_CANNONE2 = 7

#Collegamenti a nodi UI
@onready var punti_bar = $Barra_Punti  # Barra di progresso dei punti
@onready var punti_label = $Barra_Punti/Punti  # Etichetta testuale dei punti
@onready var timer_punti = $TimerPunti  # Timer per generare punti nel tempo

@onready var carta1 = $BarraCarte/Carta  # Carta cannone A
@onready var carta2 = $BarraCarte/Carta2  # Carta cannone B

func _ready():
	#Avvia il timer che aggiunge punti ogni tot secondi
	timer_punti.start()
	#Connetti gli eventi di click delle carte alle funzioni corrispondenti
	carta1.gui_input.connect(_on_Carta1_clicked)
	carta2.gui_input.connect(_on_Carta2_clicked)

#Click su Carta1 (Cannone A)
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

#Click su Carta2 (Cannone B)
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

#Crea un'anteprima semitrasparente del cannone selezionato che segue il mouse
func crea_anteprima(cannone_tipo: String):
	if anteprima_cannone:
		print("🧹 Rimuovo anteprima precedente")
		anteprima_cannone.queue_free()

	if carta_selezionata != null:
		anteprima_cannone = carta_selezionata.instantiate() as StaticBody2D
		add_child(anteprima_cannone)
		anteprima_cannone.modulate.a = 0.5  # Semitrasparente
		anteprima_cannone.global_position = get_viewport().get_mouse_position()
		print("🆕 Creata nuova anteprima:", cannone_tipo)

#Gestione click finale per piazzare il cannone sulla mappa
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if anteprima_cannone:
			print("✅ Confermato posizionamento di", tipo_cannone_selezionato)
			anteprima_cannone.modulate.a = 1.0  # Ora è completamente visibile
			anteprima_cannone.attivo = true  # Attivazione della logica di sparo

			# Sottrae i punti in base al cannone selezionato
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

			# Reset delle variabili per permettere nuove selezioni
			anteprima_cannone = null
			carta_selezionata = null
			tipo_cannone_selezionato = ""

#Aggiorna la UI dei punti (barra + testo)
func aggiorna_punti():
	print("🔄 Aggiornamento barra punti:", punti)
	punti_label.text = "Punti: %d/10" % punti
	punti_bar.value = punti

#Fa seguire l’anteprima del cannone al mouse
func _process(delta: float) -> void:
	if anteprima_cannone:
		anteprima_cannone.global_position = get_viewport().get_mouse_position()

#Timer attivo: ogni tot secondi aggiunge 1 punto (massimo 10)
func _on_TimerPunti_timeout():
	print("⏲️ Timer attivato! Punti prima:", punti)
	punti += 1
	if punti > 10:
		punti = 10  # Non supera mai il limite massimo
	print("⏲️ Timer - punti incrementati a", punti)
	aggiorna_punti()
