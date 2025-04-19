extends StaticBody2D

# Carica la scena del proiettile in anticipo
const percorsoProiettile = preload("res://Scene/Proiettile/proiettile.tscn")

# Variabile per sapere se un nemico è stato rilevato
var nemico_rilevato = false

# Tempo da attendere tra uno sparo e l'altro (in secondi)
var tempo_tra_spari = 1.0
var timer_sparo = 0.0  # Timer per controllare il tempo tra gli spari

func _ready() -> void:
	# Collega i segnali di entrata e uscita all'Area2D usata per il rilevamento
	$Area_Rilevamento.body_entered.connect(_on_body_entered)
	print("Segnale connesso? Area_Rilevamento valido:", $Area_Rilevamento != null)
	$Area_Rilevamento.body_exited.connect(_on_body_exited)
	
	# Imposta il timer per il primo sparo
	timer_sparo = tempo_tra_spari
	print("Cannone pronto a sparare, timer impostato su:", timer_sparo)

func _process(delta: float) -> void:
	# Se un nemico è rilevato, gestisci il conto alla rovescia per lo sparo
	if nemico_rilevato:
		print("Nemico rilevato! Timer rimasto:", timer_sparo)
		timer_sparo -= delta  # Scala il timer con il tempo reale

		if timer_sparo <= 0:
			# Quando il timer è scaduto, spara un proiettile
			print("Sparando proiettile!")
			spara()
			timer_sparo = tempo_tra_spari  # Resetta il timer per lo sparo successivo
			print("Timer resetto a:", timer_sparo)

func spara():
	print("Inizio sparo...")  # Debug
	# Istanzia un nuovo proiettile dalla scena
	var proiettile = percorsoProiettile.instantiate()
	get_parent().add_child(proiettile)  # Aggiunge il proiettile alla scena

	# Posiziona il proiettile nella posizione del nodo Posizione_Proiettile
	var posizione = $Posizione_Proiettile
	if posizione != null:
		proiettile.global_position = posizione.global_position
		proiettile.velocity = Vector2(1, 0)  # Imposta la direzione verso destra
		print("Proiettile sparato alla posizione:", proiettile.global_position)
	else:
		print("Posizione_Proiettile node not found!")  # Nodo mancante

# Funzione chiamata quando un corpo entra nell'area di rilevamento
func _on_body_entered(body: Node) -> void:
	print("Corpo entrato:", body.name)
	print("Layer body:", body.collision_layer)
	print("Mask area:", $Area_Rilevamento.collision_mask)
	print("Corpo entrato nell'area di rilevamento:", body.name)
	print("Tipo:", body.get_class())
	print("Gruppi:", body.get_groups())

	# Se il corpo fa parte del gruppo "Nemico", lo consideriamo rilevato
	if body.is_in_group("Nemico"):
		print("Nemico entrato nell'area di rilevamento!")
		nemico_rilevato = true

# Funzione chiamata quando un corpo esce dall'area di rilevamento
func _on_body_exited(body: Node) -> void:
	print("Corpo uscito dall'area di rilevamento:", body.name)
	if body.is_in_group("Nemico"):
		print("Nemico uscito dall'area di rilevamento!")
		nemico_rilevato = false
