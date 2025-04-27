extends CanvasLayer

var punti = 10  # Elisir iniziale
var carta_selezionata : PackedScene = null
var anteprima_cannone : StaticBody2D = null  # Cambia la variabile in StaticBody2D
var tipo_cannone_selezionato: String = ""

const COSTO_CANNONE1 = 5
const COSTO_CANNONE2 = 7

@onready var punti_bar = $Barra_Punti
@onready var punti_label = $Barra_Punti/Punti
@onready var timer_punti = $TimerPunti

@onready var carta1 = $BarraCarte/Carta
@onready var carta2 = $BarraCarte/Carta2


func _ready():
	timer_punti.start()
	carta1.gui_input.connect(_on_Carta1_clicked)
	carta2.gui_input.connect(_on_Carta2_clicked)

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

func crea_anteprima(cannone_tipo: String):
	if anteprima_cannone:
		print("🧹 Rimuovo anteprima precedente")
		anteprima_cannone.queue_free()

	if carta_selezionata != null:
		anteprima_cannone = carta_selezionata.instantiate() as StaticBody2D
		add_child(anteprima_cannone)
		anteprima_cannone.modulate.a = 0.5
		anteprima_cannone.global_position = get_viewport().get_mouse_position()
		print("🆕 Creata nuova anteprima:", cannone_tipo)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if anteprima_cannone:
			print("✅ Confermato posizionamento di", tipo_cannone_selezionato)
			anteprima_cannone.modulate.a = 1.0
			# Ora controlliamo il tipo, non il nome nodo!
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
			anteprima_cannone = null
			carta_selezionata = null
			tipo_cannone_selezionato = ""  # 🆕 Resetti il tipo selezionato

func aggiorna_punti():
	print("🔄 Aggiornamento barra punti:", punti)
	punti_label.text = "Punti: %d/10" % punti
	punti_bar.value = punti

func _process(delta: float) -> void:
	if anteprima_cannone:
		anteprima_cannone.global_position = get_viewport().get_mouse_position()

func _on_TimerPunti_timeout():
	print("⏲️ Timer attivato! Punti prima:", punti)
	punti += 1
	if punti > 10:
		punti = 10
	print("⏲️ Timer - punti incrementati a", punti)
	aggiorna_punti()
