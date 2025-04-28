extends StaticBody2D

# Carica la scena del proiettile in anticipo
const percorsoProiettile = preload("res://Scene/Proiettile/proiettile.tscn")

# Lista per tenere traccia dei nemici rilevati
var nemici_rilevati = []

# Tempo da attendere tra uno sparo e l'altro (in secondi)
var tempo_tra_spari = 0.3
var timer_sparo = 0.0  # Timer per controllare il tempo tra gli spari

var danno_proiettile = 40  # Imposta il danno per i proiettili del Cannone B (puoi cambiarlo)
var attivo: bool = false  # Nuovo - il cannone spara solo se attivo

func _ready() -> void:
	# Collega i segnali di entrata e uscita all'Area2D usata per il rilevamento
	$Area_Rilevamento.body_entered.connect(_on_body_entered)
	print("Segnale connesso? Area_Rilevamento valido:", $Area_Rilevamento != null)
	$Area_Rilevamento.body_exited.connect(_on_body_exited)
	
	# Imposta il timer per il primo sparo
	timer_sparo = tempo_tra_spari
	print("Cannone pronto a sparare, timer impostato su:", timer_sparo)

func _process(delta: float) -> void:
	if not attivo:
		return  # Se non attivo, non fa niente
	# Se ci sono nemici rilevati, gestisci il conto alla rovescia per lo sparo
	if nemici_rilevati.size() > 0:
		print("Nemici rilevati! Timer rimasto:", timer_sparo)
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
		# Imposta il tipo di cannone e il danno specifico
		proiettile.set_cannon_type("CannoneB")  # Imposta il tipo di cannone per il proiettile
		proiettile.set_damage(danno_proiettile)  # Imposta il danno del proiettile
		
		print("Proiettile sparato alla posizione:", proiettile.global_position)
	else:
		print("Posizione_Proiettile node not found!")  # Nodo mancante

# Funzione chiamata quando un corpo entra nell'area di rilevamento
func _on_body_entered(body: Node) -> void:
	print("Corpo entrato:", body.name)
	if body.is_in_group("Nemico"):
		print("Nemico entrato nell'area di rilevamento!")
		nemici_rilevati.append(body)  # Aggiungi il nemico alla lista dei rilevati

# Funzione chiamata quando un corpo esce dall'area di rilevamento
func _on_body_exited(body: Node) -> void:
	print("Corpo uscito dall'area di rilevamento:", body.name)
	if body.is_in_group("Nemico"):
		print("Nemico uscito dall'area di rilevamento!")
		nemici_rilevati.erase(body)  # Rimuovi il nemico dalla lista dei rilevati
