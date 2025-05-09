extends StaticBody2D  # Il cannone è un oggetto statico nella scena, non si muove

# Carica in anticipo la scena del proiettile per evitare di farlo a runtime
const percorsoProiettile = preload("res://Scene/Proiettile/proiettile.tscn")

# Lista dei nemici attualmente dentro l'area di rilevamento del cannone
var nemici_rilevati = []

# Tempo da attendere tra uno sparo e l'altro
var tempo_tra_spari = 1.0
var timer_sparo = 0.0  # Conta quanto manca al prossimo sparo
var attivo: bool = false  # Il cannone spara solo se è stato attivato da fuori

func _ready() -> void:
	# Inizializza il timer per lo sparo
	timer_sparo = tempo_tra_spari
	print("Cannone pronto a sparare, timer impostato su:", timer_sparo)

func _process(delta: float) -> void:
	# Se il cannone non è attivo, esce subito
	if not attivo:
		return
	
	# Pulisce la lista rimuovendo riferimenti a nemici già distrutti o usciti dalla scena
	nemici_rilevati = nemici_rilevati.filter(func(n): return is_instance_valid(n))

	# Se ci sono nemici, avvia il conto alla rovescia per sparare
	if nemici_rilevati.size() > 0:
		print("Nemici rilevati:", nemici_rilevati.size(), " - Timer:", timer_sparo)
		timer_sparo -= delta  # Scala il timer con il tempo trascorso

		if timer_sparo <= 0:
			# Se il tempo è scaduto, spara un proiettile
			print("Sparando proiettile!")
			spara()
			timer_sparo = tempo_tra_spari  # Reset del timer
			print("Timer resetto a:", timer_sparo)

func spara():
	print("Inizio sparo...")  # Messaggio di debug
	# Crea un'istanza del proiettile
	var proiettile = percorsoProiettile.instantiate()
	get_parent().add_child(proiettile)  # Aggiunge il proiettile alla scena principale

	# Ottiene la posizione da cui sparare il proiettile
	var posizione = $Posizione_Proiettile
	if posizione != null:
		proiettile.global_position = posizione.global_position
		proiettile.velocity = Vector2(1, 0)  # Imposta la direzione verso destra
		print("Proiettile sparato alla posizione:", proiettile.global_position)
	else:
		print("Posizione_Proiettile node non trovato!")

# Quando un corpo entra nell'area di rilevamento
func _on_body_entered(body: Node) -> void:
	print("Corpo entrato:", body.name)
	print("Layer body:", body.collision_layer)
	print("Mask area:", $Area_Rilevamento.collision_mask)
	print("Tipo:", body.get_class())
	print("Gruppi:", body.get_groups())

	# Se il corpo appartiene al gruppo "Nemico", lo aggiunge alla lista
	if body.is_in_group("Nemico") and body not in nemici_rilevati:
		nemici_rilevati.append(body)
		print("Nemico aggiunto. Totale nemici:", nemici_rilevati.size())

# Quando un corpo esce dall'area di rilevamento
func _on_body_exited(body: Node) -> void:
	print("Corpo uscito dall'area di rilevamento:", body.name)
	# Se il corpo era un nemico, lo rimuove dalla lista
	if body.is_in_group("Nemico"):
		nemici_rilevati.erase(body)
		print("Nemico rimosso. Rimasti:", nemici_rilevati.size())
