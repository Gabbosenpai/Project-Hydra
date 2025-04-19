extends CharacterBody2D

# Velocità del proiettile in pixel al secondo
var velocita = 300

# Direzione verso cui si muove il proiettile (in questo caso verso destra)
var velocitaVettore = Vector2.RIGHT  # Vector2(1, 0)

# Variabile per identificare il cannone che ha sparato il proiettile
var tipo_cannone = "CannoneA"  # Default, se non definito
var danno = 20  # Danno di default


# Imposta il tipo di cannone
func set_cannon_type(tipo: String) -> void:
	tipo_cannone = tipo

# Imposta il danno del proiettile
func set_damage(danno_val: int) -> void:
	danno = danno_val

# Restituisci il tipo di cannone
func get_cannon_type() -> String:
	return tipo_cannone


func _physics_process(delta: float) -> void:
	# Muove il proiettile e rileva eventuali collisioni lungo il percorso
	var infoCollisione = move_and_collide(velocitaVettore * velocita * delta)

	# Se il proiettile collide con qualcosa
	if infoCollisione:
		var corpo = infoCollisione.get_collider()

		# Stampa il nome del corpo con cui ha colliso (utile per il debug)
		print("Proiettile ha colliso con:", corpo.name)

		# Se il corpo fa parte del gruppo "Nemico"
		if corpo.is_in_group("Nemico"):
			print("Proiettile ha colpito un nemico!")

			# Se il nemico ha il metodo 'take_damage', allora infliggi danno
			if corpo.has_method("take_damage"):
				corpo.take_damage(danno)   # Infligge il danno configurato
				print("Danno inflitto al nemico. Tipo cannone:", tipo_cannone)

		# Indipendentemente dal tipo di collisione, distruggi il proiettile
		queue_free()
		print("Proiettile distrutto dopo la collisione.")
